import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:cryptography/cryptography.dart';

/// Encrypted export/import of identity keys for device transfer.
///
/// File format (v1):
///   [4 bytes magic "PLKE"]
///   [2 bytes version  LE uint16 = 1]
///   [16 bytes PBKDF2 salt]
///   [12 bytes AES-GCM IV]
///   [remaining: AES-256-GCM ciphertext + 16-byte auth tag]
///
/// Keys exported:
///   - signal_id_key (Signal identity key pair)
///   - signal_reg_id (Signal registration ID)
///   - signal_signed_prekey_0 (Signal signed prekey)
///   - nostr_privkey (Nostr private key)
///   - oxen_seed (Oxen/Session seed)
///   - pqc_kyber_pk (post-quantum public key)
///   - pqc_kyber_sk (post-quantum secret key)
///
/// Signal prekeys are NOT exported — they are per-device by design.
/// New prekeys are generated on import when the app reinitializes.
class KeyExportService {
  static const _secureStorage = FlutterSecureStorage();

  // File format constants — same scheme as message backup in LocalStorageService
  static const _kMagic = [0x50, 0x4C, 0x4B, 0x45]; // "PLKE"
  static const _kVersion = 1;
  // 600 000 iterations: OWASP 2025 PBKDF2-HMAC-SHA256 recommendation.
  // The export file is subject to offline brute-force (attacker receives the
  // file and can try passwords at GPU speed).  Higher iterations directly
  // reduce the feasibility of dictionary attacks on weak export passwords.
  // Account creation uses Argon2id (memory-hard, ~1000× stronger per guess),
  // but the export format stays PBKDF2 for broad compatibility; 600k
  // iterations narrows the gap without requiring a format version bump.
  static const _kPbkdf2Iterations = 600000;
  static const _kPbkdf2KeyLen = 32; // 256-bit
  static const _kSaltLen = 16;
  static const _kIvLen = 12;
  static const _kHeaderLen = 4 + 2 + _kSaltLen + _kIvLen; // 34 bytes

  static final _aesGcm = AesGcm.with256bits();

  /// Keys to export — identity-critical only, no per-device prekeys.
  static const _exportKeys = [
    'signal_id_key',
    'signal_reg_id',
    'signal_signed_prekey_0',
    'nostr_privkey',
    'oxen_seed',
    'pqc_kyber_pk',
    'pqc_kyber_sk',
  ];

  /// Export all critical identity keys as an encrypted file.
  ///
  /// Returns encrypted bytes ready to write to a file, or null on failure.
  static Future<Uint8List?> exportKeys(String password) async {
    try {
      // 1. Read all keys from flutter_secure_storage
      final bundle = <String, String>{};
      for (final key in _exportKeys) {
        final val = await _secureStorage.read(key: key);
        if (val != null && val.isNotEmpty) {
          bundle[key] = val;
        }
      }

      if (bundle.isEmpty) {
        debugPrint('[KeyExport] No keys found to export');
        return null;
      }

      // 2. Serialize to JSON
      final jsonBytes = utf8.encode(jsonEncode(bundle));

      // 3. Generate salt + IV
      final rng = Random.secure();
      final salt =
          Uint8List.fromList(List.generate(_kSaltLen, (_) => rng.nextInt(256)));
      final iv =
          Uint8List.fromList(List.generate(_kIvLen, (_) => rng.nextInt(256)));

      // 4. Derive key via PBKDF2-HMAC-SHA256 (isolate for non-blocking)
      final keyBytes = await _deriveKey(password, salt);
      final secretKey = SecretKey(keyBytes);

      // 5. Encrypt with AES-256-GCM
      final secretBox = await _aesGcm.encrypt(
        jsonBytes,
        secretKey: secretKey,
        nonce: iv,
      );

      // 6. Assemble file: magic + version + salt + iv + ciphertext + mac
      final output = BytesBuilder(copy: false);
      output.add(_kMagic);
      output.add([_kVersion & 0xFF, (_kVersion >> 8) & 0xFF]);
      output.add(salt);
      output.add(iv);
      output.add(secretBox.cipherText);
      output.add(secretBox.mac.bytes);

      debugPrint('[KeyExport] Exported ${bundle.length} keys');
      return output.toBytes();
    } catch (e, st) {
      debugPrint('[KeyExport] Export failed: $e\n$st');
      return null;
    }
  }

  /// Import keys from an encrypted bundle.
  ///
  /// Returns the number of keys imported, or -1 on error.
  static Future<int> importKeys(Uint8List data, String password) async {
    try {
      // 1. Validate header
      if (data.length < _kHeaderLen + 16) {
        debugPrint('[KeyExport] File too small (${data.length} bytes)');
        return -1;
      }

      // Check magic bytes
      for (int i = 0; i < 4; i++) {
        if (data[i] != _kMagic[i]) {
          debugPrint('[KeyExport] Invalid magic bytes');
          return -1;
        }
      }

      // Check version
      final version = data[4] | (data[5] << 8);
      if (version != _kVersion) {
        debugPrint('[KeyExport] Unsupported version: $version');
        return -1;
      }

      // 2. Extract fields
      final salt = Uint8List.sublistView(data, 6, 6 + _kSaltLen);
      final iv = Uint8List.sublistView(data, 6 + _kSaltLen, _kHeaderLen);
      final encryptedPayload = Uint8List.sublistView(data, _kHeaderLen);

      if (encryptedPayload.length < 16) {
        debugPrint('[KeyExport] Encrypted payload too small');
        return -1;
      }

      final cipherText = Uint8List.sublistView(
          encryptedPayload, 0, encryptedPayload.length - 16);
      final macBytes = Uint8List.sublistView(
          encryptedPayload, encryptedPayload.length - 16);

      // 3. Derive key
      final keyBytes = await _deriveKey(password, salt);
      final secretKey = SecretKey(keyBytes);

      // 4. Decrypt
      final secretBox = SecretBox(
        cipherText,
        nonce: iv,
        mac: Mac(macBytes),
      );

      final List<int> plainBytes;
      try {
        plainBytes = await _aesGcm.decrypt(secretBox, secretKey: secretKey);
      } catch (e) {
        debugPrint('[KeyExport] Decryption failed (wrong password?): $e');
        return -1;
      }

      // 5. Parse JSON
      final Map<String, dynamic> bundle;
      try {
        bundle = jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[KeyExport] JSON parse failed: $e');
        return -1;
      }

      // 6. Write each key to flutter_secure_storage
      int imported = 0;
      for (final entry in bundle.entries) {
        if (_exportKeys.contains(entry.key) && entry.value is String) {
          await _secureStorage.write(key: entry.key, value: entry.value as String);
          imported++;
        }
      }

      // 7. Clear the prekeys_generated flag so Signal reinitializes fresh prekeys
      await _secureStorage.delete(key: 'signal_prekeys_generated');

      debugPrint('[KeyExport] Imported $imported keys');
      return imported;
    } catch (e, st) {
      debugPrint('[KeyExport] Import failed: $e\n$st');
      return -1;
    }
  }

  /// Encrypt an arbitrary string→string map (e.g. identity backup).
  ///
  /// Same binary format as [exportKeys]: magic + PBKDF2 salt + IV + AES-GCM.
  /// Returns encrypted bytes, or null on failure.
  static Future<Uint8List?> encryptRawBundle(
      Map<String, String> bundle, String password) async {
    try {
      final jsonBytes = utf8.encode(jsonEncode(bundle));
      final rng  = Random.secure();
      final salt = Uint8List.fromList(
          List.generate(_kSaltLen, (_) => rng.nextInt(256)));
      final iv   = Uint8List.fromList(
          List.generate(_kIvLen,   (_) => rng.nextInt(256)));
      final keyBytes  = await _deriveKey(password, salt);
      final secretBox = await _aesGcm.encrypt(
        jsonBytes, secretKey: SecretKey(keyBytes), nonce: iv);
      final out = BytesBuilder(copy: false);
      out.add(_kMagic);
      out.add([_kVersion & 0xFF, (_kVersion >> 8) & 0xFF]);
      out.add(salt);
      out.add(iv);
      out.add(secretBox.cipherText);
      out.add(secretBox.mac.bytes);
      return out.toBytes();
    } catch (e) {
      debugPrint('[KeyExport] encryptRawBundle failed: $e');
      return null;
    }
  }

  /// Decrypt a bundle encrypted with [encryptRawBundle].
  ///
  /// Returns the map, or null on wrong password / corrupted data.
  static Future<Map<String, String>?> decryptRawBundle(
      Uint8List data, String password) async {
    try {
      if (data.length < _kHeaderLen + 16) return null;
      for (int i = 0; i < 4; i++) {
        if (data[i] != _kMagic[i]) return null;
      }
      final version = data[4] | (data[5] << 8);
      if (version != _kVersion) return null;
      final salt = Uint8List.sublistView(data, 6, 6 + _kSaltLen);
      final iv   = Uint8List.sublistView(data, 6 + _kSaltLen, _kHeaderLen);
      final enc  = Uint8List.sublistView(data, _kHeaderLen);
      if (enc.length < 16) return null;
      final cipher   = Uint8List.sublistView(enc, 0, enc.length - 16);
      final macBytes = Uint8List.sublistView(enc, enc.length - 16);
      final keyBytes = await _deriveKey(password, salt);
      final List<int> plain;
      try {
        plain = await _aesGcm.decrypt(
          SecretBox(cipher, nonce: iv, mac: Mac(macBytes)),
          secretKey: SecretKey(keyBytes),
        );
      } catch (_) {
        debugPrint('[KeyExport] decryptRawBundle: wrong password or corrupted');
        return null;
      }
      final raw = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      return {for (final e in raw.entries) e.key: e.value.toString()};
    } catch (e) {
      debugPrint('[KeyExport] decryptRawBundle failed: $e');
      return null;
    }
  }

  /// Validate that a file has the correct PLKE magic bytes.
  static bool isValidExportFile(Uint8List data) {
    if (data.length < _kHeaderLen + 16) return false;
    for (int i = 0; i < 4; i++) {
      if (data[i] != _kMagic[i]) return false;
    }
    return true;
  }

  /// Derive a 256-bit AES key from [password] and [salt] using
  /// PBKDF2-HMAC-SHA256 in an isolate (non-blocking).
  static Future<Uint8List> _deriveKey(String password, Uint8List salt) {
    return compute(_pbkdf2Isolate, {
      'password': password,
      'salt': salt,
    });
  }

  /// Isolate entry point for PBKDF2.
  static Uint8List _pbkdf2Isolate(Map<String, dynamic> params) {
    final password = params['password'] as String;
    final salt = params['salt'] as Uint8List;
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    derivator.init(
        pc.Pbkdf2Parameters(salt, _kPbkdf2Iterations, _kPbkdf2KeyLen));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }
}
