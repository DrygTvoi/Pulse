import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('allows up to maxTokens requests immediately (burst)', () {
      final limiter = RateLimiter(maxTokens: 5, refillInterval: const Duration(seconds: 10));
      for (int i = 0; i < 5; i++) {
        expect(limiter.allow('alice'), isTrue, reason: 'burst request $i should be allowed');
      }
    });

    test('rejects when burst is exhausted', () {
      final limiter = RateLimiter(maxTokens: 3, refillInterval: const Duration(seconds: 10));
      limiter.allow('alice');
      limiter.allow('alice');
      limiter.allow('alice');
      expect(limiter.allow('alice'), isFalse);
    });

    test('different senders have independent buckets', () {
      final limiter = RateLimiter(maxTokens: 1, refillInterval: const Duration(seconds: 10));
      expect(limiter.allow('alice'), isTrue);
      expect(limiter.allow('alice'), isFalse);
      // Bob still has his own full bucket
      expect(limiter.allow('bob'), isTrue);
    });

    test('refills tokens after interval passes', () async {
      final limiter = RateLimiter(maxTokens: 2, refillInterval: const Duration(milliseconds: 50));
      limiter.allow('alice');
      limiter.allow('alice');
      expect(limiter.allow('alice'), isFalse); // exhausted

      await Future.delayed(const Duration(milliseconds: 110)); // ≥2 intervals
      expect(limiter.allow('alice'), isTrue); // should have refilled
    });

    test('tokens are capped at maxTokens after long idle', () async {
      final limiter = RateLimiter(maxTokens: 3, refillInterval: const Duration(milliseconds: 10));
      limiter.allow('alice'); // 1 consumed

      await Future.delayed(const Duration(milliseconds: 200)); // many intervals pass
      // Tokens should be capped at maxTokens (3), not overflow to e.g. 20
      int allowed = 0;
      for (int i = 0; i < 10; i++) {
        if (limiter.allow('alice')) allowed++;
      }
      expect(allowed, equals(3)); // still capped at maxTokens
    });

    test('reset() restores a sender to full bucket', () {
      final limiter = RateLimiter(maxTokens: 2, refillInterval: const Duration(seconds: 10));
      limiter.allow('alice');
      limiter.allow('alice');
      expect(limiter.allow('alice'), isFalse);

      limiter.reset('alice');
      expect(limiter.allow('alice'), isTrue); // bucket restored
    });

    test('clear() removes all buckets', () {
      final limiter = RateLimiter(maxTokens: 1, refillInterval: const Duration(seconds: 10));
      limiter.allow('alice');
      limiter.allow('bob');
      expect(limiter.allow('alice'), isFalse);
      expect(limiter.allow('bob'), isFalse);

      limiter.clear();
      expect(limiter.allow('alice'), isTrue);
      expect(limiter.allow('bob'), isTrue);
    });

    test('reset() on unknown sender is a no-op', () {
      final limiter = RateLimiter(maxTokens: 2);
      expect(() => limiter.reset('nobody'), returnsNormally);
    });
  });
}
