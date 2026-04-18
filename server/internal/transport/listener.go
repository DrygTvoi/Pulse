package transport

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"strings"
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
	httpServer   *http.Server
	hub          *relay.Hub
	cfg          *config.Config
	users        *store.UserStore
	invites      *store.InviteStore
	messages     *store.MessageStore
	turnServer   *turn.Server
	peerManager  *federation.PeerManager
	decoyHandler *DecoyHandler
	certFP       string
	startTime    time.Time
	tcpListener  net.Listener // raw TCP listener for ICE-TCP mux sharing
	stunListener net.Listener // STUN connections from TLS mux (for TURNS on 443)
}

// NewServer creates a new transport server.
func NewServer(cfg *config.Config, hub *relay.Hub, users *store.UserStore, invites *store.InviteStore, messages *store.MessageStore, turnSrv *turn.Server, pm *federation.PeerManager) *Server {
	s := &Server{
		hub:          hub,
		cfg:          cfg,
		users:        users,
		invites:      invites,
		messages:     messages,
		turnServer:   turnSrv,
		peerManager:  pm,
		decoyHandler: NewDecoyHandler(cfg.Decoy),
		startTime:    time.Now(),
	}

	// Internal mux for known endpoints
	innerMux := http.NewServeMux()
	innerMux.HandleFunc("/ws", s.handleWebSocket)

	// NOTE: /turn/credentials removed — TURN creds are delivered inside auth_ok.
	// An open HTTP endpoint was a fingerprint (non-nginx response to probers).

	if pm != nil {
		innerMux.HandleFunc("/federation", s.handleFederation)
	}

	// Sealed sender endpoint
	innerMux.HandleFunc("/sealed", s.handleSealedSend)

	// Metrics endpoints (Phase 7) — auth checked in probeResistantHandler
	// so failed attempts get consistent nginx decoy responses (not Go's http.NotFound)
	if hub.Metrics() != nil {
		innerMux.HandleFunc("/metrics", hub.Metrics().PrometheusHandler())
		innerMux.HandleFunc("/metrics/json", hub.Metrics().JSONHandler())
	}


	// Probe-resistant wrapper: unknown paths → decoy
	var handler http.Handler = s.probeResistantHandler(innerMux)

	// Access logging middleware (when enabled)
	if cfg.Privacy.AccessLog {
		handler = accessLogMiddleware(handler)
	}

	// Server header on ALL responses — looks like nginx to scanners/DPI
	handler = serverHeaderMiddleware(handler, "nginx/1.24.0")

	s.httpServer = &http.Server{
		Handler:     handler,
		IdleTimeout: 120 * time.Second,
		// NOTE: ReadTimeout/WriteTimeout removed — they interfere with
		// long-lived WebSocket connections after Hijack().
	}

	return s
}

// SetCertFP sets the TLS certificate fingerprint for auth_ok.
func (s *Server) SetCertFP(fp string) {
	s.certFP = fp
}

// probeResistantHandler wraps the internal mux.
// Known WS endpoints require proper WebSocket upgrade; all other paths serve the decoy.
func (s *Server) probeResistantHandler(inner *http.ServeMux) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Strip forwarded headers if configured
		if s.cfg.Privacy.StripForwardedHeaders {
			r.Header.Del("X-Forwarded-For")
			r.Header.Del("X-Real-IP")
			r.Header.Del("Forwarded")
		}

		path := r.URL.Path

		switch path {
		case "/ws":
			// WebSocket — requires upgrade + pulse protocol header
			if !isWebSocketUpgrade(r) {
				s.decoyHandler.ServeHTTP(w, r)
				return
			}
			inner.ServeHTTP(w, r)

		case "/health":
			// Minimal response — don't expose JSON structure or server identity
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("ok"))

		case "/federation":
			if s.peerManager != nil && isWebSocketUpgrade(r) {
				inner.ServeHTTP(w, r)
			} else {
				s.decoyHandler.ServeHTTP(w, r)
			}

		case "/sealed":
			// Sealed sender endpoint — requires WS upgrade
			if !isWebSocketUpgrade(r) {
				s.decoyHandler.ServeHTTP(w, r)
				return
			}
			inner.ServeHTTP(w, r)

		case "/metrics", "/metrics/json":
			// Metrics require valid secret token — wrong/missing token → decoy
			// (consistent nginx 404, not Go's http.NotFound which differs)
			secret := s.cfg.Limits.MetricsSecret
			if secret == "" {
				s.decoyHandler.ServeHTTP(w, r)
				return
			}
			token := r.URL.Query().Get("token")
			if token == "" {
				auth := r.Header.Get("Authorization")
				if strings.HasPrefix(auth, "Bearer ") {
					token = auth[7:]
				}
			}
			if token != secret {
				s.decoyHandler.ServeHTTP(w, r)
				return
			}
			inner.ServeHTTP(w, r)

		default:
			// All unknown paths → decoy website
			s.decoyHandler.ServeHTTP(w, r)
		}
	})
}

func isWebSocketUpgrade(r *http.Request) bool {
	for _, v := range r.Header.Values("Connection") {
		// Handle comma-separated values: "keep-alive, Upgrade"
		for _, part := range strings.Split(v, ",") {
			if strings.EqualFold(strings.TrimSpace(part), "upgrade") {
				return true
			}
		}
	}
	return false
}

// STUNListener returns a net.Listener that receives only STUN/TURN connections
// from the shared TLS port. Must be called BEFORE ListenAndServe.
// Returns nil if TURN multiplexing is not applicable (no TLS, no TURN server).
func (s *Server) STUNListener() net.Listener {
	return s.stunListener
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
	s.tcpListener = ln

	switch s.cfg.Server.TLSMode {
	case "none", "":
		log.Printf("[transport] serving plain HTTP/WebSocket on %s", addr)
		return s.httpServer.Serve(ln)

	case "self-signed":
		tlsCfg, fp, fresh, err := LoadOrGenerateSelfSignedTLS(s.cfg.Server.DataDir)
		if err != nil {
			ln.Close()
			return fmt.Errorf("failed to generate self-signed TLS: %w", err)
		}
		s.certFP = fp
		if fresh {
			fmt.Printf("CERT_FP %s\n", fp)
		}
		log.Printf("[transport] cert fingerprint: %s (fresh=%v)", fp, fresh)
		tlsLn := tls.NewListener(ln, tlsCfg)
		httpLn := s.maybeEnableTURNMux(tlsLn)
		log.Printf("[transport] serving TLS (self-signed) on %s", addr)
		return s.httpServer.Serve(httpLn)

	case "manual":
		tlsCfg, err := LoadTLS(s.cfg.Server.TLSCert, s.cfg.Server.TLSKey)
		if err != nil {
			ln.Close()
			return fmt.Errorf("failed to load TLS certificates: %w", err)
		}
		s.certFP = CertFingerprint(tlsCfg)
		if s.certFP != "" {
			fmt.Printf("CERT_FP %s\n", s.certFP)
			log.Printf("[transport] cert fingerprint: %s", s.certFP)
		}
		tlsLn := tls.NewListener(ln, tlsCfg)
		httpLn := s.maybeEnableTURNMux(tlsLn)
		log.Printf("[transport] serving TLS (manual) on %s", addr)
		return s.httpServer.Serve(httpLn)

	case "auto":
		ln.Close()
		tlsCfg, acmeMgr, err := AutoTLS(s.cfg.Server.AutoTLSDomain, s.cfg.Server.DataDir)
		if err != nil {
			return fmt.Errorf("failed to configure auto TLS: %w", err)
		}
		go http.ListenAndServe(":80", acmeMgr.HTTPHandler(nil))
		tlsLn, err := net.Listen("tcp", addr)
		if err != nil {
			return fmt.Errorf("failed to listen on %s: %w", addr, err)
		}
		autoLn := tls.NewListener(tlsLn, tlsCfg)
		httpLn := s.maybeEnableTURNMux(autoLn)
		log.Printf("[transport] serving TLS (auto/Let's Encrypt) on %s for domain %s", addr, s.cfg.Server.AutoTLSDomain)
		return s.httpServer.Serve(httpLn)

	default:
		ln.Close()
		return fmt.Errorf("unknown TLS mode: %s", s.cfg.Server.TLSMode)
	}
}

// maybeEnableTURNMux splits the TLS listener into STUN (for TURN) and HTTP
// streams if a TURN server is configured. Returns the HTTP listener to serve.
// If no TURN server, returns the original TLS listener unchanged.
func (s *Server) maybeEnableTURNMux(tlsLn net.Listener) net.Listener {
	if s.turnServer == nil {
		return tlsLn
	}
	stunLn := newChanListener(tlsLn.Addr())
	httpLn := newChanListener(tlsLn.Addr())
	s.stunListener = stunLn
	go muxAcceptLoop(tlsLn, stunLn, httpLn)
	log.Printf("[transport] STUN/HTTP multiplexer enabled on TLS port")
	return httpLn
}

// Shutdown gracefully shuts down the server.
func (s *Server) Shutdown(ctx context.Context) error {
	return s.httpServer.Shutdown(ctx)
}

// handleWebSocket upgrades an HTTP connection to WebSocket and creates a client.
func (s *Server) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	if s.hub.MaxConnectionsReached() {
		s.decoyHandler.ServeHTTP(w, r)
		return
	}

	// Check for valid WebSocket subprotocol — use neutral name to avoid fingerprinting.
	// Accept both legacy "pulse.auth" and new "mqtt" (camouflage).
	proto := r.Header.Get("Sec-WebSocket-Protocol")
	hasMqtt := strings.Contains(proto, "mqtt")
	hasPulse := strings.Contains(proto, "pulse")
	if !hasMqtt && !hasPulse {
		// No valid protocol header → decoy response
		s.decoyHandler.ServeHTTP(w, r)
		return
	}

	// Negotiate the subprotocol the client offered
	negotiated := "mqtt"
	if !hasMqtt && hasPulse {
		negotiated = "pulse.auth"
	}

	// Upgrade with protocol negotiation
	wsUpgrader := websocket.Upgrader{
		ReadBufferSize:  4096,
		WriteBufferSize: 4096,
		CheckOrigin:     func(r *http.Request) bool { return true },
		Subprotocols:    []string{negotiated},
	}

	conn, err := wsUpgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[transport] WebSocket upgrade failed: %v", err)
		return
	}

	client := relay.NewClient(s.hub, conn, s.cfg, s.users, s.invites, s.messages, s.certFP)
	client.SetRemoteIP(extractIP(r))
	client.Start()
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

// handleSealedSend upgrades to WebSocket and handles sealed sender messages.
func (s *Server) handleSealedSend(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[transport] sealed WS upgrade failed: %v", err)
		return
	}
	defer conn.Close()

	// Read a single sealed_send message
	conn.SetReadDeadline(time.Now().Add(15 * time.Second))
	_, message, err := conn.ReadMessage()
	if err != nil {
		return
	}

	var sealed relay.SealedSend
	if err := json.Unmarshal(message, &sealed); err != nil {
		return // silent — no fingerprinting error messages
	}

	if sealed.Cert == "" || sealed.To == "" || sealed.Body == "" {
		return
	}

	// Respond with generic ack regardless of success — don't leak delivery status
	s.hub.HandleSealedSend(sealed.Cert, sealed.To, sealed.Body)
	conn.WriteJSON(map[string]string{"status": "ok"})
}

// StartTime returns the server start time.
func (s *Server) StartTime() time.Time {
	return s.startTime
}

// extractIP returns the remote IP from the request, stripping port.
func extractIP(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

// accessLogMiddleware wraps a handler with request/response logging.
func accessLogMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rw := &responseWriter{ResponseWriter: w, status: 200}
		next.ServeHTTP(rw, r)
		log.Printf("[access] %s %s %s %d %s", extractIP(r), r.Method, r.URL.Path, rw.status, time.Since(start).Truncate(time.Millisecond))
	})
}

// serverHeaderMiddleware sets a consistent Server header on all responses
// so health/metrics/WS endpoints don't leak the Go default.
func serverHeaderMiddleware(next http.Handler, serverName string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Server", serverName)
		next.ServeHTTP(w, r)
	})
}

type responseWriter struct {
	http.ResponseWriter
	status int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.status = code
	rw.ResponseWriter.WriteHeader(code)
}


// GetTCPListener returns the raw TCP listener for ICE-TCP mux sharing.
// Available after ListenAndServe has been called.
func (s *Server) GetTCPListener() net.Listener {
	return s.tcpListener
}
