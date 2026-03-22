import 'package:flutter_test/flutter_test.dart';

/// Reimplements testable constants and logic from UTLSService
/// (lib/services/utls_service.dart) without platform dependencies.

// Constants extracted from source
const _maxRestartDelay = 30; // seconds

/// Reimplements the exponential backoff delay calculation from UTLSService._start():
///   final delay = (_restartCount < 5) ? (1 << _restartCount) : _maxRestartDelay;
int computeRestartDelay(int restartCount) {
  return (restartCount < 5) ? (1 << restartCount) : _maxRestartDelay;
}

/// Reimplements the findProxy string format from UTLSService.buildHttpClient():
///   client.findProxy = (_) => 'PROXY 127.0.0.1:$_port';
String formatProxyString(int port) => 'PROXY 127.0.0.1:$port';

void main() {
  group('UTLSService constants', () {
    test('_maxRestartDelay is 30 seconds', () {
      expect(_maxRestartDelay, equals(30));
    });
  });

  group('UTLSService restart backoff', () {
    test('first restart delay is 1 second (2^0)', () {
      expect(computeRestartDelay(0), equals(1));
    });

    test('second restart delay is 2 seconds (2^1)', () {
      expect(computeRestartDelay(1), equals(2));
    });

    test('delay doubles each attempt: 1, 2, 4, 8, 16', () {
      final delays = List.generate(5, computeRestartDelay);
      expect(delays, equals([1, 2, 4, 8, 16]));
    });

    test('delay caps at _maxRestartDelay after 5 attempts', () {
      expect(computeRestartDelay(5), equals(_maxRestartDelay));
      expect(computeRestartDelay(10), equals(_maxRestartDelay));
      expect(computeRestartDelay(100), equals(_maxRestartDelay));
    });

    test('delay never exceeds _maxRestartDelay', () {
      for (int i = 0; i < 50; i++) {
        expect(computeRestartDelay(i), lessThanOrEqualTo(_maxRestartDelay),
            reason: 'restart delay at attempt $i should not exceed max');
      }
    });
  });

  group('UTLSService proxy string format', () {
    test('formats PROXY directive with loopback and port', () {
      expect(formatProxyString(8080), equals('PROXY 127.0.0.1:8080'));
    });

    test('formats correctly for various port numbers', () {
      expect(formatProxyString(0), equals('PROXY 127.0.0.1:0'));
      expect(formatProxyString(1080), equals('PROXY 127.0.0.1:1080'));
      expect(formatProxyString(65535), equals('PROXY 127.0.0.1:65535'));
    });

    test('always starts with PROXY keyword', () {
      expect(formatProxyString(9999), startsWith('PROXY '));
    });

    test('always uses IPv4 loopback 127.0.0.1', () {
      expect(formatProxyString(3000), contains('127.0.0.1'));
    });
  });
}
