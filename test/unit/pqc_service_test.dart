import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pqcrypto/pqcrypto.dart';
import 'package:pulse_messenger/services/pqc_service.dart';

void main() {
  group('PqcService — state and zeroize logic', () {
    late PqcService service;

    setUp(() {
      service = PqcService.testInstance();
    });

    tearDown(() {
      // Restore default singleton so other tests are not affected.
      PqcService.setInstanceForTesting(PqcService.testInstance());
    });

    test('newly constructed instance is not initialized', () {
      expect(service.isInitialized, isFalse);
    });

    test('publicKey throws StateError when not initialized', () {
      expect(() => service.publicKey, throwsStateError);
    });

    test('encapsulate throws StateError when not initialized', () {
      final fakePk = Uint8List(32);
      expect(() => service.encapsulate(fakePk), throwsStateError);
    });

    test('decapsulate throws StateError when not initialized', () {
      final fakeCt = Uint8List(32);
      expect(() => service.decapsulate(fakeCt), throwsStateError);
    });

    test('setKeysForTesting sets keys and marks initialized', () {
      final pk = Uint8List.fromList(List.generate(16, (i) => i));
      final sk = Uint8List.fromList(List.generate(16, (i) => i + 100));
      service.setKeysForTesting(pk: pk, sk: sk);

      expect(service.isInitialized, isTrue);
      expect(service.publicKey, equals(pk));
    });

    test('zeroize clears public key to all zeros then nulls it', () {
      final pk = Uint8List.fromList([1, 2, 3, 4, 5]);
      final sk = Uint8List.fromList([10, 20, 30, 40, 50]);
      service.setKeysForTesting(pk: pk, sk: sk);

      // Capture references before zeroize
      final pkRef = pk;
      final skRef = sk;

      service.zeroize();

      // The buffers should be zeroed
      expect(pkRef.every((b) => b == 0), isTrue,
          reason: 'pk buffer should be zeroed in place');
      expect(skRef.every((b) => b == 0), isTrue,
          reason: 'sk buffer should be zeroed in place');

      // Service should no longer be initialized
      expect(service.isInitialized, isFalse);
    });

    test('zeroize also clears previous secret key', () {
      final pk = Uint8List.fromList([1, 2, 3]);
      final sk = Uint8List.fromList([4, 5, 6]);
      final skPrev = Uint8List.fromList([7, 8, 9]);
      service.setKeysForTesting(pk: pk, sk: sk, skPrev: skPrev);

      service.zeroize();

      expect(skPrev.every((b) => b == 0), isTrue,
          reason: 'skPrev buffer should be zeroed in place');
      expect(service.isInitialized, isFalse);
    });

    test('zeroize on already-uninitialized service is safe (no-op)', () {
      // Should not throw
      service.zeroize();
      expect(service.isInitialized, isFalse);
    });

    test('publicKey throws after zeroize', () {
      final pk = Uint8List.fromList([1, 2]);
      final sk = Uint8List.fromList([3, 4]);
      service.setKeysForTesting(pk: pk, sk: sk);
      expect(service.isInitialized, isTrue);

      service.zeroize();
      expect(() => service.publicKey, throwsStateError);
    });

    test('setInstanceForTesting replaces the singleton', () {
      final custom = PqcService.testInstance();
      final pk = Uint8List.fromList([99]);
      final sk = Uint8List.fromList([88]);
      custom.setKeysForTesting(pk: pk, sk: sk);

      PqcService.setInstanceForTesting(custom);
      expect(PqcService().isInitialized, isTrue);
      expect(PqcService().publicKey, equals(pk));
    });

    test('double zeroize is safe', () {
      final pk = Uint8List.fromList([1, 2, 3]);
      final sk = Uint8List.fromList([4, 5, 6]);
      service.setKeysForTesting(pk: pk, sk: sk);

      service.zeroize();
      // Second zeroize after keys are already null — should not throw
      service.zeroize();
      expect(service.isInitialized, isFalse);
    });
  });

  group('PqcService — KEM encapsulate/decapsulate roundtrip', () {
    late PqcService service;

    setUp(() {
      // Generate a real Kyber-1024 keypair via the pqcrypto library
      final kem = PqcKem.kyber1024;
      final (pk, sk) = kem.generateKeyPair();
      service = PqcService.testInstance();
      service.setKeysForTesting(
        pk: Uint8List.fromList(pk),
        sk: Uint8List.fromList(sk),
      );
    });

    test('encapsulate returns ciphertext and shared secret', () {
      final remotePk = service.publicKey;
      final (ct, ss) = service.encapsulate(remotePk);
      expect(ct, isNotEmpty);
      expect(ss, isNotEmpty);
      expect(ss.length, equals(32), reason: 'shared secret should be 32 bytes');
    });

    test('decapsulate recovers the same shared secret', () {
      final remotePk = service.publicKey;
      final (ct, ssEncap) = service.encapsulate(remotePk);
      final ssDecap = service.decapsulate(ct);
      expect(ssDecap, equals(ssEncap),
          reason: 'decapsulated secret should match encapsulated secret');
    });

    test('different encapsulations produce different shared secrets', () {
      final remotePk = service.publicKey;
      final (_, ss1) = service.encapsulate(remotePk);
      final (_, ss2) = service.encapsulate(remotePk);
      // Shared secrets should almost certainly differ (random encapsulation).
      // With 32 bytes of randomness, collision probability is negligible.
      expect(ss1, isNot(equals(ss2)),
          reason: 'each encapsulation should produce a unique shared secret');
    });

    test('decapsulate with wrong ciphertext throws', () {
      // A garbage ciphertext should fail
      // Kyber KEM is implicitly rejecting; wrong length throws.
      final shortCt = Uint8List(10);
      expect(() => service.decapsulate(shortCt), throwsA(anything));
    });

    test('decapsulate with wrong-length ciphertext triggers fallback to skPrev', () {
      // Kyber uses implicit rejection: wrong key returns garbage (no throw).
      // But wrong-length ciphertext causes a RangeError, triggering the
      // catch block and fallback to skPrev.
      final kem = PqcKem.kyber1024;
      final (pk1, sk1) = kem.generateKeyPair();
      final (pk2, sk2) = kem.generateKeyPair();

      // Encapsulate to pk1 (the "old" key)
      final (ct, ssOriginal) = kem.encapsulate(pk1);

      // Configure service: current sk is truncated (will throw on decapsulate),
      // skPrev is the correct sk for ct.
      final svc = PqcService.testInstance();
      // Use a deliberately invalid current sk (too short) so decapsulate throws
      svc.setKeysForTesting(
        pk: Uint8List.fromList(pk2),
        sk: Uint8List(10), // invalid: will cause RangeError
        skPrev: Uint8List.fromList(sk1),
      );

      final ssRecovered = svc.decapsulate(Uint8List.fromList(ct));
      expect(ssRecovered, equals(Uint8List.fromList(ssOriginal)),
          reason: 'fallback to skPrev should recover the shared secret');
    });

    test('zeroize prevents subsequent encapsulate', () {
      service.zeroize();
      expect(() => service.encapsulate(Uint8List(32)), throwsStateError);
    });

    test('zeroize prevents subsequent decapsulate', () {
      service.zeroize();
      expect(() => service.decapsulate(Uint8List(32)), throwsStateError);
    });
  });
}
