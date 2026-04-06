package cmd

import (
	"context"
	"crypto/ed25519"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/spf13/cobra"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/federation"
	"github.com/nicholasgasior/pulse-server/internal/privacy"
	"github.com/nicholasgasior/pulse-server/internal/relay"
	"github.com/nicholasgasior/pulse-server/internal/sfu"
	"github.com/nicholasgasior/pulse-server/internal/store"
	"github.com/nicholasgasior/pulse-server/internal/transport"
	"github.com/nicholasgasior/pulse-server/internal/tunnel"
	"github.com/nicholasgasior/pulse-server/internal/turn"
)

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "Start the Pulse relay server",
	Long:  "Starts the WebSocket relay server and begins accepting connections.",
	RunE:  runServe,
}

func init() {
	rootCmd.AddCommand(serveCmd)
}

func runServe(cmd *cobra.Command, args []string) error {
	// Load config
	cfg, err := config.Load(cfgFile)
	if err != nil {
		return err
	}

	// Override data_dir from CLI flag if set
	if cmd.Flags().Changed("data-dir") {
		cfg.Server.DataDir = dataDir
	}

	log.Printf("[serve] Pulse relay server starting")
	log.Printf("[serve] config: %s, data dir: %s", cfgFile, cfg.Server.DataDir)
	log.Printf("[serve] auth mode: %s, TLS mode: %s", cfg.Auth.Mode, cfg.Server.TLSMode)

	// Open database
	db, err := store.Open(cfg.Server.DataDir)
	if err != nil {
		return err
	}
	defer db.Close()

	// Run migrations
	if err := store.Migrate(db); err != nil {
		return err
	}
	log.Printf("[serve] database migrations complete")

	// Initialize stores
	users := store.NewUserStore(db)
	messages := store.NewMessageStore(db)
	invites := store.NewInviteStore(db)
	keys := store.NewKeyStore(db)
	backups := store.NewBackupStore(db)

	// Initialize file store
	fileStore := store.NewFileStore(db, cfg.Server.DataDir)
	if err := fileStore.EnsureDirs(); err != nil {
		return err
	}
	log.Printf("[serve] file store initialized")

	// Initialize hub
	hub := relay.NewHub(cfg, users, messages, invites, keys, backups)
	hub.SetFileStore(fileStore)
	go hub.Run()
	log.Printf("[serve] hub started")

	// Initialize TURN server
	var turnSrv *turn.Server
	if cfg.Turn.Enabled {
		turnSrv = turn.NewServer()

		// Load or generate TURN secret via the key store
		var turnSecret []byte
		kb, err := keys.GetBundle("_server_turn_secret")
		if err == nil && kb != nil {
			turnSecret = kb.Bundle
		}

		if err := turnSrv.Start(cfg.Turn.Port, cfg.Turn.Realm, turnSecret); err != nil {
			log.Printf("[serve] WARNING: failed to start TURN server: %v", err)
			turnSrv = nil
		} else {
			// Persist the secret if it was newly generated
			if kb == nil {
				if err := keys.PutBundle("_server_turn_secret", turnSrv.Secret()); err != nil {
					log.Printf("[serve] WARNING: failed to persist TURN secret: %v", err)
				}
			}
			log.Printf("[serve] TURN server started on port %d", cfg.Turn.Port)
		}
	}

	// Initialize federation
	var peerManager *federation.PeerManager
	if cfg.Federation.Enabled {
		// Load or generate federation keypair
		var fedAuth *federation.FederationAuth
		kb, kbErr := keys.GetBundle("_server_federation_key")
		if kbErr == nil && kb != nil {
			privKey := ed25519.PrivateKey(kb.Bundle)
			fa, faErr := federation.NewFederationAuth(privKey)
			if faErr != nil {
				log.Printf("[serve] WARNING: failed to load federation key: %v", faErr)
			} else {
				fedAuth = fa
			}
		}
		if fedAuth == nil {
			fa, faErr := federation.NewFederationAuth(nil)
			if faErr != nil {
				log.Printf("[serve] WARNING: failed to generate federation key: %v", faErr)
			} else {
				fedAuth = fa
				if putErr := keys.PutBundle("_server_federation_key", []byte(fedAuth.PrivateKey)); putErr != nil {
					log.Printf("[serve] WARNING: failed to persist federation key: %v", putErr)
				}
			}
		}

		if fedAuth != nil {
			log.Printf("[serve] federation pubkey: %s", fedAuth.PubkeyHex())

			// Create the peer manager and router together
			var router *federation.FederationRouter
			peerManager = federation.NewPeerManager(fedAuth, func(env *federation.FederatedEnvelope) {
				if router != nil {
					router.HandleIncoming(env, "")
				}
			})
			router = federation.NewFederationRouter(users, peerManager, hub, db, &cfg.Federation)

			// Load saved peers from DB and connect
			rows, qErr := db.Query("SELECT pubkey, address FROM federation_peers WHERE enabled = 1")
			if qErr == nil {
				for rows.Next() {
					var pubkey, address string
					if err := rows.Scan(&pubkey, &address); err != nil {
						log.Printf("[serve] failed to scan federation peer: %v", err)
						continue
					}
					if err := peerManager.AddPeer(address, pubkey); err != nil {
						log.Printf("[serve] failed to add federation peer %s: %v", pubkey, err)
					}
				}
				rows.Close()
			}
			log.Printf("[serve] federation enabled")
		}
	}

	// Set TURN server on hub for auth
	if turnSrv != nil {
		hub.SetTurnServer(turnSrv)
	}

	// Initialize SFU manager (Phase 2)
	var sfuMgr *sfu.Manager
	if cfg.Media.Enabled {
		// Pass nil listener for now — ICE-TCP mux listener is set up during TLS init
		sfuMgr = sfu.NewManager(&cfg.Media, nil)
		hub.SetSFUManager(sfuMgr)
		log.Printf("[serve] SFU media relay enabled (mode: %s)", cfg.Media.Mode)
	}

	// Initialize tunnel manager (Phase 5)
	var tunnelMgr *tunnel.Manager
	if cfg.Tunnel.Enabled {
		tunnelMgr = tunnel.NewManager(&cfg.Tunnel)
		hub.SetTunnelManager(tunnelMgr)
		log.Printf("[serve] tunnel/proxy enabled")
	}

	// Initialize padding service (Phase 6)
	paddingSvc := privacy.NewPaddingService(
		cfg.Privacy.Padding,
		cfg.Privacy.PaddingMode,
		cfg.Privacy.PaddingRateKbps,
		cfg.Privacy.PaddingJitterPct,
		cfg.Privacy.Chaff,
		cfg.Privacy.ChaffIntervalSec,
	)
	hub.SetPaddingService(paddingSvc)
	paddingSvc.Start()

	// Initialize sealed sender service (Phase 6)
	if cfg.Privacy.SealedSender {
		certCount := cfg.Privacy.SealedCertCount
		if certCount <= 0 {
			certCount = 10
		}
		certTTL := cfg.Privacy.SealedCertTTL
		if certTTL == "" {
			certTTL = "24h"
		}
		sealedSvc := privacy.NewSealedSenderService(certCount, certTTL)

		// Persist or restore the HMAC secret
		sealedKB, sealedErr := keys.GetBundle("_server_sealed_secret")
		if sealedErr == nil && sealedKB != nil {
			sealedSvc.SetSecret(sealedKB.Bundle)
		} else {
			if putErr := keys.PutBundle("_server_sealed_secret", sealedSvc.Secret()); putErr != nil {
				log.Printf("[serve] WARNING: failed to persist sealed sender secret: %v", putErr)
			}
		}

		hub.SetSealedSenderService(sealedSvc)
		log.Printf("[serve] sealed sender enabled (certs: %d, ttl: %s)", certCount, certTTL)
	}

	// Initialize transport server
	srv := transport.NewServer(cfg, hub, users, invites, messages, turnSrv, peerManager)

	// Signal handling for graceful shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	errCh := make(chan error, 1)
	go func() {
		errCh <- srv.ListenAndServe()
	}()

	select {
	case err := <-errCh:
		if err != nil {
			log.Printf("[serve] server error: %v", err)
			return err
		}
	case sig := <-sigCh:
		log.Printf("[serve] received signal %v, shutting down", sig)
	}

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30)
	defer cancel()

	if peerManager != nil {
		peerManager.Stop()
	}

	if turnSrv != nil {
		turnSrv.Stop()
	}

	if sfuMgr != nil {
		sfuMgr.Stop()
	}

	if tunnelMgr != nil {
		tunnelMgr.Stop()
	}

	paddingSvc.Stop()

	hub.Stop()

	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("[serve] shutdown error: %v", err)
		return err
	}

	log.Printf("[serve] server stopped")
	return nil
}
