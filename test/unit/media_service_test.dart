import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/media_service.dart';

void main() {
  // Helper: build a minimal media payload JSON
  // Image bytes start with JPEG magic (FF D8 FF) so they pass magic validation.
  String makeImagePayload({String name = 'photo.jpg', int size = 1024}) {
    final bytes = Uint8List(size);
    bytes[0] = 0xFF; bytes[1] = 0xD8; bytes[2] = 0xFF; // JPEG magic
    return jsonEncode({
      't': 'img',
      'd': base64Encode(bytes),
      'n': name,
      'sz': size,
    });
  }

  // File bytes are plain zeros (PDF, etc.) — no executable magic, passes file validation.
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
      final bytes = Uint8List(10); // zeros — no executable magic, valid file
      final raw = jsonEncode({'t': 'file', 'd': base64Encode(bytes), 'sz': 10});
      final payload = MediaService.parse(raw);
      expect(payload!.name, equals('file'));
    });

    test('uses data.length as size when sz field is missing', () {
      // Provide JPEG magic so the image passes security validation.
      final bytes = Uint8List(16);
      bytes[0] = 0xFF; bytes[1] = 0xD8; bytes[2] = 0xFF;
      final raw = jsonEncode({'t': 'img', 'd': base64Encode(bytes), 'n': 'x'});
      final payload = MediaService.parse(raw);
      expect(payload!.size, equals(bytes.length)); // falls back to rawData.length
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

  group('MediaPayload.isVoice', () {
    test('returns true for type "voice"', () {
      final p = MediaPayload(type: 'voice', data: Uint8List(0), name: 'x', size: 0);
      expect(p.isVoice, isTrue);
    });

    test('returns false for type "img"', () {
      final p = MediaPayload(type: 'img', data: Uint8List(0), name: 'x', size: 0);
      expect(p.isVoice, isFalse);
    });

    test('returns false for type "file"', () {
      final p = MediaPayload(type: 'file', data: Uint8List(0), name: 'x', size: 0);
      expect(p.isVoice, isFalse);
    });
  });

  group('MediaService.isChunkPayload()', () {
    test('returns true for chunk payload', () {
      final chunk = jsonEncode({
        't': 'chunk',
        'fid': 'abc',
        'idx': 0,
        'total': 3,
        'd': base64Encode(Uint8List(10)),
        'h': 'sha256hash',
      });
      expect(MediaService.isChunkPayload(chunk), isTrue);
    });

    test('returns false for non-chunk media payload', () {
      expect(MediaService.isChunkPayload(makeFilePayload()), isFalse);
    });

    test('returns false for plain text', () {
      expect(MediaService.isChunkPayload('Hello'), isFalse);
    });

    test('returns false for empty string', () {
      expect(MediaService.isChunkPayload(''), isFalse);
    });

    test('returns false for invalid JSON', () {
      expect(MediaService.isChunkPayload('{broken'), isFalse);
    });
  });

  group('MediaService.chunkPayloads()', () {
    test('single chunk for data <= 512 KB', () {
      final data = Uint8List(1024); // 1 KB — well under 512 KB limit
      final chunks = MediaService.chunkPayloads(data, 'small.bin');
      expect(chunks.length, equals(1));
      final parsed = jsonDecode(chunks.first) as Map<String, dynamic>;
      expect(parsed['t'], equals('file'));
      expect(parsed['n'], equals('small.bin'));
      expect(parsed['sz'], equals(1024));
    });

    test('multiple chunks for data > 512 KB', () {
      // 1.5 MB => should produce 3 chunks (512KB * 3 = 1.5MB)
      final data = Uint8List(512 * 1024 + 100); // just over 512 KB
      final chunks = MediaService.chunkPayloads(data, 'big.bin');
      expect(chunks.length, equals(2)); // ceil((512*1024+100) / (512*1024)) = 2
      // First chunk should have name and size metadata
      final first = jsonDecode(chunks.first) as Map<String, dynamic>;
      expect(first['t'], equals('chunk'));
      expect(first['n'], equals('big.bin'));
      expect(first['sz'], equals(data.length));
      expect(first['mt'], equals('file'));
      expect(first['idx'], equals(0));
      expect(first['total'], equals(2));
      expect(first.containsKey('h'), isTrue); // SHA-256 hash present
      // Second chunk should NOT have name/size metadata
      final second = jsonDecode(chunks[1]) as Map<String, dynamic>;
      expect(second['t'], equals('chunk'));
      expect(second.containsKey('n'), isFalse);
      expect(second.containsKey('sz'), isFalse);
      expect(second['idx'], equals(1));
      expect(second['total'], equals(2));
    });

    test('respects custom mediaType parameter', () {
      final data = Uint8List(100);
      final chunks = MediaService.chunkPayloads(data, 'audio.wav', mediaType: 'voice');
      final parsed = jsonDecode(chunks.first) as Map<String, dynamic>;
      expect(parsed['t'], equals('voice'));
    });

    test('chunkIterable yields same number of chunks as chunkPayloads', () {
      final data = Uint8List(1024 * 1024); // 1 MB
      final chunked = MediaService.chunkPayloads(data, 'test.bin');
      final iterable = MediaService.chunkIterable(data, 'test.bin').toList();
      expect(iterable.length, equals(chunked.length));
      // Each call generates a different fileId, so compare structure not identity
      for (int i = 0; i < chunked.length; i++) {
        final a = jsonDecode(chunked[i]) as Map<String, dynamic>;
        final b = jsonDecode(iterable[i]) as Map<String, dynamic>;
        expect(b['t'], equals(a['t']));
        expect(b['d'], equals(a['d']));
        expect(b['idx'], equals(a['idx']));
        expect(b['total'], equals(a['total']));
      }
    });

    test('chunk fileIds are consistent across all chunks', () {
      final data = Uint8List(1024 * 1024 + 1); // just over 1 MB => 3 chunks
      final chunks = MediaService.chunkPayloads(data, 'multi.bin');
      expect(chunks.length, greaterThan(1));
      final fid = (jsonDecode(chunks.first) as Map<String, dynamic>)['fid'];
      expect(fid, isNotNull);
      for (final chunk in chunks) {
        final parsed = jsonDecode(chunk) as Map<String, dynamic>;
        expect(parsed['fid'], equals(fid));
      }
    });

    test('sanitizes filename in chunk payloads', () {
      final data = Uint8List(100);
      final chunks = MediaService.chunkPayloads(data, '../../../etc/passwd');
      final parsed = jsonDecode(chunks.first) as Map<String, dynamic>;
      expect(parsed['n'], isNot(contains('..')));
      expect(parsed['n'], equals('passwd'));
    });
  });

  group('MediaService.parse() — voice payload', () {
    test('parses voice payload with duration and amplitudes', () {
      // Build valid WAV magic header: RIFF....WAVE
      final wavBytes = Uint8List(64);
      // RIFF
      wavBytes[0] = 0x52; wavBytes[1] = 0x49; wavBytes[2] = 0x46; wavBytes[3] = 0x46;
      // WAVE
      wavBytes[8] = 0x57; wavBytes[9] = 0x41; wavBytes[10] = 0x56; wavBytes[11] = 0x45;

      final payload = jsonEncode({
        't': 'voice',
        'd': base64Encode(wavBytes),
        'dur': 15,
        'sz': wavBytes.length,
        'amp': [0, 25, 50, 75, 100],
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals('voice'));
      expect(parsed.isVoice, isTrue);
      expect(parsed.durationSeconds, equals(15));
      expect(parsed.amplitudes, isNotNull);
      expect(parsed.amplitudes!.length, equals(5));
      // Amplitudes are divided by 100 and clamped to [0, 1]
      expect(parsed.amplitudes![0], closeTo(0.0, 0.01));
      expect(parsed.amplitudes![2], closeTo(0.5, 0.01));
      expect(parsed.amplitudes![4], closeTo(1.0, 0.01));
    });

    test('parse returns durationSeconds=0 when dur field is missing', () {
      final wavBytes = Uint8List(64);
      wavBytes[0] = 0x52; wavBytes[1] = 0x49; wavBytes[2] = 0x46; wavBytes[3] = 0x46;
      wavBytes[8] = 0x57; wavBytes[9] = 0x41; wavBytes[10] = 0x56; wavBytes[11] = 0x45;
      final payload = jsonEncode({
        't': 'voice',
        'd': base64Encode(wavBytes),
        'sz': wavBytes.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNotNull);
      expect(parsed!.durationSeconds, equals(0));
      expect(parsed.amplitudes, isNull);
    });
  });

  group('MediaTooLargeException', () {
    test('toString returns descriptive message', () {
      expect(
        MediaTooLargeException().toString(),
        contains('100 MB'),
      );
    });
  });

  group('MediaSecurityException', () {
    test('toString includes the reason', () {
      const e = MediaSecurityException('bad magic bytes');
      expect(e.toString(), contains('bad magic bytes'));
    });

    test('reason field is preserved', () {
      const e = MediaSecurityException('executable detected');
      expect(e.reason, equals('executable detected'));
    });
  });

  // ==========================================================================
  // MediaPayload — video_note
  // ==========================================================================
  group('parse video_note', () {
    Uint8List _makeMp4({int size = 64}) {
      final b = Uint8List(size);
      b[4] = 0x66; b[5] = 0x74; b[6] = 0x79; b[7] = 0x70;
      return b;
    }

    test('parses video_note payload correctly', () {
      final mp4 = _makeMp4();
      final thumbBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x01, 0x02]);
      final payload = jsonEncode({
        't': 'video_note',
        'd': base64Encode(mp4),
        'sz': mp4.length,
        'dur': 10,
        'thumb': base64Encode(thumbBytes),
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals('video_note'));
      expect(parsed.isVideoNote, isTrue);
      expect(parsed.isGif, isFalse);
      expect(parsed.thumbnailData, isNotNull);
      expect(parsed.thumbnailData!.length, equals(thumbBytes.length));
      expect(parsed.durationSeconds, equals(10));
    });

    test('video_note without thumb field parses with null thumbnailData', () {
      final mp4 = _makeMp4();
      final payload = jsonEncode({
        't': 'video_note',
        'd': base64Encode(mp4),
        'sz': mp4.length,
        'dur': 5,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNotNull);
      expect(parsed!.isVideoNote, isTrue);
      expect(parsed.thumbnailData, isNull);
    });

    test('rejects video_note exceeding 15 MB via actual data size', () {
      // parse() estimates size from base64 length, not 'sz' field.
      // Create actual oversized base64 to trigger the size check.
      final mp4 = _makeMp4(size: 15 * 1024 * 1024 + 100);
      final payload = jsonEncode({
        't': 'video_note',
        'd': base64Encode(mp4),
        'sz': mp4.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNull);
    });

    test('rejects video_note with invalid magic bytes', () {
      final bad = Uint8List(64); // all zeros, no video magic
      final payload = jsonEncode({
        't': 'video_note',
        'd': base64Encode(bad),
        'sz': bad.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNull);
    });
  });

  // ==========================================================================
  // MediaPayload — gif
  // ==========================================================================
  group('parse gif', () {
    Uint8List _makeGif({int size = 64}) {
      final b = Uint8List(size);
      b[0] = 0x47; b[1] = 0x49; b[2] = 0x46;
      b[3] = 0x38; b[4] = 0x39; b[5] = 0x61;
      return b;
    }

    test('parses gif payload correctly', () {
      final gif = _makeGif();
      final payload = jsonEncode({
        't': 'gif',
        'd': base64Encode(gif),
        'sz': gif.length,
        'w': 320,
        'h': 240,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals('gif'));
      expect(parsed.isGif, isTrue);
      expect(parsed.isVideoNote, isFalse);
    });

    test('rejects gif exceeding 10 MB via actual data size', () {
      final gif = _makeGif(size: 10 * 1024 * 1024 + 100);
      final payload = jsonEncode({
        't': 'gif',
        'd': base64Encode(gif),
        'sz': gif.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNull);
    });

    test('rejects gif with invalid magic bytes', () {
      final bad = Uint8List(64);
      final payload = jsonEncode({
        't': 'gif',
        'd': base64Encode(bad),
        'sz': bad.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed, isNull);
    });
  });

  // ==========================================================================
  // MediaPayload — property getters
  // ==========================================================================
  group('MediaPayload properties', () {
    test('isVideoNote returns true for video_note type', () {
      final mp4 = Uint8List(64);
      mp4[4] = 0x66; mp4[5] = 0x74; mp4[6] = 0x79; mp4[7] = 0x70;
      final payload = jsonEncode({
        't': 'video_note',
        'd': base64Encode(mp4),
        'sz': mp4.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed!.isVideoNote, isTrue);
      expect(parsed.isGif, isFalse);
      expect(parsed.isVoice, isFalse);
    });

    test('isGif returns true for gif type', () {
      final gif = Uint8List(64);
      gif[0] = 0x47; gif[1] = 0x49; gif[2] = 0x46;
      gif[3] = 0x38; gif[4] = 0x39; gif[5] = 0x61;
      final payload = jsonEncode({
        't': 'gif',
        'd': base64Encode(gif),
        'sz': gif.length,
      });
      final parsed = MediaService.parse(payload);
      expect(parsed!.isGif, isTrue);
      expect(parsed.isVideoNote, isFalse);
    });
  });
}
