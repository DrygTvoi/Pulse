import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// Per-file AES-256-GCM encryption for Blossom uploads.
///
/// Same algorithm as [CryptoLayer._aesGcmEncrypt/Decrypt] but with a random
/// per-file key. The key + IV travel inside the Signal-encrypted message,
/// so the Blossom server only ever sees ciphertext.
class MediaCryptoService {
  static final _rng = Random.secure();

  /// Encrypt [plaintext] with a fresh random AES-256 key and 12-byte IV.
  /// Returns ciphertext (with 16-byte GCM tag appended), key, and IV.
  static ({Uint8List ciphertext, Uint8List key, Uint8List iv}) encrypt(
      Uint8List plaintext) {
    final key = _randomBytes(32);
    final iv = _randomBytes(12);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    final ciphertext = cipher.process(plaintext);
    return (ciphertext: ciphertext, key: key, iv: iv);
  }

  /// Decrypt AES-256-GCM ciphertext (with 16-byte GCM tag at end).
  /// Throws [InvalidCipherTextException] on authentication failure.
  static Uint8List decrypt(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return cipher.process(ciphertext);
  }

  static Uint8List _randomBytes(int length) =>
      Uint8List.fromList(List.generate(length, (_) => _rng.nextInt(256)));
}
