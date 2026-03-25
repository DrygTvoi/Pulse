import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';
import 'pqc_service.dart';

/// PQC hybrid encryption layer.
///
/// Wraps a Signal ciphertext (`E2EE||…`) with:
///   Kyber-1024 KEM  →  HKDF-SHA256  →  AES-256-GCM
///
/// Wire format (sent over transport):
///   `PQC2||<kyber_ct_b64>||<nonce_b64>||<aes_gcm_b64>`
///
///   kyber_ct  : Kyber-1024 encapsulation ciphertext (1568 bytes)
///   nonce     : 12-byte random AES-GCM nonce
///   aes_gcm   : AES-256-GCM(messageKey, nonce, signalCiphertext)
///               with 128-bit GCM authentication tag appended
///
/// Key derivation:
///   messageKey = HKDF-SHA256(kyber_shared_secret, info="Aegis_PQC_v1")
///
/// Backward compatibility:
///   Messages not starting with `PQC2||` pass through unchanged (v1 / legacy).
///   If the contact has no kyberPublicKey in their bundle, wrap() is a no-op.
///
/// Crypto agility:
///   The `PQC2` prefix is the version tag.  Future algorithms use `PQC3`, etc.
///   Only the wrap/unwrap logic in this file needs updating — nothing else changes.
class CryptoLayer {
  static const _prefix = 'PQC2||';
  static final _rng = Random.secure();

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Wrap [signalCt] with a fresh Kyber-1024 encapsulation + AES-256-GCM.
  ///
  /// [remotePk] is the recipient's Kyber public key from their bundle.
  /// Returns [signalCt] unchanged when [remotePk] is null (no PQC available).
  static String wrap(String signalCt, Uint8List? remotePk) {
    if (remotePk == null) return signalCt;
    // ML-KEM-1024 public key must be exactly 1568 bytes.
    if (remotePk.length != 1568) return signalCt; // silently skip — don't crash sender

    // Fresh per-message encapsulation → perfect forward secrecy at PQC layer.
    final (ct, ss) = PqcService().encapsulate(remotePk);
    final key = _hkdf(ss);
    final nonce = _randomBytes(12);
    final ciphertext = _aesGcmEncrypt(key, nonce, utf8.encode(signalCt));

    return '$_prefix${base64Encode(ct)}||${base64Encode(nonce)}||${base64Encode(ciphertext)}';
  }

  /// Unwrap a PQC-wrapped message → inner Signal ciphertext.
  ///
  /// Returns [wrapped] unchanged if it does not start with `PQC2||`.
  /// Throws [FormatException] or [Exception] on tampered / malformed input.
  static String unwrap(String wrapped) {
    if (!wrapped.startsWith(_prefix)) return wrapped;

    final body = wrapped.substring(_prefix.length);
    final parts = body.split('||');
    if (parts.length != 3) {
      throw FormatException('Invalid PQC envelope: expected 3 parts, got ${parts.length}');
    }

    final Uint8List ct, nonce, ciphertext;
    try {
      ct = base64Decode(parts[0]);
      nonce = base64Decode(parts[1]);
      ciphertext = base64Decode(parts[2]);
    } catch (e) {
      throw FormatException('Invalid PQC envelope: base64 decode failed — $e');
    }

    // ML-KEM-1024 ciphertext is always 1568 bytes — reject anything else early
    // to avoid double-decapsulation with _skPrev on obviously malformed input.
    if (ct.length != 1568) {
      throw FormatException('Invalid PQC ciphertext: expected 1568 bytes, got ${ct.length}');
    }
    final ss = PqcService().decapsulate(ct);
    final key = _hkdf(ss);

    final Uint8List plaintext;
    try {
      plaintext = _aesGcmDecrypt(key, nonce, ciphertext);
    } catch (e) {
      throw Exception('PQC-GCM authentication failed (tampered or wrong key): $e');
    }

    return utf8.decode(plaintext);
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// HKDF-SHA256 (RFC 5869) with all-zero salt and fixed info string.
  /// Input: 32-byte Kyber shared secret.  Output: 32-byte AES key.
  static Uint8List _hkdf(Uint8List ikm) {
    // Step 1 — Extract: PRK = HMAC-SHA256(salt=0x00…00, IKM)
    final salt = Uint8List(32); // 32 zero bytes (SHA-256 hash length)
    final prk = Uint8List.fromList(
      crypto.Hmac(crypto.sha256, salt).convert(ikm).bytes,
    );

    // Step 2 — Expand: T(1) = HMAC-SHA256(PRK, info || 0x01)
    // Single block suffices because output length (32) == HashLen (32).
    // Label kept as 'Aegis_PQC_v1' for backward compat — do not rename.
    final info = utf8.encode('Aegis_PQC_v1'); // domain-separation label
    final expandInput = Uint8List(info.length + 1)
      ..setAll(0, info)
      ..[info.length] = 0x01;

    return Uint8List.fromList(
      crypto.Hmac(crypto.sha256, prk).convert(expandInput).bytes,
    );
  }

  /// AES-256-GCM encrypt. Returns ciphertext with 16-byte GCM tag appended.
  static Uint8List _aesGcmEncrypt(Uint8List key, Uint8List nonce, Uint8List plaintext) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)));
    return cipher.process(plaintext);
  }

  /// AES-256-GCM decrypt + verify. Input must include 16-byte GCM tag at end.
  /// Throws [InvalidCipherTextException] on authentication failure.
  static Uint8List _aesGcmDecrypt(Uint8List key, Uint8List nonce, Uint8List ciphertext) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)));
    return cipher.process(ciphertext);
  }

  static Uint8List _randomBytes(int length) =>
      Uint8List.fromList(List.generate(length, (_) => _rng.nextInt(256)));
}
