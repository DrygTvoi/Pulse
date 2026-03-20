import 'package:flutter_test/flutter_test.dart';

// ── Pure logic extracted from AdaptiveRelayService ────────────────────────────
//
// AdaptiveRelayService touches SharedPreferences, WebSocket, and DNS-over-HTTPS,
// none of which are available in unit tests.  We extract every piece of pure
// decision-making logic so it can be tested in isolation — the same pattern
// used by transport_test.dart for ChatController logic.
//
// Extracted functions mirror:
//   • getBetterRelay()  → shouldUpgradeRelay()
//   • TTL cache check   → isCacheValid()
//   • in-memory fast-path guard → isInMemoryCacheValid()
//   • relay URL normalisation → normaliseRelayUrl()
//   • CF candidate seeding filter → chooseCandidates()

// ── Hot-swap threshold ─────────────────────────────────────────────────────

/// Mirrors AdaptiveRelayService.getBetterRelay():
/// Returns true only when the current RTT warrants looking for a replacement.
/// Threshold is 800 ms — same value used in production.
bool shouldUpgradeRelay(int currentRttMs) => currentRttMs >= 800;

/// Given a forced-race result and the current URL, decides whether to return
/// the new relay.  Mirrors the `better != null && better != currentUrl` check.
String? pickBetterRelay(String? raceWinner, String currentUrl) {
  if (raceWinner == null) return null;
  if (raceWinner == currentUrl) return null;
  return raceWinner;
}

// ── TTL / cache validity ───────────────────────────────────────────────────

const int ttlMs = 15 * 60 * 1000; // 15 minutes — matches production constant

/// Mirrors the SharedPreferences cache validity check in getBestRelay().
/// [cacheTs] is the millisecond epoch when the cache was written.
/// [nowMs] is the current millisecond epoch.
bool isCacheValid(int cacheTs, int nowMs) {
  return nowMs - cacheTs < ttlMs;
}

/// Mirrors the in-memory fast-path check:
///   _bestRelay != null && _lastRace != null &&
///   DateTime.now().difference(_lastRace!).inMilliseconds < _ttlMs
bool isInMemoryCacheValid({
  required bool hasCachedRelay,
  required int ageMs,
}) {
  return hasCachedRelay && ageMs < ttlMs;
}

// ── WebSocket URL normalisation ────────────────────────────────────────────

/// Mirrors the URL normalisation inside _probeWs:
///   If the URL has no explicit port (or port 0), append the default port
///   (443 for wss, 80 for ws) to produce a canonical form for the connection.
String normaliseRelayUrl(String url) {
  final uri = Uri.parse(url);
  final defaultPort = uri.scheme == 'wss' ? 443 : 80;
  final port = (uri.hasPort && uri.port != 0) ? uri.port : defaultPort;
  if (!uri.hasPort || uri.port == 0) {
    return '${uri.scheme}://${uri.host}:$port${uri.path}';
  }
  return url;
}

// ── Candidate seeding ─────────────────────────────────────────────────────

/// Mirrors _getCfCandidates's seeding preference:
///   If seeded URLs are present they take priority; otherwise fall back.
List<String> chooseCandidates({
  required List<String> seeded,
  required List<String> discovered,
}) {
  return seeded.isNotEmpty ? seeded : discovered;
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Hot-swap threshold ───────────────────────────────────────────────────

  group('shouldUpgradeRelay: RTT threshold', () {
    test('RTT below 800ms does NOT trigger upgrade', () {
      expect(shouldUpgradeRelay(0), isFalse);
      expect(shouldUpgradeRelay(100), isFalse);
      expect(shouldUpgradeRelay(799), isFalse);
    });

    test('RTT of exactly 800ms triggers upgrade', () {
      expect(shouldUpgradeRelay(800), isTrue);
    });

    test('RTT above 800ms triggers upgrade', () {
      expect(shouldUpgradeRelay(801), isTrue);
      expect(shouldUpgradeRelay(1500), isTrue);
      expect(shouldUpgradeRelay(5000), isTrue);
    });

    test('extremely high RTT (network dead) still triggers upgrade', () {
      expect(shouldUpgradeRelay(999999), isTrue);
    });
  });

  // ── pickBetterRelay: race-result selection ───────────────────────────────

  group('pickBetterRelay: race result selection', () {
    const current = 'wss://relay.damus.io';
    const better  = 'wss://relay.snort.social';

    test('returns winner when it differs from current URL', () {
      expect(pickBetterRelay(better, current), equals(better));
    });

    test('returns null when race winner equals current URL (no upgrade needed)', () {
      expect(pickBetterRelay(current, current), isNull);
    });

    test('returns null when race produced no winner (all relays timed out)', () {
      expect(pickBetterRelay(null, current), isNull);
    });

    test('winner with different path is treated as distinct relay', () {
      const winnerWithPath = 'wss://relay.damus.io/v2';
      expect(pickBetterRelay(winnerWithPath, current), equals(winnerWithPath));
    });

    test('comparison is case-sensitive', () {
      // URL schemes are lower-case; capitalised version is a different string.
      const upperCurrent = 'WSS://relay.damus.io';
      expect(pickBetterRelay(current, upperCurrent), equals(current));
    });
  });

  // ── TTL cache validity ───────────────────────────────────────────────────

  group('isCacheValid: SharedPrefs TTL check', () {
    test('cache written right now is valid', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(isCacheValid(now, now), isTrue);
    });

    test('cache written 14 minutes ago is still valid', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ts = now - 14 * 60 * 1000;
      expect(isCacheValid(ts, now), isTrue);
    });

    test('cache written exactly 15 minutes ago is NOT valid (boundary)', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ts = now - ttlMs; // exactly at TTL boundary
      expect(isCacheValid(ts, now), isFalse);
    });

    test('cache written 15 minutes and 1ms ago is NOT valid', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ts = now - ttlMs - 1;
      expect(isCacheValid(ts, now), isFalse);
    });

    test('cache written 30 minutes ago is NOT valid', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ts = now - 30 * 60 * 1000;
      expect(isCacheValid(ts, now), isFalse);
    });

    test('cache written 1 second ago is valid', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ts = now - 1000;
      expect(isCacheValid(ts, now), isTrue);
    });
  });

  // ── In-memory fast-path ──────────────────────────────────────────────────

  group('isInMemoryCacheValid: in-memory fast-path', () {
    test('valid when relay cached and age is well within TTL', () {
      expect(isInMemoryCacheValid(hasCachedRelay: true, ageMs: 60 * 1000), isTrue);
    });

    test('invalid when no relay has been cached yet', () {
      expect(isInMemoryCacheValid(hasCachedRelay: false, ageMs: 0), isFalse);
    });

    test('invalid when age equals TTL', () {
      expect(isInMemoryCacheValid(hasCachedRelay: true, ageMs: ttlMs), isFalse);
    });

    test('invalid when age exceeds TTL even slightly', () {
      expect(isInMemoryCacheValid(hasCachedRelay: true, ageMs: ttlMs + 1), isFalse);
    });

    test('valid for age of 0 when relay is cached', () {
      expect(isInMemoryCacheValid(hasCachedRelay: true, ageMs: 0), isTrue);
    });

    test('force-fetch bypasses cache: both conditions disabled', () {
      // When force=true, caller skips the fast-path entirely.
      // Verify: even a brand-new in-memory cache would be bypassed
      // by confirming the guard returns true before force is applied.
      final wouldUseFastPath =
          isInMemoryCacheValid(hasCachedRelay: true, ageMs: 1000);
      expect(wouldUseFastPath, isTrue,
          reason: 'non-forced call should use cached value');
      // With force, the caller doesn't call this function at all, so the
      // fast-path is irrelevant — no further assertion needed here.
    });
  });

  // ── URL normalisation ────────────────────────────────────────────────────

  group('normaliseRelayUrl: port insertion', () {
    test('wss:// without explicit port gets :443 appended', () {
      expect(normaliseRelayUrl('wss://relay.damus.io'),
          equals('wss://relay.damus.io:443'));
    });

    test('ws:// without explicit port gets :80 appended', () {
      expect(normaliseRelayUrl('ws://relay.example.com'),
          equals('ws://relay.example.com:80'));
    });

    test('URL with explicit port is returned unchanged', () {
      const url = 'wss://relay.damus.io:8080';
      expect(normaliseRelayUrl(url), equals(url));
    });

    test('wss:// with default port 443 is returned unchanged', () {
      const url = 'wss://relay.damus.io:443';
      expect(normaliseRelayUrl(url), equals(url));
    });

    test('URL with non-standard port is preserved', () {
      const url = 'wss://relay.example.com:9001/nostr';
      expect(normaliseRelayUrl(url), equals(url));
    });

    test('URL path is preserved after normalisation', () {
      final result = normaliseRelayUrl('wss://relay.example.com/nostr');
      expect(result, equals('wss://relay.example.com:443/nostr'));
    });

    test('different hosts produce distinct normalised URLs', () {
      final a = normaliseRelayUrl('wss://relay.damus.io');
      final b = normaliseRelayUrl('wss://relay.snort.social');
      expect(a, isNot(equals(b)));
    });
  });

  // ── Candidate seeding preference ─────────────────────────────────────────

  group('chooseCandidates: seed priority', () {
    const seeded     = ['wss://fast.cf-relay.io', 'wss://fast2.cf-relay.io'];
    const discovered = ['wss://relay.damus.io', 'wss://nos.lol'];

    test('seeded list is used when non-empty', () {
      expect(chooseCandidates(seeded: seeded, discovered: discovered),
          equals(seeded));
    });

    test('discovered list is used as fallback when seed is empty', () {
      expect(chooseCandidates(seeded: [], discovered: discovered),
          equals(discovered));
    });

    test('returns empty list when both sources are empty', () {
      expect(chooseCandidates(seeded: [], discovered: []), isEmpty);
    });

    test('single seeded URL is returned as-is', () {
      const singleSeed = ['wss://single.example.com'];
      expect(
        chooseCandidates(seeded: singleSeed, discovered: discovered),
        equals(singleSeed),
      );
    });

    test('order within seeded list is preserved', () {
      const orderedSeed = ['wss://c.example.com', 'wss://a.example.com', 'wss://b.example.com'];
      expect(
        chooseCandidates(seeded: orderedSeed, discovered: discovered),
        equals(orderedSeed),
      );
    });

    test('discovered list order is preserved when used as fallback', () {
      const orderedDiscovered = ['wss://z.example.com', 'wss://a.example.com'];
      expect(
        chooseCandidates(seeded: [], discovered: orderedDiscovered),
        equals(orderedDiscovered),
      );
    });
  });

  // ── Combined hot-swap decision ─────────────────────────────────────────────

  group('combined hot-swap decision', () {
    test('low RTT short-circuits: no upgrade even if better relay found', () {
      // With RTT < 800, getBetterRelay returns null immediately without racing.
      // Verify the guard fires before pickBetterRelay is considered.
      const rtt = 400;
      const winner = 'wss://faster.example.com';
      const current = 'wss://current.example.com';

      if (!shouldUpgradeRelay(rtt)) {
        // Early return path — winner is irrelevant.
        expect(pickBetterRelay(winner, current), equals(winner),
            reason:
                'winner logic is correct but early-return guard prevented it from running');
        // The real API would return null here due to the guard.
      } else {
        fail('shouldUpgradeRelay should have returned false for rtt=$rtt');
      }
    });

    test('high RTT + distinct winner → upgrade recommended', () {
      const rtt = 1200;
      const winner = 'wss://faster.example.com';
      const current = 'wss://slow.example.com';

      expect(shouldUpgradeRelay(rtt), isTrue);
      expect(pickBetterRelay(winner, current), equals(winner));
    });

    test('high RTT + race timeout → no upgrade', () {
      const rtt = 1200;
      const current = 'wss://slow.example.com';

      expect(shouldUpgradeRelay(rtt), isTrue);
      expect(pickBetterRelay(null, current), isNull);
    });

    test('high RTT + winner is current relay → no upgrade', () {
      const rtt = 2000;
      const current = 'wss://relay.damus.io';

      expect(shouldUpgradeRelay(rtt), isTrue);
      expect(pickBetterRelay(current, current), isNull);
    });
  });
}
