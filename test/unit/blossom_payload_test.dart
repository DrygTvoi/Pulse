import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/media_service.dart';

void main() {
  group('BlossomPayload', () {
    test('buildBlossomPayload produces valid JSON', () {
      final payload = BlossomPayloadHelpers.buildBlossomPayload(
        hash: 'abc123',
        server: 'https://blossom.primal.net',
        key: 'a2V5',
        iv: 'aXY=',
        name: 'photo.jpg',
        size: 12345,
        mediaType: 'img',
      );
      final map = jsonDecode(payload) as Map<String, dynamic>;
      expect(map['t'], 'blossom');
      expect(map['h'], 'abc123');
      expect(map['s'], 'https://blossom.primal.net');
      expect(map['k'], 'a2V5');
      expect(map['iv'], 'aXY=');
      expect(map['n'], 'photo.jpg');
      expect(map['sz'], 12345);
      expect(map['mt'], 'img');
      expect(map.containsKey('thumb'), false);
    });

    test('buildBlossomPayload includes thumbnail when provided', () {
      final payload = BlossomPayloadHelpers.buildBlossomPayload(
        hash: 'h1',
        server: 'https://s.com',
        key: 'k',
        iv: 'v',
        name: 'f.jpg',
        size: 100,
        mediaType: 'img',
        thumbnail: 'base64thumb',
      );
      final map = jsonDecode(payload) as Map<String, dynamic>;
      expect(map['thumb'], 'base64thumb');
    });

    test('isBlossomPayload returns true for valid payload', () {
      final payload = '{"t":"blossom","h":"abc","s":"https://x.com","k":"k","iv":"v","n":"f","sz":1,"mt":"img"}';
      expect(BlossomPayloadHelpers.isBlossomPayload(payload), true);
    });

    test('isBlossomPayload returns false for non-blossom', () {
      expect(BlossomPayloadHelpers.isBlossomPayload('{"t":"img","d":"abc"}'), false);
      expect(BlossomPayloadHelpers.isBlossomPayload('hello world'), false);
      expect(BlossomPayloadHelpers.isBlossomPayload(''), false);
      expect(BlossomPayloadHelpers.isBlossomPayload('not json'), false);
    });

    test('isBlossomPayload returns false for missing required fields', () {
      expect(BlossomPayloadHelpers.isBlossomPayload('{"t":"blossom"}'), false);
      expect(BlossomPayloadHelpers.isBlossomPayload('{"t":"blossom","h":"abc"}'), false);
    });

    test('parseBlossomPayload roundtrip', () {
      final payload = BlossomPayloadHelpers.buildBlossomPayload(
        hash: 'deadbeef',
        server: 'https://cdn.hzrd149.com',
        key: 'key123',
        iv: 'iv456',
        name: 'document.pdf',
        size: 999999,
        mediaType: 'file',
        thumbnail: 'thumbdata',
      );

      final parsed = BlossomPayloadHelpers.parseBlossomPayload(payload);
      expect(parsed, isNotNull);
      expect(parsed!.hash, 'deadbeef');
      expect(parsed.server, 'https://cdn.hzrd149.com');
      expect(parsed.key, 'key123');
      expect(parsed.iv, 'iv456');
      expect(parsed.name, 'document.pdf');
      expect(parsed.size, 999999);
      expect(parsed.mediaType, 'file');
      expect(parsed.thumbnail, 'thumbdata');
    });

    test('parseBlossomPayload returns null for invalid payload', () {
      expect(BlossomPayloadHelpers.parseBlossomPayload('hello'), null);
      expect(BlossomPayloadHelpers.parseBlossomPayload('{"t":"img"}'), null);
    });

    test('parseBlossomPayload returns null when key fields are missing', () {
      final payload = '{"t":"blossom","h":"hash","s":"https://x.com"}';
      final parsed = BlossomPayloadHelpers.parseBlossomPayload(payload);
      expect(parsed, null);
    });

    test('BlossomPayload.sizeLabel formats correctly', () {
      final p1 = BlossomPayload(hash: '', server: '', key: '', iv: '', name: '', size: 500, mediaType: '');
      expect(p1.sizeLabel, '500B');

      final p2 = BlossomPayload(hash: '', server: '', key: '', iv: '', name: '', size: 5120, mediaType: '');
      expect(p2.sizeLabel, '5.0KB');

      final p3 = BlossomPayload(hash: '', server: '', key: '', iv: '', name: '', size: 5242880, mediaType: '');
      expect(p3.sizeLabel, '5.0MB');
    });

    test('buildBlossomPayload sanitizes filename', () {
      final payload = BlossomPayloadHelpers.buildBlossomPayload(
        hash: 'h',
        server: 'https://s.com',
        key: 'k',
        iv: 'v',
        name: '../../../etc/passwd',
        size: 1,
        mediaType: 'file',
      );
      final map = jsonDecode(payload) as Map<String, dynamic>;
      // MediaValidator.sanitizeFilename strips path traversal
      expect(map['n'], isNot(contains('..')));
    });

    test('isBlossomPayload rejects oversized strings', () {
      // 500KB+ string should be rejected before JSON parse
      final huge = '{"t":"blossom","h":"abc","s":"https://x.com",${'x' * 600000}}';
      expect(BlossomPayloadHelpers.isBlossomPayload(huge), false);
    });
  });
}
