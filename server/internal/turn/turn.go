package turn

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"encoding/base64"
	"fmt"
	"log"
	"net"
	"strconv"
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
// If secret is nil, a random secret is generated.
// tlsListener is optional — if provided, TURNS (TURN over TLS) is served on it
// (typically the shared TLS listener on port 443).
func (s *Server) Start(port int, realm string, secret []byte, tlsListener net.Listener) error {
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

	// Open UDP listener
	udpListener, err := net.ListenPacket("udp4", "0.0.0.0:"+strconv.Itoa(port))
	if err != nil {
		return fmt.Errorf("failed to listen on UDP port %d: %w", port, err)
	}

	// Open TCP listener on same port (optional — may fail if port is in use)
	var listenerConfigs []turn.ListenerConfig
	tcpListener, tcpErr := net.Listen("tcp4", "0.0.0.0:"+strconv.Itoa(port))
	if tcpErr != nil {
		log.Printf("[turn] WARNING: TCP on port %d unavailable (%v) — UDP only", port, tcpErr)
	} else {
		listenerConfigs = append(listenerConfigs, turn.ListenerConfig{
			Listener: tcpListener,
			RelayAddressGenerator: &turn.RelayAddressGeneratorStatic{
				RelayAddress: net.ParseIP("0.0.0.0"),
				Address:      "0.0.0.0",
			},
		})
	}

	// Add TLS listener for TURNS on port 443 (multiplexed with HTTPS)
	if tlsListener != nil {
		listenerConfigs = append(listenerConfigs, turn.ListenerConfig{
			Listener: tlsListener,
			RelayAddressGenerator: &turn.RelayAddressGeneratorStatic{
				RelayAddress: net.ParseIP("0.0.0.0"),
				Address:      "0.0.0.0",
			},
		})
		log.Printf("[turn] TURNS listener added (shared TLS port)")
	}

	// Create the TURN server
	logFactory := logging.NewDefaultLoggerFactory()
	logFactory.DefaultLogLevel = logging.LogLevelWarn

	srv, err := turn.NewServer(turn.ServerConfig{
		Realm: realm,
		AuthHandler: func(username, realm string, srcAddr net.Addr) ([]byte, bool) {
			return s.authHandler(username, realm)
		},
		PacketConnConfigs: []turn.PacketConnConfig{
			{
				PacketConn: udpListener,
				RelayAddressGenerator: &turn.RelayAddressGeneratorStatic{
					RelayAddress: net.ParseIP("0.0.0.0"),
					Address:      "0.0.0.0",
				},
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
	log.Printf("[turn] TURN server started on %s port %d (realm: %s)", transports, port, realm)
	return nil
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

	uris := []string{
		fmt.Sprintf("turn:%s:%d?transport=udp", host, port),
		fmt.Sprintf("turn:%s:%d?transport=tcp", host, port),
	}
	// Advertise TURNS on the TLS port (typically 443) — looks like regular
	// HTTPS to DPI, making it censorship-resistant.
	if tlsPort > 0 {
		uris = append(uris, fmt.Sprintf("turns:%s:%d?transport=tcp", host, tlsPort))
	}

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
