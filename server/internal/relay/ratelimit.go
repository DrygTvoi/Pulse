package relay

import (
	"log"
	"net"
	"sync"
	"sync/atomic"
	"time"
)

// maxBuckets caps the rate limiter map to prevent unbounded growth
// from probe/DDoS attacks creating millions of unique keys.
const maxBuckets = 10000

// helloRate is the per-IP rate limit for pre-auth "hello" messages (per minute).
const helloRate = 5

// RateLimiter implements a per-pubkey token bucket rate limiter.
type RateLimiter struct {
	mu      sync.Mutex
	buckets map[string]*bucket
	rate    int           // tokens per window
	window  time.Duration // window duration
}

type bucket struct {
	tokens    int
	lastReset time.Time
}

// NewRateLimiter creates a rate limiter with the given messages per minute limit.
func NewRateLimiter(messagesPerMinute int) *RateLimiter {
	return &RateLimiter{
		buckets: make(map[string]*bucket),
		rate:    messagesPerMinute,
		window:  time.Minute,
	}
}

// Allow checks if a pubkey is allowed to send a message.
// Returns true if the action is allowed, false if rate-limited.
func (rl *RateLimiter) Allow(pubkey string) bool {
	return rl.allowKey(pubkey, rl.rate)
}

// AllowHello rate-limits pre-auth "hello" messages per IP prefix.
// We key on /24 (IPv4) or /48 (IPv6) so an attacker who rotates their
// source port or picks random /32s from a single network block can't
// trivially exhaust the per-IP bucket count and deny service to legit
// users. Real-world residential shares use the same prefix, which is
// acceptable for a pre-auth "hello" rate at 5/min.
func (rl *RateLimiter) AllowHello(ip string) bool {
	return rl.allowKey("hello:"+helloIPKey(ip), helloRate)
}

func helloIPKey(ip string) string {
	parsed := net.ParseIP(ip)
	if parsed == nil {
		return ip
	}
	if v4 := parsed.To4(); v4 != nil {
		v4[3] = 0 // collapse to /24
		return v4.String()
	}
	// IPv6: keep the first 48 bits (6 bytes).
	masked := parsed.Mask(net.CIDRMask(48, 128))
	return masked.String()
}

// helloCapHits counts how many Allow() calls were rejected because the
// bucket cap was already full. Exposed for metrics; increments under
// attack let operators see the self-DoS risk before real users notice.
var helloCapHits atomic.Int64

// HelloCapHits returns (and clears) the count of bucket-cap rejections
// since the last call. Intended for periodic metrics scraping.
func (rl *RateLimiter) HelloCapHits() int64 {
	return helloCapHits.Swap(0)
}

func (rl *RateLimiter) allowKey(key string, rate int) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()

	b, ok := rl.buckets[key]
	if !ok {
		if len(rl.buckets) >= maxBuckets {
			if hits := helloCapHits.Add(1); hits == 1 || hits%100 == 0 {
				log.Printf("[ratelimit] bucket cap reached (%d) — rejecting new keys; possible spoofed flood", maxBuckets)
			}
			return false // cap reached — reject to prevent OOM
		}
		rl.buckets[key] = &bucket{
			tokens:    rate - 1,
			lastReset: now,
		}
		return true
	}

	// Reset tokens if window has elapsed
	if now.Sub(b.lastReset) >= rl.window {
		b.tokens = rate
		b.lastReset = now
	}

	if b.tokens <= 0 {
		return false
	}

	b.tokens--
	return true
}

// Cleanup removes stale bucket entries to prevent memory leaks.
// Should be called periodically.
func (rl *RateLimiter) Cleanup() {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	cutoff := time.Now().Add(-5 * time.Minute)
	for key, b := range rl.buckets {
		if b.lastReset.Before(cutoff) {
			delete(rl.buckets, key)
		}
	}
}
