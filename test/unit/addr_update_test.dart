import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/contact.dart';

/// Tests for the addr_update signal logic.
///
/// The core transformation (extracted from ChatController._handleIncomingSignals):
///   1. Find contact by senderId OR any of the 'all' addresses
///   2. Set databaseId = primary
///   3. Move old databaseId + extra 'all' addresses → alternateAddresses (deduped)
Contact _applyAddrUpdate(Contact contact, String primary, List<String> all) {
  final alts = <String>{...contact.alternateAddresses};
  if (contact.databaseId.isNotEmpty && contact.databaseId != primary) {
    alts.add(contact.databaseId);
  }
  alts.addAll(all.where((a) => a != primary));
  alts.remove(primary);
  return contact.copyWith(
    databaseId: primary,
    alternateAddresses: alts.toList(),
  );
}

bool _contactMatchesSender(Contact contact, String senderId, List<String> all) {
  if (contact.databaseId == senderId) return true;
  if (contact.databaseId.split('@').first == senderId) return true;
  return all.any((a) =>
      contact.databaseId == a || contact.databaseId.split('@').first == a);
}

void main() {
  group('addr_update: contact matching', () {
    test('matches by exact databaseId', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'pubkey@wss://relay.damus.io');
      expect(_contactMatchesSender(c, 'pubkey@wss://relay.damus.io', []), isTrue);
    });

    test('matches by pubkey prefix (without relay)', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'pubkey@wss://relay.damus.io');
      expect(_contactMatchesSender(c, 'pubkey', []), isTrue);
    });

    test('matches by old address in all[] list', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'oldkey@wss://old.relay.io');
      expect(_contactMatchesSender(c, 'newkey@wss://new.relay.io',
          ['newkey@wss://new.relay.io', 'oldkey@wss://old.relay.io']), isTrue);
    });

    test('does not match unrelated contact', () {
      final c = Contact(id: '1', name: 'Bob', provider: 'Firebase', publicKey: '',
          databaseId: 'bob-uid');
      expect(_contactMatchesSender(c, 'alice-uid', ['alice-uid']), isFalse);
    });
  });

  group('addr_update: contact transformation', () {
    test('updates databaseId to new primary', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'pubkey@wss://old.relay.io');
      final updated = _applyAddrUpdate(
          c, 'pubkey@wss://new.relay.io', ['pubkey@wss://new.relay.io']);
      expect(updated.databaseId, 'pubkey@wss://new.relay.io');
    });

    test('old databaseId moves to alternateAddresses', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'pubkey@wss://old.relay.io');
      final updated = _applyAddrUpdate(
          c, 'pubkey@wss://new.relay.io', ['pubkey@wss://new.relay.io']);
      expect(updated.alternateAddresses, contains('pubkey@wss://old.relay.io'));
    });

    test('all additional addresses added to alternateAddresses', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Firebase', publicKey: '',
          databaseId: 'alice-uid@https://proj.firebaseio.com');
      final updated = _applyAddrUpdate(c,
          'alice-uid@https://proj.firebaseio.com',
          ['alice-uid@https://proj.firebaseio.com', 'nostr-pubkey@wss://relay.damus.io']);
      expect(updated.alternateAddresses, contains('nostr-pubkey@wss://relay.damus.io'));
    });

    test('primary is NOT in alternateAddresses', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'key@wss://old.io');
      final updated = _applyAddrUpdate(
          c, 'key@wss://new.io', ['key@wss://new.io', 'key@wss://old.io']);
      expect(updated.alternateAddresses, isNot(contains('key@wss://new.io')));
    });

    test('no duplicates in alternateAddresses', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'key@wss://old.io',
          alternateAddresses: ['key@wss://old.io']); // already there
      final updated = _applyAddrUpdate(
          c, 'key@wss://new.io', ['key@wss://new.io', 'key@wss://old.io']);
      final alts = updated.alternateAddresses;
      expect(alts.where((a) => a == 'key@wss://old.io').length, 1);
    });

    test('if primary unchanged — databaseId stays same, alts get extra addresses', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Firebase', publicKey: '',
          databaseId: 'alice-uid');
      final updated = _applyAddrUpdate(
          c, 'alice-uid', ['alice-uid', 'nostr-key@wss://relay.damus.io']);
      expect(updated.databaseId, 'alice-uid');
      expect(updated.alternateAddresses, contains('nostr-key@wss://relay.damus.io'));
    });

    test('existing alternateAddresses are preserved', () {
      final c = Contact(id: '1', name: 'Alice', provider: 'Nostr', publicKey: '',
          databaseId: 'key@wss://old.io',
          alternateAddresses: ['key@wss://backup.io']);
      final updated = _applyAddrUpdate(
          c, 'key@wss://new.io', ['key@wss://new.io']);
      expect(updated.alternateAddresses, containsAll(['key@wss://old.io', 'key@wss://backup.io']));
    });
  });
}
