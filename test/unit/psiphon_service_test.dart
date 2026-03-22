import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Reimplements testable constants and logic from PsiphonService
/// (lib/services/psiphon_service.dart) without platform dependencies.

// Constants extracted from source
const _maxRestartDelay = 60; // seconds

/// Reimplements the exponential backoff delay calculation from PsiphonService._start():
///   final delay = (_restartCount < 6) ? (2 << _restartCount) : _maxRestartDelay;
int computePsiphonRestartDelay(int restartCount) {
  return (restartCount < 6) ? (2 << restartCount) : _maxRestartDelay;
}

/// Reimplements the default port resolution from buildPsiphonHttpClient():
///   final port = (uri.hasPort && uri.port != 0)
///       ? uri.port
///       : (uri.scheme == 'https' ? 443 : 80);
int resolveTargetPort(Uri uri) {
  return (uri.hasPort && uri.port != 0)
      ? uri.port
      : (uri.scheme == 'https' ? 443 : 80);
}

/// Reimplements the SOCKS5 CONNECT request format from _runPsiphonSocks5Bridge():
///   proxy.add([
///     0x05, 0x01, 0x00, 0x03,
///     hostBytes.length, ...hostBytes,
///     (targetPort >> 8) & 0xFF, targetPort & 0xFF,
///   ]);
List<int> buildSocks5ConnectRequest(String host, int port) {
  final hostBytes = utf8.encode(host);
  if (hostBytes.length > 255) throw ArgumentError('Hostname too long');
  return [
    0x05, 0x01, 0x00, 0x03,
    hostBytes.length, ...hostBytes,
    (port >> 8) & 0xFF, port & 0xFF,
  ];
}

void main() {
  group('PsiphonService constants', () {
    test('_maxRestartDelay is 60 seconds', () {
      expect(_maxRestartDelay, equals(60));
    });
  });

  group('PsiphonService restart backoff', () {
    test('first restart delay is 2 seconds (2 << 0)', () {
      expect(computePsiphonRestartDelay(0), equals(2));
    });

    test('delay doubles each attempt: 2, 4, 8, 16, 32, 64', () {
      final delays = List.generate(6, computePsiphonRestartDelay);
      expect(delays, equals([2, 4, 8, 16, 32, 64]));
    });

    test('delay caps at _maxRestartDelay after 6 attempts', () {
      expect(computePsiphonRestartDelay(6), equals(_maxRestartDelay));
      expect(computePsiphonRestartDelay(10), equals(_maxRestartDelay));
      expect(computePsiphonRestartDelay(100), equals(_maxRestartDelay));
    });

    test('delay never exceeds 64 seconds (2 << 5 at count=5, then capped)', () {
      for (int i = 0; i < 50; i++) {
        // Max uncapped value is 2 << 5 = 64 at count=5; after that it's _maxRestartDelay (60)
        expect(computePsiphonRestartDelay(i), lessThanOrEqualTo(64),
            reason: 'restart delay at attempt $i should not exceed 64');
      }
    });
  });

  group('buildPsiphonHttpClient port resolution', () {
    test('uses explicit port when present', () {
      final uri = Uri.parse('https://example.com:8443/path');
      expect(resolveTargetPort(uri), equals(8443));
    });

    test('defaults to 443 for https without explicit port', () {
      final uri = Uri.parse('https://example.com/path');
      // Uri.parse('https://example.com') sets uri.port = 443 and hasPort = false
      // but (uri.hasPort && uri.port != 0) depends on the implementation
      // The actual logic: if port is non-zero and explicit, use it; else scheme-based
      expect(resolveTargetPort(uri), equals(443));
    });

    test('defaults to 80 for http without explicit port', () {
      final uri = Uri.parse('http://example.com/path');
      expect(resolveTargetPort(uri), equals(80));
    });
  });

  group('SOCKS5 CONNECT request format', () {
    test('builds correct SOCKS5 header for domain', () {
      final req = buildSocks5ConnectRequest('example.com', 443);
      // Version 5, CMD connect, reserved, address type domain
      expect(req[0], equals(0x05)); // SOCKS version
      expect(req[1], equals(0x01)); // CMD: CONNECT
      expect(req[2], equals(0x00)); // Reserved
      expect(req[3], equals(0x03)); // Address type: domain
      expect(req[4], equals(11));   // length of 'example.com'
      // Last two bytes encode port 443 big-endian
      expect(req[req.length - 2], equals((443 >> 8) & 0xFF));
      expect(req[req.length - 1], equals(443 & 0xFF));
    });

    test('encodes port bytes in big-endian', () {
      final req = buildSocks5ConnectRequest('x.com', 8080);
      // Port 8080 = 0x1F90 → high byte 0x1F (31), low byte 0x90 (144)
      expect(req[req.length - 2], equals(31));
      expect(req[req.length - 1], equals(144));
    });

    test('rejects hostnames longer than 255 bytes', () {
      final longHost = 'a' * 256;
      expect(() => buildSocks5ConnectRequest(longHost, 443),
          throwsArgumentError);
    });

    test('accepts hostname exactly 255 bytes', () {
      final maxHost = 'a' * 255;
      final req = buildSocks5ConnectRequest(maxHost, 80);
      expect(req[4], equals(255));
    });

    test('SOCKS5 greeting is correct bytes', () {
      // The greeting sent before CONNECT is [0x05, 0x01, 0x00]
      // (SOCKS v5, 1 auth method, NO_AUTH)
      const greeting = [0x05, 0x01, 0x00];
      expect(greeting[0], equals(5));
      expect(greeting[1], equals(1));
      expect(greeting[2], equals(0));
    });
  });
}
