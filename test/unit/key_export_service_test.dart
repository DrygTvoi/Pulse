import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for KeyExportService file-format logic.
///
/// KeyExportService depends on FlutterSecureStorage and flutter/foundation
/// (compute), so we cannot import it directly.  Instead we reimplement the
/// pure validation/format constants here (same pattern as waku_adapter_test).
///
/// File format (v1):
///   [4 bytes magic "PLKE"]
///   [2 bytes version LE uint16 = 1]
///   [16 bytes PBKDF2 salt]
///   [12 bytes AES-GCM IV]
///   [remaining: AES-256-GCM ciphertext + 16-byte auth tag]

// ── Reimplemented constants from KeyExportService ────────────────────────────

const _kMagic = [0x50, 0x4C, 0x4B, 0x45]; // "PLKE"
const _kVersion = 1;
const _kSaltLen = 16;
const _kIvLen = 12;
const _kHeaderLen = 4 + 2 + _kSaltLen + _kIvLen; // 34 bytes
const _kGcmTagLen = 16;
const _kPbkdf2Iterations = 200000;
const _kPbkdf2KeyLen = 32;

/// Reimplemented from KeyExportService.isValidExportFile
bool isValidExportFile(Uint8List data) {
  if (data.length < _kHeaderLen + _kGcmTagLen) return false;
  for (int i = 0; i < 4; i++) {
    if (data[i] != _kMagic[i]) return false;
  }
  return true;
}

/// Parse the LE uint16 version from bytes 4-5.
int parseVersion(Uint8List data) {
  if (data.length < 6) return -1;
  return data[4] | (data[5] << 8);
}

/// Extract the salt from the header (bytes 6..22).
Uint8List extractSalt(Uint8List data) {
  if (data.length < _kHeaderLen) return Uint8List(0);
  return Uint8List.sublistView(data, 6, 6 + _kSaltLen);
}

/// Extract the IV from the header (bytes 22..34).
Uint8List extractIv(Uint8List data) {
  if (data.length < _kHeaderLen) return Uint8List(0);
  return Uint8List.sublistView(data, 6 + _kSaltLen, _kHeaderLen);
}

/// Build a minimal valid PLKE file header with a fake GCM tag.
Uint8List buildValidFile({int version = _kVersion, int extraPayload = 0}) {
  final bytes = BytesBuilder(copy: false);
  bytes.add(_kMagic);
  bytes.add([version & 0xFF, (version >> 8) & 0xFF]);
  bytes.add(List.filled(_kSaltLen, 0xAA)); // salt
  bytes.add(List.filled(_kIvLen, 0xBB)); // IV
  bytes.add(List.filled(extraPayload, 0xCC)); // ciphertext (may be empty)
  bytes.add(List.filled(_kGcmTagLen, 0xDD)); // GCM auth tag
  return bytes.toBytes();
}

/// Keys that KeyExportService exports.
const exportKeys = [
  'signal_id_key',
  'signal_reg_id',
  'signal_signed_prekey_0',
  'nostr_privkey',
  'oxen_seed',
  'pqc_kyber_pk',
  'pqc_kyber_sk',
];

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Magic bytes ──────────────────────────────────────────────────────────

  group('Magic bytes', () {
    test('magic bytes spell "PLKE" in ASCII', () {
      final ascii = String.fromCharCodes(_kMagic);
      expect(ascii, equals('PLKE'));
    });

    test('magic bytes are exactly 4 bytes', () {
      expect(_kMagic.length, equals(4));
    });

    test('magic byte values are correct', () {
      expect(_kMagic[0], equals(0x50)); // P
      expect(_kMagic[1], equals(0x4C)); // L
      expect(_kMagic[2], equals(0x4B)); // K
      expect(_kMagic[3], equals(0x45)); // E
    });
  });

  // ── File format constants ────────────────────────────────────────────────

  group('File format constants', () {
    test('version is 1', () {
      expect(_kVersion, equals(1));
    });

    test('salt length is 16 bytes', () {
      expect(_kSaltLen, equals(16));
    });

    test('IV length is 12 bytes (AES-GCM standard)', () {
      expect(_kIvLen, equals(12));
    });

    test('header length is 34 bytes (4 magic + 2 version + 16 salt + 12 IV)', () {
      expect(_kHeaderLen, equals(34));
      expect(_kHeaderLen, equals(4 + 2 + _kSaltLen + _kIvLen));
    });

    test('GCM auth tag is 16 bytes', () {
      expect(_kGcmTagLen, equals(16));
    });

    test('minimum valid file size is headerLen + 16 (tag only, no ciphertext)', () {
      final minSize = _kHeaderLen + _kGcmTagLen;
      expect(minSize, equals(50));
    });
  });

  // ── PBKDF2 parameters ───────────────────────────────────────────────────

  group('PBKDF2 parameters', () {
    test('iteration count is 200000 (OWASP 2023 recommendation)', () {
      expect(_kPbkdf2Iterations, equals(200000));
    });

    test('derived key length is 32 bytes (256-bit AES key)', () {
      expect(_kPbkdf2KeyLen, equals(32));
    });

    test('iteration count is at least 100000 (minimum security)', () {
      expect(_kPbkdf2Iterations, greaterThanOrEqualTo(100000));
    });
  });

  // ── isValidExportFile ────────────────────────────────────────────────────

  group('isValidExportFile', () {
    test('accepts a minimal valid PLKE file (header + GCM tag only)', () {
      final data = buildValidFile();
      expect(isValidExportFile(data), isTrue);
    });

    test('accepts a valid PLKE file with ciphertext payload', () {
      final data = buildValidFile(extraPayload: 128);
      expect(isValidExportFile(data), isTrue);
    });

    test('rejects empty file', () {
      expect(isValidExportFile(Uint8List(0)), isFalse);
    });

    test('rejects file shorter than minimum (49 bytes = headerLen + 15)', () {
      final tooShort = Uint8List(_kHeaderLen + _kGcmTagLen - 1);
      // Set magic bytes so only length check fails
      tooShort[0] = 0x50;
      tooShort[1] = 0x4C;
      tooShort[2] = 0x4B;
      tooShort[3] = 0x45;
      expect(isValidExportFile(tooShort), isFalse);
    });

    test('accepts file of exactly minimum size (50 bytes)', () {
      final exact = buildValidFile(extraPayload: 0);
      expect(exact.length, equals(_kHeaderLen + _kGcmTagLen));
      expect(isValidExportFile(exact), isTrue);
    });

    test('rejects file with wrong first magic byte', () {
      final data = buildValidFile();
      data[0] = 0x00; // corrupt first byte
      expect(isValidExportFile(data), isFalse);
    });

    test('rejects file with wrong second magic byte', () {
      final data = buildValidFile();
      data[1] = 0xFF;
      expect(isValidExportFile(data), isFalse);
    });

    test('rejects file with wrong third magic byte', () {
      final data = buildValidFile();
      data[2] = 0x00;
      expect(isValidExportFile(data), isFalse);
    });

    test('rejects file with wrong fourth magic byte', () {
      final data = buildValidFile();
      data[3] = 0x00;
      expect(isValidExportFile(data), isFalse);
    });

    test('rejects file with completely wrong magic bytes', () {
      final data = Uint8List(_kHeaderLen + _kGcmTagLen);
      // All zeros — wrong magic
      expect(isValidExportFile(data), isFalse);
    });

    test('rejects a PNG file (magic 0x89 0x50 0x4E 0x47)', () {
      final png = Uint8List(_kHeaderLen + _kGcmTagLen);
      png[0] = 0x89;
      png[1] = 0x50;
      png[2] = 0x4E;
      png[3] = 0x47;
      expect(isValidExportFile(png), isFalse);
    });

    test('rejects a ZIP file (magic 0x50 0x4B 0x03 0x04)', () {
      final zip = Uint8List(_kHeaderLen + _kGcmTagLen);
      zip[0] = 0x50;
      zip[1] = 0x4B;
      zip[2] = 0x03;
      zip[3] = 0x04;
      expect(isValidExportFile(zip), isFalse);
    });

    test('does not check version (isValidExportFile only checks magic + length)', () {
      // isValidExportFile does NOT validate version — it only checks magic + min size.
      // Version check happens in importKeys().
      final data = buildValidFile(version: 99);
      expect(isValidExportFile(data), isTrue);
    });
  });

  // ── Version parsing ──────────────────────────────────────────────────────

  group('Version parsing (LE uint16)', () {
    test('parses version 1 correctly', () {
      final data = buildValidFile(version: 1);
      expect(parseVersion(data), equals(1));
    });

    test('parses version 0 correctly', () {
      final data = buildValidFile(version: 0);
      expect(parseVersion(data), equals(0));
    });

    test('parses version 256 correctly (tests LE byte order)', () {
      final data = buildValidFile(version: 256);
      // LE: low byte = 0x00, high byte = 0x01
      expect(data[4], equals(0x00));
      expect(data[5], equals(0x01));
      expect(parseVersion(data), equals(256));
    });

    test('returns -1 for data too short to contain version', () {
      expect(parseVersion(Uint8List(5)), equals(-1));
    });
  });

  // ── Header field extraction ─────────────────────────────────────────────

  group('Header field extraction', () {
    test('extractSalt returns 16 bytes starting at offset 6', () {
      final data = buildValidFile();
      final salt = extractSalt(data);
      expect(salt.length, equals(_kSaltLen));
      // Our builder fills salt with 0xAA
      for (final b in salt) {
        expect(b, equals(0xAA));
      }
    });

    test('extractIv returns 12 bytes starting at offset 22', () {
      final data = buildValidFile();
      final iv = extractIv(data);
      expect(iv.length, equals(_kIvLen));
      // Our builder fills IV with 0xBB
      for (final b in iv) {
        expect(b, equals(0xBB));
      }
    });

    test('salt and IV do not overlap', () {
      final data = buildValidFile();
      final salt = extractSalt(data);
      final iv = extractIv(data);
      // Salt ends at offset 22, IV starts at offset 22
      expect(salt.length + 6, equals(6 + _kSaltLen)); // salt offset end
      // They are contiguous but not overlapping
      expect(salt.length, equals(16));
      expect(iv.length, equals(12));
      // Fill differently and verify independence
      final custom = buildValidFile();
      // Modify salt region
      for (int i = 6; i < 6 + _kSaltLen; i++) {
        custom[i] = 0x11;
      }
      // Modify IV region
      for (int i = 6 + _kSaltLen; i < _kHeaderLen; i++) {
        custom[i] = 0x22;
      }
      final s = extractSalt(custom);
      final v = extractIv(custom);
      expect(s.every((b) => b == 0x11), isTrue);
      expect(v.every((b) => b == 0x22), isTrue);
    });

    test('extractSalt returns empty on too-short data', () {
      expect(extractSalt(Uint8List(10)).length, equals(0));
    });

    test('extractIv returns empty on too-short data', () {
      expect(extractIv(Uint8List(10)).length, equals(0));
    });
  });

  // ── Export keys list ─────────────────────────────────────────────────────

  group('Export keys list', () {
    test('contains 7 identity-critical keys', () {
      expect(exportKeys.length, equals(7));
    });

    test('includes signal_id_key', () {
      expect(exportKeys, contains('signal_id_key'));
    });

    test('includes nostr_privkey', () {
      expect(exportKeys, contains('nostr_privkey'));
    });

    test('includes oxen_seed', () {
      expect(exportKeys, contains('oxen_seed'));
    });

    test('includes both PQC Kyber keys (pk + sk)', () {
      expect(exportKeys, contains('pqc_kyber_pk'));
      expect(exportKeys, contains('pqc_kyber_sk'));
    });

    test('does NOT include per-device prekeys', () {
      expect(exportKeys, isNot(contains('signal_prekeys_generated')));
    });

    test('all key names are non-empty strings', () {
      for (final key in exportKeys) {
        expect(key, isNotEmpty);
        expect(key, isA<String>());
      }
    });
  });

  // ── File assembly roundtrip ──────────────────────────────────────────────

  group('File assembly roundtrip', () {
    test('buildValidFile produces correct total length (no extra payload)', () {
      final data = buildValidFile(extraPayload: 0);
      expect(data.length, equals(_kHeaderLen + _kGcmTagLen));
    });

    test('buildValidFile produces correct total length (with payload)', () {
      final data = buildValidFile(extraPayload: 64);
      expect(data.length, equals(_kHeaderLen + 64 + _kGcmTagLen));
    });

    test('header layout: magic at [0..3], version at [4..5], salt at [6..21], IV at [22..33]', () {
      final data = buildValidFile();
      // Magic
      expect(data.sublist(0, 4), equals(_kMagic));
      // Version LE
      expect(data[4], equals(1));
      expect(data[5], equals(0));
      // Salt (filled with 0xAA)
      expect(data.sublist(6, 22).every((b) => b == 0xAA), isTrue);
      // IV (filled with 0xBB)
      expect(data.sublist(22, 34).every((b) => b == 0xBB), isTrue);
    });
  });
}
