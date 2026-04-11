import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Typing state
  final Map<String, bool> _isTypingMap = {};
  final Map<String, Timer> _typingTimers = {};

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

  /// Process an incoming typing event and update local state.
  /// Calls [onTypingChanged] with the targetId when state changes.
  void handleTypingEvent(
      String targetId, void Function(String) onTypingChanged) {
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

  // ── Heartbeats ───────────────────────────────────────────────────────────

  void startHeartbeats(List<Contact> Function() contactsGetter) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      unawaited(_sendHeartbeats(contactsGetter()));
    });
  }

  void stopHeartbeats() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
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
    final targets = contacts.where((c) => !c.isGroup).toList();
    // addr_update is critical — send via ALL transports so the receiver gets it.
    await Future.wait(targets.map((c) => _sendSignalToAll(c, 'addr_update', payload)));
  }

  /// Send a signal via ALL available transports for a contact.
  /// Used for critical signals like addr_update that must reach the recipient.
  Future<void> _sendSignalToAll(
      Contact contact, String type, Map<String, dynamic> payload) async {
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
    final effectivePayload =
        await _maybePqcWrap(signedPayload ?? payload, contact.databaseId);

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

  Future<void> sendGroupInvite(Contact target, Contact group) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    await _sendSignalTo(target, 'group_invite', {
      'groupId': group.id,
      'name': group.name,
      'members': group.members,
      if (group.creatorId != null) 'creatorId': group.creatorId,
    });
    debugPrint('[Broadcaster] Sent group invite to ${target.name} for "${group.name}"');
  }

  Future<void> broadcastGroupUpdate(
      Contact group, List<Contact> allContacts) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    final payload = <String, dynamic>{
      'groupId': group.id,
      'name': group.name,
      'members': group.members,
      if (group.creatorId != null) 'creatorId': group.creatorId,
    };
    final memberContacts = allContacts
        .where((c) => !c.isGroup && group.members.contains(c.id))
        .toList();
    await Future.wait(
        memberContacts.map((c) => _sendSignalTo(c, 'group_update', payload)));
    debugPrint(
        '[Broadcaster] Broadcast membership update for ${group.name} to ${memberContacts.length} members');
  }

  Future<void> sendGroupHistory(
      Contact target, Contact group, List<Message> messages) async {
    // BUG-4 fix: sending history to new members violates group forward secrecy.
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
    return _sendSignalToAll(senderContact, 'msg_read',
        {'from': selfId, 'groupId': groupId, 'msgId': msgId});
  }

  // ── 1-on-1 receipts ───────────────────────────────────────────────────────

  Future<void> sendReadReceipt(Contact contact) {
    final selfId = _getSelfId();
    return _sendSignalToAll(contact, 'msg_read', {'from': selfId});
  }

  Future<void> sendDeliveryAck(Contact contact, String msgId,
      {String? groupId}) {
    final selfId = _getSelfId();
    return _sendSignalToAll(contact, 'msg_ack', {
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

  Future<void> sendReactionSignal(
      Contact contact, String msgId, String emoji, String selfId,
      {bool remove = false, String? groupId}) {
    return _sendSignalToAll(contact, 'reaction', {
      'msgId': msgId,
      'emoji': emoji,
      'from': selfId,
      if (remove) 'remove': true,
      'groupId': groupId,
    });
  }

  Future<void> sendEditSignal(Contact contact, String msgId, String text) {
    final selfId = _getSelfId();
    return _sendSignalToAll(contact, 'edit',
        {'msgId': msgId, 'text': text, 'from': selfId});
  }

  Future<void> sendGroupEditSignal(Contact group, String msgId, String text,
      List<Contact> allContacts) async {
    final selfId = _getSelfId();
    final memberContacts = allContacts
        .where((c) => !c.isGroup && group.members.contains(c.id))
        .toList();
    await Future.wait(memberContacts.map((c) => _sendSignalToAll(c, 'edit', {
          'msgId': msgId,
          'text': text,
          'from': selfId,
          'groupId': group.id,
        })));
  }

  Future<void> sendDeleteSignal(Contact contact, String msgId,
      {String? groupId}) {
    final selfId = _getSelfId();
    return _sendSignalToAll(contact, 'msg_delete', {
      'msgId': msgId,
      'groupId': groupId,
      'from': selfId,
    });
  }

  Future<void> broadcastGroupDelete(
      Contact group, String msgId, List<Contact> allContacts) async {
    final selfId = _getSelfId();
    final memberContacts = allContacts
        .where((c) => !c.isGroup && group.members.contains(c.id))
        .toList();
    await Future.wait(memberContacts.map((c) => _sendSignalToAll(c, 'msg_delete', {
          'msgId': msgId,
          'groupId': group.id,
          'from': selfId,
        })));
  }

  Future<void> sendTtlSignal(Contact contact, int seconds) =>
      _sendSignalTo(contact, 'ttl_update', {'seconds': seconds});

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
  }
}
