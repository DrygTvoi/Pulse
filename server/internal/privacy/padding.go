package privacy

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"sync"
	"time"
)

// PaddingService manages constant-rate or burst traffic padding and chaff.
type PaddingService struct {
	mode         string // "cbr" | "burst"
	rateKbps     int
	jitterPct    int
	enabled      bool

	// Chaff: fake message-like text frames between random clients
	chaffEnabled     bool
	chaffIntervalSec int

	mu       sync.Mutex
	clients  map[string]func([]byte) error // pubkey → send binary callback
	textClients map[string]func([]byte) error // pubkey → send text callback (for chaff)
	stopCh   chan struct{}
	stopped  bool
}

// NewPaddingService creates a new padding service.
func NewPaddingService(enabled bool, mode string, rateKbps, jitterPct int, chaffEnabled bool, chaffIntervalSec int) *PaddingService {
	return &PaddingService{
		enabled:          enabled,
		mode:             mode,
		rateKbps:         rateKbps,
		jitterPct:        jitterPct,
		chaffEnabled:     chaffEnabled,
		chaffIntervalSec: chaffIntervalSec,
		clients:          make(map[string]func([]byte) error),
		textClients:      make(map[string]func([]byte) error),
		stopCh:           make(chan struct{}),
	}
}

// RegisterClient adds a client to receive padding and chaff frames.
func (ps *PaddingService) RegisterClient(pubkey string, sendBinary func([]byte) error, sendText func([]byte) error) {
	ps.mu.Lock()
	if ps.enabled {
		ps.clients[pubkey] = sendBinary
	}
	if ps.chaffEnabled && sendText != nil {
		ps.textClients[pubkey] = sendText
	}
	ps.mu.Unlock()
}

// UnregisterClient removes a client.
func (ps *PaddingService) UnregisterClient(pubkey string) {
	ps.mu.Lock()
	delete(ps.clients, pubkey)
	delete(ps.textClients, pubkey)
	ps.mu.Unlock()
}

// Start begins sending padding frames to all registered clients.
func (ps *PaddingService) Start() {
	if ps.enabled {
		switch ps.mode {
		case "cbr":
			go ps.cbrLoop()
		case "burst":
			go ps.burstLoop()
		}
	}

	if ps.chaffEnabled && ps.chaffIntervalSec > 0 {
		go ps.chaffLoop()
	}
}

// cbrLoop sends constant-rate padding at configured kbps.
func (ps *PaddingService) cbrLoop() {
	// Calculate interval and size for target rate
	// rateKbps = 32 → 32000 bits/s → 4000 bytes/s
	bytesPerSec := ps.rateKbps * 1000 / 8
	// Send a frame every 100ms → 10 frames/s → bytesPerFrame = bytesPerSec / 10
	interval := 100 * time.Millisecond
	bytesPerFrame := bytesPerSec / 10
	if bytesPerFrame < 32 {
		bytesPerFrame = 32
	}

	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			ps.sendPaddingToAll(bytesPerFrame)
		case <-ps.stopCh:
			return
		}
	}
}

// burstLoop sends random bursts of padding.
func (ps *PaddingService) burstLoop() {
	for {
		// Random interval between 50ms and 500ms
		delay := randomInt(50, 500)
		timer := time.NewTimer(time.Duration(delay) * time.Millisecond)

		select {
		case <-timer.C:
			size := randomInt(32, 512)
			ps.sendPaddingToAll(size)
		case <-ps.stopCh:
			timer.Stop()
			return
		}
	}
}

func (ps *PaddingService) sendPaddingToAll(size int) {
	// Apply jitter to size
	if ps.jitterPct > 0 {
		jitter := randomInt(-size*ps.jitterPct/100, size*ps.jitterPct/100)
		size += jitter
		if size < 1 {
			size = 1
		}
	}

	// Build padding frame: 0xFF + random bytes
	frame := make([]byte, 1+size)
	frame[0] = 0xFF
	rand.Read(frame[1:])

	ps.mu.Lock()
	clients := make([]func([]byte) error, 0, len(ps.clients))
	for _, send := range ps.clients {
		clients = append(clients, send)
	}
	ps.mu.Unlock()

	for _, send := range clients {
		send(frame)
	}
}

// chaffLoop periodically sends fake message-like JSON frames to random clients.
// This makes real messages indistinguishable from chaff in traffic analysis.
func (ps *PaddingService) chaffLoop() {
	interval := time.Duration(ps.chaffIntervalSec) * time.Second
	// Add randomness: ±50% of interval
	for {
		jitter := randomInt(int(interval.Milliseconds())/2, int(interval.Milliseconds())*3/2)
		timer := time.NewTimer(time.Duration(jitter) * time.Millisecond)

		select {
		case <-timer.C:
			ps.sendChaff()
		case <-ps.stopCh:
			timer.Stop()
			return
		}
	}
}

func (ps *PaddingService) sendChaff() {
	ps.mu.Lock()
	if len(ps.textClients) < 1 {
		ps.mu.Unlock()
		return
	}

	// Pick a random client to receive chaff
	keys := make([]string, 0, len(ps.textClients))
	for k := range ps.textClients {
		keys = append(keys, k)
	}
	idx := randomInt(0, len(keys))
	sendFn := ps.textClients[keys[idx]]
	ps.mu.Unlock()

	// Generate a chaff message that looks like a real message envelope
	// Random body size matching bucket sizes
	bodySize := []int{256, 1024, 4096}[randomInt(0, 3)]
	body := make([]byte, bodySize)
	rand.Read(body)

	// Send as a "message" type that the client will recognize and discard
	// The "_chaff" field tells the client this is not real
	chaff := []byte(fmt.Sprintf(`{"type":"message","id":"chaff_%d","from":"chaff","body":"%x","_chaff":true}`,
		time.Now().UnixNano(), body[:32]))
	sendFn(chaff)
}

// Stop stops the padding service.
func (ps *PaddingService) Stop() {
	ps.mu.Lock()
	if !ps.stopped {
		ps.stopped = true
		close(ps.stopCh)
	}
	ps.mu.Unlock()
}

func randomInt(min, max int) int {
	if min >= max {
		return min
	}
	n, _ := rand.Int(rand.Reader, big.NewInt(int64(max-min)))
	return min + int(n.Int64())
}
