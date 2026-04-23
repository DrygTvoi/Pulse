import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  /// True for contacts auto-created from incoming messages by unknown senders.
  /// Pending contacts have restricted capabilities until accepted.
  final bool isPending;
  /// Routing-only contact: created automatically so the messenger can encrypt
  /// for a group member whose pubkey we know but who is not in our address
  /// book. Hidden from the chat list (you can't open a chat with a hidden
  /// contact) but reachable internally for group fan-out + Signal sessions.
  /// Becomes false the moment the user actually messages them out-of-group.
  final bool isHidden;
  /// For groups only: map of member UUID → Nostr secp256k1 pubkey hex.
  /// Filled by the creator when broadcasting group_invite / group_update
  /// and carried to receivers so they can resolve member UUIDs back to
  /// pubkeys they already have as local contacts — without this the
  /// receiver has no way to know which of its contacts corresponds to
  /// a given member-UUID (UUIDs are generated independently on each
  /// device). Empty for non-group contacts and for legacy groups
  /// created before this field existed.
  final Map<String, String> memberPubkeys;

  /// For groups only. Selects the call architecture used for *this* group:
  ///   'mesh' — full peer mesh, every member holds N−1 RTCPeerConnections
  ///            directly to the others. No server, no media-relay. Best
  ///            for small (≤4) trusted-roster groups; bandwidth scales with
  ///            roster size on every device.
  ///   'sfu'  — Selective Forwarding Unit, every client uploads once to
  ///            the Pulse SFU server (configured via [groupServerUrl]) and
  ///            downloads each remote stream from that server. Scales to
  ///            ~20 participants but requires a reachable Pulse server.
  ///
  /// Empty string for non-group contacts. For groups created before this
  /// field existed (legacy DB rows), readers should treat empty as
  /// implicit-'sfu' so existing groups keep working unchanged.
  final String groupCallMode;

  /// Pulse server endpoint used for SFU group calls (only when
  /// [groupCallMode] == 'sfu'). Format: `https://host:port` (or `http://`
  /// for self-hosted dev). Empty string for mesh groups and non-groups.
  final String groupServerUrl;

  /// Optional invite code required by closed Pulse servers. Empty string
  /// when the server is open or for mesh groups.
  final String groupServerInvite;

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
    this.isPending = false,
    this.isHidden = false,
    this.memberPubkeys = const {},
    this.groupCallMode = '',
    this.groupServerUrl = '',
    this.groupServerInvite = '',
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
    bool isPending = false,
    bool isHidden = false,
    Map<String, String> memberPubkeys = const {},
    String groupCallMode = '',
    String groupServerUrl = '',
    String groupServerInvite = '',
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
      isPending: isPending,
      isHidden: isHidden,
      memberPubkeys: memberPubkeys,
      groupCallMode: groupCallMode,
      groupServerUrl: groupServerUrl,
      groupServerInvite: groupServerInvite,
    );
  }

  // ── Backward-compat getters ─────────────────────────────────────────────

  /// Primary provider name (first in transport priority).
  String get provider =>
      transportPriority.isNotEmpty ? transportPriority.first : 'Nostr';

  /// Primary transport address (first address of the highest-priority transport).
  /// Cached lazily — safe because Contact instances are immutable (copyWith
  /// creates a new instance).
  String? _cachedDatabaseId;
  String get databaseId {
    return _cachedDatabaseId ??= _computeDatabaseId();
  }

  String _computeDatabaseId() {
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
  /// Cached lazily — safe because Contact instances are immutable (copyWith
  /// creates a new instance).
  List<String>? _cachedAlternateAddresses;
  List<String> get alternateAddresses {
    return _cachedAlternateAddresses ??= transportAddresses.values
        .expand((a) => a)
        .where((a) => a != databaseId)
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
      if (isPending) 'isPending': true,
      if (isHidden) 'isHidden': true,
      if (memberPubkeys.isNotEmpty)
        'memberPubkeys': Map<String, String>.from(memberPubkeys),
      if (groupCallMode.isNotEmpty) 'groupCallMode': groupCallMode,
      if (groupServerUrl.isNotEmpty) 'groupServerUrl': groupServerUrl,
      if (groupServerInvite.isNotEmpty) 'groupServerInvite': groupServerInvite,
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
    bool? isPending,
    bool? isHidden,
    Map<String, String>? memberPubkeys,
    String? groupCallMode,
    String? groupServerUrl,
    String? groupServerInvite,
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
        isPending: isPending ?? this.isPending,
        isHidden: isHidden ?? this.isHidden,
        memberPubkeys: memberPubkeys ?? this.memberPubkeys,
        groupCallMode: groupCallMode ?? this.groupCallMode,
        groupServerUrl: groupServerUrl ?? this.groupServerUrl,
        groupServerInvite: groupServerInvite ?? this.groupServerInvite,
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
        isPending: isPending ?? this.isPending,
        isHidden: isHidden ?? this.isHidden,
        memberPubkeys: memberPubkeys ?? this.memberPubkeys,
        groupCallMode: groupCallMode ?? this.groupCallMode,
        groupServerUrl: groupServerUrl ?? this.groupServerUrl,
        groupServerInvite: groupServerInvite ?? this.groupServerInvite,
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
      isPending: isPending ?? this.isPending,
      isHidden: isHidden ?? this.isHidden,
      memberPubkeys: memberPubkeys ?? this.memberPubkeys,
      groupCallMode: groupCallMode ?? this.groupCallMode,
      groupServerUrl: groupServerUrl ?? this.groupServerUrl,
      groupServerInvite: groupServerInvite ?? this.groupServerInvite,
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
      isPending: map['isPending'] as bool? ?? false,
      isHidden: map['isHidden'] as bool? ?? false,
      memberPubkeys: (map['memberPubkeys'] as Map?)
              ?.map((k, v) => MapEntry(k as String, v as String)) ??
          const {},
      groupCallMode: (map['groupCallMode'] as String?) ?? '',
      groupServerUrl: (map['groupServerUrl'] as String?) ?? '',
      groupServerInvite: (map['groupServerInvite'] as String?) ?? '',
    );
  }

  // ── Group call helpers ──────────────────────────────────────────────────

  /// Resolves the effective call architecture for this group, applying the
  /// legacy default. Pre-2026-04-23 groups stored an empty mode; treat them
  /// as 'sfu' so they keep working without manual migration. New groups set
  /// the field explicitly via CreateGroupDialog.
  String get effectiveGroupCallMode {
    if (!isGroup) return '';
    return groupCallMode.isEmpty ? 'sfu' : groupCallMode;
  }

  /// True iff this group should be called via the local mesh (each member
  /// connects directly to every other member). False = SFU-relayed.
  bool get isMeshGroup => effectiveGroupCallMode == 'mesh';

  // ── Address classification helper ──────────────────────────────────────

  static final _sessionAddrRegex = RegExp(r'^[0-9a-f]{66}$');
  static final _nostrPubRegex = RegExp(r'^[0-9a-f]{64}$');
  static final _pulseAddrRegex = RegExp(r'^[0-9a-f]{64}@https://', caseSensitive: false);

  /// Classify an address into its transport provider name.
  static String providerFromAddress(String address) => _providerFromAddress(address);

  static String _providerFromAddress(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        _sessionAddrRegex.hasMatch(lower)) {
      return 'Session';
    }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        _nostrPubRegex.hasMatch(lower)) {
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

  // ── Block list ──────────────────────────────────────────────���───────────
  static const _blockedPrefsKey = 'blocked_contact_ids';
  final Set<String> _blockedIds = {};
  Set<String> get blockedIds => Set.unmodifiable(_blockedIds);

  bool isBlocked(String id) => _blockedIds.contains(id);

  Future<void> loadBlockList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_blockedPrefsKey);
    _blockedIds.clear();
    if (raw != null) {
      try {
        _blockedIds.addAll(
          (jsonDecode(raw) as List).whereType<String>(),
        );
      } catch (_) {}
    }
  }

  Future<void> _saveBlockList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_blockedPrefsKey, jsonEncode(_blockedIds.toList()));
  }

  Future<void> blockContact(String id) async {
    _blockedIds.add(id);
    await _saveBlockList();
    // Also remove the contact and wipe chat history
    final contact = findById(id);
    if (contact != null) {
      await removeContact(id);
      await LocalStorageService().clearHistory(contact.storageKey);
    }
  }

  Future<void> unblockContact(String id) async {
    _blockedIds.remove(id);
    await _saveBlockList();
  }

  // ── Pending contact rate limiting ──────────────────────────────────��────
  static const int maxPendingContacts = 50;
  static const int maxPendingPerMinute = 5;
  final List<DateTime> _pendingCreationTimes = [];

  int get pendingContactCount =>
      _contacts.where((c) => c.isPending).length;

  bool canCreatePendingContact() {
    if (pendingContactCount >= maxPendingContacts) return false;
    final now = DateTime.now();
    _pendingCreationTimes.removeWhere(
      (t) => now.difference(t).inSeconds > 60,
    );
    return _pendingCreationTimes.length < maxPendingPerMinute;
  }

  /// Creates a pending contact from an unknown sender's incoming message.
  /// Returns the new contact, or null if limits are exceeded.
  Future<Contact?> createPendingContact({
    required String senderId,
    required String senderName,
    required String address,
    Map<String, List<String>>? transportAddresses,
    bool isHidden = false,
  }) async {
    if (!canCreatePendingContact()) return null;
    final contactId = senderId.split('@').first;
    // Avoid duplicates: check by ID and by address.
    final existing = findById(contactId) ?? findByAddress(senderId) ?? findByAddress(address);
    if (existing != null) return existing;
    final Contact contact;
    if (transportAddresses != null && transportAddresses.isNotEmpty) {
      contact = Contact(
        id: contactId,
        name: senderName,
        publicKey: '',
        transportAddresses: transportAddresses,
        isPending: true,
        isHidden: isHidden,
      );
    } else {
      contact = Contact(
        id: contactId,
        name: senderName,
        publicKey: '',
        databaseId: address,
        isPending: true,
        isHidden: isHidden,
      );
    }
    await addContact(contact);
    _pendingCreationTimes.add(DateTime.now());
    return contact;
  }

  void _rebuildIndices() {
    _idIndex.clear();
    _addressIndex.clear();
    for (final c in _contacts) {
      _indexContact(c);
    }
  }

  void _indexContact(Contact c) {
    _idIndex[c.id] = c;
    for (final addrs in c.transportAddresses.values) {
      for (final addr in addrs) {
        if (addr.isEmpty) continue;
        _addressIndex[addr] = c;
        // Also index the bare pubkey / Session-ID part so a sender whose
        // incoming message uses a different relay suffix (or no suffix at
        // all) still matches the existing contact — prevents duplicate
        // pending contacts being created for already-accepted people.
        final atIdx = addr.indexOf('@');
        if (atIdx > 0) {
          final bare = addr.substring(0, atIdx);
          _addressIndex.putIfAbsent(bare, () => c);
        }
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
        final atIdx = addr.indexOf('@');
        if (atIdx > 0) {
          final bare = addr.substring(0, atIdx);
          if (_addressIndex[bare]?.id == c.id) {
            _addressIndex.remove(bare);
          }
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
    // One-time dedup: earlier builds could create a pending duplicate next
    // to an already-accepted contact when the incoming message used a bare
    // pubkey (no @relay suffix) that didn't match the accepted contact's
    // randomly-assigned id. Drop any pending contact whose bare pubkey is
    // shared with a non-pending, non-group contact.
    _dedupePendingDuplicates();
    await _migrateLegacyGroupRoutingPhantoms();
    _rebuildIndices();
    await loadBlockList();
  }

  /// One-shot migration: earlier versions of the auto-pending-from-group-
  /// member code created visible contacts named "Group: <hash>" that
  /// appeared as ghost chat tiles. New code marks them isHidden:true; this
  /// migration retroactively hides any legacy ones still on disk so users
  /// upgrading from v1.4 don't keep seeing the phantoms.
  Future<void> _migrateLegacyGroupRoutingPhantoms() async {
    var migrated = 0;
    final updates = <Contact>[];
    for (var i = 0; i < _contacts.length; i++) {
      final c = _contacts[i];
      if (c.isHidden || c.isGroup || !c.isPending) continue;
      if (c.name.startsWith('Group: ') || c.name.startsWith('Member ')) {
        final fixed = c.copyWith(isHidden: true);
        _contacts[i] = fixed;
        updates.add(fixed);
        migrated++;
      }
    }
    if (migrated == 0) return;
    for (final c in updates) {
      try { await LocalStorageService().saveContact(c.id, c.toMap()); }
      catch (_) {}
    }
    debugPrint('[ContactManager] Migrated $migrated legacy group-routing phantoms to hidden');
  }

  void _dedupePendingDuplicates() {
    final bareOfAccepted = <String>{};
    for (final c in _contacts) {
      if (c.isPending || c.isGroup) continue;
      for (final addrs in c.transportAddresses.values) {
        for (final addr in addrs) {
          if (addr.isEmpty) continue;
          final at = addr.indexOf('@');
          bareOfAccepted.add(at > 0 ? addr.substring(0, at) : addr);
        }
      }
    }
    if (bareOfAccepted.isEmpty) return;
    final removed = <String>[];
    _contacts.removeWhere((c) {
      if (!c.isPending || c.isGroup) return false;
      for (final addrs in c.transportAddresses.values) {
        for (final addr in addrs) {
          if (addr.isEmpty) continue;
          final at = addr.indexOf('@');
          final bare = at > 0 ? addr.substring(0, at) : addr;
          if (bareOfAccepted.contains(bare)) {
            removed.add(c.id);
            return true;
          }
        }
      }
      return false;
    });
    for (final id in removed) {
      unawaited(LocalStorageService().deleteContact(id));
    }
    if (removed.isNotEmpty) {
      debugPrint('[ContactManager] Dropped ${removed.length} stale pending duplicate(s)');
    }
  }

  @override
  Future<void> addContact(Contact contact) async {
    // Prevent duplicate contacts with the same ID.
    if (_idIndex.containsKey(contact.id)) return;
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

  /// Indexed pubkey lookup. `_addressIndex` already stores entries keyed
  /// by the bare pubkey part of each Nostr address (see [_indexContact]),
  /// so we just lowercase the input and hit the same map — O(1) instead
  /// of the linear fallback in the base class.
  @override
  Contact? findByPubkey(String hexPubkey) {
    if (hexPubkey.isEmpty) return null;
    return _addressIndex[hexPubkey.toLowerCase()];
  }
}
