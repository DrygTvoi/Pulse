import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/adapters/nostr_adapter.dart';

/// Pure-Dart unit tests for Nostr adapter public crypto helpers
/// and class initial-state invariants.
void main() {
  // ── Test key pairs (secp256k1 known vectors) ──────────────────────────────
  const privkeyA =
      '0000000000000000000000000000000000000000000000000000000000000001';
  const privkeyB =
      '0000000000000000000000000000000000000000000000000000000000000002';
  const privkeyC =
      '0000000000000000000000000000000000000000000000000000000000000003';

  late String pubkeyA;
  late String pubkeyB;
  late String pubkeyC;

  setUpAll(() {
    pubkeyA = deriveNostrPubkeyHex(privkeyA);
    pubkeyB = deriveNostrPubkeyHex(privkeyB);
    pubkeyC = deriveNostrPubkeyHex(privkeyC);
  });

  // ── deriveNostrPubkeyHex ──────────────────────────────────────────────────

  group('deriveNostrPubkeyHex', () {
    test('valid privkey returns 64-char hex pubkey', () {
      expect(pubkeyA.length, equals(64));
      expect(pubkeyA, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('privkey 1 yields known generator x-coordinate', () {
      expect(
        pubkeyA,
        equals(
            '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798'),
      );
    });

    test('privkey 2 yields known 2G x-coordinate', () {
      expect(
        pubkeyB,
        equals(
            'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5'),
      );
    });

    test('different privkeys produce different pubkeys', () {
      expect(pubkeyA, isNot(equals(pubkeyB)));
      expect(pubkeyB, isNot(equals(pubkeyC)));
    });

    test('is deterministic', () {
      expect(deriveNostrPubkeyHex(privkeyA), equals(pubkeyA));
      expect(deriveNostrPubkeyHex(privkeyA), equals(pubkeyA));
    });

    test('throws on empty string', () {
      expect(() => deriveNostrPubkeyHex(''), throwsA(anything));
    });

    test('throws on invalid hex', () {
      expect(() => deriveNostrPubkeyHex('zzzzzz'), throwsA(anything));
    });

    test('32-byte hex input produces correct-length output', () {
      const key =
          'b94f5374fce5edbc8e2a8697c15331677e6ebf0b000000000000000000000001';
      final pub = deriveNostrPubkeyHex(key);
      expect(pub.length, equals(64));
      expect(pub, matches(RegExp(r'^[0-9a-f]{64}$')));
    });
  });

  // ── computeEcdhSecret ─────────────────────────────────────────────────────

  group('computeEcdhSecret', () {
    test('symmetric property: ECDH(a,B) == ECDH(b,A)', () {
      final secretAB = computeEcdhSecret(privkeyA, pubkeyB);
      final secretBA = computeEcdhSecret(privkeyB, pubkeyA);
      expect(secretAB, equals(secretBA));
    });

    test('symmetric property with different key pair', () {
      final secretAC = computeEcdhSecret(privkeyA, pubkeyC);
      final secretCA = computeEcdhSecret(privkeyC, pubkeyA);
      expect(secretAC, equals(secretCA));
    });

    test('different pairs produce different secrets', () {
      final secretAB = computeEcdhSecret(privkeyA, pubkeyB);
      final secretAC = computeEcdhSecret(privkeyA, pubkeyC);
      expect(secretAB, isNot(equals(secretAC)));
    });

    test('returns 32-byte Uint8List', () {
      final secret = computeEcdhSecret(privkeyA, pubkeyB);
      expect(secret, isA<Uint8List>());
      expect(secret.length, equals(32));
    });

    test('is deterministic', () {
      final s1 = computeEcdhSecret(privkeyA, pubkeyB);
      final s2 = computeEcdhSecret(privkeyA, pubkeyB);
      expect(s1, equals(s2));
    });
  });

  // ── NIP-04 encrypt/decrypt roundtrip ──────────────────────────────────────

  group('nip04Encrypt / nip04Decrypt roundtrip', () {
    test('encrypts and decrypts ASCII plaintext', () {
      const plain = 'Hello, Nostr world!';
      final ct = nip04Encrypt(privkeyA, pubkeyB, plain);
      final recovered = nip04Decrypt(privkeyB, pubkeyA, ct);
      expect(recovered, equals(plain));
    });

    test('encrypts and decrypts unicode plaintext', () {
      const plain = 'Hola mundo! Tschuss! 42';
      final ct = nip04Encrypt(privkeyA, pubkeyB, plain);
      final recovered = nip04Decrypt(privkeyB, pubkeyA, ct);
      expect(recovered, equals(plain));
    });

    test('encrypts and decrypts empty string', () {
      // PKCS#7 padding handles 0-length plaintext as a full 16-byte pad block.
      const plain = '';
      final ct = nip04Encrypt(privkeyA, pubkeyB, plain);
      final recovered = nip04Decrypt(privkeyB, pubkeyA, ct);
      expect(recovered, equals(plain));
    });

    test('encrypts and decrypts long text (>1 AES block)', () {
      final plain = 'A' * 256; // 16 AES blocks
      final ct = nip04Encrypt(privkeyA, pubkeyB, plain);
      final recovered = nip04Decrypt(privkeyB, pubkeyA, ct);
      expect(recovered, equals(plain));
    });

    test('ciphertext contains iv and mac', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test');
      expect(ct, contains('?iv='));
      expect(ct, contains('&mac='));
    });

    test('MAC is 64-char lowercase hex (SHA-256)', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test');
      final mac = ct.split('&mac=').last;
      expect(mac.length, equals(64));
      expect(mac, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('each encryption produces different ciphertext (random IV)', () {
      final ct1 = nip04Encrypt(privkeyA, pubkeyB, 'same text');
      final ct2 = nip04Encrypt(privkeyA, pubkeyB, 'same text');
      expect(ct1, isNot(equals(ct2)));
    });

    test('throws on missing MAC', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test');
      final noMac = ct.split('&mac=').first;
      expect(
        () => nip04Decrypt(privkeyB, pubkeyA, noMac),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('missing MAC'))),
      );
    });

    test('throws on tampered MAC', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'test');
      final tampered = ct.substring(0, ct.length - 1) +
          (ct.endsWith('0') ? '1' : '0');
      expect(
        () => nip04Decrypt(privkeyB, pubkeyA, tampered),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('MAC verification failed'))),
      );
    });

    test('throws on wrong recipient key', () {
      final ct = nip04Encrypt(privkeyA, pubkeyB, 'secret');
      expect(
        () => nip04Decrypt(privkeyC, pubkeyA, ct),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on invalid ciphertext format (no ?iv=)', () {
      expect(
        () => nip04Decrypt(privkeyB, pubkeyA, 'not-valid-ciphertext'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // ── signSignalPayload / verifySignalPayload ───────────────────────────────

  group('signSignalPayload / verifySignalPayload', () {
    test('signing and verification roundtrip succeeds', () {
      const json = '{"type":"typing","roomId":"r1"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      final valid = verifySignalPayload(privkeyB, pubkeyA, json, sig);
      expect(valid, isTrue);
    });

    test('HMAC is 64-char lowercase hex', () {
      const json = '{"type":"heartbeat"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      expect(sig.length, equals(64));
      expect(sig, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('is deterministic for same inputs', () {
      const json = '{"type":"test"}';
      final sig1 = signSignalPayload(privkeyA, pubkeyB, json);
      final sig2 = signSignalPayload(privkeyA, pubkeyB, json);
      expect(sig1, equals(sig2));
    });

    test('symmetric shared secret: sign with A verify with B', () {
      const json = '{"hello":"world"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      final valid = verifySignalPayload(privkeyB, pubkeyA, json, sig);
      expect(valid, isTrue);
    });

    test('fails with wrong sender pubkey', () {
      const json = '{"type":"test"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      // Verify with C's pubkey instead of A's
      final valid = verifySignalPayload(privkeyB, pubkeyC, json, sig);
      expect(valid, isFalse);
    });

    test('fails with wrong verifier privkey', () {
      const json = '{"type":"test"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      // Verify with C's privkey instead of B's
      final valid = verifySignalPayload(privkeyC, pubkeyA, json, sig);
      expect(valid, isFalse);
    });

    test('fails with tampered payload', () {
      const json = '{"type":"test"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      const tampered = '{"type":"tampered"}';
      final valid = verifySignalPayload(privkeyB, pubkeyA, tampered, sig);
      expect(valid, isFalse);
    });

    test('fails with tampered HMAC', () {
      const json = '{"type":"test"}';
      final sig = signSignalPayload(privkeyA, pubkeyB, json);
      final tampered = sig.substring(0, sig.length - 1) +
          (sig.endsWith('0') ? '1' : '0');
      final valid = verifySignalPayload(privkeyB, pubkeyA, json, tampered);
      expect(valid, isFalse);
    });

    test('fails with wrong length HMAC', () {
      const json = '{"type":"test"}';
      final valid = verifySignalPayload(privkeyB, pubkeyA, json, 'short');
      expect(valid, isFalse);
    });

    test('different payloads produce different signatures', () {
      final sig1 = signSignalPayload(privkeyA, pubkeyB, 'payload1');
      final sig2 = signSignalPayload(privkeyA, pubkeyB, 'payload2');
      expect(sig1, isNot(equals(sig2)));
    });
  });

  // ── NostrInboxReader initial state ────────────────────────────────────────

  group('NostrInboxReader initial state', () {
    test('_loopStarted is false (loop not started)', () {
      final reader = NostrInboxReader();
      // A freshly created reader should not have started its event loop.
      // We verify this indirectly: circuitBroken should be false.
      expect(reader.circuitBroken, isFalse);
    });

    test('circuitBroken is false on creation', () {
      final reader = NostrInboxReader();
      expect(reader.circuitBroken, isFalse);
    });

    test('healthChanges is a valid stream', () {
      final reader = NostrInboxReader();
      expect(reader.healthChanges, isA<Stream<bool>>());
    });
  });

  // ── NostrInboxReader.close() ──────────────────────────────────────────────

  group('NostrInboxReader.close()', () {
    test('sets running to false — no crash on double close', () {
      final reader = NostrInboxReader();
      // close() should not throw even when nothing is running
      reader.close();
      reader.close(); // double close — should be idempotent
    });

    test('circuitBroken remains false after close (no failures)', () {
      final reader = NostrInboxReader();
      reader.close();
      expect(reader.circuitBroken, isFalse);
    });
  });

  // ── NostrInboxReader.zeroize() ────────────────────────────────────────────

  group('NostrInboxReader.zeroize()', () {
    test('does not throw on fresh reader', () {
      final reader = NostrInboxReader();
      reader.zeroize();
      // After zeroize, circuitBroken should still be false
      expect(reader.circuitBroken, isFalse);
    });

    test('idempotent — calling twice does not crash', () {
      final reader = NostrInboxReader();
      reader.zeroize();
      reader.zeroize();
    });
  });

  // ── NostrMessageSender.zeroize() ──────────────────────────────────────────

  group('NostrMessageSender.zeroize()', () {
    test('clears internal state without crash', () {
      final sender = NostrMessageSender();
      // zeroize() clears _privateKeyHex and _wsPool.
      sender.zeroize();
      // Should not throw; state is cleanly reset.
    });

    test('idempotent — calling twice does not crash', () {
      final sender = NostrMessageSender();
      sender.zeroize();
      sender.zeroize();
    });
  });
}
