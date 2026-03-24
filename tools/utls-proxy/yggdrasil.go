package main

// ── Yggdrasil + pion/turn local relay ────────────────────────────────────────
//
// This file adds two capabilities to pulse-utls-proxy:
//
//  1. Yggdrasil node (library-embedded) — assigns this device a globally-
//     routable 200::/7 IPv6 address derived from its public key.  Peers
//     connect over encrypted TCP tunnels through public Yggdrasil bootstrap
//     nodes.  No VPN service or OS tun interface required.
//
//  2. Local pion/turn server on 127.0.0.1:53478 — Flutter WebRTC treats it
//     as a standard TURN server.  Relay addresses are Yggdrasil IPv6 + port.
//     Media travels Flutter → local TURN → Yggdrasil overlay → remote TURN →
//     remote Flutter, bypassing all traditional STUN/TURN infrastructure.
//
//  3. Outbound proxy (POST /ygg/proxy) — creates a UDP↔Yggdrasil-overlay
//     bridge for each remote Yggdrasil relay address.  Flutter's ICE candidate
//     interceptor uses this to map incoming [200:…]:port candidates to a
//     loopback UDP port before handing them to WebRTC.
//
// Transport model (yggdrasil-go v0.5.8):
//   Core.ReadFrom / Core.WriteTo provide raw packet I/O over the overlay.
//   Addresses are ironwood types.Addr (ed25519 public keys).
//   Packets carry a 2-byte port prefix for per-allocation multiplexing.
//
// HTTP endpoints added to the existing proxy:
//   GET  /ygg         → {"addr":"200:aaa::1","pubkey":"BASE64","turn_port":53478}
//   POST /ygg/proxy   → {"target":"[200:bbb::1]:50000","pubkey":"BASE64"} → {"local_port":N}
//
// Build:
//   go build -o pulse-utls-proxy .
//
// The Yggdrasil node starts in the background at binary startup.  If it
// fails to bootstrap (e.g. all public peers blocked), the binary continues
// running normally — the /ygg endpoint returns 503.

import (
	"crypto/ed25519"
	cryptorand "crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"math/rand"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	iwtypes "github.com/Arceliar/ironwood/types"
	"github.com/pion/turn/v3"
	yggaddr "github.com/yggdrasil-network/yggdrasil-go/src/address"
	yggcore "github.com/yggdrasil-network/yggdrasil-go/src/core"
)

// ── Public Yggdrasil bootstrap peers ─────────────────────────────────────────
//
// Sourced from https://github.com/yggdrasil-network/public-peers (March 2026).
// Geographically diverse to maximise reachability from CN/RU/IR.

var yggPublicPeers = []string{
	// Hostname peers — resolve to IPv4 or IPv6 depending on device
	"tcp://cloudflare-ygg.ib.gg:12345",    // EU / CF CDN
	"tcp://ygg.mkg20001.io:80",             // Germany, TCP/80 (firewall-friendly)
	"tcp://ygg.loskiq.ru:17001",            // Russia, dual-stack
	"tcp://ygg-uplink.thingylabs.io:9999",  // EU, dual-stack

	// Raw IPv4 fallbacks for environments where DNS is unavailable
	"tcp://91.108.4.1:12345",               // community IPv4 peer, EU
	"tcp://46.151.26.194:12345",            // community IPv4 peer, EU
}

// ── Singleton state ───────────────────────────────────────────────────────────

var (
	yggMu             sync.RWMutex
	yggNode           *yggcore.Core
	yggAddress        net.IP  // our 200::/7 IPv6 (nil until bootstrapped)
	yggPubKey         []byte  // our ed25519 public key
	yggDisp           *yggDispatcher
	yggTurnActualPort int     // actual TURN port (0 if TURN failed to start)
	yggActiveRelays   atomic.Int32 // number of live relay allocations
)

// yggLogger implements yggcore.Logger writing to stderr.
type yggLogger struct{}

func (l *yggLogger) Printf(f string, v ...interface{})  { fmt.Fprintf(os.Stderr, f, v...) }
func (l *yggLogger) Println(v ...interface{})           { fmt.Fprintln(os.Stderr, v...) }
func (l *yggLogger) Infof(f string, v ...interface{})   { fmt.Fprintf(os.Stderr, "[ygg] "+f+"\n", v...) }
func (l *yggLogger) Infoln(v ...interface{})            { fmt.Fprintln(os.Stderr, v...) }
func (l *yggLogger) Warnf(f string, v ...interface{})   { fmt.Fprintf(os.Stderr, "[ygg-warn] "+f+"\n", v...) }
func (l *yggLogger) Warnln(v ...interface{})            { fmt.Fprintln(os.Stderr, v...) }
func (l *yggLogger) Errorf(f string, v ...interface{})  { fmt.Fprintf(os.Stderr, "[ygg-err] "+f+"\n", v...) }
func (l *yggLogger) Errorln(v ...interface{})           { fmt.Fprintln(os.Stderr, v...) }
func (l *yggLogger) Debugf(f string, v ...interface{})  {} // suppress debug noise
func (l *yggLogger) Debugln(v ...interface{})           {}
func (l *yggLogger) Traceln(v ...interface{})           {}

// ── Identity key (persistent) ─────────────────────────────────────────────────
//
// yggcore.New (v0.5.8+) requires an explicit *tls.Certificate with an ed25519
// private key — passing nil returns "no private key supplied".
//
// We persist the key next to the executable so the Yggdrasil address stays
// stable across restarts.  The file is 64 raw bytes (ed25519.PrivateKey).
// If the file cannot be written (e.g. read-only filesystem) the key is used
// in-memory only — Yggdrasil still works, the address just changes on restart.

// yggKeyPath returns the path where the identity key is stored.
//
// Priority:
//  1. ~/.pulse/ygg_identity.key — stable across binary re-extractions on
//     Android (HOME = app's files dir) and clean on Linux (~/.pulse/).
//  2. <exe_dir>/ygg_identity.key — fallback if home dir is unavailable.
func yggKeyPath() string {
	if home, err := os.UserHomeDir(); err == nil {
		dir := filepath.Join(home, ".pulse")
		if err := os.MkdirAll(dir, 0700); err == nil {
			return filepath.Join(dir, "ygg_identity.key")
		}
	}
	if exe, err := os.Executable(); err == nil {
		return filepath.Join(filepath.Dir(exe), "ygg_identity.key")
	}
	return "ygg_identity.key"
}

// loadOrCreateYggKey loads the persisted ed25519 private key, or generates and
// saves a new one if none exists.
func loadOrCreateYggKey() (ed25519.PrivateKey, error) {
	return loadOrCreateYggKeyAt(yggKeyPath())
}

// loadOrCreateYggKeyAt is the path-explicit implementation (also used by tests).
func loadOrCreateYggKeyAt(path string) (ed25519.PrivateKey, error) {
	if data, err := os.ReadFile(path); err == nil {
		if len(data) == ed25519.PrivateKeySize {
			fmt.Fprintf(os.Stderr, "[ygg] loaded identity from %s\n", path)
			return ed25519.PrivateKey(data), nil
		}
		fmt.Fprintf(os.Stderr, "[ygg] invalid key file (%d bytes), regenerating\n", len(data))
	}
	_, priv, err := ed25519.GenerateKey(cryptorand.Reader)
	if err != nil {
		return nil, fmt.Errorf("generate key: %w", err)
	}
	if err := os.WriteFile(path, []byte(priv), 0600); err != nil {
		fmt.Fprintf(os.Stderr, "[ygg] warning: cannot save identity key to %s: %v\n", path, err)
	} else {
		fmt.Fprintf(os.Stderr, "[ygg] new identity saved to %s\n", path)
	}
	return priv, nil
}

// newSelfSignedYggCert wraps an ed25519 private key in a self-signed TLS
// certificate as required by yggcore.New.
func newSelfSignedYggCert(priv ed25519.PrivateKey) (*tls.Certificate, error) {
	template := &x509.Certificate{
		SerialNumber: big.NewInt(1),
		NotBefore:    time.Now().Add(-time.Hour),
		NotAfter:     time.Now().Add(100 * 365 * 24 * time.Hour),
	}
	der, err := x509.CreateCertificate(cryptorand.Reader, template, template, priv.Public(), priv)
	if err != nil {
		return nil, fmt.Errorf("create cert: %w", err)
	}
	return &tls.Certificate{
		Certificate: [][]byte{der},
		PrivateKey:  priv,
	}, nil
}

// ── Start ─────────────────────────────────────────────────────────────────────

// startYggdrasil starts the embedded Yggdrasil node in the background.
// Non-fatal: errors are logged but do not crash the proxy.
func startYggdrasil() {
	go func() {
		if err := doStartYggdrasil(); err != nil {
			fmt.Fprintf(os.Stderr, "[ygg] failed to start: %v\n", err)
		}
	}()
}

func doStartYggdrasil() error {
	priv, err := loadOrCreateYggKey()
	if err != nil {
		return fmt.Errorf("identity key: %w", err)
	}
	cert, err := newSelfSignedYggCert(priv)
	if err != nil {
		return fmt.Errorf("cert: %w", err)
	}

	opts := []yggcore.SetupOption{
		yggcore.ListenAddress("tcp://0.0.0.0:0"),
	}
	for _, p := range yggPublicPeers {
		opts = append(opts, yggcore.Peer{URI: p})
	}

	node, err := yggcore.New(cert, &yggLogger{}, opts...)
	if err != nil {
		return fmt.Errorf("core.New: %w", err)
	}

	addr := node.Address()
	if addr == nil {
		node.Stop()
		return fmt.Errorf("Address() returned nil")
	}
	pubKey := []byte(node.PublicKey())

	disp := newYggDispatcher(node)
	go disp.run()

	yggMu.Lock()
	yggNode    = node
	yggAddress = addr
	yggPubKey  = pubKey
	yggDisp    = disp
	yggMu.Unlock()

	fmt.Fprintf(os.Stderr, "[ygg] bootstrapped: addr=%s pubkey=%x\n", addr, pubKey)

	// Start the local pion/turn server that relays via Yggdrasil
	if err := startYggTurnServer(node, disp, addr); err != nil {
		fmt.Fprintf(os.Stderr, "[ygg] TURN server failed (non-fatal): %v\n", err)
	}

	return nil
}

// ── Packet dispatcher ─────────────────────────────────────────────────────────
//
// Protocol: every packet exchanged via the Yggdrasil overlay is prefixed with
// 2 bytes (big-endian uint16) encoding a virtual port number.
//
// Routing rules (checked in order):
//  1. Relay registry — packets for locally-allocated relay ports.
//     Key: uint16 port number.
//  2. Proxy registry — response packets from a specific remote node.
//     Key: "srcPubkeyHex:port" string.

type yggDatagram struct {
	data []byte
	from net.Addr
}

type yggReceiver interface {
	dispatch(dg yggDatagram)
}

type yggDispatcher struct {
	node        *yggcore.Core
	relayPorts  sync.Map // uint16 → yggReceiver
	proxyRoutes sync.Map // "srcHex:port" → yggReceiver
}

func newYggDispatcher(node *yggcore.Core) *yggDispatcher {
	return &yggDispatcher{node: node}
}

func (d *yggDispatcher) run() {
	buf := make([]byte, 65536+2)
	errDelay := time.Second
	for {
		n, from, err := d.node.ReadFrom(buf)
		if err != nil {
			fmt.Fprintf(os.Stderr, "[ygg-disp] ReadFrom error (retry in %v): %v\n", errDelay, err)
			time.Sleep(errDelay)
			if errDelay < 30*time.Second {
				errDelay *= 2
			}
			continue
		}
		errDelay = time.Second // reset on success
		if n < 2 {
			continue
		}
		port := binary.BigEndian.Uint16(buf[:2])
		data := make([]byte, n-2)
		copy(data, buf[2:n])
		dg := yggDatagram{data: data, from: from}

		// 1. Relay registry (local allocation → any source)
		if v, ok := d.relayPorts.Load(port); ok {
			v.(yggReceiver).dispatch(dg)
			continue
		}
		// 2. Proxy registry (specific source → proxy listener)
		key := from.String() + ":" + strconv.Itoa(int(port))
		if v, ok := d.proxyRoutes.Load(key); ok {
			v.(yggReceiver).dispatch(dg)
		}
	}
}

func (d *yggDispatcher) registerRelay(port uint16, r yggReceiver) {
	d.relayPorts.Store(port, r)
}

func (d *yggDispatcher) unregisterRelay(port uint16) {
	d.relayPorts.Delete(port)
}

func (d *yggDispatcher) registerProxy(srcAddr net.Addr, port uint16, r yggReceiver) {
	key := srcAddr.String() + ":" + strconv.Itoa(int(port))
	d.proxyRoutes.Store(key, r)
}

func (d *yggDispatcher) unregisterProxy(srcAddr net.Addr, port uint16) {
	key := srcAddr.String() + ":" + strconv.Itoa(int(port))
	d.proxyRoutes.Delete(key)
}

// send writes a port-prefixed packet to dst via the Yggdrasil overlay.
func (d *yggDispatcher) send(data []byte, port uint16, dst net.Addr) error {
	packet := make([]byte, 2+len(data))
	binary.BigEndian.PutUint16(packet[:2], port)
	copy(packet[2:], data)
	_, err := d.node.WriteTo(packet, dst)
	return err
}

// ── Port allocator ────────────────────────────────────────────────────────────

// allocateYggPort picks a random free port in the dynamic range 49152–65535.
// Using random ports reduces the probability of cross-device collision when
// both peers start pion/turn relay allocations concurrently.
// Returns an error if no free port is found after 200 attempts (e.g. table full).
func allocateYggPort(d *yggDispatcher) (uint16, error) {
	const maxTries = 200
	for i := 0; i < maxTries; i++ {
		p := uint16(49152 + rand.Intn(16383))
		if _, ok := d.relayPorts.Load(p); !ok {
			return p, nil
		}
	}
	return 0, fmt.Errorf("allocateYggPort: no free port after %d attempts", maxTries)
}

// ── pion/turn relay server ────────────────────────────────────────────────────

const (
	yggTurnPort     = 53478
	yggTurnRealm    = "pulse.ygg"
	yggTurnUser     = "pulse"
	yggTurnPassword = "yggtoken"
)

func startYggTurnServer(node *yggcore.Core, disp *yggDispatcher, addr net.IP) error {
	// Try preferred port first, then let the OS pick a free one.
	// Port conflicts would otherwise cause TURN to silently not start while
	// /ygg still reports success.
	var udpConn net.PacketConn
	var err error
	for _, candidate := range []int{yggTurnPort, 0} {
		udpConn, err = net.ListenPacket("udp4", fmt.Sprintf("127.0.0.1:%d", candidate))
		if err == nil {
			break
		}
		fmt.Fprintf(os.Stderr, "[ygg] port %d busy, trying next\n", candidate)
	}
	if err != nil {
		return fmt.Errorf("ListenPacket: %w", err)
	}
	actualPort := udpConn.LocalAddr().(*net.UDPAddr).Port

	gen := &yggRelayAddressGenerator{disp: disp, addr: addr}

	_, err = turn.NewServer(turn.ServerConfig{
		Realm: yggTurnRealm,
		AuthHandler: func(username, realm string, _ net.Addr) ([]byte, bool) {
			if username == yggTurnUser {
				return turn.GenerateAuthKey(username, realm, yggTurnPassword), true
			}
			return nil, false
		},
		PacketConnConfigs: []turn.PacketConnConfig{
			{
				PacketConn:            udpConn,
				RelayAddressGenerator: gen,
			},
		},
	})
	if err != nil {
		udpConn.Close()
		return fmt.Errorf("turn.NewServer: %w", err)
	}

	yggMu.Lock()
	yggTurnActualPort = actualPort
	yggMu.Unlock()

	fmt.Fprintf(os.Stderr, "[ygg] TURN listening on 127.0.0.1:%d relay=%s\n",
		actualPort, addr)
	return nil
}

// ── RelayAddressGenerator ─────────────────────────────────────────────────────

// yggRelayAddressGenerator implements pion/turn's RelayAddressGenerator.
// Each allocation registers a virtual port in the Yggdrasil dispatcher;
// the relay address advertised to WebRTC is our Yggdrasil IPv6 + that port.
type yggRelayAddressGenerator struct {
	disp *yggDispatcher
	addr net.IP
}

func (g *yggRelayAddressGenerator) Validate() error { return nil }

// AllocatePacketConn is called by pion/turn for each new TURN allocation.
func (g *yggRelayAddressGenerator) AllocatePacketConn(
	network string, requestedPort int,
) (net.PacketConn, net.Addr, error) {
	port, err := allocateYggPort(g.disp)
	if err != nil {
		return nil, nil, err
	}
	relayAddr := &net.UDPAddr{IP: g.addr, Port: int(port)}
	pconn := newYggPacketConn(g.disp, port, relayAddr)
	g.disp.registerRelay(port, pconn)
	yggActiveRelays.Add(1)
	fmt.Fprintf(os.Stderr, "[ygg] relay allocated port=%d addr=%s active=%d\n",
		port, relayAddr, yggActiveRelays.Load())
	return pconn, relayAddr, nil
}

// AllocateConn is not used for UDP-based WebRTC media.
func (g *yggRelayAddressGenerator) AllocateConn(
	network string, requestedPort int,
) (net.Conn, net.Addr, error) {
	return nil, nil, fmt.Errorf("AllocateConn not supported")
}

// ── yggPacketConn ─────────────────────────────────────────────────────────────
//
// yggPacketConn bridges UDP datagrams (expected by pion/turn) with the
// Yggdrasil overlay via the global dispatcher.  It implements net.PacketConn.
//
// ReadFrom — blocks until a datagram arrives via the dispatcher.
// WriteTo  — sends data to the specified overlay address (iwtypes.Addr).

type yggPacketConn struct {
	disp      *yggDispatcher
	port      uint16
	localAddr net.Addr

	incoming  chan yggDatagram
	closeOnce sync.Once
	closed    chan struct{}
	addrCache sync.Map // yggIP.String() → iwtypes.Addr(pubkey)
}

var _ yggReceiver = (*yggPacketConn)(nil)

func newYggPacketConn(disp *yggDispatcher, port uint16, addr net.Addr) *yggPacketConn {
	return &yggPacketConn{
		disp:      disp,
		port:      port,
		localAddr: addr,
		incoming:  make(chan yggDatagram, 256),
		closed:    make(chan struct{}),
	}
}

func (pc *yggPacketConn) dispatch(dg yggDatagram) {
	select {
	case pc.incoming <- dg:
	case <-pc.closed:
	default: // drop if buffer full
	}
}

// pubkeyToUDPAddr converts an iwtypes.Addr (ed25519 pubkey) to a *net.UDPAddr
// whose IP is the deterministic Yggdrasil 200::/7 address for that key.
// pion/turn calls ipnet.FingerprintAddr(srcAddr) which only recognises
// *net.UDPAddr / *net.TCPAddr — iwtypes.Addr returns "" → permission lookup
// fails → every relay packet is silently dropped.  This function fixes that.
func pubkeyToUDPAddr(from net.Addr) *net.UDPAddr {
	if iwa, ok := from.(iwtypes.Addr); ok {
		yggIP := net.IP(yggaddr.AddrForKey(ed25519.PublicKey(iwa))[:])
		return &net.UDPAddr{IP: yggIP, Port: 0}
	}
	return &net.UDPAddr{IP: net.IPv6loopback, Port: 0}
}

// ReadFrom blocks until a datagram arrives via the dispatcher.
// Returns a synthetic *net.UDPAddr derived from the sender's pubkey so that
// pion/turn's FingerprintAddr can match it against TURN permissions.
// The pubkey→UDPAddr mapping is cached for use by WriteTo.
func (pc *yggPacketConn) ReadFrom(b []byte) (int, net.Addr, error) {
	select {
	case dg := <-pc.incoming:
		n := copy(b, dg.data)
		synth := pubkeyToUDPAddr(dg.from)
		pc.addrCache.Store(synth.IP.String(), dg.from)
		return n, synth, nil
	case <-pc.closed:
		return 0, nil, net.ErrClosed
	}
}

// WriteTo sends [b] to [addr] via the Yggdrasil overlay.
// [addr] is a *net.UDPAddr (Yggdrasil IPv6) as returned by ReadFrom;
// we reverse-map its IP back to the original iwtypes.Addr via addrCache.
func (pc *yggPacketConn) WriteTo(b []byte, addr net.Addr) (int, error) {
	udp, ok := addr.(*net.UDPAddr)
	if !ok {
		return 0, fmt.Errorf("yggPacketConn.WriteTo: unexpected addr type %T", addr)
	}
	v, ok := pc.addrCache.Load(udp.IP.String())
	if !ok {
		return 0, fmt.Errorf("yggPacketConn.WriteTo: no route for %s", udp.IP)
	}
	iwAddr, ok := v.(net.Addr)
	if !ok {
		return 0, fmt.Errorf("yggPacketConn.WriteTo: cache entry has unexpected type %T", v)
	}
	if err := pc.disp.send(b, pc.port, iwAddr); err != nil {
		return 0, err
	}
	return len(b), nil
}

func (pc *yggPacketConn) Close() error {
	pc.closeOnce.Do(func() {
		pc.disp.unregisterRelay(pc.port)
		close(pc.closed)
		yggActiveRelays.Add(-1)
	})
	return nil
}

func (pc *yggPacketConn) LocalAddr() net.Addr                { return pc.localAddr }
func (pc *yggPacketConn) SetDeadline(t time.Time) error      { return nil }
func (pc *yggPacketConn) SetReadDeadline(t time.Time) error  { return nil }
func (pc *yggPacketConn) SetWriteDeadline(t time.Time) error { return nil }

// ── Outbound proxy ────────────────────────────────────────────────────────────
//
// When Flutter's ICE candidate interceptor sees a remote 200::/7 relay
// address it calls POST /ygg/proxy to create a local UDP↔Yggdrasil bridge.
// Flutter WebRTC sends media to 127.0.0.1:LOCAL_PORT; the bridge forwards
// it through the Yggdrasil overlay to the remote relay allocation.
//
// The remote's relay port number is used as the multiplexing key.
// Responses from the remote are routed via the dispatcher's proxy registry.

type proxyState struct {
	udpConn   *net.UDPConn
	localPort int
}

var (
	proxyMu  sync.Mutex
	proxyMap = map[string]*proxyState{} // "pubkeyHex:port" → proxy
)

// proxyReceiver implements yggReceiver for an outbound proxy session.
type proxyReceiver struct {
	incoming chan yggDatagram
}

func (pr *proxyReceiver) dispatch(dg yggDatagram) {
	select {
	case pr.incoming <- dg:
	default:
	}
}

// handleYggProxy handles POST /ygg/proxy.
//
// Request body: {"target":"[200:bbb::1]:50000","pubkey":"BASE64_ED25519"}
// Response:     {"local_port":N}
func handleYggProxy(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "POST only", http.StatusMethodNotAllowed)
		return
	}

	body, err := io.ReadAll(io.LimitReader(r.Body, 4096))
	if err != nil {
		http.Error(w, "read error", http.StatusBadRequest)
		return
	}
	var req struct {
		Target string `json:"target"`
		Pubkey string `json:"pubkey"`
	}
	if err := json.Unmarshal(body, &req); err != nil || req.Target == "" || req.Pubkey == "" {
		http.Error(w, "missing target or pubkey", http.StatusBadRequest)
		return
	}

	// Decode ed25519 public key → iwtypes.Addr
	pubkeyBytes, err := base64.StdEncoding.DecodeString(req.Pubkey)
	if err != nil || len(pubkeyBytes) != 32 {
		http.Error(w, "invalid pubkey", http.StatusBadRequest)
		return
	}
	targetAddr := iwtypes.Addr(pubkeyBytes)

	// Parse target port
	_, portStr, err := net.SplitHostPort(req.Target)
	if err != nil {
		http.Error(w, "invalid target address", http.StatusBadRequest)
		return
	}
	portNum, err := strconv.ParseUint(portStr, 10, 16)
	if err != nil {
		http.Error(w, "invalid port", http.StatusBadRequest)
		return
	}
	targetPort := uint16(portNum)

	yggMu.RLock()
	disp := yggDisp
	yggMu.RUnlock()
	if disp == nil {
		http.Error(w, "yggdrasil not ready", http.StatusServiceUnavailable)
		return
	}

	// Deduplicate by pubkey+port
	cacheKey := req.Pubkey + ":" + portStr
	proxyMu.Lock()
	if existing, ok := proxyMap[cacheKey]; ok {
		proxyMu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]int{"local_port": existing.localPort})
		return
	}

	// Bind a UDP socket on loopback for Flutter WebRTC
	udpConn, err := net.ListenUDP("udp4", &net.UDPAddr{IP: net.ParseIP("127.0.0.1")})
	if err != nil {
		proxyMu.Unlock()
		http.Error(w, "udp listen failed", http.StatusInternalServerError)
		return
	}
	localPort := udpConn.LocalAddr().(*net.UDPAddr).Port
	ps := &proxyState{udpConn: udpConn, localPort: localPort}
	proxyMap[cacheKey] = ps
	proxyMu.Unlock()

	go runYggOutboundProxy(disp, udpConn, targetPort, targetAddr, cacheKey)

	fmt.Fprintf(os.Stderr, "[ygg] proxy %s → 127.0.0.1:%d\n", req.Target, localPort)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{"local_port": localPort})
}

// runYggOutboundProxy bridges Flutter UDP ↔ Yggdrasil overlay for one remote target.
//
// Outgoing: UDP datagram from Flutter → core.WriteTo([targetPort][data], targetAddr)
// Incoming: dispatcher delivers [data] from targetAddr at targetPort → UDP to Flutter
func runYggOutboundProxy(
	disp *yggDispatcher,
	udpConn *net.UDPConn,
	targetPort uint16,
	targetAddr iwtypes.Addr,
	cacheKey string,
) {
	defer func() {
		proxyMu.Lock()
		delete(proxyMap, cacheKey)
		proxyMu.Unlock()
	}()
	recv := &proxyReceiver{incoming: make(chan yggDatagram, 256)}
	disp.registerProxy(targetAddr, targetPort, recv)
	defer disp.unregisterProxy(targetAddr, targetPort)
	defer udpConn.Close()

	var (
		clientMu   sync.Mutex
		clientAddr *net.UDPAddr
	)

	done := make(chan struct{})
	defer close(done)

	// Yggdrasil → UDP (incoming from remote relay)
	go func() {
		for {
			select {
			case dg := <-recv.incoming:
				clientMu.Lock()
				ca := clientAddr
				clientMu.Unlock()
				if ca != nil {
					udpConn.WriteToUDP(dg.data, ca)
				}
			case <-done:
				return
			}
		}
	}()

	// UDP → Yggdrasil (outgoing from Flutter WebRTC)
	buf := make([]byte, 65535)
	for {
		udpConn.SetReadDeadline(time.Now().Add(5 * time.Minute))
		n, from, err := udpConn.ReadFromUDP(buf)
		if err != nil {
			return
		}
		clientMu.Lock()
		clientAddr = from
		clientMu.Unlock()

		if err := disp.send(buf[:n], targetPort, targetAddr); err != nil {
			fmt.Fprintf(os.Stderr, "[ygg-proxy] send error: %v\n", err)
		}
	}
}

// ── HTTP handlers registered in main ─────────────────────────────────────────

// handleYggStatus handles GET /ygg.
// Returns our Yggdrasil address, public key (base64), and TURN port; or 503.
func handleYggStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "GET only", http.StatusMethodNotAllowed)
		return
	}
	yggMu.RLock()
	addr      := yggAddress
	pubKey    := yggPubKey
	turnPort  := yggTurnActualPort
	yggMu.RUnlock()
	if addr == nil {
		http.Error(w, "yggdrasil not ready", http.StatusServiceUnavailable)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"addr":          addr.String(),
		"pubkey":        base64.StdEncoding.EncodeToString(pubKey),
		"turn_port":     turnPort, // 0 if TURN failed to start (port conflict etc.)
		"user":          yggTurnUser,
		"pass":          yggTurnPassword,
		"active_relays": yggActiveRelays.Load(),
	})
}
