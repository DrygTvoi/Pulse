import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/media_validator.dart';

/// Helper: build a minimal valid PNG header with specific dimensions.
/// PNG layout: 8-byte signature, then IHDR chunk (length 4 + "IHDR" 4 + data 13 + CRC 4).
/// Width at offset 16, height at offset 20 (big-endian uint32).
Uint8List _makePng({int width = 100, int height = 100}) {
  final b = Uint8List(32);
  // PNG signature
  b[0] = 0x89;
  b[1] = 0x50;
  b[2] = 0x4E;
  b[3] = 0x47;
  b[4] = 0x0D;
  b[5] = 0x0A;
  b[6] = 0x1A;
  b[7] = 0x0A;
  // IHDR chunk length (13 bytes)
  b[8] = 0x00;
  b[9] = 0x00;
  b[10] = 0x00;
  b[11] = 0x0D;
  // "IHDR"
  b[12] = 0x49;
  b[13] = 0x48;
  b[14] = 0x44;
  b[15] = 0x52;
  // Width (big-endian uint32) at offset 16
  b[16] = (width >> 24) & 0xFF;
  b[17] = (width >> 16) & 0xFF;
  b[18] = (width >> 8) & 0xFF;
  b[19] = width & 0xFF;
  // Height (big-endian uint32) at offset 20
  b[20] = (height >> 24) & 0xFF;
  b[21] = (height >> 16) & 0xFF;
  b[22] = (height >> 8) & 0xFF;
  b[23] = height & 0xFF;
  return b;
}

/// Helper: build a minimal JPEG with SOF0 marker encoding dimensions.
/// JPEG: FF D8 FF [E0 or other APP markers] ... FF C0 len precision height width
Uint8List _makeJpeg({int width = 100, int height = 100}) {
  final b = Uint8List(32);
  // SOI marker
  b[0] = 0xFF;
  b[1] = 0xD8;
  // SOF0 marker at offset 2
  b[2] = 0xFF;
  b[3] = 0xC0;
  // Segment length (big-endian)
  b[4] = 0x00;
  b[5] = 0x11; // 17 bytes
  // Precision
  b[6] = 0x08;
  // Height at offset 7 (big-endian uint16)
  b[7] = (height >> 8) & 0xFF;
  b[8] = height & 0xFF;
  // Width at offset 9 (big-endian uint16)
  b[9] = (width >> 8) & 0xFF;
  b[10] = width & 0xFF;
  return b;
}

/// Helper: build a minimal valid WAV header (RIFF....WAVE).
Uint8List _makeWav({int extraBytes = 32}) {
  final b = Uint8List(12 + extraBytes);
  // "RIFF"
  b[0] = 0x52;
  b[1] = 0x49;
  b[2] = 0x46;
  b[3] = 0x46;
  // File size (ignored by validator)
  b[4] = 0x00;
  b[5] = 0x00;
  b[6] = 0x00;
  b[7] = 0x00;
  // "WAVE"
  b[8] = 0x57;
  b[9] = 0x41;
  b[10] = 0x56;
  b[11] = 0x45;
  return b;
}

void main() {
  // ==========================================================================
  // validateImage
  // ==========================================================================
  group('validateImage', () {
    test('accepts valid JPEG magic bytes', () {
      // FF D8 FF followed by enough padding for the header check
      final bytes = Uint8List(32);
      bytes[0] = 0xFF;
      bytes[1] = 0xD8;
      bytes[2] = 0xFF;
      bytes[3] = 0xE0;
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
      expect(result.reason, isNull);
    });

    test('accepts valid PNG magic bytes', () {
      final bytes = _makePng();
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('accepts valid GIF magic bytes', () {
      // GIF89a signature
      final bytes = Uint8List(32);
      bytes[0] = 0x47; // G
      bytes[1] = 0x49; // I
      bytes[2] = 0x46; // F
      bytes[3] = 0x38; // 8
      bytes[4] = 0x39; // 9
      bytes[5] = 0x61; // a
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('accepts valid WebP magic bytes', () {
      // RIFF....WEBP
      final bytes = Uint8List(32);
      bytes[0] = 0x52; // R
      bytes[1] = 0x49; // I
      bytes[2] = 0x46; // F
      bytes[3] = 0x46; // F
      // bytes 4-7: file size (irrelevant)
      bytes[8] = 0x57;  // W
      bytes[9] = 0x45;  // E
      bytes[10] = 0x42; // B
      bytes[11] = 0x50; // P
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('accepts valid BMP magic bytes', () {
      final bytes = Uint8List(32);
      bytes[0] = 0x42; // B
      bytes[1] = 0x4D; // M
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('rejects unknown magic bytes', () {
      final bytes = Uint8List(32);
      bytes[0] = 0x00;
      bytes[1] = 0x01;
      bytes[2] = 0x02;
      bytes[3] = 0x03;
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('not a recognised image format'));
    });

    test('rejects data shorter than 4 bytes', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8]);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('not a recognised image format'));
    });

    test('rejects empty data', () {
      final bytes = Uint8List(0);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
    });

    test('rejects image exceeding maxImageBytes', () {
      // Create data just over 20 MB
      final size = MediaValidator.maxImageBytes + 1;
      final bytes = Uint8List(size);
      // Give it valid PNG magic so we isolate the size check
      bytes[0] = 0x89;
      bytes[1] = 0x50;
      bytes[2] = 0x4E;
      bytes[3] = 0x47;
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('MB limit'));
    });

    test('rejects PNG with oversized width', () {
      final bytes = _makePng(width: 5000, height: 100);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('exceed'));
      expect(result.reason, contains('px limit'));
    });

    test('rejects PNG with oversized height', () {
      final bytes = _makePng(width: 100, height: 5000);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('exceed'));
    });

    test('rejects PNG with both dimensions oversized', () {
      final bytes = _makePng(width: 8000, height: 8000);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
    });

    test('accepts PNG exactly at maxImageDimension', () {
      final bytes = _makePng(width: 4096, height: 4096);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('rejects PNG one pixel over maxImageDimension', () {
      final bytes = _makePng(width: 4097, height: 100);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
    });

    test('rejects JPEG with oversized dimensions via SOF0', () {
      final bytes = _makeJpeg(width: 5000, height: 5000);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('exceed'));
    });

    test('accepts JPEG with dimensions within limit', () {
      final bytes = _makeJpeg(width: 1920, height: 1080);
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('JPEG with SOF2 (progressive) is dimension-checked', () {
      final bytes = _makeJpeg(width: 5000, height: 5000);
      // Change SOF0 (C0) to SOF2 (C2) — progressive JPEG
      bytes[3] = 0xC2;
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isFalse);
    });

    test('JPEG without SOF marker skips dimension check (accepted)', () {
      // JPEG with only APP0 marker, no SOF — dimension reader returns null
      final bytes = Uint8List(32);
      bytes[0] = 0xFF;
      bytes[1] = 0xD8;
      bytes[2] = 0xFF;
      bytes[3] = 0xE0; // APP0
      bytes[4] = 0x00;
      bytes[5] = 0x10; // segment length 16
      // No SOF marker follows — _readJpegDimensions returns null
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });

    test('GIF does not get dimension-checked (accepted regardless of size)', () {
      // GIF magic, dimension reader returns null for GIF
      final bytes = Uint8List(32);
      bytes[0] = 0x47;
      bytes[1] = 0x49;
      bytes[2] = 0x46;
      bytes[3] = 0x38;
      final result = MediaValidator.validateImage(bytes);
      expect(result.isValid, isTrue);
    });
  });

  // ==========================================================================
  // validateAudio
  // ==========================================================================
  group('validateAudio', () {
    test('accepts valid WAV magic bytes', () {
      final bytes = _makeWav();
      final result = MediaValidator.validateAudio(bytes);
      expect(result.isValid, isTrue);
    });

    test('rejects non-WAV data', () {
      final bytes = Uint8List(32);
      final result = MediaValidator.validateAudio(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('not a valid WAV'));
    });

    test('rejects data shorter than 12 bytes', () {
      final bytes = Uint8List(8);
      // Partial RIFF header
      bytes[0] = 0x52;
      bytes[1] = 0x49;
      bytes[2] = 0x46;
      bytes[3] = 0x46;
      final result = MediaValidator.validateAudio(bytes);
      expect(result.isValid, isFalse);
    });

    test('rejects RIFF without WAVE subtype', () {
      final bytes = Uint8List(32);
      // RIFF header
      bytes[0] = 0x52;
      bytes[1] = 0x49;
      bytes[2] = 0x46;
      bytes[3] = 0x46;
      // AVI instead of WAVE
      bytes[8] = 0x41; // A
      bytes[9] = 0x56; // V
      bytes[10] = 0x49; // I
      bytes[11] = 0x20; // space
      final result = MediaValidator.validateAudio(bytes);
      expect(result.isValid, isFalse);
    });

    test('rejects audio exceeding maxVoiceBytes', () {
      final size = MediaValidator.maxVoiceBytes + 1;
      final bytes = Uint8List(size);
      // Valid WAV header
      bytes[0] = 0x52;
      bytes[1] = 0x49;
      bytes[2] = 0x46;
      bytes[3] = 0x46;
      bytes[8] = 0x57;
      bytes[9] = 0x41;
      bytes[10] = 0x56;
      bytes[11] = 0x45;
      final result = MediaValidator.validateAudio(bytes);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('MB limit'));
    });

    test('accepts WAV exactly at maxVoiceBytes', () {
      final bytes = Uint8List(MediaValidator.maxVoiceBytes);
      bytes[0] = 0x52;
      bytes[1] = 0x49;
      bytes[2] = 0x46;
      bytes[3] = 0x46;
      bytes[8] = 0x57;
      bytes[9] = 0x41;
      bytes[10] = 0x56;
      bytes[11] = 0x45;
      final result = MediaValidator.validateAudio(bytes);
      expect(result.isValid, isTrue);
    });
  });

  // ==========================================================================
  // validateFile
  // ==========================================================================
  group('validateFile', () {
    test('accepts a normal file with safe content', () {
      final bytes = Uint8List.fromList([0x50, 0x44, 0x46, 0x2D]); // "PDF-"
      final result = MediaValidator.validateFile(bytes, 'document.pdf');
      expect(result.isValid, isTrue);
    });

    test('rejects ELF executable (Linux binary)', () {
      // 7F 45 4C 46
      final bytes = Uint8List.fromList([0x7F, 0x45, 0x4C, 0x46, 0x00, 0x00]);
      final result = MediaValidator.validateFile(bytes, 'program');
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Executable'));
    });

    test('rejects PE/MZ executable (Windows binary)', () {
      // 4D 5A (MZ)
      final bytes = Uint8List.fromList([0x4D, 0x5A, 0x90, 0x00, 0x03, 0x00]);
      final result = MediaValidator.validateFile(bytes, 'program.exe');
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Executable'));
    });

    test('rejects 32-bit Mach-O executable', () {
      // CE FA ED FE
      final bytes = Uint8List.fromList([0xCE, 0xFA, 0xED, 0xFE, 0x00, 0x00]);
      final result = MediaValidator.validateFile(bytes, 'app');
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Executable'));
    });

    test('rejects 64-bit Mach-O executable', () {
      // CF FA ED FE
      final bytes = Uint8List.fromList([0xCF, 0xFA, 0xED, 0xFE, 0x00, 0x00]);
      final result = MediaValidator.validateFile(bytes, 'app');
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Executable'));
    });

    test('rejects shell script (#!)', () {
      // 23 21 = "#!"
      final bytes = Uint8List.fromList([0x23, 0x21, 0x2F, 0x62, 0x69, 0x6E]); // #!/bin
      final result = MediaValidator.validateFile(bytes, 'script.sh');
      expect(result.isValid, isFalse);
      expect(result.reason, contains('Executable'));
    });

    test('rejects file exceeding maxFileBytes', () {
      final size = MediaValidator.maxFileBytes + 1;
      final bytes = Uint8List(size);
      final result = MediaValidator.validateFile(bytes, 'huge.bin');
      expect(result.isValid, isFalse);
      expect(result.reason, contains('MB limit'));
    });

    test('accepts file exactly at maxFileBytes', () {
      final bytes = Uint8List(MediaValidator.maxFileBytes);
      final result = MediaValidator.validateFile(bytes, 'big.bin');
      expect(result.isValid, isTrue);
    });

    test('does not reject file with only 3 bytes (too short for magic check)', () {
      // _isExecutable returns false for < 4 bytes
      final bytes = Uint8List.fromList([0x7F, 0x45, 0x4C]);
      final result = MediaValidator.validateFile(bytes, 'short');
      expect(result.isValid, isTrue);
    });
  });

  // ==========================================================================
  // sanitizeFilename
  // ==========================================================================
  group('sanitizeFilename', () {
    test('passes through a normal filename unchanged', () {
      expect(MediaValidator.sanitizeFilename('photo.jpg'), equals('photo.jpg'));
    });

    test('strips path traversal with ../', () {
      expect(
        MediaValidator.sanitizeFilename('../../etc/passwd'),
        equals('passwd'),
      );
    });

    test('strips absolute Unix path', () {
      expect(
        MediaValidator.sanitizeFilename('/etc/shadow'),
        equals('shadow'),
      );
    });

    test('strips Windows backslash path', () {
      expect(
        MediaValidator.sanitizeFilename('C:\\Users\\admin\\evil.exe'),
        equals('evil.exe'),
      );
    });

    test('removes null bytes', () {
      expect(
        MediaValidator.sanitizeFilename('file\x00name.txt'),
        equals('filename.txt'),
      );
    });

    test('removes leading dots (hidden files)', () {
      expect(
        MediaValidator.sanitizeFilename('.hidden'),
        equals('hidden'),
      );
    });

    test('removes multiple leading dots', () {
      expect(
        MediaValidator.sanitizeFilename('...bashrc'),
        equals('bashrc'),
      );
    });

    test('truncates names longer than 255 characters', () {
      final longName = 'a' * 300;
      final result = MediaValidator.sanitizeFilename(longName);
      expect(result.length, equals(255));
    });

    test('returns "file" for empty string', () {
      expect(MediaValidator.sanitizeFilename(''), equals('file'));
    });

    test('returns "file" for string that becomes empty after sanitization', () {
      // Only dots and path separators
      expect(MediaValidator.sanitizeFilename('/...'), equals('file'));
    });

    test('returns "file" for only null bytes', () {
      expect(MediaValidator.sanitizeFilename('\x00\x00'), equals('file'));
    });

    test('handles combined path traversal + null bytes + dots', () {
      expect(
        MediaValidator.sanitizeFilename('../\x00.secret'),
        equals('secret'),
      );
    });

    test('preserves extensions after sanitization', () {
      expect(
        MediaValidator.sanitizeFilename('path/to/document.pdf'),
        equals('document.pdf'),
      );
    });
  });

  // ==========================================================================
  // validateJsonPayload
  // ==========================================================================
  group('validateJsonPayload', () {
    test('accepts valid small JSON', () {
      final result = MediaValidator.validateJsonPayload('{"key": "value"}');
      expect(result.isValid, isTrue);
    });

    test('accepts empty JSON object', () {
      final result = MediaValidator.validateJsonPayload('{}');
      expect(result.isValid, isTrue);
    });

    test('accepts empty JSON array', () {
      final result = MediaValidator.validateJsonPayload('[]');
      expect(result.isValid, isTrue);
    });

    test('accepts JSON at exactly maxJsonDepth nesting', () {
      // Build JSON with exactly 8 levels of nesting
      var json = '"leaf"';
      for (var i = 0; i < MediaValidator.maxJsonDepth; i++) {
        json = '{"d": $json}';
      }
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isTrue);
    });

    test('rejects JSON exceeding maxJsonDepth nesting', () {
      // Build JSON with 9 levels of nesting (one more than allowed)
      var json = '"leaf"';
      for (var i = 0; i < MediaValidator.maxJsonDepth + 1; i++) {
        json = '{"d": $json}';
      }
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('nesting too deep'));
    });

    test('rejects JSON exceeding maxJsonBytes', () {
      // Create a string longer than 512 KB
      final oversized = '{"v": "${'x' * (MediaValidator.maxJsonBytes + 1)}"}';
      final result = MediaValidator.validateJsonPayload(oversized);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('too large'));
    });

    test('accepts JSON exactly at maxJsonBytes', () {
      // Build a valid JSON string of exactly maxJsonBytes length
      // {"v":"xxx..."} — overhead is 7 chars for {"v":"} and "} = 7 + 1 = 8? no:
      // {"v":"<padding>"} = 7 + padding.length + 2 = padding.length + 9
      // Wait: {"v":" is 6 chars, then padding, then "} is 2 chars = padding + 8
      // Actually: { " v " : " padding " } = 7 + padding + 1 = padding + 8
      // Let's just measure: '{"v":""}' is 8 chars, so padding = maxJsonBytes - 8
      final padding = 'x' * (MediaValidator.maxJsonBytes - 8);
      final json = '{"v":"$padding"}';
      expect(json.length, equals(MediaValidator.maxJsonBytes));
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isTrue);
    });

    test('counts array nesting correctly', () {
      // [[[[[[[[["leaf"]]]]]]]]] — 9 levels of array nesting
      var json = '"leaf"';
      for (var i = 0; i < MediaValidator.maxJsonDepth + 1; i++) {
        json = '[$json]';
      }
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('nesting too deep'));
    });

    test('does not count braces inside strings as nesting', () {
      // The depth counter should ignore braces inside quoted strings
      final json = '{"data": "{{{{{{{{{{{{{{{{{{{{{"}';
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isTrue);
    });

    test('mixed object and array nesting is summed', () {
      // Build 9 alternating object/array levels
      var json = '"x"';
      for (var i = 0; i < MediaValidator.maxJsonDepth + 1; i++) {
        json = i.isEven ? '{"d": $json}' : '[$json]';
      }
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isFalse);
    });

    test('accepts empty string payload', () {
      final result = MediaValidator.validateJsonPayload('');
      expect(result.isValid, isTrue);
    });

    test('accepts flat JSON with many keys (no deep nesting)', () {
      final entries =
          List.generate(100, (i) => '"k$i": "v$i"').join(', ');
      final json = '{$entries}';
      final result = MediaValidator.validateJsonPayload(json);
      expect(result.isValid, isTrue);
    });
  });

  // ==========================================================================
  // MediaValidationResult
  // ==========================================================================
  group('MediaValidationResult', () {
    test('ok result has isValid=true and null reason', () {
      const r = MediaValidationResult.ok;
      expect(r.isValid, isTrue);
      expect(r.reason, isNull);
    });

    test('reject result has isValid=false and a reason', () {
      final r = MediaValidationResult.reject('bad data');
      expect(r.isValid, isFalse);
      expect(r.reason, equals('bad data'));
    });

    test('toString for ok', () {
      expect(MediaValidationResult.ok.toString(), equals('ok'));
    });

    test('toString for reject includes reason', () {
      final r = MediaValidationResult.reject('too big');
      expect(r.toString(), equals('rejected: too big'));
    });
  });

  // ==========================================================================
  // validateVideo
  // ==========================================================================
  group('validateVideo', () {
    Uint8List makeMp4({int size = 64}) {
      final b = Uint8List(size);
      // MP4 "ftyp" at offset 4
      b[4] = 0x66; b[5] = 0x74; b[6] = 0x79; b[7] = 0x70;
      return b;
    }

    Uint8List makeWebM({int size = 64}) {
      final b = Uint8List(size);
      // EBML header 0x1A45DFA3
      b[0] = 0x1A; b[1] = 0x45; b[2] = 0xDF; b[3] = 0xA3;
      return b;
    }

    test('accepts valid MP4 bytes', () {
      final result = MediaValidator.validateVideo(makeMp4());
      expect(result.isValid, isTrue);
    });

    test('accepts valid WebM bytes', () {
      final result = MediaValidator.validateVideo(makeWebM());
      expect(result.isValid, isTrue);
    });

    test('rejects video exceeding 15 MB', () {
      final big = makeMp4(size: MediaValidator.maxVideoNoteBytes + 1);
      final result = MediaValidator.validateVideo(big);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('15 MB'));
    });

    test('rejects bytes without video magic', () {
      final result = MediaValidator.validateVideo(Uint8List(64));
      expect(result.isValid, isFalse);
      expect(result.reason, contains('video format'));
    });

    test('rejects bytes too short for magic detection', () {
      final result = MediaValidator.validateVideo(Uint8List(4));
      expect(result.isValid, isFalse);
    });

    test('accepts MP4 at exactly 15 MB', () {
      final exact = makeMp4(size: MediaValidator.maxVideoNoteBytes);
      final result = MediaValidator.validateVideo(exact);
      expect(result.isValid, isTrue);
    });
  });

  // ==========================================================================
  // validateGif
  // ==========================================================================
  group('validateGif', () {
    Uint8List makeGif89a({int size = 64}) {
      final b = Uint8List(size);
      // GIF89a: 47 49 46 38 39 61
      b[0] = 0x47; b[1] = 0x49; b[2] = 0x46;
      b[3] = 0x38; b[4] = 0x39; b[5] = 0x61;
      return b;
    }

    Uint8List makeGif87a({int size = 64}) {
      final b = Uint8List(size);
      // GIF87a: 47 49 46 38 37 61
      b[0] = 0x47; b[1] = 0x49; b[2] = 0x46;
      b[3] = 0x38; b[4] = 0x37; b[5] = 0x61;
      return b;
    }

    test('accepts valid GIF89a bytes', () {
      final result = MediaValidator.validateGif(makeGif89a());
      expect(result.isValid, isTrue);
    });

    test('accepts valid GIF87a bytes', () {
      final result = MediaValidator.validateGif(makeGif87a());
      expect(result.isValid, isTrue);
    });

    test('rejects GIF exceeding 10 MB', () {
      final big = makeGif89a(size: MediaValidator.maxGifBytes + 1);
      final result = MediaValidator.validateGif(big);
      expect(result.isValid, isFalse);
      expect(result.reason, contains('10 MB'));
    });

    test('rejects bytes without GIF magic', () {
      final result = MediaValidator.validateGif(Uint8List(64));
      expect(result.isValid, isFalse);
      expect(result.reason, contains('GIF'));
    });

    test('rejects bytes too short for magic detection', () {
      final result = MediaValidator.validateGif(Uint8List(3));
      expect(result.isValid, isFalse);
    });

    test('accepts GIF at exactly 10 MB', () {
      final exact = makeGif89a(size: MediaValidator.maxGifBytes);
      final result = MediaValidator.validateGif(exact);
      expect(result.isValid, isTrue);
    });
  });
}
