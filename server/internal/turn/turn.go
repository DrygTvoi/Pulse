package turn

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"encoding/base64"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/pion/logging"
	"github.com/pion/turn/v3"
)

const (
	credentialTTL = 24 * time.Hour
	secretBytes   = 32

	// credentialRateWindow is the cooldown window per-pubkey: repeat calls
	// to GenerateCredentials within this window return the cached credentials
	// rather than minting a new HMAC (which would shift the expiry and waste
	// churn). Clients that re-connect rapidly (reconnect storms, flaky
	// networks) benefit most.
	credentialRateWindow = 10 * time.Second

	// credentialCacheTTL is how long a cache entry lives before being eligible
	// for cleanup. Anything older than this is discarded during the periodic
	// sweep so the cache cannot grow unbounded if a pubkey stops calling.
	credentialCacheTTL = 1 * time.Hour

	// cleanupEvery triggers a cleanup sweep on every Nth GenerateCredentials
	// call — cheap amortised maintenance without a background goroutine.
	cleanupEvery = 100

	// previousSecretTTL is how long a rotated-out secret remains valid so
	// already-issued credentials keep working until their own expiry.
	previousSecretTTL = 6 * time.Hour
)

// credCacheEntry is one pubkey's most recent credential plus when it was issued.
type credCacheEntry struct {
	creds    *Credentials
	issuedAt time.Time
}

// Server wraps a pion/turn TURN server with ephemeral credential support.
type Server struct {
	mu         sync.RWMutex
	server     *turn.Server
	secret     []byte
	realm      string
	port       int
	publicHost string // hostname/IP used in TURN URIs (defaults to realm)
	tlsPort    int    // TLS port for turns: URIs (0 = not advertised)

	// previousSecret holds the previously-active secret after a rotation so
	// credentials issued under it continue to authenticate until their TTL
	// naturally expires. previousSecretAt is the rotation timestamp — entries
	// older than previousSecretTTL are discarded.
	previousSecret   []byte
	previousSecretAt time.Time

	// credCache maps pubkey -> *credCacheEntry for per-user rate limiting on
	// GenerateCredentials. sync.Map is appropriate here: the key space is
	// effectively unbounded (one per user) and reads dominate writes.
	credCache sync.Map

	// credCallCount is incremented atomically-ish under mu to decide when to
	// sweep the cache. A plain int under the existing mutex is sufficient —
	// GenerateCredentials already takes the lock briefly.
	credCallCount uint64
}

// SetPublicHost overrides the hostname used in generated TURN URIs.
func (s *Server) SetPublicHost(host string) {
	s.mu.Lock()
	s.publicHost = host
	s.mu.Unlock()
}

// SetTLSPort sets the port advertised in turns: URIs (typically 443).
func (s *Server) SetTLSPort(port int) {
	s.mu.Lock()
	s.tlsPort = port
	s.mu.Unlock()
}

// Credentials holds a generated TURN credential set.
type Credentials struct {
	Username string   `json:"username"`
	Password string   `json:"password"`
	TTL      int      `json:"ttl"`
	URIs     []string `json:"uris"`
}

// NewServer creates a new TURN server instance. Call Start() to begin listening.
func NewServer() *Server {
	return &Server{}
}

// Start begins the TURN relay on the given UDP port with the specified realm.
// publicIP is the server's external IP — used in XOR-RELAYED-ADDRESS so relay-
// to-relay (hairpin) works correctly.  If empty, the realm is DNS-resolved.
// If secret is nil, a random secret is generated.
// tlsListener is optional — if provided, TURNS (TURN over TLS) is served on it
// (typically the shared TLS listener on port 443).
func (s *Server) Start(port int, realm string, secret []byte, tlsListener net.Listener, publicIP string, extraListeners ...net.Listener) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.server != nil {
		return fmt.Errorf("TURN server already running")
	}

	// Generate secret if not provided
	if secret == nil {
		secret = make([]byte, secretBytes)
		if _, err := rand.Read(secret); err != nil {
			return fmt.Errorf("failed to generate TURN secret: %w", err)
		}
	}
	s.secret = secret
	s.realm = realm
	s.port = port

	// Resolve the external relay address for XOR-RELAYED-ADDRESS.
	// Without this, Address="0.0.0.0" causes relay-to-relay hairpin failures
	// because the TURN server can't route between its own allocations.
	relayAddr := resolvePublicIP(publicIP, realm)
	log.Printf("[turn] relay address: %s (publicIP=%q, realm=%q)", relayAddr, publicIP, realm)

	// Open UDP listener
	udpListener, err := net.ListenPacket("udp4", "0.0.0.0:"+strconv.Itoa(port))
	if err != nil {
		return fmt.Errorf("failed to listen on UDP port %d: %w", port, err)
	}

	relayGen := func() *turn.RelayAddressGeneratorStatic {
		return &turn.RelayAddressGeneratorStatic{
			RelayAddress: net.ParseIP(relayAddr), // advertised to clients in XOR-RELAYED-ADDRESS
			Address:      "0.0.0.0",              // bind to all interfaces
		}
	}

	// Open TCP listener on same port (optional — may fail if port is in use)
	var listenerConfigs []turn.ListenerConfig
	tcpListener, tcpErr := net.Listen("tcp4", "0.0.0.0:"+strconv.Itoa(port))
	if tcpErr != nil {
		log.Printf("[turn] WARNING: TCP on port %d unavailable (%v) — UDP only", port, tcpErr)
	} else {
		listenerConfigs = append(listenerConfigs, turn.ListenerConfig{
			Listener:              tcpListener,
			RelayAddressGenerator: relayGen(),
		})
	}

	// Add TLS listener for TURNS on port 443 (multiplexed with HTTPS)
	if tlsListener != nil {
		listenerConfigs = append(listenerConfigs, turn.ListenerConfig{
			Listener:              tlsListener,
			RelayAddressGenerator: relayGen(),
		})
		log.Printf("[turn] TURNS listener added (shared TLS port)")
	}

	// Add extra listeners (e.g., TURN-over-WebSocket virtual listener)
	for i, ln := range extraListeners {
		if ln != nil {
			listenerConfigs = append(listenerConfigs, turn.ListenerConfig{
				Listener:              ln,
				RelayAddressGenerator: relayGen(),
			})
			log.Printf("[turn] extra listener #%d added (TURN-over-WS)", i)
		}
	}

	// Create the TURN server
	logFactory := logging.NewDefaultLoggerFactory()
	logFactory.DefaultLogLevel = logging.LogLevelInfo

	srv, err := turn.NewServer(turn.ServerConfig{
		Realm: realm,
		AuthHandler: func(username, realm string, srcAddr net.Addr) ([]byte, bool) {
			return s.authHandler(username, realm)
		},
		PacketConnConfigs: []turn.PacketConnConfig{
			{
				PacketConn:            udpListener,
				RelayAddressGenerator: relayGen(),
			},
		},
		ListenerConfigs: listenerConfigs,
		LoggerFactory:   logFactory,
	})
	if err != nil {
		udpListener.Close()
		if tcpListener != nil {
			tcpListener.Close()
		}
		return fmt.Errorf("failed to create TURN server: %w", err)
	}

	s.server = srv
	transports := "UDP"
	if tcpListener != nil {
		transports += "+TCP"
	}
	if tlsListener != nil {
		transports += "+TLS"
	}
	log.Printf("[turn] TURN server started on %s port %d (realm: %s, relay: %s)", transports, port, realm, relayAddr)
	return nil
}

// resolvePublicIP determines the external IP for relay address generation.
// Priority: explicit publicIP → DNS resolve realm → auto-detect via HTTP → 0.0.0.0.
func resolvePublicIP(publicIP, realm string) string {
	// Explicit IP provided
	if publicIP != "" {
		if ip := net.ParseIP(publicIP); ip != nil {
			return publicIP
		}
		// It's a hostname — resolve it
		ips, err := net.LookupHost(publicIP)
		if err == nil && len(ips) > 0 {
			return ips[0]
		}
		log.Printf("[turn] WARNING: could not resolve publicIP %q: %v", publicIP, err)
	}

	// Try resolving realm
	if realm != "" {
		if ip := net.ParseIP(realm); ip != nil {
			return realm
		}
		ips, err := net.LookupHost(realm)
		if err == nil && len(ips) > 0 {
			return ips[0]
		}
		log.Printf("[turn] WARNING: could not resolve realm %q: %v", realm, err)
	}

	// Auto-detect public IP via external services
	if ip := detectPublicIP(); ip != "" {
		log.Printf("[turn] auto-detected public IP: %s", ip)
		return ip
	}

	log.Printf("[turn] WARNING: could not determine public IP — relay address will be 0.0.0.0 (TURN will not work for remote peers)")
	return "0.0.0.0"
}

// detectPublicIP tries external services to determine the server's public IP.
func detectPublicIP() string {
	services := []string{
		"https://api.ipify.org",
		"https://ifconfig.me/ip",
		"https://icanhazip.com",
	}
	for _, url := range services {
		if ip := httpGetIP(url); ip != "" {
			return ip
		}
	}
	return ""
}

func httpGetIP(url string) string {
	resp, err := (&http.Client{Timeout: 5 * time.Second}).Get(url)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 64))
	if err != nil {
		return ""
	}
	ip := strings.TrimSpace(string(body))
	if net.ParseIP(ip) != nil {
		return ip
	}
	return ""
}


// Stop gracefully shuts down the TURN server.
func (s *Server) Stop() error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.server == nil {
		return nil
	}

	err := s.server.Close()
	s.server = nil
	if err != nil {
		return fmt.Errorf("failed to stop TURN server: %w", err)
	}
	log.Printf("[turn] TURN server stopped")
	return nil
}

// GenerateCredentials creates ephemeral TURN credentials for the given pubkey.
// Username format: "expiry_timestamp:pubkey"
// Password: base64(HMAC-SHA1(secret, username))
//
// Per-pubkey rate limit: repeat calls within credentialRateWindow return the
// cached credentials instead of minting a fresh HMAC (and fresh expiry). This
// keeps reconnect-storm clients on a stable credential and dampens churn.
// Every cleanupEvery-th call triggers a sweep that discards entries older than
// credentialCacheTTL so the cache cannot grow without bound.
func (s *Server) GenerateCredentials(pubkey string) (*Credentials, error) {
	// Rate-limit: if we issued creds for this pubkey recently, reuse them.
	now := time.Now()
	if v, ok := s.credCache.Load(pubkey); ok {
		if e, ok := v.(*credCacheEntry); ok && e != nil && e.creds != nil {
			if now.Sub(e.issuedAt) < credentialRateWindow {
				// Return a copy to avoid callers mutating shared state.
				c := *e.creds
				urisCopy := make([]string, len(e.creds.URIs))
				copy(urisCopy, e.creds.URIs)
				c.URIs = urisCopy
				return &c, nil
			}
		}
	}

	s.mu.Lock()
	secret := s.secret
	realm := s.realm
	port := s.port
	host := s.publicHost
	tlsPort := s.tlsPort
	s.credCallCount++
	shouldSweep := s.credCallCount%cleanupEvery == 0
	s.mu.Unlock()

	if secret == nil {
		return nil, fmt.Errorf("TURN server not initialized")
	}

	if host == "" {
		host = realm
	}

	expiry := now.Add(credentialTTL).Unix()
	username := strconv.FormatInt(expiry, 10) + ":" + pubkey

	mac := hmac.New(sha1.New, secret)
	mac.Write([]byte(username))
	password := base64.StdEncoding.EncodeToString(mac.Sum(nil))

	// Advertise both TURNS (TLS/TCP on 443) and plain TURN (UDP on dedicated port).
	// TURNS is preferred for censorship resistance, but some clients (Waydroid,
	// older Android) may fail TLS-based TURN allocation — UDP fallback ensures
	// connectivity.
	var uris []string
	if tlsPort > 0 {
		uris = append(uris, fmt.Sprintf("turns:%s:%d?transport=tcp", host, tlsPort))
	}
	// Always include plain UDP TURN as fallback
	uris = append(uris, fmt.Sprintf("turn:%s:%d?transport=udp", host, port))

	creds := &Credentials{
		Username: username,
		Password: password,
		TTL:      int(credentialTTL.Seconds()),
		URIs:     uris,
	}

	// Cache for rate-limit purposes.
	s.credCache.Store(pubkey, &credCacheEntry{creds: creds, issuedAt: now})

	if shouldSweep {
		s.sweepCredCache(now)
	}

	return creds, nil
}

// sweepCredCache removes entries older than credentialCacheTTL. Called
// amortised (every cleanupEvery-th GenerateCredentials call) to bound cache
// size without a background goroutine.
func (s *Server) sweepCredCache(now time.Time) {
	cutoff := now.Add(-credentialCacheTTL)
	s.credCache.Range(func(k, v any) bool {
		if e, ok := v.(*credCacheEntry); ok && e != nil && e.issuedAt.Before(cutoff) {
			s.credCache.Delete(k)
		}
		return true
	})
}

// RotateSecret swaps in a new TURN secret, retaining the previous one for
// previousSecretTTL so credentials already issued under it continue to
// authenticate until they reach their own expiry. The credential rate-limit
// cache is cleared because entries are keyed to the old secret and would
// otherwise hand out stale passwords for up to credentialRateWindow.
//
// Not called automatically — exposed for an operator-triggered CLI.
func (s *Server) RotateSecret(newSecret []byte) {
	if len(newSecret) == 0 {
		return
	}
	cpy := make([]byte, len(newSecret))
	copy(cpy, newSecret)

	s.mu.Lock()
	s.previousSecret = s.secret
	s.previousSecretAt = time.Now()
	s.secret = cpy
	s.mu.Unlock()

	// Drop cached creds so reconnects pick up the new secret immediately.
	s.credCache.Range(func(k, _ any) bool {
		s.credCache.Delete(k)
		return true
	})
}

// Secret returns the current TURN secret for persistence.
func (s *Server) Secret() []byte {
	s.mu.RLock()
	defer s.mu.RUnlock()
	cpy := make([]byte, len(s.secret))
	copy(cpy, s.secret)
	return cpy
}

// authHandler validates ephemeral credentials using the HMAC-SHA1 scheme.
// It returns the password key for pion/turn's internal validation.
//
// After a RotateSecret call the previous secret remains valid for
// previousSecretTTL. authHandler tries the current secret first, then the
// previous one, so credentials issued under the old secret keep working
// until their TTL expires.
func (s *Server) authHandler(username, realm string) ([]byte, bool) {
	s.mu.RLock()
	secret := s.secret
	prevSecret := s.previousSecret
	prevAt := s.previousSecretAt
	s.mu.RUnlock()

	if secret == nil {
		return nil, false
	}

	// Parse expiry from username (format: "timestamp:pubkey")
	var expiryStr string
	for i, c := range username {
		if c == ':' {
			expiryStr = username[:i]
			break
		}
	}
	if expiryStr == "" {
		return nil, false
	}

	expiry, err := strconv.ParseInt(expiryStr, 10, 64)
	if err != nil {
		return nil, false
	}

	// Check if credential has expired
	now := time.Now()
	if now.Unix() > expiry {
		return nil, false
	}

	// Try current secret first.
	mac := hmac.New(sha1.New, secret)
	mac.Write([]byte(username))
	password := base64.StdEncoding.EncodeToString(mac.Sum(nil))
	key := turn.GenerateAuthKey(username, realm, password)

	// Fall back to the previous (rotated-out) secret if it's still within the
	// grace window. pion/turn compares the returned key against the one it
	// computed from the client's MESSAGE-INTEGRITY, so we return the previous
	// secret's key when the current one wouldn't match. We can't know which
	// secret the client used without timing-leaking comparisons, so the real
	// fallback is handled by pion: if auth fails with the current key, this
	// function won't be called again. Since pion expects a single key return,
	// we pick the previous-secret key only when the credential's expiry falls
	// inside the pre-rotation window — a best-effort heuristic that keeps
	// in-flight credentials working.
	if len(prevSecret) > 0 && !prevAt.IsZero() && now.Sub(prevAt) < previousSecretTTL {
		// If the username's expiry is older than (prevAt + credentialTTL),
		// it was plausibly minted under the previous secret. Prefer that key.
		issuedBefore := time.Unix(expiry, 0).Before(prevAt.Add(credentialTTL))
		if issuedBefore {
			macOld := hmac.New(sha1.New, prevSecret)
			macOld.Write([]byte(username))
			passwordOld := base64.StdEncoding.EncodeToString(macOld.Sum(nil))
			key = turn.GenerateAuthKey(username, realm, passwordOld)
		}
	}

	return key, true
}
