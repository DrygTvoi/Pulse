/// Per-sender token-bucket rate limiter.
///
/// Each sender gets [maxTokens] tokens initially (burst allowance).
/// Tokens refill at a rate of one per [refillInterval].
/// [allow] returns `true` if a token was consumed, `false` if rate-limited.
class RateLimiter {
  final int maxTokens;
  final Duration refillInterval;
  final Map<String, _Bucket> _buckets = {};

  RateLimiter({this.maxTokens = 30, this.refillInterval = const Duration(seconds: 2)});

  bool allow(String senderId) {
    final now = DateTime.now();
    final bucket = _buckets.putIfAbsent(senderId, () => _Bucket(maxTokens, now));
    final elapsed = now.difference(bucket.lastRefill);
    final tokensToAdd = elapsed.inMilliseconds ~/ refillInterval.inMilliseconds;
    if (tokensToAdd > 0) {
      bucket.tokens = (bucket.tokens + tokensToAdd).clamp(0, maxTokens);
      bucket.lastRefill = now;
    }
    if (bucket.tokens > 0) {
      bucket.tokens--;
      return true;
    }
    return false;
  }

  void reset(String senderId) => _buckets.remove(senderId);
  void clear() => _buckets.clear();
}

class _Bucket {
  int tokens;
  DateTime lastRefill;
  _Bucket(this.tokens, this.lastRefill);
}
