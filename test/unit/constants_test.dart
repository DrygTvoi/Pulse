import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/constants.dart';

void main() {
  group('kDefaultNostrRelay', () {
    test('is a non-empty string', () {
      expect(kDefaultNostrRelay, isNotEmpty);
    });

    test('starts with wss://', () {
      expect(kDefaultNostrRelay, startsWith('wss://'));
    });

    test('is a valid WebSocket URL format', () {
      final uri = Uri.tryParse(kDefaultNostrRelay);
      expect(uri, isNotNull, reason: 'should be a parseable URI');
      expect(uri!.scheme, equals('wss'),
          reason: 'scheme should be wss for secure WebSocket');
      expect(uri.host, isNotEmpty, reason: 'host should not be empty');
      // Should not contain spaces or other illegal characters
      expect(kDefaultNostrRelay, isNot(contains(' ')),
          reason: 'URL should not contain spaces');
    });
  });
}
