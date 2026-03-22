package transport

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"time"

	"github.com/gorilla/websocket"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/federation"
	"github.com/nicholasgasior/pulse-server/internal/relay"
	"github.com/nicholasgasior/pulse-server/internal/store"
	"github.com/nicholasgasior/pulse-server/internal/turn"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  4096,
	WriteBufferSize: 4096,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins since this is not a browser app
	},
}

// Server holds the HTTP server and its dependencies.
type Server struct {
	httpServer  *http.Server
	hub         *relay.Hub
	cfg         *config.Config
	users       *store.UserStore
	invites     *store.InviteStore
	turnServer  *turn.Server
	peerManager *federation.PeerManager
	startTime   time.Time
}

// NewServer creates a new transport server.
func NewServer(cfg *config.Config, hub *relay.Hub, users *store.UserStore, invites *store.InviteStore, turnSrv *turn.Server, pm *federation.PeerManager) *Server {
	s := &Server{
		hub:         hub,
		cfg:         cfg,
		users:       users,
		invites:     invites,
		turnServer:  turnSrv,
		peerManager: pm,
		startTime:   time.Now(),
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/ws", s.handleWebSocket)
	mux.HandleFunc("/health", s.handleHealth)

	// TURN credentials endpoint (only if TURN is enabled)
	if turnSrv != nil {
		mux.HandleFunc("/turn/credentials", s.handleTurnCredentials)
	}

	// Federation endpoint (only if federation is enabled)
	if pm != nil {
		mux.HandleFunc("/federation", s.handleFederation)
	}

	s.httpServer = &http.Server{
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	return s
}

// ListenAndServe starts the server on the configured address.
func (s *Server) ListenAndServe() error {
	addr := s.cfg.Server.Listen
	log.Printf("[transport] starting server on %s (TLS mode: %s)", addr, s.cfg.Server.TLSMode)

	// Create dual-stack listener
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return fmt.Errorf("failed to listen on %s: %w", addr, err)
	}

	switch s.cfg.Server.TLSMode {
	case "none", "":
		log.Printf("[transport] serving plain HTTP/WebSocket on %s", addr)
		return s.httpServer.Serve(ln)

	case "self-signed":
		tlsCfg, err := GenerateSelfSignedTLS()
		if err != nil {
			ln.Close()
			return fmt.Errorf("failed to generate self-signed TLS: %w", err)
		}
		tlsLn := tls.NewListener(ln, tlsCfg)
		log.Printf("[transport] serving TLS (self-signed) on %s", addr)
		return s.httpServer.Serve(tlsLn)

	case "manual":
		tlsCfg, err := LoadTLS(s.cfg.Server.TLSCert, s.cfg.Server.TLSKey)
		if err != nil {
			ln.Close()
			return fmt.Errorf("failed to load TLS certificates: %w", err)
		}
		tlsLn := tls.NewListener(ln, tlsCfg)
		log.Printf("[transport] serving TLS (manual) on %s", addr)
		return s.httpServer.Serve(tlsLn)

	case "auto":
		ln.Close()
		return fmt.Errorf("TLS mode 'auto' (Let's Encrypt) is not yet implemented — use 'manual' or 'self-signed'")

	default:
		ln.Close()
		return fmt.Errorf("unknown TLS mode: %s", s.cfg.Server.TLSMode)
	}
}

// Shutdown gracefully shuts down the server.
func (s *Server) Shutdown(ctx context.Context) error {
	return s.httpServer.Shutdown(ctx)
}

// handleWebSocket upgrades an HTTP connection to WebSocket and creates a client.
func (s *Server) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	if s.hub.MaxConnectionsReached() {
		http.Error(w, "server at capacity", http.StatusServiceUnavailable)
		return
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[transport] WebSocket upgrade failed: %v", err)
		return
	}

	client := relay.NewClient(s.hub, conn, s.cfg, s.users, s.invites)
	client.Start()
}

// handleHealth returns a simple health check response.
func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"status": "ok",
	})
}

// handleTurnCredentials generates ephemeral TURN credentials for an authenticated client.
func (s *Server) handleTurnCredentials(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	pubkey := r.URL.Query().Get("pubkey")
	if pubkey == "" {
		http.Error(w, "missing pubkey parameter", http.StatusBadRequest)
		return
	}

	creds, err := s.turnServer.GenerateCredentials(pubkey)
	if err != nil {
		log.Printf("[transport] failed to generate TURN credentials for %s: %v", pubkey, err)
		http.Error(w, "failed to generate credentials", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(creds)
}

// handleFederation upgrades to WebSocket for server-to-server federation.
func (s *Server) handleFederation(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[transport] federation WebSocket upgrade failed: %v", err)
		return
	}

	if err := s.peerManager.AcceptPeer(conn); err != nil {
		log.Printf("[transport] federation accept failed: %v", err)
	}
}

// StartTime returns the server start time.
func (s *Server) StartTime() time.Time {
	return s.startTime
}
