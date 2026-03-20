import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/waku_signal_crypto.dart';

void main() {
  group('Waku signal key derivation', () {
    test('is deterministic', () {
      final k1 = deriveWakuSignalKey('alice', 'bob');
      final k2 = deriveWakuSignalKey('alice', 'bob');
      expect(k1, equals(k2));
    });

    test('is symmetric (A,B == B,A)', () {
      final k1 = deriveWakuSignalKey('alice', 'bob');
      final k2 = deriveWakuSignalKey('bob', 'alice');
      expect(k1, equals(k2));
    });

    test('different pairs produce different keys', () {
      final k1 = deriveWakuSignalKey('alice', 'bob');
      final k2 = deriveWakuSignalKey('alice', 'carol');
      expect(k1, isNot(equals(k2)));
    });

    test('produces 32-byte key', () {
      final k = deriveWakuSignalKey('sender', 'receiver');
      expect(k.length, equals(32));
    });
  });

  group('Waku signal encrypt/decrypt', () {
    test('round-trip encryption', () async {
      const json = '{"type":"typing","senderId":"alice","roomId":"r1","payload":{}}';
      final enc = await encryptWakuSignal(json, 'alice', 'bob');
      final dec = await decryptWakuSignal(enc, 'alice', 'bob');
      expect(dec, equals(json));
    });

    test('symmetric decryption (sender/recipient order)', () async {
      const json = '{"type":"heartbeat"}';
      final enc = await encryptWakuSignal(json, 'alice', 'bob');
      // Decrypt with reversed order should work (key is symmetric)
      final dec = await decryptWakuSignal(enc, 'bob', 'alice');
      expect(dec, equals(json));
    });

    test('wrong recipient fails to decrypt', () async {
      const json = '{"type":"typing"}';
      final enc = await encryptWakuSignal(json, 'alice', 'bob');
      final dec = await decryptWakuSignal(enc, 'alice', 'carol');
      expect(dec, isNull);
    });

    test('handles unicode content', () async {
      const json = '{"type":"edit","payload":{"text":"Привет 🌍"}}';
      final enc = await encryptWakuSignal(json, 'user1', 'user2');
      final dec = await decryptWakuSignal(enc, 'user1', 'user2');
      expect(dec, equals(json));
    });

    test('tampered ciphertext fails', () async {
      final enc = await encryptWakuSignal('{"type":"test"}', 'a', 'b');
      final raw = Uint8List.fromList(base64.decode(enc)); // mutable copy
      raw[15] ^= 0xFF; // tamper with ciphertext
      final dec = await decryptWakuSignal(base64.encode(raw), 'a', 'b');
      expect(dec, isNull);
    });

    test('too-short payload returns null', () async {
      final dec = await decryptWakuSignal(base64.encode([1, 2, 3]), 'a', 'b');
      expect(dec, isNull);
    });

    test('each encryption produces different ciphertext (random nonce)', () async {
      const json = '{"type":"typing"}';
      final enc1 = await encryptWakuSignal(json, 'a', 'b');
      final enc2 = await encryptWakuSignal(json, 'a', 'b');
      expect(enc1, isNot(equals(enc2)));
    });
  });
}
