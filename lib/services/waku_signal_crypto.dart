import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart' as cryptography;

// ── Waku signal envelope encryption (AES-256-GCM) ─────────────────────────────
// Derives a symmetric key from sender+recipient IDs so signals are not
// readable by Waku relay nodes. Not full E2EE (IDs are public-ish), but
// prevents passive metadata observation by relays.

final _aesGcm = cryptography.AesGcm.with256bits();

/// Derive a 32-byte symmetric key from two peer IDs.
/// Inputs are sorted so both sides derive the same key regardless of call order.
Uint8List deriveWakuSignalKey(String a, String b) {
  final sorted = [a, b]..sort();
  final hmac = crypto.Hmac(crypto.sha256, utf8.encode('waku-signal-v1'));
  return Uint8List.fromList(
      hmac.convert(utf8.encode('${sorted[0]}|${sorted[1]}')).bytes);
}

/// Encrypt [json] with AES-256-GCM. Returns base64(nonce‖ciphertext‖mac).
Future<String> encryptWakuSignal(
    String json, String senderId, String recipientId) async {
  final keyBytes = deriveWakuSignalKey(senderId, recipientId);
  final key = cryptography.SecretKey(keyBytes);
  final box = await _aesGcm.encrypt(utf8.encode(json), secretKey: key);
  // nonce(12) || ciphertext || mac(16)
  final out = BytesBuilder()
    ..add(box.nonce)
    ..add(box.cipherText)
    ..add(box.mac.bytes);
  return base64.encode(out.toBytes());
}

/// Decrypt a base64 envelope produced by [encryptWakuSignal].
/// Returns the original JSON string, or null if decryption fails.
Future<String?> decryptWakuSignal(
    String b64, String senderId, String recipientId) async {
  try {
    final raw = base64.decode(b64);
    if (raw.length < 28) return null; // 12 nonce + 16 mac minimum
    final nonce = raw.sublist(0, 12);
    final mac = raw.sublist(raw.length - 16);
    final ct = raw.sublist(12, raw.length - 16);
    final keyBytes = deriveWakuSignalKey(senderId, recipientId);
    final key = cryptography.SecretKey(keyBytes);
    final box =
        cryptography.SecretBox(ct, nonce: nonce, mac: cryptography.Mac(mac));
    final plain = await _aesGcm.decrypt(box, secretKey: key);
    return utf8.decode(plain);
  } catch (_) {
    return null;
  }
}
