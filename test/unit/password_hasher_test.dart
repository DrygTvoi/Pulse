import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    const testSalt = '0123456789abcdef0123456789abcdef';

    test('hash returns pbkdf2v1-prefixed string', () async {
      final h = await PasswordHasher.hash('testpass', testSalt);
      expect(h.startsWith('pbkdf2v1:'), isTrue);
    });

    test('hash is deterministic', () async {
      final h1 = await PasswordHasher.hash('password', testSalt);
      final h2 = await PasswordHasher.hash('password', testSalt);
      expect(h1, equals(h2));
    });

    test('different passwords produce different hashes', () async {
      final h1 = await PasswordHasher.hash('password1', testSalt);
      final h2 = await PasswordHasher.hash('password2', testSalt);
      expect(h1, isNot(equals(h2)));
    });

    test('verify returns true for correct password', () async {
      final h = await PasswordHasher.hash('correct', testSalt);
      expect(await PasswordHasher.verify('correct', testSalt, h), isTrue);
    });

    test('verify returns false for wrong password', () async {
      final h = await PasswordHasher.hash('correct', testSalt);
      expect(await PasswordHasher.verify('wrong', testSalt, h), isFalse);
    });

    test('verify handles legacy SHA-256 hashes', () async {
      // Legacy format: SHA-256(salt:password) as a plain hex string (no prefix).
      const pass = 'legacypass';
      final legacyHash = crypto.sha256
          .convert(utf8.encode('$testSalt:$pass'))
          .toString();

      expect(PasswordHasher.isLegacy(legacyHash), isTrue);
      expect(PasswordHasher.isLegacy('pbkdf2v1:$legacyHash'), isFalse);
      // verify() must accept the legacy hash and return true for the correct password.
      expect(await PasswordHasher.verify(pass, testSalt, legacyHash), isTrue);
      // and false for a wrong password.
      expect(await PasswordHasher.verify('wrong', testSalt, legacyHash), isFalse);
    });

    test('verify rejects empty password', () async {
      final h = await PasswordHasher.hash('secret', testSalt);
      expect(await PasswordHasher.verify('', testSalt, h), isFalse);
    });

    test('different salts produce different hashes', () async {
      final h1 = await PasswordHasher.hash('pass', testSalt);
      final h2 = await PasswordHasher.hash('pass', 'fedcba9876543210fedcba9876543210');
      expect(h1, isNot(equals(h2)));
    });
  });
}
