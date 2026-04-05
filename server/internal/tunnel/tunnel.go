package tunnel

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/nicholasgasior/pulse-server/config"
)

// HeaderSize is the binary tunnel frame header size (1 type + 16 tunnelID).
const HeaderSize = 17

// Manager handles all active tunnels.
type Manager struct {
	cfg    *config.TunnelConfig
	mu     sync.RWMutex
	byUser map[string]map[string]*Tunnel // pubkey → tunnelID → Tunnel
	stopCh chan struct{}
}

// Tunnel represents a single TCP tunnel connection.
type Tunnel struct {
	ID         string
	Owner      string // pubkey
	Host       string
	Port       int
	conn       net.Conn
	sendToWS   func([]byte) error // callback to send binary to client
	limiter    *TokenBucket
	bytesUp    atomic.Int64
	bytesDown  atomic.Int64
	closedOnce sync.Once
	done       chan struct{}
}

// TokenBucket implements a simple token bucket rate limiter.
type TokenBucket struct {
	mu         sync.Mutex
	tokens     int64 // current available tokens (bytes)
	maxTokens  int64 // bucket capacity
	refillRate int64 // bytes per second
	lastRefill time.Time
}

// NewTokenBucket creates a rate limiter with the given Mbps limit.
func NewTokenBucket(mbps int) *TokenBucket {
	bytesPerSec := int64(mbps) * 1000000 / 8
	return &TokenBucket{
		tokens:     bytesPerSec, // start full
		maxTokens:  bytesPerSec, // 1 second worth of burst
		refillRate: bytesPerSec,
		lastRefill: time.Now(),
	}
}

// Allow checks if n bytes can be consumed, refilling tokens first.
func (tb *TokenBucket) Allow(n int) bool {
	tb.mu.Lock()
	defer tb.mu.Unlock()

	// Refill tokens based on elapsed time
	now := time.Now()
	elapsed := now.Sub(tb.lastRefill).Seconds()
	tb.tokens += int64(elapsed * float64(tb.refillRate))
	if tb.tokens > tb.maxTokens {
		tb.tokens = tb.maxTokens
	}
	tb.lastRefill = now

	if tb.tokens >= int64(n) {
		tb.tokens -= int64(n)
		return true
	}
	return false
}

// NewManager creates a new tunnel manager.
func NewManager(cfg *config.TunnelConfig) *Manager {
	return &Manager{
		cfg:    cfg,
		byUser: make(map[string]map[string]*Tunnel),
		stopCh: make(chan struct{}),
	}
}

// OpenTunnel opens a new TCP tunnel for a user.
func (m *Manager) OpenTunnel(pubkey, tunnelID, host string, port int, sendToWS func([]byte) error) (string, error) {
	if !m.cfg.Enabled {
		return "", fmt.Errorf("tunnel_disabled")
	}

	// Check concurrent tunnel limit
	m.mu.RLock()
	userTunnels := m.byUser[pubkey]
	m.mu.RUnlock()

	if len(userTunnels) >= m.cfg.MaxTunnelsPerUser {
		return "", fmt.Errorf("rate_limited")
	}

	// Validate port
	if len(m.cfg.AllowedPorts) > 0 {
		allowed := false
		for _, p := range m.cfg.AllowedPorts {
			if p == port {
				allowed = true
				break
			}
		}
		if !allowed {
			return "", fmt.Errorf("blocked")
		}
	}

	// Check blocked hosts
	for _, pattern := range m.cfg.BlockedHosts {
		if matchHostPattern(pattern, host) {
			return "", fmt.Errorf("blocked")
		}
	}

	// Resolve DNS (via DoH if configured)
	addr, err := m.resolveHost(host, port)
	if err != nil {
		return "", fmt.Errorf("dns_failed")
	}

	// Prevent SSRF — reject private IPs
	if isPrivateAddr(addr) {
		return "", fmt.Errorf("blocked")
	}

	// Connect to target
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	dialer := &net.Dialer{}
	conn, err := dialer.DialContext(ctx, "tcp", addr)
	if err != nil {
		if ctx.Err() == context.DeadlineExceeded {
			return "", fmt.Errorf("timeout")
		}
		return "", fmt.Errorf("connection_refused")
	}

	t := &Tunnel{
		ID:       tunnelID,
		Owner:    pubkey,
		Host:     host,
		Port:     port,
		conn:     conn,
		sendToWS: sendToWS,
		done:     make(chan struct{}),
	}
	// Apply bandwidth limit if configured
	if m.cfg.BandwidthLimitMbps > 0 {
		t.limiter = NewTokenBucket(m.cfg.BandwidthLimitMbps)
	}

	m.mu.Lock()
	if m.byUser[pubkey] == nil {
		m.byUser[pubkey] = make(map[string]*Tunnel)
	}
	m.byUser[pubkey][tunnelID] = t
	m.mu.Unlock()

	// Get the remote IP for tunnel_opened response
	remoteIP := ""
	if tcpAddr, ok := conn.RemoteAddr().(*net.TCPAddr); ok {
		remoteIP = tcpAddr.IP.String()
	}

	// Start reading from TCP and forwarding to WS
	go t.readLoop()

	return remoteIP, nil
}

// readLoop reads from the TCP connection and sends binary tunnel frames to the WS client.
func (t *Tunnel) readLoop() {
	defer t.Close()

	buf := make([]byte, 32768) // 32KB read buffer
	tidBytes := tunnelIDBytes(t.ID)

	for {
		select {
		case <-t.done:
			return
		default:
		}

		t.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		n, err := t.conn.Read(buf)
		if n > 0 {
			// Enforce bandwidth limit on downstream too
			if t.limiter != nil && !t.limiter.Allow(n) {
				continue // drop frame if over limit
			}
			t.bytesDown.Add(int64(n))
			// Build binary frame: 0x21 + tunnelID(16) + payload
			frame := make([]byte, HeaderSize+n)
			frame[0] = 0x21 // tunnel data, server→client
			copy(frame[1:17], tidBytes)
			copy(frame[HeaderSize:], buf[:n])

			if err := t.sendToWS(frame); err != nil {
				return
			}
		}
		if err != nil {
			if err != io.EOF {
				log.Printf("[tunnel] read error for %s: %v", t.ID[:8], err)
			}
			return
		}
	}
}

// WriteData writes data received from the WS client to the TCP connection.
func (t *Tunnel) WriteData(data []byte) error {
	// Enforce bandwidth limit via token bucket
	if t.limiter != nil && !t.limiter.Allow(len(data)) {
		return fmt.Errorf("bandwidth limit exceeded")
	}
	t.bytesUp.Add(int64(len(data)))
	_, err := t.conn.Write(data)
	return err
}

// Close closes the tunnel.
func (t *Tunnel) Close() {
	t.closedOnce.Do(func() {
		close(t.done)
		t.conn.Close()
	})
}

// CloseTunnel closes a specific tunnel for a user.
func (m *Manager) CloseTunnel(pubkey, tunnelID string) {
	m.mu.Lock()
	userTunnels := m.byUser[pubkey]
	if userTunnels != nil {
		if t, ok := userTunnels[tunnelID]; ok {
			t.Close()
			delete(userTunnels, tunnelID)
			if len(userTunnels) == 0 {
				delete(m.byUser, pubkey)
			}
		}
	}
	m.mu.Unlock()
}

// CloseAllForUser closes all tunnels for a user.
func (m *Manager) CloseAllForUser(pubkey string) {
	m.mu.Lock()
	userTunnels := m.byUser[pubkey]
	if userTunnels != nil {
		for _, t := range userTunnels {
			t.Close()
		}
		delete(m.byUser, pubkey)
	}
	m.mu.Unlock()
}

// HandleTunnelData handles a binary tunnel frame from the client (0x20).
func (m *Manager) HandleTunnelData(pubkey string, data []byte) {
	if len(data) < HeaderSize {
		return
	}

	tunnelID := fmt.Sprintf("%x", data[1:17])
	payload := data[HeaderSize:]

	m.mu.RLock()
	userTunnels := m.byUser[pubkey]
	var t *Tunnel
	if userTunnels != nil {
		t = userTunnels[tunnelID]
	}
	m.mu.RUnlock()

	if t == nil {
		return
	}

	if err := t.WriteData(payload); err != nil {
		log.Printf("[tunnel] write error for %s: %v", tunnelID[:8], err)
		m.CloseTunnel(pubkey, tunnelID)
	}
}

// Stop shuts down all tunnels.
func (m *Manager) Stop() {
	close(m.stopCh)
	m.mu.Lock()
	for pubkey, tunnels := range m.byUser {
		for _, t := range tunnels {
			t.Close()
		}
		delete(m.byUser, pubkey)
	}
	m.mu.Unlock()
}

// resolveHost resolves a hostname to an address.
func (m *Manager) resolveHost(host string, port int) (string, error) {
	// If already an IP, just return with port
	if ip := net.ParseIP(host); ip != nil {
		return fmt.Sprintf("%s:%d", host, port), nil
	}

	if m.cfg.DNSProvider == "doh" {
		addr, err := resolveDoH(host)
		if err != nil {
			// Fallback to system resolver
			log.Printf("[tunnel] DoH failed for %s, falling back to system: %v", host, err)
			addrs, sysErr := net.LookupHost(host)
			if sysErr != nil {
				return "", sysErr
			}
			if len(addrs) == 0 {
				return "", fmt.Errorf("no addresses found for %s", host)
			}
			return fmt.Sprintf("%s:%d", addrs[0], port), nil
		}
		return fmt.Sprintf("%s:%d", addr, port), nil
	}

	return fmt.Sprintf("%s:%d", host, port), nil
}

// dohResponse represents the Cloudflare/Google DoH JSON response.
type dohResponse struct {
	Status int `json:"Status"`
	Answer []struct {
		Type int    `json:"type"`
		Data string `json:"data"`
	} `json:"Answer"`
}

// resolveDoH resolves a hostname via DNS-over-HTTPS (Cloudflare).
func resolveDoH(host string) (string, error) {
	url := fmt.Sprintf("https://cloudflare-dns.com/dns-query?name=%s&type=A", host)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Accept", "application/dns-json")

	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("DoH request failed: %w", err)
	}
	defer resp.Body.Close()

	var doh dohResponse
	if err := json.NewDecoder(resp.Body).Decode(&doh); err != nil {
		return "", fmt.Errorf("DoH decode failed: %w", err)
	}

	if doh.Status != 0 {
		return "", fmt.Errorf("DoH returned status %d", doh.Status)
	}

	// Find first A record (type 1)
	for _, ans := range doh.Answer {
		if ans.Type == 1 {
			if ip := net.ParseIP(ans.Data); ip != nil {
				return ip.String(), nil
			}
		}
	}

	// Try AAAA (type 28)
	for _, ans := range doh.Answer {
		if ans.Type == 28 {
			if ip := net.ParseIP(ans.Data); ip != nil {
				return ip.String(), nil
			}
		}
	}

	return "", fmt.Errorf("no A/AAAA records in DoH response for %s", host)
}

// isPrivateAddr checks if an address resolves to a private/loopback IP (SSRF prevention).
func isPrivateAddr(addr string) bool {
	host, _, err := net.SplitHostPort(addr)
	if err != nil {
		return true // err on the side of caution
	}

	ip := net.ParseIP(host)
	if ip == nil {
		// Try resolving
		addrs, err := net.LookupHost(host)
		if err != nil || len(addrs) == 0 {
			return true
		}
		ip = net.ParseIP(addrs[0])
		if ip == nil {
			return true
		}
	}

	// Normalize to 4-byte form if IPv4
	if ip4 := ip.To4(); ip4 != nil {
		ip = ip4
	}

	// Check private ranges
	privateRanges := []struct {
		network *net.IPNet
	}{
		{parseCIDR("10.0.0.0/8")},
		{parseCIDR("172.16.0.0/12")},
		{parseCIDR("192.168.0.0/16")},
		{parseCIDR("127.0.0.0/8")},
		{parseCIDR("169.254.0.0/16")},
		{parseCIDR("::1/128")},
		{parseCIDR("fc00::/7")},
		{parseCIDR("fe80::/10")},
	}

	for _, r := range privateRanges {
		if r.network.Contains(ip) {
			return true
		}
	}
	return false
}

func parseCIDR(s string) *net.IPNet {
	_, n, _ := net.ParseCIDR(s)
	return n
}

// matchHostPattern matches a host against a wildcard pattern like "*.gov.cn".
func matchHostPattern(pattern, host string) bool {
	if strings.HasPrefix(pattern, "*.") {
		suffix := pattern[1:] // ".gov.cn"
		return strings.HasSuffix(host, suffix) || host == pattern[2:]
	}
	return host == pattern
}

// tunnelIDBytes converts a hex tunnel ID to 16 bytes.
func tunnelIDBytes(id string) []byte {
	b := make([]byte, 16)
	decoded, _ := decodeHexPadded(id, 16)
	copy(b, decoded)
	return b
}

func decodeHexPadded(s string, size int) ([]byte, error) {
	b := make([]byte, size)
	// Remove dashes if UUID format
	s = strings.ReplaceAll(s, "-", "")
	decoded := make([]byte, len(s)/2)
	for i := 0; i < len(s)/2 && i < size; i++ {
		_, err := fmt.Sscanf(s[i*2:i*2+2], "%02x", &decoded[i])
		if err != nil {
			return b, err
		}
		b[i] = decoded[i]
	}
	return b, nil
}
