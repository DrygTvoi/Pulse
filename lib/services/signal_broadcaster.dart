import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../models/identity.dart';
import '../models/user_status.dart';
import '../adapters/inbox_manager.dart';
import '../adapters/firebase_adapter.dart';
import '../adapters/nostr_adapter.dart';
import '../adapters/session_adapter.dart';
import '../adapters/pulse_adapter.dart';
import '../constants.dart';
import 'key_manager.dart';
import 'connectivity_probe_service.dart';
import 'ice_server_config.dart';
import 'app_lifecycle_service.dart';

/// Handles all *outgoing* signals: typing indicators, heartbeats, status/profile
/// broadcasts, group signals, delivery ACKs, reactions, edits, and more.
///
/// Owns the typing + heartbeat timer state. ChatController delegates all signal
/// sending here; public API is unchanged.
class SignalBroadcaster {
  final KeyManager _keys;
  final Identity? Function() _getIdentity;
  final String Function() _getSelfId;

  static const _secureStorage = FlutterSecureStorage();
  static const _kDefaultNostrRelay = kDefaultNostrRelay;

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  // Online status
  final Map<String, DateTime> _lastSeen = {};

  // Typing state (1-on-1)
  final Map<String, bool> _isTypingMap = {};
  final Map<String, Timer> _typingTimers = {};

  // Group typing state: groupId → { memberId → expiry timer }
  final Map<String, Map<String, Timer>> _groupTypingMembers = {};

  // Heartbeat timer
  Timer? _heartbeatTimer;

  SignalBroadcaster({
    required KeyManager keys,
    required Identity? Function() getIdentity,
    required String Function() getSelfId,
  })  : _keys = keys,
        _getIdentity = getIdentity,
        _getSelfId = getSelfId;

  // ── Online status ────────────────────────────────────────────────────────

  bool isOnline(String contactId) {
    final last = _lastSeen[contactId];
    if (last == null) return false;
    return DateTime.now().difference(last).inSeconds < 90;
  }

  String lastSeenLabel(String contactId) {
    final last = _lastSeen[contactId];
    if (last == null) return '';
    final diff = DateTime.now().difference(last);
    if (diff.inSeconds < 60) return 'online';
    if (diff.inSeconds < 90) return 'just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    return 'last seen ${diff.inHours}h ago';
  }

  void updateLastSeen(String contactId) {
    _lastSeen[contactId] = DateTime.now();
  }

  // ── Typing state ─────────────────────────────────────────────────────────

  bool isContactTyping(String contactId) => _isTypingMap[contactId] ?? false;

  /// Currently typing member IDs for a group chat.
  Set<String> getGroupTypingMembers(String groupId) =>
      _groupTypingMembers[groupId]?.keys.toSet() ?? const {};

  /// Process an incoming typing event and update local state.
  /// For groups, pass [memberId] to track per-member typing.
  /// Calls [onTypingChanged] with the targetId when state changes.
  void handleTypingEvent(
      String targetId, void Function(String) onTypingChanged,
      {String? memberId}) {
    // Group typing: track individual member
    if (memberId != null) {
      final members = _groupTypingMembers.putIfAbsent(targetId, () => {});
      members[memberId]?.cancel();
      members[memberId] = Timer(const Duration(seconds: 4), () {
        members.remove(memberId);
        if (members.isEmpty) {
          _groupTypingMembers.remove(targetId);
          _isTypingMap.remove(targetId);
        }
        onTypingChanged(targetId);
      });
      _isTypingMap[targetId] = true;
      onTypingChanged(targetId);
      return;
    }
    // 1-on-1 typing
    _isTypingMap[targetId] = true;
    onTypingChanged(targetId);
    _typingTimers[targetId]?.cancel();
    // Evict oldest entries when map grows too large.
    if (_typingTimers.length >= 200) {
      final oldest = _typingTimers.keys.first;
      _typingTimers[oldest]?.cancel();
      _typingTimers.remove(oldest);
      _isTypingMap.remove(oldest);
    }
    _typingTimers[targetId] = Timer(const Duration(seconds: 4), () {
      _isTypingMap.remove(targetId);
      onTypingChanged(targetId);
    });
  }

  /// Clear typing state for a contact (e.g. when their message arrives).
  /// For groups, pass [groupId] to clear only that member from the group.
  void clearTyping(String contactId, void Function(String) onTypingChanged,
      {String? groupId}) {
    if (groupId != null) {
      final members = _groupTypingMembers[groupId];
      if (members != null && members.containsKey(contactId)) {
        members[contactId]?.cancel();
        members.remove(contactId);
        if (members.isEmpty) {
          _groupTypingMembers.remove(groupId);
          _isTypingMap.remove(groupId);
        }
        onTypingChanged(groupId);
      }
      return;
    }
    if (_isTypingMap.containsKey(contactId)) {
      _isTypingMap.remove(contactId);
      _typingTimers[contactId]?.cancel();
      _typingTimers.remove(contactId);
      onTypingChanged(contactId);
    }
  }

  // ── Heartbeats ───────────────────────────────────────────────────────────

  void startHeartbeats(List<Contact> Function() contactsGetter) {
    _heartbeatContactsGetter = contactsGetter;
    AppLifecycleService.instance.removeListener(_onLifecycleChange);
    AppLifecycleService.instance.addListener(_onLifecycleChange);
    _heartbeatTimer?.cancel();
    if (AppLifecycleService.instance.isPaused) {
      // Already backgrounded — wait for resume to start ticking.
      return;
    }
    // Fire immediately so contacts see us online right away.
    unawaited(_sendHeartbeats(contactsGetter()));
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      unawaited(_sendHeartbeats(contactsGetter()));
    });
  }

  void stopHeartbeats() {
    AppLifecycleService.instance.removeListener(_onLifecycleChange);
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatContactsGetter = null;
  }

  List<Contact> Function()? _heartbeatContactsGetter;

  /// Pause heartbeats while backgrounded — peer "is online" status is best-
  /// effort; missing 5-30 minutes of beats during background isn't worth
  /// the radio wakeups + battery cost. Resumes immediately on foreground
  /// with one fresh beat so contacts see us back online.
  void _onLifecycleChange() {
    final getter = _heartbeatContactsGetter;
    if (getter == null) return;
    if (AppLifecycleService.instance.isPaused) {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    } else if (_heartbeatTimer == null) {
      unawaited(_sendHeartbeats(getter()));
      _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (_) {
        unawaited(_sendHeartbeats(getter()));
      });
    }
  }

  Future<void> _sendHeartbeats(List<Contact> contacts) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final futures = <Future>[];
    for (final contact in contacts) {
      if (contact.isGroup) continue;
      futures.add(_sendSignalTo(contact, 'heartbeat',
          {'from': selfId, 'ts': ts}));
    }
    await Future.wait(futures);
  }

  // Per-contact heartbeat throttle: contactId → last sent timestamp
  final Map<String, int> _lastHbSent = {};

  /// Send a heartbeat to a single contact (e.g. when opening their chat).
  /// Throttled to at most once per 30 seconds per contact.
  Future<void> sendHeartbeatTo(Contact contact) async {
    if (contact.isGroup) return;
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastHbSent[contact.id] ?? 0;
    if (now - last < 30000) return; // throttle 30s
    _lastHbSent[contact.id] = now;
    await _sendSignalTo(contact, 'heartbeat', {'from': selfId, 'ts': now});
  }

  // ── Typing ────────────────────────────────────────────────────────────────

  Future<void> sendTypingSignal(Contact contact,
      List<Contact> Function() contactsGetter) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    if (contact.isGroup) {
      final memberContacts = contactsGetter()
          .where((c) => !c.isGroup && contact.members.contains(c.id))
          .toList();
      final payload = {'from': selfId, 'groupId': contact.id};
      await Future.wait(
          memberContacts.map((m) => _sendSignalTo(m, 'typing', payload)));
    } else {
      await _sendSignalTo(contact, 'typing', {'from': selfId});
    }
  }

  // ── Status / Profile ──────────────────────────────────────────────────────

  Future<void> broadcastStatus(
      UserStatus status, List<Contact> contacts) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    for (final contact in contacts) {
      if (contact.isGroup) continue;
      await _sendSignalTo(contact, 'status_update', status.toJson());
    }
  }

  Future<void> broadcastProfile(
      String name, String about, List<Contact> contacts,
      {String avatarB64 = ''}) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final payload = <String, dynamic>{'name': name, 'about': about};
    if (avatarB64.isNotEmpty) payload['avatar'] = avatarB64;
    final targets = contacts.where((c) => !c.isGroup).toList();
    await Future.wait(
        targets.map((c) => _sendSignalTo(c, 'profile_update', payload)));
  }

  Future<void> broadcastAddressUpdate(
      List<Contact> contacts, String selfId, List<String> allAddresses,
      {Map<String, List<String>>? selfTransportAddresses,
       List<String>? selfTransportPriority,
       String? nostrPubkey}) async {
    if (selfId.isEmpty || allAddresses.isEmpty) return;
    final payload = <String, dynamic>{
      // New format: per-transport address map
      if (selfTransportAddresses != null)
        'transportAddresses': selfTransportAddresses,
      if (selfTransportPriority != null)
        'transportPriority': selfTransportPriority,
      // Nostr secp256k1 pubkey for HMAC signing (may differ from Pulse pubkey)
      if (nostrPubkey != null && nostrPubkey.isNotEmpty)
        'nostrPubkey': nostrPubkey,
      // Backward compat: flat address list for old clients
      'primary': selfId,
      'all': allAddresses,
    };
    // Skip-if-same: heartbeat fires every 2 min even when nothing about our
    // address map changed. Re-broadcasting an identical payload to 100
    // contacts × 4 transports each is pure waste. Hash the payload and
    // bail if it matches the last one we sent.
    final fingerprint = _fingerprintPayload(payload);
    if (fingerprint == _lastAddrBroadcastFp &&
        DateTime.now().difference(_lastAddrBroadcastAt ?? DateTime(0)) <
            const Duration(minutes: 30)) {
      return;
    }
    _lastAddrBroadcastFp = fingerprint;
    _lastAddrBroadcastAt = DateTime.now();

    // Batch to avoid opening 100+ connections at once on large contact lists.
    final targets = contacts.where((c) => !c.isGroup).toList();
    const int batchSize = 20;
    for (var i = 0; i < targets.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, targets.length);
      final batch = targets.sublist(i, end);
      // addr_update is critical — send via ALL transports so the receiver gets it.
      await Future.wait(batch.map((c) => _sendSignalToAll(c, 'addr_update', payload)));
      if (end < targets.length) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  String? _lastAddrBroadcastFp;
  DateTime? _lastAddrBroadcastAt;
  String _fingerprintPayload(Map<String, dynamic> payload) {
    // A stable canonical JSON string is enough of a fingerprint — the
    // payload is small (<1 KB typical) and we only compare strings.
    return jsonEncode(payload);
  }

  /// Public wrapper around [_sendSignalToAll] for callers outside this file.
  /// Pushes [payload] as [type] to every transport known for [contact].
  /// Set [pqcWrap] to false for signals that must stay decryptable even
  /// when the Kyber session is broken (e.g. `sys_keys` recovery push).
  Future<void> sendSignalToAllTransports(
          Contact contact, String type, Map<String, dynamic> payload,
          {bool pqcWrap = true}) =>
      _sendSignalToAll(contact, type, payload, pqcWrap: pqcWrap);

  /// Send a signal via ALL available transports for a contact.
  /// Used for critical signals like addr_update that must reach the recipient.
  Future<void> _sendSignalToAll(
      Contact contact, String type, Map<String, dynamic> payload,
      {bool pqcWrap = true}) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;

    // Pre-sign the payload once — used for non-Nostr transports.
    Map<String, dynamic>? signedPayload;
    try {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final selfPubkey = privkey.isNotEmpty ? deriveNostrPubkeyHex(privkey) : null;
      signedPayload = await _keys.signPayload(contact, type, payload, selfPubkey);
    } catch (e) {
      debugPrint('[Broadcaster] _sendSignalToAll: signing failed: $e');
    }
    final effectivePayload = pqcWrap
        ? await _maybePqcWrap(signedPayload ?? payload, contact.databaseId)
        : (signedPayload ?? payload);

    // Developer mode: check adapter toggles
    final prefs = await _getPrefs();
    final devModeOn = prefs.getBool('dev_mode_enabled') ?? false;

    // Iterate ALL addresses across ALL transports
    for (final transport in contact.transportPriority) {
      if (devModeOn && !(prefs.getBool('dev_adapter_$transport') ?? true)) continue;
      for (final addr in contact.transportAddresses[transport] ?? []) {
        try {
          final built = await _buildSenderForAddress(addr);
          if (built == null) continue;
          await built.sender.initializeSender(built.apiKey);
          final ok = await built.sender.sendSignal(
              addr, addr, selfId, type, effectivePayload);
          if (ok) {
            debugPrint('[Broadcaster] Signal $type delivered via $transport: $addr');
          }
        } catch (e) {
          debugPrint('[Broadcaster] Signal $type to $addr failed: $e');
        }
      }
    }
  }

  /// Sends our TURN server list to [contact] after a call connects via TURN.
  /// Enables organic peer exchange: each successfully used TURN server is
  /// shared so contacts can try it on future calls even if it's not in the
  /// default list.
  Future<void> broadcastTurnToContact(Contact contact) async {
    final identity = _getIdentity();
    final selfId   = _getSelfId();
    if (identity == null || selfId.isEmpty || contact.isGroup) return;

    // Only share TURN servers from static well-known presets.
    // NIP-117-discovered / probe-discovered / peer-received servers are
    // excluded: they may be attacker-controlled and would propagate transitively
    // to all contacts (HIGH-3 transitive TURN poisoning).
    final prefs = await _getPrefs();
    final enabled = prefs.getStringList('turn_presets_enabled') ?? ['openrelay', 'freestun'];
    final turnServers = <Map<String, dynamic>>[];
    for (final preset in IceServerConfig.turnPresets) {
      if (!enabled.contains(preset['id'] as String)) continue;
      for (final s in preset['servers'] as List) {
        turnServers.add(Map<String, dynamic>.from(s as Map));
      }
    }
    if (turnServers.length > 10) turnServers.length = 10;
    if (turnServers.isEmpty) return;

    await _sendSignalTo(contact, 'turn_exchange', {'servers': turnServers});
    debugPrint('[Broadcaster] Shared ${turnServers.length} TURN '
        'server(s) with ${contact.name}');
  }

  Future<void> broadcastWorkingRelays(List<Contact> contacts) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final probe = ConnectivityProbeService.instance.lastResult;
    final relays = [...probe.nostrRelays, ...probe.torNostrRelays];
    if (relays.isEmpty) return;
    final targets = contacts
        .where((c) =>
            !c.isGroup &&
            (c.provider == 'Nostr' || c.provider == 'Session'))
        .toList();
    await Future.wait(
        targets.map((c) => _sendSignalTo(c, 'relay_exchange', {'relays': relays})));
    debugPrint(
        '[Broadcaster] Shared ${relays.length} relay(s) with ${targets.length} contact(s)');
  }

  /// Share known Blossom servers with a contact (peer exchange).
  Future<void> broadcastBlossomServers(Contact contact, List<String> servers) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty || servers.isEmpty) return;
    await _sendSignalTo(contact, 'blossom_exchange', {'servers': servers});
    debugPrint('[Broadcaster] Shared ${servers.length} Blossom server(s) with ${contact.name}');
  }

  // ── Group signals ─────────────────────────────────────────────────────────

  Future<void> sendGroupInvite(
      Contact target, Contact group, List<Contact> allContacts) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final memberAddresses = _buildMemberAddresses(group, allContacts);
    final memberNames = _buildMemberNames(group, allContacts);
    await _sendSignalTo(target, 'group_invite', {
      'groupId': group.id,
      'name': group.name,
      'members': group.members,
      if (group.creatorId != null) 'creatorId': group.creatorId,
      if (group.memberPubkeys.isNotEmpty)
        'memberPubkeys': Map<String, String>.from(group.memberPubkeys),
      if (memberAddresses.isNotEmpty) 'memberAddresses': memberAddresses,
      if (memberNames.isNotEmpty) 'memberNames': memberNames,
      // Carry the call architecture + Pulse server endpoint so every
      // joiner stores the same flag and routes their own calls the same
      // way as the creator. Empty string = legacy / unspecified → readers
      // fall back to 'sfu' for backward compat.
      if (group.groupCallMode.isNotEmpty) 'groupCallMode': group.groupCallMode,
      if (group.groupServerUrl.isNotEmpty) 'groupServerUrl': group.groupServerUrl,
      if (group.groupServerInvite.isNotEmpty)
        'groupServerInvite': group.groupServerInvite,
    });
    debugPrint('[Broadcaster] Sent group invite to ${target.name} for "${group.name}"');
  }

  /// For every member UUID in [group.members] that we have as a local
  /// contact, copy their `transportAddresses` into a map keyed by UUID.
  /// Lets invitees auto-create pending contacts for group members they
  /// don't yet know, so group sends don't silently drop that recipient.
  /// Public alias for callers outside this file (e.g. invite-link builder)
  /// so they don't need to duplicate the address-collection logic.
  Map<String, Map<String, List<String>>> buildMemberAddressesForInvite(
          Contact group, List<Contact> allContacts) =>
      _buildMemberAddresses(group, allContacts);

  Map<String, Map<String, List<String>>> _buildMemberAddresses(
      Contact group, List<Contact> allContacts) {
    final out = <String, Map<String, List<String>>>{};
    for (final uuid in group.members) {
      Contact? mc;
      for (final c in allContacts) {
        if (c.isGroup) continue;
        if (c.id == uuid) {
          mc = c;
          break;
        }
      }
      if (mc == null || mc.transportAddresses.isEmpty) continue;
      out[uuid] = mc.transportAddresses.map(
          (k, v) => MapEntry(k, List<String>.from(v)));
    }
    return out;
  }

  /// Maps each member UUID → the display name we have for that contact
  /// locally. Lets invitees / receivers populate auto-pending member
  /// contacts with the real name instead of the "Member <pubkey>" stub —
  /// otherwise users in the group whose contact isn't in YOUR address book
  /// show up as gibberish like "Member 30bb9a6e".
  ///
  /// Skip empty / placeholder names so we never overwrite a better local
  /// name with our own placeholder. Self isn't included — we'd be naming
  /// ourselves to ourselves.
  Map<String, String> _buildMemberNames(
      Contact group, List<Contact> allContacts) {
    final out = <String, String>{};
    for (final uuid in group.members) {
      Contact? mc;
      for (final c in allContacts) {
        if (c.isGroup) continue;
        if (c.id == uuid) {
          mc = c;
          break;
        }
      }
      if (mc == null) continue;
      final name = mc.name.trim();
      if (name.isEmpty) continue;
      // Skip the auto-generated "Member <pubkey>" stub — sending it would
      // overwrite a real name on the receiving side if their ContactManager
      // happens to have one.
      if (RegExp(r'^Member [0-9a-f]{4,}$').hasMatch(name)) continue;
      out[uuid] = name;
    }
    return out;
  }

  /// Broadcast a group_update to [recipientMemberIds] if given, else to
  /// everyone currently in `group.members`. The override is needed for
  /// tombstone ("delete group") sends where the NEW payload has
  /// `members: []` but we still need to reach the *old* members to tell
  /// them the group is gone.
  Future<void> broadcastGroupUpdate(
      Contact group, List<Contact> allContacts,
      {Iterable<String>? recipientMemberIds, String? avatar}) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final memberAddresses = _buildMemberAddresses(group, allContacts);
    final memberNames = _buildMemberNames(group, allContacts);
    final payload = <String, dynamic>{
      'groupId': group.id,
      'name': group.name,
      'members': group.members,
      if (group.creatorId != null) 'creatorId': group.creatorId,
      if (group.memberPubkeys.isNotEmpty)
        'memberPubkeys': Map<String, String>.from(group.memberPubkeys),
      if (memberAddresses.isNotEmpty) 'memberAddresses': memberAddresses,
      if (memberNames.isNotEmpty) 'memberNames': memberNames,
      // Mirror invite-side fields so a client that joined via a *link*
      // (no group_invite signal received) still learns the call mode +
      // Pulse server when the creator next broadcasts an update.
      if (group.groupCallMode.isNotEmpty) 'groupCallMode': group.groupCallMode,
      if (group.groupServerUrl.isNotEmpty) 'groupServerUrl': group.groupServerUrl,
      if (group.groupServerInvite.isNotEmpty)
        'groupServerInvite': group.groupServerInvite,
      // Caller passes the avatar only when it actually changed, so we don't
      // re-broadcast a 30 KiB blob on every membership tweak. Cap at 32 KiB
      // to keep us under nos.lol's 64 KiB Nostr-event ceiling.
      if (avatar != null && avatar.isNotEmpty && avatar.length <= 32 * 1024)
        'avatar': avatar,
    };
    // recipientMemberIds is a per-call override used by deleteGroup to send
    // the tombstone (members:[]) to the OLD roster. Otherwise, route via
    // the helper which handles UUID + pubkey-fallback lookup.
    final List<Contact> recipients;
    if (recipientMemberIds != null) {
      final set = recipientMemberIds.toSet();
      recipients = allContacts
          .where((c) => !c.isGroup && set.contains(c.id))
          .toList();
    } else {
      recipients = _resolveGroupRecipients(group, allContacts);
    }
    await Future.wait(
        recipients.map((c) => _sendSignalTo(c, 'group_update', payload)));
    debugPrint(
        '[Broadcaster] Broadcast membership update for ${group.name} to ${recipients.length} members '
        '(payload members=${group.members.length})');
  }

  Future<void> sendGroupHistory(
      Contact target, Contact group, List<Message> messages) async {
    // Sending history to new members violates group forward secrecy.
    // Messages were stored as plaintext locally; forwarding them exposes pre-join
    // content to the new member and to any compromised relay in the chain.
    // New members start fresh — they see only messages sent after joining.
    debugPrint('[Broadcaster] sendGroupHistory suppressed (forward secrecy)');
  }

  Future<void> markGroupMessagesRead(
      Contact group, List<Message> messages, List<Contact> allContacts,
      String selfId) async {
    if (!group.isGroup) return;
    for (final msg in List.of(messages)) {
      if (msg.senderId == selfId || msg.senderId.isEmpty) continue;
      Contact? senderContact;
      for (final c in allContacts) {
        if (c.databaseId == msg.senderId ||
            c.databaseId.split('@').first == msg.senderId) {
          senderContact = c;
          break;
        }
      }
      if (senderContact == null) continue;
      unawaited(sendGroupReadReceipt(senderContact, group.id, msg.id));
    }
  }

  Future<void> sendGroupReadReceipt(
      Contact senderContact, String groupId, String msgId) {
    final selfId = _getSelfId();
    return _sendSignalTo(senderContact, 'msg_read',
        {'from': selfId, 'groupId': groupId, 'msgId': msgId});
  }

  // ── 1-on-1 receipts ───────────────────────────────────────────────────────

  Future<void> sendReadReceipt(Contact contact) {
    final selfId = _getSelfId();
    return _sendSignalTo(contact, 'msg_read', {'from': selfId});
  }

  Future<void> sendDeliveryAck(Contact contact, String msgId,
      {String? groupId}) {
    final selfId = _getSelfId();
    return _sendSignalTo(contact, 'msg_ack', {
      'msgId': msgId,
      'from': selfId,
      'groupId': groupId,
    });
  }

  // ── Reactions / Edit / Delete ─────────────────────────────────────────────

  // Edit/delete/reaction use _sendSignalToAll so the signal is delivered via
  // both primary (Pulse) and alternate transports (Nostr).  Pulse signals are
  // real-time only — they are dropped when the recipient is briefly offline
  // during its connection cycle.  Sending via all transports ensures delivery.

  // _sid is attached as a safety net: even though we now send these signals
  // down a single transport (stop-on-first-success), a relay may still fan
  // them out through multiple subscriptions on the receiver side. Dedup
  // catches those without the receiver noticing.
  String _newSid() => _uuid.v4();
  static const _uuid = Uuid();

  Future<void> sendReactionSignal(
      Contact contact, String msgId, String emoji, String selfId,
      {bool remove = false, String? groupId}) {
    return _sendSignalTo(contact, 'reaction', {
      '_sid': _newSid(),
      'msgId': msgId,
      'emoji': emoji,
      'from': selfId,
      if (remove) 'remove': true,
      'groupId': groupId,
    });
  }

  Future<void> sendEditSignal(Contact contact, String msgId, String text) {
    final selfId = _getSelfId();
    return _sendSignalTo(contact, 'edit',
        {'_sid': _newSid(), 'msgId': msgId, 'text': text, 'from': selfId});
  }

  /// Resolve a group's `members` (UUIDs from the creator's perspective) to
  /// local Contact objects. Falls back to pubkey lookup when no contact
  /// matches by UUID — necessary for invite-link joiners whose hidden
  /// routing contacts are keyed by pubkey rather than the creator's UUID.
  List<Contact> _resolveGroupRecipients(
      Contact group, List<Contact> allContacts) {
    final byUuid = <String, Contact>{};
    final byPubkey = <String, Contact>{};
    for (final c in allContacts) {
      if (c.isGroup) continue;
      byUuid[c.id] = c;
      for (final addrs in c.transportAddresses.values) {
        for (final addr in addrs) {
          final at = addr.indexOf('@');
          final pub = (at > 0 ? addr.substring(0, at) : addr).toLowerCase();
          if (pub.isNotEmpty) byPubkey[pub] = c;
        }
      }
    }
    final selfPub = _selfPubkeyLower();
    final out = <Contact>{};
    final seenUuids = <String>{};
    // Pass 1 — group.members (UUID-keyed). Cross-device UUID match first,
    // pubkey fallback via memberPubkeys[uuid].
    for (final uuid in group.members) {
      seenUuids.add(uuid);
      final direct = byUuid[uuid];
      if (direct != null) {
        out.add(direct);
        continue;
      }
      final pub = group.memberPubkeys[uuid]?.toLowerCase();
      if (pub != null && pub != selfPub) {
        final viaPub = byPubkey[pub];
        if (viaPub != null) out.add(viaPub);
      }
    }
    // Pass 2 — sweep memberPubkeys for entries whose UUID was NOT in
    // group.members (creator's local roster doesn't always contain itself
    // or every member from every device's perspective). Without this, a
    // group whose creator forgot to add themselves to `members` causes
    // every fan-out to silently skip the creator — sfu_invite never
    // reaches them, the pairwise sender_key dist misses them, etc. Safe
    // because we still skip self by pubkey and dedup against `out`.
    for (final entry in group.memberPubkeys.entries) {
      if (seenUuids.contains(entry.key)) continue;
      final pub = entry.value.toLowerCase();
      if (pub.isEmpty || pub == selfPub) continue;
      final viaPub = byPubkey[pub];
      if (viaPub != null) out.add(viaPub);
    }
    return out.toList();
  }

  String _selfPubkeyLower() {
    final selfId = _getSelfId();
    final at = selfId.indexOf('@');
    return (at > 0 ? selfId.substring(0, at) : selfId).toLowerCase();
  }

  Future<void> sendGroupEditSignal(Contact group, String msgId, String text,
      List<Contact> allContacts) async {
    final selfId = _getSelfId();
    final sid = _newSid();
    final memberContacts = _resolveGroupRecipients(group, allContacts);
    await Future.wait(memberContacts.map((c) => _sendSignalTo(c, 'edit', {
          '_sid': sid,
          'msgId': msgId,
          'text': text,
          'from': selfId,
          'groupId': group.id,
        })));
  }

  Future<void> sendDeleteSignal(Contact contact, String msgId,
      {String? groupId}) {
    final selfId = _getSelfId();
    return _sendSignalTo(contact, 'msg_delete', {
      '_sid': _newSid(),
      'msgId': msgId,
      'groupId': groupId,
      'from': selfId,
    });
  }

  Future<void> broadcastGroupDelete(
      Contact group, String msgId, List<Contact> allContacts) async {
    final selfId = _getSelfId();
    final memberContacts = _resolveGroupRecipients(group, allContacts);
    await Future.wait(memberContacts.map((c) => _sendSignalToAll(c, 'msg_delete', {
          'msgId': msgId,
          'groupId': group.id,
          'from': selfId,
        })));
  }

  Future<void> sendTtlSignal(Contact contact, int seconds) =>
      _sendSignalTo(contact, 'ttl_update', {'seconds': seconds});

  /// Broadcast an SFU call invite to every group member. Carries the SFU
  /// room id + token in cleartext (HMAC-signed by the existing signal
  /// signing layer) so receivers can join the same room. Until SFU media
  /// metadata gets a proper E2EE wrapper this leaks "a call started in
  /// group X" to the Pulse relay; the actual media stream over SFU is
  /// still per-pair encrypted by Signal at the application layer above.
  Future<void> broadcastSfuInvite(Contact group, String roomId, String token,
      List<Contact> allContacts,
      {bool isVideoCall = false}) async {
    if (!group.isGroup) return;
    final members = _resolveGroupRecipients(group, allContacts);
    if (members.isEmpty) return;
    final sid = _newSid();
    // Use _sendSignalTo (single best transport) instead of _sendSignalToAll:
    // call invites are real-time so an offline recipient isn't going to
    // join anyway, and All-transport delivery makes every recipient ring
    // 2-3 times (one per transport) which is the "повторные уведомления"
    // bug the user hit. The `_sid` field lets the dispatcher dedupe in
    // case the same invite is replayed.
    await Future.wait(members.map((c) => _sendSignalTo(c, 'sfu_invite', {
          '_sid': sid,
          'groupId': group.id,
          'sfuRoomId': roomId,
          'sfuToken': token,
          'isVideoCall': isVideoCall,
        })));
  }

  /// Broadcast a TTL change for a group to every member. Each member's
  /// receive-side handler applies the same TTL to their copy of the group
  /// chat, so disappearing-messages settings stay consistent across the
  /// whole group instead of being a per-device toggle.
  Future<void> broadcastGroupTtl(
      Contact group, int seconds, List<Contact> allContacts) async {
    if (!group.isGroup) return;
    final members = _resolveGroupRecipients(group, allContacts);
    if (members.isEmpty) return;
    await Future.wait(members.map((c) => _sendSignalToAll(c, 'ttl_update', {
          'seconds': seconds,
          'groupId': group.id,
        })));
  }

  Future<void> sendP2PSignal(
      Contact contact, String type, Map<String, dynamic> payload) =>
      _sendSignalTo(contact, type, payload);

  // ── Internal: sender helper ───────────────────────────────────────────────

  /// PQC-wrap a signal payload if the contact has a Kyber public key.
  /// Falls back to the original payload on error or missing key.
  Future<Map<String, dynamic>> _maybePqcWrap(
      Map<String, dynamic> payload, String contactId) async {
    if (!await _keys.hasPqcKeyAsync(contactId)) return payload;
    try {
      final wrapped = await _keys.pqcWrap(jsonEncode(payload), contactId);
      if (wrapped.startsWith('PQC2||')) return {'_pqc_wrapped': wrapped};
    } catch (e) {
      debugPrint('[Broadcaster] PQC signal wrap failed: $e');
    }
    return payload;
  }

  /// Build a (MessageSender, apiKey) pair for a contact's provider.
  Future<({MessageSender sender, String apiKey})?> _buildSenderFor(
      Contact contact) async {
    final identity = _getIdentity();
    if (identity == null) return null;
    // Developer mode: skip disabled adapters.
    final prefs = await _getPrefs();
    if ((prefs.getBool('dev_mode_enabled') ?? false) &&
        !(prefs.getBool('dev_adapter_${contact.provider}') ?? true)) {
      debugPrint('[Dev] Adapter ${contact.provider} disabled — skipping signal');
      return null;
    }
    switch (contact.provider) {
      case 'Firebase':
        final token = identity.adapterConfig['token'] ?? '';
        return (sender: FirebaseInboxSender(), apiKey: token);
      case 'Nostr':
        final privkey =
            await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final relay = identity.adapterConfig['relay'] ?? _kDefaultNostrRelay;
        return (
          sender: NostrMessageSender(),
          apiKey: jsonEncode({'privkey': privkey, 'relay': relay})
        );
      case 'Session':
        final prefs = await _getPrefs();
        final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
        return (sender: SessionMessageSender(), apiKey: nodeUrl);
      case 'Pulse':
        final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
        final prefs = await _getPrefs();
        final serverUrl = prefs.getString('pulse_server_url') ?? '';
        return (sender: PulseMessageSender(), apiKey: jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
      default:
        return null;
    }
  }

  static final _sessionAddrRegex = RegExp(r'^[0-9a-f]{66}$');

  /// Build a (MessageSender, apiKey) pair from a raw address string.
  /// Used for retry through alternate addresses when primary delivery fails.
  Future<({MessageSender sender, String apiKey})?> _buildSenderForAddress(
      String address) async {
    final identity = _getIdentity();
    if (identity == null) return null;
    // Developer mode: resolve provider from address format and check toggle.
    final prefs = await _getPrefs();
    final devEnabled = !(prefs.getBool('dev_mode_enabled') ?? false);
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        _sessionAddrRegex.hasMatch(lower)) {
      if (!devEnabled && !(prefs.getBool('dev_adapter_Session') ?? true)) return null;
      final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
      return (sender: SessionMessageSender(), apiKey: nodeUrl);
    }
    if (lower.contains('@wss://') || lower.contains('@ws://')) {
      if (!devEnabled && !(prefs.getBool('dev_adapter_Nostr') ?? true)) return null;
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final identity = _getIdentity();
      final relay = identity?.adapterConfig['relay'] ?? _kDefaultNostrRelay;
      return (
        sender: NostrMessageSender(),
        apiKey: jsonEncode({'privkey': privkey, 'relay': relay})
      );
    }
    if (lower.contains('@https://') || lower.contains('@http://')) {
      // Pulse: 64-char hex pubkey @ https://server
      final atIdx = address.indexOf('@');
      final pubPart = atIdx > 0 ? address.substring(0, atIdx) : '';
      if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pubPart.toLowerCase())) {
        if (!devEnabled && !(prefs.getBool('dev_adapter_Pulse') ?? true)) return null;
        final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
        final serverUrl = atIdx > 0 ? address.substring(atIdx + 1) : '';
        return (sender: PulseMessageSender(), apiKey: jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
      }
      // Firebase fallback
      if (!devEnabled && !(prefs.getBool('dev_adapter_Firebase') ?? true)) return null;
      final token = identity.adapterConfig['token'] ?? '';
      return (sender: FirebaseInboxSender(), apiKey: token);
    }
    return null;
  }

  /// Sign + send a signal to a contact using transport-priority routing.
  /// Iterates transports in priority order; stops on first success.
  Future<void> _sendSignalTo(
      Contact contact, String type, Map<String, dynamic> payload) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    debugPrint('[Broadcaster] _sendSignalTo: type=$type contact=${contact.name} provider=${contact.provider} selfId=${selfId.substring(0, selfId.length.clamp(0, 16))}…');

    final prefs = await _getPrefs();
    final devModeOn = prefs.getBool('dev_mode_enabled') ?? false;

    // Pre-sign + PQC wrap once
    Map<String, dynamic> signedPayload = payload;
    try {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final selfPubkey = privkey.isNotEmpty ? deriveNostrPubkeyHex(privkey) : null;
      signedPayload = await _keys.signPayload(contact, type, payload, selfPubkey);
    } catch (_) {}
    final effectivePayload = await _maybePqcWrap(signedPayload, contact.databaseId);

    for (final transport in contact.transportPriority) {
      if (devModeOn && !(prefs.getBool('dev_adapter_$transport') ?? true)) continue;
      for (final addr in contact.transportAddresses[transport] ?? []) {
        try {
          final built = await _buildSenderForAddress(addr);
          if (built == null) continue;
          await built.sender.initializeSender(built.apiKey);
          // For Nostr transports, use unsigned payload (Schnorr-verified natively)
          final addrPayload = transport == 'Nostr'
              ? await _maybePqcWrap(payload, contact.databaseId)
              : effectivePayload;
          final ok = await built.sender.sendSignal(
              addr, addr, selfId, type, addrPayload);
          if (ok) {
            debugPrint('[Broadcaster] Signal $type delivered via $transport: $addr');
            return;  // stop on first success
          }
        } catch (e) {
          debugPrint('[Broadcaster] Signal $type to $addr failed: $e');
        }
      }
    }
    debugPrint('[Broadcaster] Signal $type to ${contact.name} failed on all transports');
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    _typingTimers.clear();
    _isTypingMap.clear();
    for (final members in _groupTypingMembers.values) {
      for (final t in members.values) {
        t.cancel();
      }
    }
    _groupTypingMembers.clear();
  }
}
