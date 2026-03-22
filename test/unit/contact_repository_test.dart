import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/contact_repository.dart';

/// Concrete in-memory implementation of [IContactRepository] that relies on
/// the **default** [findById] and [findByAddress] implementations from the
/// abstract class — i.e. does NOT override them.
class _TestContactRepo extends IContactRepository {
  final List<Contact> _contacts = [];

  @override
  List<Contact> get contacts => _contacts;

  @override
  Future<void> loadContacts() async {
    // no-op for tests
  }

  @override
  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
  }

  @override
  Future<void> removeContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> updateContact(Contact updated) async {
    final idx = _contacts.indexWhere((c) => c.id == updated.id);
    if (idx != -1) _contacts[idx] = updated;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Contact _makeContact({
  required String id,
  String name = 'Test',
  String provider = 'Nostr',
  String databaseId = '',
  String publicKey = 'pk',
}) {
  return Contact(
    id: id,
    name: name,
    provider: provider,
    databaseId: databaseId,
    publicKey: publicKey,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _TestContactRepo repo;

  setUp(() {
    repo = _TestContactRepo();
  });

  group('IContactRepository.findById', () {
    test('returns correct contact when id exists', () async {
      final alice = _makeContact(id: 'alice-1', name: 'Alice');
      final bob = _makeContact(id: 'bob-2', name: 'Bob');
      await repo.addContact(alice);
      await repo.addContact(bob);

      final result = repo.findById('bob-2');
      expect(result, isNotNull);
      expect(result!.name, 'Bob');
      expect(result.id, 'bob-2');
    });

    test('returns null for non-existent id', () async {
      await repo.addContact(_makeContact(id: 'alice-1'));

      final result = repo.findById('non-existent');
      expect(result, isNull);
    });

    test('returns null when contacts list is empty', () {
      final result = repo.findById('any-id');
      expect(result, isNull);
    });

    test('returns first matching contact when duplicates exist', () async {
      final first = _makeContact(id: 'dup', name: 'First');
      final second = _makeContact(id: 'dup', name: 'Second');
      await repo.addContact(first);
      await repo.addContact(second);

      final result = repo.findById('dup');
      expect(result, isNotNull);
      expect(result!.name, 'First');
    });
  });

  group('IContactRepository.findByAddress', () {
    test('returns correct contact when address exists', () async {
      final alice = _makeContact(
        id: 'a1',
        name: 'Alice',
        databaseId: 'alice@wss://relay.example.com',
      );
      await repo.addContact(alice);

      final result = repo.findByAddress('alice@wss://relay.example.com');
      expect(result, isNotNull);
      expect(result!.id, 'a1');
      expect(result.name, 'Alice');
    });

    test('returns null for non-existent address', () async {
      await repo.addContact(_makeContact(
        id: 'a1',
        databaseId: 'alice@wss://relay.example.com',
      ));

      final result = repo.findByAddress('bob@wss://other.relay.com');
      expect(result, isNull);
    });

    test('returns null when contacts list is empty', () {
      final result = repo.findByAddress('some@address');
      expect(result, isNull);
    });

    test('works correctly across different providers', () async {
      final nostrContact = _makeContact(
        id: 'n1',
        name: 'NostrUser',
        provider: 'Nostr',
        databaseId: 'pubkey@wss://relay.nostr.com',
      );
      final firebaseContact = _makeContact(
        id: 'f1',
        name: 'FirebaseUser',
        provider: 'Firebase',
        databaseId: 'uid@https://project.firebaseio.com',
      );
      final oxenContact = _makeContact(
        id: 'o1',
        name: 'OxenUser',
        provider: 'Oxen',
        databaseId: '05${'ab' * 32}',
      );
      await repo.addContact(nostrContact);
      await repo.addContact(firebaseContact);
      await repo.addContact(oxenContact);

      expect(repo.findByAddress('pubkey@wss://relay.nostr.com')?.id, 'n1');
      expect(repo.findByAddress('uid@https://project.firebaseio.com')?.id, 'f1');
      expect(repo.findByAddress('05${'ab' * 32}')?.id, 'o1');
    });
  });

  group('addContact / removeContact affect findById', () {
    test('findById finds a contact after addContact', () async {
      expect(repo.findById('c1'), isNull);

      await repo.addContact(_makeContact(id: 'c1', name: 'Charlie'));
      expect(repo.findById('c1'), isNotNull);
      expect(repo.findById('c1')!.name, 'Charlie');
    });

    test('findById returns null after removeContact', () async {
      await repo.addContact(_makeContact(id: 'c1', name: 'Charlie'));
      expect(repo.findById('c1'), isNotNull);

      await repo.removeContact('c1');
      expect(repo.findById('c1'), isNull);
    });

    test('removeContact only removes the targeted contact', () async {
      await repo.addContact(_makeContact(id: 'c1', name: 'Alice'));
      await repo.addContact(_makeContact(id: 'c2', name: 'Bob'));
      await repo.addContact(_makeContact(id: 'c3', name: 'Charlie'));

      await repo.removeContact('c2');

      expect(repo.findById('c1'), isNotNull);
      expect(repo.findById('c2'), isNull);
      expect(repo.findById('c3'), isNotNull);
      expect(repo.contacts.length, 2);
    });
  });

  group('updateContact changes the contact', () {
    test('findById reflects updated fields after updateContact', () async {
      final original = _makeContact(
        id: 'u1',
        name: 'Original Name',
        databaseId: 'addr@wss://relay',
      );
      await repo.addContact(original);

      final updated = original.copyWith(name: 'Updated Name');
      await repo.updateContact(updated);

      final result = repo.findById('u1');
      expect(result, isNotNull);
      expect(result!.name, 'Updated Name');
      expect(result.databaseId, 'addr@wss://relay'); // unchanged field
    });

    test('updateContact does nothing for non-existent id', () async {
      await repo.addContact(_makeContact(id: 'c1', name: 'Alice'));

      final ghost = _makeContact(id: 'ghost', name: 'Ghost');
      await repo.updateContact(ghost);

      expect(repo.contacts.length, 1);
      expect(repo.findById('ghost'), isNull);
    });

    test('findByAddress reflects updated databaseId', () async {
      final original = _makeContact(
        id: 'u1',
        name: 'Alice',
        databaseId: 'old@wss://relay',
      );
      await repo.addContact(original);
      expect(repo.findByAddress('old@wss://relay'), isNotNull);

      final updated = original.copyWith(databaseId: 'new@wss://relay');
      await repo.updateContact(updated);

      expect(repo.findByAddress('old@wss://relay'), isNull);
      expect(repo.findByAddress('new@wss://relay'), isNotNull);
      expect(repo.findByAddress('new@wss://relay')!.id, 'u1');
    });
  });

  group('edge cases', () {
    test('findById with empty string id returns null when none match', () {
      expect(repo.findById(''), isNull);
    });

    test('findByAddress with empty string address matches contact with empty databaseId', () async {
      final groupContact = _makeContact(
        id: 'g1',
        name: 'Group',
        provider: 'group',
        databaseId: '',
      );
      await repo.addContact(groupContact);

      // Groups have empty databaseId, so searching for '' should find it
      final result = repo.findByAddress('');
      expect(result, isNotNull);
      expect(result!.id, 'g1');
    });

    test('loadContacts can be called without error', () async {
      // Ensure the no-op implementation does not throw
      await expectLater(repo.loadContacts(), completes);
    });
  });
}
