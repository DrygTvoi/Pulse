import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../services/signal_service.dart';
import 'contact_repository.dart';

class Contact {
  final String id;
  final String name;
  /// Per-transport address map.
  /// Keys are provider names ('Pulse', 'Nostr', 'Session', 'Firebase').
  /// Values are lists of addresses for that transport.
  final Map<String, List<String>> transportAddresses;
  /// Ordered list of transports to try when sending. First = highest priority.
  final List<String> transportPriority;
  final String publicKey; // E2EE public key
  final String? avatarUrl;
  final bool isGroup;
  // For groups: list of member contact IDs
  final List<String> members;
  /// UUID of the contact who created this group — determines admin privileges.
  final String? creatorId;
  /// Bio/about text received via profile_update signal.
  final String bio;

  // Private generative constructor
  Contact._raw({
    required this.id,
    required this.name,
    required this.transportAddresses,
    required this.transportPriority,
    required this.publicKey,
    this.avatarUrl,
    this.isGroup = false,
    this.members = const [],
    this.creatorId,
    this.bio = '',
  });

  /// Create a Contact, accepting either new-style transportAddresses or
  /// old-style provider/databaseId/alternateAddresses (auto-migrated).
  factory Contact({
    required String id,
    required String name,
    required String publicKey,
    Map<String, List<String>>? transportAddresses,
    List<String>? transportPriority,
    String? avatarUrl,
    bool isGroup = false,
    List<String> members = const [],
    String? creatorId,
    String? provider,
    String? databaseId,
    List<String>? alternateAddresses,
    String bio = '',
  }) {
    Map<String, List<String>> ta;
    List<String> tp;

    if (transportAddresses != null && transportAddresses.isNotEmpty) {
      ta = transportAddresses;
      tp = transportPriority ?? ta.keys.toList();
    } else if (databaseId != null && databaseId.isNotEmpty) {
      // Migrate from old-style fields
      ta = <String, List<String>>{};
      final allAddrs = <String>[databaseId, ...?alternateAddresses];
      for (final addr in allAddrs) {
        final t = _providerFromAddress(addr);
        (ta[t] ??= []).add(addr);
      }
      final primaryTransport = provider ?? _providerFromAddress(databaseId);
      tp = [primaryTransport, ...ta.keys.where((t) => t != primaryTransport)];
    } else {
      ta = {};
      tp = transportPriority ?? [];
    }

    return Contact._raw(
      id: id,
      name: name,
      transportAddresses: ta,
      transportPriority: tp,
      publicKey: publicKey,
      avatarUrl: avatarUrl,
      isGroup: isGroup,
      members: members,
      creatorId: creatorId,
      bio: bio,
    );
  }

  // ── Backward-compat getters ─────────────────────────────────────────────

  /// Primary provider name (first in transport priority).
  String get provider =>
      transportPriority.isNotEmpty ? transportPriority.first : 'Nostr';

  /// Primary transport address (first address of the highest-priority transport).
  String get databaseId {
    for (final t in transportPriority) {
      final addrs = transportAddresses[t];
      if (addrs != null && addrs.isNotEmpty) return addrs.first;
    }
    // Fallback: first address from any transport
    for (final addrs in transportAddresses.values) {
      if (addrs.isNotEmpty) return addrs.first;
    }
    return '';
  }

  /// All addresses except the primary, flattened for backward compat.
  List<String> get alternateAddresses {
    final primary = databaseId;
    return transportAddresses.values
        .expand((a) => a)
        .where((a) => a != primary)
        .toList();
  }

  /// The canonical local storage key for this contact's message history.
  /// Groups use their UUID (databaseId is empty for groups).
  /// Direct contacts use their transport address (databaseId).
  String get storageKey => isGroup ? id : databaseId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'transportAddresses': transportAddresses.map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ),
      'transportPriority': transportPriority,
      // Write legacy fields for backward compat with older app versions
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
    Map<String, List<String>>? transportAddresses,
    List<String>? transportPriority,
    String? publicKey,
    String? avatarUrl,
    List<String>? members,
    String? creatorId,
    String? bio,
    // Legacy params — translated to transport fields
    String? provider,
    String? databaseId,
    List<String>? alternateAddresses,
  }) {
    // If caller uses new-style params, use them directly
    if (transportAddresses != null || transportPriority != null) {
      return Contact._raw(
        id: id,
        name: name ?? this.name,
        transportAddresses: transportAddresses ?? this.transportAddresses,
        transportPriority: transportPriority ?? this.transportPriority,
        publicKey: publicKey ?? this.publicKey,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isGroup: isGroup,
        members: members ?? this.members,
        creatorId: creatorId ?? this.creatorId,
        bio: bio ?? this.bio,
      );
    }
    // If caller uses legacy params, rebuild transport map
    if (databaseId != null || provider != null || alternateAddresses != null) {
      final effDb = databaseId ?? this.databaseId;
      final effAlts = alternateAddresses ?? this.alternateAddresses;
      final ta = <String, List<String>>{};
      final allAddrs = [if (effDb.isNotEmpty) effDb, ...effAlts];
      for (final addr in allAddrs) {
        final t = _providerFromAddress(addr);
        (ta[t] ??= []).add(addr);
      }
      final primaryTransport = provider ?? (effDb.isNotEmpty ? _providerFromAddress(effDb) : this.provider);
      final tp = [primaryTransport, ...ta.keys.where((t) => t != primaryTransport)];
      return Contact._raw(
        id: id,
        name: name ?? this.name,
        transportAddresses: ta,
        transportPriority: tp,
        publicKey: publicKey ?? this.publicKey,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isGroup: isGroup,
        members: members ?? this.members,
        creatorId: creatorId ?? this.creatorId,
        bio: bio ?? this.bio,
      );
    }
    // No transport changes — keep existing
    return Contact._raw(
      id: id,
      name: name ?? this.name,
      transportAddresses: this.transportAddresses,
      transportPriority: this.transportPriority,
      publicKey: publicKey ?? this.publicKey,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroup: isGroup,
      members: members ?? this.members,
      creatorId: creatorId ?? this.creatorId,
      bio: bio ?? this.bio,
    );
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    Map<String, List<String>> ta;
    List<String> tp;

    if (map.containsKey('transportAddresses') && map['transportAddresses'] != null) {
      // New format
      final rawTa = map['transportAddresses'] as Map;
      ta = rawTa.map((k, v) => MapEntry(
        k as String,
        (v as List).whereType<String>().toList(),
      ));
      tp = (map['transportPriority'] as List?)?.whereType<String>().toList() ?? ta.keys.toList();
    } else {
      // Legacy format — migrate
      final primary = (map['databaseId'] as String?) ?? '';
      final alts = (map['alternateAddresses'] as List?)?.whereType<String>().toList() ?? [];
      final allAddrs = [if (primary.isNotEmpty) primary, ...alts];
      ta = {};
      for (final addr in allAddrs) {
        final transport = _providerFromAddress(addr);
        (ta[transport] ??= []).add(addr);
      }
      final storedProvider = (map['provider'] as String?) ?? 'Nostr';
      final primaryTransport = primary.isNotEmpty ? _providerFromAddress(primary) : storedProvider;
      tp = [primaryTransport, ...ta.keys.where((t) => t != primaryTransport)];
    }

    return Contact._raw(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      transportAddresses: ta,
      transportPriority: tp,
      publicKey: (map['publicKey'] as String?) ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      isGroup: map['isGroup'] as bool? ?? false,
      members: (map['members'] as List?)?.whereType<String>().toList() ?? [],
      creatorId: map['creatorId'] as String?,
      bio: (map['bio'] as String?) ?? '',
    );
  }

  // ── Address classification helper ──────────────────────────────────────

  static final _sessionAddrRegex = RegExp(r'^[0-9a-f]{66}$');
  static final _pulseAddrRegex = RegExp(r'^[0-9a-f]{64}@https://', caseSensitive: false);

  static String _providerFromAddress(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        _sessionAddrRegex.hasMatch(lower)) {
      return 'Session';
    }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) {
      return 'Nostr';
    }
    if (_pulseAddrRegex.hasMatch(lower)) return 'Pulse';
    if (lower.contains('@https://')) return 'Firebase';
    return 'Nostr';
  }
}

class ContactManager implements IContactRepository {
  static final ContactManager _instance = ContactManager._internal();
  factory ContactManager() => _instance;
  ContactManager._internal();

  List<Contact> _contacts = [];
  @override
  List<Contact> get contacts => _contacts;

  // O(1) lookup indices — rebuilt on load/add/remove/update.
  final Map<String, Contact> _idIndex = {};
  final Map<String, Contact> _addressIndex = {};

  void _rebuildIndices() {
    _idIndex.clear();
    _addressIndex.clear();
    for (final c in _contacts) {
      _idIndex[c.id] = c;
      // Index ALL addresses from all transports for O(1) lookup.
      for (final addrs in c.transportAddresses.values) {
        for (final addr in addrs) {
          if (addr.isNotEmpty) _addressIndex[addr] = c;
        }
      }
    }
  }

  void _indexContact(Contact c) {
    _idIndex[c.id] = c;
    for (final addrs in c.transportAddresses.values) {
      for (final addr in addrs) {
        if (addr.isNotEmpty) _addressIndex[addr] = c;
      }
    }
  }

  void _removeContactFromIndex(Contact c) {
    _idIndex.remove(c.id);
    for (final addrs in c.transportAddresses.values) {
      for (final addr in addrs) {
        if (_addressIndex[addr]?.id == c.id) {
          _addressIndex.remove(addr);
        }
      }
    }
  }

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
    _rebuildIndices();
  }

  @override
  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    _indexContact(contact);
    await LocalStorageService().saveContact(contact.id, contact.toMap());
  }

  @override
  Future<void> removeContact(String id) async {
    final contact = findById(id);
    _contacts.removeWhere((c) => c.id == id);
    if (contact != null) {
      _removeContactFromIndex(contact);
    }
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
      final old = _contacts[idx];
      _contacts[idx] = updated;
      // Remove old index entries, add new ones
      _removeContactFromIndex(old);
      _indexContact(updated);
      await LocalStorageService().saveContact(updated.id, updated.toMap());
    }
  }

  @override
  Contact? findById(String id) => _idIndex[id];

  @override
  Contact? findByAddress(String address) => _addressIndex[address];
}
