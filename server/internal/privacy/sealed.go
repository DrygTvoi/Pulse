package privacy

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"sync"
	"time"
)

// SealedSenderService handles delivery certificates for anonymous message sending.
type SealedSenderService struct {
	secret    []byte // server HMAC secret
	certTTL   time.Duration
	certCount int

	usedMu    sync.Mutex
	usedCerts map[string]int64 // token → expiry timestamp (for cleanup)
}

// NewSealedSenderService creates a new sealed sender service.
func NewSealedSenderService(certCount int, certTTL string) *SealedSenderService {
	secret := make([]byte, 32)
	rand.Read(secret)

	ttl := 24 * time.Hour
	if d, err := time.ParseDuration(certTTL); err == nil {
		ttl = d
	}

	svc := &SealedSenderService{
		secret:    secret,
		certTTL:   ttl,
		certCount: certCount,
		usedCerts: make(map[string]int64),
	}
	go svc.cleanupLoop()
	return svc
}

// DeliveryCert represents a single-use delivery token.
type DeliveryCert struct {
	Token   string `json:"token"`
	Expires int64  `json:"expires"`
}

// IssueCerts generates a batch of delivery certificates.
func (s *SealedSenderService) IssueCerts() []DeliveryCert {
	certs := make([]DeliveryCert, s.certCount)
	expires := time.Now().Add(s.certTTL).Unix()

	for i := range certs {
		certs[i] = DeliveryCert{
			Token:   s.generateToken(expires),
			Expires: expires,
		}
	}
	return certs
}

// VerifyCert verifies that a delivery certificate is valid and marks it as used (single-use).
func (s *SealedSenderService) VerifyCert(token string) bool {
	tokenBytes, err := hex.DecodeString(token)
	if err != nil || len(tokenBytes) < 40 {
		return false
	}

	// Token format: randomID(16) + expires(8) + HMAC(16)
	randomID := tokenBytes[:16]
	expiresBytes := tokenBytes[16:24]
	providedMAC := tokenBytes[24:40]

	// Check expiry
	expires := int64(binary.BigEndian.Uint64(expiresBytes))
	if time.Now().Unix() > expires {
		return false
	}

	// Verify HMAC
	expectedMAC := s.computeMAC(randomID, expiresBytes)
	if !hmac.Equal(providedMAC, expectedMAC[:16]) {
		return false
	}

	// Single-use check: reject if already used
	s.usedMu.Lock()
	if _, used := s.usedCerts[token]; used {
		s.usedMu.Unlock()
		return false
	}
	s.usedCerts[token] = expires
	s.usedMu.Unlock()

	return true
}

func (s *SealedSenderService) generateToken(expires int64) string {
	randomID := make([]byte, 16)
	rand.Read(randomID)

	expiresBytes := make([]byte, 8)
	binary.BigEndian.PutUint64(expiresBytes, uint64(expires))

	mac := s.computeMAC(randomID, expiresBytes)

	// Token = randomID(16) + expires(8) + HMAC(16) = 40 bytes → 80 hex chars
	token := make([]byte, 40)
	copy(token[:16], randomID)
	copy(token[16:24], expiresBytes)
	copy(token[24:40], mac[:16])

	return hex.EncodeToString(token)
}

func (s *SealedSenderService) computeMAC(randomID, expiresBytes []byte) []byte {
	h := hmac.New(sha256.New, s.secret)
	h.Write(randomID)
	h.Write(expiresBytes)
	return h.Sum(nil)
}

// cleanupLoop periodically removes expired used tokens.
func (s *SealedSenderService) cleanupLoop() {
	ticker := time.NewTicker(10 * time.Minute)
	defer ticker.Stop()
	for range ticker.C {
		now := time.Now().Unix()
		s.usedMu.Lock()
		for token, expires := range s.usedCerts {
			if now > expires {
				delete(s.usedCerts, token)
			}
		}
		s.usedMu.Unlock()
	}
}

// SetSecret sets the HMAC secret (used when loading from persistent storage).
func (s *SealedSenderService) SetSecret(secret []byte) {
	s.secret = secret
}

// Secret returns the HMAC secret for persistence.
func (s *SealedSenderService) Secret() []byte {
	return s.secret
}

// BatchDeliveryBuffer holds messages for batched delivery.
type BatchDeliveryBuffer struct {
	mu       sync.Mutex
	interval time.Duration
	pending  map[string][]PendingDelivery // pubkey → pending messages
	deliver  func(pubkey string, msgs []PendingDelivery)
	stopCh   chan struct{}
}

// PendingDelivery represents a message waiting for batch delivery.
type PendingDelivery struct {
	Data []byte
	Ts   time.Time
}

// NewBatchDeliveryBuffer creates a batch delivery buffer.
func NewBatchDeliveryBuffer(intervalMs int, deliver func(pubkey string, msgs []PendingDelivery)) *BatchDeliveryBuffer {
	return &BatchDeliveryBuffer{
		interval: time.Duration(intervalMs) * time.Millisecond,
		pending:  make(map[string][]PendingDelivery),
		deliver:  deliver,
		stopCh:   make(chan struct{}),
	}
}

// Enqueue adds a message to the batch for a recipient.
func (b *BatchDeliveryBuffer) Enqueue(pubkey string, data []byte) {
	b.mu.Lock()
	b.pending[pubkey] = append(b.pending[pubkey], PendingDelivery{
		Data: data,
		Ts:   time.Now(),
	})
	b.mu.Unlock()
}

// Start begins the batch delivery ticker.
func (b *BatchDeliveryBuffer) Start() {
	if b.interval <= 0 {
		return
	}
	go func() {
		ticker := time.NewTicker(b.interval)
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				b.flush()
			case <-b.stopCh:
				b.flush() // deliver any remaining
				return
			}
		}
	}()
}

func (b *BatchDeliveryBuffer) flush() {
	b.mu.Lock()
	batches := b.pending
	b.pending = make(map[string][]PendingDelivery)
	b.mu.Unlock()

	for pubkey, msgs := range batches {
		if len(msgs) > 0 && b.deliver != nil {
			b.deliver(pubkey, msgs)
		}
	}
}

// Stop stops the batch delivery buffer.
func (b *BatchDeliveryBuffer) Stop() {
	select {
	case <-b.stopCh:
	default:
		close(b.stopCh)
	}
}

// NormalizeBucketSize returns the bucket-padded size for a given message size.
func NormalizeBucketSize(size int) int {
	switch {
	case size <= 256:
		return 256
	case size <= 1024:
		return 1024
	case size <= 4096:
		return 4096
	case size <= 16384:
		return 16384
	default:
		return 65536
	}
}

// ApplyJitter returns a random delay up to maxMs.
func ApplyJitter(maxMs int) time.Duration {
	if maxMs <= 0 {
		return 0
	}
	ms := randomInt(0, maxMs)
	return time.Duration(ms) * time.Millisecond
}

// ResolvePreset returns the effective privacy settings for a preset.
func ResolvePreset(preset string) (padding bool, paddingMode string, sealedSender bool, jitterMs int, batchDelivery bool, batchMs int, chaff bool) {
	switch preset {
	case "private":
		return true, "burst", true, 200, false, 0, false
	case "paranoid":
		return true, "cbr", true, 500, true, 2000, true
	case "standard":
		return false, "", false, 0, false, 0, false
	default:
		// "custom" — use individual settings from config
		return false, "", false, 0, false, 0, false
	}
}

// EffectiveSettings returns the actual settings to use, resolving presets.
type EffectiveSettings struct {
	Padding          bool
	PaddingMode      string
	PaddingRateKbps  int
	SealedSender     bool
	DeliveryJitterMs int
	BatchDelivery    bool
	BatchIntervalMs  int
	Chaff            bool
	ChaffIntervalSec int
}

// ResolveSettings resolves preset or custom settings.
func ResolveSettings(preset string, padding bool, paddingMode string, rateKbps int, sealedSender bool, jitterMs int, batchDelivery bool, batchMs int, chaff bool, chaffSec int) EffectiveSettings {
	switch preset {
	case "private":
		return EffectiveSettings{
			Padding: true, PaddingMode: "burst", PaddingRateKbps: rateKbps,
			SealedSender: true, DeliveryJitterMs: 200,
		}
	case "paranoid":
		return EffectiveSettings{
			Padding: true, PaddingMode: "cbr", PaddingRateKbps: rateKbps,
			SealedSender: true, DeliveryJitterMs: 500,
			BatchDelivery: true, BatchIntervalMs: 2000,
			Chaff: true, ChaffIntervalSec: 300,
		}
	case "custom":
		return EffectiveSettings{
			Padding: padding, PaddingMode: paddingMode, PaddingRateKbps: rateKbps,
			SealedSender: sealedSender, DeliveryJitterMs: jitterMs,
			BatchDelivery: batchDelivery, BatchIntervalMs: batchMs,
			Chaff: chaff, ChaffIntervalSec: chaffSec,
		}
	default: // "standard"
		return EffectiveSettings{}
	}
}

