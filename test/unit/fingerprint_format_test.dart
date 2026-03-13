import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

// Replicate the fingerprint formatting algorithm from SignalService.
// _formatFingerprint is private, so we mirror the exact logic here
// to test it independently of platform-channel dependencies.
//
// Algorithm: skip the leading DJB prefix byte (0x05) when the array
// is long enough, then take up to 10 bytes and format as HEX:HEX:...
// uppercased.
String _formatFingerprint(Uint8List bytes) {
  final start = bytes.length > 10 ? 1 : 0;
  final take = (bytes.length - start).clamp(0, 10);
  return List.generate(
    take,
    (i) => bytes[start + i].toRadixString(16).padLeft(2, '0'),
  ).join(':').toUpperCase();
}

void main() {
  group('_formatFingerprint', () {
    test('normal key (33 bytes): skips prefix, takes bytes 1-10', () {
      // Simulate a 33-byte DJB public key: prefix 0x05 + 32 bytes of data
      final bytes = Uint8List(33);
      bytes[0] = 0x05;
      for (int i = 1; i <= 10; i++) {
        bytes[i] = i; // 0x01..0x0A
      }

      final fp = _formatFingerprint(bytes);
      expect(fp, '01:02:03:04:05:06:07:08:09:0A');
    });

    test('output is always 10 pairs for a standard 33-byte key', () {
      final bytes = Uint8List(33);
      final fp = _formatFingerprint(bytes);
      final parts = fp.split(':');
      expect(parts.length, 10);
    });

    test('each part is exactly 2 uppercase hex chars', () {
      final bytes = Uint8List(33);
      for (int i = 0; i < 33; i++) { bytes[i] = i * 7; } // varied values
      final fp = _formatFingerprint(bytes);
      for (final part in fp.split(':')) {
        expect(part.length, 2, reason: 'Part "$part" should be 2 chars');
        expect(RegExp(r'^[0-9A-F]{2}$').hasMatch(part), isTrue);
      }
    });

    test('output is uppercase (no lowercase hex)', () {
      final bytes = Uint8List(33);
      bytes[1] = 0xAB;
      bytes[2] = 0xCD;
      bytes[3] = 0xEF;
      final fp = _formatFingerprint(bytes);
      expect(fp, equals(fp.toUpperCase()));
    });

    test('single-digit byte values are zero-padded', () {
      final bytes = Uint8List(33);
      bytes[0] = 0x05; // prefix
      bytes[1] = 0x01; // → "01" not "1"
      bytes[2] = 0x0F; // → "0F" not "F"

      final fp = _formatFingerprint(bytes);
      final parts = fp.split(':');
      expect(parts[0], '01');
      expect(parts[1], '0F');
    });

    test('short array (≤10 bytes): no prefix skipped, all bytes used', () {
      // 5-byte array — should NOT skip first byte
      final bytes = Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05]);
      final fp = _formatFingerprint(bytes);
      expect(fp, '01:02:03:04:05');
    });

    test('exactly 11 bytes: skips first byte, takes next 10', () {
      final bytes = Uint8List(11);
      for (int i = 0; i < 11; i++) { bytes[i] = i; }
      // start=1, bytes[1..10] = 1,2,...,10
      final fp = _formatFingerprint(bytes);
      final parts = fp.split(':');
      expect(parts.length, 10);
      expect(parts.first, '01');
      expect(parts.last, '0A');
    });

    test('all-zero bytes produce all-zero fingerprint', () {
      final bytes = Uint8List(33); // zero-initialized
      final fp = _formatFingerprint(bytes);
      expect(fp, '00:00:00:00:00:00:00:00:00:00');
    });

    test('all-0xFF bytes produce all-FF fingerprint', () {
      final bytes = Uint8List(33);
      for (int i = 0; i < 33; i++) { bytes[i] = 0xFF; }
      final fp = _formatFingerprint(bytes);
      expect(fp, 'FF:FF:FF:FF:FF:FF:FF:FF:FF:FF');
    });

    test('two different keys produce different fingerprints', () {
      final key1 = Uint8List(33);
      final key2 = Uint8List(33);
      key1[1] = 0xAA;
      key2[1] = 0xBB;
      expect(_formatFingerprint(key1), isNot(_formatFingerprint(key2)));
    });

    test('same bytes always produce the same fingerprint (deterministic)', () {
      final bytes = Uint8List.fromList(List.generate(33, (i) => (i * 13) % 256));
      final fp1 = _formatFingerprint(bytes);
      final fp2 = _formatFingerprint(bytes);
      expect(fp1, fp2);
    });

    test('empty array returns empty string without crash', () {
      final fp = _formatFingerprint(Uint8List(0));
      expect(fp, '');
    });

    test('1-byte array is treated as data (not prefix), produces 1 part', () {
      final bytes = Uint8List.fromList([0xAB]);
      final fp = _formatFingerprint(bytes);
      expect(fp, 'AB');
    });
  });
}
