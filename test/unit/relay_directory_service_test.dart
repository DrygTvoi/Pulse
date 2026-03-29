import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/relay_directory_service.dart';

void main() {
  late RelayDirectoryService service;

  setUp(() {
    service = RelayDirectoryService.forTesting();
  });

  // ── parseApiResponse ─────────────────────────────────────────────────────────

  group('parseApiResponse', () {
    test('parses nostr.watch array format (list of URL strings)', () {
      final body = jsonEncode([
        'wss://relay.damus.io',
        'wss://nos.lol',
        'wss://relay.snort.social',
      ]);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(3));
      expect(result, contains('wss://relay.damus.io'));
      expect(result, contains('wss://nos.lol'));
      expect(result, contains('wss://relay.snort.social'));
    });

    test('parses nostr.band object format with "relays" key', () {
      final body = jsonEncode({
        'relays': ['wss://relay.damus.io', 'wss://nos.lol'],
      });
      final result = service.parseApiResponse(body);
      expect(result, hasLength(2));
      expect(result, contains('wss://relay.damus.io'));
    });

    test('parses object format with "data" key', () {
      final body = jsonEncode({
        'data': ['wss://relay.damus.io'],
      });
      final result = service.parseApiResponse(body);
      expect(result, hasLength(1));
    });

    test('parses list of objects with "url" field', () {
      final body = jsonEncode([
        {'url': 'wss://relay.damus.io', 'uptime': 99},
        {'url': 'wss://nos.lol', 'uptime': 95},
      ]);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(2));
      expect(result, contains('wss://relay.damus.io'));
    });

    test('filters out non-WebSocket URLs', () {
      final body = jsonEncode([
        'wss://relay.damus.io',
        'https://example.com',  // not wss
        'http://plain.com',     // not wss
        'ws://insecure-relay.com', // cleartext ws:// rejected
      ]);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(1)); // only wss:// allowed
      expect(result, contains('wss://relay.damus.io'));
    });

    test('skips empty URLs', () {
      final body = jsonEncode(['', 'wss://relay.damus.io', '']);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(1));
    });

    test('skips URLs with empty host', () {
      final body = jsonEncode(['wss://', 'wss://relay.damus.io']);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(1));
    });

    test('skips unparseable URLs', () {
      final body = jsonEncode([
        'wss://relay.damus.io',
        ':::not-a-url:::', // Uri.tryParse returns non-null but host is empty
      ]);
      final result = service.parseApiResponse(body);
      // Only the valid wss URL should be included
      expect(result.every((u) => u.startsWith('ws')), isTrue);
    });

    test('returns empty list for invalid JSON', () {
      final result = service.parseApiResponse('not json at all');
      expect(result, isEmpty);
    });

    test('returns empty list for unexpected JSON type (number)', () {
      final result = service.parseApiResponse('42');
      expect(result, isEmpty);
    });

    test('returns empty list for null-ish JSON', () {
      final result = service.parseApiResponse('null');
      expect(result, isEmpty);
    });

    test('returns empty list for empty array', () {
      final result = service.parseApiResponse('[]');
      expect(result, isEmpty);
    });

    test('returns empty list for empty object', () {
      final result = service.parseApiResponse('{}');
      expect(result, isEmpty);
    });

    test('handles mixed list items (strings, objects, numbers)', () {
      final body = jsonEncode([
        'wss://relay.damus.io',
        {'url': 'wss://nos.lol'},
        42,           // number — ignored
        true,         // bool — ignored
        null,         // null — ignored
      ]);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(2));
    });

    test('preserves wss:// URL with path', () {
      final body = jsonEncode(['wss://relay.damus.io/path']);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(1));
      expect(result.first, equals('wss://relay.damus.io/path'));
    });

    test('preserves wss:// URL with port', () {
      final body = jsonEncode(['wss://relay.example.com:8080']);
      final result = service.parseApiResponse(body);
      expect(result, hasLength(1));
      expect(result.first, equals('wss://relay.example.com:8080'));
    });
  });

  // ── urlsToCandidates ─────────────────────────────────────────────────────────

  group('urlsToCandidates', () {
    test('extracts host and default port 443 for wss:// without port', () {
      final candidates = service.urlsToCandidates(['wss://relay.damus.io']);
      expect(candidates, hasLength(1));
      expect(candidates.first.$1, equals('relay.damus.io'));
      expect(candidates.first.$2, equals(443));
    });

    test('extracts explicit port when present', () {
      final candidates =
          service.urlsToCandidates(['wss://relay.example.com:8080']);
      expect(candidates, hasLength(1));
      expect(candidates.first.$1, equals('relay.example.com'));
      expect(candidates.first.$2, equals(8080));
    });

    test('skips invalid and empty URLs', () {
      final candidates = service.urlsToCandidates([
        'wss://relay.damus.io',
        ':::bad:::',
        '',
      ]);
      // Only the valid wss URL should produce a candidate
      expect(candidates, hasLength(1));
      expect(candidates.first.$1, equals('relay.damus.io'));
    });

    test('handles empty input list', () {
      final candidates = service.urlsToCandidates([]);
      expect(candidates, isEmpty);
    });

    test('handles ws:// scheme without explicit port (defaults to 443)', () {
      // ws:// without explicit port: Uri.hasPort = false → code defaults to 443
      final candidates = service.urlsToCandidates(['ws://relay.example.com']);
      expect(candidates, hasLength(1));
      expect(candidates.first.$1, equals('relay.example.com'));
      expect(candidates.first.$2, equals(443));
    });

    test('multiple URLs produce multiple candidates', () {
      final candidates = service.urlsToCandidates([
        'wss://relay.damus.io',
        'wss://nos.lol',
        'wss://relay.snort.social:443',
      ]);
      expect(candidates, hasLength(3));
    });
  });
}
