import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/adapters/nostr_adapter.dart';

/// Tests for NIP-04 Encrypt-then-MAC enforcement.
/// After the security hardening, MAC is required — messages without MAC are rejected.
void main() {
  // A pair of known secp256k1 private keys (for testing only, not real keys).
  const privkeyA =
      '0000000000000000000000000000000000000000000000000000000000000001';
  final pubkeyA = deriveNostrPubkeyHex(privkeyA);

  const privkeyB =
      '0000000000000000000000000000000000000000000000000000000000000002';
  final pubkeyB = deriveNostrPubkeyHex(privkeyB);

  group('NIP-04 encrypt', () {
    test('output contains ?iv= and &mac=', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'hello world');
      expect(ct, contains('?iv='));
      expect(ct, contains('&mac='));
    });

    test('mac is 64 hex characters (SHA-256)', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test message');
      final macPart = ct.split('&mac=').last;
      expect(macPart.length, equals(64));
      expect(macPart, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('is deterministic for same IV (different messages → different ct)', () {
      final ct1 = nip04Encrypt(privkeyA, pubkeyB, 'message one');
      final ct2 = nip04Encrypt(privkeyA, pubkeyB, 'message two');
      // Contents differ (different plaintext), but both have correct structure.
      expect(ct1, isNot(equals(ct2)));
      expect(ct1, contains('&mac='));
      expect(ct2, contains('&mac='));
    });
  });

  group('NIP-04 decrypt', () {
    test('round-trip: encrypt then decrypt recovers plaintext', () {
      const plain = 'Hello, Pulse!';
      final ct = nip04Encrypt(privkeyA, pubkeyB, plain);
      final recovered = nip04Decrypt(privkeyB, pubkeyA, ct);
      expect(recovered, equals(plain));
    });

    test('round-trip with unicode plaintext', () {
      const plain = 'Привет, мир! 🔐';
      final ct = nip04Encrypt(privkeyA, pubkeyB, plain);
      final recovered = nip04Decrypt(privkeyB, pubkeyA, ct);
      expect(recovered, equals(plain));
    });

    test('throws on missing MAC (backward compat removed)', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test');
      // Strip the &mac= part to simulate an old-style message.
      final ctNoMac = ct.split('&mac=').first;
      expect(
        () => nip04Decrypt(privkeyB, pubkeyA, ctNoMac),
        throwsA(isA<FormatException>().having(
          (e) => e.message, 'message', contains('missing MAC'),
        )),
      );
    });

    test('throws on tampered MAC', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test');
      // Replace last char of MAC with a different one.
      final tampered = ct.substring(0, ct.length - 1) +
          (ct.endsWith('a') ? 'b' : 'a');
      expect(
        () => nip04Decrypt(privkeyB, pubkeyA, tampered),
        throwsA(isA<FormatException>().having(
          (e) => e.message, 'message', contains('MAC verification failed'),
        )),
      );
    });

    test('throws on tampered ciphertext', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test message here');
      // Flip a byte in the ciphertext (before ?iv=).
      final ctPart = ct.split('?iv=').first;
      final ctBytes = base64Decode(ctPart);
      ctBytes[0] ^= 0xff;
      final tampered = '${base64Encode(ctBytes)}?iv=${ct.split('?iv=').last}';
      expect(
        () => nip04Decrypt(privkeyB, pubkeyA, tampered),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws with wrong recipient key', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'secret');
      // Try to decrypt with privkeyA instead of privkeyB → wrong ECDH secret → bad MAC.
      expect(
        () => nip04Decrypt(privkeyA, pubkeyA, ct),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
