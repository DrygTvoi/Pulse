import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      alternateAddresses: alternateAddresses ?? this.alternateAddresses,
      bio: bio ?? this.bio,
    );
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      provider: map['provider'],
      databaseId: map['databaseId'],
      publicKey: map['publicKey'] ?? '',
      avatarUrl: map['avatarUrl'],
      isGroup: map['isGroup'] ?? false,
      members: List<String>.from(map['members'] ?? []),
      alternateAddresses: List<String>.from(map['alternateAddresses'] ?? []),
      bio: map['bio'] as String? ?? '',
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
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(contactsJson);
        _contacts = decoded
            .map((e) {
              try { return Contact.fromMap(e); }
              catch (_) { return null; }
            })
            .whereType<Contact>()
            .toList();
      } catch (e) {
        debugPrint('[ContactManager] Failed to parse contacts: $e');
        _contacts = [];
      }
    }
  }

  @override
  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    await _saveContacts();
  }

  @override
  Future<void> removeContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _saveContacts();
  }

  @override
  Future<void> updateContact(Contact updated) async {
    final idx = _contacts.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _contacts[idx] = updated;
      await _saveContacts();
    }
  }

  @override
  Contact? findById(String id) =>
      _contacts.cast<Contact?>().firstWhere((c) => c?.id == id, orElse: () => null);

  @override
  Contact? findByAddress(String address) =>
      _contacts.cast<Contact?>().firstWhere(
          (c) => c?.databaseId == address, orElse: () => null);

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_contacts.map((c) => c.toMap()).toList());
    await prefs.setString('contacts', encoded);
  }
}
