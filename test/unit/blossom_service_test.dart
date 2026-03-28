import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/blossom_service.dart';

void main() {
  group('BlossomService', () {
    group('isValidServerUrl', () {
      test('accepts valid https URLs', () {
        expect(BlossomService.isValidServerUrl('https://blossom.primal.net'), true);
        expect(BlossomService.isValidServerUrl('https://cdn.hzrd149.com'), true);
        expect(BlossomService.isValidServerUrl('https://example.com:8080'), true);
      });

      test('rejects non-https URLs', () {
        expect(BlossomService.isValidServerUrl('http://example.com'), false);
        expect(BlossomService.isValidServerUrl('ws://example.com'), false);
        expect(BlossomService.isValidServerUrl('ftp://example.com'), false);
      });

      test('rejects localhost', () {
        expect(BlossomService.isValidServerUrl('https://localhost'), false);
        expect(BlossomService.isValidServerUrl('https://127.0.0.1'), false);
        expect(BlossomService.isValidServerUrl('https://::1'), false);
        expect(BlossomService.isValidServerUrl('https://0.0.0.0'), false);
      });

      test('rejects private IP ranges', () {
        expect(BlossomService.isValidServerUrl('https://10.0.0.1'), false);
        expect(BlossomService.isValidServerUrl('https://192.168.1.1'), false);
        expect(BlossomService.isValidServerUrl('https://172.16.0.1'), false);
        expect(BlossomService.isValidServerUrl('https://172.31.255.255'), false);
        expect(BlossomService.isValidServerUrl('https://169.254.0.1'), false);
      });

      test('accepts non-private 172.x addresses', () {
        expect(BlossomService.isValidServerUrl('https://172.15.0.1'), true);
        expect(BlossomService.isValidServerUrl('https://172.32.0.1'), true);
      });

      test('rejects empty/invalid URLs', () {
        expect(BlossomService.isValidServerUrl(''), false);
        expect(BlossomService.isValidServerUrl('https://'), false);
        expect(BlossomService.isValidServerUrl('not-a-url'), false);
      });
    });

    test('isAvailable returns true (default servers)', () {
      expect(BlossomService.instance.isAvailable, true);
    });

    test('servers list is not empty', () {
      expect(BlossomService.instance.servers, isNotEmpty);
      expect(BlossomService.instance.servers, contains('https://blossom.primal.net'));
    });
  });
}
