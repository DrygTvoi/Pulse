/// Per-sender token-bucket rate limiter.
///
/// Each sender gets [maxTokens] tokens initially (burst allowance).
/// Tokens refill at a rate of one per [refillInterval].
/// [allow] returns `true` if a token was consumed, `false` if rate-limited.
///
/// Buckets are capped at [maxBuckets] to prevent unbounded memory growth.
/// When the limit is exceeded, the least-recently-accessed buckets are evicted.
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
      bucket.lastRefill = now;
    }
    if (_buckets.length > maxBuckets) {
      _evictOldest();
    }
    if (bucket.tokens > 0) {
      bucket.tokens--;
      return true;
    }
    return false;
  }

  /// Evict the oldest buckets by lastAccess until at or below maxBuckets.
  void _evictOldest() {
    final entries = _buckets.entries.toList()
      ..sort((a, b) => a.value.lastAccess.compareTo(b.value.lastAccess));
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
  _Bucket(this.tokens, this.lastRefill) : lastAccess = lastRefill;
}
