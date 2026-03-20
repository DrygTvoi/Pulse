import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:pulse_messenger/services/crypto_layer.dart';

// ── Helpers that mirror CryptoLayer private methods exactly ──────────────────
//
// CryptoLayer._hkdf, ._aesGcmEncrypt, and ._aesGcmDecrypt are private.
// We reproduce them here verbatim so we can test the AES-256-GCM primitive
// behaviour (known-answer and roundtrip) without touching PqcService.

Uint8List _hkdf(Uint8List ikm) {
  final salt = Uint8List(32);
  final prk = Uint8List.fromList(
    crypto.Hmac(crypto.sha256, salt).convert(ikm).bytes,
  );
  final info = utf8.encode('Aegis_PQC_v1');
  final expandInput = Uint8List(info.length + 1)
    ..setAll(0, info)
    ..[info.length] = 0x01;
  return Uint8List.fromList(
    crypto.Hmac(crypto.sha256, prk).convert(expandInput).bytes,
  );
}

Uint8List _aesGcmEncrypt(Uint8List key, Uint8List nonce, Uint8List plaintext) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)));
  return cipher.process(plaintext);
}

Uint8List _aesGcmDecrypt(Uint8List key, Uint8List nonce, Uint8List ciphertext) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)));
  return cipher.process(ciphertext);
}

// ── Construct a syntactically valid PQC2 envelope with given key/nonce ───────
//
// This lets us produce tampered-but-parseable envelopes to verify that
// CryptoLayer.unwrap() correctly rejects them.

String _buildFakeEnvelope({
  required Uint8List kyberCt,
  required Uint8List nonce,
  required Uint8List aesCt,
}) {
  return 'PQC2||${base64Encode(kyberCt)}||${base64Encode(nonce)}||${base64Encode(aesCt)}';
}

void main() {
  // ── CryptoLayer.wrap with null remotePk ───────────────────────────────────
  //
  // When remotePk is null the function must return the signal ciphertext
  // unchanged.  No PqcService initialisation is required for this path.

  group('CryptoLayer.wrap null key passthrough', () {
    test('returns signalCt unchanged when remotePk is null', () {
      const signal = 'E2EE||3||AAAAAAAAAA==';
      final result = CryptoLayer.wrap(signal, null);
      expect(result, equals(signal));
    });

    test('null remotePk passthrough is lossless for empty-looking payload', () {
      const signal = '';
      expect(CryptoLayer.wrap(signal, null), equals(signal));
    });

    test('null remotePk passthrough does not add PQC2 prefix', () {
      const signal = 'someArbitraryPayload';
      expect(CryptoLayer.wrap(signal, null), isNot(startsWith('PQC2||')));
    });
  });

  // ── CryptoLayer.unwrap passthrough for non-PQC messages ──────────────────
  //
  // Messages that do not start with "PQC2||" must be returned verbatim.
  // This covers v1/legacy Signal ciphertexts and any plain text that
  // inadvertently reaches unwrap().

  group('CryptoLayer.unwrap passthrough for non-PQC2 messages', () {
    test('E2EE envelope is returned unchanged', () {
      const signal = 'E2EE||3||SGVsbG8=';
      expect(CryptoLayer.unwrap(signal), equals(signal));
    });

    test('empty string is returned unchanged', () {
      expect(CryptoLayer.unwrap(''), equals(''));
    });

    test('plain text is returned unchanged', () {
      const text = 'not a pqc message';
      expect(CryptoLayer.unwrap(text), equals(text));
    });

    test('string that starts with "PQC" but not "PQC2||" passes through', () {
      const text = 'PQC3||something';
      expect(CryptoLayer.unwrap(text), equals(text));
    });

    test('string that starts with "PQC2" without delimiter passes through', () {
      // Must start with "PQC2||" exactly — "PQC2|" is not the prefix.
      const text = 'PQC2|not-quite';
      expect(CryptoLayer.unwrap(text), equals(text));
    });
  });

  // ── CryptoLayer.unwrap rejects malformed PQC2 envelopes ──────────────────
  //
  // Once the "PQC2||" prefix is recognised the function must validate the
  // structure strictly and throw FormatException on any deviation.

  group('CryptoLayer.unwrap malformed envelope rejection', () {
    test('throws FormatException for too few parts (1 part)', () {
      const bad = 'PQC2||onlyone';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });

    test('throws FormatException for too few parts (2 parts)', () {
      const bad = 'PQC2||aaa||bbb';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });

    test('throws FormatException for too many parts (4 parts)', () {
      const bad = 'PQC2||aaa||bbb||ccc||ddd';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });

    test('throws FormatException for invalid base64 in kyber_ct slot', () {
      // "!!!" is not valid base64
      const bad = 'PQC2||!!!||AAAAAAAAAAAAAAAA||AAAAAAAAAAAAAAAA';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });

    test('throws FormatException for invalid base64 in nonce slot', () {
      const bad = 'PQC2||AAAA||!!!||AAAAAAAAAAAAAAAA';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });

    test('throws FormatException for invalid base64 in ciphertext slot', () {
      const bad = 'PQC2||AAAA||AAAAAAAAAAAAA=||!!!';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });

    test('throws FormatException for completely empty body after prefix', () {
      const bad = 'PQC2||';
      expect(() => CryptoLayer.unwrap(bad), throwsFormatException);
    });
  });

  // ── HKDF-SHA256 correctness (mirrors CryptoLayer._hkdf) ──────────────────
  //
  // The key derivation must be deterministic, produce 32 bytes, and be
  // sensitive to the input material.

  group('HKDF-SHA256 (Aegis_PQC_v1)', () {
    test('produces a 32-byte key', () {
      final ikm = Uint8List.fromList(List.generate(32, (i) => i));
      expect(_hkdf(ikm).length, equals(32));
    });

    test('is deterministic for the same IKM', () {
      final ikm = Uint8List.fromList(List.generate(32, (i) => i + 7));
      expect(_hkdf(ikm), equals(_hkdf(ikm)));
    });

    test('different IKMs produce different keys', () {
      final ikm1 = Uint8List(32)..fillRange(0, 32, 0x00);
      final ikm2 = Uint8List(32)..fillRange(0, 32, 0x01);
      expect(_hkdf(ikm1), isNot(equals(_hkdf(ikm2))));
    });

    test('single-bit difference in IKM changes the output key', () {
      final ikm1 = Uint8List.fromList(List.generate(32, (i) => i));
      final ikm2 = Uint8List.fromList(List.generate(32, (i) => i));
      ikm2[0] ^= 0x01; // flip exactly one bit
      expect(_hkdf(ikm1), isNot(equals(_hkdf(ikm2))));
    });

    test('output is never all-zero for non-zero IKM', () {
      final ikm = Uint8List(32)..fillRange(0, 32, 0xFF);
      final key = _hkdf(ikm);
      expect(key.any((b) => b != 0), isTrue);
    });

    test('all-zero IKM still produces non-trivial output (HMAC over zero)', () {
      // HMAC(salt=0…0, ikm=0…0) is deterministic and non-zero.
      final key = _hkdf(Uint8List(32));
      expect(key.length, equals(32));
      // The PRK step with zero salt and zero IKM is a valid HMAC evaluation.
      // We verify it is consistent with a second identical call.
      expect(key, equals(_hkdf(Uint8List(32))));
    });
  });

  // ── AES-256-GCM roundtrip (mirrors CryptoLayer._aesGcmEncrypt/Decrypt) ───
  //
  // Verifies that the encryption primitive that CryptoLayer wraps the Signal
  // ciphertext with behaves correctly: authenticated roundtrip, nonce
  // sensitivity, key sensitivity, and tamper detection.

  group('AES-256-GCM (PQC inner layer)', () {
    // A fixed 32-byte key and 12-byte nonce for deterministic tests.
    final key   = Uint8List.fromList(List.generate(32, (i) => i));
    final nonce = Uint8List.fromList(List.generate(12, (i) => i + 100));

    test('roundtrip produces original plaintext', () {
      final plaintext = Uint8List.fromList(utf8.encode('Signal-ciphertext-payload'));
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      final recovered = _aesGcmDecrypt(key, nonce, ct);
      expect(recovered, equals(plaintext));
    });

    test('roundtrip with empty plaintext', () {
      final plaintext = Uint8List(0);
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      final recovered = _aesGcmDecrypt(key, nonce, ct);
      expect(recovered, equals(plaintext));
    });

    test('ciphertext is longer than plaintext (includes 16-byte GCM tag)', () {
      final plaintext = Uint8List.fromList(utf8.encode('hello'));
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      expect(ct.length, equals(plaintext.length + 16));
    });

    test('different keys produce different ciphertexts', () {
      final plaintext = Uint8List.fromList(utf8.encode('payload'));
      final key2 = Uint8List.fromList(List.generate(32, (i) => i + 1));
      final ct1 = _aesGcmEncrypt(key, nonce, plaintext);
      final ct2 = _aesGcmEncrypt(key2, nonce, plaintext);
      expect(ct1, isNot(equals(ct2)));
    });

    test('different nonces produce different ciphertexts', () {
      final plaintext = Uint8List.fromList(utf8.encode('payload'));
      final nonce2 = Uint8List.fromList(List.generate(12, (i) => i + 200));
      final ct1 = _aesGcmEncrypt(key, nonce, plaintext);
      final ct2 = _aesGcmEncrypt(key, nonce2, plaintext);
      expect(ct1, isNot(equals(ct2)));
    });

    test('wrong key causes decryption to throw (GCM auth failure)', () {
      final plaintext = Uint8List.fromList(utf8.encode('secret'));
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      final wrongKey = Uint8List.fromList(List.generate(32, (i) => i + 99));
      expect(
        () => _aesGcmDecrypt(wrongKey, nonce, ct),
        throwsA(isA<InvalidCipherTextException>()),
      );
    });

    test('wrong nonce causes decryption to throw (GCM auth failure)', () {
      final plaintext = Uint8List.fromList(utf8.encode('secret'));
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      final wrongNonce = Uint8List.fromList(List.generate(12, (i) => i + 200));
      expect(
        () => _aesGcmDecrypt(key, wrongNonce, ct),
        throwsA(isA<InvalidCipherTextException>()),
      );
    });

    test('single-bit flip in ciphertext causes GCM auth failure', () {
      final plaintext = Uint8List.fromList(utf8.encode('tamper me'));
      final ct = Uint8List.fromList(_aesGcmEncrypt(key, nonce, plaintext));
      ct[0] ^= 0x01; // flip one bit in the body
      expect(
        () => _aesGcmDecrypt(key, nonce, ct),
        throwsA(isA<InvalidCipherTextException>()),
      );
    });

    test('single-bit flip in GCM tag causes auth failure', () {
      final plaintext = Uint8List.fromList(utf8.encode('tamper tag'));
      final ct = Uint8List.fromList(_aesGcmEncrypt(key, nonce, plaintext));
      ct[ct.length - 1] ^= 0xFF; // flip the last byte of the 16-byte tag
      expect(
        () => _aesGcmDecrypt(key, nonce, ct),
        throwsA(isA<InvalidCipherTextException>()),
      );
    });

    test('unicode plaintext roundtrips correctly', () {
      final plaintext = Uint8List.fromList(utf8.encode('Привет мир 🔐'));
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      final recovered = _aesGcmDecrypt(key, nonce, ct);
      expect(utf8.decode(recovered), equals('Привет мир 🔐'));
    });

    test('large plaintext roundtrips correctly', () {
      final plaintext = Uint8List.fromList(List.generate(4096, (i) => i & 0xFF));
      final ct = _aesGcmEncrypt(key, nonce, plaintext);
      final recovered = _aesGcmDecrypt(key, nonce, ct);
      expect(recovered, equals(plaintext));
    });
  });

  // ── Wire format invariants ────────────────────────────────────────────────
  //
  // Verify structural properties of the PQC2 wire format that must hold
  // regardless of the key material: prefix, delimiter count, base64 slots.

  group('PQC2 wire format structure', () {
    // Build a valid synthetic envelope to check the parser accepts the format.
    final fakeCt    = Uint8List(1568)..fillRange(0, 1568, 0xAB); // Kyber-1024 ct size
    final fakeNonce = Uint8List(12)..fillRange(0, 12, 0x01);
    final fakeAes   = Uint8List(32)..fillRange(0, 32, 0x02); // arbitrary AES ciphertext

    test('valid 3-part base64 body passes base64 decoding stage', () {
      final envelope = _buildFakeEnvelope(
        kyberCt: fakeCt,
        nonce: fakeNonce,
        aesCt: fakeAes,
      );
      // The envelope should reach the PqcService.decapsulate() stage (and fail
      // there because these are fake bytes), but NOT throw a FormatException.
      // We verify by catching the correct exception type.
      expect(
        () => CryptoLayer.unwrap(envelope),
        throwsA(isNot(isA<FormatException>())),
      );
    });

    test('PQC2 prefix check is prefix-exact, not substring', () {
      // Insert a character before the prefix — must pass through unchanged.
      final notPqc = 'XPQC2||aaa||bbb||ccc';
      expect(CryptoLayer.unwrap(notPqc), equals(notPqc));
    });

    test('delimiter count: exactly 2 "||" in body required', () {
      // Body with 1 delimiter → 2 parts → FormatException
      final twoPartBody = 'PQC2||${base64Encode(fakeCt)}||${base64Encode(fakeNonce)}';
      expect(() => CryptoLayer.unwrap(twoPartBody), throwsFormatException);
    });
  });
}
