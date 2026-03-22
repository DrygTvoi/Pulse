import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart reimplementation of the testable logic from OxenKeyService.
/// The real service depends on FlutterSecureStorage (platform channels),
/// so we extract and test the cryptographic derivation logic directly.

/// Derive a Session ID from a 32-byte seed, identical to OxenKeyService.
Future<String> deriveSessionId(List<int> seed) async {
  final x25519 = X25519();
  final kp = await x25519.newKeyPairFromSeed(seed);
  final pub = await kp.extractPublicKey();
  return '05${hex.encode(pub.bytes)}';
}

/// Ed25519 sign [message] using the given seed, identical to OxenKeyService.sign.
Future<List<int>> signWithSeed(List<int> seed, List<int> message) async {
  final ed25519 = Ed25519();
  final kp = await ed25519.newKeyPairFromSeed(seed);
  final sig = await ed25519.sign(message, keyPair: kp);
  return sig.bytes;
}

/// Extract the Ed25519 public key from a seed.
Future<List<int>> ed25519PubFromSeed(List<int> seed) async {
  final ed25519 = Ed25519();
  final kp = await ed25519.newKeyPairFromSeed(seed);
  final pub = await kp.extractPublicKey();
  return pub.bytes;
}

void main() {
  // A fixed 32-byte seed for deterministic tests.
  final fixedSeed = Uint8List.fromList(List.generate(32, (i) => i));
  // A different fixed seed.
  final otherSeed = Uint8List.fromList(List.generate(32, (i) => 255 - i));
  // All-zeros seed.
  final zeroSeed = Uint8List(32);

  group('Session ID format', () {
    test('Session ID is exactly 66 hex characters', () async {
      final sid = await deriveSessionId(fixedSeed);
      expect(sid.length, equals(66));
    });

    test('Session ID starts with "05" prefix', () async {
      final sid = await deriveSessionId(fixedSeed);
      expect(sid.substring(0, 2), equals('05'));
    });

    test('Session ID body (after "05") is valid lowercase hex', () async {
      final sid = await deriveSessionId(fixedSeed);
      final body = sid.substring(2);
      expect(body, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('Session ID body decodes to 32 bytes (X25519 public key)', () async {
      final sid = await deriveSessionId(fixedSeed);
      final pubBytes = hex.decode(sid.substring(2));
      expect(pubBytes.length, equals(32));
    });
  });

  group('Determinism', () {
    test('same seed always produces the same Session ID', () async {
      final sid1 = await deriveSessionId(fixedSeed);
      final sid2 = await deriveSessionId(Uint8List.fromList(fixedSeed));
      expect(sid1, equals(sid2));
    });

    test('different seeds produce different Session IDs', () async {
      final sid1 = await deriveSessionId(fixedSeed);
      final sid2 = await deriveSessionId(otherSeed);
      expect(sid1, isNot(equals(sid2)));
    });

    test('all-zero seed produces a valid Session ID', () async {
      final sid = await deriveSessionId(zeroSeed);
      expect(sid.length, equals(66));
      expect(sid.startsWith('05'), isTrue);
    });
  });

  group('Seed constraints', () {
    test('seed hex representation is 64 characters', () {
      final seedHex = hex.encode(fixedSeed);
      expect(seedHex.length, equals(64));
    });

    test('seed is exactly 32 bytes', () {
      expect(fixedSeed.length, equals(32));
    });
  });

  group('Ed25519 signing', () {
    test('sign produces a 64-byte signature', () async {
      final message = [1, 2, 3, 4, 5];
      final sig = await signWithSeed(fixedSeed, message);
      expect(sig.length, equals(64));
    });

    test('same seed + same message produces same signature', () async {
      final message = [72, 101, 108, 108, 111]; // "Hello"
      final sig1 = await signWithSeed(fixedSeed, message);
      final sig2 = await signWithSeed(Uint8List.fromList(fixedSeed), message);
      expect(sig1, equals(sig2));
    });

    test('different messages produce different signatures', () async {
      final msg1 = [1, 2, 3];
      final msg2 = [4, 5, 6];
      final sig1 = await signWithSeed(fixedSeed, msg1);
      final sig2 = await signWithSeed(fixedSeed, msg2);
      expect(sig1, isNot(equals(sig2)));
    });

    test('signature is verifiable with the corresponding public key', () async {
      final message = [10, 20, 30, 40, 50];
      final sigBytes = await signWithSeed(fixedSeed, message);
      final pubBytes = await ed25519PubFromSeed(fixedSeed);

      final ed25519 = Ed25519();
      final publicKey = SimplePublicKey(pubBytes, type: KeyPairType.ed25519);
      final signature = Signature(sigBytes, publicKey: publicKey);

      // verify should not throw
      final valid = await ed25519.verify(message, signature: signature);
      expect(valid, isTrue);
    });

    test('signature fails verification with wrong public key', () async {
      final message = [10, 20, 30, 40, 50];
      final sigBytes = await signWithSeed(fixedSeed, message);
      final wrongPubBytes = await ed25519PubFromSeed(otherSeed);

      final ed25519 = Ed25519();
      final wrongPub =
          SimplePublicKey(wrongPubBytes, type: KeyPairType.ed25519);
      final signature = Signature(sigBytes, publicKey: wrongPub);

      final valid = await ed25519.verify(message, signature: signature);
      expect(valid, isFalse);
    });
  });

  group('X25519 vs Ed25519 independence', () {
    test(
        'X25519 public key and Ed25519 public key from same seed are different',
        () async {
      // X25519 public key (from Session ID derivation)
      final sid = await deriveSessionId(fixedSeed);
      final x25519PubHex = sid.substring(2);

      // Ed25519 public key
      final ed25519Pub = await ed25519PubFromSeed(fixedSeed);
      final ed25519PubHex = hex.encode(ed25519Pub);

      // They use different curve operations, so the public keys differ
      expect(x25519PubHex, isNot(equals(ed25519PubHex)));
    });
  });
}
