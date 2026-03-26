import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/contact.dart';

void main() {
  group('Contact model', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      final contact = Contact(
        id: 'c1',
        name: 'Alice',
        provider: 'Nostr',
        databaseId: 'alice@wss://relay.example.com',
        publicKey: 'pk123',
        avatarUrl: 'https://example.com/avatar.png',
        isGroup: false,
        members: [],
        alternateAddresses: ['alice@wss://backup.example.com'],
        bio: 'Hello world',
      );
      final map = contact.toMap();
      final restored = Contact.fromMap(map);

      expect(restored.id, contact.id);
      expect(restored.name, contact.name);
      expect(restored.provider, contact.provider);
      expect(restored.databaseId, contact.databaseId);
      expect(restored.publicKey, contact.publicKey);
      expect(restored.avatarUrl, contact.avatarUrl);
      expect(restored.isGroup, contact.isGroup);
      expect(restored.members, contact.members);
      expect(restored.alternateAddresses, contact.alternateAddresses);
      expect(restored.bio, contact.bio);
    });

    test('fromMap handles missing optional fields', () {
      final contact = Contact.fromMap({
        'id': 'c1',
        'name': 'Bob',
        'provider': 'Firebase',
        'databaseId': 'bob@https://proj.firebaseio.com',
      });

      expect(contact.publicKey, '');
      expect(contact.avatarUrl, isNull);
      expect(contact.isGroup, false);
      expect(contact.members, isEmpty);
      expect(contact.alternateAddresses, isEmpty);
      expect(contact.bio, '');
    });

    test('storageKey uses databaseId for direct contacts', () {
      final contact = Contact(
        id: 'c1',
        name: 'Alice',
        provider: 'Nostr',
        databaseId: 'alice@wss://relay',
        publicKey: 'pk',
      );
      expect(contact.storageKey, 'alice@wss://relay');
    });

    test('storageKey uses id for groups', () {
      final contact = Contact(
        id: 'group-uuid-123',
        name: 'Team Chat',
        provider: 'group',
        databaseId: '',
        publicKey: '',
        isGroup: true,
        members: ['c1', 'c2'],
      );
      expect(contact.storageKey, 'group-uuid-123');
    });

    test('copyWith creates new contact with updated fields', () {
      final original = Contact(
        id: 'c1',
        name: 'Alice',
        provider: 'Nostr',
        databaseId: 'alice@wss://relay',
        publicKey: 'pk1',
        bio: 'old bio',
      );
      final updated = original.copyWith(
        name: 'Alice Smith',
        bio: 'new bio',
        databaseId: 'alice@wss://newrelay',
      );

      expect(updated.id, 'c1'); // unchanged
      expect(updated.name, 'Alice Smith');
      expect(updated.bio, 'new bio');
      expect(updated.databaseId, 'alice@wss://newrelay');
      expect(updated.provider, 'Nostr'); // unchanged
    });

    test('copyWith preserves isGroup (not overridable)', () {
      final group = Contact(
        id: 'g1',
        name: 'Team',
        provider: 'group',
        databaseId: '',
        publicKey: '',
        isGroup: true,
      );
      final updated = group.copyWith(name: 'New Team Name');
      expect(updated.isGroup, true);
    });

    test('toMap omits bio when empty', () {
      final contact = Contact(
        id: 'c1',
        name: 'Alice',
        provider: 'Nostr',
        databaseId: 'alice@wss://relay',
        publicKey: 'pk',
        bio: '',
      );
      final map = contact.toMap();
      expect(map.containsKey('bio'), false);
    });

    test('toMap includes bio when non-empty', () {
      final contact = Contact(
        id: 'c1',
        name: 'Alice',
        provider: 'Nostr',
        databaseId: 'alice@wss://relay',
        publicKey: 'pk',
        bio: 'Hello',
      );
      final map = contact.toMap();
      expect(map['bio'], 'Hello');
    });

    test('alternateAddresses preserved through serialization', () {
      final contact = Contact(
        id: 'c1',
        name: 'Multi',
        provider: 'Nostr',
        databaseId: 'pk@wss://relay1',
        publicKey: 'pk',
        alternateAddresses: [
          'pk@wss://relay2',
          'pk@wss://relay3',
        ],
      );
      final map = contact.toMap();
      final restored = Contact.fromMap(map);
      expect(restored.alternateAddresses, hasLength(2));
      expect(restored.alternateAddresses[1], 'pk@wss://relay3');
    });

    test('creatorId preserved through serialization', () {
      final group = Contact(
        id: 'g1', name: 'Team', provider: 'group',
        databaseId: '', publicKey: '', isGroup: true,
        members: ['c1', 'c2'], creatorId: 'c1',
      );
      final restored = Contact.fromMap(group.toMap());
      expect(restored.creatorId, equals('c1'));
    });

    test('creatorId is null when absent in map', () {
      final contact = Contact.fromMap({
        'id': 'c1', 'name': 'Alice',
        'provider': 'Nostr', 'databaseId': 'pk@wss://r',
      });
      expect(contact.creatorId, isNull);
    });

    test('copyWith updates creatorId (admin transfer)', () {
      final group = Contact(
        id: 'g1', name: 'Team', provider: 'group',
        databaseId: '', publicKey: '', isGroup: true,
        members: ['c1', 'c2'], creatorId: 'c1',
      );
      final transferred = group.copyWith(creatorId: 'c2');
      expect(transferred.creatorId, equals('c2'));
      expect(group.creatorId, equals('c1')); // original unchanged
    });

    test('toMap omits creatorId when null', () {
      final contact = Contact(
        id: 'c1', name: 'Alice', provider: 'Nostr',
        databaseId: 'pk@wss://r', publicKey: '',
      );
      expect(contact.toMap().containsKey('creatorId'), isFalse);
    });

    test('group members preserved through serialization', () {
      final group = Contact(
        id: 'g1',
        name: 'Team',
        provider: 'group',
        databaseId: '',
        publicKey: '',
        isGroup: true,
        members: ['c1', 'c2', 'c3'],
      );
      final map = group.toMap();
      final restored = Contact.fromMap(map);
      expect(restored.isGroup, true);
      expect(restored.members, ['c1', 'c2', 'c3']);
    });
  });
}
