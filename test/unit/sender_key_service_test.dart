import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

// ──────────────────────────────────────────────────────────────────────────
// Pure-Dart tests for Sender Key group E2EE logic.
//
// We use InMemorySenderKeyStore (from libsignal_protocol_dart) to avoid
// SharedPreferences platform dependency. The tests exercise the same
// GroupSessionBuilder / GroupCipher API that SenderKeyService wraps.
// ──────────────────────────────────────────────────────────────────────────

/// Helper: creates a SenderKeyName for a participant in a group.
SenderKeyName _skn(String groupId, String name) =>
    SenderKeyName(groupId, SignalProtocolAddress(name, 1));

void main() {
  group('InMemorySenderKeyStore round-trip', () {
    test('store and load returns equivalent record', () async {
      final store = InMemorySenderKeyStore();
      final skn = _skn('group1', 'alice');

      // Create a distribution (which seeds the store).
      final builder = GroupSessionBuilder(store);
      final skdm = await builder.create(skn);

      // Load should return a non-empty record.
      final loaded = await store.loadSenderKey(skn);
      expect(loaded.isEmpty, isFalse);

      // Serialize → deserialize round-trip should produce a working record.
      final serialized = loaded.serialize();
      final restored = SenderKeyRecord.fromSerialized(serialized);
      expect(restored.isEmpty, isFalse);

      // The restored record should have the same keyId.
      final state = restored.getSenderKeyState();
      expect(state.keyId, equals(skdm.id));
    });

    test('load returns empty record for unknown name', () async {
      final store = InMemorySenderKeyStore();
      final record = await store.loadSenderKey(_skn('unknown', 'nobody'));
      expect(record.isEmpty, isTrue);
    });
  });

  group('Create + process distribution → encrypt → decrypt', () {
    test('Alice sends encrypted message to Bob', () async {
      final aliceStore = InMemorySenderKeyStore();
      final bobStore = InMemorySenderKeyStore();
      const groupId = 'test-group-1';

      // Alice creates distribution.
      final aliceBuilder = GroupSessionBuilder(aliceStore);
      final skdm = await aliceBuilder.create(_skn(groupId, 'alice'));

      // Bob processes Alice's distribution.
      final bobBuilder = GroupSessionBuilder(bobStore);
      await bobBuilder.process(_skn(groupId, 'alice'), skdm);

      // Alice encrypts.
      final aliceCipher = GroupCipher(aliceStore, _skn(groupId, 'alice'));
      final plaintext = Uint8List.fromList(utf8.encode('Hello, group!'));
      final ciphertext = await aliceCipher.encrypt(plaintext);

      // Bob decrypts.
      final bobCipher = GroupCipher(bobStore, _skn(groupId, 'alice'));
      final decrypted = await bobCipher.decrypt(ciphertext);

      expect(utf8.decode(decrypted), equals('Hello, group!'));
    });

    test('multiple messages decrypt in order', () async {
      final aliceStore = InMemorySenderKeyStore();
      final bobStore = InMemorySenderKeyStore();
      const groupId = 'multi-msg-group';

      final aliceBuilder = GroupSessionBuilder(aliceStore);
      final skdm = await aliceBuilder.create(_skn(groupId, 'alice'));

      final bobBuilder = GroupSessionBuilder(bobStore);
      await bobBuilder.process(_skn(groupId, 'alice'), skdm);

      final aliceCipher = GroupCipher(aliceStore, _skn(groupId, 'alice'));
      final bobCipher = GroupCipher(bobStore, _skn(groupId, 'alice'));

      for (int i = 0; i < 10; i++) {
        final plain = Uint8List.fromList(utf8.encode('Message #$i'));
        final ct = await aliceCipher.encrypt(plain);
        final pt = await bobCipher.decrypt(ct);
        expect(utf8.decode(pt), equals('Message #$i'));
      }
    });
  });

  group('3-member group (Alice, Bob, Charlie)', () {
    test('each member can encrypt and others can decrypt', () async {
      final aliceStore = InMemorySenderKeyStore();
      final bobStore = InMemorySenderKeyStore();
      final charlieStore = InMemorySenderKeyStore();
      const groupId = 'three-way';

      // Each member creates their own distribution.
      final aliceBuilder = GroupSessionBuilder(aliceStore);
      final aliceSkdm = await aliceBuilder.create(_skn(groupId, 'alice'));

      final bobBuilder = GroupSessionBuilder(bobStore);
      final bobSkdm = await bobBuilder.create(_skn(groupId, 'bob'));

      final charlieBuilder = GroupSessionBuilder(charlieStore);
      final charlieSkdm = await charlieBuilder.create(_skn(groupId, 'charlie'));

      // Distribute: each member processes the others' distributions.
      // Bob and Charlie get Alice's key.
      await GroupSessionBuilder(bobStore).process(_skn(groupId, 'alice'), aliceSkdm);
      await GroupSessionBuilder(charlieStore).process(_skn(groupId, 'alice'), aliceSkdm);
      // Alice and Charlie get Bob's key.
      await GroupSessionBuilder(aliceStore).process(_skn(groupId, 'bob'), bobSkdm);
      await GroupSessionBuilder(charlieStore).process(_skn(groupId, 'bob'), bobSkdm);
      // Alice and Bob get Charlie's key.
      await GroupSessionBuilder(aliceStore).process(_skn(groupId, 'charlie'), charlieSkdm);
      await GroupSessionBuilder(bobStore).process(_skn(groupId, 'charlie'), charlieSkdm);

      // Alice sends.
      final aliceCipher = GroupCipher(aliceStore, _skn(groupId, 'alice'));
      final ct1 = await aliceCipher.encrypt(Uint8List.fromList(utf8.encode('From Alice')));

      final bobDecAlice = GroupCipher(bobStore, _skn(groupId, 'alice'));
      final charlieDecAlice = GroupCipher(charlieStore, _skn(groupId, 'alice'));
      expect(utf8.decode(await bobDecAlice.decrypt(ct1)), 'From Alice');
      expect(utf8.decode(await charlieDecAlice.decrypt(ct1)), 'From Alice');

      // Bob sends.
      final bobCipher = GroupCipher(bobStore, _skn(groupId, 'bob'));
      final ct2 = await bobCipher.encrypt(Uint8List.fromList(utf8.encode('From Bob')));

      final aliceDecBob = GroupCipher(aliceStore, _skn(groupId, 'bob'));
      final charlieDecBob = GroupCipher(charlieStore, _skn(groupId, 'bob'));
      expect(utf8.decode(await aliceDecBob.decrypt(ct2)), 'From Bob');
      expect(utf8.decode(await charlieDecBob.decrypt(ct2)), 'From Bob');

      // Charlie sends.
      final charlieCipher = GroupCipher(charlieStore, _skn(groupId, 'charlie'));
      final ct3 = await charlieCipher.encrypt(Uint8List.fromList(utf8.encode('From Charlie')));

      final aliceDecCharlie = GroupCipher(aliceStore, _skn(groupId, 'charlie'));
      final bobDecCharlie = GroupCipher(bobStore, _skn(groupId, 'charlie'));
      expect(utf8.decode(await aliceDecCharlie.decrypt(ct3)), 'From Charlie');
      expect(utf8.decode(await bobDecCharlie.decrypt(ct3)), 'From Charlie');
    });
  });

  group('Key rotation on member removal', () {
    test('old key cannot decrypt messages after rotation', () async {
      final aliceStore = InMemorySenderKeyStore();
      final bobStore = InMemorySenderKeyStore();
      const groupId = 'rotation-test';

      // Initial setup.
      final aliceBuilder = GroupSessionBuilder(aliceStore);
      final skdm1 = await aliceBuilder.create(_skn(groupId, 'alice'));
      await GroupSessionBuilder(bobStore).process(_skn(groupId, 'alice'), skdm1);

      // Verify initial setup works.
      final cipher1 = GroupCipher(aliceStore, _skn(groupId, 'alice'));
      final ct1 = await cipher1.encrypt(Uint8List.fromList(utf8.encode('Before rotation')));
      final bobCipher1 = GroupCipher(bobStore, _skn(groupId, 'alice'));
      expect(utf8.decode(await bobCipher1.decrypt(ct1)), 'Before rotation');

      // Simulate rotation: Alice creates a fresh store entry.
      // Clear old record and create new distribution.
      final freshAliceStore = InMemorySenderKeyStore();
      final freshBuilder = GroupSessionBuilder(freshAliceStore);
      final skdm2 = await freshBuilder.create(_skn(groupId, 'alice'));

      // Bob processes new distribution.
      final freshBobStore = InMemorySenderKeyStore();
      await GroupSessionBuilder(freshBobStore).process(_skn(groupId, 'alice'), skdm2);

      // New messages can be decrypted with new key.
      final cipher2 = GroupCipher(freshAliceStore, _skn(groupId, 'alice'));
      final ct2 = await cipher2.encrypt(Uint8List.fromList(utf8.encode('After rotation')));
      final bobCipher2 = GroupCipher(freshBobStore, _skn(groupId, 'alice'));
      expect(utf8.decode(await bobCipher2.decrypt(ct2)), 'After rotation');

      // Old Bob store cannot decrypt new messages (different key).
      final oldBobCipher = GroupCipher(bobStore, _skn(groupId, 'alice'));
      expect(
        () async => oldBobCipher.decrypt(ct2),
        throwsA(anything),
        reason: 'Old key should not decrypt messages encrypted with rotated key',
      );
    });
  });

  group('Decrypt fails without distribution', () {
    test('throws when no distribution has been processed', () async {
      final store = InMemorySenderKeyStore();
      final cipher = GroupCipher(store, _skn('no-dist-group', 'alice'));

      // Create a dummy ciphertext from a proper session.
      final senderStore = InMemorySenderKeyStore();
      final builder = GroupSessionBuilder(senderStore);
      await builder.create(_skn('no-dist-group', 'alice'));
      final senderCipher = GroupCipher(senderStore, _skn('no-dist-group', 'alice'));
      final ct = await senderCipher.encrypt(Uint8List.fromList(utf8.encode('Secret')));

      // Receiver without distribution should fail.
      expect(
        () async => cipher.decrypt(ct),
        throwsA(anything),
        reason: 'Decrypt should fail without processing sender key distribution',
      );
    });
  });

  group('Out-of-order messages', () {
    test('messages delivered out of order can still be decrypted', () async {
      final aliceStore = InMemorySenderKeyStore();
      final bobStore = InMemorySenderKeyStore();
      const groupId = 'ooo-group';

      final builder = GroupSessionBuilder(aliceStore);
      final skdm = await builder.create(_skn(groupId, 'alice'));
      await GroupSessionBuilder(bobStore).process(_skn(groupId, 'alice'), skdm);

      final aliceCipher = GroupCipher(aliceStore, _skn(groupId, 'alice'));

      // Encrypt 5 messages.
      final ciphertexts = <Uint8List>[];
      for (int i = 0; i < 5; i++) {
        ciphertexts.add(
            await aliceCipher.encrypt(Uint8List.fromList(utf8.encode('Msg $i'))));
      }

      // Bob decrypts in reverse order (out of order).
      final bobCipher = GroupCipher(bobStore, _skn(groupId, 'alice'));

      // Decrypt msg 4 first (future message).
      final pt4 = await bobCipher.decrypt(ciphertexts[4]);
      expect(utf8.decode(pt4), 'Msg 4');

      // Decrypt msg 2.
      final pt2 = await bobCipher.decrypt(ciphertexts[2]);
      expect(utf8.decode(pt2), 'Msg 2');

      // Decrypt msg 0.
      final pt0 = await bobCipher.decrypt(ciphertexts[0]);
      expect(utf8.decode(pt0), 'Msg 0');

      // Decrypt msg 1.
      final pt1 = await bobCipher.decrypt(ciphertexts[1]);
      expect(utf8.decode(pt1), 'Msg 1');

      // Decrypt msg 3.
      final pt3 = await bobCipher.decrypt(ciphertexts[3]);
      expect(utf8.decode(pt3), 'Msg 3');
    });
  });

  group('SenderKeyDistributionMessageWrapper serialization', () {
    test('serialize → fromSerialized round-trip', () async {
      final store = InMemorySenderKeyStore();
      final builder = GroupSessionBuilder(store);
      final skdm = await builder.create(_skn('serde-group', 'alice'));

      final bytes = skdm.serialize();
      final restored = SenderKeyDistributionMessageWrapper.fromSerialized(bytes);

      expect(restored.id, equals(skdm.id));
      expect(restored.iteration, equals(skdm.iteration));
      expect(restored.chainKey, equals(skdm.chainKey));
    });
  });

  group('Same ciphertext sent to multiple members', () {
    test('identical ciphertext is decryptable by all members with the distribution', () async {
      final aliceStore = InMemorySenderKeyStore();
      final bobStore = InMemorySenderKeyStore();
      final charlieStore = InMemorySenderKeyStore();
      const groupId = 'broadcast-group';

      final builder = GroupSessionBuilder(aliceStore);
      final skdm = await builder.create(_skn(groupId, 'alice'));

      await GroupSessionBuilder(bobStore).process(_skn(groupId, 'alice'), skdm);
      await GroupSessionBuilder(charlieStore).process(_skn(groupId, 'alice'), skdm);

      // Alice encrypts once.
      final aliceCipher = GroupCipher(aliceStore, _skn(groupId, 'alice'));
      final ct = await aliceCipher.encrypt(
          Uint8List.fromList(utf8.encode('Broadcast message')));

      // Both Bob and Charlie can decrypt the same ciphertext.
      final bobCipher = GroupCipher(bobStore, _skn(groupId, 'alice'));
      final charlieCipher = GroupCipher(charlieStore, _skn(groupId, 'alice'));

      expect(utf8.decode(await bobCipher.decrypt(ct)), 'Broadcast message');
      expect(utf8.decode(await charlieCipher.decrypt(ct)), 'Broadcast message');
    });
  });
}
