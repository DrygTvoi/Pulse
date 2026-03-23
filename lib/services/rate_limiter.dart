/// Per-sender token-bucket rate limiter.
///
/// Each sender gets [maxTokens] tokens initially (burst allowance).
/// Tokens refill at a rate of one per [refillInterval].
/// [allow] returns `true` if a token was consumed, `false` if rate-limited.
///
/// Buckets are capped at [maxBuckets] to prevent unbounded memory growth.
/// When the limit is exceeded, buckets are evicted in LRU order — but senders
/// that have been recently rate-limited are deprioritised for eviction to
/// prevent a burst-and-evict attack (exhaust tokens → go quiet → get evicted
/// → return with a fresh full bucket).
class RateLimiter {
  final int maxTokens;
  final Duration refillInterval;
  final int maxBuckets;
  final Map<String, _Bucket> _buckets = {};

  RateLimiter({
    this.maxTokens = 30,
    this.refillInterval = const Duration(seconds: 2),
    this.maxBuckets = 500,
  });

  bool allow(String senderId) {
    final now = DateTime.now();
    final bucket = _buckets.putIfAbsent(senderId, () => _Bucket(maxTokens, now));
    bucket.lastAccess = now;
    final elapsed = now.difference(bucket.lastRefill);
    final tokensToAdd = elapsed.inMilliseconds ~/ refillInterval.inMilliseconds;
    if (tokensToAdd > 0) {
      bucket.tokens = (bucket.tokens + tokensToAdd).clamp(0, maxTokens);
      // Advance lastRefill by exactly tokensToAdd intervals so fractional
      // elapsed time carries over to the next refill cycle rather than
      // being lost (which would make the limiter slightly stricter than intended).
      bucket.lastRefill = bucket.lastRefill.add(refillInterval * tokensToAdd);
    }
    if (_buckets.length > maxBuckets) {
      _evictOldest();
    }
    if (bucket.tokens > 0) {
      bucket.tokens--;
      return true;
    }
    bucket.lastBlocked = now; // track rate-limit hit for eviction protection
    return false;
  }

  /// Evict buckets until at or below [maxBuckets].
  ///
  /// Sort order:
  ///   1. Buckets with NO recent rate-limit hit evicted first (safe to lose).
  ///   2. Buckets with a recent hit (within the full-refill penalty window)
  ///      are evicted last — evicting them early would reset their penalty.
  ///   3. Within each group, least-recently-accessed first.
  void _evictOldest() {
    final now = DateTime.now();
    // Penalty window = time for a fully-empty bucket to refill to max.
    final penaltyWindow =
        Duration(milliseconds: refillInterval.inMilliseconds * maxTokens);
    final entries = _buckets.entries.toList()
      ..sort((a, b) {
        final aBlocked = a.value.lastBlocked;
        final bBlocked = b.value.lastBlocked;
        final aInPenalty =
            aBlocked != null && now.difference(aBlocked) < penaltyWindow;
        final bInPenalty =
            bBlocked != null && now.difference(bBlocked) < penaltyWindow;
        // Non-penalty senders sort first (evicted first).
        if (aInPenalty != bInPenalty) return aInPenalty ? 1 : -1;
        // Within the same group, evict least-recently-accessed first.
        return a.value.lastAccess.compareTo(b.value.lastAccess);
      });
    final toRemove = _buckets.length - maxBuckets;
    for (var i = 0; i < toRemove; i++) {
      _buckets.remove(entries[i].key);
    }
  }

  void reset(String senderId) => _buckets.remove(senderId);
  void clear() => _buckets.clear();
}

class _Bucket {
  int tokens;
  DateTime lastRefill;
  DateTime lastAccess;
  DateTime? lastBlocked; // last time this sender hit the rate limit

  _Bucket(this.tokens, this.lastRefill) : lastAccess = lastRefill;
}
