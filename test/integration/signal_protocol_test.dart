import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

/// Integration tests for the Signal Protocol double-ratchet layer.
///
/// Uses [InMemorySignalProtocolStore] from libsignal_protocol_dart directly —
/// no platform channels needed. This tests the same cryptographic library
/// that [SignalService] relies on end-to-end.
void main() {
  // Helpers to set up an in-memory Signal participant
  Future<
      ({
        InMemorySignalProtocolStore store,
        SignalProtocolAddress address,
        IdentityKeyPair idKey,
        int regId,
        PreKeyRecord preKey,
        SignedPreKeyRecord signedPreKey,
      })> makeParticipant(String name) async {
    final idKey = generateIdentityKeyPair();
    final regId = generateRegistrationId(false);
    final store = InMemorySignalProtocolStore(idKey, regId);
    final address = SignalProtocolAddress(name, 1);

    final preKey = generatePreKeys(0, 1).first;
    await store.storePreKey(preKey.id, preKey);

    final signedPreKey = generateSignedPreKey(idKey, 0);
    await store.storeSignedPreKey(signedPreKey.id, signedPreKey);

    return (
      store: store,
      address: address,
      idKey: idKey,
      regId: regId,
      preKey: preKey,
      signedPreKey: signedPreKey,
    );
  }

  PreKeyBundle makeBundle(
    int regId,
    PreKeyRecord preKey,
    SignedPreKeyRecord signedPreKey,
    IdentityKeyPair idKey,
  ) =>
      PreKeyBundle(
        regId,
        1,
        preKey.id,
        preKey.getKeyPair().publicKey,
        signedPreKey.id,
        signedPreKey.getKeyPair().publicKey,
        signedPreKey.signature,
        idKey.getPublicKey(),
      );

  group('Signal Protocol — session establishment', () {
    test('Alice sends first message to Bob (PreKey message)', () async {
      final alice = await makeParticipant('alice');
      final bob = await makeParticipant('bob');

      // Alice builds session with Bob's bundle
      final bobBundle =
          makeBundle(bob.regId, bob.preKey, bob.signedPreKey, bob.idKey);
      await SessionBuilder(
        alice.store, alice.store, alice.store, alice.store, bob.address,
      ).processPreKeyBundle(bobBundle);

      // Alice encrypts
      const plaintext = 'Hello Bob!';
      final aliceCipher = SessionCipher(
          alice.store, alice.store, alice.store, alice.store, bob.address);
      final ciphertext = await aliceCipher.encrypt(
          Uint8List.fromList(plaintext.codeUnits));

      expect(ciphertext.getType(), equals(CiphertextMessage.prekeyType));

      // Bob decrypts
      final bobCipher = SessionCipher(
          bob.store, bob.store, bob.store, bob.store, alice.address);
      final decrypted = await bobCipher.decrypt(
          PreKeySignalMessage(ciphertext.serialize()));

      expect(String.fromCharCodes(decrypted), equals(plaintext));
    });

    test('subsequent messages after Bob replies use WhisperMessage (ratchet)', () async {
      final alice = await makeParticipant('alice');
      final bob = await makeParticipant('bob');

      final bobBundle =
          makeBundle(bob.regId, bob.preKey, bob.signedPreKey, bob.idKey);
      await SessionBuilder(
        alice.store, alice.store, alice.store, alice.store, bob.address,
      ).processPreKeyBundle(bobBundle);

      final aliceCipher = SessionCipher(
          alice.store, alice.store, alice.store, alice.store, bob.address);
      final bobCipher = SessionCipher(
          bob.store, bob.store, bob.store, bob.store, alice.address);

      // First message from Alice (PreKey bootstrap)
      final first = await aliceCipher
          .encrypt(Uint8List.fromList('first'.codeUnits));
      expect(first.getType(), equals(CiphertextMessage.prekeyType));
      await bobCipher.decrypt(PreKeySignalMessage(first.serialize()));

      // Bob replies — this creates his outgoing session
      final bobReply = await bobCipher
          .encrypt(Uint8List.fromList('reply'.codeUnits));
      await aliceCipher.decryptFromSignal(
          SignalMessage.fromSerialized(bobReply.serialize()));

      // Alice's next message — ratchet has advanced, should be WhisperMessage
      final second = await aliceCipher
          .encrypt(Uint8List.fromList('second'.codeUnits));
      expect(second.getType(), equals(CiphertextMessage.whisperType));

      final decrypted2 = await bobCipher
          .decryptFromSignal(SignalMessage.fromSerialized(second.serialize()));
      expect(String.fromCharCodes(decrypted2), equals('second'));
    });

    test('bidirectional exchange — ratchet advances in both directions',
        () async {
      final alice = await makeParticipant('alice');
      final bob = await makeParticipant('bob');

      final bobBundle =
          makeBundle(bob.regId, bob.preKey, bob.signedPreKey, bob.idKey);
      await SessionBuilder(
        alice.store, alice.store, alice.store, alice.store, bob.address,
      ).processPreKeyBundle(bobBundle);

      final aliceCipher = SessionCipher(
          alice.store, alice.store, alice.store, alice.store, bob.address);
      final bobCipher = SessionCipher(
          bob.store, bob.store, bob.store, bob.store, alice.address);

      // Alice → Bob (ASCII only — codeUnits is safe for ASCII)
      final ct1 = await aliceCipher
          .encrypt(Uint8List.fromList('A2B msg1'.codeUnits));
      await bobCipher.decrypt(PreKeySignalMessage(ct1.serialize()));

      // Bob → Alice (Bob now has a session after decrypting PreKey message)
      final ct2 = await bobCipher
          .encrypt(Uint8List.fromList('B2A reply'.codeUnits));
      final decryptedReply = await aliceCipher
          .decryptFromSignal(SignalMessage.fromSerialized(ct2.serialize()));
      expect(String.fromCharCodes(decryptedReply), equals('B2A reply'));

      // Alice → Bob again (ratchet advances)
      final ct3 = await aliceCipher
          .encrypt(Uint8List.fromList('A2B msg2'.codeUnits));
      final decrypted3 = await bobCipher
          .decryptFromSignal(SignalMessage.fromSerialized(ct3.serialize()));
      expect(String.fromCharCodes(decrypted3), equals('A2B msg2'));
    });

    test('encrypts and decrypts unicode / special characters (UTF-8)', () async {
      final alice = await makeParticipant('alice');
      final bob = await makeParticipant('bob');

      final bobBundle =
          makeBundle(bob.regId, bob.preKey, bob.signedPreKey, bob.idKey);
      await SessionBuilder(
        alice.store, alice.store, alice.store, alice.store, bob.address,
      ).processPreKeyBundle(bobBundle);

      final aliceCipher = SessionCipher(
          alice.store, alice.store, alice.store, alice.store, bob.address);
      final bobCipher = SessionCipher(
          bob.store, bob.store, bob.store, bob.store, alice.address);

      // Use UTF-8 encoding — mirrors the fix applied to SignalService.encryptMessage.
      const text = 'Hello! Привет! 🔐 مرحبا 你好';
      final ct = await aliceCipher.encrypt(Uint8List.fromList(utf8.encode(text)));
      final decrypted =
          await bobCipher.decrypt(PreKeySignalMessage(ct.serialize()));
      expect(utf8.decode(decrypted), equals(text));
    });

    test('different participants cannot read each other messages', () async {
      final alice = await makeParticipant('alice');
      final bob = await makeParticipant('bob');
      final carol = await makeParticipant('carol');

      // Alice → Bob session
      final bobBundle =
          makeBundle(bob.regId, bob.preKey, bob.signedPreKey, bob.idKey);
      await SessionBuilder(
        alice.store, alice.store, alice.store, alice.store, bob.address,
      ).processPreKeyBundle(bobBundle);

      final aliceToBobCipher = SessionCipher(
          alice.store, alice.store, alice.store, alice.store, bob.address);
      final carolCipher = SessionCipher(
          carol.store, carol.store, carol.store, carol.store, alice.address);

      // Alice encrypts to Bob
      final ct = await aliceToBobCipher
          .encrypt(Uint8List.fromList('secret for bob'.codeUnits));

      // Carol (with no session) attempting to decrypt should throw
      expect(
        () async => await carolCipher
            .decrypt(PreKeySignalMessage(ct.serialize())),
        throwsA(anything),
      );
    });
  });
}
