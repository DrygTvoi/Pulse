import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/media_crypto_service.dart';

void main() {
  group('MediaCryptoService', () {
    test('encrypt returns ciphertext, key and iv', () {
      final plaintext = Uint8List.fromList(List.generate(256, (i) => i % 256));
      final result = MediaCryptoService.encrypt(plaintext);

      expect(result.key.length, 32); // AES-256
      expect(result.iv.length, 12); // GCM nonce
      // Ciphertext = plaintext + 16-byte GCM tag
      expect(result.ciphertext.length, plaintext.length + 16);
      // Ciphertext should differ from plaintext
      expect(result.ciphertext.sublist(0, plaintext.length), isNot(equals(plaintext)));
    });

    test('encrypt → decrypt roundtrip', () {
      final plaintext = Uint8List.fromList(
        List.generate(1024, (i) => i % 256),
      );
      final enc = MediaCryptoService.encrypt(plaintext);
      final decrypted = MediaCryptoService.decrypt(enc.ciphertext, enc.key, enc.iv);

      expect(decrypted, equals(plaintext));
    });

    test('decrypt fails with wrong key', () {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final enc = MediaCryptoService.encrypt(plaintext);
      final wrongKey = Uint8List(32); // all zeros

      expect(
        () => MediaCryptoService.decrypt(enc.ciphertext, wrongKey, enc.iv),
        throwsA(anything),
      );
    });

    test('decrypt fails with wrong iv', () {
      final plaintext = Uint8List.fromList([10, 20, 30]);
      final enc = MediaCryptoService.encrypt(plaintext);
      final wrongIv = Uint8List(12);

      expect(
        () => MediaCryptoService.decrypt(enc.ciphertext, enc.key, wrongIv),
        throwsA(anything),
      );
    });

    test('decrypt fails with tampered ciphertext', () {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final enc = MediaCryptoService.encrypt(plaintext);
      // Flip a bit
      final tampered = Uint8List.fromList(enc.ciphertext);
      tampered[0] ^= 0xFF;

      expect(
        () => MediaCryptoService.decrypt(tampered, enc.key, enc.iv),
        throwsA(anything),
      );
    });

    test('each encryption produces unique key and iv', () {
      final plaintext = Uint8List.fromList([1, 2, 3]);
      final enc1 = MediaCryptoService.encrypt(plaintext);
      final enc2 = MediaCryptoService.encrypt(plaintext);

      expect(enc1.key, isNot(equals(enc2.key)));
      expect(enc1.iv, isNot(equals(enc2.iv)));
    });

    test('handles empty plaintext', () {
      final plaintext = Uint8List(0);
      final enc = MediaCryptoService.encrypt(plaintext);
      expect(enc.ciphertext.length, 16); // just GCM tag
      final decrypted = MediaCryptoService.decrypt(enc.ciphertext, enc.key, enc.iv);
      expect(decrypted, equals(plaintext));
    });

    test('handles large plaintext (1MB)', () {
      final plaintext = Uint8List(1024 * 1024);
      for (int i = 0; i < plaintext.length; i++) {
        plaintext[i] = i & 0xFF;
      }
      final enc = MediaCryptoService.encrypt(plaintext);
      final decrypted = MediaCryptoService.decrypt(enc.ciphertext, enc.key, enc.iv);
      expect(decrypted, equals(plaintext));
    });
  });
}
