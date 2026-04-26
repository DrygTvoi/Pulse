import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:pulse_messenger/models/message_envelope.dart';

// ─────────────────────────────────────────────────────────────────
// E2E integration tests — full message pipeline:
//   MessageEnvelope.wrap → Signal encrypt → FakeTransport → Signal decrypt → tryUnwrap
// Pure Dart, no plugins, no network.
// ─────────────────────────────────────────────────────────────────

/// In-memory message bus: send() pushes to recipient's mailbox stream.
class FakeTransport {
  final _mailboxes = <String, StreamController<String>>{};

  StreamController<String> _box(String address) =>
      _mailboxes.putIfAbsent(address, () => StreamController<String>.broadcast());

  void send(String recipientAddress, String ciphertext) {
    _box(recipientAddress).add(ciphertext);
  }

  Stream<String> inbox(String address) => _box(address).stream;

  void dispose() {
    for (final c in _mailboxes.values) {
      c.close();
    }
  }
}

/// One user's Signal state + transport binding.
class Participant {
  final String name;
  final String address;
  final InMemorySignalProtocolStore store;
  final SignalProtocolAddress signalAddress;
  final IdentityKeyPair idKey;
  final int regId;
  final PreKeyRecord preKey;
  final SignedPreKeyRecord signedPreKey;
  final FakeTransport transport;

  Participant._({
    required this.name,
    required this.address,
    required this.store,
    required this.signalAddress,
    required this.idKey,
    required this.regId,
    required this.preKey,
    required this.signedPreKey,
    required this.transport,
  });

  static Future<Participant> create(
      String name, String address, FakeTransport transport) async {
    final idKey = generateIdentityKeyPair();
    final regId = generateRegistrationId(false);
    final store = InMemorySignalProtocolStore(idKey, regId);
    final signalAddress = SignalProtocolAddress(name, 1);

    final preKey = generatePreKeys(0, 1).first;
    await store.storePreKey(preKey.id, preKey);

    final signedPreKey = generateSignedPreKey(idKey, 0);
    await store.storeSignedPreKey(signedPreKey.id, signedPreKey);

    return Participant._(
      name: name,
      address: address,
      store: store,
      signalAddress: signalAddress,
      idKey: idKey,
      regId: regId,
      preKey: preKey,
      signedPreKey: signedPreKey,
      transport: transport,
    );
  }

  PreKeyBundle getPublicBundle() => PreKeyBundle(
        regId,
        1,
        preKey.id,
        preKey.getKeyPair().publicKey,
        signedPreKey.id,
        signedPreKey.getKeyPair().publicKey,
        signedPreKey.signature,
        idKey.getPublicKey(),
      );

  Future<void> buildSessionWith(Participant remote) async {
    await SessionBuilder(store, store, store, store, remote.signalAddress)
        .processPreKeyBundle(remote.getPublicBundle());
  }

  /// Encrypt plaintext → E2EE||type||base64 (matches SignalService wire format).
  Future<String> encryptMessage(
      Participant remote, String plaintext) async {
    final cipher =
        SessionCipher(store, store, store, store, remote.signalAddress);
    final ct =
        await cipher.encrypt(Uint8List.fromList(utf8.encode(plaintext)));
    return 'E2EE||${ct.getType()}||${base64Encode(ct.serialize())}';
  }

  /// Decrypt E2EE||type||base64 → plaintext.
  Future<String> decryptMessage(
      Participant remote, String envelope) async {
    assert(envelope.startsWith('E2EE||'));
    final parts = envelope.split('||');
    final type = int.parse(parts[1]);
    final bytes = base64Decode(parts[2]);

    final cipher =
        SessionCipher(store, store, store, store, remote.signalAddress);

    Uint8List plain;
    if (type == CiphertextMessage.prekeyType) {
      plain = await cipher.decrypt(PreKeySignalMessage(bytes));
    } else if (type == CiphertextMessage.whisperType) {
      plain =
          await cipher.decryptFromSignal(SignalMessage.fromSerialized(bytes));
    } else {
      throw Exception('Unknown ciphertext type: $type');
    }
    return utf8.decode(plain);
  }

  /// Full pipeline: wrap envelope → encrypt → send via transport.
  Future<void> sendText(Participant recipient, String text) async {
    final wrapped = MessageEnvelope.wrap(address, text);
    final encrypted = await encryptMessage(recipient, wrapped);
    transport.send(recipient.address, encrypted);
  }

  /// Full pipeline: decrypt → unwrap envelope.
  Future<MessageEnvelope?> receiveAndDecrypt(
      Participant sender, String ciphertext) async {
    final plainJson = await decryptMessage(sender, ciphertext);
    return MessageEnvelope.tryUnwrap(plainJson);
  }
}

void main() {
  late FakeTransport transport;

  setUp(() {
    transport = FakeTransport();
  });

  tearDown(() {
    transport.dispose();
  });

  group('E2E message flow', () {
    test('Alice → Bob: basic send and decrypt', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      final received = Completer<String>();
      transport.inbox(bob.address).listen(received.complete);

      await alice.sendText(bob, 'Hello Bob!');
      final ciphertext = await received.future;

      final envelope = await bob.receiveAndDecrypt(alice, ciphertext);
      expect(envelope, isNotNull);
      expect(envelope!.from, equals('alice@relay'));
      expect(envelope.body, equals('Hello Bob!'));
    });

    test('Bidirectional: Alice → Bob → Alice reply', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      // Alice → Bob
      final bobReceived = Completer<String>();
      transport.inbox(bob.address).listen(bobReceived.complete);
      await alice.sendText(bob, 'Hi Bob');
      final ct1 = await bobReceived.future;
      final env1 = await bob.receiveAndDecrypt(alice, ct1);
      expect(env1!.body, equals('Hi Bob'));

      // Bob → Alice (session established from decrypt)
      final aliceReceived = Completer<String>();
      transport.inbox(alice.address).listen(aliceReceived.complete);
      await bob.sendText(alice, 'Hey Alice!');
      final ct2 = await aliceReceived.future;
      final env2 = await alice.receiveAndDecrypt(bob, ct2);
      expect(env2!.body, equals('Hey Alice!'));
      expect(env2.from, equals('bob@relay'));
    });

    test('Sequential messages: ratchet advances over 5 messages', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      // Deterministic barrier: take exactly 5 events from the broadcast
      // stream, then await the resulting list. No `Future.delayed` race —
      // `take(5).toList()` completes ONLY after the 5th add() lands.
      final messagesFut = transport.inbox(bob.address).take(5).toList()
          .timeout(const Duration(seconds: 5));

      for (var i = 0; i < 5; i++) {
        await alice.sendText(bob, 'Message $i');
      }

      final messages = await messagesFut;
      expect(messages.length, equals(5));
      for (var i = 0; i < 5; i++) {
        final env = await bob.receiveAndDecrypt(alice, messages[i]);
        expect(env!.body, equals('Message $i'));
      }
    });

    test('Envelope integrity: JSON payload preserved through crypto', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      const body = '{"action":"typing","ts":1234567890}';
      final wrapped = MessageEnvelope.wrap('alice@relay', body);
      final encrypted = await alice.encryptMessage(bob, wrapped);

      // Verify wire format
      expect(encrypted.startsWith('E2EE||'), isTrue);

      final decrypted = await bob.decryptMessage(alice, encrypted);
      final envelope = MessageEnvelope.tryUnwrap(decrypted);
      expect(envelope, isNotNull);
      expect(envelope!.body, equals(body));
      expect(envelope.from, equals('alice@relay'));

      // Verify body is valid JSON
      final parsed = jsonDecode(envelope.body) as Map<String, dynamic>;
      expect(parsed['action'], equals('typing'));
      expect(parsed['ts'], equals(1234567890));
    });

    test('Large message: 10KB payload', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      final largeBody = 'X' * 10240; // 10KB
      final received = Completer<String>();
      transport.inbox(bob.address).listen(received.complete);

      await alice.sendText(bob, largeBody);
      final ct = await received.future;
      final env = await bob.receiveAndDecrypt(alice, ct);
      expect(env!.body, equals(largeBody));
      expect(env.body.length, equals(10240));
    });

    test('UTF-8: Russian, Chinese, Arabic, emoji', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      const text = 'Привет 你好 مرحبا 🔐🚀💬';
      final received = Completer<String>();
      transport.inbox(bob.address).listen(received.complete);

      await alice.sendText(bob, text);
      final ct = await received.future;
      final env = await bob.receiveAndDecrypt(alice, ct);
      expect(env!.body, equals(text));
    });

    test('Wrong recipient: Carol cannot decrypt message for Bob', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);
      final carol =
          await Participant.create('carol', 'carol@relay', transport);

      await alice.buildSessionWith(bob);

      final wrapped = MessageEnvelope.wrap('alice@relay', 'secret for Bob');
      final encrypted = await alice.encryptMessage(bob, wrapped);

      // Carol has no session with Alice — decrypt must throw
      expect(
        () async => await carol.decryptMessage(alice, encrypted),
        throwsA(anything),
      );
    });

    test('Wire format: validates E2EE||type||base64 structure', () async {
      final alice = await Participant.create('alice', 'alice@relay', transport);
      final bob = await Participant.create('bob', 'bob@relay', transport);

      await alice.buildSessionWith(bob);

      const text = 'format check';
      final wrapped = MessageEnvelope.wrap('alice@relay', text);
      final encrypted = await alice.encryptMessage(bob, wrapped);

      // Validate wire format
      expect(encrypted.startsWith('E2EE||'), isTrue);
      final parts = encrypted.split('||');
      expect(parts.length, equals(3));
      expect(parts[0], equals('E2EE'));

      final type = int.tryParse(parts[1]);
      expect(type, isNotNull);
      expect(
          type,
          anyOf(equals(CiphertextMessage.prekeyType),
              equals(CiphertextMessage.whisperType)));

      // Third part must be valid base64
      expect(() => base64Decode(parts[2]), returnsNormally);
    });
  });
}
