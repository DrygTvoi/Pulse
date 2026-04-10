package relay

import (
	"sync"
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

// AllowHello rate-limits pre-auth "hello" messages per IP address.
// Much lower limit than authenticated messages to prevent hello floods.
func (rl *RateLimiter) AllowHello(ip string) bool {
	return rl.allowKey("hello:"+ip, helloRate)
}

func (rl *RateLimiter) allowKey(key string, rate int) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()

	b, ok := rl.buckets[key]
	if !ok {
		if len(rl.buckets) >= maxBuckets {
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
