import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/contact_repository.dart';

/// In-memory IContactRepository for unit tests.
class MockContactRepository implements IContactRepository {
  final List<Contact> _contacts;

  MockContactRepository([List<Contact>? contacts])
      : _contacts = contacts ?? [];

  @override
  List<Contact> get contacts => List.unmodifiable(_contacts);

  @override
  Future<void> loadContacts() async {}

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
