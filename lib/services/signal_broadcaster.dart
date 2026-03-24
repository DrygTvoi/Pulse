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
import '../adapters/waku_adapter.dart';
import '../adapters/oxen_adapter.dart';
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
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) {
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
    for (final contact in contacts) {
      if (contact.isGroup) continue;
      await _sendSignalTo(contact, 'heartbeat',
          {'from': selfId, 'ts': DateTime.now().millisecondsSinceEpoch});
    }
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
      List<Contact> contacts, String selfId, List<String> allAddresses) async {
    if (selfId.isEmpty || allAddresses.isEmpty) return;
    final payload = <String, dynamic>{
      'primary': selfId,
      'all': allAddresses,
    };
    final targets = contacts.where((c) => !c.isGroup).toList();
    await Future.wait(
        targets.map((c) => _sendSignalTo(c, 'addr_update', payload)));
  }

  /// Sends our TURN server list to [contact] after a call connects via TURN.
  /// Enables organic peer exchange: each successfully used TURN server is
  /// shared so contacts can try it on future calls even if it's not in the
  /// default list.
  Future<void> broadcastTurnToContact(Contact contact) async {
    final identity = _getIdentity();
    final selfId   = _getSelfId();
    if (identity == null || selfId.isEmpty || contact.isGroup) return;

    final allServers = await IceServerConfig.load();
    final turnServers = allServers
        .where((s) {
          final urls = s['urls'];
          final url  = urls is String ? urls : '';
          return url.startsWith('turn:') || url.startsWith('turns:');
        })
        .take(10)
        .toList();
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
            (c.provider == 'Nostr' || c.provider == 'Oxen'))
        .toList();
    await Future.wait(
        targets.map((c) => _sendSignalTo(c, 'relay_exchange', {'relays': relays})));
    debugPrint(
        '[Broadcaster] Shared ${relays.length} relay(s) with ${targets.length} contact(s)');
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
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    for (final msg in messages) {
      try {
        final text = msg.encryptedPayload;
        if (text.isEmpty) continue;
        if (text.startsWith('data:') || text.length > 4096) continue;
        await _sendSignalTo(target, 'msg', {
          '_group': group.id,
          'text': text,
          '_history': true,
        });
      } catch (e) {
        debugPrint('[Broadcaster] History sync failed for msg ${msg.id}: $e');
      }
    }
    debugPrint('[Broadcaster] Sent history to ${target.name}');
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

  Future<void> sendReactionSignal(
      Contact contact, String msgId, String emoji, String selfId,
      {bool remove = false, String? groupId}) {
    return _sendSignalTo(contact, 'reaction', {
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
        {'msgId': msgId, 'text': text, 'from': selfId});
  }

  Future<void> sendGroupEditSignal(Contact group, String msgId, String text,
      List<Contact> allContacts) async {
    final selfId = _getSelfId();
    final memberContacts = allContacts
        .where((c) => !c.isGroup && group.members.contains(c.id))
        .toList();
    await Future.wait(memberContacts.map((c) => _sendSignalTo(c, 'edit', {
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
    await Future.wait(memberContacts.map((c) => _sendSignalTo(c, 'msg_delete', {
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

  /// Build a (MessageSender, apiKey) pair for a contact's provider.
  Future<({MessageSender sender, String apiKey})?> _buildSenderFor(
      Contact contact) async {
    final identity = _getIdentity();
    if (identity == null) return null;
    switch (contact.provider) {
      case 'Firebase':
        final token = identity.adapterConfig['token'] ?? '';
        return (sender: FirebaseInboxSender(), apiKey: token);
      case 'Nostr':
        final privkey =
            await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay =
            prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
        return (
          sender: NostrMessageSender(),
          apiKey: jsonEncode({'privkey': privkey, 'relay': relay})
        );
      case 'Waku':
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl =
            prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        return (
          sender: WakuMessageSender(),
          apiKey: jsonEncode({'nodeUrl': nodeUrl, 'userId': userId})
        );
      case 'Oxen':
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('oxen_node_url') ?? '';
        return (sender: OxenMessageSender(), apiKey: nodeUrl);
      default:
        return null;
    }
  }

  /// Sign + send a signal to a contact.
  Future<void> _sendSignalTo(
      Contact contact, String type, Map<String, dynamic> payload) async {
    final identity = _getIdentity();
    final selfId = _getSelfId();
    if (identity == null || selfId.isEmpty) return;
    try {
      final built = await _buildSenderFor(contact);
      if (built == null) return;
      await built.sender.initializeSender(built.apiKey);

      var signedPayload = payload;
      if (contact.provider != 'Nostr') {
        final privkey =
            await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final selfPubkey =
            privkey.isNotEmpty ? deriveNostrPubkeyHex(privkey) : null;
        signedPayload = await _keys.signPayload(
            contact, type, payload, selfPubkey);
      }

      await built.sender.sendSignal(
          contact.databaseId, contact.databaseId, selfId, type, signedPayload);
    } catch (e) {
      debugPrint('[Broadcaster] Signal $type to ${contact.name} failed: $e');
    }
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
