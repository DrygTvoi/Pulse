import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/media_service.dart';

void main() {
  // Helper: build a minimal media payload JSON
  String makeImagePayload({String name = 'photo.jpg', int size = 1024}) {
    final bytes = Uint8List(size);
    return jsonEncode({
      't': 'img',
      'd': base64Encode(bytes),
      'n': name,
      'sz': size,
    });
  }

  String makeFilePayload({String name = 'doc.pdf', int size = 2048}) {
    final bytes = Uint8List(size);
    return jsonEncode({
      't': 'file',
      'd': base64Encode(bytes),
      'n': name,
      'sz': size,
    });
  }

  group('MediaService.isMediaPayload()', () {
    test('returns false for plain text', () {
      expect(MediaService.isMediaPayload('Hello, world!'), isFalse);
    });

    test('returns false for empty string', () {
      expect(MediaService.isMediaPayload(''), isFalse);
    });

    test('returns false for non-media JSON (no t/d keys)', () {
      expect(MediaService.isMediaPayload('{"foo":"bar"}'), isFalse);
    });

    test('returns true for image payload', () {
      expect(MediaService.isMediaPayload(makeImagePayload()), isTrue);
    });

    test('returns true for file payload', () {
      expect(MediaService.isMediaPayload(makeFilePayload()), isTrue);
    });

    test('returns false for invalid JSON starting with {', () {
      expect(MediaService.isMediaPayload('{not valid json}'), isFalse);
    });

    test('returns false for Signal envelope string', () {
      expect(
        MediaService.isMediaPayload('E2EE||3||abc123=='),
        isFalse,
      );
    });
  });

  group('MediaService.parse()', () {
    test('returns null for plain text', () {
      expect(MediaService.parse('Hello'), isNull);
    });

    test('parses image payload correctly', () {
      final raw = makeImagePayload(name: 'cat.jpg', size: 512);
      final payload = MediaService.parse(raw);
      expect(payload, isNotNull);
      expect(payload!.type, equals('img'));
      expect(payload.name, equals('cat.jpg'));
      expect(payload.size, equals(512));
      expect(payload.data.length, equals(512));
      expect(payload.isImage, isTrue);
    });

    test('parses file payload correctly', () {
      final raw = makeFilePayload(name: 'report.pdf', size: 4096);
      final payload = MediaService.parse(raw);
      expect(payload, isNotNull);
      expect(payload!.type, equals('file'));
      expect(payload.name, equals('report.pdf'));
      expect(payload.size, equals(4096));
      expect(payload.isImage, isFalse);
    });

    test('uses "file" as default name when missing', () {
      final bytes = Uint8List(10);
      final raw = jsonEncode({'t': 'file', 'd': base64Encode(bytes), 'sz': 10});
      final payload = MediaService.parse(raw);
      expect(payload!.name, equals('file'));
    });

    test('uses 0 as default size when missing', () {
      final bytes = Uint8List(5);
      final raw = jsonEncode({'t': 'img', 'd': base64Encode(bytes), 'n': 'x'});
      final payload = MediaService.parse(raw);
      expect(payload!.size, equals(0));
    });

    test('returns null for corrupted base64 data', () {
      final raw = jsonEncode({'t': 'img', 'd': '!!!invalid_base64!!!', 'n': 'x', 'sz': 0});
      expect(MediaService.parse(raw), isNull);
    });
  });

  group('MediaPayload.sizeLabel', () {
    MediaPayload payload(int size) => MediaPayload(
          type: 'file',
          data: Uint8List(0),
          name: 'x',
          size: size,
        );

    test('shows bytes for size < 1024', () {
      expect(payload(512).sizeLabel, equals('512B'));
      expect(payload(0).sizeLabel, equals('0B'));
      expect(payload(1023).sizeLabel, equals('1023B'));
    });

    test('shows KB for 1024 ≤ size < 1MB', () {
      expect(payload(1024).sizeLabel, equals('1.0KB'));
      expect(payload(1536).sizeLabel, equals('1.5KB'));
      expect(payload(10 * 1024).sizeLabel, equals('10.0KB'));
    });

    test('shows MB for size ≥ 1MB', () {
      expect(payload(1024 * 1024).sizeLabel, equals('1.0MB'));
      expect(payload((1.5 * 1024 * 1024).round()).sizeLabel, equals('1.5MB'));
    });
  });

  group('MediaPayload.isImage', () {
    test('returns true for type "img"', () {
      final p = MediaPayload(type: 'img', data: Uint8List(0), name: 'x', size: 0);
      expect(p.isImage, isTrue);
    });

    test('returns false for type "file"', () {
      final p = MediaPayload(type: 'file', data: Uint8List(0), name: 'x', size: 0);
      expect(p.isImage, isFalse);
    });
  });

  group('MediaTooLargeException', () {
    test('toString returns descriptive message', () {
      expect(
        MediaTooLargeException().toString(),
        contains('2 MB'),
      );
    });
  });
}
