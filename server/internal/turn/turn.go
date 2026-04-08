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
)

// Server wraps a pion/turn TURN server with ephemeral credential support.
type Server struct {
	mu         sync.RWMutex
	server     *turn.Server
	secret     []byte
	realm      string
	port       int
	publicHost string // hostname/IP used in TURN URIs (defaults to realm)
	tlsPort    int    // TLS port for turns: URIs (0 = not advertised)
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
func (s *Server) Start(port int, realm string, secret []byte, tlsListener net.Listener, publicIP string) error {
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
func (s *Server) GenerateCredentials(pubkey string) (*Credentials, error) {
	s.mu.RLock()
	secret := s.secret
	realm := s.realm
	port := s.port
	host := s.publicHost
	tlsPort := s.tlsPort
	s.mu.RUnlock()

	if secret == nil {
		return nil, fmt.Errorf("TURN server not initialized")
	}

	if host == "" {
		host = realm
	}

	expiry := time.Now().Add(credentialTTL).Unix()
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

	return &Credentials{
		Username: username,
		Password: password,
		TTL:      int(credentialTTL.Seconds()),
		URIs:     uris,
	}, nil
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
func (s *Server) authHandler(username, realm string) ([]byte, bool) {
	s.mu.RLock()
	secret := s.secret
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
	if time.Now().Unix() > expiry {
		return nil, false
	}

	// Compute expected password
	mac := hmac.New(sha1.New, secret)
	mac.Write([]byte(username))
	password := base64.StdEncoding.EncodeToString(mac.Sum(nil))

	// Return the key that pion/turn uses for auth validation
	return turn.GenerateAuthKey(username, realm, password), true
}
