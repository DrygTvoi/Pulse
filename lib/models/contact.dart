import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../services/signal_service.dart';
import 'contact_repository.dart';

class Contact {
  final String id;
  final String name;
  final String provider; // 'Firebase' or 'Nostr'
  final String databaseId; // inbox address
  final String publicKey; // E2EE public key
  final String? avatarUrl;
  final bool isGroup;
  // For groups: list of member contact IDs
  final List<String> members;
  /// UUID of the contact who created this group — determines admin privileges.
  final String? creatorId;
  /// Fallback addresses tried (in random order) if the primary [databaseId]
  /// is unreachable. Same protocol or cross-protocol alternates are supported.
  /// Format: same as [databaseId] — e.g. "pubkey@wss://relay2.example.com"
  final List<String> alternateAddresses;
  /// Bio/about text received via profile_update signal.
  final String bio;

  Contact({
    required this.id,
    required this.name,
    required this.provider,
    required this.databaseId,
    required this.publicKey,
    this.avatarUrl,
    this.isGroup = false,
    this.members = const [],
    this.creatorId,
    this.alternateAddresses = const [],
    this.bio = '',
  });

  /// The canonical local storage key for this contact's message history.
  /// Groups use their UUID (databaseId is empty for groups).
  /// Direct contacts use their transport address (databaseId).
  String get storageKey => isGroup ? id : databaseId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'databaseId': databaseId,
      'publicKey': publicKey,
      'avatarUrl': avatarUrl,
      'isGroup': isGroup,
      'members': members,
      if (creatorId != null) 'creatorId': creatorId,
      'alternateAddresses': alternateAddresses,
      if (bio.isNotEmpty) 'bio': bio,
    };
  }

  Contact copyWith({
    String? name,
    String? provider,
    String? databaseId,
    String? publicKey,
    String? avatarUrl,
    List<String>? members,
    String? creatorId,
    List<String>? alternateAddresses,
    String? bio,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      databaseId: databaseId ?? this.databaseId,
      publicKey: publicKey ?? this.publicKey,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroup: isGroup,
      members: members ?? this.members,
      creatorId: creatorId ?? this.creatorId,
      alternateAddresses: alternateAddresses ?? this.alternateAddresses,
      bio: bio ?? this.bio,
    );
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      provider: (map['provider'] as String?) ?? 'Nostr',
      databaseId: (map['databaseId'] as String?) ?? '',
      publicKey: (map['publicKey'] as String?) ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      isGroup: map['isGroup'] as bool? ?? false,
      // Use whereType<String>() to reject non-string list elements that could
      // smuggle garbage or attacker-controlled addresses via type confusion.
      members: (map['members'] as List?)?.whereType<String>().toList() ?? [],
      creatorId: map['creatorId'] as String?,
      alternateAddresses: (map['alternateAddresses'] as List?)
              ?.whereType<String>()
              .toList() ??
          [],
      bio: (map['bio'] as String?) ?? '',
    );
  }
}

class ContactManager implements IContactRepository {
  static final ContactManager _instance = ContactManager._internal();
  factory ContactManager() => _instance;
  ContactManager._internal();

  List<Contact> _contacts = [];
  @override
  List<Contact> get contacts => _contacts;

  @override
  Future<void> loadContacts() async {
    try {
      final rows = await LocalStorageService().loadContacts();
      _contacts = rows
          .map((e) {
            try { return Contact.fromMap(e); }
            catch (_) { return null; }
          })
          .whereType<Contact>()
          .toList();
    } catch (e) {
      debugPrint('[ContactManager] Failed to load contacts: $e');
      _contacts = [];
    }
  }

  @override
  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    await LocalStorageService().saveContact(contact.id, contact.toMap());
  }

  @override
  Future<void> removeContact(String id) async {
    final contact = findById(id);
    _contacts.removeWhere((c) => c.id == id);
    await LocalStorageService().deleteContact(id);
    // Clean up Signal sessions and identity keys so stale material
    // cannot be replayed if a new contact with the same address is added.
    if (contact != null && contact.databaseId.isNotEmpty) {
      unawaited(SignalService().deleteContactData(contact.databaseId));
    }
  }

  @override
  Future<void> updateContact(Contact updated) async {
    final idx = _contacts.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _contacts[idx] = updated;
      await LocalStorageService().saveContact(updated.id, updated.toMap());
    }
  }

  @override
  Contact? findById(String id) =>
      _contacts.cast<Contact?>().firstWhere((c) => c?.id == id, orElse: () => null);

  @override
  Contact? findByAddress(String address) =>
      _contacts.cast<Contact?>().firstWhere(
          (c) => c?.databaseId == address, orElse: () => null);
}
