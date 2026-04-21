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

  /// Find a contact by their Nostr secp256k1 pubkey (64 hex chars).
  /// This is the cross-device stable identifier group code paths should
  /// use — UUIDs (from [findById]) are generated independently on each
  /// device and never match between peers for the same person.
  ///
  /// Matches against every Nostr transport address the contact has,
  /// stripping the `@relay` suffix and comparing case-insensitively.
  /// Default implementation scans linearly; concrete repositories
  /// (e.g. [ContactManager]) may override with an indexed variant.
  Contact? findByPubkey(String hexPubkey) {
    if (hexPubkey.isEmpty) return null;
    final needle = hexPubkey.toLowerCase();
    for (final c in contacts) {
      final addrs = c.transportAddresses['Nostr'] ?? const <String>[];
      for (final a in addrs) {
        final atIdx = a.indexOf('@');
        final pub = (atIdx > 0 ? a.substring(0, atIdx) : a).toLowerCase();
        if (pub == needle) return c;
      }
    }
    return null;
  }
}
