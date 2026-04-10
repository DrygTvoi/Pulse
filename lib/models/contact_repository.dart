import 'contact.dart';

/// Abstract interface for contact storage.
/// Implement this interface to swap ContactManager in tests.
abstract class IContactRepository {
  /// All contacts currently loaded in memory.
  List<Contact> get contacts;

  /// Load contacts from persistent storage.
  Future<void> loadContacts();

  /// Persist a new contact.
  Future<void> addContact(Contact contact);

  /// Remove contact by [id].
  Future<void> removeContact(String id);

  /// Update an existing contact (matched by [updated.id]).
  Future<void> updateContact(Contact updated);

  /// Find a contact by its UUID [id]. Returns null if not found.
  Contact? findById(String id) {
    for (final c in contacts) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Find a contact by its transport address [databaseId]. Returns null if not found.
  Contact? findByAddress(String address) {
    for (final c in contacts) {
      if (c.databaseId == address) return c;
    }
    return null;
  }
}
