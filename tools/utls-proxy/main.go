// pulse-utls-proxy — local HTTP CONNECT proxy with full anti-GFW stack:
//
//   1. ECH (Encrypted Client Hello) — hides real SNI from DPI
//   2. ECH retry configs — auto-recovers when server rotates ECH keys
//   3. TLS fingerprint rotation — Chrome/Firefox/Edge/Safari/Randomized
//   4. DoH resolution of target hostname — bypasses DNS poisoning
//   5. 7 DoH providers — CF, Google, Quad9, AdGuard, Mullvad
//   6. Multi-IP fallback — tries all DoH-resolved IPs
//   7. Probe resistance — looks like nginx on non-CONNECT requests
//   8. 64KB copy buffers — larger TLS records, less distinguishable
//   9. TCP keepalive — detects dead connections
//
// GFW sees: Chrome TLS fingerprint, ECH decoy SNI, connection to known CDN IP.
// GFW does NOT see: real hostname, real SNI, Dart-specific TLS fingerprint.
//
// Usage:
//   pulse-utls-proxy             → prints port to stdout, exits when stdin closes
//
// Build:
//   go build -ldflags="-s -w" -o ../../assets/bins/linux_x64/pulse-utls-proxy .
//   GOARCH=arm64 go build -ldflags="-s -w" -o ../../assets/bins/linux_arm64/pulse-utls-proxy .
//
// Architecture:
//   Dart → CONNECT host:443 → Go proxy (loopback)
//     → DoH resolve host → try each IP with uTLS+ECH+rotating fingerprint
//     → fallback to system DNS if all DoH fail
//     → 502 if everything fails → Dart falls through to Tor/I2P/plain
//
// Items NOT implemented (with reasons):
//   - QUIC/HTTP3: quic-go adds ~10MB, most Nostr relays don't support WS over H3
//   - Domain fronting: CF blocks cross-customer fronting since 2018; ECH provides
//     the same SNI-hiding benefit for CF-hosted relays
//   - Shadowsocks/wstunnel/dnstt: require own server infrastructure (breaks serverless)
//   - Snowflake/Meek direct: these are Tor PTs, already available via Tor chain
//   - WS multiplexing: Dart shared loop already uses 1 WS per relay (optimal)
//   - App-level traffic padding: can't add bytes to TCP tunnel (breaks WS protocol);
//     TLS 1.3 already provides record-level padding
package main

import (
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"net"
	"net/http"
	"os"
	"regexp"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	utls "github.com/refraction-networking/utls"
)

// ─── ECH Config Cache ────────────────────────────────────────────────────────

type echEntry struct {
	configs   []utls.ECHConfig
	fetchedAt time.Time
}

var echCache sync.Map // hostname → *echEntry

const (
	echCacheTTL    = 1 * time.Hour
	echNegativeTTL = 5 * time.Minute // cache "no ECH" to avoid DoH spam
)

var echRe = regexp.MustCompile(`ech="([A-Za-z0-9+/=]+)"`)

// ─── DoH Resolution Cache ────────────────────────────────────────────────────

type dohEntry struct {
	ips       []string
	fetchedAt time.Time
}

var dohCache sync.Map // hostname → *dohEntry

const dohCacheTTL = 10 * time.Minute

// ─── DoH Providers ───────────────────────────────────────────────────────────
//
// All connections by raw IP — no DNS needed to reach the DoH server.
// 7 providers across 5 organizations for maximum resilience.

type dohProvider struct{ ip, sni, path string }

var dohProviders = []dohProvider{
	{"1.1.1.1", "cloudflare-dns.com", "/dns-query"},
	{"1.0.0.1", "cloudflare-dns.com", "/dns-query"},
	{"8.8.8.8", "dns.google", "/resolve"},
	{"8.8.4.4", "dns.google", "/resolve"},
	{"9.9.9.9", "dns.quad9.net", "/dns-query"},
	{"94.140.14.14", "dns.adguard-dns.com", "/dns-query"},
	{"194.242.2.2", "dns.mullvad.net", "/dns-query"},
}

// ─── TLS Fingerprint Rotation ────────────────────────────────────────────────
//
// Rotate through 5 browser fingerprints per connection.
// If GFW blocks one fingerprint, next connection uses a different one.
// HelloRandomized generates a random-but-valid ClientHello each time.

var fingerprints = []utls.ClientHelloID{
	utls.HelloChrome_Auto,
	utls.HelloFirefox_Auto,
	utls.HelloEdge_Auto,
	utls.HelloSafari_Auto,
	utls.HelloRandomized,
}

var fpCounter atomic.Uint64

func nextFingerprint() utls.ClientHelloID {
	idx := fpCounter.Add(1) - 1
	return fingerprints[idx%uint64(len(fingerprints))]
}

// ─── Probe Resistance ────────────────────────────────────────────────────────
//
// Non-CONNECT requests get a fake nginx 404 page.
// Prevents GFW active probing from identifying this as a proxy.
// (Proxy listens on loopback so GFW can't probe it directly, but defense in depth.)

const fakeNginxPage = `<!DOCTYPE html>
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
`

// ─── DoH Transport Factory ──────────────────────────────────────────────────

func makeDohTransport(dohIP, sniHost string) *http.Transport {
	dialer := &net.Dialer{Timeout: 3 * time.Second}
	return &http.Transport{
		DialTLS: func(network, addr string) (net.Conn, error) {
			conn, err := dialer.Dial("tcp", dohIP+":443")
			if err != nil {
				return nil, err
			}
			// Standard crypto/tls — this is an internal DoH call, DPI fingerprint irrelevant
			tlsConn := tls.Client(conn, &tls.Config{ServerName: sniHost})
			if err := tlsConn.Handshake(); err != nil {
				conn.Close()
				return nil, err
			}
			return tlsConn, nil
		},
	}
}

// ─── DoH A-Record Resolution ─────────────────────────────────────────────────
//
// Resolves hostname to IPs via DoH, bypassing GFW DNS poisoning.
// Tries 7 providers in order; caches results for 10 minutes.
// Returns nil if all providers fail — caller falls back to system DNS.

func resolveViaDoH(hostname string) []string {
	// Skip if already an IP address
	if net.ParseIP(hostname) != nil {
		return []string{hostname}
	}

	// Check cache
	if v, ok := dohCache.Load(hostname); ok {
		entry := v.(*dohEntry)
		if time.Since(entry.fetchedAt) < dohCacheTTL {
			return entry.ips
		}
	}

	ips := doResolveA(hostname)
	if len(ips) > 0 {
		dohCache.Store(hostname, &dohEntry{ips: ips, fetchedAt: time.Now()})
		fmt.Fprintf(os.Stderr, "[doh] %s → %v\n", hostname, ips)
	}
	return ips
}

func doResolveA(hostname string) []string {
	for _, p := range dohProviders {
		ips, err := queryARecordViaDoH(hostname, p.ip, p.sni, p.path)
		if err != nil {
			continue
		}
		if len(ips) > 0 {
			return ips
		}
	}
	return nil
}

func queryARecordViaDoH(hostname, dohIP, sniHost, pathPrefix string) ([]string, error) {
	transport := makeDohTransport(dohIP, sniHost)
	client := &http.Client{Transport: transport, Timeout: 5 * time.Second}
	defer client.CloseIdleConnections()

	u := fmt.Sprintf("https://%s%s?name=%s&type=A&do=1", sniHost, pathPrefix, hostname)
	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/dns-json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("HTTP %d", resp.StatusCode)
	}

	body, err := io.ReadAll(io.LimitReader(resp.Body, 64*1024))
	if err != nil {
		return nil, err
	}

	var dnsResp struct {
		Answer []struct {
			Type int    `json:"type"`
			Data string `json:"data"`
		} `json:"Answer"`
	}
	if err := json.Unmarshal(body, &dnsResp); err != nil {
		return nil, err
	}

	var ips []string
	for _, a := range dnsResp.Answer {
		if a.Type != 1 { // A record only
			continue
		}
		ip := strings.TrimSpace(a.Data)
		if net.ParseIP(ip) != nil && !isPrivateIP(ip) {
			ips = append(ips, ip)
		}
	}
	return ips, nil
}

// isPrivateIP filters RFC-1918, loopback, link-local addresses.
// GFW sometimes poisons DNS with private IPs — reject them.
func isPrivateIP(ip string) bool {
	parsed := net.ParseIP(ip)
	if parsed == nil {
		return true
	}
	private := []struct{ network string }{
		{"10.0.0.0/8"},
		{"172.16.0.0/12"},
		{"192.168.0.0/16"},
		{"127.0.0.0/8"},
		{"169.254.0.0/16"},
	}
	for _, p := range private {
		_, cidr, _ := net.ParseCIDR(p.network)
		if cidr != nil && cidr.Contains(parsed) {
			return true
		}
	}
	return false
}

// ─── ECH Config Fetching ─────────────────────────────────────────────────────
//
// Queries DNS HTTPS record (type=65) via DoH for the ech="..." SvcParam.
// Parses ECH config bytes via utls.UnmarshalECHConfigs.
// Caches results: 1h positive, 5min negative.

func fetchECHConfigs(hostname string) []utls.ECHConfig {
	// No ECH for raw IP connections
	if net.ParseIP(hostname) != nil {
		return nil
	}

	// Check cache
	if v, ok := echCache.Load(hostname); ok {
		entry := v.(*echEntry)
		ttl := echCacheTTL
		if entry.configs == nil {
			ttl = echNegativeTTL
		}
		if time.Since(entry.fetchedAt) < ttl {
			return entry.configs
		}
	}

	configs := doFetchECH(hostname)
	echCache.Store(hostname, &echEntry{configs: configs, fetchedAt: time.Now()})
	return configs
}

func doFetchECH(hostname string) []utls.ECHConfig {
	for _, p := range dohProviders {
		configs, err := queryECHViaDoH(hostname, p.ip, p.sni, p.path)
		if err != nil {
			continue
		}
		if configs != nil {
			return configs
		}
		// Provider responded but no ECH record — try next
		// (CF returns ECH, Google/Quad9 may not serve type=65 SvcParams)
	}
	return nil
}

func queryECHViaDoH(hostname, dohIP, sniHost, pathPrefix string) ([]utls.ECHConfig, error) {
	transport := makeDohTransport(dohIP, sniHost)
	client := &http.Client{Transport: transport, Timeout: 5 * time.Second}
	defer client.CloseIdleConnections()

	u := fmt.Sprintf("https://%s%s?name=%s&type=HTTPS&do=1", sniHost, pathPrefix, hostname)
	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/dns-json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("HTTP %d", resp.StatusCode)
	}

	body, err := io.ReadAll(io.LimitReader(resp.Body, 64*1024))
	if err != nil {
		return nil, err
	}

	var dnsResp struct {
		Answer []struct {
			Type int    `json:"type"`
			Data string `json:"data"`
		} `json:"Answer"`
	}
	if err := json.Unmarshal(body, &dnsResp); err != nil {
		return nil, err
	}

	for _, a := range dnsResp.Answer {
		if a.Type != 65 { // HTTPS record
			continue
		}
		m := echRe.FindStringSubmatch(a.Data)
		if m == nil {
			continue
		}
		raw, err := base64.StdEncoding.DecodeString(m[1])
		if err != nil {
			fmt.Fprintf(os.Stderr, "[ech] base64 decode failed: %v\n", err)
			continue
		}
		configs, err := utls.UnmarshalECHConfigs(raw)
		if err != nil {
			fmt.Fprintf(os.Stderr, "[ech] UnmarshalECHConfigs failed: %v\n", err)
			continue
		}
		if len(configs) > 0 {
			return configs, nil
		}
	}
	return nil, nil
}

// ─── TLS Connection ──────────────────────────────────────────────────────────

// dialTLS connects to ip:port with uTLS + optional ECH + rotating fingerprint.
// On ECH rejection with retry configs, automatically reconnects once.
func dialTLS(ip, port, hostname string, echConfigs []utls.ECHConfig) (net.Conn, error) {
	upstream, err := net.DialTimeout("tcp", net.JoinHostPort(ip, port), 10*time.Second)
	if err != nil {
		return nil, err
	}
	// TCP keepalive — detect dead connections
	if tc, ok := upstream.(*net.TCPConn); ok {
		tc.SetKeepAlive(true)
		tc.SetKeepAlivePeriod(30 * time.Second)
	}

	config := &utls.Config{
		ServerName:         hostname,
		InsecureSkipVerify: false,
	}
	if len(echConfigs) > 0 {
		config.ECHConfigs = echConfigs
	}

	fp := nextFingerprint()
	tlsConn := utls.UClient(upstream, config, fp)

	if err := tlsConn.Handshake(); err != nil {
		// Check for ECH retry configs — server rotated keys and sent new ones
		state := tlsConn.ConnectionState()
		if len(state.ECHRetryConfigs) > 0 {
			tlsConn.Close()
			fmt.Fprintf(os.Stderr, "[ech] %s → got retry configs, reconnecting\n", hostname)
			// Update cache with retry configs
			echCache.Store(hostname, &echEntry{
				configs:   state.ECHRetryConfigs,
				fetchedAt: time.Now(),
			})
			// One retry with fresh configs
			return dialTLSWithConfigs(ip, port, hostname, state.ECHRetryConfigs)
		}
		tlsConn.Close()
		return nil, fmt.Errorf("%s (fp=%s)", err, fp.Client)
	}

	echUsed := len(echConfigs) > 0
	fmt.Fprintf(os.Stderr, "[conn] %s → %s (fp=%s, ech=%v)\n",
		hostname, ip, fp.Client, echUsed)
	return tlsConn, nil
}

// dialTLSWithConfigs does a single retry with specific ECH configs.
func dialTLSWithConfigs(ip, port, hostname string, echConfigs []utls.ECHConfig) (net.Conn, error) {
	upstream, err := net.DialTimeout("tcp", net.JoinHostPort(ip, port), 10*time.Second)
	if err != nil {
		return nil, err
	}
	if tc, ok := upstream.(*net.TCPConn); ok {
		tc.SetKeepAlive(true)
		tc.SetKeepAlivePeriod(30 * time.Second)
	}

	config := &utls.Config{
		ServerName:         hostname,
		InsecureSkipVerify: false,
		ECHConfigs:         echConfigs,
	}
	fp := nextFingerprint()
	tlsConn := utls.UClient(upstream, config, fp)
	if err := tlsConn.Handshake(); err != nil {
		tlsConn.Close()
		return nil, err
	}
	fmt.Fprintf(os.Stderr, "[conn] %s → %s (fp=%s, ech=retry)\n",
		hostname, ip, fp.Client)
	return tlsConn, nil
}

// ─── Tunnel ──────────────────────────────────────────────────────────────────

func tunnel(w http.ResponseWriter, upstream net.Conn) {
	hijacker, ok := w.(http.Hijacker)
	if !ok {
		upstream.Close()
		http.Error(w, "hijack unsupported", http.StatusInternalServerError)
		return
	}
	clientConn, _, err := hijacker.Hijack()
	if err != nil {
		upstream.Close()
		return
	}
	clientConn.Write([]byte("HTTP/1.1 200 Connection Established\r\n\r\n"))

	// 64KB buffers — larger TLS records are less distinguishable by DPI
	// than small Dart-default writes. Also reduces syscall overhead.
	done := make(chan struct{}, 2)
	go func() {
		buf := make([]byte, 64*1024)
		io.CopyBuffer(upstream, clientConn, buf)
		done <- struct{}{}
	}()
	go func() {
		buf := make([]byte, 64*1024)
		io.CopyBuffer(clientConn, upstream, buf)
		done <- struct{}{}
	}()
	<-done
	upstream.Close()
	clientConn.Close()
}

// ─── HTTP Handler ────────────────────────────────────────────────────────────

func handleRequest(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodConnect {
		// Probe resistance: look like nginx
		w.Header().Set("Server", "nginx/1.24.0")
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(404)
		w.Write([]byte(fakeNginxPage))
		return
	}
	handleConnect(w, r)
}

func handleConnect(w http.ResponseWriter, r *http.Request) {
	host := r.Host
	if !strings.Contains(host, ":") {
		host += ":443"
	}
	colonIdx := strings.LastIndex(host, ":")
	hostname := host[:colonIdx]
	port := host[colonIdx+1:]

	// Step 1: Resolve via DoH (bypasses DNS poisoning)
	ips := resolveViaDoH(hostname)

	// Step 2: Fetch ECH config (hides real SNI from DPI)
	echConfigs := fetchECHConfigs(hostname)
	if len(echConfigs) > 0 {
		fmt.Fprintf(os.Stderr, "[ech] %s → ECH config ready (%d configs)\n",
			hostname, len(echConfigs))
	}

	// Step 3: Shuffle IPs for load balancing / anti-fingerprinting
	if len(ips) > 1 {
		rand.Shuffle(len(ips), func(i, j int) { ips[i], ips[j] = ips[j], ips[i] })
	}

	// Step 4: Try each DoH-resolved IP with uTLS+ECH+rotating fingerprint
	var lastErr error
	for _, ip := range ips {
		conn, err := dialTLS(ip, port, hostname, echConfigs)
		if err != nil {
			lastErr = err
			fmt.Fprintf(os.Stderr, "[conn] %s via %s failed: %v\n", hostname, ip, err)
			continue
		}
		tunnel(w, conn)
		return
	}

	// Step 5: System DNS fallback (DoH resolved IPs all failed, or DoH itself failed)
	conn, err := dialTLS(hostname, port, hostname, echConfigs)
	if err == nil {
		method := "system-dns"
		if len(ips) == 0 {
			method = "direct (no DoH)"
		}
		fmt.Fprintf(os.Stderr, "[conn] %s → %s fallback\n", hostname, method)
		tunnel(w, conn)
		return
	}
	lastErr = err

	fmt.Fprintf(os.Stderr, "[conn] %s → ALL FAILED: %v\n", hostname, lastErr)
	http.Error(w, "all connection methods failed for "+hostname, http.StatusBadGateway)
}

// ─── Main ────────────────────────────────────────────────────────────────────

func main() {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		fmt.Fprintln(os.Stderr, "[utls-proxy] listen error:", err)
		os.Exit(1)
	}

	port := listener.Addr().(*net.TCPAddr).Port
	// Print port to stdout — Dart reads this to know where to connect.
	fmt.Println(port)

	// Exit cleanly when Dart closes stdin (parent process died).
	go func() {
		io.Copy(io.Discard, os.Stdin)
		os.Exit(0)
	}()

	fmt.Fprintf(os.Stderr, "[utls-proxy] listening on 127.0.0.1:%d\n", port)
	fmt.Fprintf(os.Stderr, "[utls-proxy] features: ECH, ECH-retry, fingerprint-rotation"+
		" (Chrome/Firefox/Edge/Safari/Random), DoH (7 providers), probe-resistance\n")

	http.Serve(listener, http.HandlerFunc(handleRequest))
}
