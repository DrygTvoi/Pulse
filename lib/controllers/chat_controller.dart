import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:crypto/crypto.dart' as hash_lib;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:convert/convert.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/identity.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../models/message_envelope.dart';
import '../models/chat_room.dart';
import '../constants.dart';
import '../adapters/inbox_manager.dart';
import '../services/local_storage_service.dart';
import '../services/media_service.dart';
import '../adapters/firebase_adapter.dart';
import '../adapters/nostr_adapter.dart';
import '../adapters/session_adapter.dart';
import '../adapters/pulse_adapter.dart';
import '../adapters/lan_adapter.dart';
import '../services/session_key_service.dart';
import '../services/p2p_transport_service.dart';
import '../services/signal_service.dart';
import '../services/pqc_service.dart';
import '../services/crypto_layer.dart';
import '../services/network_monitor.dart';
import '../models/user_status.dart';
import '../services/status_service.dart';
import '../services/connectivity_probe_service.dart';
import '../services/rate_limiter.dart';
import '../services/chunk_assembler.dart';
import '../services/media_crypto_service.dart';
import '../services/blossom_service.dart';
import '../services/sentry_service.dart';
import '../services/voice_service.dart';
import '../services/sender_key_service.dart';
import '../services/signal_dispatcher.dart';
import '../services/ice_server_config.dart';
import '../models/contact_repository.dart';
// Facade services
import '../services/message_repository.dart';
import '../services/key_manager.dart';
import '../services/signal_broadcaster.dart';
import '../services/nip44_service.dart' as nip44;

enum ConnectionStatus { disconnected, connecting, connected }

class ChatController extends ChangeNotifier {
  static ChatController _instance = ChatController._create(ContactManager());
  factory ChatController() => _instance;
  ChatController._create(this._contacts);

  /// Constructor for unit testing — pass a [MockContactRepository].
  @visibleForTesting
  factory ChatController.forTesting(IContactRepository contacts) =>
      ChatController._create(contacts);

  /// Replace the singleton for testing. Call in setUp/tearDown.
  @visibleForTesting
  static void setInstanceForTesting(ChatController instance) =>
      _instance = instance;

  final IContactRepository _contacts;

  Identity? _identity;
  String _selfId = ''; // adapter-specific ID used as senderId in outgoing messages
  final SignalService _signalService = SignalService();
  StreamSubscription<void>? _bundleRefreshSub;
  final List<StreamSubscription> _messageSubs = [];
  final List<StreamSubscription> _signalSubs = [];
  final List<StreamSubscription> _healthSubs = [];
  final List<StreamSubscription> _dispatcherSubs = [];
  final Map<String, bool> _adapterHealth = {}; // addr → isHealthy
  List<String> _allAddresses = [];
  SignalDispatcher? _signalDispatcher;
  // PQC: contacts from whom we've successfully unwrapped a PQC message.
  // Only PQC-wrap outgoing messages to contacts in this set.
  final Set<String> _pqcConfirmed = {};


  // ── Facade services ────────────────────────────────────────────────────────
  late final MessageRepository _repo = MessageRepository();
  late final KeyManager _keys = KeyManager(_signalService, PqcService());
  late final SignalBroadcaster _broadcaster = SignalBroadcaster(
    keys: _keys,
    getIdentity: () => _identity,
    getSelfId: () => _selfId,
  );

  // Emits (from: oldAddr, to: newAddr) when automatic failover occurs.
  final StreamController<({String from, String to})> _failoverCtrl =
      StreamController.broadcast();
  Stream<({String from, String to})> get failoverEvents => _failoverCtrl.stream;

  // ── LAN fallback ──────────────────────────────────────────────────────────
  LanInboxReader?  _lanReader;
  LanMessageSender? _lanSender;
  bool _lanModeActive = false;
  bool _disposed = false; // guards notifyListeners in TTL callbacks
  String? _activeRoomId; // contact ID of the currently open chat screen

  // Per-room reaction version — incremented per storageKey so chat_screen
  // only rebuilds when ITS room's reactions change, not all rooms.
  final _reactionVersions = <String, int>{};
  int reactionVersionFor(String storageKey) => _reactionVersions[storageKey] ?? 0;

  final _editVersions = <String, int>{};
  int editVersionFor(String storageKey) => _editVersions[storageKey] ?? 0;

  // Timer-debounced notifyListeners — collapses rapid-fire updates into one
  // rebuild per 200ms window (≈1 frame at 5fps — imperceptible to users).
  Timer? _notifyTimer;
  void _scheduleNotify() {
    if (_disposed) return;
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 200), () {
      _notifyTimer = null;
      if (!_disposed) notifyListeners();
    });
  }

  /// Called by ChatScreen when it becomes the active/visible chat.
  void setActiveRoom(String? contactId) => _activeRoomId = contactId;

  /// True when all internet adapters are unreachable and LAN is being used.
  bool get lanModeActive => _lanModeActive;

  /// Whether the LAN adapter is enabled (persisted in SharedPreferences).
  static Future<bool> getLanModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLanModeEnabled) ?? true;
  }

  /// Enable or disable the LAN adapter and reconnect the inbox.
  Future<void> setLanModeEnabled(bool enabled) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_kLanModeEnabled, enabled);
    } catch (e) {
      debugPrint('[ChatController] setLanModeEnabled: prefs write failed: $e');
    }
    await reconnectInbox();
  }

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  // Emits every incoming message so UI can show in-app banners
  final StreamController<({String contactId, Message message})> _newMsgController =
      StreamController.broadcast();
  Stream<({String contactId, Message message})> get newMessages => _newMsgController.stream;

  // ── Incremental unread counts ──────────────────────────────────────────────
  final Map<String, int> _unreadCounts = {};
  final StreamController<String> _unreadChangedCtrl = StreamController.broadcast();
  /// Emits the contactId whose unread count changed.
  Stream<String> get unreadChanged => _unreadChangedCtrl.stream;
  /// O(1) lookup of unread message count for a contact.
  int getUnreadCount(String contactId) => _unreadCounts[contactId] ?? 0;

  // Emits contact name + databaseId when their Signal identity key changes
  final StreamController<({String contactName, String contactId})> _keyChangeCtrl = StreamController.broadcast();
  Stream<({String contactName, String contactId})> get keyChangeWarnings => _keyChangeCtrl.stream;

  // Emits a display message when an incoming signal fails MAC/integrity check
  final StreamController<String> _tamperWarningCtrl = StreamController.broadcast();
  Stream<String> get tamperWarnings => _tamperWarningCtrl.stream;

  // (SmartRouter delivery stats removed — transport-priority routing replaces promotion)

  // File transfer resume
  final Map<String, ({Contact contact, Uint8List bytes, String name})> _pendingSends = {};
  Timer? _stallCheckTimer;

  // Pagination delegation
  bool hasMoreHistory(String contactId) => _repo.hasMoreHistory(contactId);
  bool isLoadingMoreHistory(String contactId) => _repo.isLoadingMoreHistory(contactId);

  // Global dedup — circular buffer approach for O(1) eviction
  // ignore: prefer_collection_literals
  final _seenMsgIds = LinkedHashSet<String>();
  final _seenMsgIdsList = <String>[]; // mirrors insertion order for O(1) eviction
  final _e2eeFailCount = <String, int>{}; // consecutive decrypt failures per contact

  // Cached contact index with dirty flag — avoids rebuilding on every call
  HashMap<String, Contact>? _contactIndex;
  bool _contactIndexDirty = true;
  int _contactIndexCount = 0;

  // Cached sender instances per provider — avoids re-allocating on every send.
  NostrMessageSender? _cachedNostrSender;
  FirebaseInboxSender? _cachedFirebaseSender;
  SessionMessageSender? _cachedSessionSender;
  SessionInboxReader? _adhocSessionReader;
  PulseMessageSender? _cachedPulseSender;
  String? _cachedNostrPrivkey;

  // Cached SharedPreferences instance — avoids repeated async platform channel
  // round-trips. The underlying singleton is initialised on first access and
  // reused for the lifetime of this controller.
  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  // Per-sender rate limiters
  final _msgRateLimiter = RateLimiter(maxTokens: 30, refillInterval: Duration(seconds: 2));
  final _sigRateLimiter = RateLimiter(maxTokens: 20, refillInterval: Duration(seconds: 3));

  // Chunk assembly
  final _chunkAssembler = ChunkAssembler();
  // Tracks which contact is sending each incoming file (fileId → contactId).
  // Used by stall-check timer to send chunk_req only to the right sender.
  final _chunkSenderIds = <String, String>{};

  // Emits contact name when a message had to be sent unencrypted
  final StreamController<String> _e2eeFailCtrl = StreamController.broadcast();
  Stream<String> get e2eeFailures => _e2eeFailCtrl.stream;

  // Group invite streams
  final StreamController<SignalGroupUpdateEvent> _groupUpdatePublicCtrl =
      StreamController.broadcast();
  Stream<SignalGroupUpdateEvent> get groupUpdates => _groupUpdatePublicCtrl.stream;

  final StreamController<SignalGroupInviteEvent> _groupInviteCtrl =
      StreamController.broadcast();
  Stream<SignalGroupInviteEvent> get groupInvites => _groupInviteCtrl.stream;

  final StreamController<SignalGroupInviteDeclineEvent> _groupInviteDeclineCtrl =
      StreamController.broadcast();
  Stream<SignalGroupInviteDeclineEvent> get groupInviteDeclines =>
      _groupInviteDeclineCtrl.stream;

  // Status updates
  final StreamController<String> _statusUpdatesCtrl = StreamController.broadcast();
  Stream<String> get statusUpdates => _statusUpdatesCtrl.stream;

  // Typing stream (state managed by broadcaster)
  final StreamController<String> _typingStreamCtrl = StreamController.broadcast();
  Stream<String> get typingUpdates => _typingStreamCtrl.stream;
  bool isContactTyping(String contactId) => _broadcaster.isContactTyping(contactId);
  Set<String> getGroupTypingMembers(String groupId) => _broadcaster.getGroupTypingMembers(groupId);

  /// Resolve group typing member IDs to short display names.
  List<String> getGroupTypingNames(String groupId) {
    final memberIds = _broadcaster.getGroupTypingMembers(groupId);
    if (memberIds.isEmpty) return [];
    final names = <String>[];
    for (final id in memberIds) {
      final contact = _contacts.findById(id);
      if (contact != null) {
        final name = contact.name.split(' ').first.split(',').first.trim();
        names.add(name.isNotEmpty ? name : id.substring(0, 8));
      } else {
        names.add(id.length > 8 ? '${id.substring(0, 8)}…' : id);
      }
    }
    return names;
  }

  // Call streams
  final StreamController<Map<String, dynamic>> _incomingCallController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingCalls => _incomingCallController.stream;

  final StreamController<Map<String, dynamic>> _incomingGroupCallController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingGroupCalls => _incomingGroupCallController.stream;

  final StreamController<Map<String, dynamic>> _signalStreamController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get signalStream => _signalStreamController.stream;

  // Cache pending webrtc_offer/candidate signals so callee can replay after subscribing.
  // Key: senderBase (bare pubkey). Value: list of signals (offer + candidates).
  final Map<String, List<Map<String, dynamic>>> _pendingCallSignals = {};

  /// Cache a call signal for late subscribers (callee accepts after offer emitted).
  void _cacheCallSignal(Map<String, dynamic> sig) {
    final sigType = sig['type'] as String? ?? '';
    // Never cache hangup — stale hangup from a previous call kills the next one.
    if (sigType == 'webrtc_hangup') return;
    final rawSender = sig['senderId'] as String? ?? '';
    final senderBase = rawSender.contains('@') ? rawSender.split('@').first : rawSender;
    if (senderBase.isEmpty) return;
    // New offer = new call attempt — discard stale signals from previous attempt.
    if (sigType == 'webrtc_offer') {
      _pendingCallSignals.remove(senderBase);
    }
    _pendingCallSignals.putIfAbsent(senderBase, () => []).add(sig);
    // Cap at 50 signals per sender to prevent unbounded growth
    final list = _pendingCallSignals[senderBase]!;
    if (list.length > 50) list.removeRange(0, list.length - 50);
  }

  /// Consume (get and clear) pending call signals for a given sender.
  List<Map<String, dynamic>> consumePendingCallSignals(String senderBase) {
    final signals = _pendingCallSignals.remove(senderBase);
    return signals ?? [];
  }

  /// Force-reconnect the Nostr subscription if it appears dead.
  /// Returns true if an actual reconnect was triggered, false if skipped
  /// (subscription is healthy — no need to disrupt it).
  bool forceReconnectSubscription() {
    final reader = InboxManager().reader;
    if (reader is NostrInboxReader) {
      return reader.forceReconnect();
    }
    return false;
  }

  Identity? get identity => _identity;
  /// The transport-level address used as senderId (e.g. pubkey@server).
  String get selfId => _selfId;
  List<String> get allAddresses => List.unmodifiable(_allAddresses);

  /// Returns addresses enriched with all currently known working relays.
  /// For Nostr, the pubkey is replicated across identity relay + probed relay +
  /// adaptive relay so invite links always contain fresh, reachable routes.
  /// Non-Nostr addresses (Session, etc.) are included as-is.
  /// Nostr addresses are expanded to cover all known live relays so the
  /// recipient can reach us on whichever relay works for them.
  List<String> get shareableAddresses {
    if (_identity == null) return allAddresses;

    // Find our Nostr pubkey from any existing Nostr address in _allAddresses.
    String? nostrPub;
    for (final addr in _allAddresses) {
      final wssIdx = addr.indexOf('@wss://');
      final wsIdx = wssIdx == -1 ? addr.indexOf('@ws://') : -1;
      final atIdx = wssIdx != -1 ? wssIdx : wsIdx;
      if (atIdx > 0) {
        nostrPub = addr.substring(0, atIdx);
        break;
      }
    }
    // Nostr-primary: extract from selfId
    if (nostrPub == null && _identity!.preferredAdapter == 'nostr') {
      final atIdx = _selfId.indexOf('@');
      if (atIdx > 0) nostrPub = _selfId.substring(0, atIdx);
    }

    if (nostrPub == null) return allAddresses;

    // Build Nostr addresses for all known live relays.
    final relays = _gatherOwnNostrRelays(limit: 3);
    final result = <String>[];
    for (final relay in relays) {
      result.add('$nostrPub@$relay');
    }
    // Add non-Nostr addresses (Pulse, Session, etc.)
    for (final addr in _allAddresses) {
      if (!addr.contains('@wss://') && !addr.contains('@ws://')) {
        result.add(addr);
      }
    }
    return result.isEmpty ? allAddresses : result;
  }

  /// Auto-retry timers keyed by message ID
  final Map<String, Timer> _retryTimers = {};

  /// Formatted inbox address to share with contacts.
  String get myAddress {
    if (_identity == null) return '';
    switch (_identity!.preferredAdapter) {
      case 'firebase':
        final dbId = _identity!.adapterConfig['dbId'] ?? _identity!.id;
        try {
          final cfg = jsonDecode(_identity!.adapterConfig['token'] ?? '{}');
          final url = (cfg['url'] as String? ?? '').replaceAll(RegExp(r'/$'), '');
          if (url.isNotEmpty) return '$dbId@$url';
        } catch (e) {
          debugPrint('[Chat] Failed to parse Firebase address config: $e');
        }
        return dbId;
      case 'nostr':
        return _selfId; // pubkey@relay
      default:
        return _selfId;
    }
  }

  // ── Delegation: MessageRepository public API ─────────────────────────────

  ChatRoom? getRoomForContact(String contactId) => _repo.getRoomForContact(contactId);

  /// Adds a system-generated message (e.g. call history record) to the room
  /// without sending it over the network.  Deduplicates by message ID.
  void addSystemMessage(Contact contact, Message msg) {
    final room = _repo.getOrCreateRoom(contact);
    if (!_repo.roomHasMessage(contact.id, msg.id)) {
      room.messages.add(msg);
      _repo.trackMessageId(contact.id, msg.id);
    }
    if (!_disposed) notifyListeners();
  }

  int getChatTtlCached(String contactId) => _repo.getChatTtlCached(contactId);

  double? getUploadProgress(String msgId) => _repo.getUploadProgress(msgId);

  bool hasPqcKey(String contactId) => _keys.hasPqcKey(contactId);

  // Online status delegation
  bool isOnline(String contactId) => _broadcaster.isOnline(contactId);
  String lastSeenLabel(String contactId) => _broadcaster.lastSeenLabel(contactId);

  /// Update online status from any incoming signal's sender ID.
  /// O(1) via contact index — safe for high-frequency calls.
  void _markSenderOnline(String fromId) {
    final idx = _getContactIndex();
    final c = idx[fromId] ?? idx[fromId.split('@').first];
    if (c != null) _broadcaster.updateLastSeen(c.id);
  }

  /// Send heartbeat to a specific contact (e.g. when opening chat).
  void sendHeartbeatTo(Contact contact) =>
      unawaited(_broadcaster.sendHeartbeatTo(contact));

  /// Load persisted message history for a contact's room.
  Future<void> loadRoomHistory(Contact contact) async {
    await _repo.loadRoomHistory(contact, onChanged: () { if (!_disposed) _scheduleNotify(); });
    // Seed unread count from loaded messages
    final room = _repo.getRoomForContact(contact.id);
    if (room != null) {
      final selfId = _identity?.id ?? '';
      _unreadCounts[contact.id] = room.messages.where((m) => !m.isRead && m.senderId != selfId).length;
    }
    // Schedule TTL deletions for loaded messages
    final ttl = _repo.getChatTtlCached(contact.id);
    if (ttl > 0) {
      if (room != null) {
        for (final m in room.messages) {
          _repo.scheduleTtlDelete(contact, m, ttl,
              onDeleted: () { if (!_disposed) notifyListeners(); });
        }
      }
    }
  }

  Future<void> loadMoreHistory(Contact contact) =>
      _repo.loadMoreHistory(contact, onChanged: () { if (!_disposed) notifyListeners(); });

  Map<String, List<String>> getReactions(String storageKey, String msgId) =>
      _repo.getReactions(storageKey, msgId);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    sentryBreadcrumb('ChatController.initialize() started', category: 'lifecycle');
    _reconnecting = true; // block reconnectInbox() until initial setup completes
    try {
      await LocalStorageService().init();
      unawaited(_repo.restoreScheduledTtls(onDeleted: () { if (!_disposed) notifyListeners(); }));
      _connectionStatus = ConnectionStatus.connecting;
      final prefs = await _getPrefs();
      final identityJson = prefs.getString('user_identity');
      if (identityJson != null) {
        try {
          _identity = Identity.fromJson(jsonDecode(identityJson));
        } catch (e) {
          debugPrint('[ChatController] Failed to parse stored identity: $e');
          _connectionStatus = ConnectionStatus.disconnected;
          return;
        }
        await _signalService.initialize();
        await PqcService().initialize();

        // One-time migration: delete all stale Signal sessions so they
        // rebuild from the fresh bundles now published on every start.
        // Without this, outbound sessions produce ciphertext the receiver
        // (with new keys) can't decrypt.
        final prefs2 = await _getPrefs();
        if (prefs2.getBool('signal_sessions_reset_v4') != true) {
          debugPrint('[Chat] One-time session+identity reset — clearing stale Signal sessions, identity keys, NIP-44 nonces & seen IDs');
          await _signalService.deleteAllContactSessions();
          // Clear NIP-44 nonce cache so old events can be re-decrypted after reset
          nip44.clearNonceCache();
          // Clear persistent seen IDs so old events are re-processed
          await prefs2.remove('nostr_seen_ids');
          // Clear stored since timestamps so we don't skip events
          for (final key in prefs2.getKeys()) {
            if (key.startsWith('nostr_since_')) await prefs2.remove(key);
          }
          await prefs2.setBool('signal_sessions_reset_v4', true);
        }

        // Load contacts BEFORE starting inbox to avoid race condition:
        // without this, events arrive before contact index is populated,
        // causing all decrypt lookups to fail with empty index.
        await _contacts.loadContacts();
        // Ensure all contacts have Nostr fallback addresses for routing.
        for (final c in List<Contact>.from(_contacts.contacts)) {
          final fixed = await _ensureNostrFallback(c);
          if (!identical(fixed, c)) await _contacts.updateContact(fixed);
        }
        _invalidateContactIndex();
        debugPrint('[Chat] Loaded ${_contacts.contacts.length} contacts before inbox start');

        await _initInbox();
      } else {
        _connectionStatus = ConnectionStatus.disconnected;
      }
    } finally {
      _reconnecting = false;
    }
  }

  bool _reconnecting = false;

  Future<void> reconnectInbox() async {
    if (_reconnecting) return;
    _reconnecting = true;
    try {
      _connectionStatus = ConnectionStatus.connecting;
      notifyListeners();
      for (final s in _messageSubs) { s.cancel(); }
      _messageSubs.clear();
      for (final s in _signalSubs) { s.cancel(); }
      _signalSubs.clear();
      for (final s in _healthSubs) { s.cancel(); }
      _healthSubs.clear();
      for (final s in _dispatcherSubs) { s.cancel(); }
      _dispatcherSubs.clear();
      _signalDispatcher?.dispose();
      _signalDispatcher = null;
      _adapterHealth.clear();
      // Invalidate caches that may depend on adapter state
      _invalidateContactIndex();
      _cachedNostrSender = null;
      _cachedNostrPrivkey = null;
      _cachedFirebaseSender = null;
      _cachedPulseSender = null;
      _cachedSessionSender = null;
      _adhocSessionReader?.close();
      _adhocSessionReader = null;
      await _initInbox();
    } finally {
      _reconnecting = false;
    }
  }

  static const _secureStorage = FlutterSecureStorage();
  static const _uuid = Uuid();
  static const _kDefaultNostrRelay = kDefaultNostrRelay;
  static const _kLanModeEnabled = 'lan_mode_enabled';

  Future<void> _initInbox() async {
    if (_identity == null) return;

    // Ensure pulse_privkey exists for cross-transport sends (migrate old accounts).
    final existingPulseKey = await _secureStorage.read(key: 'pulse_privkey');
    if (existingPulseKey == null || existingPulseKey.isEmpty) {
      final nostrKey = await _secureStorage.read(key: 'nostr_privkey');
      if (nostrKey != null && nostrKey.isNotEmpty) {
        // Derive Pulse key from Nostr key as HKDF-like fallback
        final seed = Uint8List.fromList(hex.decode(nostrKey));
        final hmac = hash_lib.Hmac(hash_lib.sha256, utf8.encode('pulse-ed25519-seed'));
        final derived = hmac.convert(seed);
        await _secureStorage.write(key: 'pulse_privkey', value: hex.encode(derived.bytes));
        seed.fillRange(0, seed.length, 0);
        debugPrint('[Chat] Derived pulse_privkey from nostr_privkey (migration)');
      }
    }

    String apiKey = _identity!.adapterConfig['token'] ?? '';
    String dbId;
    String providerName;

    switch (_identity!.preferredAdapter) {
      case 'firebase':
        providerName = 'Firebase';
        dbId = _identity!.adapterConfig['dbId'] ?? _identity!.id;
        _selfId = dbId;
        {
          String firebaseUrl = '';
          try {
            final cfg = jsonDecode(apiKey);
            firebaseUrl = (cfg['url'] as String? ?? '').trim();
          } catch (_) {
            firebaseUrl = apiKey.trim();
          }
          if (!firebaseUrl.startsWith('https://')) {
            debugPrint('[ChatController] Stale/invalid Firebase config detected ("$firebaseUrl"). '
                'Clearing token — please re-enter your Firebase URL in Settings.');
            _identity = _identity!.copyWith(
              adapterConfig: Map.from(_identity!.adapterConfig)..remove('token'),
            );
            final prefs2 = await _getPrefs();
            await prefs2.setString('user_identity', jsonEncode(_identity!.toJson()));
            _connectionStatus = ConnectionStatus.disconnected;
            _scheduleNotify();
            return;
          }
        }
      case 'nostr':
        providerName = 'Nostr';
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await _getPrefs();
        final relay = _identity!.adapterConfig['relay'] ??
            prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
        apiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        dbId = relay;
        if (privkey.isNotEmpty) {
          try {
            final pubkey = deriveNostrPubkeyHex(privkey);
            _selfId = '$pubkey@$relay';
          } catch (e) {
            debugPrint('[ChatController] Invalid Nostr private key: $e');
            _connectionStatus = ConnectionStatus.disconnected;
            _scheduleNotify();
            return;
          }
        } else {
          _selfId = '${_identity!.id}@$relay';
        }
      case 'session':
        providerName = 'Session';
        {
          await SessionKeyService.instance.initialize();
          _selfId = SessionKeyService.instance.sessionId;
          final prefs = await _getPrefs();
          final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          apiKey = nodeUrl;
          dbId = _selfId;
        }
      case 'pulse':
        providerName = 'Pulse';
        {
          final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _getPrefs();
          final serverUrl = prefs.getString('pulse_server_url') ?? '';
          final invite = prefs.getString('pulse_invite_code') ?? '';
          apiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl, 'invite': invite});
          dbId = serverUrl;
          if (privkey.isNotEmpty) {
            try {
              final seed = Uint8List.fromList(hex.decode(privkey));
              final pubkey = await ed25519PubkeyFromSeed(seed);
              _selfId = '$pubkey@$serverUrl';
            } catch (e) {
              debugPrint('[ChatController] Invalid Pulse private key: $e');
              _connectionStatus = ConnectionStatus.disconnected;
              _scheduleNotify();
              return;
            }
          } else {
            _selfId = '${_identity!.id}@$serverUrl';
          }
        }
      default:
        providerName = 'Firebase';
        dbId = _identity!.adapterConfig['dbId'] ?? _identity!.id;
        _selfId = dbId;
    }

    await InboxManager().configureSelf(providerName, apiKey, dbId);
    _connectionStatus = ConnectionStatus.connected;
    sentryBreadcrumb('Adapter connected: $providerName', category: 'adapter');
    _scheduleNotify();

    // (Delivery stats removed — transport-priority routing replaces promotion)

    // Republish Signal bundle whenever a preKey is consumed.
    _signalService.onPreKeyConsumed = () => unawaited(_republishKeys());

    // Re-publish bundle to ALL transports when prekeys are exhausted.
    _bundleRefreshSub?.cancel();
    _bundleRefreshSub = _signalService.onBundleRefresh.listen((_) {
      debugPrint('[Chat] PreKeys exhausted — re-publishing bundle to all transports');
      unawaited(_republishAllKeys());
    });

    // Surface prekey exhaustion attack warnings.
    _signalSubs.add(_signalService.onPreKeyExhaustionWarning.listen((msg) {
      if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add('⚠️ $msg');
    }));

    unawaited(_keys.maybePublishOwnKeys(
        _identity!.preferredAdapter, _selfId, _identity!.adapterConfig['token'] ?? ''));

    unawaited(_restoreScheduledMessages());

    // Heartbeats via broadcaster
    _broadcaster.startHeartbeats(() => _contacts.contacts);

    final newAddresses = <String>[myAddress];
    _adapterHealth.clear();
    for (final s in _healthSubs) { s.cancel(); }
    _healthSubs.clear();

    _initSignalDispatcher();

    if (InboxManager().reader != null) {
      final r = InboxManager().reader!;
      _messageSubs.add(r.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(r.listenForSignals().listen(_signalDispatcher!.dispatch));
      _adapterHealth[myAddress] = true;
      _healthSubs.add(r.healthChanges.listen((h) => _onAdapterHealthChange(myAddress, h)));
    }

    // Register contact relays as secondary subscriptions so fallback publishes
    // (when a contact's relay rate-limits us) are still received by both sides.
    final mainReader = InboxManager().reader;
    if (mainReader is NostrInboxReader) {
      for (final c in _contacts.contacts) {
        if (c.provider != 'Nostr') continue;
        final dbId = c.databaseId;
        final wsIdx = dbId.indexOf('@wss://');
        final wsIdx2 = dbId.indexOf('@ws://');
        final atIdx = wsIdx != -1 ? wsIdx : (wsIdx2 != -1 ? wsIdx2 : -1);
        if (atIdx != -1) {
          final contactRelay = dbId.substring(atIdx + 1);
          mainReader.addSecondaryRelay(contactRelay);
        }
      }
      // Subscribe to probe/adaptive relays for own inbox redundancy.
      final prefs = await _getPrefs();
      final probeRelay = prefs.getString('probe_nostr_relay') ?? '';
      final adaptiveRelay = prefs.getString('adaptive_cf_relay') ?? '';
      if (probeRelay.isNotEmpty) {
        mainReader.addSecondaryRelay(
            probeRelay.startsWith('ws') ? probeRelay : 'wss://$probeRelay');
      }
      if (adaptiveRelay.isNotEmpty) {
        mainReader.addSecondaryRelay(adaptiveRelay);
      }
      // Always subscribe to the hardcoded default relay so that fallback
      // publishes (when primary relay rate-limits/rejects) are received.
      mainReader.addSecondaryRelay(_kDefaultNostrRelay);
    }

    // Subscribe to tamper warnings from the Nostr layer.
    _signalSubs.add(NostrInboxReader.tamperWarnings.stream.listen((senderId) {
      final short = senderId.length > 8 ? senderId.substring(0, 8) : senderId;
      debugPrint('[Security] MAC tamper warning from $senderId');
      _tamperWarningCtrl.add(
          'Tamper detected — a signal from $short… failed integrity check');
    }));

    // Subscribe secondary adapters
    final secondaryCfgs = await _loadSecondaryAdapters();
    for (final cfg in secondaryCfgs) {
      final reader = await InboxManager().createAdhocReader(
          cfg['provider']!, cfg['apiKey']!, cfg['databaseId']!);
      if (reader == null) continue;
      _messageSubs.add(reader.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(reader.listenForSignals().listen(_signalDispatcher!.dispatch));
      final addr = cfg['selfId'] ?? '';
      if (addr.isNotEmpty) {
        newAddresses.add(addr);
        _adapterHealth[addr] = true;
        _healthSubs.add(reader.healthChanges.listen((h) => _onAdapterHealthChange(addr, h)));
      }
      unawaited(_keys.publishKeysToAdapter(
          cfg['provider']!, cfg['apiKey']!, cfg['selfId'] ?? ''));
    }

    // Auto-register Pulse inbox if configured but not primary — so we can
    // RECEIVE messages on Pulse even when primary is Nostr/Firebase/etc.
    // Also adds our Pulse address to allAddresses → contacts learn it via addr_update.
    if (_identity!.preferredAdapter != 'pulse') {
      final pulseKey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
      final pulseUrl = (await _getPrefs()).getString('pulse_server_url') ?? '';
      if (pulseKey.isNotEmpty && pulseUrl.isNotEmpty) {
        try {
          final pulseApiKey = jsonEncode({'privkey': pulseKey, 'serverUrl': pulseUrl});
          final pulseReader = await InboxManager().createAdhocReader('Pulse', pulseApiKey, pulseUrl);
          if (pulseReader != null) {
            _messageSubs.add(pulseReader.listenForMessages().listen(_handleIncomingMessages));
            _signalSubs.add(pulseReader.listenForSignals().listen(_signalDispatcher!.dispatch));
            final seed = Uint8List.fromList(hex.decode(pulseKey));
            final pulsePub = await ed25519PubkeyFromSeed(seed);
            final pulseAddr = '$pulsePub@$pulseUrl';
            newAddresses.add(pulseAddr);
            _adapterHealth[pulseAddr] = true;
            _healthSubs.add(pulseReader.healthChanges.listen((h) => _onAdapterHealthChange(pulseAddr, h)));
            // Publish Signal keys to Pulse so contacts can fetch our bundle.
            unawaited(_keys.publishKeysToAdapter('Pulse', pulseApiKey, pulseAddr));
            debugPrint('[Chat] Auto-registered Pulse secondary inbox: $pulseAddr');
          }
        } catch (e) {
          debugPrint('[Chat] Failed to auto-register Pulse inbox: $e');
        }
      }
    }

    // Auto-register Session inbox so we receive messages sent to our Session ID.
    // Session ID is derived from the same seed on all devices.
    {
      try {
        await SessionKeyService.instance.initialize();
        final sessId = SessionKeyService.instance.sessionId;
        if (sessId.isNotEmpty) {
          final prefs = await _getPrefs();
          final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          final sessionReader = await InboxManager().createAdhocReader('Session', nodeUrl, sessId);
          if (sessionReader != null) {
            _adhocSessionReader = sessionReader as SessionInboxReader;
            _messageSubs.add(sessionReader.listenForMessages().listen(_handleIncomingMessages));
            _signalSubs.add(sessionReader.listenForSignals().listen(_signalDispatcher!.dispatch));
            // Remove any stale Session IDs from secondary adapters — only
            // SessionKeyService's ID is real (derived from current seed).
            newAddresses.removeWhere((a) =>
                a != sessId && RegExp(r'^05[0-9a-fA-F]{64}$').hasMatch(a));
            newAddresses.add(sessId);
            _adapterHealth[sessId] = true;
            _healthSubs.add(sessionReader.healthChanges.listen((h) => _onAdapterHealthChange(sessId, h)));
            unawaited(_keys.publishKeysToAdapter('Session', nodeUrl, sessId));
            debugPrint('[Chat] Auto-registered Session secondary inbox: ${sessId.substring(0, 12)}…');
          }
        }
      } catch (e) {
        debugPrint('[Chat] Failed to auto-register Session inbox: $e');
      }
    }

    // Auto-register Nostr inbox if we have a Nostr key but primary isn't Nostr.
    // Subscribe on multiple relays (default + probe results) for redundancy.
    if (_identity!.preferredAdapter != 'nostr') {
      try {
        final nostrPriv = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        if (nostrPriv.isNotEmpty &&
            !newAddresses.any((a) => a.contains('@wss://') || a.contains('@ws://'))) {
          final nostrPub = deriveNostrPubkeyHex(nostrPriv);
          const primaryRelay = _kDefaultNostrRelay;
          final apiKey = jsonEncode({'privkey': nostrPriv, 'relay': primaryRelay});
          final nostrReader = await InboxManager().createAdhocReader('Nostr', apiKey, primaryRelay);
          if (nostrReader != null) {
            _messageSubs.add(nostrReader.listenForMessages().listen(_handleIncomingMessages));
            _signalSubs.add(nostrReader.listenForSignals().listen(_signalDispatcher!.dispatch));
            // Subscribe to additional probed relays as secondary (up to 2 more).
            // These are subscribed for receiving but NOT added to _allAddresses
            // until we confirm they actually connect (dead relays get filtered out).
            final secondaryRelays = <String>[];
            if (nostrReader is NostrInboxReader) {
              final probeRelays = ConnectivityProbeService.instance.lastResult.nostrRelays;
              for (final r in probeRelays) {
                if (secondaryRelays.length >= 2) break;
                final relay = r.startsWith('ws') ? r : 'wss://$r';
                if (relay == primaryRelay) continue;
                nostrReader.addSecondaryRelay(relay);
                secondaryRelays.add(relay);
              }
            }
            // Only register primary address now. Secondary addresses are added
            // after we confirm they connect (via _updateNostrSecondaryAddresses).
            newAddresses.add('$nostrPub@$primaryRelay');
            _adapterHealth['$nostrPub@$primaryRelay'] = true;
            _healthSubs.add(nostrReader.healthChanges.listen((h) =>
                _onAdapterHealthChange('$nostrPub@$primaryRelay', h)));
            unawaited(_keys.publishKeysToAdapter('Nostr', apiKey, '$nostrPub@$primaryRelay'));
            // After a short delay, check which secondaries actually connected
            // and add their addresses.
            if (secondaryRelays.isNotEmpty) {
              Future.delayed(const Duration(seconds: 8), () {
                _addConnectedSecondaryRelays(nostrPub, nostrReader, secondaryRelays);
              });
            }
            debugPrint('[Chat] Auto-registered Nostr inbox: $primaryRelay + ${secondaryRelays.length} secondary pending');
          }
        }
      } catch (e) {
        debugPrint('[Chat] Failed to auto-register Nostr inbox: $e');
      }
    }

    // Assign all addresses atomically so concurrent readers see a complete list.
    _allAddresses = newAddresses;

    // (Session→Pulse revert removed — transport-priority routing eliminates cross-transport promotion)

    // LAN fallback
    _lanReader?.close();
    _lanSender?.close();
    _lanReader = null;
    _lanSender = null;
    final lanEnabled = (await _getPrefs()).getBool(_kLanModeEnabled) ?? true;
    if (lanEnabled) {
      _lanReader = LanInboxReader();
      _lanSender = LanMessageSender();
      await _lanReader!.initializeReader('', _selfId);
      await _lanSender!.initializeSender(_selfId);
      _messageSubs.add(_lanReader!.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(_lanReader!.listenForSignals().listen(_signalDispatcher!.dispatch));
    }

    NetworkMonitor.instance.startMonitoring(
      onChanged: (isAvailable) {
        if (_lanModeActive == isAvailable) {
          _lanModeActive = !isAvailable;
          _scheduleNotify();
        }
      },
      onNetworkChanged: () {
        debugPrint('[Chat] Network changed — re-probing relays');
        ConnectivityProbeService.instance.forceProbe().then((_) {
          reconnectInbox();
          Future.delayed(const Duration(seconds: 3), _flushFailedMessages);
        });
      },
    );

    // P2P DataChannel transport
    P2PTransportService.instance.onSendSignal = (contactId, type, payload) {
      final contact = _contacts.findById(contactId);
      if (contact != null) {
        unawaited(_broadcaster.sendP2PSignal(contact, type, payload));
      }
    };
    _messageSubs.add(P2PTransportService.instance.messageStream.listen((evt) {
      _handleP2PMessage(evt.contactId, evt.payload);
    }));
    _messageSubs.add(P2PTransportService.instance.binaryStream.listen((evt) {
      _handleP2PBinaryFrame(evt.contactId, evt.data);
    }));

    // Broadcast our addresses on every connect so contacts learn any new
    // secondary transport IDs (e.g. changed Session ID after key derivation fix).
    unawaited(Future.delayed(const Duration(seconds: 2), () => broadcastAddressUpdate()));

    _scheduleNotify();
  }

  Future<List<Map<String, String>>> _loadSecondaryAdapters() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('secondary_adapters');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      final result = <Map<String, String>>[];
      for (final item in list) {
        final entry = Map<String, String>.from(
            (item as Map).map((k, v) => MapEntry(k.toString(), v.toString())));
        if (entry['provider'] == 'Nostr') {
          final relay = entry['databaseId'] ?? '';
          // F6: Must use same SHA256 suffix as the write path in provider_section/screen.
          final keySuffix = hash_lib.sha256.convert(utf8.encode(relay)).toString().substring(0, 16);
          final privkey = await _secureStorage.read(key: 'secondary_nostr_privkey_$keySuffix') ?? '';
          entry['apiKey'] = jsonEncode({'privkey': privkey, 'relay': relay});
          try {
            final pubkey = privkey.isNotEmpty ? deriveNostrPubkeyHex(privkey) : '';
            entry['selfId'] = pubkey.isNotEmpty ? '$pubkey@$relay' : (entry['selfId'] ?? '');
          } catch (e) {
            debugPrint('[Chat] Failed to derive secondary Nostr pubkey: $e');
          }
        }
        result.add(entry);
      }
      return result;
    } catch (e) {
      debugPrint('[Chat] Failed to load secondary adapters: $e');
      sentryBreadcrumb('Secondary adapter load failed', category: 'adapter');
      return [];
    }
  }

  // ── Sender factory ────────────────────────────────────────────────────────

  /// Returns the cached Nostr private key, reading from secure storage only on
  /// first call or after invalidation (reconnect).
  Future<String> _getNostrPrivkey() async {
    if (_cachedNostrPrivkey != null) return _cachedNostrPrivkey!;
    _cachedNostrPrivkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
    return _cachedNostrPrivkey!;
  }

  /// Invalidate the cached Nostr private key so the next send re-reads from
  /// secure storage. Call this whenever the Nostr key is changed in Settings
  /// without a full reconnect, to prevent stale-key delivery.
  void invalidateNostrPrivkeyCache() {
    _cachedNostrPrivkey = null;
  }

  Future<({MessageSender sender, String apiKey})?> _buildSenderFor(Contact contact) async {
    // Derive effective provider from address format — more reliable than the
    // stored field which may be stale (e.g. after addr_update changed databaseId
    // from Nostr to Pulse but provider field wasn't updated on old clients).
    final effectiveProvider = contact.databaseId.isNotEmpty
        ? _providerFromAddress(contact.databaseId)
        : contact.provider;
    // Auto-fix stale provider field.
    if (effectiveProvider != contact.provider && contact.databaseId.isNotEmpty) {
      debugPrint('[Chat] Fixing stale provider: ${contact.provider} → $effectiveProvider for ${contact.name}');
      final fixed = contact.copyWith(provider: effectiveProvider);
      unawaited(_contacts.updateContact(fixed));
    }
    // Developer mode: skip disabled adapters.
    final prefs = await _getPrefs();
    if (prefs.getBool('dev_mode_enabled') ?? false) {
      if (!(prefs.getBool('dev_adapter_$effectiveProvider') ?? true)) {
        debugPrint('[Dev] Adapter $effectiveProvider disabled — skipping send');
        return null;
      }
    }
    switch (effectiveProvider) {
      case 'Firebase':
        final token = _identity!.adapterConfig['token'] ?? '';
        _cachedFirebaseSender ??= FirebaseInboxSender();
        return (sender: _cachedFirebaseSender!, apiKey: token);
      case 'Nostr':
        final privkey = await _getNostrPrivkey();
        // Use identity relay when Nostr is primary, otherwise default.
        // Don't read 'nostr_relay' pref — it may contain a stale probe value.
        final relay = _identity!.adapterConfig['relay'] ?? _kDefaultNostrRelay;
        _cachedNostrSender ??= NostrMessageSender();
        return (sender: _cachedNostrSender!,
                apiKey: jsonEncode({'privkey': privkey, 'relay': relay}));
      case 'Session':
        final prefs = await _getPrefs();
        final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
        _cachedSessionSender ??= SessionMessageSender();
        return (sender: _cachedSessionSender!, apiKey: nodeUrl);
      case 'Pulse':
        final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
        final prefs = await _getPrefs();
        // Extract server URL from contact's address (pubkey@https://server:port)
        // so we can send to ANY Pulse server, not just the one we configured.
        var serverUrl = prefs.getString('pulse_server_url') ?? '';
        final atIdx = contact.databaseId.indexOf('@');
        if (atIdx != -1) {
          final contactServer = contact.databaseId.substring(atIdx + 1);
          if (contactServer.startsWith('https://') || contactServer.startsWith('http://')) {
            serverUrl = contactServer;
          }
        }
        _cachedPulseSender ??= PulseMessageSender();
        return (sender: _cachedPulseSender!,
                apiKey: jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
      default:
        return null;
    }
  }

  /// Centralised helper: init sender for contact's provider and send a signal.
  /// Uses transport-priority routing: iterates transports in order, stops on first success.
  Future<bool> _sendSignalTo(Contact contact, String type, Map<String, dynamic> payload) async {
    if (_identity == null || _selfId.isEmpty) return false;
    final prefs = await _getPrefs();
    final devModeOn = prefs.getBool('dev_mode_enabled') ?? false;
    // PQC wrap once for all attempts
    Map<String, dynamic> effectivePayload = payload;
    if (await _keys.hasPqcKeyAsync(contact.databaseId)) {
      try {
        final wrapped = await _keys.pqcWrap(jsonEncode(payload), contact.databaseId);
        if (wrapped.startsWith('PQC2||')) effectivePayload = {'_pqc_wrapped': wrapped};
      } catch (e) {
        debugPrint('[Chat] PQC signal wrap failed: $e');
      }
    }
    for (final transport in contact.transportPriority) {
      if (devModeOn && !(prefs.getBool('dev_adapter_$transport') ?? true)) continue;
      final addresses = contact.transportAddresses[transport] ?? [];
      for (final addr in addresses) {
        try {
          var signedPayload = effectivePayload;
          if (transport != 'Nostr') {
            signedPayload = await _signPayload(contact, type, effectivePayload);
          }
          final ok = await _deliverSignalViaAddress(addr, type, signedPayload);
          if (ok) {
            debugPrint('[ChatController] Signal $type delivered via $transport: $addr');
            return true;
          }
        } catch (e) {
          debugPrint('[ChatController] Signal $type to $addr failed: $e');
        }
      }
    }
    return false;
  }

  Future<bool> _deliverSignalViaAddress(String address, String type, Map<String, dynamic> payload) async {
    final provider = _providerFromAddress(address);
    final prefs = await _getPrefs();
    if ((prefs.getBool('dev_mode_enabled') ?? false) &&
        !(prefs.getBool('dev_adapter_$provider') ?? true)) {
      return false;
    }
    if (provider == 'Pulse') {
      final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
      final atIdx = address.indexOf('@');
      final serverUrl = atIdx != -1 ? address.substring(atIdx + 1) : '';
      _cachedPulseSender ??= PulseMessageSender();
      await _cachedPulseSender!.initializeSender(jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
      return _cachedPulseSender!.sendSignal(address, address, _selfId, type, payload);
    } else if (provider == 'Nostr') {
      final privkey = await _getNostrPrivkey();
      final relay = _identity?.adapterConfig['relay'] ?? _kDefaultNostrRelay;
      final sender = NostrMessageSender();
      await sender.initializeSender(jsonEncode({'privkey': privkey, 'relay': relay}));
      return sender.sendSignal(address, address, _selfId, type, payload);
    }
    return false;
  }

  Future<Map<String, dynamic>> _signPayload(
      Contact contact, String type, Map<String, dynamic> payload) async {
    try {
      final privkey = await _getNostrPrivkey();
      if (privkey.isEmpty) return payload;
      final recipientPub = _extractPubkey(contact.databaseId);
      if (recipientPub == null) return payload;
      final senderPub = deriveNostrPubkeyHex(privkey);
      final canonical = jsonEncode({'t': type, 'p': payload});
      final hmac = signSignalPayload(privkey, recipientPub, canonical);
      return {...payload, '_sig': hmac, '_spk': senderPub};
    } catch (e) {
      debugPrint('[ChatController] Signal sign error: $e');
      return payload;
    }
  }

  String? _extractPubkey(String databaseId) {
    return _keys.extractPubkey(databaseId, _contacts.contacts);
  }

  Future<void> _addSenderPlugin(Contact contact) async {
    final built = await _buildSenderFor(contact);
    if (built != null) {
      final provider = contact.databaseId.isNotEmpty
          ? _providerFromAddress(contact.databaseId)
          : contact.provider;
      await InboxManager().addSenderPlugin(provider, built.sender, built.apiKey);
    }
  }

  /// Fetch Signal keys from an alternate address on a specific provider.
  Future<Map<String, dynamic>?> _fetchKeysFromAddress(String address, String provider) async {
    InboxReader reader;
    String apiKey;
    String dbId = address;
    if (provider == 'Nostr') {
      reader = NostrInboxReader();
      apiKey = '';
    } else if (provider == 'Pulse') {
      reader = PulseInboxReader();
      final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
      final atIdx = address.indexOf('@');
      final serverUrl = atIdx != -1 ? address.substring(atIdx + 1) : '';
      apiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
    } else if (provider == 'Session') {
      reader = SessionInboxReader();
      final prefs = await _getPrefs();
      apiKey = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
    } else {
      return null;
    }
    await reader.initializeReader(apiKey, dbId);
    return await reader.fetchPublicKeys();
  }

  // ── Key republishing (delegates to KeyManager) ────────────────────────────

  Future<void> _republishKeys() async {
    if (_identity == null || _selfId.isEmpty) return;
    await _keys.clearPublishedFlag(_identity!.preferredAdapter, _selfId);
    await _keys.maybePublishOwnKeys(
        _identity!.preferredAdapter, _selfId, _identity!.adapterConfig['token'] ?? '');
    debugPrint('[ChatController] Republished Signal bundle after preKey consumption');
  }

  Future<void> _republishAllKeys() async {
    await _republishKeys();
    final secondaryCfgs = await _loadSecondaryAdapters();
    for (final cfg in secondaryCfgs) {
      final selfId = cfg['selfId'] ?? '';
      if (selfId.isEmpty) continue;
      await _keys.clearPublishedFlag(cfg['provider']?.toLowerCase() ?? '', selfId);
      await _keys.publishKeysToAdapter(cfg['provider']!, cfg['apiKey']!, selfId);
    }
    debugPrint('[ChatController] Republished Signal bundle to all transports');
  }

  // ── Signal dispatcher ─────────────────────────────────────────────────────

  /// Marks the contact index as stale so [_getContactIndex] rebuilds it.
  void _invalidateContactIndex() {
    _contactIndexDirty = true;
    _contactIndex = null;
  }

  /// Returns the cached contact index, rebuilding only when dirty.
  Map<String, Contact> _getContactIndex() {
    // Auto-invalidate when contact list size changed (e.g. contact added via UI).
    final currentCount = _contacts.contacts.length;
    if (currentCount != _contactIndexCount) {
      _contactIndexDirty = true;
    }
    if (!_contactIndexDirty && _contactIndex != null) return _contactIndex!;
    final contactByDbId = HashMap<String, Contact>();
    for (final c in _contacts.contacts) {
      contactByDbId[c.databaseId] = c;
      final idPart = c.databaseId.split('@').first;
      if (idPart.isNotEmpty && idPart != c.databaseId) {
        contactByDbId.putIfAbsent(idPart, () => c);
      }
      // Index alternate addresses so messages from any transport match.
      for (final alt in c.alternateAddresses) {
        contactByDbId.putIfAbsent(alt, () => c);
        final altPart = alt.split('@').first;
        if (altPart.isNotEmpty && altPart != alt) {
          contactByDbId.putIfAbsent(altPart, () => c);
        }
      }
    }
    _contactIndex = contactByDbId;
    _contactIndexDirty = false;
    _contactIndexCount = currentCount;
    return contactByDbId;
  }

  Future<bool> _verifySignalSignature(
      String type, Map<String, dynamic> payload, String hmac, String senderPub) =>
      _keys.verifySignalSignature(type, payload, hmac, senderPub);

  void _initSignalDispatcher() {
    _signalDispatcher?.dispose();
    for (final s in _dispatcherSubs) { s.cancel(); }
    _dispatcherSubs.clear();

    _signalDispatcher = SignalDispatcher(
      allAddressesGetter: () => _allAddresses,
      selfIdGetter: () => _selfId,
      contactIndexBuilder: _getContactIndex,
      signatureVerifier: _verifySignalSignature,
      groupContactResolver: (id) {
        final c = _contacts.findById(id);
        return (c != null && c.isGroup) ? c : null;
      },
      rateLimiter: _sigRateLimiter,
    );

    final d = _signalDispatcher!;

    // PQC confirmation from signals — breaks the chicken-and-egg:
    // receiving a PQC-wrapped signal proves the contact has valid Kyber keys,
    // so we can PQC-wrap messages to them.
    _dispatcherSubs.add(d.pqcConfirmed.listen((senderId) {
      _pqcConfirmed.add(senderId);
      final prefix = senderId.split('@').first;
      for (final c in _contacts.contacts) {
        if (c.databaseId.split('@').first == prefix) {
          _pqcConfirmed.add(c.databaseId);
          break;
        }
      }
    }));

    _dispatcherSubs.add(d.rawSignals.listen((e) {
      if (!_signalStreamController.isClosed) _signalStreamController.add(e.signal);
      // Cache webrtc signals so callee can replay them after accepting the call
      final sigType = e.signal['type'] as String? ?? '';
      if (sigType.startsWith('webrtc_')) {
        _cacheCallSignal(e.signal);
      }
    }));

    _dispatcherSubs.add(d.incomingCalls.listen((e) {
      if (!_incomingCallController.isClosed) _incomingCallController.add(e.signal);
    }));

    _dispatcherSubs.add(d.incomingGroupCalls.listen((e) {
      if (!_incomingGroupCallController.isClosed) {
        _incomingGroupCallController.add({...e.signal, 'groupId': e.groupId});
      }
    }));

    // Typing — delegate state to broadcaster, emit on our stream
    _dispatcherSubs.add(d.typingEvents.listen((e) {
      final targetId = e.groupId ?? e.contact.id;
      _broadcaster.handleTypingEvent(targetId, (id) {
        if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(id);
        _scheduleNotify();
      }, memberId: e.groupId != null ? e.contact.id : null);
    }));

    _dispatcherSubs.add(d.readReceipts.listen((e) {
      _markSenderOnline(e.fromId);
      _handleReadReceipt(e.fromId);
    }));

    _dispatcherSubs.add(d.groupReadReceipts.listen((e) {
      _markSenderOnline(e.fromId);
      _handleGroupReadReceipt(e.fromId, e.groupId, e.msgId);
    }));

    _dispatcherSubs.add(d.deliveryAcks.listen((e) {
      _markSenderOnline(e.fromId);
      _handleDeliveryAck(e.fromId, e.msgId, groupId: e.groupId);
    }));

    // Pulse server-confirmed storage ACK → transition 'sending' → 'sent'
    _dispatcherSubs.add(pulseServerAcks.listen(_handleServerAck));

    _dispatcherSubs.add(d.ttlUpdates.listen((e) {
      unawaited(setChatTtlSeconds(e.contact, e.seconds, sendSignal: false));
    }));

    // Reactions — delegate to repo
    _dispatcherSubs.add(d.reactions.listen((e) {
      debugPrint('[Chat] Reaction received: storageKey=${e.storageKey} msgId=${e.msgId} emoji=${e.emoji} from=${e.from} remove=${e.remove}');
      _repo.applyRemoteReaction(e.storageKey, e.msgId, '${e.emoji}_${e.from}', e.remove);
      if (e.remove) {
        unawaited(LocalStorageService().removeReaction(e.storageKey, e.msgId, e.emoji, e.from));
      } else {
        unawaited(LocalStorageService().addReaction(e.storageKey, e.msgId, e.emoji, e.from));
      }
      _reactionVersions[e.storageKey] = (_reactionVersions[e.storageKey] ?? 0) + 1;
      _scheduleNotify();
    }));

    _dispatcherSubs.add(d.edits.listen((e) {
      debugPrint('[Edit] Received: contact=${e.contact.name} msgId=${e.msgId} text=${e.text.substring(0, e.text.length.clamp(0, 30))} groupId=${e.groupId}');
      final room = e.groupId != null
          ? (_repo.getRoomForContact(e.groupId!) ?? _repo.getRoomForContact(e.contact.id))
          : _repo.getRoomForContact(e.contact.id);
      if (room != null) {
        debugPrint('[Edit] Room found: contactId=${room.contact.id} msgs=${room.messages.length}');
        final idx = _repo.messageIndexById(room.contact.id, e.msgId);
        debugPrint('[Edit] Message lookup: idx=$idx msgId=${e.msgId}');
        if (idx != -1) {
          // Only the original sender may edit their own message.
          // Compare by pubkey prefix (before '@') to allow editing via alternate
          // relay addresses — msg.senderId may contain a different relay URL than
          // the contact's current primary address.
          final msg = room.messages[idx];
          final senderKey = msg.senderId.contains('@')
              ? msg.senderId.split('@').first
              : msg.senderId;
          final contactKey = e.contact.databaseId.contains('@')
              ? e.contact.databaseId.split('@').first
              : e.contact.databaseId;
          debugPrint('[Edit] Ownership check: senderKey=$senderKey contactKey=$contactKey match=${senderKey == contactKey}');
          if (senderKey != contactKey) {
            debugPrint('[Edit] Rejected: ${e.contact.databaseId} tried to edit '
                'message owned by ${msg.senderId}');
            return;
          }
          final storageKey = room.contact.storageKey;
          final updated = msg.copyWith(encryptedPayload: e.text, isEdited: true);
          room.messages[idx] = updated;
          unawaited(LocalStorageService().saveMessage(storageKey, updated.toJson()));
          _editVersions[storageKey] = (_editVersions[storageKey] ?? 0) + 1;
          _scheduleNotify();
          debugPrint('[Edit] SUCCESS: updated msgId=${e.msgId}');
        } else {
          debugPrint('[Edit] DROPPED: message not found. First 5 msg IDs: ${room.messages.take(5).map((m) => m.id).toList()}');
        }
      } else {
        debugPrint('[Edit] DROPPED: room not found for contactId=${e.contact.id}');
      }
    }));

    // Heartbeats — update broadcaster's last-seen
    _dispatcherSubs.add(d.heartbeats.listen((e) {
      _broadcaster.updateLastSeen(e.contact.id);
      _scheduleNotify();
    }));

    _dispatcherSubs.add(d.keysEvents.listen((e) async {
      final keyChanged = await _signalService.buildSession(
          e.contact.databaseId, e.payload);
      _keys.cacheContactKyberPk(e.contact.databaseId, e.payload);
      if (keyChanged && !_keyChangeCtrl.isClosed) {
        _keyChangeCtrl.add((contactName: e.contact.name, contactId: e.contact.databaseId));
      }
      if (e.contact.provider == 'Session') {
        unawaited(_keys.publishSessionKeysTo(e.contact, _selfId));
      }
    }));

    _dispatcherSubs.add(d.p2pEvents.listen((e) {
      unawaited(P2PTransportService.instance.handleSignal(
          e.contact.id, e.type, e.payload));
    }));

    _dispatcherSubs.add(d.relayExchanges.listen((e) async {
      await savePeerRelays(e.relays);
    }));

    _dispatcherSubs.add(d.turnExchanges.listen((e) async {
      await IceServerConfig.savePeerTurnServers(e.servers);
    }));

    _dispatcherSubs.add(d.blossomExchanges.listen((e) async {
      await BlossomService.instance.addPeerServers(e.servers);
    }));

    _dispatcherSubs.add(d.statusUpdates.listen((e) async {
      await StatusService.instance.saveContactStatus(e.contact.id, e.status);
      if (!_statusUpdatesCtrl.isClosed) {
        _statusUpdatesCtrl.add(e.contact.id);
      }
    }));

    _dispatcherSubs.add(d.addrUpdates.listen((e) async {
      final addrContact = e.contact;
      final payload = e.rawPayload;
      // F3/F4-4: Validate relay addresses — only wss:// and no private IPs.
      bool isValidAltAddr(String addr) {
        final lower = addr.toLowerCase();
        // Session addresses (66-char hex) are always valid
        if (lower.startsWith('05') && lower.length == 66 &&
            RegExp(r'^[0-9a-f]{66}$').hasMatch(lower)) return true;
        if (!lower.contains('@wss://') && !lower.contains('@ws://') &&
            !lower.contains('@https://') && !lower.contains('@http://')) return false;
        try {
          final urlPart = addr.substring(addr.indexOf('@') + 1);
          final uri = Uri.parse(urlPart);
          final h = uri.host;
          if (h.isEmpty || h == 'localhost' || h == '127.0.0.1' ||
              h == '::1' || h == '0.0.0.0') { return false; }
          if (h.startsWith('192.168.') || h.startsWith('10.') ||
              h.startsWith('169.254.')) { return false; }
          if (h.startsWith('172.')) {
            final seg = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
            if (seg != null && seg >= 16 && seg <= 31) return false;
          }
          if (h.startsWith('100.')) {
            final seg = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
            if (seg != null && seg >= 64 && seg <= 127) return false;
          }
          if (h.startsWith('fc') || h.startsWith('fd')) return false;
        } catch (_) { return false; }
        return true;
      }

      Contact updated;
      debugPrint('[ChatController] addr_update payload keys: ${payload.keys.toList()}'
          '${payload.containsKey('transportAddresses') ? ' ta=${payload['transportAddresses']}' : ''}'
          ' all=${(payload['all'] as List?)?.length ?? 0}');
      if (payload.containsKey('transportAddresses') && payload['transportAddresses'] is Map) {
        // ── New format: per-transport address map ────────────────────────
        final rawTa = payload['transportAddresses'] as Map;
        final ta = <String, List<String>>{};
        for (final entry in rawTa.entries) {
          final transport = entry.key as String;
          final addrs = (entry.value as List).whereType<String>().where(isValidAltAddr).toList();
          if (addrs.isNotEmpty) ta[transport] = addrs;
        }
        final tp = (payload['transportPriority'] as List?)?.whereType<String>().toList()
            ?? ta.keys.toList();
        if (ta.isEmpty) {
          debugPrint('[ChatController] addr_update: empty transportAddresses, ignoring');
          return;
        }
        updated = addrContact.copyWith(
          transportAddresses: ta,
          transportPriority: tp,
        );
      } else {
        // ── Old format: primary + all flat list → build transport map ────
        final primary = e.primary;
        final all = e.all;
        if (primary.toLowerCase().contains('@wss://') ||
            primary.toLowerCase().contains('@ws://') ||
            primary.toLowerCase().contains('@https://') ||
            primary.toLowerCase().contains('@http://')) {
          if (!isValidAltAddr(primary)) {
            debugPrint('[ChatController] addr_update: invalid primary $primary, ignoring');
            return;
          }
        }
        final allAddrs = <String>{primary, ...all.where(isValidAltAddr)};
        final ta = _buildTransportMap(allAddrs.toList());
        final primaryTransport = _providerFromAddress(primary);
        final tp = [primaryTransport, ...ta.keys.where((t) => t != primaryTransport)];
        updated = addrContact.copyWith(
          transportAddresses: ta,
          transportPriority: tp,
        );
      }
      // Save Nostr secp256k1 pubkey if provided (needed for HMAC signing
      // even when contact has no Nostr relay address).
      final nostrPub = payload['nostrPubkey'] as String?;
      if (nostrPub != null && nostrPub.isNotEmpty) {
        updated = updated.copyWith(publicKey: nostrPub);
      }
      // Ensure the contact has a Nostr fallback address for routing.
      updated = await _ensureNostrFallback(updated);
      await _contacts.updateContact(updated);
      _invalidateContactIndex();
      debugPrint('[ChatController] addr_update: ${addrContact.name} → ${updated.databaseId}'
          ' session=${updated.transportAddresses['Session'] ?? []}');
      _scheduleNotify();
    }));

    _dispatcherSubs.add(d.profileUpdates.listen((e) async {
      final profileContact = e.contact;
      bool changed = false;
      Contact updated = profileContact;
      if (e.about != profileContact.bio) {
        updated = updated.copyWith(bio: e.about);
        changed = true;
      }
      if (e.avatarB64.isNotEmpty) {
        await LocalStorageService().saveAvatar(profileContact.id, e.avatarB64);
        changed = true;
      }
      if (changed) {
        await _contacts.updateContact(updated);
        _invalidateContactIndex();
        _scheduleNotify();
      }
    }));

    _dispatcherSubs.add(d.chunkRequests.listen((e) {
      unawaited(_resendMissingChunks(e.fid, e.missing, e.senderId));
    }));

    _dispatcherSubs.add(d.groupInvites.listen((e) {
      if (!_groupInviteCtrl.isClosed) _groupInviteCtrl.add(e);
    }));

    _dispatcherSubs.add(d.groupInviteDeclines.listen((e) {
      if (!_groupInviteDeclineCtrl.isClosed) _groupInviteDeclineCtrl.add(e);
    }));

    _dispatcherSubs.add(d.msgDeletes.listen((e) {
      _handleRemoteDelete(e.fromId, e.msgId, groupId: e.groupId);
    }));

    _dispatcherSubs.add(d.groupUpdates.listen((e) async {
      final g = _contacts.findById(e.groupId);
      if (g == null || !g.isGroup) return;
      final group = g;
      // Only the group creator may update membership.
      // F1 fix: reject updates for groups without a creatorId — a null/empty
      // creatorId means the check was previously skipped, letting anyone update.
      // creatorId is a UUID but e.senderId is a transport
      // address — they were never equal. Resolve sender to a contact UUID first.
      if (group.creatorId == null || group.creatorId!.isEmpty) {
        debugPrint('[Group] Rejected group_update: group has no creatorId');
        return;
      }
      {
        final senderContact = _contacts.findByAddress(e.senderId);
        final senderUuid = senderContact?.id ?? '';
        if (senderUuid != group.creatorId) {
          debugPrint('[Group] Rejected group_update from non-creator '
              '${e.senderId} (creator: ${group.creatorId})');
          return;
        }
      }
      // Length comparison missed membership swap (same count, different set).
      final memberRemoved = group.members.toSet().difference(e.members.toSet()).isNotEmpty;
      final updated = group.copyWith(
        name: e.groupName.isNotEmpty ? e.groupName : group.name,
        members: e.members,
        creatorId: group.creatorId ?? e.creatorId,
      );
      await _contacts.updateContact(updated);
      _invalidateContactIndex();
      debugPrint('[Group] Membership updated for ${updated.name}: ${e.members.length} members');
      // Rotate sender key when a member was removed (forward secrecy).
      if (memberRemoved && _selfId.isNotEmpty) {
        unawaited(rotateGroupSenderKey(updated));
      }
      if (!_groupUpdatePublicCtrl.isClosed) _groupUpdatePublicCtrl.add(e);
      _scheduleNotify();
    }));

    _dispatcherSubs.add(d.senderKeyDists.listen((e) async {
      try {
        // Reject SKDM from contacts not in the group.
        final sg = _contacts.findById(e.groupId);
        final skdmGroup = (sg != null && sg.isGroup) ? sg : null;
        // F5: Reject SKDM for unknown groups (null skdmGroup) AND from non-members.
        // Old guard `skdmGroup != null && !members.contains(...)` accepted all
        // distributions for unknown group IDs (skdmGroup == null → guard skipped).
        // An attacker could inject key material for arbitrary groupIds.
        if (skdmGroup == null ||
            !skdmGroup.members.contains(e.fromContact.id)) {
          debugPrint('[SenderKey] Rejected SKDM from non-member '
              '${e.fromContact.name} for group ${e.groupId}');
          return;
        }
        final skdmBytes = base64Decode(e.skdmB64);
        await SenderKeyService.instance.processDistribution(
            e.groupId, e.fromContact.databaseId, skdmBytes);
        debugPrint('[SenderKey] Received distribution from ${e.fromContact.name} for group ${e.groupId}');
      } catch (err) {
        debugPrint('[SenderKey] Failed to process distribution: $err');
      }
    }));
  }

  // ── Sorted insertion (O(log n) vs O(n log n) sort) ──────────────────────
  /// Insert [msg] into an already-sorted [list] using binary search.
  static void _insertMessageSorted(List<Message> list, Message msg) {
    int low = 0, high = list.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (list[mid].timestamp.compareTo(msg.timestamp) < 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    list.insert(low, msg);
  }

  // ── Incoming messages ─────────────────────────────────────────────────────

  void _handleGroupReadReceipt(String fromId, String groupId, String msgId) {
    final gc = _contacts.findById(groupId);
    if (gc == null || !gc.isGroup) return;
    final groupContact = gc;
    // Resolve reader and verify group membership to prevent forged receipts.
    Contact? reader;
    for (final c in _contacts.contacts) {
      if (c.databaseId == fromId || c.databaseId.split('@').first == fromId.split('@').first) {
        reader = c;
        break;
      }
    }
    // Reject receipts from unresolved senders.
    // The fallback reader?.id ?? fromId would let an attacker forge a receipt
    // by sending a UUID that happens to match a group member's ID.
    if (reader == null) return;
    final readerId = reader.id;
    if (!groupContact.members.contains(readerId)) return;
    final room = _repo.getRoomForContact(groupContact.id);
    if (room == null) return;
    final idx = _repo.messageIndexById(groupContact.id, msgId);
    if (idx == -1) return;
    final msg = room.messages[idx];
    if (!msg.readBy.contains(readerId)) {
      room.messages[idx] = msg.copyWith(readBy: [...msg.readBy, readerId]);
      unawaited(LocalStorageService().saveMessage(
          groupContact.storageKey, room.messages[idx].toJson()));
      _scheduleNotify();
    }
  }

  Future<void> _handleIncomingMessages(List<Message> newMessages) async {
    bool hasUpdates = false;
    final contactByDbId = _getContactIndex();

    for (var msg in newMessages) {
      try {
        if (_seenMsgIds.contains(msg.id)) continue;
        if (_seenMsgIds.length >= 10000) {
          // Atomic eviction: rebuild both structures from remaining entries
          // to avoid Set/List desync across microtask boundaries.
          final evictCount = 5000.clamp(0, _seenMsgIdsList.length);
          final remaining = _seenMsgIdsList.sublist(evictCount);
          _seenMsgIdsList
            ..clear()
            ..addAll(remaining);
          _seenMsgIds
            ..clear()
            ..addAll(remaining);
        }
        _seenMsgIds.add(msg.id);
        _seenMsgIdsList.add(msg.id);

        // Normalise to pubkey prefix so a sender using multiple transports
        // (nostr, firebase) shares one rate-limit bucket rather than
        // getting a fresh 30-token bucket per transport address.
        final rlKey = msg.senderId.split('@').first;
        if (!_allAddresses.contains(msg.senderId) &&
            msg.senderId != _selfId &&
            !_msgRateLimiter.allow(rlKey)) {
          debugPrint('[Chat] Rate limited message from: ${msg.senderId}');
          continue;
        }

        String rawPayload = msg.encryptedPayload;
        if (rawPayload.startsWith('PQC2||')) {
          try {
            rawPayload = CryptoLayer.unwrap(rawPayload);
            // PQC succeeded — mark sender as confirmed so we PQC-wrap replies.
            _pqcConfirmed.add(msg.senderId);
            final senderPub = msg.senderId.split('@').first;
            for (final c in _contacts.contacts) {
              if (c.databaseId.split('@').first == senderPub) {
                _pqcConfirmed.add(c.databaseId);
                break;
              }
            }
          } catch (e) {
            debugPrint('[PQC] Unwrap failed for ${msg.id}: $e — dropping message');
            // PQC-wrapped message is irrecoverable — clear sender's cached
            // Kyber pk so our replies go Signal-only (they'll work).
            _keys.clearContactKyberPk(msg.senderId);
            continue; // skip this message entirely — don't show gibberish
          }
        }

        // All real messages must be E2EE-wrapped (plaintext fallback removed).
        // Non-E2EE payloads are server chaff or invalid — drop silently.
        if (!rawPayload.startsWith('E2EE||')) {
          debugPrint('[Chat] ⏭ Non-E2EE payload from ${msg.senderId.substring(0, 12)}…: ${rawPayload.substring(0, 30.clamp(0, rawPayload.length))}…');
          continue;
        }

        String decryptedRaw = rawPayload;
        if (rawPayload.startsWith('E2EE||')) {
          final fastContact = contactByDbId[msg.senderId]
              ?? contactByDbId[msg.senderId.split('@').first];
          debugPrint('[Chat] Contact lookup for ${msg.senderId.substring(0, 16)}…: ${fastContact?.name ?? "NOT FOUND"} (index has ${contactByDbId.length} entries)');
          if (fastContact != null) {
            try {
              decryptedRaw = await _signalService.decryptMessage(fastContact.databaseId, rawPayload);
            } catch (e) {
              debugPrint('[Chat] E2EE fast-path decrypt failed for ${fastContact.databaseId}: $e');
              sentryBreadcrumb('E2EE fast-path decrypt failed', category: 'signal');
            }
          }
          // If fast-path failed, try ALL known addresses for this contact as
          // session keys.  After addr_update the databaseId changes but the Signal
          // session may still be keyed by an older address.
          if (decryptedRaw == rawPayload && fastContact != null) {
            final tryAddrs = <String>{
              msg.senderId, // raw sender address from transport
              ...fastContact.alternateAddresses,
            };
            tryAddrs.remove(fastContact.databaseId); // already tried
            for (final addr in tryAddrs) {
              try {
                decryptedRaw = await _signalService.decryptMessage(addr, rawPayload);
                debugPrint('[Chat] Decrypt OK via alt session key: $addr');
                break;
              } catch (e) {
                debugPrint('[Chat] Alt-key decrypt failed for $addr: $e');
              }
            }
          }
          // Fallback: search all contacts by sender pubkey prefix
          if (decryptedRaw == rawPayload && fastContact == null) {
            final senderPubPrefix = msg.senderId.split('@').first;
            for (final c in _contacts.contacts) {
              if (c.databaseId.split('@').first == senderPubPrefix ||
                  c.alternateAddresses.any((a) => a.split('@').first == senderPubPrefix)) {
                final tryAddrs = <String>[c.databaseId, msg.senderId, ...c.alternateAddresses];
                for (final addr in tryAddrs) {
                  try {
                    decryptedRaw = await _signalService.decryptMessage(addr, rawPayload);
                    debugPrint('[Chat] Decrypt OK via contact ${c.name} key: $addr');
                    break;
                  } catch (e) { /* try next */ }
                }
                if (decryptedRaw != rawPayload) break;
              }
            }
          }
        }

        // Reset fail counter on successful decrypt.
        if (!decryptedRaw.startsWith('E2EE||')) {
          final okKey = contactByDbId[msg.senderId]?.databaseId
              ?? contactByDbId[msg.senderId.split('@').first]?.databaseId
              ?? msg.senderId;
          _e2eeFailCount.remove(okKey);
        }

        // If E2EE decryption failed entirely, drop the message (don't show
        // ciphertext). Track consecutive failures per contact — only delete the
        // session after 3+ failures to avoid nuking a valid session due to
        // stale replayed events from the relay's since window.
        if (decryptedRaw.startsWith('E2EE||')) {
          final failContact = contactByDbId[msg.senderId]
              ?? contactByDbId[msg.senderId.split('@').first];
          final failKey = failContact?.databaseId ?? msg.senderId;
          _e2eeFailCount[failKey] = (_e2eeFailCount[failKey] ?? 0) + 1;
          final failN = _e2eeFailCount[failKey]!;
          if (failContact != null && failN >= 3) {
            debugPrint('[Chat] E2EE decrypt failed ${failN}x for ${failContact.name} — '
                'deleting stale session to force rebuild');
            unawaited(_signalService.deleteContactData(failContact.databaseId));
            _e2eeFailCount.remove(failKey);
          } else {
            debugPrint('[Chat] E2EE decrypt failed (${failN}x) for ${failContact?.name ?? msg.senderId} — dropping');
          }
          continue;
        }

        final env = MessageEnvelope.tryUnwrap(decryptedRaw);
        // Validate envelope's claimed sender matches transport-layer sender.
        // env.from may use a different transport address (e.g. Firebase vs Nostr)
        // but the pubkey prefix must always agree. If they differ, an attacker
        // forged the inner envelope — fall back to transport sender.
        // Exception: sealed sender messages have transport ID "sealed" —
        // the real sender is only known from the encrypted envelope.
        String canonicalSenderId;
        final isSealed = msg.senderId == 'sealed';
        if (env?.from != null && env!.from.isNotEmpty) {
          if (isSealed) {
            // Sealed sender: transport ID is anonymous, trust envelope.
            canonicalSenderId = env.from;
          } else {
            final envPrefix = env.from.split('@').first;
            final transportPrefix = msg.senderId.split('@').first;
            if (envPrefix == transportPrefix) {
              canonicalSenderId = env.from;
            } else {
              // Different key formats (e.g. Session 05-prefix vs Pulse Ed25519)
              // may belong to the same contact. Check if both resolve to the
              // same contact before raising a tamper warning.
              final envContact = contactByDbId[env.from]
                  ?? contactByDbId[envPrefix];
              final transportContact = contactByDbId[msg.senderId]
                  ?? contactByDbId[transportPrefix];
              if (envContact != null && transportContact != null &&
                  envContact.id == transportContact.id) {
                // Same contact, different address format — use envelope.
                canonicalSenderId = env.from;
              } else {
                debugPrint('[Chat] Envelope sender mismatch: '
                    'envelope=$envPrefix transport=$transportPrefix — using transport');
                if (!_tamperWarningCtrl.isClosed) {
                  _tamperWarningCtrl.add('Authenticity warning from ${msg.senderId}');
                }
                canonicalSenderId = msg.senderId;
              }
            }
          }
        } else {
          canonicalSenderId = msg.senderId;
        }
        final bodyText = env?.body ?? decryptedRaw;

        Contact? senderContact = contactByDbId[canonicalSenderId]
            ?? contactByDbId[canonicalSenderId.split('@').first];
        senderContact ??= contactByDbId[msg.senderId]
            ?? contactByDbId[msg.senderId.split('@').first];

        if (senderContact != null) {
          // Sender is provably online — update status.
          _broadcaster.updateLastSeen(senderContact.id);
          // Message arrived — clear typing indicator immediately (1-on-1).
          _broadcaster.clearTyping(senderContact.id, (id) {
            if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(id);
            _scheduleNotify();
          });
          // Learn sender's transport address: if they sent from a different
          // address (e.g. Pulse vs Nostr), store it so SmartRouter can use it.
          final incomingAddr = msg.senderId;
          if (incomingAddr.contains('@') &&
              incomingAddr != senderContact.databaseId &&
              !senderContact.alternateAddresses.contains(incomingAddr)) {
            final updated = senderContact.copyWith(
              alternateAddresses: [...senderContact.alternateAddresses, incomingAddr],
            );
            await _contacts.updateContact(updated);
            _invalidateContactIndex();
            senderContact = updated;
            debugPrint('[Chat] Learned new route for ${senderContact.name}: $incomingAddr');
          }
          _repo.getOrCreateRoomWithId(senderContact, msg.senderId, senderContact.provider);
          final room = _repo.getRoomForContact(senderContact.id)!;

          if (!_repo.roomHasMessage(senderContact.id, msg.id)) {
            try {
              String displayText = bodyText;
              Contact targetContact = senderContact;
              String finalText = displayText;
              String? groupReplyToId, groupReplyToText, groupReplyToSender;
              try { if (displayText.startsWith('{')) {
                var parsed = jsonDecode(displayText) as Map<String, dynamic>;
                // ── Sender Key decrypt: unwrap _sk envelope ──
                if (parsed['_sk'] == true) {
                  final skGroupId = parsed['_group'] as String?;
                  final ct = parsed['ct'] as String?;
                  if (skGroupId != null && ct != null) {
                    // Check membership BEFORE decrypting to prevent
                    // removed members from advancing the ratchet or leaking plaintext.
                    final skg = _contacts.findById(skGroupId);
                    final skGroup = (skg != null && skg.isGroup) ? skg : null;
                    if (skGroup == null ||
                        !skGroup.members.contains(senderContact.id)) {
                      debugPrint('[SenderKey] Rejected SK message from non-member '
                          '${senderContact.name} for group $skGroupId');
                    } else {
                      try {
                        final cipherBytes = base64Decode(ct);
                        final plainBytes = await SenderKeyService.instance
                            .decrypt(skGroupId, senderContact.databaseId, cipherBytes);
                        final innerJson = utf8.decode(plainBytes);
                        parsed = jsonDecode(innerJson) as Map<String, dynamic>;
                        displayText = innerJson;
                      } catch (skErr) {
                        debugPrint('[SenderKey] Decrypt failed from ${senderContact.name}: $skErr');
                        // Fall through — parsed still has _sk envelope.
                      }
                    }
                  }
                }
                final groupId = parsed['_group'] as String?;
                if (groupId != null) {
                  final gcl = _contacts.findById(groupId);
                  final groupContact = (gcl != null && gcl.isGroup) ? gcl : null;
                  final isMember = groupContact?.members.contains(senderContact.id) ?? false;
                  if (groupContact != null && isMember) {
                    targetContact = groupContact;
                    // Clear group-specific typing for this member.
                    _broadcaster.clearTyping(senderContact.id, (id) {
                      if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(id);
                      _scheduleNotify();
                    }, groupId: groupId);
                    finalText = parsed['text'] as String? ?? displayText;
                    groupReplyToId = parsed['_replyToId'] as String?;
                    groupReplyToText = parsed['_replyToText'] as String?;
                    groupReplyToSender = parsed['_replyToSender'] as String?;
                    _repo.getOrCreateRoomWithId(groupContact, groupContact.id, 'group');
                  }
                }
              } } catch (e) { debugPrint('[Chat] Signal JSON parse (treating as plain text): $e'); }

              bool skipMessage = false;

              // P2P file header: initiates binary file transfer (not stored as message)
              if (finalText.startsWith('{') && finalText.contains('"p2p_file"')) {
                try {
                  final hdr = jsonDecode(finalText) as Map<String, dynamic>;
                  if (hdr['p2p_file'] == true) {
                    _handleP2PFileHeader(senderContact.id, hdr);
                    skipMessage = true;
                  }
                } catch (_) {}
              }

              if (!skipMessage && MediaService.isChunkPayload(finalText)) {
                // Track which contact is sending this file (F7 fix: stall
                // chunk_req should only go to the actual sender).
                try {
                  final chunkMap = jsonDecode(finalText) as Map<String, dynamic>;
                  final chunkFid = chunkMap['fid'] as String?;
                  if (chunkFid != null && chunkFid.isNotEmpty) {
                    _chunkSenderIds[chunkFid] = senderContact.id;
                  }
                } catch (_) {}
                final assembled = _chunkAssembler.handleChunk(finalText);
                if (assembled == null) {
                  skipMessage = true;
                } else {
                  // Transfer complete — clean up sender tracking.
                  try {
                    final chunkMap = jsonDecode(finalText) as Map<String, dynamic>;
                    _chunkSenderIds.remove(chunkMap['fid']);
                  } catch (_) {}
                  finalText = assembled;
                }
              }

              if (!skipMessage &&
                  !MediaService.isMediaPayload(finalText) &&
                  !MediaService.isChunkPayload(finalText) &&
                  !BlossomPayloadHelpers.isBlossomPayload(finalText) &&
                  finalText.length > 65536) {
                debugPrint('[ChatController] Dropped oversized message (${finalText.length} bytes)');
                skipMessage = true;
              }

              if (!skipMessage) {
                final targetRoom = _repo.getRoomForContact(targetContact.id) ?? room;
                // Use sender's local UUID from envelope (_id field) if present,
                // so reactions/deletes use the same ID on both devices.
                // Fall back to transport-level ID (Nostr event hash, etc.).
                final resolvedId = env?.msgId ?? msg.id;
                if (!targetRoom.messages.any((m) => m.id == resolvedId)) {
                  final decryptedMsg = Message(
                    id: resolvedId,
                    senderId: msg.senderId,
                    receiverId: msg.receiverId,
                    encryptedPayload: finalText,
                    timestamp: msg.timestamp,
                    adapterType: msg.adapterType,
                    isRead: false,
                    replyToId: groupReplyToId ?? env?.replyTo?.id,
                    replyToText: groupReplyToText ?? env?.replyTo?.text,
                    replyToSender: groupReplyToSender ?? env?.replyTo?.sender,
                  );
                  _insertMessageSorted(targetRoom.messages, decryptedMsg);
                  _repo.trackMessageId(targetContact.id, decryptedMsg.id);
                  await LocalStorageService().saveMessage(
                      targetContact.storageKey, decryptedMsg.toJson());
                  hasUpdates = true;
                  if (!_newMsgController.isClosed) {
                    _newMsgController.add((contactId: targetContact.id, message: decryptedMsg));
                  }
                  // Increment unread count if this chat is not currently open
                  if (_activeRoomId != targetContact.id) {
                    _unreadCounts[targetContact.id] = (_unreadCounts[targetContact.id] ?? 0) + 1;
                    if (!_unreadChangedCtrl.isClosed) {
                      _unreadChangedCtrl.add(targetContact.id);
                    }
                  }
                  unawaited(_broadcaster.sendDeliveryAck(senderContact, decryptedMsg.id,
                      groupId: targetContact.isGroup ? targetContact.id : null));
                  if (targetContact.isGroup && _activeRoomId == targetContact.id) {
                    unawaited(_broadcaster.sendGroupReadReceipt(
                        senderContact, targetContact.id, decryptedMsg.id));
                  }
                  final ttl = _repo.getChatTtlCached(targetContact.id);
                  if (ttl > 0) {
                    _repo.scheduleTtlDelete(targetContact, decryptedMsg, ttl,
                        onDeleted: () { if (!_disposed) notifyListeners(); });
                  }
                }
              }
            } catch (e) {
              debugPrint("Decryption failed for message ${msg.id}: $e");
            }
          }
        }
      } catch (e) {
        debugPrint('[ChatController] Skipping malformed message ${msg.id}: $e');
      }
    }

    if (hasUpdates) _scheduleNotify();
  }

  // ── Message sending ───────────────────────────────────────────────────────

  Future<void> sendMessage(Contact contact, String text, {
    bool noAutoRetry = false,
    Message? replyTo,
  }) async {
    if (_identity == null) return;

    if (contact.isGroup) {
      final groupRoom = _repo.getOrCreateRoom(contact);
      final localMsg = Message(
        id: _uuid.v4(), senderId: _identity!.id, receiverId: contact.id,
        encryptedPayload: text, timestamp: DateTime.now(),
        adapterType: 'group', isRead: true, status: 'sending',
        replyToId: replyTo?.id,
        replyToText: replyTo?.encryptedPayload.substring(0, replyTo.encryptedPayload.length.clamp(0, 80)),
        replyToSender: replyTo?.senderId,
      );
      groupRoom.messages.add(localMsg);
      _repo.trackMessageId(contact.id, localMsg.id);
      notifyListeners();

      final groupMap = <String, dynamic>{'_group': contact.id, 'text': text};
      if (replyTo != null) {
        groupMap['_replyToId'] = replyTo.id;
        groupMap['_replyToText'] = replyTo.encryptedPayload.length > 80
            ? replyTo.encryptedPayload.substring(0, 80)
            : replyTo.encryptedPayload;
        groupMap['_replyToSender'] = replyTo.senderId;
      }
      final groupPayload = jsonEncode(groupMap);

      // ── Sender Key: distribute if needed, then try encrypt-once ──
      int sent = 0;
      bool usedSenderKey = false;
      try {
        final sk = SenderKeyService.instance;
        // Ensure all members have our sender key distribution.
        if (!await sk.allMembersHaveKey(contact.id, contact.members)) {
          final skdmBytes = await sk.createDistribution(contact.id, _selfId);
          final skdmB64 = base64Encode(skdmBytes);
          for (final memberId in contact.members) {
            final memberContact = _contacts.findById(memberId);
            if (memberContact == null) continue;
            final distOk = await _sendSignalTo(memberContact, 'sender_key_dist', {
              'groupId': contact.id,
              'skdm': skdmB64,
            });
            if (distOk) await sk.markDistributed(contact.id, memberId);
          }
        }
        // Encrypt once with GroupCipher.
        final plainBytes = Uint8List.fromList(utf8.encode(groupPayload));
        final cipherBytes = await sk.encrypt(contact.id, _selfId, plainBytes);
        final skEnvelope = jsonEncode({
          '_sk': true,
          '_group': contact.id,
          'ct': base64Encode(cipherBytes),
        });
        // Send same ciphertext to all members via per-member Signal session.
        for (final memberId in contact.members) {
          final memberContact = _contacts.findById(memberId);
          if (memberContact == null) continue;
          await _sendToContact(memberContact, skEnvelope, noAutoRetry: noAutoRetry);
          sent++;
        }
        usedSenderKey = true;
      } catch (e) {
        debugPrint('[SenderKey] Encrypt failed, falling back to per-member: $e');
      }
      // Fallback: per-member encryption (original path).
      if (!usedSenderKey) {
        sent = 0;
        for (final memberId in contact.members) {
          final memberContact = _contacts.findById(memberId);
          if (memberContact == null) continue;
          await _sendToContact(memberContact, groupPayload, noAutoRetry: noAutoRetry);
          sent++;
        }
      }

      final finalStatus = sent > 0 ? 'sent' : 'failed';
      final idx = _repo.messageIndexById(contact.id, localMsg.id);
      final finalMsg = localMsg.copyWith(status: finalStatus);
      if (idx != -1) groupRoom.messages[idx] = finalMsg;
      await LocalStorageService().saveMessage(contact.id, finalMsg.toJson());
      final ttl = _repo.getChatTtlCached(contact.id);
      if (ttl > 0) _repo.scheduleTtlDelete(contact, finalMsg, ttl, onDeleted: () { if (!_disposed) notifyListeners(); });
      notifyListeners();
      return;
    }

    ({String id, String text, String sender})? replyInfo;
    if (replyTo != null) {
      final preview = replyTo.encryptedPayload.length > 80
          ? replyTo.encryptedPayload.substring(0, 80)
          : replyTo.encryptedPayload;
      replyInfo = (id: replyTo.id, text: preview, sender: replyTo.senderId);
    }

    // Create local message FIRST so it appears in UI immediately.
    final msgId = _uuid.v4();
    final contactAdapterType = contact.provider == 'Nostr' ? 'nostr'
        : contact.provider == 'Session' ? 'session'
        : 'firebase';
    final room = _repo.getOrCreateRoom(contact);
    final localMsg = Message(
      id: msgId, senderId: _identity!.id, receiverId: contact.id,
      encryptedPayload: text, timestamp: DateTime.now(),
      adapterType: contactAdapterType, isRead: true, status: 'sending',
      replyToId: replyInfo?.id,
      replyToText: replyInfo?.text,
      replyToSender: replyInfo?.sender,
    );
    room.messages.add(localMsg);
    _repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, localMsg, localTtl, onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();

    final envelope = MessageEnvelope.wrap(
      _selfId.isNotEmpty ? _selfId : _identity!.id, text,
      msgId: msgId, replyTo: replyInfo);

    String encryptedText;
    try {
      debugPrint('[Send] Encrypting for ${contact.name} (${contact.databaseId.substring(0, 8)}…)');
      encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
      debugPrint('[Send] Encrypted OK for ${contact.name}');
    } catch (e) {
      debugPrint('[E2EE] Encrypt failed: $e — rebuilding session');
      try {
        final ourApiKey = _identity!.adapterConfig['token'] ?? '';
        InboxReader contactReader;
        String initApiKey = ourApiKey;
        String initDbId = contact.databaseId;
        if (contact.provider == 'Firebase') {
          contactReader = FirebaseInboxReader();
          final atIdx = contact.databaseId.indexOf('@http');
          if (atIdx != -1) {
            initDbId = contact.databaseId.substring(0, atIdx);
            final contactDbUrl = contact.databaseId.substring(atIdx + 1);
            initApiKey = jsonEncode({'url': contactDbUrl, 'key': ''});
          }
        } else if (contact.provider == 'Nostr') {
          contactReader = NostrInboxReader();
          initApiKey = '';
          initDbId = contact.databaseId;
        } else if (contact.provider == 'Session') {
          contactReader = SessionInboxReader();
          final prefs = await _getPrefs();
          initApiKey = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          initDbId = contact.databaseId;
          unawaited(_keys.publishSessionKeysTo(contact, _selfId));
        } else if (contact.provider == 'Pulse') {
          contactReader = PulseInboxReader();
          final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _getPrefs();
          var serverUrl = prefs.getString('pulse_server_url') ?? '';
          final pAt = contact.databaseId.indexOf('@');
          if (pAt != -1) {
            final s = contact.databaseId.substring(pAt + 1);
            if (s.startsWith('https://') || s.startsWith('http://')) serverUrl = s;
          }
          initApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
          initDbId = contact.databaseId;
        } else {
          throw Exception('Unknown provider: ${contact.provider}');
        }
        debugPrint('[E2EE] Fetching bundle for ${contact.name} via ${contact.provider}');

        // ── Key fetch strategy: Session first (reliable storage), Nostr fallback ──
        Map<String, dynamic>? bundle;

        // Priority 1: Session — storage servers keep keys ~14 days, highly reliable.
        final sessionAddrs = contact.transportAddresses['Session'] ?? [];
        if (sessionAddrs.isNotEmpty) {
          try {
            final sessionReader = SessionInboxReader();
            final prefs = await _getPrefs();
            final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
            await sessionReader.initializeReader(nodeUrl, sessionAddrs.first);
            bundle = await sessionReader.fetchPublicKeys();
            if (bundle != null) {
              debugPrint('[E2EE] Key fetch OK via Session (${sessionAddrs.first.substring(0, 8)}…)');
            }
          } catch (e) {
            debugPrint('[E2EE] Session key fetch failed: $e');
          }
        }

        // Priority 2: contact's primary transport (Nostr relay, Pulse, etc.)
        if (bundle == null) {
          await contactReader.initializeReader(initApiKey, initDbId);
          debugPrint('[E2EE] Trying ${contact.provider} primary...');
          bundle = await contactReader.fetchPublicKeys();
        }

        // Priority 3: other Nostr relays (key may exist on a different relay).
        if (bundle == null && contact.provider == 'Nostr') {
          final atIdx = contact.databaseId.indexOf('@');
          final contactPubkey = atIdx > 0 ? contact.databaseId.substring(0, atIdx) : '';
          final primaryRelay = atIdx > 0 ? contact.databaseId.substring(atIdx + 1) : '';
          if (contactPubkey.isNotEmpty) {
            final relays = await gatherKnownRelays(primaryRelay, limit: 3);
            for (final relay in relays) {
              if (relay == primaryRelay) continue;
              try {
                final altReader = NostrInboxReader();
                await altReader.initializeReader('', '$contactPubkey@$relay');
                final altBundle = await altReader.fetchPublicKeys();
                if (altBundle != null) {
                  debugPrint('[E2EE] Fallback key fetch OK via Nostr relay $relay');
                  bundle = altBundle;
                  break;
                }
              } catch (e) {
                debugPrint('[E2EE] Fallback key fetch from $relay failed: $e');
              }
            }
          }
        }

        // Priority 4: any remaining alternate transport.
        if (bundle == null && contact.alternateAddresses.isNotEmpty) {
          for (final alt in contact.alternateAddresses) {
            final altProvider = _providerFromAddress(alt);
            if (altProvider.isEmpty || altProvider == contact.provider || altProvider == 'Session') continue;
            try {
              final altBundle = await _fetchKeysFromAddress(alt, altProvider);
              if (altBundle != null) {
                debugPrint('[E2EE] Fallback key fetch OK via $altProvider');
                bundle = altBundle;
                break;
              }
            } catch (e) {
              debugPrint('[E2EE] Fallback key fetch from $altProvider failed: $e');
            }
          }
        }
        debugPrint('[E2EE] fetchPublicKeys: ${bundle != null ? "${bundle.keys.length} keys" : "null"}');
        if (bundle != null) {
          final keyChanged = await _signalService.buildSession(contact.databaseId, bundle);
          _keys.cacheContactKyberPk(contact.databaseId, bundle);
          if (keyChanged && !_keyChangeCtrl.isClosed) {
            _keyChangeCtrl.add((contactName: contact.name, contactId: contact.databaseId));
          }
          debugPrint('[E2EE] Session built, re-encrypting...');
          encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
          debugPrint('[E2EE] Session rebuilt OK');
        } else {
          debugPrint('[E2EE] No key bundle for ${contact.name} — send aborted');
          if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add(contact.name);
          final idx = _repo.messageIndexById(contact.id, msgId);
          if (idx != -1) room.messages[idx] = localMsg.copyWith(status: 'failed');
          await LocalStorageService().saveMessage(contact.id, localMsg.copyWith(status: 'failed').toJson());
          notifyListeners();
          return;
        }
      } catch (e2) {
        debugPrint('[E2EE] Session build failed for ${contact.name}: $e2 — send aborted');
        sentryBreadcrumb('E2EE session build failed', category: 'encryption');
        if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add(contact.name);
        final idx = _repo.messageIndexById(contact.id, msgId);
        if (idx != -1) room.messages[idx] = localMsg.copyWith(status: 'failed');
        await LocalStorageService().saveMessage(contact.id, localMsg.copyWith(status: 'failed').toJson());
        notifyListeners();
        return;
      }
    }

    if (encryptedText.startsWith('E2EE||') &&
        _pqcConfirmed.contains(contact.databaseId)) {
      encryptedText = await _keys.pqcWrap(encryptedText, contact.databaseId);
    }

    final msg = Message(
      id: msgId,
      senderId: _selfId.isNotEmpty ? _selfId : _identity!.id,
      receiverId: contact.databaseId,
      encryptedPayload: encryptedText,
      timestamp: localMsg.timestamp,
      adapterType: contactAdapterType,
    );

    debugPrint('[Send] Routing to ${contact.name}...');
    await _addSenderPlugin(contact);
    final _devPrefs = await _getPrefs();
    final devModeOn = _devPrefs.getBool('dev_mode_enabled') ?? false;

    // Transport-priority routing: iterate transports in priority order,
    // try each address within a transport before moving to the next transport.
    bool sent = false;

    // P2P shortcut — try direct connection first regardless of transport.
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) debugPrint('[P2P] Direct delivery to ${contact.name}');
    }

    if (!sent) {
      for (final transport in contact.transportPriority) {
        if (devModeOn && !(_devPrefs.getBool('dev_adapter_$transport') ?? true)) {
          debugPrint('[Dev] Adapter $transport disabled — skipping');
          continue;
        }
        final addresses = contact.transportAddresses[transport] ?? [];
        for (final addr in addresses) {
          sent = await _deliverEncryptedMessage(addr, msg);
          if (sent) {
            debugPrint('[SmartRouter] Delivered via $transport: $addr');
            break;
          }
        }
        if (sent) break;
      }
    }

    debugPrint('[Send] Route result: ${sent ? "SENT" : "FAILED"} for ${contact.name}');
    final idx = _repo.messageIndexById(contact.id, msg.id);
    final finalMsg = localMsg.copyWith(status: sent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    notifyListeners();
    if (!sent && !noAutoRetry) _scheduleAutoRetry(contact, finalMsg);
  }

  // ── Smart Router helpers ──────────────────────────────────────────────────

  static final _sessionAddrRegex = RegExp(r'^[0-9a-f]{66}$');
  static final _nostrPubRegex = RegExp(r'^[0-9a-f]{64}$');
  static final _pulseAddrRegex = RegExp(r'^[0-9a-f]{64}@https://', caseSensitive: false);

  static String _providerFromAddress(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        _sessionAddrRegex.hasMatch(lower)) { return 'Session'; }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        _nostrPubRegex.hasMatch(lower)) { return 'Nostr'; }
    // Pulse: 64-char hex @ https:// (not wss://)
    if (_pulseAddrRegex.hasMatch(lower)) { return 'Pulse'; }
    if (lower.contains('@https://')) { return 'Firebase'; }
    return 'Nostr';
  }

  /// After a delay, add secondary relay addresses that successfully connected.
  void _addConnectedSecondaryRelays(
      String nostrPub, InboxReader reader, List<String> candidates) {
    if (reader is! NostrInboxReader) return;
    final connected = reader.connectedSecondaryRelays;
    var added = 0;
    for (final relay in candidates) {
      if (connected.contains(relay)) {
        final addr = '$nostrPub@$relay';
        if (!_allAddresses.contains(addr)) {
          _allAddresses.add(addr);
          added++;
        }
      }
    }
    if (added > 0) {
      debugPrint('[Chat] Added $added connected secondary Nostr relays to addresses');
      // Re-run contact fallback with the new relay set
      _refreshContactNostrFallback();
    }
  }

  /// Refresh Nostr fallback addresses for all contacts using current relay set.
  void _refreshContactNostrFallback() {
    unawaited(() async {
      for (final c in List<Contact>.from(_contacts.contacts)) {
        final fixed = await _ensureNostrFallback(c);
        if (!identical(fixed, c)) await _contacts.updateContact(fixed);
      }
    }());
  }

  /// Gather our own Nostr relay URLs from addresses we're actually subscribed to.
  /// Used for auto-registration, shareable addresses, and contact fallback.
  List<String> _gatherOwnNostrRelays({int limit = 3}) {
    final seen = <String>{};
    final result = <String>[];
    void _add(String relay) {
      if (relay.isEmpty) return;
      if (!relay.startsWith('ws://') && !relay.startsWith('wss://')) {
        relay = 'wss://$relay';
      }
      if (seen.add(relay)) result.add(relay);
    }
    // 1) Hardcoded default — always reachable, always first
    _add(_kDefaultNostrRelay);
    // 2) Identity config relay (if Nostr-primary user configured one)
    _add(_identity?.adapterConfig['relay'] ?? '');
    // 3) Relays we're actually connected to (from our own addresses)
    for (final addr in _allAddresses) {
      if (result.length >= limit) break;
      final wssIdx = addr.indexOf('@wss://');
      final wsIdx = wssIdx == -1 ? addr.indexOf('@ws://') : -1;
      final atIdx = wssIdx != -1 ? wssIdx : wsIdx;
      if (atIdx > 0) _add(addr.substring(atIdx + 1));
    }
    // 4) Ensure at least default is present
    if (result.isEmpty) result.add(_kDefaultNostrRelay);
    return result.take(limit).toList();
  }

  /// Classify a flat address list into a per-transport map.
  static Map<String, List<String>> _buildTransportMap(List<String> addresses) {
    final map = <String, List<String>>{};
    for (final addr in addresses) {
      if (addr.isEmpty) continue;
      final transport = _providerFromAddress(addr);
      (map[transport] ??= []).add(addr);
    }
    return map;
  }

  static final _hex64 = RegExp(r'^[0-9a-f]{64}$');

  /// Ensure a contact has Nostr fallback addresses on all our known live relays.
  /// This guarantees Nostr is always available as a transport even when the contact
  /// was originally added with only Pulse/Session addresses.
  Future<Contact> _ensureNostrFallback(Contact contact) async {
    if (contact.publicKey.isEmpty || !_hex64.hasMatch(contact.publicKey)) {
      return contact;
    }
    final relays = _gatherOwnNostrRelays(limit: 3);
    final desired = relays.map((r) => '${contact.publicKey}@$r').toList();
    final existing = contact.transportAddresses['Nostr'] ?? [];
    // Check if already up to date (same set)
    final desiredSet = desired.toSet();
    if (existing.length == desired.length &&
        existing.toSet().containsAll(desiredSet)) return contact;
    // Replace with our known-good relay addresses.
    // Contact-sent addresses arrive via addr_update and will be merged there.
    final ta = Map<String, List<String>>.from(
      contact.transportAddresses.map((k, v) => MapEntry(k, List<String>.from(v))),
    );
    ta['Nostr'] = desired;
    final tp = List<String>.from(contact.transportPriority);
    if (!tp.contains('Nostr')) tp.add('Nostr');
    debugPrint('[Chat] Nostr fallback for ${contact.name}: ${desired.length} relays');
    return contact.copyWith(transportAddresses: ta, transportPriority: tp);
  }

  Future<bool> _deliverEncryptedMessage(String address, Message msg) async {
    if (_identity == null) return false;
    final provider = _providerFromAddress(address);
    // Developer mode: skip disabled adapters.
    final prefs = await _getPrefs();
    if ((prefs.getBool('dev_mode_enabled') ?? false) &&
        !(prefs.getBool('dev_adapter_$provider') ?? true)) {
      debugPrint('[Dev] Adapter $provider disabled — skipping deliver to $address');
      return false;
    }
    final sendMsg = Message(
      id: msg.id,
      senderId: msg.senderId,
      receiverId: msg.receiverId,
      encryptedPayload: msg.encryptedPayload,
      timestamp: msg.timestamp,
      adapterType: provider.toLowerCase(),
    );
    final ourApiKey = _identity!.adapterConfig['token'] ?? '';
    if (provider == 'Firebase') {
      await InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
    } else if (provider == 'Nostr') {
      final privkey = await _getNostrPrivkey();
      final prefs = await _getPrefs();
      final atIdx = address.indexOf('@');
      final relay = atIdx != -1
          ? address.substring(atIdx + 1)
          : _identity?.adapterConfig['relay'] ?? _kDefaultNostrRelay;
      _cachedNostrSender ??= NostrMessageSender();
      await InboxManager().addSenderPlugin('Nostr', _cachedNostrSender!,
          jsonEncode({'privkey': privkey, 'relay': relay}));
    } else if (provider == 'Session') {
      final prefs = await _getPrefs();
      final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
      await InboxManager().addSenderPlugin('Session', SessionMessageSender(), nodeUrl);
    } else if (provider == 'Pulse') {
      final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
      final prefs = await _getPrefs();
      // Extract server URL from the recipient address
      var serverUrl = prefs.getString('pulse_server_url') ?? '';
      final pAtIdx = address.indexOf('@');
      if (pAtIdx != -1) {
        final addrServer = address.substring(pAtIdx + 1);
        if (addrServer.startsWith('https://') || addrServer.startsWith('http://')) {
          serverUrl = addrServer;
        }
      }
      _cachedPulseSender ??= PulseMessageSender();
      await InboxManager().addSenderPlugin('Pulse', _cachedPulseSender!,
          jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
    } else {
      return false;
    }
    return InboxManager().routeMessage(provider, address, address, sendMsg);
  }

  Future<bool> _sendToContact(Contact contact, String plaintext, {bool noAutoRetry = false}) async {
    if (_identity == null) return false;
    final envelope = MessageEnvelope.wrap(_selfId.isNotEmpty ? _selfId : _identity!.id, plaintext);
    String encryptedText;
    try {
      encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
    } catch (e) {
      debugPrint('[E2EE] encryptMessage failed for ${contact.name} — attempting session rebuild: $e');
      try {
        final ourApiKey = _identity!.adapterConfig['token'] ?? '';
        final InboxReader contactReader;
        String initApiKey = ourApiKey;
        String initDbId = contact.databaseId;
        if (contact.provider == 'Firebase') {
          contactReader = FirebaseInboxReader();
          final atIdx = contact.databaseId.indexOf('@http');
          if (atIdx != -1) {
            initDbId = contact.databaseId.substring(0, atIdx);
            initApiKey = jsonEncode({'url': contact.databaseId.substring(atIdx + 1), 'key': ''});
          }
        } else if (contact.provider == 'Nostr') {
          contactReader = NostrInboxReader();
          initApiKey = '';
        } else if (contact.provider == 'Session') {
          contactReader = SessionInboxReader();
          final prefs = await _getPrefs();
          initApiKey = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          unawaited(_keys.publishSessionKeysTo(contact, _selfId));
        } else if (contact.provider == 'Pulse') {
          contactReader = PulseInboxReader();
          final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _getPrefs();
          var serverUrl = prefs.getString('pulse_server_url') ?? '';
          final pAt = contact.databaseId.indexOf('@');
          if (pAt != -1) {
            final s = contact.databaseId.substring(pAt + 1);
            if (s.startsWith('https://') || s.startsWith('http://')) serverUrl = s;
          }
          initApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
        } else {
          return false;
        }
        // Session-first key fetch for group members
        Map<String, dynamic>? bundle;
        final sessionAddrs = contact.transportAddresses['Session'] ?? [];
        if (sessionAddrs.isNotEmpty) {
          try {
            final sr = SessionInboxReader();
            final prefs = await _getPrefs();
            final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
            await sr.initializeReader(nodeUrl, sessionAddrs.first);
            bundle = await sr.fetchPublicKeys();
            if (bundle != null) debugPrint('[E2EE] Group key fetch OK via Session');
          } catch (_) {}
        }
        if (bundle == null) {
          await contactReader.initializeReader(initApiKey, initDbId);
          bundle = await contactReader.fetchPublicKeys();
        }
        // Nostr relay fallback for group members
        if (bundle == null && contact.provider == 'Nostr') {
          final atIdx = contact.databaseId.indexOf('@');
          final pk = atIdx > 0 ? contact.databaseId.substring(0, atIdx) : '';
          final pr = atIdx > 0 ? contact.databaseId.substring(atIdx + 1) : '';
          if (pk.isNotEmpty) {
            for (final relay in await gatherKnownRelays(pr, limit: 3)) {
              if (relay == pr) continue;
              try {
                final ar = NostrInboxReader();
                await ar.initializeReader('', '$pk@$relay');
                final ab = await ar.fetchPublicKeys();
                if (ab != null) { bundle = ab; break; }
              } catch (_) {}
            }
          }
        }
        if (bundle != null) {
          final keyChanged = await _signalService.buildSession(contact.databaseId, bundle);
          _keys.cacheContactKyberPk(contact.databaseId, bundle);
          if (keyChanged && !_keyChangeCtrl.isClosed) {
            _keyChangeCtrl.add((contactName: contact.name, contactId: contact.databaseId));
          }
          encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
        } else {
          debugPrint('[E2EE] No key bundle for ${contact.name} — group send skipped');
          return false;
        }
      } catch (e2) {
        debugPrint('[E2EE] Session build failed for ${contact.name}: $e2 — group send skipped');
        return false;
      }
    }
    if (encryptedText.startsWith('E2EE||') &&
        _pqcConfirmed.contains(contact.databaseId)) {
      encryptedText = await _keys.pqcWrap(encryptedText, contact.databaseId);
    }
    final routeProvider = _providerFromAddress(contact.databaseId).isNotEmpty
        ? _providerFromAddress(contact.databaseId)
        : contact.provider;
    final msg = Message(
      id: _uuid.v4(),
      senderId: _selfId.isNotEmpty ? _selfId : _identity!.id,
      receiverId: contact.databaseId,
      encryptedPayload: encryptedText,
      timestamp: DateTime.now(),
      adapterType: routeProvider.toLowerCase(),
    );
    await _addSenderPlugin(contact);
    final devPrefs = await _getPrefs();
    final devModeOn = devPrefs.getBool('dev_mode_enabled') ?? false;

    // Transport-priority routing: iterate transports in priority order,
    // try each address within a transport before moving to the next.
    bool sent = false;

    // P2P shortcut
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) debugPrint('[P2P] Direct delivery to ${contact.name}');
    }

    if (!sent) {
      for (final transport in contact.transportPriority) {
        if (devModeOn && !(devPrefs.getBool('dev_adapter_$transport') ?? true)) {
          debugPrint('[Dev] Adapter $transport disabled — skipping');
          continue;
        }
        final addresses = contact.transportAddresses[transport] ?? [];
        for (final addr in addresses) {
          sent = await _deliverEncryptedMessage(addr, msg);
          if (sent) {
            debugPrint('[SmartRouter] Delivered via $transport: $addr');
            break;
          }
        }
        if (sent) break;
      }
    }

    // LAN last resort
    final lanDisabled = devModeOn &&
        !(devPrefs.getBool('dev_adapter_LAN') ?? true);
    if (!sent && _lanSender != null && !lanDisabled) {
      sent = await _lanSender!.sendMessage('', '', msg);
      if (sent) {
        debugPrint('[LAN] Delivered via local network multicast');
        if (!_lanModeActive) {
          _lanModeActive = true;
          _scheduleNotify();
        }
      }
    } else if (sent && _lanModeActive) {
      _lanModeActive = false;
      _scheduleNotify();
    }

    return sent;
  }

  // ── Smart media routing ─────────────────────────────────────────────────
  //
  //  <48KB          → inline in single message (small photos, gzipped voice)
  //  ≥48KB, P2P up  → P2P DataChannel (1-on-1 only)
  //  ≥48KB, Blossom → Blossom HTTPS upload (1-on-1 + groups: upload once,
  //                    send E2EE key to each member)
  //  ≥48KB, nothing → relay chunks 32KB (last resort — antisocial to relays)
  //
  // NIP-44 plaintext limit is 65535 bytes (2-byte length prefix). Gift Wrap
  // uses double NIP-44 (seal + wrap). After base64 + Signal + double NIP-44,
  // 20KB raw bytes → ~50KB seal JSON — safely under 65535.
  static const _inlineThreshold = 8 * 1024; // 8KB — must fit in NIP-44 after double Gift Wrap

  Future<void> sendFile(Contact contact, Uint8List bytes, String name,
      {String mediaType = 'file'}) async {
    if (_identity == null) return;

    // Tier 0: small files (<48KB) go inline as a single message.
    if (bytes.length < _inlineThreshold) {
      await sendMessage(contact, MediaService.chunkPayloads(bytes, name, mediaType: mediaType).first);
      return;
    }

    // Tier 1: P2P DataChannel — direct transfer if already connected (1-on-1 only).
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      final ok = await _sendViaP2PBinary(contact, bytes, name, mediaType);
      if (ok) return;
    }

    // Tier 2: Blossom — HTTPS upload, works behind any NAT (1-on-1 + groups).
    if (BlossomService.instance.isAvailable) {
      final ok = await _sendViaBlossom(contact, bytes, name, mediaType);
      if (ok) return;
    }

    // Tier 3: relay chunks — last resort (floods relay with binary events).
    await _sendViaRelayChunks(contact, bytes, name, mediaType: mediaType);
  }

  /// Send a voice message using a 3-tier routing strategy:
  /// 1. Inline (single NIP-44 event) for short clips — full waveform preserved.
  /// 2. P2P DataChannel if connected (1-on-1 only).
  /// 3. Blossom HTTPS upload (works behind any NAT, 1-on-1 + groups).
  /// 4. Relay chunks as last resort (8 KB each, well within NIP-44 limit).
  ///
  /// OPUS inline threshold: 34 KB JSON (≈ 8–10 s at 24 kbps) — safely fits
  /// through double NIP-44 Gift Wrap (max ~36 KB raw before hitting 65535).
  /// WAV inline threshold: 6 KB (gzip-compressed short clips only).
  Future<bool> sendVoice(Contact contact, Uint8List audioBytes, int durationSeconds,
      List<double> amplitudes) async {
    if (_identity == null) return false;

    // Detect format from magic bytes.
    // OggS (4F 67 67 53) = OPUS; ftyp at offset 4 (66 74 79 70) = AAC/M4A; else WAV.
    final bool isCompressed;
    final String encField;
    final String fileExt;
    if (audioBytes.length >= 4 &&
        audioBytes[0] == 0x4F && audioBytes[1] == 0x67 &&
        audioBytes[2] == 0x67 && audioBytes[3] == 0x53) {
      isCompressed = true; encField = 'opus'; fileExt = 'opus';
    } else if (audioBytes.length >= 8 &&
        audioBytes[4] == 0x66 && audioBytes[5] == 0x74 &&
        audioBytes[6] == 0x79 && audioBytes[7] == 0x70) {
      isCompressed = true; encField = 'aac'; fileExt = 'm4a';
    } else {
      isCompressed = false; encField = 'wav'; fileExt = 'wav';
    }

    final ampInt = amplitudes.map((v) => (v * 100).round()).toList();
    final String payload;
    if (isCompressed) {
      final b64 = base64Encode(audioBytes);
      payload = jsonEncode({
        't': 'voice', 'd': b64, 'dur': durationSeconds,
        'sz': audioBytes.length, 'amp': ampInt, 'enc': encField,
      });
    } else {
      final compressed = gzip.encode(audioBytes);
      final b64 = base64Encode(compressed);
      payload = jsonEncode({
        't': 'voice', 'd': b64, 'dur': durationSeconds,
        'sz': audioBytes.length, 'amp': ampInt, 'z': true,
      });
    }

    final payloadBytes = utf8.encode(payload).length;
    // Inline threshold: NIP-44 double gift-wrap expands payload ~2.7×; nos.lol
    // hard-rejects events > 65535 bytes. 20 KB payload → ~55 KB final event (safe).
    // Larger messages go via Blossom (single HTTP upload, no size limit).
    final inlineLimit = isCompressed ? 20000 : 6000;
    if (payloadBytes <= inlineLimit) {
      await sendMessage(contact, payload);
      return true;
    }

    // Large voice — show locally as a full voice bubble, then route via tiers.
    final isGroup = contact.isGroup;
    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();
    final localMsg = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: payload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, localMsg, localTtl,
        onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();

    final voiceName = 'voice_${durationSeconds}s.$fileExt';

    // Tier 1: Blossom HTTPS upload.
    if (BlossomService.instance.isAvailable) {
      room.messages.removeWhere((m) => m.id == msgId);
      _scheduleNotify();
      final ok = await _sendViaBlossom(contact, audioBytes, voiceName, 'voice');
      if (ok) return true;
      // Re-add local placeholder for relay chunk fallback.
      room.messages.add(localMsg);
      _scheduleNotify();
    }

    // Tier 3: relay chunks (8 KB each — always fits NIP-44).
    bool allSent = true;
    try {
      _repo.setUploadProgress(msgId, 0.0);
      final chunks = MediaService.chunkPayloads(audioBytes, voiceName, mediaType: 'voice');
      int i = 0;
      for (final chunk in chunks) {
        final bool ok;
        if (isGroup) {
          ok = await _sendGroupChunk(contact, chunk);
        } else {
          ok = await _sendToContact(contact, chunk);
        }
        if (!ok) { allSent = false; break; }
        i++;
        _repo.setUploadProgress(msgId, i / chunks.length);
        _scheduleNotify();
      }
    } catch (e) {
      debugPrint('[Voice] sendVoice chunk loop error: $e');
      allSent = false;
    } finally {
      _repo.clearUploadProgress(msgId);
    }

    final idx = _repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx >= 0) room.messages[idx] = finalMsg;
    unawaited(LocalStorageService().saveMessage(contact.id, finalMsg.toJson()));
    notifyListeners();
    return allSent;
  }

  /// Send a video note (circle). Small recordings go inline; larger ones
  /// route through the 3-tier media pipeline (P2P → Blossom → relay chunks).
  Future<void> sendVideoNote(Contact contact, Uint8List mp4Bytes,
      int durationSeconds, Uint8List? thumbnailJpeg) async {
    if (_identity == null) return;
    final thumbB64 = thumbnailJpeg != null ? base64Encode(thumbnailJpeg) : null;
    final b64 = base64Encode(mp4Bytes);
    final payload = jsonEncode({
      't': 'video_note',
      'd': b64,
      'dur': durationSeconds,
      'sz': mp4Bytes.length,
      'n': 'video_note.mp4',
      if (thumbB64 != null) 'thumb': thumbB64,
    });
    final payloadBytes = utf8.encode(payload).length;
    // Small video notes: send inline (under NIP-44 limit after Gift Wrap)
    if (payloadBytes <= 6000) {
      await sendMessage(contact, payload);
      return;
    }
    // Large video notes: show locally with full payload, send via media pipeline
    final isGroup = contact.isGroup;
    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();
    final localMsg = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: payload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, localMsg, localTtl,
        onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();

    // Route through sendFile's 3-tier pipeline (P2P → Blossom → relay chunks)
    // We mark the local message first, then delegate the actual send.
    _repo.setUploadProgress(msgId, 0.0);
    bool sent = false;

    // Tier 1: P2P
    if (!isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = await _sendViaP2PBinary(contact, mp4Bytes, 'video_note.mp4', 'video_note');
    }

    // Tier 2: Blossom
    if (!sent && BlossomService.instance.isAvailable) {
      // Remove the local placeholder (Blossom creates its own)
      room.messages.removeWhere((m) => m.id == msgId);
      _scheduleNotify();
      sent = await _sendViaBlossom(contact, mp4Bytes, 'video_note.mp4', 'video_note');
      if (sent) {
        _repo.clearUploadProgress(msgId);
        return;
      }
      // Re-add local placeholder for relay chunk fallback
      room.messages.add(localMsg);
      _scheduleNotify();
    }

    // Tier 3: relay chunks
    if (!sent) {
      final chunks = MediaService.chunkPayloads(mp4Bytes, 'video_note.mp4',
          mediaType: 'video_note');
      int i = 0;
      bool allSent = true;
      for (final chunk in chunks) {
        final bool ok;
        if (isGroup) {
          ok = await _sendGroupChunk(contact, chunk);
        } else {
          ok = await _sendToContact(contact, chunk);
        }
        if (!ok) { allSent = false; break; }
        i++;
        _repo.setUploadProgress(msgId, i / chunks.length);
        _scheduleNotify();
      }
      sent = allSent;
    }

    _repo.clearUploadProgress(msgId);
    final idx = _repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: sent ? 'sent' : 'failed');
    if (idx >= 0) room.messages[idx] = finalMsg;
    final storageKey = isGroup ? contact.id : contact.storageKey;
    unawaited(LocalStorageService().saveMessage(storageKey, finalMsg.toJson()));
    notifyListeners();
  }

  /// Tier 2: Encrypt, upload to Blossom, send metadata message.
  /// Works for both 1-on-1 and group chats. For groups: upload once,
  /// send E2EE blossom payload (with AES key) to each member individually.
  Future<bool> _sendViaBlossom(Contact contact, Uint8List bytes, String name,
      String mediaType) async {
    final isGroup = contact.isGroup;
    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();

    // Generate thumbnail for images/gifs
    String? thumbnail;
    if (mediaType == 'img' || mediaType == 'gif') {
      try {
        thumbnail = await compute(_generateThumbnailIsolate, bytes);
      } catch (e) {
        debugPrint('[Blossom] Thumbnail generation failed: $e');
      }
    }

    // Show sending state immediately
    final displayPayload = BlossomPayloadHelpers.buildBlossomPayload(
      hash: '', server: '', key: '', iv: '',
      name: name, size: bytes.length, mediaType: mediaType, thumbnail: thumbnail,
    );
    final localMsg = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: displayPayload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _repo.trackMessageId(contact.id, localMsg.id);
    _repo.setUploadProgress(msgId, 0.1);
    notifyListeners();

    try {
      // Encrypt
      final enc = MediaCryptoService.encrypt(bytes);
      _repo.setUploadProgress(msgId, 0.3);
      _scheduleNotify();

      // Upload
      final result = await BlossomService.instance.upload(enc.ciphertext);
      if (result == null) {
        _repo.clearUploadProgress(msgId);
        // Remove sending placeholder — will fall back to relay chunks
        room.messages.removeWhere((m) => m.id == msgId);
        _scheduleNotify();
        return false;
      }
      _repo.setUploadProgress(msgId, 0.8);
      _scheduleNotify();

      // Build payload with key material
      final payload = BlossomPayloadHelpers.buildBlossomPayload(
        hash: result.hash,
        server: result.server,
        key: base64Encode(enc.key),
        iv: base64Encode(enc.iv),
        name: name,
        size: bytes.length,
        mediaType: mediaType,
        thumbnail: thumbnail,
      );

      // Send via E2EE — group: wrap in _group and send to each member
      bool sent = false;
      if (isGroup) {
        final groupPayload = jsonEncode({'_group': contact.id, 'text': payload});
        int membersSent = 0;
        for (final memberId in contact.members) {
          final memberContact = _contacts.findById(memberId);
          if (memberContact == null) continue;
          final ok = await _sendToContact(memberContact, groupPayload);
          if (ok) membersSent++;
        }
        sent = membersSent > 0;
      } else {
        sent = await _sendToContact(contact, payload);
      }

      final idx = _repo.messageIndexById(contact.id, msgId);
      final finalMsg = localMsg.copyWith(
        encryptedPayload: payload,
        status: sent ? 'sent' : 'failed',
      );
      if (idx != -1) room.messages[idx] = finalMsg;
      final storageKey = isGroup ? contact.id : contact.storageKey;
      await LocalStorageService().saveMessage(storageKey, finalMsg.toJson());
      _repo.clearUploadProgress(msgId);
      final localTtl = _repo.getChatTtlCached(contact.id);
      if (localTtl > 0) _repo.scheduleTtlDelete(contact, finalMsg, localTtl, onDeleted: () { if (!_disposed) notifyListeners(); });
      notifyListeners();
      return sent;
    } catch (e) {
      debugPrint('[Blossom] _sendViaBlossom error: $e');
      _repo.clearUploadProgress(msgId);
      room.messages.removeWhere((m) => m.id == msgId);
      _scheduleNotify();
      return false;
    }
  }

  /// Tier 1: Send file directly via P2P DataChannel binary frames.
  Future<bool> _sendViaP2PBinary(Contact contact, Uint8List bytes,
      String name, String mediaType) async {
    const chunkSize = 64 * 1024; // 64KB P2P frames
    final total = (bytes.length / chunkSize).ceil();
    final fid = _uuid.v4();
    final fh = hash_lib.sha256.convert(bytes).toString();

    // Send header as text message
    final header = jsonEncode({
      'p2p_file': true,
      'fid': fid,
      'n': name,
      'sz': bytes.length,
      'mt': mediaType,
      'total': total,
      'fh': fh,
    });
    if (!P2PTransportService.instance.send(contact.id, header)) return false;

    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();
    final displayPayload = jsonEncode({'t': mediaType, 'n': name, 'sz': bytes.length, 'd': ''});
    final localMsg = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: displayPayload,
      timestamp: DateTime.now(),
      adapterType: 'p2p',
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _repo.trackMessageId(contact.id, localMsg.id);
    _repo.setUploadProgress(msgId, 0.0);
    notifyListeners();

    bool allSent = true;
    try {
      for (int i = 0; i < total; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize).clamp(0, bytes.length);
        final chunk = bytes.sublist(start, end);
        if (!P2PTransportService.instance.sendBinary(contact.id, chunk)) {
          allSent = false;
          break;
        }
        _repo.setUploadProgress(msgId, (i + 1) / total);
        _scheduleNotify();
        // Yield to event loop periodically to avoid blocking UI
        if (i % 4 == 3) await Future.delayed(Duration.zero);
      }
    } finally {
      _repo.clearUploadProgress(msgId);
    }

    final idx = _repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, finalMsg, localTtl, onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();
    return allSent;
  }

  /// Tier 3 / group fallback: relay-based 32KB chunks (original behavior).
  Future<void> _sendViaRelayChunks(Contact contact, Uint8List bytes, String name,
      {String mediaType = 'file'}) async {
    final totalChunks = (bytes.length / (8 * 1024)).ceil();
    final isGroup = contact.isGroup;
    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();

    final displayPayload = jsonEncode({'t': mediaType, 'n': name, 'sz': bytes.length, 'd': ''});
    final localMsg = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: displayPayload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, localMsg, localTtl, onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();

    bool allSent = true;
    _repo.setUploadProgress(msgId, 0.0);
    int i = 0;
    String? fileId;
    try {
      for (final chunk in MediaService.chunkIterable(bytes, name, mediaType: mediaType)) {
        if (fileId == null) {
          try {
            final m = jsonDecode(chunk) as Map<String, dynamic>;
            fileId = m['fid'] as String?;
          } catch (e) { debugPrint('[Chat] Could not extract fileId from chunk: $e'); }
        }
        final bool ok;
        if (isGroup) {
          ok = await _sendGroupChunk(contact, chunk);
        } else {
          ok = await _sendToContact(contact, chunk);
        }
        if (!ok) { allSent = false; break; }
        i++;
        _repo.setUploadProgress(msgId, i / totalChunks);
        _scheduleNotify();
      }
      if (fileId != null) {
        _pendingSends[fileId] = (contact: contact, bytes: bytes, name: name);
        Future.delayed(const Duration(minutes: 10), () => _pendingSends.remove(fileId));
        _startStallCheckTimer();
      }
    } finally {
      _repo.clearUploadProgress(msgId);
    }

    final idx = _repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    final storageKey = isGroup ? contact.id : contact.storageKey;
    await LocalStorageService().saveMessage(storageKey, finalMsg.toJson());
    notifyListeners();
  }

  Future<bool> _sendGroupChunk(Contact group, String chunkPayload) async {
    final groupPayload = jsonEncode({'_group': group.id, 'text': chunkPayload});
    int sent = 0;
    for (final memberId in group.members) {
      final memberContact = _contacts.findById(memberId);
      if (memberContact == null) continue;
      final ok = await _sendToContact(memberContact, groupPayload);
      if (ok) sent++;
    }
    return sent > 0;
  }

  // ── Message CRUD ──────────────────────────────────────────────────────────

  Future<void> deleteLocalMessage(Contact contact, String messageId) async {
    _retryTimers[messageId]?.cancel();
    _retryTimers.remove(messageId);
    await _repo.deleteMessageFromRoom(contact, messageId);
    _scheduleNotify();
  }

  Future<void> deleteMessage(Contact contact, Message message) async {
    debugPrint('[Chat] deleteMessage: msgId=${message.id} senderId=${message.senderId} selfId=$_selfId isGroup=${contact.isGroup}');
    await deleteLocalMessage(contact, message.id);
    // senderId may be identity.id (UUID) or _selfId (pubkey@relay) depending
    // on when the message was created. Accept either.
    final selfBare = _selfId.contains('@') ? _selfId.split('@').first : _selfId;
    final isMine = message.senderId == _selfId ||
        message.senderId == _identity!.id ||
        message.senderId == selfBare;
    if (!isMine) {
      debugPrint('[Chat] deleteMessage: NOT my message — skip remote delete (senderId=${message.senderId} selfId=$_selfId identityId=${_identity!.id})');
      return;
    }
    if (contact.isGroup) {
      unawaited(_broadcaster.broadcastGroupDelete(
          contact, message.id, _contacts.contacts));
    } else {
      debugPrint('[Chat] deleteMessage: sending 1:1 delete to ${contact.name} (${contact.databaseId})');
      unawaited(_broadcaster.sendDeleteSignal(contact, message.id));
    }
  }

  void _handleRemoteDelete(String fromId, String msgId, {String? groupId}) {
    debugPrint('[Chat] _handleRemoteDelete: fromId=$fromId msgId=$msgId groupId=$groupId');
    if (groupId != null) {
      final room = _repo.getRoomForContact(groupId);
      if (room == null) return;
      final idx = _repo.messageIndexById(groupId, msgId);
      if (idx == -1) return;
      Contact? sender;
      for (final c in _contacts.contacts) {
        if (c.databaseId == fromId || c.databaseId.split('@').first == fromId.split('@').first) {
          sender = c;
          break;
        }
      }
      final senderId = sender?.id ?? fromId;
      if (room.messages[idx].senderId != senderId) return;
      room.messages.removeAt(idx);
      _repo.untrackMessageId(groupId, msgId);
      _repo.rebuildPositionIndex(groupId);
      unawaited(LocalStorageService().deleteMessage(room.contact.storageKey, msgId));
      _scheduleNotify();
    } else {
      debugPrint('[Chat] _handleRemoteDelete 1:1: scanning ${_repo.rooms.length} rooms for fromId=$fromId');
      bool found = false;
      for (final room in _repo.rooms) {
        if (room.contact.isGroup) continue;
        final cId = room.contact.databaseId;
        if (cId != fromId && cId.split('@').first != fromId) {
          continue;
        }
        debugPrint('[Chat] _handleRemoteDelete: matched room cId=$cId');
        final idx = _repo.messageIndexById(room.contact.id, msgId);
        if (idx != -1) {
          // Verify the message was sent by this contact.
          // Without this, a contact could delete your own outgoing messages.
          final msg = room.messages[idx];
          final senderPub = msg.senderId.split('@').first;
          final fromPub = fromId.split('@').first;
          debugPrint('[Chat] _handleRemoteDelete: msg.senderId=${msg.senderId} senderPub=$senderPub fromPub=$fromPub');
          if (senderPub != fromPub) {
            debugPrint('[Chat] _handleRemoteDelete: sender mismatch — REJECTED');
            break;
          }
          room.messages.removeAt(idx);
          _repo.untrackMessageId(room.contact.id, msgId);
          _repo.rebuildPositionIndex(room.contact.id);
          unawaited(LocalStorageService().deleteMessage(room.contact.storageKey, msgId));
          _scheduleNotify();
          found = true;
          debugPrint('[Chat] _handleRemoteDelete: SUCCESS — removed msgId=$msgId');
          break;
        } else {
          debugPrint('[Chat] _handleRemoteDelete: msgId=$msgId NOT found in room (${room.messages.length} msgs)');
        }
      }
      if (!found) debugPrint('[Chat] _handleRemoteDelete: NO matching room/msg found');
    }
  }

  Future<void> markRoomAsRead(Contact contact) async {
    final room = _repo.getRoomForContact(contact.id);
    if (room == null) return;
    final updated = <Map<String, dynamic>>[];
    for (int i = 0; i < room.messages.length; i++) {
      final m = room.messages[i];
      if (!m.isRead) {
        room.messages[i] = m.copyWith(isRead: true);
        updated.add(room.messages[i].toJson());
      }
    }
    if (updated.isNotEmpty) {
      unawaited(LocalStorageService().saveMessagesBatch(contact.storageKey, updated));
      _scheduleNotify();
      unawaited(_broadcaster.sendReadReceipt(contact));
    }
    // Reset incremental unread count
    if (_unreadCounts.containsKey(contact.id)) {
      _unreadCounts[contact.id] = 0;
      if (!_unreadChangedCtrl.isClosed) _unreadChangedCtrl.add(contact.id);
    }
  }

  Future<void> clearRoomHistory(Contact contact) =>
      _repo.clearRoomHistory(contact, onChanged: () { if (!_disposed) notifyListeners(); });

  Future<void> retryMessage(Contact contact, Message message) async {
    if (message.status != 'failed') return;
    final room = _repo.getRoomForContact(contact.id);
    if (room == null) return;
    room.messages.removeWhere((m) => m.id == message.id);
    _repo.untrackMessageId(contact.id, message.id);
    await LocalStorageService().deleteMessage(contact.storageKey, message.id);
    _scheduleNotify();
    await sendMessage(contact, message.encryptedPayload, noAutoRetry: true);
  }

  /// Evicts the oldest 100 entries when the map exceeds 500, preventing
  /// unbounded growth if messages are created faster than resolved.
  void _pruneRetryTimers() {
    if (_retryTimers.length > 500) {
      final keysToRemove = _retryTimers.keys.take(100).toList();
      for (final key in keysToRemove) {
        _retryTimers[key]?.cancel();
        _retryTimers.remove(key);
      }
      debugPrint('[ChatController] Pruned 100 oldest retry timers (was ${_retryTimers.length + 100})');
    }
  }

  void _scheduleAutoRetry(Contact contact, Message failedMsg) {
    _pruneRetryTimers();
    _retryTimers[failedMsg.id]?.cancel();
    _retryTimers[failedMsg.id] = Timer(const Duration(seconds: 30), () async {
      _retryTimers.remove(failedMsg.id);
      try {
        final room = _repo.getRoomForContact(contact.id);
        if (room == null) return;
        final idx = _repo.messageIndexById(contact.id, failedMsg.id);
        if (idx != -1 && room.messages[idx].status == 'failed') {
          await retryMessage(contact, room.messages[idx]);
        }
      } catch (e) {
        debugPrint('[ChatController] Auto-retry failed for ${failedMsg.id}: $e');
      }
    });
  }

  Future<void> _flushFailedMessages() async {
    int count = 0;
    for (final room in _repo.rooms) {
      final failed = room.messages.where((m) => m.status == 'failed').toList();
      if (failed.isEmpty) continue;
      for (final msg in failed) {
        if (_retryTimers.containsKey(msg.id)) continue;
        count++;
        unawaited(retryMessage(room.contact, msg));
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    if (count > 0) debugPrint('[Chat] Flushing $count failed message(s) after network change');
  }

  void _handleServerAck(String msgId) {
    for (final room in _repo.rooms) {
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.id != msgId) continue;
        if (m.status == 'sending') {
          room.messages[i] = m.copyWith(status: 'sent');
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          debugPrint('[Chat] Server ACK: $msgId → sent');
          _scheduleNotify();
        }
        return;
      }
    }
  }

  void _handleReadReceipt(String fromId) {
    // O(1) contact lookup via indexed map, then O(1) room lookup.
    final contactIndex = _getContactIndex();
    final contact = contactIndex[fromId] ?? contactIndex[fromId.split('@').first];
    if (contact == null) return;
    final room = _repo.getRoomForContact(contact.id);
    if (room == null) return;

    final updated = <Map<String, dynamic>>[];
    // Scan newest→oldest: once we hit an already-read message, all older ones
    // should be read too, so we can stop early.
    for (int i = room.messages.length - 1; i >= 0; i--) {
      final m = room.messages[i];
      if (m.status == 'sending' || m.status == 'sent' || m.status == 'delivered') {
        room.messages[i] = m.copyWith(status: 'read');
        updated.add(room.messages[i].toJson());
      } else if (m.status == 'read' && m.senderId == (_identity?.id ?? '')) {
        break; // All older outgoing messages should already be read.
      }
    }
    if (updated.isNotEmpty) {
      unawaited(LocalStorageService().saveMessagesBatch(
          room.contact.storageKey, updated));
      _scheduleNotify();
    }
  }

  void _handleDeliveryAck(String fromId, String msgId, {String? groupId}) {
    bool changed = false;
    final roomsToSearch = groupId != null
        ? [if (_repo.getRoomForContact(groupId) != null) _repo.getRoomForContact(groupId)!]
        : _repo.rooms.where((r) {
            final cId = r.contact.databaseId;
            return cId == fromId || cId.split('@').first == fromId.split('@').first;
          }).toList();

    String resolvedId = fromId;
    if (groupId != null) {
      for (final c in _contacts.contacts) {
        if (c.databaseId == fromId || c.databaseId.split('@').first == fromId.split('@').first) {
          resolvedId = c.id;
          break;
        }
      }
    }

    for (final room in roomsToSearch) {
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.id != msgId) continue;
        if (groupId != null && !m.deliveredTo.contains(resolvedId)) {
          final newDeliveredTo = [...m.deliveredTo, resolvedId];
          final newStatus = (m.status == 'sending' || m.status == 'sent') ? 'delivered' : m.status;
          room.messages[i] = m.copyWith(status: newStatus, deliveredTo: newDeliveredTo);
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
          break;
        }
        if (m.status == 'sending' || m.status == 'sent') {
          room.messages[i] = m.copyWith(status: 'delivered');
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
          break;
        }
      }
      if (changed) break;
    }
    if (changed) _scheduleNotify();
  }

  // ── Disappearing messages ─────────────────────────────────────────────────

  Future<void> setChatTtlSeconds(Contact contact, int seconds, {bool sendSignal = true}) async {
    _repo.setChatTtl(contact.id, seconds);
    final prefs = await _getPrefs();
    if (seconds == 0) {
      await prefs.remove('chat_ttl_${contact.id}');
    } else {
      await prefs.setInt('chat_ttl_${contact.id}', seconds);
    }
    if (sendSignal && !contact.isGroup) {
      unawaited(_broadcaster.sendTtlSignal(contact, seconds));
    }
    final room = _repo.getRoomForContact(contact.id);
    if (room != null && seconds > 0) {
      final now = DateTime.now();
      room.messages.removeWhere((m) {
        if (m.timestamp.add(Duration(seconds: seconds)).isBefore(now)) {
          _repo.untrackMessageId(contact.id, m.id);
          unawaited(LocalStorageService().deleteMessage(contact.storageKey, m.id));
          return true;
        }
        return false;
      });
      for (final m in List.of(room.messages)) {
        _repo.scheduleTtlDelete(contact, m, seconds, onDeleted: () { if (!_disposed) _scheduleNotify(); });
      }
      _scheduleNotify();
    }
  }

  // ── Broadcast delegation ──────────────────────────────────────────────────

  Future<void> sendTypingSignal(Contact contact) =>
      _broadcaster.sendTypingSignal(contact, () => _contacts.contacts);

  /// Send a hangup signal to a contact (used when declining an incoming call).
  Future<void> sendHangupSignal(Contact contact) =>
      _sendSignalTo(contact, 'webrtc_hangup', {'action': 'hangup'});

  Future<void> broadcastStatus(UserStatus status) =>
      _broadcaster.broadcastStatus(status, _contacts.contacts);

  Future<void> broadcastProfile(String name, String about, {String avatarB64 = ''}) =>
      _broadcaster.broadcastProfile(name, about, _contacts.contacts, avatarB64: avatarB64);

  Future<void> broadcastAddressUpdate() async {
    // Build per-transport address map from our own addresses
    final selfTa = _buildTransportMap(_allAddresses);
    final selfTp = ['Pulse', 'Nostr', 'Session', 'Firebase']
        .where((t) => selfTa.containsKey(t))
        .toList();
    // Include our Nostr secp256k1 pubkey so contacts can do HMAC signing
    // even if we don't have a Nostr relay address.
    final privkey = await _getNostrPrivkey();
    final nostrPub = privkey.isNotEmpty ? deriveNostrPubkeyHex(privkey) : null;
    return _broadcaster.broadcastAddressUpdate(
      _contacts.contacts, _selfId, _allAddresses,
      selfTransportAddresses: selfTa,
      selfTransportPriority: selfTp,
      nostrPubkey: nostrPub,
    );
  }

  Future<void> broadcastWorkingRelays() =>
      _broadcaster.broadcastWorkingRelays(_contacts.contacts);

  /// Sends our TURN server list to [contact] when a call connects via TURN.
  /// The peer saves the list and tries these servers on future calls.
  Future<void> broadcastTurnToContact(Contact contact) =>
      _broadcaster.broadcastTurnToContact(contact);

  Future<void> sendGroupInvite(Contact target, Contact group) =>
      _broadcaster.sendGroupInvite(target, group);

  Future<void> declineGroupInvite(SignalGroupInviteEvent invite) async {
    if (_identity == null || _selfId.isEmpty) return;
    await _sendSignalTo(invite.fromContact, 'group_invite_decline', {
      'groupId': invite.groupId,
      'from': _selfId,
    });
    debugPrint('[Group] Declined invite from ${invite.fromContact.name} for "${invite.groupName}"');
  }

  Future<void> sendGroupHistory(Contact target, Contact group, {int limit = 50}) async {
    if (_identity == null || _selfId.isEmpty) return;
    final storageKey = group.storageKey;
    final stored = await LocalStorageService()
        .loadMessagesPage(storageKey, pageSize: limit);
    if (stored.isEmpty) return;
    final messages = stored
        .map((raw) {
          try {
            final data = raw['data'] is String
                ? jsonDecode(raw['data'] as String) as Map<String, dynamic>
                : raw;
            final text = data['encryptedPayload'] as String? ?? '';
            if (text.isEmpty) return null;
            return Message.tryFromJson(raw);
          } catch (_) { return null; }
        })
        .whereType<Message>()
        .toList();
    await _broadcaster.sendGroupHistory(target, group, messages);
  }

  Future<void> acceptGroupInvite(SignalGroupInviteEvent invite) async {
    final _ex = _contacts.findById(invite.groupId);
    if (_ex != null && _ex.isGroup) return;
    // Only the declared creator should be allowed to send group invites.
    // Require creatorId to always be present — if absent,
    // any known contact could forge a group invite unconditionally.
    if (invite.creatorId == null || invite.creatorId!.isEmpty) {
      debugPrint('[Group] Rejected invite with no creatorId');
      return;
    }
    // F4-2: Compare using contact UUID (invite.fromContact.id), not databaseId.
    // databaseId is a transport address (e.g. "pubkey@wss://relay") while
    // creatorId is a UUID — they were never equal, causing every invite to fail
    // or (if attacker sets creatorId=databaseId) to be trivially bypassed.
    final senderUuid = invite.fromContact.id;
    if (senderUuid != invite.creatorId) {
      debugPrint('[Group] Rejected invite from non-creator '
          '$senderUuid (declared creator: ${invite.creatorId})');
      return;
    }
    // Reject invite where our own UUID is absent from the member list.
    // Prevents joining a group in an inconsistent state where we're not
    // listed as a member (e.g., relay replaying an old invite to someone else).
    // F6 fix: use _identity?.id (UUID) not _selfId (transport address).
    // group.members contains UUIDs; _selfId is "pubkey@relay" — never a match.
    final myUuid = _identity?.id ?? '';
    if (myUuid.isNotEmpty && !invite.members.contains(myUuid)) {
      debugPrint('[Group] Rejected invite: self not listed in members');
      return;
    }
    final newGroup = Contact(
      id: invite.groupId,
      name: invite.groupName,
      provider: 'group',
      databaseId: '',
      publicKey: '',
      isGroup: true,
      members: invite.members,
      creatorId: invite.creatorId,
    );
    await _contacts.addContact(newGroup);
    _invalidateContactIndex();
    debugPrint('[Group] Joined group "${invite.groupName}" via invite');
    _scheduleNotify();
  }

  Future<void> broadcastGroupUpdate(Contact group) =>
      _broadcaster.broadcastGroupUpdate(group, _contacts.contacts);

  /// Rotate the sender key for a group after a member is removed, then
  /// redistribute to all remaining members. Call this AFTER updating the
  /// group's member list and broadcasting the group update.
  Future<void> rotateGroupSenderKey(Contact group) async {
    if (!group.isGroup || _selfId.isEmpty) return;
    try {
      final sk = SenderKeyService.instance;
      final skdmBytes = await sk.rotateKey(group.id, _selfId);
      final skdmB64 = base64Encode(skdmBytes);
      for (final memberId in group.members) {
        final memberContact = _contacts.findById(memberId);
        if (memberContact == null) continue;
        final distOk = await _sendSignalTo(memberContact, 'sender_key_dist', {
          'groupId': group.id,
          'skdm': skdmB64,
        });
        if (distOk) await sk.markDistributed(group.id, memberId);
      }
      debugPrint('[SenderKey] Rotated and redistributed key for group ${group.name}');
    } catch (e) {
      debugPrint('[SenderKey] Key rotation failed for group ${group.name}: $e');
    }
  }

  Future<void> markGroupMessagesRead(Contact group) async {
    if (!group.isGroup || _identity == null || _selfId.isEmpty) return;
    final room = _repo.getRoomForContact(group.id);
    if (room == null) return;
    await _broadcaster.markGroupMessagesRead(
        group, room.messages, _contacts.contacts, _selfId);
  }

  // ── Online / Adapter health ───────────────────────────────────────────────

  void _onAdapterHealthChange(String addr, bool healthy) {
    _adapterHealth[addr] = healthy;
    sentryBreadcrumb('Adapter health: ${healthy ? "healthy" : "unhealthy"}', category: 'adapter');
    debugPrint('[Failover] $addr → ${healthy ? "healthy" : "UNHEALTHY"}');
    if (!healthy && addr == _selfId) {
      final newPrimary = _allAddresses.firstWhere(
        (a) => a != addr && (_adapterHealth[a] ?? true),
        orElse: () => '',
      );
      if (newPrimary.isNotEmpty) {
        _promoteAddress(addr, newPrimary);
      } else {
        debugPrint('[Failover] No healthy alternate found — staying on $addr');
      }
    }
  }

  void _promoteAddress(String oldAddr, String newPrimary) {
    debugPrint('[Failover] Promoting "$newPrimary" (was "$oldAddr")');
    _selfId = newPrimary;
    if (!_failoverCtrl.isClosed) {
      _failoverCtrl.add((from: oldAddr, to: newPrimary));
    }
    unawaited(broadcastAddressUpdate());
    _scheduleNotify();
  }

  // (SmartRouter per-contact promotion removed — transport-priority routing replaces it)

  // ── Reactions ─────────────────────────────────────────────────────────────

  Future<void> toggleReaction(Contact contact, String msgId, String emoji) async {
    if (_identity == null || _selfId.isEmpty) return;
    final storageKey = contact.storageKey;
    final compositeKey = '${emoji}_$_selfId';
    final currentSet = _repo.getReactions(storageKey, msgId);
    final senderIds = currentSet[emoji] ?? [];
    final alreadyReacted = senderIds.contains(_selfId);

    _repo.applyReactionLocally(storageKey, msgId, compositeKey, !alreadyReacted);
    if (alreadyReacted) {
      unawaited(LocalStorageService().removeReaction(storageKey, msgId, emoji, _selfId)
          .catchError((Object e) => debugPrint('[Chat] removeReaction DB failed: $e')));
    } else {
      unawaited(LocalStorageService().addReaction(storageKey, msgId, emoji, _selfId)
          .catchError((Object e) => debugPrint('[Chat] addReaction DB failed: $e')));
    }
    _reactionVersions[storageKey] = (_reactionVersions[storageKey] ?? 0) + 1;
    _scheduleNotify();

    if (contact.isGroup) {
      for (final memberId in contact.members) {
        final memberContact = _contacts.findById(memberId);
        if (memberContact == null) continue;
        unawaited(_broadcaster.sendReactionSignal(
            memberContact, msgId, emoji, _selfId,
            remove: alreadyReacted, groupId: contact.id));
      }
    } else {
      unawaited(_broadcaster.sendReactionSignal(
          contact, msgId, emoji, _selfId, remove: alreadyReacted));
    }
  }

  // ── Message editing ───────────────────────────────────────────────────────

  Future<void> editMessage(Contact contact, String msgId, String newText) async {
    if (_identity == null) return;
    final storageKey = contact.storageKey;
    final room = _repo.getRoomForContact(contact.id);
    if (room == null) return;
    final idx = _repo.messageIndexById(contact.id, msgId);
    if (idx == -1) return;
    if (room.messages[idx].senderId != _identity!.id) return;
    final updated = room.messages[idx].copyWith(encryptedPayload: newText, isEdited: true);
    room.messages[idx] = updated;
    await LocalStorageService().saveMessage(storageKey, updated.toJson());
    _editVersions[storageKey] = (_editVersions[storageKey] ?? 0) + 1;
    _scheduleNotify();
    if (contact.isGroup) {
      unawaited(_broadcaster.sendGroupEditSignal(
          contact, msgId, newText, _contacts.contacts));
    } else {
      unawaited(_broadcaster.sendEditSignal(contact, msgId, newText));
    }
  }

  // ── P2P relay exchange ────────────────────────────────────────────────────

  static const _peerRelaysKey = 'peer_relays_v1';

  static Future<List<String>> loadPeerRelays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_peerRelaysKey) ?? [];
  }

  static Future<void> savePeerRelays(List<String> relays) async {
    if (relays.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = Set<String>.from(prefs.getStringList(_peerRelaysKey) ?? []);
    const maxUrlLen = 256;
    const maxRelays = 50; // cap total stored peer relays
    final before = existing.length;
    for (final r in relays) {
      if (existing.length >= maxRelays) break;
      // Validate relay URLs received from untrusted peers
      if (r.length > maxUrlLen) continue;
      final uri = Uri.tryParse(r);
      if (uri == null || uri.host.isEmpty) continue;
      if (uri.scheme != 'wss') continue;          // no ws:// cleartext
      if (uri.userInfo.isNotEmpty) continue;       // no embedded credentials
      // Reject loopback and private IP ranges to prevent LAN port-scanning
      final h = uri.host.toLowerCase();
      if (h == 'localhost' || h == '127.0.0.1' || h == '::1') continue;
      if (h.startsWith('10.') || h.startsWith('192.168.') ||
          h.startsWith('169.254.') ||
          RegExp(r'^172\.(1[6-9]|2[0-9]|3[01])\.').hasMatch(h)) {
        continue;
      }
      // 100.64.0.0/10 — Carrier-Grade NAT (RFC 6598)
      if (h.startsWith('100.')) {
        final second = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
        if (second != null && second >= 64 && second <= 127) continue;
      }
      existing.add(r);
    }
    if (existing.length > before) {
      await prefs.setStringList(_peerRelaysKey, existing.toList());
      debugPrint('[P2P] Learned ${existing.length - before} new relay(s) from peer');
    }
  }

  // ── Export chat history ───────────────────────────────────────────────────

  Future<String?> exportHistory(Contact contact) async {
    final storageKey = contact.storageKey;
    final all = await LocalStorageService().loadMessages(storageKey);
    final myId = _identity?.id ?? '';
    final buf = StringBuffer('=== Chat with ${contact.name} ===\n\n');
    for (final m in all) {
      final msg = Message.tryFromJson(m);
      if (msg == null) continue;
      final who = msg.senderId == myId ? 'You' : contact.name;
      final ts = '${msg.timestamp.year}-${msg.timestamp.month.toString().padLeft(2, '0')}-'
          '${msg.timestamp.day.toString().padLeft(2, '0')} '
          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
      final text = MediaService.isMediaPayload(msg.encryptedPayload)
          ? '[Media: ${MediaService.parse(msg.encryptedPayload)?.name ?? 'file'}]'
          : msg.encryptedPayload;
      buf.writeln('[$ts] $who: $text');
    }
    try {
      // Write to app-private documents directory, not world-accessible Downloads.
      final dir = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final safeName = contact.name.replaceAll(RegExp(r'[^\w\-. ]'), '_');
      final file = File('${dir.path}/chat_${safeName}_$date.txt');
      await file.writeAsString(buf.toString());
      return file.path;
    } catch (e) {
      debugPrint('[ChatController] exportChatHistory failed: $e');
      return null;
    }
  }

  // ── Scheduled messages ────────────────────────────────────────────────────

  /// Schedules [text] to be sent to [contact] at [scheduledAt].
  ///
  /// Creates a placeholder [Message] with status `'scheduled'` that is shown
  /// in the chat UI immediately. The message and its timer are persisted to
  /// SharedPreferences so they survive app restarts (see
  /// [_restoreScheduledMessages]).
  Future<void> scheduleMessage(Contact contact, String text, DateTime scheduledAt) async {
    if (_identity == null) return;
    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();
    final placeholder = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: text,
      timestamp: DateTime.now(),
      adapterType: contact.isGroup ? 'group' : contact.provider == 'Nostr' ? 'nostr' :
          contact.provider == 'Session' ? 'session' : 'firebase',
      isRead: true,
      status: 'scheduled',
      scheduledAt: scheduledAt,
    );
    room.messages.add(placeholder);
    _repo.trackMessageId(contact.id, placeholder.id);
    _scheduleNotify();

    final prefs = await _getPrefs();
    final storageKey = 'scheduled_${contact.id}';
    List existing;
    try {
      existing = jsonDecode(prefs.getString(storageKey) ?? '[]') as List;
    } catch (e) {
      debugPrint('[Scheduled] Corrupt scheduled list for ${contact.id}: $e');
      existing = [];
    }
    existing.add(placeholder.toJson());
    await prefs.setString(storageKey, jsonEncode(existing));
    _scheduleTimer(contact, placeholder);
  }

  /// Arms a [Timer] that fires [_fireScheduled] when [msg.scheduledAt] arrives.
  ///
  /// If the scheduled time is already past (e.g. restored after a long
  /// offline period), the message is fired immediately.
  void _scheduleTimer(Contact contact, Message msg) {
    final delay = msg.scheduledAt!.difference(DateTime.now());
    if (delay.isNegative) {
      unawaited(_fireScheduled(contact, msg));
      return;
    }
    _pruneRetryTimers();
    _retryTimers[msg.id] = Timer(delay, () => unawaited(_fireScheduled(contact, msg)));
  }

  /// Sends the previously-scheduled [msg] via [sendMessage], removes the
  /// placeholder from the chat room, and cleans up SharedPreferences.
  Future<void> _fireScheduled(Contact contact, Message msg) async {
    _retryTimers.remove(msg.id);
    final room = _repo.getRoomForContact(contact.id);
    if (room != null) {
      room.messages.removeWhere((m) => m.id == msg.id);
      _repo.untrackMessageId(contact.id, msg.id);
    }
    final prefs = await _getPrefs();
    final storageKey = 'scheduled_${contact.id}';
    List list;
    try {
      list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
          .where((m) => m is Map && m['id'] != msg.id)
          .toList();
    } catch (e) {
      debugPrint('[Scheduled] Corrupt scheduled list on fire for ${contact.id}: $e');
      list = [];
    }
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
    await sendMessage(contact, msg.encryptedPayload);
  }

  /// Cancels a pending scheduled message identified by [msgId].
  ///
  /// Stops its timer, removes the placeholder from the room, and deletes
  /// the entry from SharedPreferences so it is not restored on next launch.
  Future<void> cancelScheduledMessage(Contact contact, String msgId) async {
    _retryTimers[msgId]?.cancel();
    _retryTimers.remove(msgId);
    final room = _repo.getRoomForContact(contact.id);
    if (room != null) {
      room.messages.removeWhere((m) => m.id == msgId);
      _repo.untrackMessageId(contact.id, msgId);
    }
    _scheduleNotify();
    final prefs = await _getPrefs();
    final storageKey = 'scheduled_${contact.id}';
    List list;
    try {
      list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
          .where((m) => m is Map && m['id'] != msgId)
          .toList();
    } catch (e) {
      debugPrint('[Scheduled] Corrupt scheduled list on cancel for ${contact.id}: $e');
      list = [];
    }
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
  }

  /// Restores all persisted scheduled messages from SharedPreferences on init.
  ///
  /// For each contact, deserialises the `scheduled_<contactId>` list, adds
  /// the placeholder messages back into their rooms, and re-arms timers via
  /// [_scheduleTimer]. Called once during [_init].
  Future<void> _restoreScheduledMessages() async {
    final prefs = await _getPrefs();
    for (final contact in _contacts.contacts) {
      final storageKey = 'scheduled_${contact.id}';
      final raw = prefs.getString(storageKey);
      if (raw == null) continue;
      try {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final msg = Message.tryFromJson(item);
          if (msg == null || msg.scheduledAt == null) continue;
          final room = _repo.getOrCreateRoom(contact);
          room.messages.add(msg);
          _repo.trackMessageId(contact.id, msg.id);
          _scheduleTimer(contact, msg);
        }
      } catch (e) {
        debugPrint('[Scheduled] Restore error for ${contact.id}: $e');
      }
    }
  }

  // ── File transfer resume ──────────────────────────────────────────────────

  void _startStallCheckTimer() {
    if (_stallCheckTimer?.isActive == true) return;
    _stallCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Prune _chunkSenderIds entries for transfers that ChunkAssembler
      // has already evicted (stale timeout / capacity). Prevents unbounded growth.
      final activeIds = _chunkAssembler.activeTransferIds.toSet();
      _chunkSenderIds.removeWhere((fid, _) => !activeIds.contains(fid));

      for (final fid in _chunkAssembler.activeTransferIds) {
        if (!_chunkAssembler.isStalled(fid)) continue;
        final missing = _chunkAssembler.getMissingChunks(fid);
        if (missing == null || missing.isEmpty) continue;
        // F7 fix: send chunk_req only to the contact who started this transfer.
        // Broadcasting to all contacts leaks file IDs and lets unrelated
        // contacts inject fake chunks.
        final senderId = _chunkSenderIds[fid];
        final senderContact = senderId != null
            ? _contacts.findById(senderId)
            : null;
        if (senderContact != null) {
          unawaited(_sendSignalTo(senderContact, 'chunk_req', {
            'fid': fid,
            'missing': missing,
          }));
        }
        debugPrint('[Resume] Sent chunk_req for $fid — missing ${missing.length} chunks');
      }
      if (_chunkAssembler.activeTransferIds.isEmpty && _pendingSends.isEmpty) {
        _stallCheckTimer?.cancel();
        _stallCheckTimer = null;
      }
    });
  }

  Future<void> _resendMissingChunks(
      String fileId, List<int> missingIndices, String recipientId) async {
    final pending = _pendingSends[fileId];
    if (pending == null) {
      debugPrint('[Resume] chunk_req for $fileId but not in pending sends — ignoring');
      return;
    }
    // Cap and deduplicate indices — prevents amplification
    // attack where attacker sends chunk_req with thousands of duplicate indices.
    final uniqueIndices = missingIndices.toSet().take(50).toList();
    debugPrint('[Resume] Re-sending ${uniqueIndices.length} chunks for $fileId to $recipientId');
    final allChunks = MediaService.chunkIterable(pending.bytes, pending.name).toList();
    for (final idx in uniqueIndices) {
      if (idx < 0 || idx >= allChunks.length) continue;
      await _sendToContact(pending.contact, allChunks[idx]);
    }
  }

  // ── P2P helpers ───────────────────────────────────────────────────────────

  void _handleP2PMessage(String contactId, String encryptedPayload) {
    final contact = _contacts.findById(contactId);
    if (contact == null) return;

    // Use SHA-256 of the full encrypted payload as the dedup ID.
    // First-32-bytes truncation allowed two distinct ciphertexts with identical
    // first 32 bytes to collide and be deduplicated incorrectly.
    final msgId = hash_lib.sha256.convert(utf8.encode(encryptedPayload)).toString();

    _handleIncomingMessages([
      Message(
        id: msgId,
        senderId: contact.databaseId,
        receiverId: _selfId,
        encryptedPayload: encryptedPayload,
        timestamp: DateTime.now(),
        adapterType: 'p2p',
      ),
    ]);
  }

  // ── P2P binary file receive ───────────────────────────────────────────────

  // Active P2P file transfers: fid → header + accumulated frames
  final _p2pFileTransfers = <String, _P2PFileTransfer>{};

  void _handleP2PBinaryFrame(String contactId, Uint8List data) {
    // Find which transfer this frame belongs to (most recent from this contact)
    _P2PFileTransfer? transfer;
    for (final t in _p2pFileTransfers.values) {
      if (t.contactId == contactId && t.framesReceived < t.total) {
        transfer = t;
        break;
      }
    }
    if (transfer == null) {
      debugPrint('[P2P] Binary frame from $contactId but no active transfer');
      return;
    }
    transfer.frames.add(data);
    transfer.framesReceived++;

    if (transfer.framesReceived >= transfer.total) {
      // Assemble the file
      final assembled = BytesBuilder(copy: false);
      for (final f in transfer.frames) {
        assembled.add(f);
      }
      final fileBytes = assembled.toBytes();
      final fileHash = hash_lib.sha256.convert(fileBytes).toString();
      _p2pFileTransfers.remove(transfer.fid);

      if (fileHash != transfer.fileHash) {
        debugPrint('[P2P] File hash mismatch for ${transfer.name}: expected ${transfer.fileHash}, got $fileHash');
        return;
      }

      // Deliver as media payload
      final payload = jsonEncode({
        't': transfer.mediaType,
        'd': base64Encode(fileBytes),
        'n': transfer.name,
        'sz': fileBytes.length,
      });

      final contact = _contacts.findById(contactId);
      if (contact == null) return;

      _handleIncomingMessages([
        Message(
          id: _uuid.v4(),
          senderId: contact.databaseId,
          receiverId: _selfId,
          encryptedPayload: payload,
          timestamp: DateTime.now(),
          adapterType: 'p2p',
        ),
      ]);
      debugPrint('[P2P] File received: ${transfer.name} (${fileBytes.length}B)');
    }
  }

  /// Called when a P2P text message contains a p2p_file header.
  void _handleP2PFileHeader(String contactId, Map<String, dynamic> header) {
    final fid = header['fid'] as String? ?? '';
    final name = header['n'] as String? ?? 'file';
    final total = header['total'] as int? ?? 0;
    final fh = header['fh'] as String? ?? '';
    final mt = header['mt'] as String? ?? 'file';
    if (fid.isEmpty || total <= 0 || fh.isEmpty) return;
    if (_p2pFileTransfers.length > 10) return; // limit concurrent transfers
    _p2pFileTransfers[fid] = _P2PFileTransfer(
      fid: fid,
      contactId: contactId,
      name: name,
      total: total,
      fileHash: fh,
      mediaType: mt,
    );
    debugPrint('[P2P] File transfer started: $name ($total frames) from $contactId');
  }

  // (SmartRouter delivery stats removed — transport-priority routing replaces promotion)

  // ── Connection Reset ──────────────────────────────────────────────────────

  /// Reset all Nostr connections (pool + subscription) after proxy settings change.
  /// Called from settings screen when force-Tor toggle changes.
  Future<void> resetNostrConnections() async {
    await _cachedNostrSender?.resetConnections();
    final reader = InboxManager().reader;
    if (reader is NostrInboxReader) await reader.resetConnections();
    for (final sender in InboxManager().senders.values) {
      if (sender is NostrMessageSender) await sender.resetConnections();
    }
    debugPrint('[ChatController] Nostr connections reset');
  }

  /// Send a raw JSON message to the Pulse relay (for SFU signaling).
  void sendRawPulseSignal(String jsonMsg) {
    _cachedPulseSender?.sendRaw(jsonMsg);
  }

  /// Check if a Pulse relay sender is available (for SFU routing).
  bool get hasPulseRelay => _cachedPulseSender != null;

  /// Reset all Pulse relay connections (called when Force-Tor toggle changes).
  Future<void> resetPulseConnections() async {
    final reader = InboxManager().reader;
    if (reader is PulseInboxReader) await reader.resetConnection();
    for (final sender in InboxManager().senders.values) {
      if (sender is PulseMessageSender) await sender.resetConnection();
    }
    debugPrint('[ChatController] Pulse connections reset');
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
    _notifyTimer?.cancel();
    NetworkMonitor.instance.stopMonitoring();
    P2PTransportService.instance.dispose();
    _lanReader?.close();
    _lanSender?.close();
    _bundleRefreshSub?.cancel();
    for (final s in _messageSubs) { s.cancel(); }
    for (final s in _signalSubs) { s.cancel(); }
    for (final s in _healthSubs) { s.cancel(); }
    _healthSubs.clear();
    for (final s in _dispatcherSubs) { s.cancel(); }
    _dispatcherSubs.clear();
    _signalDispatcher?.dispose();
    _signalDispatcher = null;
    _sigRateLimiter.clear();
    SenderKeyService.instance.clearCaches();
    _broadcaster.dispose();
    for (final t in _retryTimers.values) { t.cancel(); }
    _retryTimers.clear();
    _repo.dispose();
    // (_deliveryStatsHalveTimer removed)
    _stallCheckTimer?.cancel();
    _typingStreamCtrl.close();
    _incomingCallController.close();
    _incomingGroupCallController.close();
    _signalStreamController.close();
    _newMsgController.close();
    _unreadChangedCtrl.close();
    _e2eeFailCtrl.close();
    _statusUpdatesCtrl.close();
    _keyChangeCtrl.close();
    _tamperWarningCtrl.close();
    _failoverCtrl.close();
    _groupInviteCtrl.close();
    _groupInviteDeclineCtrl.close();
    _groupUpdatePublicCtrl.close();
    _msgRateLimiter.clear();
    _cachedNostrSender?.zeroize();
    _cachedNostrSender = null;
    _cachedNostrPrivkey = null;
    _cachedFirebaseSender = null;
    _cachedSessionSender = null;
    _adhocSessionReader?.close();
    _adhocSessionReader = null;
    _cachedPulseSender = null;
    _contactIndex = null;
    unawaited(VoiceService().dispose());
    _signalService.zeroize();
    PqcService().zeroize();
    final reader = InboxManager().reader;
    if (reader is NostrInboxReader) reader.zeroize();
    if (reader is PulseInboxReader) reader.zeroize();
    for (final sender in InboxManager().senders.values) {
      if (sender is NostrMessageSender) sender.zeroize();
      if (sender is PulseMessageSender) sender.zeroize();
    }
    super.dispose();
  }
}

// ── P2P file transfer state ───────────────────────────────────────────────

class _P2PFileTransfer {
  final String fid;
  final String contactId;
  final String name;
  final int total;
  final String fileHash;
  final String mediaType;
  final List<Uint8List> frames = [];
  int framesReceived = 0;

  _P2PFileTransfer({
    required this.fid,
    required this.contactId,
    required this.name,
    required this.total,
    required this.fileHash,
    required this.mediaType,
  });
}

// ── Thumbnail generation (runs in isolate) ────────────────────────────────

/// Top-level function for compute(): generates a tiny JPEG thumbnail.
String? _generateThumbnailIsolate(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final thumb = img.copyResize(decoded, width: 64);
    final jpeg = img.encodeJpg(thumb, quality: 40);
    return base64Encode(jpeg);
  } catch (_) {
    return null;
  }
}
