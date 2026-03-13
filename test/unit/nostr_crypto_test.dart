import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/adapters/nostr_adapter.dart';

/// Known secp256k1 test vectors (x-coordinate of scalar * G).
/// These are mathematically fixed: G = generator point of secp256k1.
///   k=1 → Gx = 79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
///   k=2 → 2Gx = c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5
void main() {
  group('deriveNostrPubkeyHex()', () {
    test('privkey 1 → generator point x-coordinate', () {
      const privkey =
          '0000000000000000000000000000000000000000000000000000000000000001';
      const expectedPubkey =
          '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';
      expect(deriveNostrPubkeyHex(privkey), equals(expectedPubkey));
    });

    test('privkey 2 → 2G x-coordinate', () {
      const privkey =
          '0000000000000000000000000000000000000000000000000000000000000002';
      const expectedPubkey =
          'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5';
      expect(deriveNostrPubkeyHex(privkey), equals(expectedPubkey));
    });

    test('result is always 64 lowercase hex characters', () {
      const privkey =
          'b94f5374fce5edbc8e2a8697c15331677e6ebf0b000000000000000000000001';
      final result = deriveNostrPubkeyHex(privkey);
      expect(result.length, equals(64));
      expect(result, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('is deterministic — same input yields same output', () {
      const privkey =
          '0000000000000000000000000000000000000000000000000000000000000001';
      expect(
        deriveNostrPubkeyHex(privkey),
        equals(deriveNostrPubkeyHex(privkey)),
      );
    });

    test('different private keys produce different public keys', () {
      const k1 =
          '0000000000000000000000000000000000000000000000000000000000000001';
      const k2 =
          '0000000000000000000000000000000000000000000000000000000000000002';
      expect(deriveNostrPubkeyHex(k1), isNot(equals(deriveNostrPubkeyHex(k2))));
    });

    test('throws on empty string', () {
      expect(() => deriveNostrPubkeyHex(''), throwsA(anything));
    });

    test('throws on invalid hex string', () {
      expect(() => deriveNostrPubkeyHex('not-hex-at-all'), throwsA(anything));
    });
  });
}
