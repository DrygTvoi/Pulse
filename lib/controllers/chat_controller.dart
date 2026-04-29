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
import '../services/group_invite_link.dart';
import '../services/signal_dispatcher.dart';
import '../services/ice_server_config.dart';
import '../services/media_validator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../models/contact_repository.dart';
// Facade services
import '../services/message_repository.dart';
import '../services/key_manager.dart';
import '../services/key_derivation_service.dart';
import '../services/recovery_key_service.dart';
import '../services/signal_broadcaster.dart';
import '../services/nip44_service.dart' as nip44;

part 'chat_controller_scheduled.dart';
part 'chat_controller_extras.dart';
part 'chat_controller_p2p.dart';
part 'chat_controller_pulse_pool.dart';
part 'chat_controller_health.dart';
part 'chat_controller_files.dart';
part 'chat_controller_keys.dart';
part 'chat_controller_crud.dart';
part 'chat_controller_groups.dart';
part 'chat_controller_sfu.dart';
part 'chat_controller_disappearing.dart';
part 'chat_controller_media.dart';
part 'chat_controller_send.dart';
part 'chat_controller_incoming.dart';

enum ConnectionStatus { disconnected, connecting, connected }

class ChatController extends ChangeNotifier {
  static ChatController _instance =
      ChatController._create(ContactManager(), SignalService());
  factory ChatController() => _instance;
  ChatController._create(this._contacts, this._signalService);

  /// Constructor for unit testing — pass a [MockContactRepository] and
  /// optionally an isolated [SignalService] (defaults to the singleton
  /// to preserve existing test behaviour).
  @visibleForTesting
  factory ChatController.forTesting(
    IContactRepository contacts, {
    SignalService? signalService,
  }) =>
      ChatController._create(contacts, signalService ?? SignalService());

  /// Replace the singleton for testing. Call in setUp/tearDown.
  @visibleForTesting
  static void setInstanceForTesting(ChatController instance) =>
      _instance = instance;

  final IContactRepository _contacts;

  /// Public read-only handle on the contact repository — used by adapters
  /// that need to walk the roster (e.g. nostr_adapter falling over to
  /// recipient's alternate relays when the primary publish fails).
  IContactRepository get contacts => _contacts;

  Identity? _identity;
  String _selfId = ''; // adapter-specific ID used as senderId in outgoing messages
  String _selfName = ''; // display name for message envelope
  String _selfAvatar = ''; // base64 avatar for message envelope
  final SignalService _signalService;
  StreamSubscription<void>? _bundleRefreshSub;
  final List<StreamSubscription> _messageSubs = [];
  final List<StreamSubscription> _signalSubs = [];
  final List<StreamSubscription> _healthSubs = [];
  final List<StreamSubscription> _dispatcherSubs = [];
  final Map<String, bool> _adapterHealth = {}; // addr → isHealthy
  /// addr → time when primary first turned unhealthy this cycle. Used to
  /// gate auto-migration so a brief flap doesn't trigger identity swap.
  final Map<String, DateTime> _primaryUnhealthySince = {};
  /// Minimum sustained unhealthy duration before migrating Nostr primary.
  static const _kPrimaryMigrationGrace = Duration(seconds: 45);
  /// Guard against concurrent migrations on repeated health events.
  bool _migrating = false;
  /// contactId → transport name of the most recent successful delivery.
  /// Read by the chat header to show which transport is active.
  final Map<String, String> _lastDeliveryTransport = {};
  /// contactId → last time we pushed a fresh sys_keys bundle in response to
  /// a stale-prekey decrypt failure. Rate-limits recovery pushes to avoid
  /// relay spam if the sender keeps retrying.
  final Map<String, DateTime> _lastStaleKeyPush = {};
  /// Per-peer cooldown on PROCESSING incoming session_reset signals.
  /// `_broadcaster.sendSignalToAllTransports(... 'session_reset' ...)` fans
  /// out via Nostr × N relays + Session + Pulse, so a single peer-side
  /// recovery dance generates 5-7 duplicate session_reset arrivals on us.
  /// Each one calling `deleteContactData + buildSession` wipes whatever
  /// session we just built and produces a fresh one with a new ratchet key
  /// — and our PreKey-init message based on the previous bundle is now
  /// against a session the peer has already moved past. Net result: the
  /// bidirectional recovery never converges. Process the first arrival,
  /// drop subsequent ones for [_kSessionResetReceiveCooldown].
  final Map<String, DateTime> _lastSessionResetReceived = {};
  static const Duration _kSessionResetReceiveCooldown = Duration(seconds: 10);
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
  )..pulseGroupSignalSender = _sendSignalToContactViaPulseServer;

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

  // ── Sleep / wake detection ────────────────────────────────────────────
  // Timer fires every 30s; if `now - last_tick > 60s`, the host suspended
  // (system sleep, mobile background freeze, hibernation). All Pulse pool
  // WebSockets are dead-but-zombie at that point — Dart's `sink.add`
  // returns void on a TCP socket the OS killed during sleep, so silent
  // sends-into-void burn until the next ping cycle (~30-70s) detects the
  // missing pong. Force-reconnect every per-server pool entry on detected
  // wake so the next user message uses a fresh authenticated channel.
  Timer? _wakeWatchdogTimer;
  DateTime _lastWakeTick = DateTime.now();
  static const Duration _wakeTickInterval = Duration(seconds: 30);
  static const Duration _wakeJumpThreshold = Duration(seconds: 60);

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
  void setActiveRoom(String? contactId) {
    _activeRoomId = contactId;
    // Opportunistic eviction: every time the user switches to a chat,
    // drop rooms that haven't been touched in 15 min (keeps the 10
    // most-recently-accessed regardless). Next open re-loads from SQLite.
    final evicted = _repo.evictInactiveRooms(activeContactId: contactId);
    if (evicted > 0) {
      debugPrint('[ChatController] evicted $evicted inactive chat rooms from memory');
    }
  }

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

  /// Completes once the adapter handshakes triggered by [initialize] finish
  /// (or fail). UI can render against cached state before this resolves;
  /// callers that need the WS/JSON-RPC channels up (broadcastAddressUpdate,
  /// reconnectInbox after probe) await it.
  final Completer<void> _adaptersReady = Completer<void>();
  Future<void> get adaptersReady => _adaptersReady.future;

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
  PulseInboxReader? _adhocPulseReader;
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

  /// Active SFU group calls keyed by groupId. Stays populated for the
  /// lifetime of the call so members who declined the initial popup or
  /// joined the group mid-call can still hop in via the chat-screen
  /// "ongoing call" banner. Cleared when the host explicitly ends the
  /// call (room_left for last participant) or after a 30-min idle
  /// timeout — whichever comes first.
  final Map<String, ActiveGroupCall> _activeGroupCalls = {};
  final StreamController<String> _activeCallsCtrl =
      StreamController<String>.broadcast();
  /// Emits groupId whenever an active group call is added/updated/removed.
  Stream<String> get activeGroupCallsChanged => _activeCallsCtrl.stream;
  ActiveGroupCall? activeGroupCall(String groupId) => _sfu.activeGroupCall(groupId);

  /// Session-scope blocklist of SFU rooms the server has confirmed do not
  /// exist. Other group members can keep rebroadcasting sfu_invite for a
  /// GC'd room (their local rebroadcast timer doesn't know the server
  /// already cleaned up) — without this, every rebroadcast re-pops the
  /// join dialog and every tap hits "room not found" again.
  final Set<String> _deadRoomIds = {};

  /// Dedup keys (`groupId|roomId`) for sfu_invite popups that the UI has
  /// already shown this session. Lives in the controller (not
  /// HomeScreen state) so that navigating away from home + coming back
  /// doesn't reset the set and cause every rebroadcast to re-pop the
  /// same accept/decline dialog. Entries are removed when the call
  /// itself is cleared (see [clearActiveGroupCall] / staleness timer).
  final Set<String> _shownInviteKeys = {};

  // ── Extracted helper classes ───────────────────────────────────────
  late final _ScheduledMessages _scheduled = _ScheduledMessages(this);
  late final _MessageActions _actions = _MessageActions(this);
  late final _P2PReceiver _p2pRx = _P2PReceiver(this);
  late final _PulsePool _pulsePool = _PulsePool(this);
  late final _AdapterHealth _health = _AdapterHealth(this);
  late final _FileResume _fileResume = _FileResume(this);
  late final _KeyRepublisher _keyRepub = _KeyRepublisher(this);
  late final _MessageCrud _crud = _MessageCrud(this);
  late final _GroupManager _groups = _GroupManager(this);
  late final _SfuCalls _sfu = _SfuCalls(this);
  late final _Disappearing _ttl = _Disappearing(this);
  late final _MediaSender _media = _MediaSender(this);
  late final _SendPipeline _pipeline = _SendPipeline(this);
  late final _IncomingHandler _incoming = _IncomingHandler(this);

  bool markInviteShownIfNew(String groupId, String roomId) => _sfu.markInviteShownIfNew(groupId, roomId);
  void forgetInvitesForGroup(String groupId) => _sfu.forgetInvitesForGroup(groupId);

  /// GroupIds where THIS client is currently a live SFU participant
  /// (SfuCallScreen mounted + ICE connected). Probes are only answered
  /// from this set — a stale `_activeGroupCalls` entry from a previous
  /// session would otherwise make the prober join a room that's
  /// already been GC'd by the server.
  final Set<String> _inCallGroupIds = {};
  /// Timestamp of the last `exitSfuCall` per group. The Pulse SFU's
  /// participant cleanup is asynchronous: a fresh `room_create` issued
  /// <2s after `room_leave` lands while the previous PC is still being
  /// torn down server-side, and the new participant ends up unable to
  /// publish audio (server treats the ssrc mapping as already-used).
  /// We use this to throttle rapid hangup→call cycles.
  final Map<String, DateTime> _recentSfuExit = {};
  void enterSfuCall(String groupId) => _sfu.enterSfuCall(groupId);
  void exitSfuCall(String groupId) => _sfu.exitSfuCall(groupId);
  Duration? sinceLastSfuExit(String groupId) => _sfu.sinceLastSfuExit(groupId);

  /// Handle an incoming `sfu_probe` signal. Only respond if we're
  /// *currently* in an SFU call for this group — otherwise a
  /// just-restarted client with a stale `_activeGroupCalls` entry
  /// would echo a dead roomId back to the prober.
  void handleSfuProbe(String groupId) => _sfu.handleSfuProbe(groupId);

  /// Before creating a new SFU room, probe the group — if anyone is
  /// already in a call they'll rebroadcast their invite, letting us
  /// join instead of fragmenting the group into two parallel rooms.
  /// Returns the discovered active call, or null after [probeTimeout].
  ///
  /// Concurrent callers (double-tapping the call button, hot UI rebuild
  /// while waiting) share the SAME in-flight Future — without this we
  /// fired N probes, all timed out independently, and each issued its
  /// own `room_create`, giving the server a fresh room per tap.
  final Map<String, Future<ActiveGroupCall?>> _inflightProbes = {};
  Future<ActiveGroupCall?> discoverGroupCall(Contact group,
      {Duration probeTimeout = const Duration(seconds: 2)}) =>
      _sfu.discoverGroupCall(group, probeTimeout: probeTimeout);

  /// Pulse pubkey → Contact lookup. Populated from the `_pulseAddr` hint
  /// on sfu_invite payloads so SfuCallScreen can resolve participant
  /// pubkeys (as reported by the SFU in `track_available`) to a local
  /// Contact — the `transportAddresses` map on a Contact may only carry
  /// Nostr addresses until that member explicitly shares Pulse.
  final Map<String, String> _pulsePkToNostrSender = {};
  String? nostrSenderForPulsePk(String pulsePk) => _sfu.nostrSenderForPulsePk(pulsePk);
  void learnPulseFromInvite(String nostrSenderId, String pulseAddr) => _sfu.learnPulseFromInvite(nostrSenderId, pulseAddr);
  bool isRoomDead(String roomId) => _sfu.isRoomDead(roomId);
  void markRoomDead(String roomId) => _sfu.markRoomDead(roomId);

  /// Per-group staleness timers. Reset on every sfu_invite we accept —
  /// caller re-broadcasts every 20s while they're in the call, so 45s of
  /// silence means the call effectively ended (everyone left / caller's
  /// network dropped). Without this, the "ongoing call" banner stays
  /// forever after all participants hang up.
  final Map<String, Timer> _callStalenessTimers = {};
  static const _kCallStalenessTimeout = Duration(seconds: 45);

  void _registerActiveGroupCall(
      String groupId, String roomId, String token, String hostId,
      {bool isVideoCall = false}) =>
      _sfu.registerActiveGroupCall(groupId, roomId, token, hostId,
          isVideoCall: isVideoCall);

  void _expireActiveGroupCall(String groupId, String roomId) =>
      _sfu._expireActiveGroupCall(groupId, roomId);

  /// Remove an active call entry — called from SfuCallScreen after the
  /// host taps "end for everyone" or when we get a definitive signal
  /// that the room is gone.
  void clearActiveGroupCall(String groupId) => _sfu.clearActiveGroupCall(groupId);

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

  /// Consume (get and clear) pending call signals for any of [senderBases].
  /// The caller (SignalingService) supplies every known base for a contact
  /// because the sender might have cached signals under a different
  /// transport's pubkey than the one we picked as primary.
  List<Map<String, dynamic>> consumePendingCallSignals(Set<String> senderBases) {
    final out = <Map<String, dynamic>>[];
    for (final base in senderBases) {
      final signals = _pendingCallSignals.remove(base);
      if (signals != null) out.addAll(signals);
    }
    return out;
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
  /// Own display name (from the user profile). Empty string if the
  /// profile has not been loaded yet.
  String get displayName => _selfName;
  List<String> get allAddresses => List.unmodifiable(_allAddresses);

  /// Transport name that was used for the most recent successful delivery to
  /// [contactId], or — if no delivery has happened yet — the transport that
  /// would be tried first on next send. Returns null only if the contact has
  /// no known transports.
  String? activeTransportFor(String contactId) {
    final last = _lastDeliveryTransport[contactId];
    if (last != null) return last;
    final contact = _contacts.findById(contactId);
    if (contact == null) return null;
    final ranked = _rankedTransportsFor(contact);
    return ranked.isNotEmpty ? ranked.first : null;
  }

  /// Build a transport address map from our own addresses for envelope sharing.
  /// Uses shareableAddresses (includes all known Nostr relays, not just primary).
  Map<String, List<String>> _buildOwnTransportMap() {
    final map = <String, List<String>>{};
    for (final addr in shareableAddresses) {
      final transport = Contact.providerFromAddress(addr);
      final list = map[transport] ??= [];
      if (!list.contains(addr)) list.add(addr);
    }
    return map;
  }

  /// Fetch Nostr kind:0 profile avatar for a contact (fire-and-forget).
  /// Queries the relay for NIP-0 metadata, downloads the picture URL,
  /// validates+resizes, and saves to local DB.
  Future<void> _fetchNostrAvatarForContact(String contactId, String pubkey, String relayWs) async {
    try {
      final channel = WebSocketChannel.connect(Uri.parse(relayWs));
      try {
        final subId = 'meta_${DateTime.now().millisecondsSinceEpoch}';
        channel.sink.add(jsonEncode(['REQ', subId, {'kinds': [0], 'authors': [pubkey], 'limit': 1}]));
        String? pictureUrl;
        await for (final raw in channel.stream.timeout(const Duration(seconds: 6))) {
          try {
            final msg = jsonDecode(raw as String) as List<dynamic>;
            if (msg.isEmpty) continue;
            if (msg[0] == 'EVENT' && msg.length >= 3) {
              final event = msg[2] as Map<String, dynamic>;
              if (event['kind'] == 0) {
                final content = jsonDecode(event['content'] as String) as Map<String, dynamic>;
                final pic = (content['picture'] as String?)?.trim();
                if (pic != null && pic.isNotEmpty && pic.length <= 2048) pictureUrl = pic;
              }
            } else if (msg[0] == 'EOSE') { break; }
          } catch (_) { continue; }
        }
        if (pictureUrl != null) {
          final uri = Uri.tryParse(pictureUrl);
          if (uri != null && (uri.isScheme('https') || uri.isScheme('http'))) {
            final client = http.Client();
            try {
              final resp = await client.get(uri).timeout(const Duration(seconds: 5));
              if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty && resp.bodyBytes.length <= 1024 * 1024) {
                final validation = MediaValidator.validateImage(resp.bodyBytes);
                if (validation.isValid) {
                  final decoded = img.decodeImage(resp.bodyBytes);
                  if (decoded != null) {
                    final resized = img.copyResizeCropSquare(decoded, size: 256);
                    final jpeg = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
                    await LocalStorageService().saveAvatar(contactId, base64Encode(jpeg));
                    debugPrint('[Chat] Fetched Nostr avatar for $contactId');
                    _scheduleNotify();
                  }
                }
              }
            } finally { client.close(); }
          }
        }
      } finally { channel.sink.close(); }
    } catch (e) {
      debugPrint('[Chat] Nostr avatar fetch failed for $contactId: $e');
    }
  }

  /// Returns addresses enriched with all currently known working relays.
  /// For Nostr, the pubkey is replicated across identity relay + probed relay +
  /// adaptive relay so invite links always contain fresh, reachable routes.
  /// Non-Nostr addresses (Session, etc.) are included as-is.
  /// Nostr addresses are expanded to cover all known live relays so the
  /// recipient can reach us on whichever relay works for them.
  List<String> get shareableAddresses {
    if (_identity == null) return allAddresses;

    // Find our Nostr pubkey from any existing Nostr address in _allAddresses.
    // CRITICAL: only accept entries whose left-of-@ part is a valid 64-hex
    // secp256k1 pubkey. UUID-shaped IDs (`bbbcc341-…`) sometimes leak into
    // _allAddresses when the Nostr privkey was missing at startup; copying
    // them into the invite link makes every receiver crash on
    // BigInt.parse("bbbcc341-…", radix: 16). One bad entry there has been
    // killing whole conversations — silently dropping non-hex prefixes is
    // strictly safer than blindly fanning them out across N relays.
    String? nostrPub;
    for (final addr in _allAddresses) {
      final wssIdx = addr.indexOf('@wss://');
      final wsIdx = wssIdx == -1 ? addr.indexOf('@ws://') : -1;
      final atIdx = wssIdx != -1 ? wssIdx : wsIdx;
      if (atIdx > 0) {
        final candidate = addr.substring(0, atIdx);
        if (_isValidHexPubkey(candidate)) {
          nostrPub = candidate;
          break;
        }
      }
    }
    // Nostr-primary: extract from selfId
    if (nostrPub == null && _identity!.preferredAdapter == 'nostr') {
      final atIdx = _selfId.indexOf('@');
      if (atIdx > 0) {
        final candidate = _selfId.substring(0, atIdx);
        if (_isValidHexPubkey(candidate)) nostrPub = candidate;
      }
    }

    if (nostrPub == null) {
      // Filter even the pass-through fallback — never include `@wss://`
      // entries with non-hex left side.
      return allAddresses.where((a) {
        final wssIdx = a.indexOf('@wss://');
        final wsIdx = wssIdx == -1 ? a.indexOf('@ws://') : -1;
        final atIdx = wssIdx != -1 ? wssIdx : wsIdx;
        if (atIdx <= 0) return true; // not a Nostr-shaped address, keep
        return _isValidHexPubkey(a.substring(0, atIdx));
      }).toList();
    }

    // Build Nostr addresses for all known live relays.
    final relays = _gatherOwnNostrRelays(limit: 5);
    final result = <String>[];
    for (final relay in relays) {
      result.add('$nostrPub@$relay');
    }
    // Add non-Nostr addresses (Pulse, Session, etc.) — apply the same
    // hex-pubkey check on Pulse-style entries (also "<pubkey>@host") so a
    // poisoned Pulse address can't slip in via this branch either.
    for (final addr in _allAddresses) {
      if (addr.contains('@wss://') || addr.contains('@ws://')) continue;
      final atIdx = addr.indexOf('@');
      if (atIdx > 0) {
        final left = addr.substring(0, atIdx);
        // Pulse pubkey is 64-hex (Ed25519) just like Nostr; Session ID is
        // 66-hex starting with "05" and lives WITHOUT a "@host" suffix so
        // it lands in the no-"@" branch below.
        if (!_isValidHexPubkey(left)) continue;
      }
      result.add(addr);
    }
    return result.isEmpty ? allAddresses : result;
  }

  /// True when [pubkey] looks like a hex-encoded 32-byte secp256k1/ed25519
  /// public key (exactly 64 hex chars). Anything else — UUID, blank, base64,
  /// half-substituted address — must NOT be advertised as a Nostr/Pulse
  /// pubkey because every consumer (NIP-04 ECDH, gift-wrap, HMAC ECDH) calls
  /// `BigInt.parse(it, radix: 16)` and crashes.
  static bool _isValidHexPubkey(String pubkey) {
    if (pubkey.length != 64) return false;
    return RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(pubkey);
  }

  /// Last-resort transport key recovery. Returns the hex-encoded private key
  /// or "" if the recovery key isn't available / KDF failed.
  ///
  /// Re-derives the same Argon2id output the setup screen wrote on first run
  /// and persists it back to secure storage so the next app start finds it
  /// without a second KDF round (~2 s on a phone).
  Future<String> _recoverTransportKey(String secureStorageKey) async {
    try {
      final recovery =
          await _secureStorage.read(key: 'recovery_key') ?? '';
      if (recovery.isEmpty || !RecoveryKeyService.isValid(recovery)) {
        return '';
      }
      final password = RecoveryKeyService.normalize(recovery);
      Uint8List bytes;
      switch (secureStorageKey) {
        case 'nostr_privkey':
          bytes = await KeyDerivationService.deriveNostrKey(password);
        case 'pulse_privkey':
          bytes = await KeyDerivationService.derivePulseKey(password);
        case 'session_seed':
          bytes = await KeyDerivationService.deriveSessionSeed(password);
        default:
          return '';
      }
      final hexEncoded = hex.encode(bytes);
      bytes.fillRange(0, bytes.length, 0);
      await _secureStorage.write(key: secureStorageKey, value: hexEncoded);
      debugPrint('[ChatController] Recovered $secureStorageKey from recovery_key');
      return hexEncoded;
    } catch (e) {
      debugPrint('[ChatController] _recoverTransportKey($secureStorageKey) failed: $e');
      return '';
    }
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
              onDeleted: () { if (!_disposed) _scheduleNotify(); });
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
    try {
      await LocalStorageService().init();
      unawaited(_repo.restoreScheduledTtls(onDeleted: () { if (!_disposed) _scheduleNotify(); }));
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
        // Load display name for message envelope (used in message requests).
        try {
          final profileJson = prefs.getString('user_profile');
          if (profileJson != null) {
            final profile = jsonDecode(profileJson) as Map<String, dynamic>;
            _selfName = (profile['name'] as String?) ?? '';
            _selfAvatar = (profile['avatar'] as String?) ?? '';
          }
        } catch (_) {}
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

        // Kick off adapter handshakes (Nostr/Pulse/Session/LAN) in the
        // background so the UI can render against cached contacts while
        // the WS/HTTP channels come up. Callers that need the network
        // layer ready — broadcastAddressUpdate, reconnectInbox — await
        // [adaptersReady] instead of blocking initialize().
        unawaited(_initializeAdapters());
      } else {
        _connectionStatus = ConnectionStatus.disconnected;
        if (!_adaptersReady.isCompleted) _adaptersReady.complete();
      }
    } catch (_) {
      // Don't leave adaptersReady pending forever on init failure.
      if (!_adaptersReady.isCompleted) _adaptersReady.complete();
      rethrow;
    }
  }

  /// Adapter-init phase — WS/HTTP handshakes, key republish, secondary
  /// reader registration. Runs unawaited off [initialize] so cold start
  /// doesn't block `runApp` on multiple serialised network handshakes.
  Future<void> _initializeAdapters() async {
    _reconnecting = true; // block reconnectInbox() until setup completes
    try {
      await _initInbox();
      // Open per-server Pulse pool entries for every existing pulse-mode
      // group so the user starts receiving group messages on app start
      // without waiting for a manual chat-screen open. Dedup by server URL
      // so multi-group-on-same-server only opens one connection. Fire-and-
      // forget — failures get retried on the next send.
      final seenServers = <String>{};
      for (final c in _contacts.contacts) {
        if (!c.isGroup || !c.isPulseGroup) continue;
        final url = c.groupServerUrl;
        if (url.isEmpty || !seenServers.add(_canonicalizePulseUrl(url))) continue;
        unawaited(ensureGroupPulseConnection(url));
      }
      _startWakeWatchdog();
    } catch (e, st) {
      debugPrint('[ChatController] adapter init failed: $e\n$st');
      _connectionStatus = ConnectionStatus.disconnected;
      notifyListeners();
    } finally {
      _reconnecting = false;
      if (!_adaptersReady.isCompleted) _adaptersReady.complete();
    }
  }

  /// Periodic ticker that compares wall-clock between fires; a gap
  /// significantly larger than the tick interval means the host suspended
  /// (system sleep / hibernation / mobile background freeze). All
  /// per-server Pulse pool WebSockets are dead-but-zombie at that point,
  /// so we tear them down and reopen — the alternative is silent
  /// sends-into-void until the next WS ping cycle (~30-70s) detects the
  /// missing pong and the reader's auto-reconnect kicks in. Fixes the
  /// "I came back to my laptop and messages don't go through" bug.
  void _startWakeWatchdog() {
    _wakeWatchdogTimer?.cancel();
    _lastWakeTick = DateTime.now();
    _wakeWatchdogTimer = Timer.periodic(_wakeTickInterval, (_) {
      if (_disposed) return;
      final now = DateTime.now();
      final gap = now.difference(_lastWakeTick);
      _lastWakeTick = now;
      if (gap < _wakeJumpThreshold) return; // normal tick
      debugPrint('[WakeWatchdog] Detected wall-clock jump of ${gap.inSeconds}s '
          '(> ${_wakeJumpThreshold.inSeconds}s) — host likely woke from sleep. '
          'Force-reconnecting ${_pulseSendersByServer.length} Pulse pool entries.');
      // Snapshot keys before iterating: resetGroupPulseConnection mutates
      // _pulseReadersByServer / _pulseSendersByServer.
      final urls = _pulseReadersByServer.keys.toList();
      for (final canonUrl in urls) {
        // The map is keyed by canonicalised URL; we need the real URL
        // back. Loop over groups to find a matching one — there should
        // always be one since the pool entry was opened for it.
        String? realUrl;
        for (final c in _contacts.contacts) {
          if (!c.isPulseGroup) continue;
          if (_canonicalizePulseUrl(c.groupServerUrl) == canonUrl) {
            realUrl = c.groupServerUrl;
            break;
          }
        }
        if (realUrl != null && realUrl.isNotEmpty) {
          unawaited(resetGroupPulseConnection(realUrl));
        }
      }
    });
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
      // CRITICAL: do NOT close _adhocPulseReader and do NOT clear
      // _pulseReadersByServer here. reconnectInbox is fired by the
      // probe-found-better-Nostr-relay path in main.dart. That probe
      // change has nothing to do with Pulse — but tearing down the
      // Pulse stack racecreates a SECOND PulseInboxReader against
      // the still-authenticating original on the server's "1 conn
      // per pubkey" slot → server kicks them in turn → SFU's
      // TURN-over-WS dies → ICE → call drops in ~1 minute.
      //
      // Subscriptions on _adhocPulseReader's stream were just
      // cancelled (via `_messageSubs.clear()` and `_signalSubs.clear()`
      // above). _initInbox below will re-subscribe on the SAME
      // existing reader (without recreating it) so messaging flow
      // resumes without a fresh WS auth.
      debugPrint('[Chat] reconnectInbox: KEEPING _adhocPulseReader '
          '${_adhocPulseReader == null ? "(null)" : identityHashCode(_adhocPulseReader)} '
          'and pool (${_pulseReadersByServer.length} entries) — '
          'avoiding multi-WS race with reconnect');
      await _initInbox();
      // Reopen pool entries for every existing pulse-mode group so signals
      // resume flowing without waiting for a manual chat-screen open.
      // Mirrors the loop in `_initializeAdapters`.
      final seenServers = <String>{};
      for (final c in _contacts.contacts) {
        if (!c.isGroup || !c.isPulseGroup) continue;
        final url = c.groupServerUrl;
        if (url.isEmpty || !seenServers.add(_canonicalizePulseUrl(url))) continue;
        unawaited(ensureGroupPulseConnection(url));
      }
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
        var privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        // Recover from recovery_key when the secure-storage privkey has been
        // wiped or never landed (Windows Keystore migration loss, fresh
        // install with imported identity, etc). Without this guard we fall
        // through to using _identity.id (a UUID) as the "pubkey", which
        // poisons every outgoing Nostr address: invite links carry
        // <UUID>@wss://… which BigInt.parse can't read → every sendSignal
        // dies with FormatException and the contact effectively goes dark.
        if (privkey.isEmpty) {
          privkey = await _recoverTransportKey('nostr_privkey');
        }
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
          // Last-resort fallback: identity has no usable Nostr key and
          // recovery failed too. Refuse to fabricate a UUID-shaped "pubkey"
          // — it's worse than no Nostr at all because it leaks broken
          // addresses into invite links. Bail and let the user re-import
          // the recovery key from Settings → Security.
          debugPrint('[ChatController] Nostr-primary identity but no privkey '
              'and recovery_key derivation failed. Refusing to fabricate a '
              'UUID-pubkey — Nostr disabled until recovery key is restored.');
          _connectionStatus = ConnectionStatus.disconnected;
          _scheduleNotify();
          return;
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
          var privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          if (privkey.isEmpty) {
            privkey = await _recoverTransportKey('pulse_privkey');
          }
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
            // Same rationale as Nostr: never fabricate a UUID-pubkey.
            debugPrint('[ChatController] Pulse-primary identity but no privkey '
                'and recovery_key derivation failed. Refusing to use UUID — '
                'Pulse disabled until recovery key is restored.');
            _connectionStatus = ConnectionStatus.disconnected;
            _scheduleNotify();
            return;
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
      final primaryTransport = _providerFromAddress(myAddress);
      _messageSubs.add(r.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(r.listenForSignals().listen(
          (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: primaryTransport)));
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

      // For Nostr-primary users: also REGISTER additional DM-capable probed
      // relays as our own advertised addresses (up to 4), not just reader
      // subscriptions. Without this, _allAddresses had exactly one Nostr
      // entry and contacts saw only a single relay per contact.
      final atIdxOwn = myAddress.indexOf('@');
      if (atIdxOwn > 0) {
        final ownPub = myAddress.substring(0, atIdxOwn);
        final ownPrimaryRelay = myAddress.substring(atIdxOwn + 1);
        final probeRelays = ConnectivityProbeService.instance.lastResult.nostrRelays;
        final advertised = <String>[];
        for (final r in probeRelays) {
          if (advertised.length >= 4) break;
          final relay = r.startsWith('ws') ? r : 'wss://$r';
          if (relay == ownPrimaryRelay) continue;
          mainReader.addSecondaryRelay(relay);
          final addr = '$ownPub@$relay';
          if (!newAddresses.contains(addr)) {
            newAddresses.add(addr);
            _adapterHealth[addr] = true;
            advertised.add(relay);
          }
        }
        if (advertised.isNotEmpty) {
          Future.delayed(const Duration(seconds: 8), () {
            _pruneDisconnectedSecondaries(ownPub, mainReader, advertised);
          });
          debugPrint('[Chat] Nostr-primary: registered '
              '${advertised.length} secondary relay address(es)');
        }
      }
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
      final secondaryTransport = cfg['provider']!;
      _messageSubs.add(reader.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(reader.listenForSignals().listen(
          (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: secondaryTransport)));
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
        // REUSE existing _adhocPulseReader if one is alive — re-subscribe
        // streams (subs were cleared above by reconnectInbox) without
        // creating a SECOND PulseInboxReader. Two readers for the same
        // pubkey would race for the server's "1 connection per pubkey"
        // slot → multi-WS storm → SFU TURN-over-WS dies → calls drop.
        if (_adhocPulseReader != null) {
          debugPrint('[Chat] _initInbox: reusing existing _adhocPulseReader '
              '${identityHashCode(_adhocPulseReader)} (re-subscribing streams)');
          final pulseReader = _adhocPulseReader!;
          _messageSubs.add(pulseReader.listenForMessages().listen(_handleIncomingMessages));
          _signalSubs.add(pulseReader.listenForSignals().listen(
              (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: 'Pulse')));
          final seed = Uint8List.fromList(hex.decode(pulseKey));
          final pulsePub = await ed25519PubkeyFromSeed(seed);
          final pulseAddr = '$pulsePub@$pulseUrl';
          newAddresses.add(pulseAddr);
          _adapterHealth[pulseAddr] = true;
          _healthSubs.add(pulseReader.healthChanges.listen((h) => _onAdapterHealthChange(pulseAddr, h)));
        } else {
        try {
          final pulseApiKey = jsonEncode({'privkey': pulseKey, 'serverUrl': pulseUrl});
          final pulseReader = await InboxManager().createAdhocReader('Pulse', pulseApiKey, pulseUrl);
          if (pulseReader != null) {
            _adhocPulseReader = pulseReader as PulseInboxReader;
            debugPrint('[Chat] _initInbox: CREATED new _adhocPulseReader '
                '${identityHashCode(pulseReader)} (none existed)');
            _messageSubs.add(pulseReader.listenForMessages().listen(_handleIncomingMessages));
            _signalSubs.add(pulseReader.listenForSignals().listen(
                (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: 'Pulse')));
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
        } // close else (existing reader reuse)
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
            _signalSubs.add(sessionReader.listenForSignals().listen(
                (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: 'Session')));
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
          // Primary Nostr relay: user-configured first, probe result second,
          // hardcoded default only as last resort. This keeps new accounts
          // from concentrating on the same bootstrap relay.
          final prefsForNostr = await _getPrefs();
          final primaryRelay = prefsForNostr.getString('nostr_relay')
              ?? prefsForNostr.getString('probe_nostr_relay')
              ?? _kDefaultNostrRelay;
          final apiKey = jsonEncode({'privkey': nostrPriv, 'relay': primaryRelay});
          final nostrReader = await InboxManager().createAdhocReader('Nostr', apiKey, primaryRelay);
          if (nostrReader != null) {
            _messageSubs.add(nostrReader.listenForMessages().listen(_handleIncomingMessages));
            _signalSubs.add(nostrReader.listenForSignals().listen(
                (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: 'Nostr')));
            // Subscribe to additional probed relays as secondary (up to 4 more)
            // so we have redundancy even if two relays fail simultaneously
            // and contacts see multiple usable addresses in our profile.
            final secondaryRelays = <String>[];
            if (nostrReader is NostrInboxReader) {
              final probeRelays = ConnectivityProbeService.instance.lastResult.nostrRelays;
              for (final r in probeRelays) {
                if (secondaryRelays.length >= 4) break;
                final relay = r.startsWith('ws') ? r : 'wss://$r';
                if (relay == primaryRelay) continue;
                nostrReader.addSecondaryRelay(relay);
                secondaryRelays.add(relay);
              }
            }
            // Register primary AND secondary addresses immediately so contacts
            // learn multiple fallback relays from the first addr_update. After
            // a short delay we prune any secondary that didn't actually connect.
            final primaryAddr = '$nostrPub@$primaryRelay';
            newAddresses.add(primaryAddr);
            _adapterHealth[primaryAddr] = true;
            _healthSubs.add(nostrReader.healthChanges.listen((h) =>
                _onAdapterHealthChange(primaryAddr, h)));
            for (final relay in secondaryRelays) {
              final addr = '$nostrPub@$relay';
              newAddresses.add(addr);
              _adapterHealth[addr] = true;
            }
            unawaited(_keys.publishKeysToAdapter('Nostr', apiKey, primaryAddr));
            if (secondaryRelays.isNotEmpty) {
              Future.delayed(const Duration(seconds: 8), () {
                _pruneDisconnectedSecondaries(nostrPub, nostrReader, secondaryRelays);
              });
            }
            debugPrint('[Chat] Auto-registered Nostr inbox: $primaryRelay + ${secondaryRelays.length} secondary');
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
      _signalSubs.add(_lanReader!.listenForSignals().listen(
          (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: 'LAN')));
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
    for (final transport in _rankedTransportsFor(contact)) {
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
    try {
      return await reader.fetchPublicKeys();
    } finally {
      // Close the adhoc reader once the key fetch is done.
      // Without this, the reader stays subscribed to our `#p` filter and
      // intercepts incoming gift wraps on its orphan _msgCtrl (no listener)
      // — they get marked as "seen" via inner-id dedup before the main
      // reader can dispatch them, silently dropping every message that
      // arrives during an active key fetch.
      try {
        if (reader is NostrInboxReader) reader.close();
        else if (reader is PulseInboxReader) reader.close();
        else if (reader is SessionInboxReader) reader.close();
      } catch (_) {}
    }
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

  /// Push our current Signal + Kyber bundle directly to [contact] as a
  /// `sys_keys` signal. The receiver's SignalDispatcher handles `sys_keys`
  /// by calling `buildSession` — which replaces any existing session
  /// state with one keyed to our freshly-published prekeys. Recovers from
  /// the "sender has a stale prekey bundle" failure mode.
  /// Push our current Signal+Kyber bundle directly to [contact] as a
  /// `session_reset` signal carrying the bundle in its payload.
  ///
  /// **Why inline bundle instead of relying on relay republish:**
  /// the receiver's SignalDispatcher pre-builds a fresh session from
  /// the embedded bundle BEFORE the next encrypt. Eliminates the race
  /// where the receiver re-fetched our published bundle from a relay
  /// that hadn't yet propagated our most recent kind:10009 update —
  /// empirically that race burned ~50% of stale-prekey recoveries
  /// (peer rebuilt session against the same stale prekey and failed
  /// again, looping forever).
  ///
  /// Recovery sequence after we hit a stale-prekey / Bad-Mac decrypt:
  ///   1. AWAIT `_republishAllKeys()` so the published bundle is on
  ///      record before the peer might refetch via legacy path.
  ///   2. Snapshot the bundle right after publish.
  ///   3. Send `session_reset` carrying the bundle directly. Peer
  ///      builds session from the inline payload, no relay round-trip.
  ///
  /// `pqcWrap: false` because the inline bundle includes the Kyber
  /// public key — wrapping the unwrap-key in PQC would be circular.
  Future<void> _pushOwnBundleTo(Contact contact) async {
    try {
      // CRITICAL: AWAIT the republish, otherwise the session_reset
      // signal beats our own publish to the peer's relay and they
      // refetch a stale bundle.
      await _republishAllKeys();
      Map<String, dynamic>? bundle;
      try {
        bundle = await _keys.buildOwnBundle();
      } catch (e) {
        debugPrint('[ChatController] _pushOwnBundleTo: buildOwnBundle failed: $e');
      }
      final payload = <String, dynamic>{
        'ts': DateTime.now().toUtc().toIso8601String(),
        if (bundle != null) 'bundle': bundle,
      };
      await _broadcaster.sendSignalToAllTransports(
          contact, 'session_reset', payload, pqcWrap: false);
      debugPrint('[ChatController] Pushed session_reset to ${contact.name} '
          'with inline bundle=${bundle != null} after stale-prekey failure');
    } catch (e) {
      debugPrint('[ChatController] Failed to push session_reset to ${contact.name}: $e');
    }
  }

  // ── Signal dispatcher ─────────────────────────────────────────────────────

  /// Returns true if [addr] refers to us — either matches _selfId exactly,
  /// appears in _allAddresses, or shares its bare pubkey with any of the
  /// above. Used to suppress self-echo signal events that return via
  /// relay but come back under a different address format (bare pubkey
  /// vs full `pubkey@relay`, alternate transport, etc.).
  bool _isOwnAddress(String addr) {
    if (addr.isEmpty) return false;
    if (addr == _selfId) return true;
    if (_allAddresses.contains(addr)) return true;
    final atIdx = addr.indexOf('@');
    final barePeer = atIdx > 0 ? addr.substring(0, atIdx) : addr;
    if (barePeer.isEmpty) return false;
    final selfAt = _selfId.indexOf('@');
    final bareSelf = selfAt > 0 ? _selfId.substring(0, selfAt) : _selfId;
    if (barePeer == bareSelf) return true;
    for (final a in _allAddresses) {
      final ai = a.indexOf('@');
      final bare = ai > 0 ? a.substring(0, ai) : a;
      if (bare == barePeer) return true;
    }
    return false;
  }

  /// Marks the contact index as stale so [_getContactIndex] rebuilds it.
  void _invalidateContactIndex() {
    _contactIndexDirty = true;
    _contactIndex = null;
  }

  /// Returns true if [sender] is a member of [group] cross-device. A
  /// plain `group.members.contains(sender.id)` only works on the device
  /// that added [sender] as a contact — peers' local UUIDs never match.
  /// Fall back to checking the sender's Nostr pubkey against the
  /// `memberPubkeys` map propagated in group_invite / group_update.
  bool _isSenderInGroup(Contact group, Contact sender) {
    if (group.members.contains(sender.id)) return true;
    if (group.memberPubkeys.isNotEmpty) {
      // Build a single normalized set of all pubkeys/IDs the sender is known
      // by — local DB id, databaseId (full and id-part), and the pubkey part
      // of every transport address (not just Nostr). Membership is then a
      // single set lookup against memberPubkeys.values (also normalized).
      // Previous version only checked Nostr-transport addresses, so a member
      // who joined via Pulse/Session never matched and group messages from
      // them were misclassified as 1-on-1 — that's the "пишу в группу,
      // приходит как ЛС" bug.
      final senderIds = <String>{
        sender.id.toLowerCase(),
        sender.databaseId.toLowerCase(),
        sender.databaseId.split('@').first.toLowerCase(),
      };
      for (final addrs in sender.transportAddresses.values) {
        for (final addr in addrs) {
          final atIdx = addr.indexOf('@');
          final id = (atIdx > 0 ? addr.substring(0, atIdx) : addr).toLowerCase();
          if (id.isNotEmpty) senderIds.add(id);
        }
      }
      for (final addr in sender.alternateAddresses) {
        final atIdx = addr.indexOf('@');
        final id = (atIdx > 0 ? addr.substring(0, atIdx) : addr).toLowerCase();
        if (id.isNotEmpty) senderIds.add(id);
      }
      senderIds.remove('');
      for (final mp in group.memberPubkeys.values) {
        if (senderIds.contains(mp.toLowerCase())) return true;
      }
    }
    debugPrint('[Group] _isSenderInGroup MISS: group=${group.id.substring(0, 8)} '
        'sender=${sender.name} sender.id=${sender.id} '
        'sender.dbId=${sender.databaseId} '
        'sender.altAddrs=${sender.alternateAddresses} '
        'group.members=${group.members} '
        'group.memberPubkeys=${group.memberPubkeys}');
    return false;
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
      // Conference mode: track the call so members who dismiss the
      // popup (or arrive after the invite landed) can still join via
      // the chat-screen "ongoing call" banner.
      final sigType = e.signal['type'] as String? ?? '';
      if (sigType == 'sfu_invite') {
        final p = e.signal['payload'];
        if (p is Map) {
          final roomId = p['sfuRoomId'] as String? ?? p['room_id'] as String? ?? '';
          final token = p['sfuToken'] as String? ?? p['token'] as String? ?? '';
          final isVideo = p['isVideoCall'] as bool? ?? false;
          final hostId = e.signal['senderId'] as String? ?? '';
          if (roomId.isNotEmpty && token.isNotEmpty) {
            _registerActiveGroupCall(e.groupId, roomId, token, hostId,
                isVideoCall: isVideo);
          }
        }
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
      // For group TTL signals, e.contact is the member who initiated the
      // change; the TTL must be applied to the group chat itself, with that
      // member recorded as the actor in the system notice.
      Contact? target = e.contact;
      if (e.groupId != null) {
        try {
          target = _contacts.contacts.firstWhere((c) => c.id == e.groupId);
        } catch (_) {
          target = null;
        }
      }
      if (target == null) return;
      unawaited(setChatTtlSeconds(target, e.seconds,
          sendSignal: false, changedBy: e.contact.id));
    }));

    // Reactions — delegate to repo.
    // Skip self-echoes from relays: the transport-layer senderId may be a
    // bare pubkey or a different relay URL than our _selfId, so the naive
    // `${emoji}_${from}` composite key wouldn't match the local one we
    // just wrote in [toggleReaction], and the user would see the reaction
    // twice under two different author identifiers.
    _dispatcherSubs.add(d.reactions.listen((e) {
      if (_isOwnAddress(e.from)) {
        debugPrint('[Chat] Reaction self-echo ignored: ${e.from}');
        return;
      }
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
          // Match by Contact record, not raw pubkey: the original message may
          // have been sent via a different transport than the edit (e.g.
          // msg.senderId is a Nostr secp256k1 pubkey, e.contact.databaseId
          // is a Pulse Ed25519 pubkey) — both belong to the same Contact.
          final msg = room.messages[idx];
          final msgBare = msg.senderId.contains('@')
              ? msg.senderId.split('@').first
              : msg.senderId;
          final contactIndex = _getContactIndex();
          final msgOwner = contactIndex[msg.senderId]
              ?? contactIndex[msgBare]
              ?? _contacts.findByAddress(msg.senderId)
              ?? _contacts.findByAddress(msgBare);
          if (msgOwner?.id != e.contact.id) {
            debugPrint('[Edit] Rejected: ${e.contact.name} (${e.contact.id}) '
                'tried to edit message owned by ${msgOwner?.name ?? msg.senderId}');
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
      if (keyChanged) {
        // Peer's identity rotated (e.g. reinstall after wipe). Sync the new
        // pubkey into every group's `memberPubkeys` map so subsequent
        // group_delete tombstones, group_update broadcasts, and pairwise
        // sender_key distributions go to the NEW identity instead of the
        // dead old one. Without this, "delete group" silently never
        // reaches a re-installed peer because _resolveGroupRecipients
        // looks up by old pubkey.
        await _refreshGroupMembershipForContact(e.contact);
      }
      if (e.contact.provider == 'Session') {
        unawaited(_keys.publishSessionKeysTo(e.contact, _selfId));
      }
    }));

    // PQC unwrap failure: dispatcher tried to unwrap a PQC2-wrapped signal
    // payload but our Kyber privkey couldn't decrypt it. The peer cached
    // our OLD Kyber pubkey (likely they reinstalled or we did) and keeps
    // wrapping replies for the dead key — every subsequent signal silently
    // gets dropped. Clear `_pqcConfirmed` so we stop telling broadcaster
    // to PQC-wrap THEIR replies, drop their cached Kyber so we don't try
    // to wrap, and trigger session_reset so the peer pulls our fresh
    // bundle (which carries our current Kyber pubkey).
    _dispatcherSubs.add(d.pqcUnwrapFailed.listen((senderId) async {
      if (senderId.isEmpty) return;
      _pqcConfirmed.remove(senderId);
      _pqcConfirmed.remove(senderId.split('@').first);
      _keys.clearContactKyberPk(senderId);
      // Find the local contact for this sender and push our fresh bundle.
      final idx = _getContactIndex();
      final c = idx[senderId] ?? idx[senderId.split('@').first];
      if (c != null) {
        debugPrint('[ChatController] PQC unwrap failed from ${c.name} — '
            'cleared cached Kyber + triggering session_reset with fresh bundle');
        unawaited(_pushOwnBundleTo(c));
      } else {
        debugPrint('[ChatController] PQC unwrap failed from unknown $senderId — '
            'cleared cached Kyber, no contact to push to');
      }
    }));

    // Peer-initiated session reset: they failed to decrypt our messages
    // because the prekey we used has been rotated out on their side.
    //
    // Modern peers include their freshly-republished Signal bundle inline
    // in the signal payload. When present, do delete + buildSession
    // atomically so we never race against the peer's own-inbox publish —
    // that race made about half of recoveries pull a stale bundle from a
    // relay that hadn't yet propagated the peer's update.
    //
    // Without inline bundle (legacy peer): just delete; our next encrypt
    // path will fetch their bundle from a relay (slightly racy, but the
    // peer is now expecting the rebuild so timing is more forgiving).
    _dispatcherSubs.add(d.sessionResets.listen((e) async {
      // Drop duplicates from the same peer within the cooldown window.
      // `sendSignalToAllTransports` fans out one logical session_reset
      // across every transport, so we see the same payload 5-7 times.
      // Processing each one rebuilds the session, generating a fresh
      // ratchet key, which leaves our just-sent PreKey-init pointing at
      // the previous (now-discarded) ratchet — peer can't decrypt and
      // fires another session_reset, looping forever.
      final lastSeen = _lastSessionResetReceived[e.contact.id];
      if (lastSeen != null &&
          DateTime.now().difference(lastSeen) < _kSessionResetReceiveCooldown) {
        debugPrint('[ChatController] Peer ${e.contact.name} session_reset within '
            'cooldown (${_kSessionResetReceiveCooldown.inSeconds}s) — ignoring duplicate');
        return;
      }
      _lastSessionResetReceived[e.contact.id] = DateTime.now();

      debugPrint('[ChatController] Peer ${e.contact.name} asked for session reset '
          '— clearing session (inlineBundle=${e.bundle != null})');
      await _signalService.deleteContactData(e.contact.databaseId);
      final bundle = e.bundle;
      if (bundle != null) {
        try {
          final keyChanged =
              await _signalService.buildSession(e.contact.databaseId, bundle);
          _keys.cacheContactKyberPk(e.contact.databaseId, bundle);
          if (keyChanged && !_keyChangeCtrl.isClosed) {
            _keyChangeCtrl
                .add((contactName: e.contact.name, contactId: e.contact.databaseId));
          }
          debugPrint('[ChatController] Built fresh session for ${e.contact.name} '
              'from inline bundle (keyChanged=$keyChanged)');
        } catch (err) {
          debugPrint('[ChatController] buildSession from inline bundle failed: $err');
        }
      }
      // Also suppress our own outgoing session_reset for this peer for the
      // same window — if we just rebuilt against their bundle, our next
      // user-msg PreKey-init carries the answer; firing OUR session_reset
      // back races with that and replaces their fresh session before they
      // can decrypt our PreKey.
      _lastStaleKeyPush[e.contact.id] = DateTime.now();
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
      // Signals arriving via LAN or our own Pulse-relay are trusted channels —
      // a peer announcing a 192.168.x address over those is legitimate (shared
      // LAN / self-hosted relay). Public channels (Nostr, Firebase, Session)
      // leak metadata, so still reject private IPs there.
      final trustedSource =
          e.sourceTransport == 'LAN' || e.sourceTransport == 'Pulse';
      // F3/F4-4: Validate relay addresses — only wss:// and no private IPs
      // when arrived over a public transport.
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
          if (h.isEmpty || h == '0.0.0.0') return false;
          if (trustedSource) return true;
          if (h == 'localhost' || h == '127.0.0.1' || h == '::1') return false;
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
        // UNION-MERGE every transport's address list with what we already
        // have (was Nostr-only — broke pulse-mode groups because the sender
        // briefly sent an addr_update WITHOUT Pulse during startup, which
        // wiped the Pulse address we'd just learned, and the next message
        // failed with "No Pulse pubkey for X"). New addresses go first
        // (fresh primary takes precedence), existing ones backfill, capped
        // at 10 per transport to bound growth. A user genuinely SWITCHING
        // their Pulse/Session server can still happen — the new entries
        // will appear first in the priority order, and stale entries get
        // pruned by health-check / never-acked routing later. This trades
        // a sliver of "switch is instant" UX for "we never lose a learned
        // address mid-flight" reliability.
        for (final transport in {'Nostr', 'Pulse', 'Session', 'Firebase'}) {
          final existing = addrContact.transportAddresses[transport]
              ?? const <String>[];
          final incoming = ta[transport] ?? const <String>[];
          if (incoming.isEmpty && existing.isEmpty) continue;
          final merged = <String>[];
          final seen = <String>{};
          for (final a in incoming) {
            if (seen.add(a)) merged.add(a);
          }
          for (final a in existing) {
            if (merged.length >= 10) break;
            if (seen.add(a)) merged.add(a);
          }
          if (merged.isNotEmpty) ta[transport] = merged;
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
        // Same UNION-MERGE for every transport as in the new-format branch.
        for (final transport in {'Nostr', 'Pulse', 'Session', 'Firebase'}) {
          final existing = addrContact.transportAddresses[transport]
              ?? const <String>[];
          final incoming = ta[transport] ?? const <String>[];
          if (incoming.isEmpty && existing.isEmpty) continue;
          final merged = <String>[];
          final seen = <String>{};
          for (final a in incoming) {
            if (seen.add(a)) merged.add(a);
          }
          for (final a in existing) {
            if (merged.length >= 10) break;
            if (seen.add(a)) merged.add(a);
          }
          if (merged.isNotEmpty) ta[transport] = merged;
        }
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
      debugPrint('[ChatController] relay group_invite from dispatcher: '
          'group="${e.groupName}" id=${e.groupId} from=${e.fromContact.name} '
          'publicCtrlClosed=${_groupInviteCtrl.isClosed} '
          'publicCtrlHasListener=${_groupInviteCtrl.hasListener}');
      if (!_groupInviteCtrl.isClosed) _groupInviteCtrl.add(e);
    }));

    _dispatcherSubs.add(d.groupInviteDeclines.listen((e) {
      if (!_groupInviteDeclineCtrl.isClosed) _groupInviteDeclineCtrl.add(e);
    }));

    _dispatcherSubs.add(d.msgDeletes.listen((e) {
      _handleRemoteDelete(e.fromId, e.msgId, groupId: e.groupId);
    }));

    _dispatcherSubs.add(d.groupUpdates.listen((e) async {
      // Drop loop-back broadcasts: every transport (Pulse server especially)
      // can echo our own kind:1059 / signed envelope back to us. Without
      // this filter the sender would re-apply their own change and emit a
      // duplicate "<self> renamed group" system notice.
      if (_isOwnAddress(e.senderId)) return;
      final g = _contacts.findById(e.groupId);
      if (g == null || !g.isGroup) return;
      final group = g;
      // NOTE: the old "senderUuid == group.creatorId" guard compared a
      // locally-generated contact UUID against the creator's own-identity
      // UUID on their device — cross-device UUIDs never match, so every
      // legitimate roster update was rejected. Signal-layer auth (Schnorr
      // on Nostr, HMAC on other transports) already proves the payload
      // was sent by the holder of e.senderId's private key; trusting it
      // is sufficient for the force-accept baseline. Pubkey-based
      // identity checks will replace this in a later step.
      debugPrint('[Group] group_update from ${e.senderId} for ${group.name}: '
          '${e.members.length} members');

      // Tombstone / self-kick: if we are no longer in the roster (or
      // the roster is empty, which is how the creator signals "group
      // deleted"), drop the group locally. Emits on _groupUpdatePublicCtrl
      // so any open chat screen + the home list both refresh.
      final myUuid = _identity?.id ?? '';
      final weWereMember = myUuid.isNotEmpty && group.members.contains(myUuid);
      final weStillMember = myUuid.isNotEmpty && e.members.contains(myUuid);
      if (e.members.isEmpty || (weWereMember && !weStillMember)) {
        await _contacts.removeContact(group.id);
        _invalidateContactIndex();
        debugPrint('[Group] ${group.name} '
            '${e.members.isEmpty ? "deleted by creator" : "kicked us"} '
            '— removed locally');
        if (!_groupUpdatePublicCtrl.isClosed) _groupUpdatePublicCtrl.add(e);
        _scheduleNotify();
        return;
      }

      final memberRemoved = group.members.toSet().difference(e.members.toSet()).isNotEmpty;
      // Merge incoming memberPubkeys with what we already know: the
      // creator may re-issue an update with the same mapping, or extend
      // it for newly-added members. Keep any entry we already have for
      // members still present; replace/add entries from the payload.
      final mergedPubkeys =
          Map<String, String>.from(group.memberPubkeys)
            ..addAll(e.memberPubkeys)
            ..removeWhere((k, _) => !e.members.contains(k));
      // Detect what actually changed so we can emit a Telegram-style
      // in-chat notice. Empty groupName / empty avatar in the signal mean
      // "no change" — only the fields that the sender actually populated
      // are treated as updates.
      final newName = e.groupName.isNotEmpty ? e.groupName : group.name;
      final nameChanged =
          e.groupName.isNotEmpty && e.groupName != group.name;
      final avatarChanged = e.avatar.isNotEmpty;
      // Inherit creator's transport mode + Pulse server, but only when the
      // payload populated them — empty string in the signal means "no
      // change", we keep whatever we already have. Lets the creator switch
      // a group between mesh/pulse after the fact (rare but supported).
      final newTransportMode = e.groupTransportMode.isNotEmpty
          ? e.groupTransportMode : group.groupTransportMode;
      final newServerUrl = e.groupServerUrl.isNotEmpty
          ? e.groupServerUrl : group.groupServerUrl;
      final newServerInvite = e.groupServerInvite.isNotEmpty
          ? e.groupServerInvite : group.groupServerInvite;
      final updated = group.copyWith(
        name: newName,
        members: e.members,
        creatorId: group.creatorId ?? e.creatorId,
        memberPubkeys: mergedPubkeys,
        groupTransportMode: newTransportMode,
        groupServerUrl: newServerUrl,
        groupServerInvite: newServerInvite,
      );
      await _contacts.updateContact(updated);
      if (avatarChanged) {
        try {
          await LocalStorageService().saveAvatar(group.id, e.avatar);
        } catch (err) {
          debugPrint('[Group] failed to save avatar: $err');
        }
      }
      _invalidateContactIndex();
      await _ensurePendingContactsForMembers(
          mergedPubkeys, e.memberAddresses, memberNames: e.memberNames);
      // Same Pulse-pubkey bootstrap as in acceptGroupInvite — group_update
      // is the primary delivery path for "members got added" after the
      // initial invite, so newcomers' pubkeys arrive here.
      if (updated.isPulseGroup &&
          updated.groupServerUrl.isNotEmpty &&
          e.memberPulsePubkeys.isNotEmpty) {
        await _seedMemberPulseAddresses(
            e.memberPulsePubkeys, mergedPubkeys, updated.groupServerUrl);
      }
      // Promote any "Member <pubkey>" placeholders to the inviter-provided
      // name. Only renames placeholders — never overwrites a name the user
      // chose locally.
      if (e.memberNames.isNotEmpty) {
        await _promotePlaceholderNames(e.memberNames, mergedPubkeys);
      }
      debugPrint('[Group] Membership updated for ${updated.name}: ${e.members.length} members');
      if (memberRemoved && _selfId.isNotEmpty) {
        unawaited(rotateGroupSenderKey(updated));
      }
      if (nameChanged || avatarChanged) {
        await _insertSystemMessage(updated, {
          '_sys': avatarChanged && nameChanged
              ? 'group_meta_changed'
              : (avatarChanged ? 'group_avatar_changed' : 'group_renamed'),
          if (nameChanged) 'old': group.name,
          if (nameChanged) 'new': newName,
          'by': e.senderId,
        });
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
            !_isSenderInGroup(skdmGroup, e.fromContact)) {
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
    if (!_isSenderInGroup(groupContact, reader)) return;
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

  Future<void> _handleIncomingMessages(List<Message> newMessages) =>
      _incoming.handleIncomingMessages(newMessages);

  // ── Message sending ───────────────────────────────────────────────────────

  Future<void> sendMessage(Contact rawContact, String text, {bool noAutoRetry = false, Message? replyTo}) => _pipeline.sendMessage(rawContact, text, noAutoRetry: noAutoRetry, replyTo: replyTo);


  // ── Smart Router helpers ──────────────────────────────────────────────────

  static final _sessionAddrRegex = RegExp(r'^[0-9a-f]{66}$');
  static final _nostrPubRegex = RegExp(r'^[0-9a-f]{64}$');
  static final _pulseAddrRegex = RegExp(r'^[0-9a-f]{64}@https://', caseSensitive: false);

  /// Static quality ranking for auto-selecting transport when sending to a
  /// contact. Higher score wins. LAN is handled separately as a last-resort
  /// broadcast, so it is not scored here.
  static const Map<String, int> _transportRank = {
    'Pulse': 40,
    'Nostr': 30,
    'Session': 20,
    'Firebase': 10,
  };

  /// Transports to try when sending to [contact], ordered by quality of the
  /// intersection of self's available transports and the contact's known
  /// transports. Falls back to [Contact.transportPriority] ordering for any
  /// transports the contact has but we don't list in [_transportRank].
  List<String> _rankedTransportsFor(Contact contact) {
    final selfTransports = _buildTransportMap(_allAddresses).keys.toSet();
    final contactTransports = contact.transportAddresses.keys.toSet();
    final common = selfTransports.intersection(contactTransports).toList()
      ..sort((a, b) =>
          (_transportRank[b] ?? 0).compareTo(_transportRank[a] ?? 0));
    final seen = common.toSet();
    final tail = contact.transportPriority.where((t) => !seen.contains(t));
    return [...common, ...tail];
  }

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

  /// After a delay, reconcile secondary-relay handshake state. Previously this
  /// REMOVED addresses whose WS didn't finish handshaking within 8s, which
  /// caused a cascading bug: a flaky startup would shrink _allAddresses from
  /// 5 relays to 1, broadcastAddressUpdate would ship the smaller set, and
  /// the receiver's addr_update handler would replace its 5-relay view of us
  /// with the 1-relay view. Full redundancy never recovered unless a later
  /// probe+prune cycle happened to succeed.
  ///
  /// Probe-reachable relays are kept in _allAddresses even if our OWN WS
  /// didn't connect in 8s: (a) the relay is still usable for contacts to
  /// reach us (probe validated DM capability), (b) we can re-subscribe
  /// later when the WS does open, (c) advertising an extra reachable relay
  /// is cheap — worst case the receiver tries it once and falls through.
  ///
  /// We still re-broadcast here so any late-arriving secondary addresses
  /// added between T=0 and T+8s get propagated, and we log which relays
  /// failed to handshake so flaky relays are visible in diagnostics.
  void _pruneDisconnectedSecondaries(
      String nostrPub, InboxReader reader, List<String> candidates) {
    if (reader is! NostrInboxReader) return;
    final connected = reader.connectedSecondaryRelays;
    var notConnected = 0;
    for (final relay in candidates) {
      if (!connected.contains(relay)) notConnected++;
    }
    if (notConnected > 0) {
      debugPrint('[Chat] $notConnected/${candidates.length} secondary Nostr relays '
          'did not handshake in 8s — keeping them advertised (probe-reachable)');
    }
    // Re-broadcast so any addresses added between T=0 and T+8s reach contacts.
    unawaited(broadcastAddressUpdate());
  }

  /// Gather our own Nostr relay URLs from addresses we're actually subscribed to.
  /// Used for auto-registration, shareable addresses, and contact fallback.
  List<String> _gatherOwnNostrRelays({int limit = 5}) {
    final seen = <String>{};
    final result = <String>[];
    void _add(String relay) {
      if (relay.isEmpty) return;
      if (!relay.startsWith('ws://') && !relay.startsWith('wss://')) {
        relay = 'wss://$relay';
      }
      if (seen.add(relay)) result.add(relay);
    }
    // 1) Identity config relay (user's configured primary relay) — always first
    _add(_identity?.adapterConfig['relay'] ?? '');
    // 2) Relays we're actually connected to (from our own addresses)
    for (final addr in _allAddresses) {
      if (result.length >= limit) break;
      final wssIdx = addr.indexOf('@wss://');
      final wsIdx = wssIdx == -1 ? addr.indexOf('@ws://') : -1;
      final atIdx = wssIdx != -1 ? wssIdx : wsIdx;
      if (atIdx > 0) _add(addr.substring(atIdx + 1));
    }
    // 3) Hardcoded default — only as last-resort fallback so we don't
    //    concentrate every new account on the same bootstrap relay.
    if (result.isEmpty) _add(_kDefaultNostrRelay);
    return result.take(limit).toList();
  }

  /// Classify a flat address list into a per-transport map.
  static Map<String, List<String>> _buildTransportMap(List<String> addresses) {
    final map = <String, List<String>>{};
    for (final addr in addresses) {
      if (addr.isEmpty) continue;
      final transport = _providerFromAddress(addr);
      final list = map[transport] ??= [];
      if (!list.contains(addr)) list.add(addr);
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
    final existing = contact.transportAddresses['Nostr'] ?? const <String>[];
    // If the contact already has at least one Nostr address, keep their
    // addresses AS THEY SENT THEM. The whole point of addr_update is that
    // the contact tells us their current primary relay in the first slot —
    // we must not reorder or overwrite that with our own relays, or we
    // end up routing DMs to relays the contact isn't subscribed to (the
    // relay still ACKs `accepted=true`, so sendMessage silently "succeeds"
    // while the message never arrives).
    if (existing.isNotEmpty) return contact;

    // No Nostr addresses at all (rare — e.g. a pure-Session contact we
    // want to reach via Nostr because we have their Nostr pubkey). Seed
    // with our own relay list as a best-effort fallback; addr_update from
    // them will replace this later.
    final relays = _gatherOwnNostrRelays(limit: 3);
    if (relays.isEmpty) return contact;
    final seeded = relays.map((r) => '${contact.publicKey}@$r').toList();
    final ta = Map<String, List<String>>.from(
      contact.transportAddresses.map((k, v) => MapEntry(k, List<String>.from(v))),
    );
    ta['Nostr'] = seeded;
    final tp = List<String>.from(contact.transportPriority);
    if (!tp.contains('Nostr')) tp.add('Nostr');
    debugPrint('[Chat] Seeded Nostr fallback for ${contact.name}: ${seeded.length} relays '
        '(contact had none)');
    return contact.copyWith(transportAddresses: ta, transportPriority: tp);
  }

  Future<bool> _deliverEncryptedMessage(String address, Message msg) => _pipeline._deliverEncryptedMessage(address, msg);


  Future<bool> _sendToContact(Contact rawContact, String plaintext, {bool noAutoRetry = false}) => _pipeline._sendToContact(rawContact, plaintext, noAutoRetry: noAutoRetry);


  /// Send [plaintext] to a single group member through a specific Pulse
  /// server (the group's `groupServerUrl`), bypassing the normal transport-
  /// priority routing. Used for pulse-mode groups so every group message
  /// flows through the host's Pulse server regardless of the recipient's
  /// preferred transport. Returns true on successful queue-to-WS.
  ///
  /// We intentionally do NOT fall back to other transports on failure —
  /// the whole point of a pulse group is that the user picked "always go
  /// through this server"; silently rerouting via Nostr would leak the
  /// group conversation off the chosen server.
  Future<bool> _sendToContactViaPulseServer(
      Contact rawContact, String plaintext, String pulseServerUrl) =>
      _pipeline._sendToContactViaPulseServer(rawContact, plaintext, pulseServerUrl);


  /// Signal-flavoured sibling of [_sendToContactViaPulseServer]. Used for
  /// pulse-group fan-out of typing/read/edit/delete/reaction/group_update/
  /// sender_key_dist/sfu_invite — anything the broadcaster would otherwise
  /// send through the per-transport priority loop.
  ///
  /// Wired into [SignalBroadcaster.pulseGroupSignalSender] during
  /// initialization; broadcaster invokes this when a group method passes
  /// `overridePulseServer`. Returns true on successful sink.add.
  Future<bool> _sendSignalToContactViaPulseServer(Contact rawContact,
      String type, Map<String, dynamic> payload, String pulseServerUrl) =>
      _pipeline._sendSignalToContactViaPulseServer(rawContact, type, payload, pulseServerUrl);

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

  Future<void> sendFile(Contact contact, Uint8List bytes, String name, {String mediaType = "file"}) => _media.sendFile(contact, bytes, name, mediaType: mediaType);


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
      List<double> amplitudes) =>
      _media.sendVoice(contact, audioBytes, durationSeconds, amplitudes);

  /// Send a video note (circle). Small recordings go inline; larger ones
  /// route through the 3-tier media pipeline (P2P → Blossom → relay chunks).
  Future<void> sendVideoNote(Contact contact, Uint8List mp4Bytes, int durationSeconds, Uint8List? thumbnailJpeg) => _media.sendVideoNote(contact, mp4Bytes, durationSeconds, thumbnailJpeg);
  Future<bool> _sendViaBlossom(Contact contact, Uint8List bytes, String name,
      String mediaType) =>
      _media._sendViaBlossom(contact, bytes, name, mediaType);


  /// Tier 1: Send file directly via P2P DataChannel binary frames.
  Future<bool> _sendViaP2PBinary(Contact contact, Uint8List bytes,
      String name, String mediaType) =>
      _media._sendViaP2PBinary(contact, bytes, name, mediaType);


  /// Tier 3 / group fallback: relay-based 32KB chunks (original behavior).
  Future<void> _sendViaRelayChunks(Contact contact, Uint8List bytes, String name,
      {String mediaType = 'file'}) =>
      _media._sendViaRelayChunks(contact, bytes, name, mediaType: mediaType);


  Future<bool> _sendGroupChunk(Contact group, String chunkPayload) =>
      _media._sendGroupChunk(group, chunkPayload);

  // ── Message CRUD ──────────────────────────────────────────────────────────

  Future<void> deleteLocalMessage(Contact contact, String messageId) =>
      _crud.deleteLocalMessage(contact, messageId);

  Future<void> deleteMessage(Contact contact, Message message) =>
      _crud.deleteMessage(contact, message);

  void _handleRemoteDelete(String fromId, String msgId, {String? groupId}) =>
      _crud.handleRemoteDelete(fromId, msgId, groupId: groupId);

  Future<void> markRoomAsRead(Contact contact) => _crud.markRoomAsRead(contact);

  Future<void> clearRoomHistory(Contact contact) => _crud.clearRoomHistory(contact);

  Future<void> retryMessage(Contact contact, Message message) =>
      _crud.retryMessage(contact, message);

  /// Evicts the oldest 100 entries when the map exceeds 500, preventing
  /// unbounded growth if messages are created faster than resolved.
  void _pruneRetryTimers() => _crud.pruneRetryTimers();

  void _scheduleAutoRetry(Contact contact, Message failedMsg) =>
      _crud.scheduleAutoRetry(contact, failedMsg);

  Future<void> _flushFailedMessages() => _crud.flushFailedMessages();

  void _handleServerAck(String msgId) => _crud.handleServerAck(msgId);

  void _handleReadReceipt(String fromId) => _crud.handleReadReceipt(fromId);

  void _handleDeliveryAck(String fromId, String msgId, {String? groupId}) =>
      _crud.handleDeliveryAck(fromId, msgId, groupId: groupId);

  // ── Disappearing messages ─────────────────────────────────────────────────

  Future<void> setChatTtlSeconds(Contact contact, int seconds,
      {bool sendSignal = true, String? changedBy}) async {
    _repo.setChatTtl(contact.id, seconds);
    final prefs = await _getPrefs();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (seconds == 0) {
      await prefs.remove('chat_ttl_${contact.id}');
    } else {
      await prefs.setInt('chat_ttl_${contact.id}', seconds);
    }
    // Record when this TTL value took effect. Telegram-style semantics:
    // disappearing messages apply to messages sent FROM NOW ON — never
    // retroactively. The repository uses this timestamp to skip scheduling
    // TTL timers on pre-existing history.
    await prefs.setInt('chat_ttl_set_at_${contact.id}', nowMs);
    _repo.setChatTtlSetAt(contact.id, nowMs);
    if (sendSignal) {
      if (contact.isGroup) {
        unawaited(_broadcaster.broadcastGroupTtl(
            contact, seconds, _contacts.contacts));
      } else {
        unawaited(_broadcaster.sendTtlSignal(contact, seconds));
      }
    }
    // Insert a Telegram-style in-chat notice. The local user changing the
    // TTL is `changedBy = null → 'self'`; an inbound ttl_update signal sets
    // `changedBy = peerContactId` so the bubble reads "<peer name> enabled
    // disappearing messages: 1 hour".
    await _insertSystemMessage(contact, {
      '_sys': 'ttl_changed',
      'seconds': seconds,
      'by': changedBy ?? 'self',
    });
    _scheduleNotify();
  }

  /// Insert a system (informational) message into the room. Persisted locally
  /// so it survives restarts; never sent over the wire — both sides generate
  /// their own copy from the corresponding signal.
  Future<void> _insertSystemMessage(
      Contact contact, Map<String, dynamic> sysPayload) async {
    final room = _repo.getRoomForContact(contact.id);
    if (room == null) return;
    final selfId = _identity?.id ?? '';
    final msg = Message(
      id: _uuid.v4(),
      senderId: selfId,
      receiverId: contact.id,
      encryptedPayload: jsonEncode(sysPayload),
      timestamp: DateTime.now(),
      adapterType: 'system',
      isRead: true,
      kind: 'system',
    );
    room.messages.add(msg);
    _repo.trackMessageId(contact.id, msg.id);
    await LocalStorageService().saveMessage(contact.storageKey, msg.toJson());
  }

  // ── Broadcast delegation ──────────────────────────────────────────────────

  Future<void> sendTypingSignal(Contact contact) =>
      _broadcaster.sendTypingSignal(contact, () => _contacts.contacts);

  /// Send a hangup signal to a contact (used when declining an incoming call).
  Future<void> sendHangupSignal(Contact contact) =>
      _sendSignalTo(contact, 'webrtc_hangup', {'action': 'hangup'});

  Future<void> broadcastStatus(UserStatus status) =>
      _broadcaster.broadcastStatus(status, _contacts.contacts);

  Future<void> broadcastProfile(String name, String about, {String avatarB64 = ''}) {
      _selfName = name;
      if (avatarB64.isNotEmpty) _selfAvatar = avatarB64;
      return _broadcaster.broadcastProfile(name, about, _contacts.contacts, avatarB64: avatarB64);
  }

  /// Adopt a Pulse server — saves its URL, reconnects the inbox so the
  /// Pulse auto-register path picks it up, then tells contacts about our
  /// new Pulse address. Returns null on success, or a user-facing error
  /// message on failure (kept generic; details go to debug logs).
  ///
  /// The [inviteCode] is optional — set if the server is in invite-only
  /// mode. Open-mode servers self-register on first auth.
  ///
  /// Re-entrance is rate-limited to one in-flight call per 30s to keep a
  /// frustrated user from stacking up reconnects.
  Future<String?> joinPulseServer(String serverUrl,
      {String? inviteCode}) async {
    final now = DateTime.now();
    final lastAttempt = _lastPulseJoinAt;
    if (lastAttempt != null && now.difference(lastAttempt) < const Duration(seconds: 30)) {
      return 'Too soon — try again in a moment';
    }
    _lastPulseJoinAt = now;

    // Normalize and validate URL — must be https://host[:port] (or http://
    // for local testing). Reject private IPs silently: the banner code
    // shouldn't have surfaced these, but belt-and-suspenders.
    final normalized = _normalizePulseServerUrl(serverUrl);
    if (normalized == null) return 'Invalid Pulse server URL';

    // We need a Pulse private key — all identities derive one at setup,
    // but restored-from-backup accounts without Pulse may be missing it.
    final pulsePriv = await _secureStorage.read(key: 'pulse_privkey') ?? '';
    if (pulsePriv.isEmpty) return 'No Pulse key in this identity';

    final prefs = await _getPrefs();
    final previousUrl = prefs.getString('pulse_server_url');
    final previousInvite = prefs.getString('pulse_invite_code');

    try {
      await prefs.setString('pulse_server_url', normalized);
      if (inviteCode != null && inviteCode.isNotEmpty) {
        await prefs.setString('pulse_invite_code', inviteCode);
      } else {
        await prefs.remove('pulse_invite_code');
      }
      // Reconnect so the Pulse auto-register path (_initInbox) picks up
      // the new URL. This also triggers an addr_update on completion
      // (see Future.delayed at the tail of _initInbox).
      await reconnectInbox();
      return null;
    } catch (e) {
      debugPrint('[ChatController] joinPulseServer failed: $e');
      // Rollback: restore previous prefs so we don't leave a half-set
      // Pulse URL that'd retry on every start.
      if (previousUrl == null) {
        await prefs.remove('pulse_server_url');
      } else {
        await prefs.setString('pulse_server_url', previousUrl);
      }
      if (previousInvite == null) {
        await prefs.remove('pulse_invite_code');
      } else {
        await prefs.setString('pulse_invite_code', previousInvite);
      }
      return 'Could not join Pulse server';
    }
  }

  DateTime? _lastPulseJoinAt;

  /// Parse a user-provided or deep-link Pulse URL into the canonical form
  /// the rest of the client expects (`https://host[:port]`). Returns null
  /// if it's obviously malformed or points at an RFC-1918 / loopback host.
  String? _normalizePulseServerUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    String withScheme = trimmed;
    if (!withScheme.startsWith('http://') && !withScheme.startsWith('https://')) {
      withScheme = 'https://$withScheme';
    }
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) return null;
    final h = uri.host.toLowerCase();
    if (h == 'localhost' || h == '127.0.0.1' || h == '::1' || h == '0.0.0.0') {
      return null;
    }
    if (h.startsWith('192.168.') || h.startsWith('10.') || h.startsWith('169.254.')) return null;
    if (h.startsWith('172.')) {
      final seg = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
      if (seg != null && seg >= 16 && seg <= 31) return null;
    }
    if (h.startsWith('fc') || h.startsWith('fd')) return null;
    // Strip trailing slash / path — server URL should be origin only.
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  /// Canonicalize a user-supplied Pulse URL and reject it if it points
  /// at a non-publicly-routable host. Exposed for UI code that wants to
  /// check a pasted address before offering a join (e.g. the add-contact
  /// deep-link dialog).
  String? publicPulseServerFromUrl(String raw) => _normalizePulseServerUrl(raw);

  /// Pulse server URL suggested by [contact] — either from their Pulse
  /// transport addresses (envelope / addr_update propagated) or null if
  /// they don't advertise Pulse. Consumed by the in-chat suggestion
  /// banner to figure out which server to offer.
  String? suggestedPulseServerForContact(Contact contact) {
    final addrs = contact.transportAddresses['Pulse'] ?? const [];
    for (final a in addrs) {
      final at = a.indexOf('@');
      if (at <= 0) continue;
      final url = _normalizePulseServerUrl(a.substring(at + 1));
      if (url != null) return url;
    }
    return null;
  }

  /// True if we do not currently have any Pulse inbox configured — either
  /// as primary (identity.preferredAdapter) or as a saved secondary.
  bool get hasPulseConfigured {
    if (_identity?.preferredAdapter == 'pulse') return true;
    final url = _prefs?.getString('pulse_server_url') ?? '';
    return url.isNotEmpty;
  }

  /// Whether the user has permanently/temporarily dismissed the Pulse
  /// suggestion banner for [contactId]. Keyed on contact+server so that
  /// a different contact offering a different server still prompts.
  Future<bool> isPulseSuggestionDismissed(String contactId, String serverUrl) async {
    final prefs = await _getPrefs();
    final key = 'pulse_sug_dismiss_${contactId}_$serverUrl';
    final ts = prefs.getInt(key);
    if (ts == null) return false;
    // ts == 0 means "permanently dismissed"; otherwise it's a snooze end.
    if (ts == 0) return true;
    return DateTime.now().millisecondsSinceEpoch < ts;
  }

  Future<void> dismissPulseSuggestion(String contactId, String serverUrl,
      {bool permanent = false}) async {
    final prefs = await _getPrefs();
    final key = 'pulse_sug_dismiss_${contactId}_$serverUrl';
    if (permanent) {
      await prefs.setInt(key, 0);
    } else {
      final snoozeUntil = DateTime.now()
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch;
      await prefs.setInt(key, snoozeUntil);
    }
  }

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

  Future<void> sendGroupInvite(Contact target, Contact group) async {
    // Pre-warm the Pulse server connection on the creator side so the very
    // first invite (and the SFU room create that often follows) doesn't
    // race against WS auth. Fire-and-forget — the invite send itself runs
    // over Nostr/Session/whatever transport the target has, the pulse
    // connection is for FUTURE group messages.
    if (group.isPulseGroup && group.groupServerUrl.isNotEmpty) {
      unawaited(ensureGroupPulseConnection(group.groupServerUrl));
    }
    return _broadcaster.sendGroupInvite(target, group, _contacts.contacts);
  }

  Future<void> declineGroupInvite(SignalGroupInviteEvent invite) => _groups.declineGroupInvite(invite);


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

  /// Build a `pulse://group?cfg=…` shareable invite URL for [group]. Returns
  /// null for non-group contacts. Embeds member pubkeys + transport
  /// addresses so the recipient can route to everyone immediately on accept.
  String? buildGroupInviteLink(Contact group) {
    if (!group.isGroup) return null;
    final memberAddresses =
        _broadcaster.buildMemberAddressesForInvite(group, _contacts.contacts);
    return GroupInviteLink.build(group, memberAddresses: memberAddresses);
  }

  /// Accept a group invite that arrived via a `pulse://group?cfg=…` deep
  /// link. The sender is *not* the in-app inviter (we got this out of band)
  /// but the embedded `creatorId` + `memberPubkeys` are sufficient to seed
  /// routing. After joining, broadcast a group_update so existing members
  /// learn we're now in the roster.
  Future<void> acceptGroupInviteFromLink(GroupInvitePayload payload) => _groups.acceptGroupInviteFromLink(payload);


  Future<void> acceptGroupInvite(SignalGroupInviteEvent invite) => _groups.acceptGroupInvite(invite);


  /// For each `(memberUuid → pulsePubkey)` entry from a pulse-group invite
  /// or update, look up the local contact (by UUID first, then by Nostr
  /// pubkey from `memberPubkeys`) and graft `<pulsePub>@<groupServerUrl>`
  /// into their `transportAddresses['Pulse']` if not already present.
  /// Lets us address pulse-mode messages to that member immediately
  /// without waiting for their own addr_update to circulate via the
  /// host server.
  Future<void> _seedMemberPulseAddresses(Map<String, String> memberPulsePubkeys, Map<String, String> memberPubkeys, String groupServerUrl) => _groups._seedMemberPulseAddresses(memberPulsePubkeys, memberPubkeys, groupServerUrl);


  /// For every `(memberUuid → pubkey)` entry we don't already have a local
  /// contact for (matched by pubkey), create a pending contact so
  /// `findByPubkey` resolves on subsequent group sends. Prefer the
  /// per-member `transportAddresses` carried in the invite/update; fall
  /// back to fabricating `{pubkey}@{relay}` entries on our top Nostr relays
  /// for legacy invites that omitted the addresses field. Pending contacts
  /// learn real addresses from message envelopes later (see the message
  /// receive path in `_handleIncomingMessages`).
  Future<void> _ensurePendingContactsForMembers(Map<String, String> memberPubkeys, Map<String, Map<String, List<String>>> memberAddresses, {Map<String, String> memberNames = const {}}) => _groups._ensurePendingContactsForMembers(memberPubkeys, memberAddresses, memberNames: memberNames);


  /// When [contact]'s pubkey rotates (peer reinstalled), every group whose
  /// `memberPubkeys` map still points at the OLD pubkey for this member
  /// needs to be patched in-place. Otherwise `_resolveGroupRecipients`
  /// keeps looking up the dead old pubkey, and tombstones / sender keys /
  /// group updates silently fail to reach the new install.
  Future<void> _refreshGroupMembershipForContact(Contact contact) async {
    final newPub = _extractPubkeyFromContact(contact);
    if (newPub.isEmpty) return;
    final updated = <Contact>[];
    for (final g in _contacts.contacts) {
      if (!g.isGroup) continue;
      // Did this group reference the (now stale) contact at all? Match by
      // local UUID first, then by old pubkey value (safest detection).
      String? mappedKey;
      for (final entry in g.memberPubkeys.entries) {
        if (entry.key == contact.id ||
            entry.value.toLowerCase() == newPub.toLowerCase()) {
          mappedKey = entry.key;
          break;
        }
      }
      if (mappedKey == null) continue;
      final newMap = Map<String, String>.from(g.memberPubkeys);
      final oldPub = newMap[mappedKey];
      if (oldPub != null && oldPub.toLowerCase() == newPub.toLowerCase()) continue;
      newMap[mappedKey] = newPub;
      // Also make sure this member is in `members`.
      final newMembers = List<String>.from(g.members);
      if (!newMembers.contains(mappedKey)) newMembers.add(mappedKey);
      final patched = g.copyWith(
        memberPubkeys: newMap,
        members: newMembers,
      );
      await _contacts.updateContact(patched);
      updated.add(patched);
    }
    if (updated.isNotEmpty) {
      _invalidateContactIndex();
      debugPrint('[Group] Refreshed memberPubkeys for ${contact.name} '
          'in ${updated.length} group(s) after identity rotation');
      _scheduleNotify();
    }
  }

  /// Replace "Member <pubkey>" placeholder names on already-existing
  /// contacts with the human-readable name we just learned via group_invite
  /// or group_update. Looks up each (uuid → pubkey) entry, finds the
  /// matching local contact (by either local UUID or pubkey), and renames
  /// it ONLY when the current name is the auto-pending placeholder so we
  /// never trample a name the user typed in themselves.
  Future<void> _promotePlaceholderNames(Map<String, String> memberNames, Map<String, String> memberPubkeys) => _groups._promotePlaceholderNames(memberNames, memberPubkeys);


  /// Pull the 64-hex pubkey out of a contact's Nostr/Pulse address. Returns
  /// "" if no recognizable hex prefix is found.
  String _extractPubkeyFromContact(Contact c) {
    for (final addrs in c.transportAddresses.values) {
      for (final addr in addrs) {
        final at = addr.indexOf('@');
        final left = at > 0 ? addr.substring(0, at) : addr;
        if (_hex64.hasMatch(left)) return left.toLowerCase();
      }
    }
    return '';
  }

  /// Best-effort fetch of the contact's published Signal+PQC bundle and
  /// `buildSession` so the first encryptMessage doesn't have to take the
  /// slow lazy path (and possibly fail because the relay hasn't seen our
  /// `#p` filter yet). Errors are swallowed — if the relay isn't reachable
  /// right now we'll retry on the next outgoing message.
  Future<void> _prewarmSignalSession(Contact contact) async {
    try {
      // Walk every transport address until we find one that returns a
      // bundle. Nostr is checked first because it's the most common
      // identity transport; Pulse next; Session last (already write-only
      // and pushed via publishSessionKeysTo in the lazy path).
      Map<String, dynamic>? bundle;
      for (final entry in contact.transportAddresses.entries) {
        final provider = entry.key;
        if (provider == 'Session') continue;
        for (final addr in entry.value) {
          try {
            final b = await _fetchKeysFromAddress(addr, provider);
            if (b != null) { bundle = b; break; }
          } catch (_) {}
        }
        if (bundle != null) break;
      }
      if (bundle == null) return;
      await _signalService.buildSession(contact.databaseId, bundle);
      _keys.cacheContactKyberPk(contact.databaseId, bundle);
      debugPrint('[Group] Pre-warmed Signal session with ${contact.name}');
    } catch (e) {
      debugPrint('[Group] _prewarmSignalSession(${contact.name}) failed: $e');
    }
  }

  /// Caller side of an SFU group call: after `room_create` returns a
  /// roomId + token, push the invite to every group member so their
  /// `incomingGroupCalls` stream fires and they see the standard accept/
  /// decline dialog.
  Future<void> broadcastSfuCallInvite(
      Contact group, String roomId, String token,
      {bool isVideoCall = false}) async {
    // Self-register first so the host's own chat shows the banner too —
    // the broadcast goes out to everyone EXCEPT us.
    _registerActiveGroupCall(
        group.id, roomId, token, _identity?.id ?? 'self',
        isVideoCall: isVideoCall);
    // Find our own Pulse address on this group's server — receivers use
    // it to map Pulse pubkeys (what the SFU reports in `track_available`)
    // back to Nostr senderIds (what their Contact records are keyed on).
    // Try `_allAddresses` first, then derive from secure-storage key as
    // a fallback — Nostr-primary users may not have the group-server
    // Pulse address in `_allAddresses` until the first addr_update
    // rebuild, which happens strictly AFTER adapter init.
    final serverUrl = group.groupServerUrl;
    String ownPulseAddr = '';
    if (serverUrl.isNotEmpty) {
      ownPulseAddr = _allAddresses.firstWhere(
          (a) => a.endsWith('@$serverUrl'),
          orElse: () => '');
      if (ownPulseAddr.isEmpty) {
        try {
          final pulseKey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          if (pulseKey.isNotEmpty) {
            final seed = Uint8List.fromList(hex.decode(pulseKey));
            final pulsePub = await ed25519PubkeyFromSeed(seed);
            ownPulseAddr = '$pulsePub@$serverUrl';
          }
        } catch (e) {
          debugPrint('[Chat] broadcastSfuCallInvite: failed to derive Pulse pk: $e');
        }
      }
    }
    debugPrint('[Chat] broadcastSfuCallInvite: ownPulseAddr="${ownPulseAddr.isEmpty ? "<empty>" : "${ownPulseAddr.substring(0, ownPulseAddr.length.clamp(0, 24))}…"}"');
    return _broadcaster.broadcastSfuInvite(
        group, roomId, token, _contacts.contacts,
        isVideoCall: isVideoCall,
        ownPulseAddr: ownPulseAddr);
  }

  /// Broadcast a group's metadata to every member. Optionally include an
  /// `avatar` blob (base64) — it's only sent when actually changed so the
  /// 30 KiB payload doesn't ride along on every membership tweak.
  /// `previousName` lets the caller signal a rename so we can insert a
  /// Telegram-style "<self> renamed group to X" notice in the local chat;
  /// the receiver-side handler emits its own copy independently.
  Future<void> broadcastGroupUpdate(Contact group,
      {String? previousName, String? avatar,
      Iterable<String>? recipientMemberIds}) async {
    await _broadcaster.broadcastGroupUpdate(group, _contacts.contacts,
        avatar: avatar, recipientMemberIds: recipientMemberIds);
    final selfUuid = _identity?.id ?? 'self';
    final renamed =
        previousName != null && previousName.isNotEmpty && previousName != group.name;
    final avatarChanged = avatar != null && avatar.isNotEmpty;
    if (renamed || avatarChanged) {
      await _insertSystemMessage(group, {
        '_sys': renamed && avatarChanged
            ? 'group_meta_changed'
            : (avatarChanged ? 'group_avatar_changed' : 'group_renamed'),
        if (renamed) 'old': previousName,
        if (renamed) 'new': group.name,
        'by': selfUuid,
      });
      _scheduleNotify();
    }
  }

  /// Build (or refresh) the `memberPubkeys` map on a group Contact by
  /// looking up each member's Nostr pubkey from our local contact list.
  /// Creator-side: after the group is created/added to the repo, call
  /// this and persist the result before broadcasting invites so each
  /// receiver can resolve member UUIDs back to Nostr identities.
  Future<Contact> enrichGroupMemberPubkeys(Contact group) => _groups.enrichGroupMemberPubkeys(group);


  /// Creator-only: broadcast an empty-roster tombstone then remove the
  /// group locally. Peers' group_update listeners detect "members empty"
  /// and self-remove (see the d.groupUpdates.listen handler). We send
  /// the tombstone to the OLD member list — the new payload is empty,
  /// so without an explicit recipient override no one would be notified.
  Future<void> deleteGroup(Contact group) => _groups.deleteGroup(group);


  /// Rotate the sender key for a group after a member is removed, then
  /// redistribute to all remaining members. Call this AFTER updating the
  /// group's member list and broadcasting the group update.
  Future<void> rotateGroupSenderKey(Contact group) => _groups.rotateGroupSenderKey(group);


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
    if (healthy) {
      _primaryUnhealthySince.remove(addr);
      return;
    }
    if (addr != _selfId) return;
    // Primary went unhealthy: start grace timer and re-check after the
    // grace period. A single transient failure shouldn't trigger a costly
    // identity migration (re-publish keys, broadcast addr_update, update
    // prefs). Only sustained failure does.
    _primaryUnhealthySince.putIfAbsent(addr, () => DateTime.now());
    Future.delayed(_kPrimaryMigrationGrace, () {
      final since = _primaryUnhealthySince[addr];
      if (since == null) return; // recovered
      if (_adapterHealth[addr] ?? false) return; // healthy now
      if (addr != _selfId) return; // already migrated by another path
      if (_migrating) return;
      final newPrimary = _allAddresses.firstWhere(
        (a) => a != addr && (_adapterHealth[a] ?? false),
        orElse: () => '',
      );
      if (newPrimary.isEmpty) {
        debugPrint('[Failover] No healthy alternate after '
            '${_kPrimaryMigrationGrace.inSeconds}s — staying on $addr');
        return;
      }
      unawaited(_migratePrimary(oldAddr: addr, newAddr: newPrimary));
    });
  }

  /// Persistently migrate the Nostr identity primary to [newAddr].
  /// Updates [_selfId], [_identity.adapterConfig], prefs.nostr_relay, and
  /// re-publishes Signal keys so contacts fetching from the new relay
  /// can still reach us. Old primary stays in [_allAddresses] as a
  /// secondary (so we keep receiving on it if it recovers).
  Future<void> _migratePrimary({
    required String oldAddr,
    required String newAddr,
  }) async {
    if (_migrating || _identity == null) return;
    _migrating = true;
    try {
      final atIdx = newAddr.indexOf('@');
      if (atIdx <= 0) return;
      final newRelay = newAddr.substring(atIdx + 1);
      debugPrint('[Failover] Migrating primary: $oldAddr → $newAddr');

      // Update in-memory state.
      _selfId = newAddr;
      _identity = Identity(
        id: _identity!.id,
        publicKey: _identity!.publicKey,
        privateKey: _identity!.privateKey,
        preferredAdapter: _identity!.preferredAdapter,
        adapterConfig: {
          ..._identity!.adapterConfig,
          'relay': newRelay,
          'dbId': newAddr,
        },
      );
      _primaryUnhealthySince.remove(oldAddr);

      // Persist to prefs so cold-start reads the new primary.
      final prefs = await _getPrefs();
      await prefs.setString('nostr_relay', newRelay);
      await prefs.setString('user_identity', jsonEncode(_identity!.toJson()));

      // Re-publish Signal keys on the new primary so contacts fetching
      // via NIP-65 / addr_update find our identity at the new address.
      final nostrPriv = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      if (nostrPriv.isNotEmpty) {
        final apiKey = jsonEncode({'privkey': nostrPriv, 'relay': newRelay});
        unawaited(_keys.publishKeysToAdapter('Nostr', apiKey, newAddr));
      }

      if (!_failoverCtrl.isClosed) {
        _failoverCtrl.add((from: oldAddr, to: newAddr));
      }
      unawaited(broadcastAddressUpdate());
      _scheduleNotify();
    } catch (e) {
      debugPrint('[Failover] Migration failed: $e');
    } finally {
      _migrating = false;
    }
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
            remove: alreadyReacted, groupId: contact.id, group: contact));
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
  /// Backward-compat: routes to the user's PRIMARY Pulse sender. For
  /// per-group SFU calls on a foreign Pulse server, callers must use
  /// [sendRawPulseSignalToServer] instead so the message lands on the
  /// correct server in the multi-server pool.
  void sendRawPulseSignal(String jsonMsg) {
    _cachedPulseSender?.sendRaw(jsonMsg);
  }

  /// Check if a Pulse relay sender is available (for SFU routing).
  bool get hasPulseRelay => _cachedPulseSender != null;

  /// Per-server pool of Pulse senders. Keyed by canonicalized server URL
  /// — same canonicalization as `_PulseSharedWs.forUrl` so each entry
  /// here lines up 1:1 with a `_PulseSharedWs` pool entry inside
  /// `pulse_adapter`. Lets the client maintain independent Pulse
  /// connections to multiple servers (primary + N group servers) without
  /// any of them clobbering the others.
  final Map<String, PulseMessageSender> _pulseSendersByServer = {};

  /// Per-server pool of adhoc Pulse readers (auth + RX loop) opened by
  /// [ensureGroupPulseConnection]. Kept so we don't open a second reader
  /// for the same server on subsequent calls.
  final Map<String, PulseInboxReader> _pulseReadersByServer = {};

  /// Send a raw JSON SFU control message to a SPECIFIC Pulse server in
  /// the pool. Required for group calls whose `groupServerUrl` differs
  /// from the user's primary Pulse server — the legacy
  /// [sendRawPulseSignal] always goes to the primary sender and would
  /// silently miss the right server.
  ///
  /// Returns false if no sender exists for [serverUrl] (caller must
  /// run [ensureGroupPulseConnection] first).
  bool sendRawPulseSignalToServer(String serverUrl, String jsonMsg) {
    final key = _canonicalizePulseUrl(serverUrl);
    final sender = _pulseSendersByServer[key];
    if (sender == null) {
      debugPrint('[Group/SFU] sendRawPulseSignalToServer: no sender for '
          '$serverUrl (call ensureGroupPulseConnection first)');
      return false;
    }
    sender.sendRaw(jsonMsg);
    return true;
  }

  /// Open (or reuse) a dedicated Pulse WebSocket connection to
  /// [serverUrl] and register a sender + reader in the per-server pool.
  ///
  /// This is the multi-server primitive: a client keeps its own primary
  /// Pulse connection AND any number of group-server connections in
  /// parallel, each with their own `_PulseSharedWs` pool entry inside
  /// `pulse_adapter`. Without this, group calls on a foreign Pulse
  /// server fail because either:
  ///   1) the user has no primary Pulse at all (Nostr-primary identity)
  ///      — `_cachedPulseSender` is null and `sendRawPulseSignal` is a
  ///      no-op; or
  ///   2) the user has a different primary Pulse server — `sendRaw`
  ///      would land on the WRONG server's WS channel.
  ///
  /// Uses the deterministic Pulse private key (Argon2id-derived from the
  /// recovery key, identical on every server) so any client can join any
  /// open server without preregistration. For closed servers the caller
  /// is expected to have stashed `groupServerInvite` server-side already.
  ///
  /// Returns true once a sender for [serverUrl] is ready.
  Future<bool> ensureGroupPulseConnection(String serverUrl) async {
    if (serverUrl.isEmpty) return false;
    final key = _canonicalizePulseUrl(serverUrl);
    if (_pulseSendersByServer.containsKey(key)) {
      // Sender cached from a previous call — but the underlying reader
      // may have died during a long laptop sleep (uTLS circuit breaker
      // tripped, _runLoop hit max consecutive failures and exited
      // permanently). The sender alone can't dispatch incoming SFU
      // signals to SignalDispatcher, so room_create replies vanish and
      // the user is stuck on "Connecting…". Detect the stale state and
      // tear it down so the path below rebuilds a fresh reader+sender.
      if (isPulseReaderHealthy(serverUrl)) return true;
      debugPrint('[Group/SFU] ensureGroupPulseConnection: cached sender '
          'present but reader is dead (post-sleep recovery) — '
          'rebuilding for $serverUrl');
      _pulseSendersByServer.remove(key);
      _pulseReadersByServer.remove(key);
      dropPulseSharedPoolFor(serverUrl);
      // Clear the uTLS breaker too, otherwise the brand-new reader's
      // first connect attempt throws StateError immediately and we end
      // up in the same broken state we just escaped.
      resetPulseUtlsBreaker();
    }

    var privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
    if (privkey.isEmpty) {
      privkey = await _recoverTransportKey('pulse_privkey');
    }
    if (privkey.isEmpty) {
      debugPrint('[Group/SFU] ensureGroupPulseConnection: no pulse_privkey '
          'and recovery_key derivation failed — cannot open SFU connection');
      return false;
    }
    try {
      final apiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});

      // Reuse an existing reader for this server if one already exists.
      // Pulse-server enforces "1 connection per pubkey" — opening a
      // second WS would make the server kick the first one (sending
      // "abnormal closure: unexpected EOF" to the dropped side), and we
      // never get to send the SFU control message. Two readers can
      // happen because:
      //   - the InboxManager's primary auto-opened an adhoc Pulse reader
      //     during _initialize when pulse_server_url was set in prefs,
      //   - then the user joins an SFU group whose groupServerUrl
      //     matches → ensureGroupPulseConnection naively opens another.
      // Detect both _pulseReadersByServer entries AND the legacy
      // _adhocPulseReader; either covers us.
      PulseInboxReader? reader = _pulseReadersByServer[key];
      final adhocServerKey = _canonicalizePulseUrl(
          // Read primary Pulse server URL from prefs to compare.
          (await _getPrefs()).getString('pulse_server_url') ?? '');
      if (reader == null &&
          _adhocPulseReader != null &&
          adhocServerKey == key) {
        reader = _adhocPulseReader;
        _pulseReadersByServer[key] = reader!;
        debugPrint('[Group/SFU] Reusing primary adhoc Pulse reader for $serverUrl');
      }
      if (reader == null) {
        final created = await InboxManager().createAdhocReader('Pulse', apiKey, serverUrl);
        if (created is PulseInboxReader) {
          reader = created;
          _pulseReadersByServer[key] = reader;
          _messageSubs.add(reader.listenForMessages().listen(_handleIncomingMessages));
          _signalSubs.add(reader.listenForSignals().listen(
              (sigs) => _signalDispatcher!.dispatch(sigs, sourceTransport: 'Pulse')));
          debugPrint('[Group/SFU] Opened pool reader for $serverUrl');
        }
      }

      final sender = PulseMessageSender();
      await sender.initializeSender(apiKey);
      _pulseSendersByServer[key] = sender;
      // Also seed _cachedPulseSender if the user had no primary Pulse
      // at all — keeps legacy `sendRawPulseSignal` callers (broadcaster
      // etc.) working when the user is otherwise Nostr-only.
      _cachedPulseSender ??= sender;
      // Reader auth is async — finishes when the run loop reaches
      // auth_ok. Block here until the pool entry's `_shared.channel` is
      // populated, otherwise the very first sender.sendRaw races and
      // emits "no authenticated connection". 15s covers PoW (~2-5s) + a
      // generous margin for slow networks / Tor.
      final ready = await waitForPulseAuth(serverUrl);
      if (!ready) {
        debugPrint('[Group/SFU] ensureGroupPulseConnection: auth timed out '
            'for $serverUrl — sender created but channel not ready yet');
      }

      // Advertise our Pulse address on this server in `_allAddresses` so the
      // next addr_update broadcast carries it. Without this, peers in our
      // pulse-mode groups never learn our universal Pulse pubkey and their
      // sends to us silently fail with "No Pulse pubkey for X" — the exact
      // bootstrap dead-end that breaks the very first send to a fresh
      // pulse group. Idempotent; broadcastAddressUpdate dedupes too.
      try {
        final seed = Uint8List.fromList(hex.decode(privkey));
        final pulsePub = await ed25519PubkeyFromSeed(seed);
        final selfPulseAddr = '$pulsePub@$serverUrl';
        if (!_allAddresses.contains(selfPulseAddr)) {
          _allAddresses = [..._allAddresses, selfPulseAddr];
          _adapterHealth[selfPulseAddr] = ready;
          debugPrint('[Group/SFU] ensureGroupPulseConnection: advertised '
              'self Pulse address $selfPulseAddr to peers');
          // Fire-and-forget — no need to block; receivers will pick up on
          // the next signal exchange anyway, and serializing here would
          // delay subsequent group sends behind addr_update fan-out.
          unawaited(broadcastAddressUpdate());
        }
        // Publish our Signal/Kyber prekey bundle to THIS server too so
        // pulse-group peers can fetch it (via `fetchPublicKeys` against
        // `<our_pulse_pub>@<groupServerUrl>`) and bootstrap their session
        // for sending to us. CRITICAL: reuse the per-server pool sender
        // we just created — `publishKeysToAdapter` would naively spawn a
        // second `PulseMessageSender` and call `initializeSender`, but
        // the Pulse hub allows only one WS per pubkey, so the second
        // connection kicks the first (the long-lived reader) and the
        // sys_keys publish silently fails with no log. Going through the
        // existing sender ensures we ride the already-authenticated WS.
        try {
          final bundle = await _keys.buildOwnBundle();
          final ok = await sender.sendSignal(
              selfPulseAddr, selfPulseAddr, selfPulseAddr, 'sys_keys', bundle);
          if (ok) {
            debugPrint('[Group/SFU] Published Signal bundle to $serverUrl '
                'via reused pool sender');
          } else {
            debugPrint('[Group/SFU] Failed to publish Signal bundle to '
                '$serverUrl (sender returned false)');
          }
        } catch (err) {
          debugPrint('[Group/SFU] Failed to publish Signal bundle to '
              '$serverUrl: $err');
        }
      } catch (e) {
        debugPrint('[Group/SFU] ensureGroupPulseConnection: failed to '
            'advertise self Pulse address / publish keys: $e');
      }

      return ready;
    } catch (e) {
      debugPrint('[Group/SFU] ensureGroupPulseConnection failed: $e');
      return false;
    }
  }

  /// Force-reconnect the per-server Pulse pool entry. Used by SFU when
  /// `room_create` / `room_join` retries silently timed out — usually
  /// the underlying WS sink is half-closed (Dart's `sink.add` returns
  /// without raising even when the TCP layer dropped the connection),
  /// so we tear down the old reader+sender and force a fresh
  /// authenticated channel before the caller resends.
  ///
  /// IMPORTANT: do not call `reader.resetConnection()` — that
  /// auto-restarts the runLoop, racing the new reader we open via
  /// ensureGroupPulseConnection and producing two competing
  /// connections (server's "1 client per pubkey" then ping-pongs
  /// between them, neither lasts long enough to deliver SFU control
  /// messages). `close()` stops the loop without restarting it.
  Future<void> resetGroupPulseConnection(String serverUrl) async {
    if (serverUrl.isEmpty) return;
    final key = _canonicalizePulseUrl(serverUrl);
    debugPrint('[Group/SFU] forcing Pulse reconnect for $serverUrl');
    final reader = _pulseReadersByServer.remove(key);
    final sender = _pulseSendersByServer.remove(key);
    // Hard-stop old reader. close() sets _running=false + closes the
    // WS sink without spawning a fresh loop. Sender holds no
    // connection state (it borrows the reader's shared channel) so
    // dropping the map reference is enough.
    try { reader?.close(); } catch (_) {}
    sender; // intentionally not closed
    // Drop the shared pool entry too so the next ensureGroup creates
    // a brand-new _PulseSharedWs instead of a stale `authenticated=true`
    // shell from the dead connection.
    dropPulseSharedPoolFor(serverUrl);
    // Tiny breather so close() completes before we reopen.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Re-open. ensureGroupPulseConnection rebuilds reader+sender +
    // signal subscriptions and waits for auth before returning.
    await ensureGroupPulseConnection(serverUrl);
  }

  /// Same canonicalization as _PulseSharedWs._canonicalize so our pool
  /// keys line up 1:1 with the pulse_adapter pool. Strips fragment,
  /// trailing slash, default ports (443 for https, 80 for http), and
  /// lower-cases scheme+host.
  ///
  /// **Stripping default ports is load-bearing**: without it, group
  /// invites carrying `https://duck.azxc.site:443` create a pool entry
  /// distinct from the pre-existing `https://duck.azxc.site` (no port)
  /// entry — same server, same pubkey, but two PulseInboxReaders trying
  /// to hold the WS at once. Server enforces one connection per pubkey
  /// so it kicks the older one ~every second; readers reconnect; cycle
  /// runs forever (~204 reconnects in 40 minutes observed in production
  /// logs). And every signal sent during the kick window comes back as
  /// `signal_fail offline` because the recipient was momentarily without
  /// a connection — explains why reactions / edits / deletes silently
  /// drop while messages (TypeSend, server-stored) eventually arrive.
  static String _canonicalizePulseUrl(String serverUrl) {
    if (serverUrl.isEmpty) return '';
    var s = serverUrl.trim();
    final hash = s.indexOf('#');
    if (hash != -1) s = s.substring(0, hash);
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);
    s = s.toLowerCase();
    // Strip default ports.
    if (s.startsWith('https://') && s.endsWith(':443')) {
      s = s.substring(0, s.length - 4);
    } else if (s.startsWith('http://') && s.endsWith(':80')) {
      s = s.substring(0, s.length - 3);
    }
    return s;
  }

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
    _wakeWatchdogTimer?.cancel();
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
    _activeCallsCtrl.close();
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
    _adhocPulseReader?.zeroize();
    _adhocPulseReader = null;
    _cachedPulseSender = null;
    _contactIndex = null;
    unawaited(VoiceService().dispose());
    // Drain the NIP-44 nonce-flush debounce timer + write any pending
    // nonces before LocalStorageService below gets torn down. Without
    // this the timer can fire after the SQLite handle is closed and
    // crash the isolate on shutdown.
    unawaited(nip44.disposeNip44Service());
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

/// Tracks an SFU group call that's currently in progress on the server.
/// Used by the chat-screen banner so users who dismissed the popup or
/// joined the group after the invite went out can still hop in.
class ActiveGroupCall {
  final String groupId;
  final String roomId;
  final String token;
  final String hostId;
  final bool isVideoCall;
  final DateTime startedAt;
  ActiveGroupCall({
    required this.groupId,
    required this.roomId,
    required this.token,
    required this.hostId,
    required this.isVideoCall,
    required this.startedAt,
  });
}

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
