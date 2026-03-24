import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for Yggdrasil-related logic.
///
/// Tests cover:
///  1. ICE candidate regex — matches valid Yggdrasil node addresses,
///     rejects non-Yggdrasil addresses.
///  2. Candidate rewrite logic — IPv6 address replaced with loopback.
///  3. YggdrasilService state — isReady reflects _address/_port state.
///
/// The production class (lib/services/signaling_service.dart) depends on
/// flutter_webrtc.  The pure logic is reimplemented here following the same
/// pattern as signaling_service_test.dart.

// ── Reimplemented logic ───────────────────────────────────────────────────────

// Yggdrasil node address range: prefix byte 0x02, leading-1-count byte
// 0x00–0x7f → first hextet 0x0200–0x027f → "200:"–"27f:"
// Pattern used in SignalingService._interceptYggCandidate:
final _yggCandidateRe = RegExp(r'\b(2[0-7][0-9a-fA-F]:[0-9a-fA-F:]+)\s+(\d+)\b');

/// Returns (yggIp, yggPort) if [candidateLine] contains a Yggdrasil relay
/// address, or null otherwise.
(String, String)? extractYggAddress(String candidateLine) {
  final m = _yggCandidateRe.firstMatch(candidateLine);
  if (m == null) return null;
  return (m.group(1)!, m.group(2)!);
}

/// Rewrites a Yggdrasil relay candidate to use a local UDP proxy port.
String rewriteCandidate(String line, String yggIp, String yggPort, int localPort) {
  return line.replaceFirst('$yggIp $yggPort', '127.0.0.1 $localPort');
}

// Minimal YggdrasilService state logic, mirroring the production class.
// isReady requires address + HTTP port + TURN port (all three).
class _YggState {
  String? address;
  int?    port;
  int     turnPort = 0;

  bool get isReady => address != null && port != null && turnPort > 0;

  Map<String, dynamic>? get iceServerEntry {
    if (!isReady) return null;
    return {
      'urls':       'turn:127.0.0.1:$turnPort',
      'username':   'pulse',
      'credential': 'yggtoken',
    };
  }
}

void main() {
  // ── ICE candidate regex ───────────────────────────────────────────────────

  group('Yggdrasil address regex — valid addresses', () {
    // Typical range: "200:" – "20f:" (most common in practice)
    test('matches 200: prefix', () {
      const line = 'candidate:1 1 UDP 100 200:aaa::1 50000 typ relay';
      final r = extractYggAddress(line);
      expect(r, isNotNull);
      expect(r!.$1, equals('200:aaa::1'));
      expect(r.$2, equals('50000'));
    });

    test('matches 20f: prefix', () {
      const line = 'candidate:1 1 UDP 100 20f:bb::cc 60000 typ relay';
      final r = extractYggAddress(line);
      expect(r, isNotNull);
      expect(r!.$1, equals('20f:bb::cc'));
    });

    // Upper range: "210:" – "27f:" (leading-1-count 16–127)
    test('matches 210: prefix (leading-1-count=16)', () {
      const line = 'candidate:1 1 UDP 100 210:dead::1 50001 typ relay';
      final r = extractYggAddress(line);
      expect(r, isNotNull);
      expect(r!.$1, equals('210:dead::1'));
    });

    test('matches 27f: prefix (leading-1-count=127, maximum)', () {
      const line = 'candidate:1 1 UDP 100 27f:cafe::1 50002 typ relay';
      final r = extractYggAddress(line);
      expect(r, isNotNull);
      expect(r!.$1, equals('27f:cafe::1'));
    });

    test('matches address with full expansion', () {
      const line = 'candidate:2 1 UDP 50 201:0:0:0:0:0:0:1 49200 typ relay';
      final r = extractYggAddress(line);
      expect(r, isNotNull);
      expect(r!.$1, startsWith('201:'));
    });

    test('extracts port correctly', () {
      const line = 'candidate:1 1 UDP 100 200:1:2:3:4:5:6:7 12345 typ relay';
      final r = extractYggAddress(line);
      expect(r!.$2, equals('12345'));
    });
  });

  group('Yggdrasil address regex — should NOT match', () {
    test('rejects normal IPv4', () {
      const line = 'candidate:1 1 UDP 100 192.168.1.1 50000 typ srflx';
      expect(extractYggAddress(line), isNull);
    });

    test('rejects public IPv4', () {
      const line = 'candidate:1 1 UDP 100 8.8.8.8 50000 typ host';
      expect(extractYggAddress(line), isNull);
    });

    test('rejects non-Yggdrasil IPv6 (fc00::)', () {
      const line = 'candidate:1 1 UDP 100 fc00::1 50000 typ relay';
      expect(extractYggAddress(line), isNull);
    });

    test('rejects non-Yggdrasil IPv6 (2001: – public but not Yggdrasil)', () {
      // 2001: is outside 0x0200–0x027f range
      const line = 'candidate:1 1 UDP 100 2001:db8::1 50000 typ relay';
      expect(extractYggAddress(line), isNull);
    });

    test('rejects 280: and above (outside Yggdrasil node range)', () {
      // 0x0280 = byte1=0x80 > 0x7f → subnet, not node address
      const line = 'candidate:1 1 UDP 100 280:dead::1 50000 typ relay';
      expect(extractYggAddress(line), isNull);
    });

    test('rejects 300: (subnet range)', () {
      const line = 'candidate:1 1 UDP 100 300:cafe::1 50000 typ relay';
      expect(extractYggAddress(line), isNull);
    });

    test('rejects loopback ::1', () {
      const line = 'candidate:1 1 UDP 100 ::1 50000 typ host';
      expect(extractYggAddress(line), isNull);
    });
  });

  group('Candidate rewrite', () {
    test('replaces Yggdrasil IP and port with loopback', () {
      const line = 'candidate:1 1 UDP 100 200:aaa::1 50000 typ relay '
          'raddr 200:bbb::1 rport 53478';
      const yggIp = '200:aaa::1';
      const yggPort = '50000';
      final result = rewriteCandidate(line, yggIp, yggPort, 12345);
      expect(result, contains('127.0.0.1 12345'));
      expect(result, isNot(contains('200:aaa::1 50000')));
    });

    test('rewritten candidate starts with candidate:', () {
      const line = 'candidate:1 1 UDP 100 201:beef::1 60000 typ relay';
      final result = rewriteCandidate(line, '201:beef::1', '60000', 9999);
      expect(result, startsWith('candidate:'));
    });

    test('raddr in candidate is preserved (raddr not rewritten)', () {
      // pion/webrtc ignores raddr for relay candidates; we only rewrite
      // the connection address, not raddr.
      const line = 'candidate:1 1 UDP 100 200:aa::1 50000 typ relay '
          'raddr 200:bb::1 rport 53478';
      final result = rewriteCandidate(line, '200:aa::1', '50000', 7777);
      // raddr remains
      expect(result, contains('raddr 200:bb::1'));
      // main address is replaced
      expect(result, contains('127.0.0.1 7777'));
    });

    test('rewrite is idempotent for the port', () {
      const line = 'candidate:1 1 UDP 100 200:aa::1 50000 typ relay';
      final r1 = rewriteCandidate(line, '200:aa::1', '50000', 1234);
      // Applying again on r1 would not match (no Yggdrasil IP left)
      expect(extractYggAddress(r1), isNull);
    });
  });

  // ── YggdrasilService state ────────────────────────────────────────────────

  group('YggdrasilService state', () {
    test('isReady false when all null / zero', () {
      expect(_YggState().isReady, isFalse);
    });

    test('isReady false when only proxy port set', () {
      expect((_YggState()..port = 8080).isReady, isFalse);
    });

    test('isReady false when only address set', () {
      expect((_YggState()..address = '200:aaa::1').isReady, isFalse);
    });

    test('isReady false when address+port but turnPort=0 (TURN not started)', () {
      final s = _YggState()
        ..address  = '200:aaa::1'
        ..port     = 8080
        ..turnPort = 0;
      expect(s.isReady, isFalse);
    });

    test('isReady true only when address + port + turnPort > 0', () {
      final s = _YggState()
        ..address  = '200:aaa::1'
        ..port     = 8080
        ..turnPort = 53478;
      expect(s.isReady, isTrue);
    });

    test('iceServerEntry null when not ready', () {
      expect(_YggState().iceServerEntry, isNull);
    });

    test('iceServerEntry contains actual turn port', () {
      final s = _YggState()
        ..address  = '200:aaa::1'
        ..port     = 8080
        ..turnPort = 53479; // non-default port (preferred was busy)
      final entry = s.iceServerEntry!;
      expect(entry['urls'], equals('turn:127.0.0.1:53479'));
      expect(entry['username'], equals('pulse'));
      expect(entry['credential'], equals('yggtoken'));
    });

    test('iceServerEntry uses fallback port when preferred was busy', () {
      final s = _YggState()
        ..address  = '200:aaa::1'
        ..port     = 8080
        ..turnPort = 54321; // OS-assigned port
      expect(s.iceServerEntry!['urls'], equals('turn:127.0.0.1:54321'));
    });
  });

  // ── init() re-init on binary restart ─────────────────────────────────────

  group('init() re-init on port change (binary restart)', () {
    // Simulates the production re-init logic:
    //   if (_initialised && _port == proxyPort) return;
    //   else reset + re-init
    bool shouldSkipInit({
      required bool initialised,
      required int? currentPort,
      required int newPort,
    }) {
      return initialised && currentPort == newPort;
    }

    test('same port after successful init → skip (no-op)', () {
      expect(shouldSkipInit(initialised: true, currentPort: 8080, newPort: 8080), isTrue);
    });

    test('new port after successful init → re-init (binary restarted)', () {
      expect(shouldSkipInit(initialised: true, currentPort: 8080, newPort: 9090), isFalse);
    });

    test('first call (not initialised) → init regardless of port', () {
      expect(shouldSkipInit(initialised: false, currentPort: null, newPort: 8080), isFalse);
    });

    test('not initialised + same port → init (previous attempt failed)', () {
      expect(shouldSkipInit(initialised: false, currentPort: 8080, newPort: 8080), isFalse);
    });

    test('re-init resets address to null until new response received', () {
      // After reset, isReady must be false even if address was set before.
      final s = _YggState()
        ..address  = '200:aaa::1'
        ..port     = 8080
        ..turnPort = 53478;
      expect(s.isReady, isTrue);

      // Simulate reset on port change
      s.address  = null;
      s.turnPort = 0;
      expect(s.isReady, isFalse);
    });
  });
}
