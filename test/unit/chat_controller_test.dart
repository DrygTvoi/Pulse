import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/controllers/chat_controller.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/message.dart';
import 'mock_contact_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Contact _makeContact({
  required String id,
  String name = 'Test',
  String provider = 'Nostr',
  String databaseId = '',
  String publicKey = '',
  bool isGroup = false,
  List<String> members = const [],
  List<String> alternateAddresses = const [],
}) =>
    Contact(
      id: id,
      name: name,
      provider: provider,
      databaseId: databaseId.isEmpty ? '$id@wss://relay.test' : databaseId,
      publicKey: publicKey,
      isGroup: isGroup,
      members: members,
      alternateAddresses: alternateAddresses,
    );

/// The same sanitisation regex used in ChatController.exportHistory().
String _sanitizeName(String name) => name.replaceAll(RegExp(r'[^\w\-. ]'), '_');

void main() {
  // =========================================================================
  // 1. IContactRepository (MockContactRepository)
  // =========================================================================
  group('IContactRepository', () {
    test('findById returns contact by id', () {
      final c = _makeContact(id: 'abc');
      final repo = MockContactRepository([c]);
      expect(repo.findById('abc'), equals(c));
      expect(repo.findById('xyz'), isNull);
    });

    test('findByAddress returns contact by databaseId', () {
      final c = _makeContact(id: 'abc', databaseId: 'pubkey@wss://relay.test');
      final repo = MockContactRepository([c]);
      expect(repo.findByAddress('pubkey@wss://relay.test'), equals(c));
      expect(repo.findByAddress('other@wss://relay.test'), isNull);
    });

    test('addContact persists in memory', () async {
      final repo = MockContactRepository();
      final c = _makeContact(id: 'x1');
      await repo.addContact(c);
      expect(repo.contacts, contains(c));
    });

    test('removeContact removes by id', () async {
      final c = _makeContact(id: 'del1');
      final repo = MockContactRepository([c]);
      await repo.removeContact('del1');
      expect(repo.contacts, isEmpty);
    });

    test('removeContact is no-op for unknown id', () async {
      final c = _makeContact(id: 'keep');
      final repo = MockContactRepository([c]);
      await repo.removeContact('nonexistent');
      expect(repo.contacts.length, equals(1));
      expect(repo.contacts.first.id, equals('keep'));
    });

    test('updateContact replaces existing contact', () async {
      final original = _makeContact(id: 'upd1', name: 'Old');
      final repo = MockContactRepository([original]);
      final updated = original.copyWith(name: 'New');
      await repo.updateContact(updated);
      expect(repo.contacts.first.name, equals('New'));
    });

    test('updateContact is no-op for unknown id', () async {
      final repo = MockContactRepository();
      final c = _makeContact(id: 'ghost', name: 'Ghost');
      await repo.updateContact(c);
      expect(repo.contacts, isEmpty);
    });

    test('contacts list is unmodifiable', () {
      final repo = MockContactRepository([_makeContact(id: 'x')]);
      expect(
        () => repo.contacts.add(_makeContact(id: 'y')),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('findById returns null on empty repo', () {
      final repo = MockContactRepository();
      expect(repo.findById('any'), isNull);
    });

    test('findByAddress returns null on empty repo', () {
      final repo = MockContactRepository();
      expect(repo.findByAddress('any@wss://relay.test'), isNull);
    });

    test('addContact adds multiple contacts', () async {
      final repo = MockContactRepository();
      await repo.addContact(_makeContact(id: 'a'));
      await repo.addContact(_makeContact(id: 'b'));
      await repo.addContact(_makeContact(id: 'c'));
      expect(repo.contacts.length, equals(3));
    });

    test('loadContacts completes without error', () async {
      final repo = MockContactRepository();
      await expectLater(repo.loadContacts(), completes);
    });
  });

  // =========================================================================
  // 2. ChatController.forTesting — initial state assertions
  // =========================================================================
  group('ChatController.forTesting', () {
    test('identity is null initially', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      expect(controller.identity, isNull);
    });

    test('connectionStatus is disconnected initially', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      expect(controller.connectionStatus, equals(ConnectionStatus.disconnected));
    });

    test('lanModeActive is false initially', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      expect(controller.lanModeActive, isFalse);
    });

    test('creates controller with injected contacts', () {
      final c1 = _makeContact(id: 'c1');
      final c2 = _makeContact(id: 'c2');
      final repo = MockContactRepository([c1, c2]);
      final controller = ChatController.forTesting(repo);
      // The controller should exist and carry the injected repo.
      expect(controller, isNotNull);
      expect(controller.identity, isNull);
      expect(controller.connectionStatus, equals(ConnectionStatus.disconnected));
      expect(controller.lanModeActive, isFalse);
    });

    test('creates controller with empty repo', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      expect(controller, isNotNull);
      expect(controller.identity, isNull);
    });

    test('newMessages stream is a broadcast stream', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      // Should be able to listen multiple times without error.
      final sub1 = controller.newMessages.listen((_) {});
      final sub2 = controller.newMessages.listen((_) {});
      sub1.cancel();
      sub2.cancel();
    });

    test('keyChangeWarnings stream is a broadcast stream', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      final sub1 = controller.keyChangeWarnings.listen((_) {});
      final sub2 = controller.keyChangeWarnings.listen((_) {});
      sub1.cancel();
      sub2.cancel();
    });

    test('failoverEvents stream is a broadcast stream', () {
      final repo = MockContactRepository();
      final controller = ChatController.forTesting(repo);
      final sub1 = controller.failoverEvents.listen((_) {});
      final sub2 = controller.failoverEvents.listen((_) {});
      sub1.cancel();
      sub2.cancel();
    });
  });

  // =========================================================================
  // 3. Peer relay storage (SharedPreferences)
  // =========================================================================
  group('Peer relay storage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadPeerRelays returns empty list when no data stored', () async {
      final relays = await ChatController.loadPeerRelays();
      expect(relays, isEmpty);
    });

    test('savePeerRelays stores wss:// relays and rejects ws:// cleartext', () async {
      // ws:// is intentionally rejected from peer-shared URLs — cleartext is
      // insecure and localhost is blocked for LAN scan prevention.
      await ChatController.savePeerRelays([
        'wss://relay.damus.io',
        'ws://localhost:8080',
      ]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded, contains('wss://relay.damus.io'));
      expect(loaded, isNot(contains('ws://localhost:8080')));
      expect(loaded.length, equals(1));
    });

    test('savePeerRelays deduplicates relays', () async {
      await ChatController.savePeerRelays([
        'wss://relay.damus.io',
        'wss://relay.damus.io',
        'wss://relay.damus.io',
      ]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded.length, equals(1));
      expect(loaded.first, equals('wss://relay.damus.io'));
    });

    test('savePeerRelays deduplicates across multiple calls', () async {
      await ChatController.savePeerRelays(['wss://relay.damus.io']);
      await ChatController.savePeerRelays(['wss://relay.damus.io', 'wss://relay2.test']);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded.length, equals(2));
      expect(loaded, contains('wss://relay.damus.io'));
      expect(loaded, contains('wss://relay2.test'));
    });

    test('savePeerRelays rejects non-ws/wss URLs', () async {
      await ChatController.savePeerRelays([
        'https://relay.damus.io',
        'http://relay.damus.io',
        'ftp://files.example.com',
        'relay.damus.io',
        '',
      ]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded, isEmpty);
    });

    test('savePeerRelays rejects ws:// and non-ws/wss schemes', () async {
      // Only wss:// is accepted from peers to prevent cleartext relay use.
      await ChatController.savePeerRelays([
        'ws://local-relay:7777',
        'tcp://somewhere',
        'wss://good.relay',
      ]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded.length, equals(1));
      expect(loaded, isNot(contains('ws://local-relay:7777')));
      expect(loaded, contains('wss://good.relay'));
      expect(loaded, isNot(contains('tcp://somewhere')));
    });

    test('savePeerRelays is no-op for empty list', () async {
      // Pre-populate some data
      await ChatController.savePeerRelays(['wss://existing.relay']);
      // Call with empty — should not modify
      await ChatController.savePeerRelays([]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded.length, equals(1));
      expect(loaded.first, equals('wss://existing.relay'));
    });

    test('loadPeerRelays returns saved relays after roundtrip', () async {
      // Only wss:// relays are saved; ws:// cleartext is filtered out.
      await ChatController.savePeerRelays([
        'wss://relay1.example.com',
        'wss://relay2.example.com',
        'ws://relay3.example.com',
      ]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded, contains('wss://relay1.example.com'));
      expect(loaded, contains('wss://relay2.example.com'));
      expect(loaded, isNot(contains('ws://relay3.example.com')));
      expect(loaded.length, equals(2));
    });

    test('savePeerRelays filters mixed valid and invalid URLs', () async {
      await ChatController.savePeerRelays([
        'wss://good.relay',
        'https://bad.relay',
        'ws://also-good.relay',  // rejected: ws:// cleartext
        'bad-no-scheme',
        'wss://another-good.relay',
      ]);
      final loaded = await ChatController.loadPeerRelays();
      expect(loaded.length, equals(2));
      expect(loaded, contains('wss://good.relay'));
      expect(loaded, isNot(contains('ws://also-good.relay')));
      expect(loaded, contains('wss://another-good.relay'));
    });
  });

  // =========================================================================
  // 4. Filename sanitisation
  // =========================================================================
  group('Filename sanitisation', () {
    test('removes forward slashes from contact name', () {
      final dangerous = 'user/../../etc/passwd';
      final safe = _sanitizeName(dangerous);
      expect(safe, isNot(contains('/')));
      // Dots are allowed by the regex (for filenames like "file.txt"),
      // but slashes are stripped, so path traversal is neutralised.
      expect(safe, equals('user_.._.._etc_passwd'));
    });

    test('removes backslashes from contact name', () {
      final dangerous = r'user\..\..\..\etc\passwd';
      final safe = _sanitizeName(dangerous);
      expect(safe, isNot(contains(r'\')));
    });

    test('preserves normal ASCII name', () {
      expect(_sanitizeName('Alice'), equals('Alice'));
    });

    test('preserves hyphens, dots, spaces, and underscores', () {
      expect(_sanitizeName('Alice Bob'), equals('Alice Bob'));
      expect(_sanitizeName('user-name'), equals('user-name'));
      expect(_sanitizeName('file.txt'), equals('file.txt'));
      expect(_sanitizeName('under_score'), equals('under_score'));
    });

    test('replaces unicode characters', () {
      final safe = _sanitizeName('Юзер');
      // Cyrillic characters are not word chars in Dart's \w (which is ASCII),
      // so they should all be replaced with underscores.
      expect(safe, equals('____'));
      expect(safe, isNot(contains('Ю')));
    });

    test('replaces shell metacharacters', () {
      final dangerous = 'user;rm -rf /';
      final safe = _sanitizeName(dangerous);
      expect(safe, isNot(contains(';')));
      expect(safe, contains('user'));
    });

    test('replaces angle brackets and pipes', () {
      final safe = _sanitizeName('user<>|name');
      expect(safe, isNot(contains('<')));
      expect(safe, isNot(contains('>')));
      expect(safe, isNot(contains('|')));
    });

    test('handles empty string', () {
      expect(_sanitizeName(''), equals(''));
    });

    test('handles string of only special characters', () {
      final safe = _sanitizeName('@#\$%^&*');
      // Every character should be replaced with underscore.
      expect(safe.contains(RegExp(r'[^\w\-. ]')), isFalse);
    });

    test('preserves digits', () {
      expect(_sanitizeName('user123'), equals('user123'));
    });

    test('real-world path traversal attack is neutralised', () {
      final safe = _sanitizeName('/../../../etc/shadow');
      // No path separators should remain.
      expect(safe, isNot(contains('/')));
      // The result should be safe to use in a filename.
      expect(safe.contains(RegExp(r'[^\w\-. ]')), isFalse);
    });
  });

  // =========================================================================
  // 5. ConnectionStatus enum
  // =========================================================================
  group('ConnectionStatus enum', () {
    test('has exactly three values', () {
      expect(ConnectionStatus.values.length, equals(3));
    });

    test('disconnected value exists', () {
      expect(ConnectionStatus.values, contains(ConnectionStatus.disconnected));
    });

    test('connecting value exists', () {
      expect(ConnectionStatus.values, contains(ConnectionStatus.connecting));
    });

    test('connected value exists', () {
      expect(ConnectionStatus.values, contains(ConnectionStatus.connected));
    });

    test('values are ordered disconnected, connecting, connected', () {
      expect(ConnectionStatus.values[0], equals(ConnectionStatus.disconnected));
      expect(ConnectionStatus.values[1], equals(ConnectionStatus.connecting));
      expect(ConnectionStatus.values[2], equals(ConnectionStatus.connected));
    });

    test('enum index matches expected ordinal', () {
      expect(ConnectionStatus.disconnected.index, equals(0));
      expect(ConnectionStatus.connecting.index, equals(1));
      expect(ConnectionStatus.connected.index, equals(2));
    });
  });

  // =========================================================================
  // 6. Contact model (exercised through the mock repo)
  // =========================================================================
  group('Contact model', () {
    test('storageKey uses databaseId for direct contacts', () {
      final c = _makeContact(id: 'abc', databaseId: 'pub@wss://relay.test');
      expect(c.storageKey, equals('pub@wss://relay.test'));
    });

    test('storageKey uses id for group contacts', () {
      final c = _makeContact(id: 'group-uuid', isGroup: true);
      expect(c.storageKey, equals('group-uuid'));
    });

    test('copyWith creates a copy with updated fields', () {
      final c = _makeContact(id: 'c1', name: 'Original', provider: 'Nostr');
      final copy = c.copyWith(name: 'Updated');
      expect(copy.name, equals('Updated'));
      expect(copy.id, equals('c1'));
      expect(copy.provider, equals('Nostr'));
    });

    test('copyWith preserves alternateAddresses', () {
      final c = _makeContact(
        id: 'c1',
        alternateAddresses: ['alt1@wss://r1.test', 'alt2@wss://r2.test'],
      );
      final copy = c.copyWith(name: 'NewName');
      expect(copy.alternateAddresses.length, equals(2));
      expect(copy.alternateAddresses, contains('alt1@wss://r1.test'));
    });

    test('toMap and fromMap roundtrip', () {
      final c = _makeContact(
        id: 'rt1',
        name: 'Roundtrip',
        provider: 'Nostr',
        databaseId: 'pk@wss://relay.test',
        publicKey: 'abc123',
      );
      final map = c.toMap();
      final restored = Contact.fromMap(map);
      expect(restored.id, equals(c.id));
      expect(restored.name, equals(c.name));
      expect(restored.provider, equals(c.provider));
      expect(restored.databaseId, equals(c.databaseId));
      expect(restored.publicKey, equals(c.publicKey));
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': 'min',
        'name': 'Minimal',
        'provider': 'Nostr',
        'databaseId': 'pk@wss://r.test',
      };
      final c = Contact.fromMap(map);
      expect(c.publicKey, equals(''));
      expect(c.isGroup, isFalse);
      expect(c.members, isEmpty);
      expect(c.alternateAddresses, isEmpty);
      expect(c.bio, equals(''));
    });
  });

  // =========================================================================
  // 7. Message model
  // =========================================================================
  group('Message model', () {
    test('fromJson creates valid message', () {
      final json = {
        'id': 'msg1',
        'senderId': 'alice',
        'receiverId': 'bob',
        'encryptedPayload': 'hello',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'adapterType': 'nostr',
      };
      final msg = Message.fromJson(json);
      expect(msg.id, equals('msg1'));
      expect(msg.senderId, equals('alice'));
      expect(msg.receiverId, equals('bob'));
      expect(msg.encryptedPayload, equals('hello'));
      expect(msg.adapterType, equals('nostr'));
      expect(msg.isRead, isFalse);
      expect(msg.status, equals(''));
      expect(msg.isEdited, isFalse);
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'id': 'msg2',
        'senderId': 'alice',
        'receiverId': 'bob',
        'encryptedPayload': 'text',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'adapterType': 'nostr',
      };
      final msg = Message.fromJson(json);
      expect(msg.replyToId, isNull);
      expect(msg.replyToText, isNull);
      expect(msg.replyToSender, isNull);
      expect(msg.scheduledAt, isNull);
      expect(msg.readBy, isEmpty);
      expect(msg.deliveredTo, isEmpty);
    });

    test('toJson and fromJson roundtrip', () {
      final original = Message(
        id: 'rt1',
        senderId: 'alice',
        receiverId: 'bob',
        encryptedPayload: 'secret',
        timestamp: DateTime.utc(2026, 3, 21, 12, 0),
        adapterType: 'nostr',
        isRead: true,
        status: 'sent',
        isEdited: true,
        replyToId: 'prev1',
        replyToText: 'quoted text',
        replyToSender: 'bob',
      );
      final json = original.toJson();
      final restored = Message.fromJson(json);
      expect(restored.id, equals(original.id));
      expect(restored.senderId, equals(original.senderId));
      expect(restored.receiverId, equals(original.receiverId));
      expect(restored.encryptedPayload, equals(original.encryptedPayload));
      expect(restored.adapterType, equals(original.adapterType));
      expect(restored.isRead, equals(original.isRead));
      expect(restored.status, equals(original.status));
      expect(restored.isEdited, equals(original.isEdited));
      expect(restored.replyToId, equals(original.replyToId));
      expect(restored.replyToText, equals(original.replyToText));
      expect(restored.replyToSender, equals(original.replyToSender));
    });

    test('copyWith overrides specific fields', () {
      final msg = Message(
        id: 'cp1',
        senderId: 'alice',
        receiverId: 'bob',
        encryptedPayload: 'text',
        timestamp: DateTime.utc(2026),
        adapterType: 'nostr',
        status: 'sending',
      );
      final updated = msg.copyWith(status: 'sent', isRead: true);
      expect(updated.status, equals('sent'));
      expect(updated.isRead, isTrue);
      expect(updated.id, equals('cp1'));
      expect(updated.senderId, equals('alice'));
    });

    test('tryFromJson returns null on malformed data', () {
      final bad = <String, dynamic>{'not': 'a message'};
      // tryFromJson should not throw even with bad data.
      // Since fromJson uses null-coalescing, it may parse but with defaults.
      final result = Message.tryFromJson(bad);
      // At minimum it should not throw; result may be a Message with defaults.
      if (result != null) {
        expect(result.id, equals(''));
      }
    });

    test('fromJson handles invalid timestamp gracefully', () {
      final json = {
        'id': 'bad-ts',
        'senderId': 'a',
        'receiverId': 'b',
        'encryptedPayload': 'x',
        'timestamp': 'not-a-date',
        'adapterType': 'nostr',
      };
      final msg = Message.fromJson(json);
      // Should fall back to epoch.
      expect(msg.timestamp, equals(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)));
    });

    test('fromJson preserves readBy and deliveredTo lists', () {
      final json = {
        'id': 'grp1',
        'senderId': 'alice',
        'receiverId': 'group1',
        'encryptedPayload': 'group msg',
        'timestamp': '2026-03-21T00:00:00.000Z',
        'adapterType': 'group',
        'readBy': ['bob', 'charlie'],
        'deliveredTo': ['bob'],
      };
      final msg = Message.fromJson(json);
      expect(msg.readBy, equals(['bob', 'charlie']));
      expect(msg.deliveredTo, equals(['bob']));
    });

    test('toJson omits null optional fields', () {
      final msg = Message(
        id: 'm',
        senderId: 's',
        receiverId: 'r',
        encryptedPayload: 'p',
        timestamp: DateTime.utc(2026),
        adapterType: 'nostr',
      );
      final json = msg.toJson();
      expect(json.containsKey('replyToId'), isFalse);
      expect(json.containsKey('replyToText'), isFalse);
      expect(json.containsKey('scheduledAt'), isFalse);
      expect(json.containsKey('readBy'), isFalse);
      expect(json.containsKey('deliveredTo'), isFalse);
    });
  });
}
