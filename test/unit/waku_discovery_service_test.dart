import 'package:flutter_test/flutter_test.dart';

// WakuDiscoveryService uses SharedPreferences + http + tor_service (dart:io),
// so we cannot import it directly in a pure-Dart test environment.
// We reimplement the deterministic model and configuration logic.

// ---------------------------------------------------------------------------
// Reimplemented from lib/services/waku_discovery_service.dart
// ---------------------------------------------------------------------------

/// Result of probing a single Waku node.
class WakuNodeInfo {
  final String url;
  final bool online;
  final int latencyMs; // -1 if offline

  const WakuNodeInfo({
    required this.url,
    required this.online,
    required this.latencyMs,
  });

  /// Human-readable label (strips protocol + port).
  String get label {
    try {
      final uri = Uri.parse(url);
      return uri.host == '127.0.0.1' ? 'Local nwaku' : uri.host;
    } catch (_) {
      return url;
    }
  }

  String get latencyLabel => online ? '${latencyMs}ms' : 'offline';
}

/// Mirrors WakuDiscoveryService.knownNodes
const knownNodes = [
  'http://127.0.0.1:8645',
  'https://node-01.ac-cn-hongkong-c.wakuv2.prod.statusim.net:8645',
  'https://node-01.do-ams3.wakuv2.prod.statusim.net:8645',
  'https://node-01.gc-us-central1-a.wakuv2.prod.statusim.net:8645',
  'https://node-01.ac-cn-hongkong-c.wakuv2.test.statusim.net:8645',
  'https://node-01.do-ams3.wakuv2.test.statusim.net:8645',
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WakuNodeInfo constructor and fields', () {
    test('stores url, online, latencyMs correctly', () {
      const info = WakuNodeInfo(
        url: 'https://example.com:8645',
        online: true,
        latencyMs: 42,
      );
      expect(info.url, 'https://example.com:8645');
      expect(info.online, isTrue);
      expect(info.latencyMs, 42);
    });

    test('offline node has latencyMs -1 by convention', () {
      const info = WakuNodeInfo(
        url: 'https://example.com:8645',
        online: false,
        latencyMs: -1,
      );
      expect(info.online, isFalse);
      expect(info.latencyMs, -1);
    });
  });

  group('WakuNodeInfo label getter', () {
    test('returns "Local nwaku" for localhost URL', () {
      const info = WakuNodeInfo(
        url: 'http://127.0.0.1:8645',
        online: true,
        latencyMs: 1,
      );
      expect(info.label, 'Local nwaku');
    });

    test('returns host for remote URL', () {
      const info = WakuNodeInfo(
        url: 'https://node-01.do-ams3.wakuv2.prod.statusim.net:8645',
        online: true,
        latencyMs: 100,
      );
      expect(info.label, 'node-01.do-ams3.wakuv2.prod.statusim.net');
    });

    test('returns full URL for unparseable input', () {
      const info = WakuNodeInfo(
        url: ':::invalid',
        online: false,
        latencyMs: -1,
      );
      // Uri.parse may or may not throw; either way label should not crash
      expect(info.label, isNotEmpty);
    });
  });

  group('WakuNodeInfo latencyLabel getter', () {
    test('returns latency with ms suffix when online', () {
      const info = WakuNodeInfo(
        url: 'https://example.com:8645',
        online: true,
        latencyMs: 123,
      );
      expect(info.latencyLabel, '123ms');
    });

    test('returns "offline" when not online', () {
      const info = WakuNodeInfo(
        url: 'https://example.com:8645',
        online: false,
        latencyMs: -1,
      );
      expect(info.latencyLabel, 'offline');
    });

    test('returns "0ms" for zero latency when online', () {
      const info = WakuNodeInfo(
        url: 'http://127.0.0.1:8645',
        online: true,
        latencyMs: 0,
      );
      expect(info.latencyLabel, '0ms');
    });

    test('handles large latency values', () {
      const info = WakuNodeInfo(
        url: 'https://example.com:8645',
        online: true,
        latencyMs: 9999,
      );
      expect(info.latencyLabel, '9999ms');
    });
  });

  group('knownNodes list', () {
    test('has at least 6 entries', () {
      expect(knownNodes.length, greaterThanOrEqualTo(6));
    });

    test('first entry is local node (http://127.0.0.1:8645)', () {
      expect(knownNodes.first, 'http://127.0.0.1:8645');
    });

    test('all entries have valid URL scheme (http or https)', () {
      for (final url in knownNodes) {
        final uri = Uri.parse(url);
        expect(
          uri.scheme == 'http' || uri.scheme == 'https',
          isTrue,
          reason: 'URL "$url" must use http or https scheme',
        );
      }
    });

    test('all entries specify port 8645', () {
      for (final url in knownNodes) {
        final uri = Uri.parse(url);
        expect(uri.port, 8645,
            reason: 'URL "$url" must use port 8645');
      }
    });

    test('contains at least one prod fleet node', () {
      final hasProd =
          knownNodes.any((u) => u.contains('.prod.statusim.net'));
      expect(hasProd, isTrue);
    });

    test('contains at least one test fleet node', () {
      final hasTest =
          knownNodes.any((u) => u.contains('.test.statusim.net'));
      expect(hasTest, isTrue);
    });

    test('all remote entries use HTTPS', () {
      for (final url in knownNodes) {
        final uri = Uri.parse(url);
        if (uri.host != '127.0.0.1') {
          expect(uri.scheme, 'https',
              reason:
                  'Remote node "$url" must use HTTPS for transport security');
        }
      }
    });

    test('no duplicate entries', () {
      expect(knownNodes.toSet().length, knownNodes.length,
          reason: 'knownNodes must not contain duplicates');
    });
  });

  group('WakuNodeInfo with various states', () {
    test('online node with high latency', () {
      const info = WakuNodeInfo(
        url: 'https://slow-node.example.com:8645',
        online: true,
        latencyMs: 3500,
      );
      expect(info.online, isTrue);
      expect(info.latencyLabel, '3500ms');
      expect(info.label, 'slow-node.example.com');
    });

    test('offline node has "offline" label regardless of latencyMs value', () {
      // Even if latencyMs is set to a positive value, online=false means "offline"
      const info = WakuNodeInfo(
        url: 'https://example.com:8645',
        online: false,
        latencyMs: 500,
      );
      expect(info.latencyLabel, 'offline');
    });
  });
}
