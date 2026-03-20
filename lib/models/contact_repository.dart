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
  Contact? findById(String id) =>
      contacts.cast<Contact?>().firstWhere((c) => c?.id == id, orElse: () => null);

  /// Find a contact by its transport address [databaseId]. Returns null if not found.
  Contact? findByAddress(String address) =>
      contacts.cast<Contact?>().firstWhere((c) => c?.databaseId == address, orElse: () => null);
}
