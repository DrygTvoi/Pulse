// Tests for pure-Dart logic from TorService.
//
// We do NOT import lib/services/tor_service.dart because it depends on
// dart:io (Process, Socket, ServerSocket) and path_provider which are
// unavailable / undesirable in a pure unit-test environment.
//
// Instead we reimplement the testable algorithms inline and verify them.

import 'package:flutter_test/flutter_test.dart';

// ─── Reimplemented constants ───────────────────────────────────────────────────

const int torSocksPort = 9250;

// ─── Reimplemented: PT mode enum ───────────────────────────────────────────────

enum PtMode { obfs4, webTunnel, snowflake, plain }

String activePtLabel(PtMode? mode) => switch (mode) {
      PtMode.obfs4 => 'obfs4',
      PtMode.webTunnel => 'webtunnel',
      PtMode.snowflake => 'snowflake',
      PtMode.plain => 'plain',
      null => '',
    };

// ─── Reimplemented: bootstrap percentage parser ────────────────────────────────
// Mirrors the regex in _launchTor:
//   final pct = RegExp(r'Bootstrapped (\d+)%').firstMatch(line);

int? parseBootstrapPercent(String line) {
  final match = RegExp(r'Bootstrapped (\d+)%').firstMatch(line);
  if (match == null) return null;
  return int.parse(match.group(1)!);
}

bool isBootstrapComplete(String line) => line.contains('Bootstrapped 100%');

// ─── Reimplemented: torrc generation ───────────────────────────────────────────
// Mirrors _writeTorrc() — pure string generation (no File I/O).

String buildTorrc({
  required String dataDir,
  required PtMode mode,
  String? ptPath,
  List<String> bridges = const [],
}) {
  final buf = StringBuffer()
    ..writeln('SocksPort $torSocksPort')
    ..writeln('DataDirectory $dataDir')
    ..writeln('Log notice stdout')
    ..writeln('LearnCircuitBuildTimeout 1')
    ..writeln('CircuitBuildTimeout 60');

  switch (mode) {
    case PtMode.obfs4:
      buf
        ..writeln('UseBridges 1')
        ..writeln('ClientTransportPlugin obfs4 exec $ptPath');
      for (final b in bridges) {
        buf.writeln('Bridge $b');
      }
    case PtMode.webTunnel:
      buf
        ..writeln('UseBridges 1')
        ..writeln('ClientTransportPlugin webtunnel exec $ptPath');
      for (final b in bridges) {
        buf.writeln('Bridge $b');
      }
    case PtMode.snowflake:
      const sfStun = 'stun:stun.cloudflare.com:3478,'
          'stun:global.stun.twilio.com:3478,'
          'stun:stun.relay.metered.ca:80,'
          'stun:stun.nextcloud.com:3478,'
          'stun:stun.nextcloud.com:443,'
          'stun:stun.bethesda.net:3478,'
          'stun:stun.mixvoip.com:3478,'
          'stun:stun.voipgate.com:3478,'
          'stun:stun.epygi.com:3478,'
          'stun:stun.stunprotocol.org:3478,'
          'stun:stun.services.mozilla.com:3478,'
          'stun:74.125.250.129:19302';
      buf
        ..writeln('UseBridges 1')
        ..writeln('ClientTransportPlugin snowflake exec $ptPath '
            '-max-peers 1 -ice $sfStun');
      for (final b in bridges) {
        buf.writeln('Bridge $b');
      }
    case PtMode.plain:
      break; // no bridges
  }

  return buf.toString();
}

// ─── Reimplemented: SOCKS5 reply code descriptions ─────────────────────────────
// From connectWebSocket error handling.

String socks5ReplyDescription(int code) {
  const repMsg = {
    0x01: 'general failure',
    0x02: 'not allowed by ruleset',
    0x03: 'network unreachable',
    0x04: 'host unreachable',
    0x05: 'connection refused',
    0x06: 'TTL expired',
    0x07: 'command not supported',
    0x08: 'address type not supported',
  };
  return repMsg[code] ?? 'unknown (0x${code.toRadixString(16)})';
}

// ─── Reimplemented: HTTP response status parsing ───────────────────────────────
// From postUrlViaSocks5.

int? parseHttpStatusCode(String response) {
  final hdrEnd = response.indexOf('\r\n\r\n');
  if (hdrEnd < 0) return null;
  final firstLineEnd = response.indexOf('\r\n');
  if (firstLineEnd < 0) return null;
  final statusLine = response.substring(0, firstLineEnd);
  final parts = statusLine.split(' ');
  if (parts.length < 2) return null;
  return int.tryParse(parts[1]);
}

String? parseHttpBody(String response) {
  final hdrEnd = response.indexOf('\r\n\r\n');
  if (hdrEnd < 0) return null;
  return response.substring(hdrEnd + 4);
}

// ─── Reimplemented: Host header generation ─────────────────────────────────────
// From postUrlViaSocks5.

String buildHostHeader(String targetHost, int targetPort) {
  if (targetPort == 443 || targetPort == 80) return targetHost;
  return '$targetHost:$targetPort';
}

// ─── Reimplemented: torrc file path ────────────────────────────────────────────

String torrcPath(String dataDir, PtMode mode) =>
    '$dataDir/torrc_${mode.name}';

// ─── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('TorService constants', () {
    test('SOCKS port is 9250 to avoid system tor conflict', () {
      expect(torSocksPort, equals(9250));
      // Must not collide with default Tor port
      expect(torSocksPort, isNot(equals(9050)));
    });
  });

  group('PT mode labels', () {
    test('each mode has a non-empty label', () {
      expect(activePtLabel(PtMode.obfs4), equals('obfs4'));
      expect(activePtLabel(PtMode.webTunnel), equals('webtunnel'));
      expect(activePtLabel(PtMode.snowflake), equals('snowflake'));
      expect(activePtLabel(PtMode.plain), equals('plain'));
    });

    test('null mode returns empty string', () {
      expect(activePtLabel(null), equals(''));
    });
  });

  group('Bootstrap percentage parsing', () {
    test('parses typical bootstrap line', () {
      const line =
          'Mar 21 12:00:00.000 [notice] Bootstrapped 45% (loading_descriptors)';
      expect(parseBootstrapPercent(line), equals(45));
    });

    test('parses 0% bootstrap', () {
      expect(
          parseBootstrapPercent('Bootstrapped 0% (starting)'), equals(0));
    });

    test('parses 100% bootstrap', () {
      expect(parseBootstrapPercent('Bootstrapped 100% (done)'), equals(100));
    });

    test('returns null for non-bootstrap lines', () {
      expect(parseBootstrapPercent('[notice] Opening SOCKS listener on 127.0.0.1:9250'),
          isNull);
      expect(parseBootstrapPercent(''), isNull);
      expect(parseBootstrapPercent('Some random log line'), isNull);
    });

    test('isBootstrapComplete detects 100%', () {
      expect(isBootstrapComplete('Bootstrapped 100% (done)'), isTrue);
      expect(isBootstrapComplete('Bootstrapped 99% (loading_descriptors)'),
          isFalse);
      expect(isBootstrapComplete('Starting Tor'), isFalse);
    });

    test('handles multi-digit percentages', () {
      expect(parseBootstrapPercent('Bootstrapped 5%'), equals(5));
      expect(parseBootstrapPercent('Bootstrapped 15%'), equals(15));
      expect(parseBootstrapPercent('Bootstrapped 100%'), equals(100));
    });
  });

  group('Torrc generation', () {
    test('plain mode produces minimal config without bridges', () {
      final rc = buildTorrc(dataDir: '/tmp/tor', mode: PtMode.plain);

      expect(rc, contains('SocksPort 9250'));
      expect(rc, contains('DataDirectory /tmp/tor'));
      expect(rc, contains('Log notice stdout'));
      expect(rc, contains('LearnCircuitBuildTimeout 1'));
      expect(rc, contains('CircuitBuildTimeout 60'));
      expect(rc, isNot(contains('UseBridges')));
      expect(rc, isNot(contains('ClientTransportPlugin')));
      expect(rc, isNot(contains('Bridge ')));
    });

    test('obfs4 mode includes UseBridges and ClientTransportPlugin', () {
      final rc = buildTorrc(
        dataDir: '/tmp/tor',
        mode: PtMode.obfs4,
        ptPath: '/usr/bin/obfs4proxy',
        bridges: [
          'obfs4 1.2.3.4:443 AAAA cert=BBBB iat-mode=0',
          'obfs4 5.6.7.8:9001 CCCC cert=DDDD iat-mode=0',
        ],
      );

      expect(rc, contains('UseBridges 1'));
      expect(rc, contains('ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy'));
      expect(rc, contains('Bridge obfs4 1.2.3.4:443 AAAA cert=BBBB iat-mode=0'));
      expect(rc, contains('Bridge obfs4 5.6.7.8:9001 CCCC cert=DDDD iat-mode=0'));
    });

    test('webTunnel mode uses webtunnel transport plugin', () {
      final rc = buildTorrc(
        dataDir: '/data/tor',
        mode: PtMode.webTunnel,
        ptPath: '/usr/bin/lyrebird',
        bridges: ['webtunnel [2001:db8::1]:443 url=https://example.com/path'],
      );

      expect(rc, contains('UseBridges 1'));
      expect(rc, contains('ClientTransportPlugin webtunnel exec /usr/bin/lyrebird'));
      expect(rc,
          contains('Bridge webtunnel [2001:db8::1]:443 url=https://example.com/path'));
    });

    test('snowflake mode includes STUN servers and bridge lines', () {
      final rc = buildTorrc(
        dataDir: '/tmp/tor',
        mode: PtMode.snowflake,
        ptPath: '/usr/bin/snowflake-client',
        bridges: ['snowflake 192.0.2.3:80 fingerprint=ABC'],
      );

      expect(rc, contains('UseBridges 1'));
      expect(rc, contains('ClientTransportPlugin snowflake exec /usr/bin/snowflake-client'));
      expect(rc, contains('-max-peers 1'));
      expect(rc, contains('-ice stun:stun.cloudflare.com:3478'));
      expect(rc, contains('stun:74.125.250.129:19302'));
      expect(rc, contains('Bridge snowflake 192.0.2.3:80 fingerprint=ABC'));
    });

    test('empty bridges list produces no Bridge lines', () {
      final rc = buildTorrc(
        dataDir: '/tmp/tor',
        mode: PtMode.obfs4,
        ptPath: '/usr/bin/obfs4proxy',
        bridges: [],
      );

      expect(rc, contains('UseBridges 1'));
      expect(rc, contains('ClientTransportPlugin obfs4'));
      expect(rc, isNot(contains('Bridge ')));
    });

    test('snowflake STUN list has non-Google servers first', () {
      final rc = buildTorrc(
        dataDir: '/tmp/tor',
        mode: PtMode.snowflake,
        ptPath: '/usr/bin/snowflake-client',
      );

      // Cloudflare STUN appears before Google's 74.125.* IP
      final cfIdx = rc.indexOf('stun:stun.cloudflare.com');
      final googleIdx = rc.indexOf('stun:74.125.250.129');
      expect(cfIdx, lessThan(googleIdx),
          reason: 'Non-Google STUN servers should come before Google (blocked in CN)');
    });
  });

  group('SOCKS5 reply descriptions', () {
    test('known reply codes return descriptive strings', () {
      expect(socks5ReplyDescription(0x01), equals('general failure'));
      expect(socks5ReplyDescription(0x03), equals('network unreachable'));
      expect(socks5ReplyDescription(0x04), equals('host unreachable'));
      expect(socks5ReplyDescription(0x05), equals('connection refused'));
      expect(socks5ReplyDescription(0x06), equals('TTL expired'));
      expect(socks5ReplyDescription(0x07), equals('command not supported'));
      expect(socks5ReplyDescription(0x08), equals('address type not supported'));
    });

    test('unknown reply code returns hex string', () {
      expect(socks5ReplyDescription(0x09), equals('unknown (0x9)'));
      expect(socks5ReplyDescription(0xFF), equals('unknown (0xff)'));
    });
  });

  group('HTTP response parsing', () {
    test('parses status 200', () {
      const resp = 'HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello';
      expect(parseHttpStatusCode(resp), equals(200));
      expect(parseHttpBody(resp), equals('Hello'));
    });

    test('parses status 404', () {
      const resp = 'HTTP/1.1 404 Not Found\r\n\r\nNot here';
      expect(parseHttpStatusCode(resp), equals(404));
    });

    test('returns null for malformed response (no header end)', () {
      const resp = 'HTTP/1.1 200 OK\r\nContent-Type: text/plain';
      expect(parseHttpStatusCode(resp), isNull);
      expect(parseHttpBody(resp), isNull);
    });

    test('returns null for empty string', () {
      expect(parseHttpStatusCode(''), isNull);
      expect(parseHttpBody(''), isNull);
    });
  });

  group('Host header generation', () {
    test('standard ports omit port number', () {
      expect(buildHostHeader('example.com', 443), equals('example.com'));
      expect(buildHostHeader('example.com', 80), equals('example.com'));
    });

    test('non-standard ports include port number', () {
      expect(buildHostHeader('example.com', 8080), equals('example.com:8080'));
      expect(buildHostHeader('snode.oxen.io', 22021),
          equals('snode.oxen.io:22021'));
    });
  });

  group('Torrc file path', () {
    test('constructs path with mode name', () {
      expect(torrcPath('/tmp/tor', PtMode.obfs4), equals('/tmp/tor/torrc_obfs4'));
      expect(torrcPath('/tmp/tor', PtMode.webTunnel),
          equals('/tmp/tor/torrc_webTunnel'));
      expect(torrcPath('/tmp/tor', PtMode.snowflake),
          equals('/tmp/tor/torrc_snowflake'));
      expect(torrcPath('/tmp/tor', PtMode.plain), equals('/tmp/tor/torrc_plain'));
    });
  });
}
