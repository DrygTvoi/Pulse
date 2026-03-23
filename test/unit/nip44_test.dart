import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/nip44_service.dart';
import 'package:pulse_messenger/services/nostr_event_builder.dart'
    show derivePubkeyHex;
import 'package:pulse_messenger/adapters/nostr_adapter.dart'
    show computeEcdhSecret;

/// Test keypairs (secp256k1 private keys).
const _privA =
    'b94f5374fce5edbc8e2a8697c15331677e6ebf0b000000000000000000000001';
const _privB =
    'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5';

String _pub(String priv) => derivePubkeyHex(priv);

void main() {
  // Clear replay nonce cache between tests to prevent cross-test interference
  setUp(() => clearNonceCache());

  group('NIP-44 padding', () {
    test('pads short text to minimum 32 bytes', () {
      final padded = nip44Pad('hi');
      expect(padded.length, equals(32));
      expect(padded[0], equals(0));
      expect(padded[1], equals(2));
    });

    test('pads to next power of 2', () {
      final text = 'A' * 40;
      final padded = nip44Pad(text);
      expect(padded.length, equals(64));
    });

    test('minimum pad size is 32', () {
      final padded = nip44Pad('x');
      expect(padded.length, greaterThanOrEqualTo(32));
    });

    test('rejects empty plaintext', () {
      expect(() => nip44Pad(''), throwsArgumentError);
    });

    test('30 bytes content → 32 padded', () {
      final padded = nip44Pad('A' * 30);
      expect(padded.length, equals(32));
    });

    test('31 bytes content → 64 padded (2 + 31 = 33 > 32)', () {
      final padded = nip44Pad('A' * 31);
      expect(padded.length, equals(64));
    });
  });

  group('NIP-44 unpad', () {
    test('round-trip pad/unpad', () {
      const text = 'Hello, NIP-44!';
      expect(nip44Unpad(nip44Pad(text)), equals(text));
    });

    test('rejects too-short data', () {
      expect(() => nip44Unpad(Uint8List(16)), throwsFormatException);
    });

    test('rejects invalid length prefix', () {
      final bad = Uint8List(32);
      bad[0] = 0xFF;
      bad[1] = 0xFF;
      expect(() => nip44Unpad(bad), throwsFormatException);
    });
  });

  group('NIP-44 conversation key', () {
    test('is deterministic', () {
      final sharedX = Uint8List.fromList(List.generate(32, (i) => i));
      expect(computeConversationKey(sharedX),
          equals(computeConversationKey(sharedX)));
    });

    test('produces 32 bytes', () {
      final key = computeConversationKey(
          Uint8List.fromList(List.generate(32, (i) => i + 42)));
      expect(key.length, equals(32));
    });

    test('is symmetric: A→B == B→A', () {
      final keyAB =
          computeConversationKey(computeEcdhSecret(_privA, _pub(_privB)));
      final keyBA =
          computeConversationKey(computeEcdhSecret(_privB, _pub(_privA)));
      expect(keyAB, equals(keyBA));
    });
  });

  group('NIP-44 message keys', () {
    test('derives 3 parts (32+24+32 bytes for XChaCha20)', () {
      final keys = deriveMessageKeys(
        Uint8List.fromList(List.generate(32, (i) => i)),
        Uint8List.fromList(List.generate(32, (i) => i + 100)),
      );
      expect(keys.chachaKey.length, equals(32));
      expect(keys.chachaNonce.length, equals(24));
      expect(keys.hmacKey.length, equals(32));
    });

    test('different nonces → different keys', () {
      final ck = Uint8List.fromList(List.generate(32, (i) => i));
      final k1 = deriveMessageKeys(ck, Uint8List.fromList(List.generate(32, (i) => i)));
      final k2 = deriveMessageKeys(ck, Uint8List.fromList(List.generate(32, (i) => i + 1)));
      expect(k1.chachaKey, isNot(equals(k2.chachaKey)));
    });
  });

  group('NIP-44 encrypt/decrypt', () {
    test('round-trip with raw shared secret', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      final enc = await nip44Encrypt(sx, 'Hello NIP-44!');
      expect(await nip44Decrypt(sx, enc), equals('Hello NIP-44!'));
    });

    test('round-trip with key wrappers', () async {
      const text = 'Test message with wrappers';
      final enc = await nip44EncryptWithKeys(_privA, _pub(_privB), text);
      final dec = await nip44DecryptWithKeys(_privB, _pub(_privA), enc);
      expect(dec, equals(text));
    });

    test('handles unicode', () async {
      const text = 'Привет мир! 🌍🔐';
      final enc = await nip44EncryptWithKeys(_privA, _pub(_privB), text);
      final dec = await nip44DecryptWithKeys(_privB, _pub(_privA), enc);
      expect(dec, equals(text));
    });

    test('payload starts with version byte 0x02', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      final enc = await nip44Encrypt(sx, 'test');
      expect(base64.decode(enc)[0], equals(2));
    });

    test('wrong key fails to decrypt', () async {
      const wrongPriv =
          '1111111111111111111111111111111111111111111111111111111111111111';
      final enc =
          await nip44EncryptWithKeys(_privA, _pub(_privB), 'secret');
      expect(
        () => nip44DecryptWithKeys(wrongPriv, _pub(_privB), enc),
        throwsFormatException,
      );
    });

    test('tampered MAC is rejected', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      final enc = await nip44Encrypt(sx, 'test');
      final raw = base64.decode(enc);
      raw[raw.length - 1] ^= 0xFF;
      expect(() => nip44Decrypt(sx, base64.encode(raw)), throwsFormatException);
    });

    test('unsupported version byte is rejected', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      final enc = await nip44Encrypt(sx, 'test');
      final raw = base64.decode(enc);
      raw[0] = 0x03;
      expect(() => nip44Decrypt(sx, base64.encode(raw)), throwsFormatException);
    });

    test('too-short payload is rejected', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      expect(
        () => nip44Decrypt(sx, base64.encode([0x02, 0, 0])),
        throwsFormatException,
      );
    });

    test('replay detection: same ciphertext rejected on second decrypt', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      final enc = await nip44Encrypt(sx, 'replay test');
      // First decrypt succeeds
      await nip44Decrypt(sx, enc);
      // Second decrypt with same nonce must be rejected
      await expectLater(() => nip44Decrypt(sx, enc), throwsFormatException);
    });

    test('different messages each decrypt exactly once', () async {
      final sx = computeEcdhSecret(_privA, _pub(_privB));
      final enc1 = await nip44Encrypt(sx, 'msg 1');
      final enc2 = await nip44Encrypt(sx, 'msg 2');
      // Both succeed first time
      expect(await nip44Decrypt(sx, enc1), equals('msg 1'));
      expect(await nip44Decrypt(sx, enc2), equals('msg 2'));
      // Replays rejected
      await expectLater(() => nip44Decrypt(sx, enc1), throwsFormatException);
      await expectLater(() => nip44Decrypt(sx, enc2), throwsFormatException);
    });
  });
}
