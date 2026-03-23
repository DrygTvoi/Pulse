import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:convert/convert.dart';
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
import '../adapters/waku_adapter.dart';
import '../adapters/oxen_adapter.dart';
import '../adapters/pulse_adapter.dart';
import '../adapters/lan_adapter.dart';
import '../services/oxen_key_service.dart';
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
import '../services/sentry_service.dart';
import '../services/voice_service.dart';
import '../services/sender_key_service.dart';
import '../services/signal_dispatcher.dart';
import '../models/contact_repository.dart';
// Facade services
import '../services/message_repository.dart';
import '../services/key_manager.dart';
import '../services/signal_broadcaster.dart';

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

  // Microtask-coalesced notifyListeners — collapses rapid-fire updates into one
  bool _notifyScheduled = false;
  void _scheduleNotify() {
    if (_notifyScheduled || _disposed) return;
    _notifyScheduled = true;
    Future.microtask(() {
      _notifyScheduled = false;
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

  // Emits contact name + databaseId when their Signal identity key changes
  final StreamController<({String contactName, String contactId})> _keyChangeCtrl = StreamController.broadcast();
  Stream<({String contactName, String contactId})> get keyChangeWarnings => _keyChangeCtrl.stream;

  // Emits a display message when an incoming signal fails MAC/integrity check
  final StreamController<String> _tamperWarningCtrl = StreamController.broadcast();
  Stream<String> get tamperWarnings => _tamperWarningCtrl.stream;

  // SmartRouter: per-address delivery success counts (in-memory + persisted).
  final Map<String, int> _deliverySuccessCount = {};
  static const _kDeliveryStatsKey = 'delivery_stats_v1';
  Timer? _deliveryStatsHalveTimer;

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

  // Cached contact index with dirty flag — avoids rebuilding on every call
  HashMap<String, Contact>? _contactIndex;
  bool _contactIndexDirty = true;

  // Cached sender instances per provider — avoids re-allocating on every send.
  NostrMessageSender? _cachedNostrSender;
  FirebaseInboxSender? _cachedFirebaseSender;
  WakuMessageSender? _cachedWakuSender;
  OxenMessageSender? _cachedOxenSender;
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

  // Call streams
  final StreamController<Map<String, dynamic>> _incomingCallController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingCalls => _incomingCallController.stream;

  final StreamController<Map<String, dynamic>> _incomingGroupCallController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingGroupCalls => _incomingGroupCallController.stream;

  final StreamController<Map<String, dynamic>> _signalStreamController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get signalStream => _signalStreamController.stream;

  Identity? get identity => _identity;
  List<String> get allAddresses => List.unmodifiable(_allAddresses);

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

  int getChatTtlCached(String contactId) => _repo.getChatTtlCached(contactId);

  double? getUploadProgress(String msgId) => _repo.getUploadProgress(msgId);

  bool hasPqcKey(String contactId) => _keys.hasPqcKey(contactId);

  // Online status delegation
  bool isOnline(String contactId) => _broadcaster.isOnline(contactId);
  String lastSeenLabel(String contactId) => _broadcaster.lastSeenLabel(contactId);

  /// Load persisted message history for a contact's room.
  Future<void> loadRoomHistory(Contact contact) async {
    await _repo.loadRoomHistory(contact, onChanged: () { if (!_disposed) notifyListeners(); });
    // Schedule TTL deletions for loaded messages
    final ttl = _repo.getChatTtlCached(contact.id);
    if (ttl > 0) {
      final room = _repo.getRoomForContact(contact.id);
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
      await _initInbox();
    } else {
      _connectionStatus = ConnectionStatus.disconnected;
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
      _cachedWakuSender = null;
      _cachedOxenSender = null;
      _cachedPulseSender = null;
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
      case 'waku':
        providerName = 'Waku';
        {
          final prefs = await _getPrefs();
          String userId = prefs.getString('waku_identity') ?? '';
          if (userId.isEmpty) {
            userId = const Uuid().v4().replaceAll('-', '');
            await prefs.setString('waku_identity', userId);
          }
          String nodeUrl = 'http://127.0.0.1:8645';
          try {
            final cfg = jsonDecode(apiKey) as Map<String, dynamic>;
            nodeUrl = (cfg['nodeUrl'] as String? ?? nodeUrl).trim();
          } catch (e) {
            debugPrint('[Chat] Failed to parse Waku config: $e');
          }
          apiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
          dbId = '$userId@$nodeUrl';
          _selfId = dbId;
        }
      case 'oxen':
        providerName = 'Oxen';
        {
          await OxenKeyService.instance.initialize();
          _selfId = OxenKeyService.instance.sessionId;
          final prefs = await _getPrefs();
          final nodeUrl = prefs.getString('oxen_node_url') ?? '';
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

    // Load delivery stats and start 24h halving timer.
    unawaited(_loadDeliveryStats());
    _deliveryStatsHalveTimer?.cancel();
    _deliveryStatsHalveTimer = Timer.periodic(const Duration(hours: 24), (_) {
      _deliverySuccessCount.updateAll((_, v) => v ~/ 2);
      unawaited(_saveDeliveryStats());
    });

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

    // Assign all addresses atomically so concurrent readers see a complete list.
    _allAddresses = newAddresses;

    // LAN fallback adapter
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
      final contact = _contacts.contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == contactId, orElse: () => null);
      if (contact != null) {
        unawaited(_broadcaster.sendP2PSignal(contact, type, payload));
      }
    };
    _messageSubs.add(P2PTransportService.instance.messageStream.listen((evt) {
      _handleP2PMessage(evt.contactId, evt.payload);
    }));

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
          final keySuffix = relay.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
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

  Future<({MessageSender sender, String apiKey})?> _buildSenderFor(Contact contact) async {
    switch (contact.provider) {
      case 'Firebase':
        final token = _identity!.adapterConfig['token'] ?? '';
        _cachedFirebaseSender ??= FirebaseInboxSender();
        return (sender: _cachedFirebaseSender!, apiKey: token);
      case 'Nostr':
        final privkey = await _getNostrPrivkey();
        final prefs = await _getPrefs();
        final relay = prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
        _cachedNostrSender ??= NostrMessageSender();
        return (sender: _cachedNostrSender!,
                apiKey: jsonEncode({'privkey': privkey, 'relay': relay}));
      case 'Waku':
        final prefs = await _getPrefs();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        _cachedWakuSender ??= WakuMessageSender();
        return (sender: _cachedWakuSender!,
                apiKey: jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
      case 'Oxen':
        final prefs = await _getPrefs();
        final nodeUrl = prefs.getString('oxen_node_url') ?? '';
        _cachedOxenSender ??= OxenMessageSender();
        return (sender: _cachedOxenSender!, apiKey: nodeUrl);
      case 'Pulse':
        final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
        final prefs = await _getPrefs();
        final serverUrl = prefs.getString('pulse_server_url') ?? '';
        _cachedPulseSender ??= PulseMessageSender();
        return (sender: _cachedPulseSender!,
                apiKey: jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
      default:
        return null;
    }
  }

  /// Centralised helper: init sender for contact's provider and send a signal.
  Future<bool> _sendSignalTo(Contact contact, String type, Map<String, dynamic> payload) async {
    if (_identity == null || _selfId.isEmpty) return false;
    try {
      final built = await _buildSenderFor(contact);
      if (built == null) return false;
      await built.sender.initializeSender(built.apiKey);

      var signedPayload = payload;
      if (contact.provider != 'Nostr') {
        signedPayload = await _signPayload(contact, type, payload);
      }

      await built.sender.sendSignal(
          contact.databaseId, contact.databaseId, _selfId, type, signedPayload);
      return true;
    } catch (e) {
      debugPrint('[ChatController] Signal $type to ${contact.name} failed: $e');
      return false;
    }
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
      await InboxManager().addSenderPlugin(contact.provider, built.sender, built.apiKey);
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

  // ── Signal dispatcher ─────────────────────────────────────────────────────

  /// Marks the contact index as stale so [_getContactIndex] rebuilds it.
  void _invalidateContactIndex() {
    _contactIndexDirty = true;
    _contactIndex = null;
  }

  /// Returns the cached contact index, rebuilding only when dirty.
  Map<String, Contact> _getContactIndex() {
    if (!_contactIndexDirty && _contactIndex != null) return _contactIndex!;
    final contactByDbId = HashMap<String, Contact>();
    for (final c in _contacts.contacts) {
      contactByDbId[c.databaseId] = c;
      final idPart = c.databaseId.split('@').first;
      if (idPart.isNotEmpty && idPart != c.databaseId) {
        contactByDbId.putIfAbsent(idPart, () => c);
      }
    }
    _contactIndex = contactByDbId;
    _contactIndexDirty = false;
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
      groupContactResolver: (id) => _contacts
          .contacts
          .cast<Contact?>()
          .firstWhere(
            (c) => c?.isGroup == true && c?.id == id,
            orElse: () => null,
          ),
      rateLimiter: _sigRateLimiter,
    );

    final d = _signalDispatcher!;

    _dispatcherSubs.add(d.rawSignals.listen((e) {
      if (!_signalStreamController.isClosed) _signalStreamController.add(e.signal);
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
      });
    }));

    _dispatcherSubs.add(d.readReceipts.listen((e) {
      _handleReadReceipt(e.fromId);
    }));

    _dispatcherSubs.add(d.groupReadReceipts.listen((e) {
      _handleGroupReadReceipt(e.fromId, e.groupId, e.msgId);
    }));

    _dispatcherSubs.add(d.deliveryAcks.listen((e) {
      _handleDeliveryAck(e.fromId, e.msgId, groupId: e.groupId);
    }));

    _dispatcherSubs.add(d.ttlUpdates.listen((e) {
      unawaited(setChatTtlSeconds(e.contact, e.seconds, sendSignal: false));
    }));

    // Reactions — delegate to repo
    _dispatcherSubs.add(d.reactions.listen((e) {
      _repo.applyRemoteReaction(e.storageKey, e.msgId, '${e.emoji}_${e.from}', e.remove);
      if (e.remove) {
        unawaited(LocalStorageService().removeReaction(e.storageKey, e.msgId, e.emoji, e.from));
      } else {
        unawaited(LocalStorageService().addReaction(e.storageKey, e.msgId, e.emoji, e.from));
      }
      _scheduleNotify();
    }));

    _dispatcherSubs.add(d.edits.listen((e) {
      final room = e.groupId != null
          ? (_repo.getRoomForContact(e.groupId!) ?? _repo.getRoomForContact(e.contact.id))
          : _repo.getRoomForContact(e.contact.id);
      if (room != null) {
        final idx = room.messages.indexWhere((m) => m.id == e.msgId);
        if (idx != -1) {
          final storageKey = room.contact.storageKey;
          final updated = room.messages[idx].copyWith(encryptedPayload: e.text, isEdited: true);
          room.messages[idx] = updated;
          unawaited(LocalStorageService().saveMessage(storageKey, updated.toJson()));
          _scheduleNotify();
        }
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
      if (e.contact.provider == 'Oxen') {
        unawaited(_keys.publishOxenKeysTo(e.contact, _selfId));
      }
    }));

    _dispatcherSubs.add(d.p2pEvents.listen((e) {
      unawaited(P2PTransportService.instance.handleSignal(
          e.contact.id, e.type, e.payload));
    }));

    _dispatcherSubs.add(d.relayExchanges.listen((e) async {
      await savePeerRelays(e.relays);
    }));

    _dispatcherSubs.add(d.statusUpdates.listen((e) async {
      await StatusService.instance.saveContactStatus(e.contact.id, e.status);
      if (!_statusUpdatesCtrl.isClosed) {
        _statusUpdatesCtrl.add(e.contact.id);
      }
    }));

    _dispatcherSubs.add(d.addrUpdates.listen((e) async {
      final addrContact = e.contact;
      final primary = e.primary;
      final all = e.all;
      final alts = <String>{...addrContact.alternateAddresses};
      if (addrContact.databaseId.isNotEmpty && addrContact.databaseId != primary) {
        alts.add(addrContact.databaseId);
      }
      alts.addAll(all.where((a) => a != primary));
      alts.remove(primary);
      final updated = addrContact.copyWith(
        databaseId: primary,
        alternateAddresses: alts.toList(),
      );
      await _contacts.updateContact(updated);
      _invalidateContactIndex();
      debugPrint('[ChatController] addr_update: ${addrContact.name} → $primary');
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
      final group = _contacts.contacts.cast<Contact?>()
          .firstWhere((c) => c?.isGroup == true && c?.id == e.groupId, orElse: () => null);
      if (group == null) return;
      final memberRemoved = e.members.length < group.members.length;
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
    final groupContact = _contacts.contacts.cast<Contact?>()
        .firstWhere((c) => c?.isGroup == true && c?.id == groupId, orElse: () => null);
    if (groupContact == null) return;
    // Resolve reader and verify group membership to prevent forged receipts.
    Contact? reader;
    for (final c in _contacts.contacts) {
      if (c.databaseId == fromId || c.databaseId.split('@').first == fromId) {
        reader = c;
        break;
      }
    }
    final readerId = reader?.id ?? fromId;
    if (!groupContact.members.contains(readerId)) return;
    final room = _repo.getRoomForContact(groupContact.id);
    if (room == null) return;
    final idx = room.messages.indexWhere((m) => m.id == msgId);
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

        if (!_allAddresses.contains(msg.senderId) &&
            msg.senderId != _selfId &&
            !_msgRateLimiter.allow(msg.senderId)) {
          debugPrint('[Chat] Rate limited message from: ${msg.senderId}');
          continue;
        }

        String rawPayload = msg.encryptedPayload;
        if (rawPayload.startsWith('PQC2||')) {
          try {
            rawPayload = CryptoLayer.unwrap(rawPayload);
          } catch (e) {
            debugPrint('[PQC] Unwrap failed for ${msg.id}: $e');
          }
        }

        String decryptedRaw = rawPayload;
        if (rawPayload.startsWith('E2EE||')) {
          final fastContact = contactByDbId[msg.senderId]
              ?? contactByDbId[msg.senderId.split('@').first];
          if (fastContact != null) {
            try {
              decryptedRaw = await _signalService.decryptMessage(fastContact.databaseId, rawPayload);
            } catch (e) {
              debugPrint('[Chat] E2EE fast-path decrypt failed for ${fastContact.databaseId}: $e');
              sentryBreadcrumb('E2EE fast-path decrypt failed', category: 'signal');
            }
          }
          if (decryptedRaw == rawPayload) {
            final senderPubPrefix = msg.senderId.split('@').first;
            for (final c in _contacts.contacts) {
              if (c.alternateAddresses.any((a) => a.startsWith(senderPubPrefix))) {
                try {
                  decryptedRaw = await _signalService.decryptMessage(c.databaseId, rawPayload);
                  break;
                } catch (e) { debugPrint('[Chat] Alt-address decrypt failed for ${c.databaseId}: $e'); }
              }
            }
          }
        }

        final env = MessageEnvelope.tryUnwrap(decryptedRaw);
        final canonicalSenderId = env?.from ?? msg.senderId;
        final bodyText = env?.body ?? decryptedRaw;

        Contact? senderContact = contactByDbId[canonicalSenderId]
            ?? contactByDbId[canonicalSenderId.split('@').first];
        senderContact ??= contactByDbId[msg.senderId]
            ?? contactByDbId[msg.senderId.split('@').first];

        if (senderContact != null) {
          _repo.getOrCreateRoomWithId(senderContact, msg.senderId, senderContact.provider);
          final room = _repo.getRoomForContact(senderContact.id)!;

          if (!room.messages.any((m) => m.id == msg.id)) {
            try {
              String displayText = bodyText;
              Contact targetContact = senderContact;
              String finalText = displayText;
              String? groupReplyToId, groupReplyToText, groupReplyToSender;
              try {
                var parsed = jsonDecode(displayText) as Map<String, dynamic>;
                // ── Sender Key decrypt: unwrap _sk envelope ──
                if (parsed['_sk'] == true) {
                  final skGroupId = parsed['_group'] as String?;
                  final ct = parsed['ct'] as String?;
                  if (skGroupId != null && ct != null) {
                    try {
                      final cipherBytes = base64Decode(ct);
                      final plainBytes = await SenderKeyService.instance
                          .decrypt(skGroupId, senderContact.databaseId, cipherBytes);
                      final innerJson = utf8.decode(plainBytes);
                      parsed = jsonDecode(innerJson) as Map<String, dynamic>;
                      displayText = innerJson;
                    } catch (skErr) {
                      debugPrint('[SenderKey] Decrypt failed from ${senderContact.name}: $skErr');
                      // Fall through — parsed still has _sk envelope, will be treated as plain text.
                    }
                  }
                }
                final groupId = parsed['_group'] as String?;
                if (groupId != null) {
                  final groupContact = _contacts.contacts.cast<Contact?>()
                      .firstWhere((c) => c?.isGroup == true && c?.id == groupId,
                          orElse: () => null);
                  final isMember = groupContact?.members.contains(senderContact.id) ?? false;
                  if (groupContact != null && isMember) {
                    targetContact = groupContact;
                    finalText = parsed['text'] as String? ?? displayText;
                    groupReplyToId = parsed['_replyToId'] as String?;
                    groupReplyToText = parsed['_replyToText'] as String?;
                    groupReplyToSender = parsed['_replyToSender'] as String?;
                    _repo.getOrCreateRoomWithId(groupContact, groupContact.id, 'group');
                  }
                }
              } catch (e) { debugPrint('[Chat] Signal JSON parse (treating as plain text): $e'); }

              bool skipMessage = false;
              if (MediaService.isChunkPayload(finalText)) {
                final assembled = _chunkAssembler.handleChunk(finalText);
                if (assembled == null) {
                  skipMessage = true;
                } else {
                  finalText = assembled;
                }
              }

              if (!skipMessage &&
                  !MediaService.isMediaPayload(finalText) &&
                  !MediaService.isChunkPayload(finalText) &&
                  finalText.length > 65536) {
                debugPrint('[ChatController] Dropped oversized message (${finalText.length} bytes)');
                skipMessage = true;
              }

              if (!skipMessage) {
                final targetRoom = _repo.getRoomForContact(targetContact.id) ?? room;
                if (!targetRoom.messages.any((m) => m.id == msg.id)) {
                  final decryptedMsg = Message(
                    id: msg.id,
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
                  await LocalStorageService().saveMessage(
                      targetContact.storageKey, decryptedMsg.toJson());
                  hasUpdates = true;
                  if (!_newMsgController.isClosed) {
                    _newMsgController.add((contactId: targetContact.id, message: decryptedMsg));
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
            final memberContact = _contacts.contacts.cast<Contact?>()
                .firstWhere((c) => c?.id == memberId, orElse: () => null);
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
          final memberContact = _contacts.contacts.cast<Contact?>()
              .firstWhere((c) => c?.id == memberId, orElse: () => null);
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
          final memberContact = _contacts.contacts.cast<Contact?>()
              .firstWhere((c) => c?.id == memberId, orElse: () => null);
          if (memberContact == null) continue;
          await _sendToContact(memberContact, groupPayload, noAutoRetry: noAutoRetry);
          sent++;
        }
      }

      final finalStatus = sent > 0 ? 'sent' : 'failed';
      final idx = groupRoom.messages.indexWhere((m) => m.id == localMsg.id);
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
    final envelope = MessageEnvelope.wrap(
      _selfId.isNotEmpty ? _selfId : _identity!.id, text, replyTo: replyInfo);

    String encryptedText;
    try {
      encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
    } catch (e) {
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
        } else if (contact.provider == 'Oxen') {
          contactReader = OxenInboxReader();
          final prefs = await _getPrefs();
          initApiKey = prefs.getString('oxen_node_url') ?? '';
          initDbId = contact.databaseId;
          unawaited(_keys.publishOxenKeysTo(contact, _selfId));
        } else if (contact.provider == 'Pulse') {
          contactReader = PulseInboxReader();
          final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _getPrefs();
          final serverUrl = prefs.getString('pulse_server_url') ?? '';
          initApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
          initDbId = contact.databaseId;
        } else {
          throw Exception('Unknown provider: ${contact.provider}');
        }
        await contactReader.initializeReader(initApiKey, initDbId);
        final bundle = await contactReader.fetchPublicKeys();
        if (bundle != null) {
          final keyChanged = await _signalService.buildSession(contact.databaseId, bundle);
          _keys.cacheContactKyberPk(contact.databaseId, bundle);
          if (keyChanged && !_keyChangeCtrl.isClosed) {
            _keyChangeCtrl.add((contactName: contact.name, contactId: contact.databaseId));
          }
          encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
        } else {
          debugPrint('[E2EE] No key bundle for ${contact.name} — send aborted');
          if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add(contact.name);
          return;
        }
      } catch (e2) {
        debugPrint('[E2EE] Session build failed for ${contact.name}: $e2 — send aborted');
        sentryBreadcrumb('E2EE session build failed', category: 'encryption');
        if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add(contact.name);
        return;
      }
    }

    if (encryptedText.startsWith('E2EE||')) {
      encryptedText = await _keys.pqcWrap(encryptedText, contact.databaseId);
    }

    final contactAdapterType = contact.provider == 'Nostr' ? 'nostr'
        : contact.provider == 'Waku' ? 'waku'
        : contact.provider == 'Oxen' ? 'oxen'
        : 'firebase';

    final msg = Message(
      id: _uuid.v4(),
      senderId: _selfId.isNotEmpty ? _selfId : _identity!.id,
      receiverId: contact.databaseId,
      encryptedPayload: encryptedText,
      timestamp: DateTime.now(),
      adapterType: contactAdapterType,
    );

    final room = _repo.getOrCreateRoom(contact);
    final localMsg = Message(
      id: msg.id, senderId: _identity!.id, receiverId: contact.id,
      encryptedPayload: text, timestamp: msg.timestamp,
      adapterType: msg.adapterType, isRead: true, status: 'sending',
      replyToId: replyInfo?.id,
      replyToText: replyInfo?.text,
      replyToSender: replyInfo?.sender,
    );
    room.messages.add(localMsg);
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, localMsg, localTtl, onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();

    if (contact.provider != 'Firebase' && contact.provider != 'Nostr' &&
        contact.provider != 'Waku' && contact.provider != 'Oxen') {
      debugPrint('[ChatController] Unknown provider "${contact.provider}" for ${contact.name}');
      final idx2 = room.messages.indexWhere((m) => m.id == msg.id);
      final failedMsg2 = localMsg.copyWith(status: 'failed');
      if (idx2 != -1) room.messages[idx2] = failedMsg2;
      await LocalStorageService().saveMessage(contact.storageKey, failedMsg2.toJson());
      notifyListeners();
      return;
    }

    await _addSenderPlugin(contact);
    bool sent;
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) debugPrint('[P2P] Direct delivery to ${contact.name}');
    } else {
      sent = await InboxManager().routeMessage(
          contact.provider, contact.databaseId, contact.databaseId, msg);
      if (!contact.isGroup) {
        unawaited(P2PTransportService.instance.connect(contact.id));
      }
    }

    final idx = room.messages.indexWhere((m) => m.id == msg.id);
    final finalMsg = localMsg.copyWith(status: sent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    notifyListeners();
    if (!sent && !noAutoRetry) _scheduleAutoRetry(contact, finalMsg);
  }

  // ── Smart Router helpers ──────────────────────────────────────────────────

  static final _oxenAddrRegex = RegExp(r'^[0-9a-f]{66}$');
  static final _nostrPubRegex = RegExp(r'^[0-9a-f]{64}$');
  static final _pulseAddrRegex = RegExp(r'^[0-9a-f]{64}@https://', caseSensitive: false);

  static String _providerFromAddress(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        _oxenAddrRegex.hasMatch(lower)) { return 'Oxen'; }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        _nostrPubRegex.hasMatch(lower)) { return 'Nostr'; }
    // Pulse: 64-char hex @ https:// (not wss://)
    if (_pulseAddrRegex.hasMatch(lower)) { return 'Pulse'; }
    if (lower.contains('@https://')) { return 'Firebase'; }
    if (lower.contains('@http://')) { return 'Waku'; }
    return 'Nostr';
  }

  Future<bool> _deliverEncryptedMessage(String address, Message msg) async {
    if (_identity == null) return false;
    final provider = _providerFromAddress(address);
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
          : prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
      _cachedNostrSender ??= NostrMessageSender();
      await InboxManager().addSenderPlugin('Nostr', _cachedNostrSender!,
          jsonEncode({'privkey': privkey, 'relay': relay}));
    } else if (provider == 'Waku') {
      final prefs = await _getPrefs();
      final userId = prefs.getString('waku_identity') ?? '';
      final atIdx = address.indexOf('@http');
      final nodeUrl = atIdx != -1 ? address.substring(atIdx + 1) : '';
      await InboxManager().addSenderPlugin('Waku', WakuMessageSender(),
          jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
    } else if (provider == 'Oxen') {
      final prefs = await _getPrefs();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      await InboxManager().addSenderPlugin('Oxen', OxenMessageSender(), nodeUrl);
    } else if (provider == 'Pulse') {
      final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
      final prefs = await _getPrefs();
      final serverUrl = prefs.getString('pulse_server_url') ?? '';
      await InboxManager().addSenderPlugin('Pulse', PulseMessageSender(),
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
        } else if (contact.provider == 'Waku') {
          contactReader = WakuInboxReader();
          initApiKey = '';
        } else if (contact.provider == 'Oxen') {
          contactReader = OxenInboxReader();
          final prefs = await _getPrefs();
          initApiKey = prefs.getString('oxen_node_url') ?? '';
          unawaited(_keys.publishOxenKeysTo(contact, _selfId));
        } else if (contact.provider == 'Pulse') {
          contactReader = PulseInboxReader();
          final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _getPrefs();
          final serverUrl = prefs.getString('pulse_server_url') ?? '';
          initApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
        } else {
          return false;
        }
        await contactReader.initializeReader(initApiKey, initDbId);
        final bundle = await contactReader.fetchPublicKeys();
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
    if (encryptedText.startsWith('E2EE||')) {
      encryptedText = await _keys.pqcWrap(encryptedText, contact.databaseId);
    }
    final msg = Message(
      id: _uuid.v4(),
      senderId: _selfId.isNotEmpty ? _selfId : _identity!.id,
      receiverId: contact.databaseId,
      encryptedPayload: encryptedText,
      timestamp: DateTime.now(),
      adapterType: contact.provider == 'Nostr' ? 'nostr'
          : contact.provider == 'Waku' ? 'waku'
          : contact.provider == 'Oxen' ? 'oxen'
          : 'firebase',
    );
    await _addSenderPlugin(contact);
    bool sent = false;
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) debugPrint('[P2P] Direct delivery to ${contact.name}');
    }
    if (!sent) {
      sent = await InboxManager().routeMessage(
          contact.provider, contact.databaseId, contact.databaseId, msg);
      if (!contact.isGroup) unawaited(P2PTransportService.instance.connect(contact.id));
    }

    if (!sent && contact.alternateAddresses.isNotEmpty) {
      final order = [...contact.alternateAddresses];
      order.shuffle();
      order.sort((a, b) =>
          (_deliverySuccessCount[b] ?? 0).compareTo(_deliverySuccessCount[a] ?? 0));
      for (final alt in order) {
        debugPrint('[SmartRouter] Primary failed, trying alternate: $alt');
        sent = await _deliverEncryptedMessage(alt, msg);
        if (sent) {
          debugPrint('[SmartRouter] Delivered via alternate: $alt');
          _deliverySuccessCount[alt] = (_deliverySuccessCount[alt] ?? 0) + 1;
          unawaited(_saveDeliveryStats());
          break;
        }
      }
    }

    if (!sent && _lanSender != null) {
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

  Future<void> sendFile(Contact contact, Uint8List bytes, String name) async {
    if (_identity == null) return;

    final totalChunks = bytes.length <= 512 * 1024
        ? 1
        : (bytes.length / (512 * 1024)).ceil();

    if (totalChunks == 1) {
      await sendMessage(contact, MediaService.chunkPayloads(bytes, name).first);
      return;
    }

    final isGroup = contact.isGroup;
    final room = _repo.getOrCreateRoom(contact);
    final msgId = _uuid.v4();

    final displayPayload = jsonEncode({'t': 'file', 'n': name, 'sz': bytes.length, 'd': ''});
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
    final localTtl = _repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _repo.scheduleTtlDelete(contact, localMsg, localTtl, onDeleted: () { if (!_disposed) notifyListeners(); });
    notifyListeners();

    bool allSent = true;
    _repo.setUploadProgress(msgId, 0.0);
    int i = 0;
    String? fileId;
    try {
      for (final chunk in MediaService.chunkIterable(bytes, name)) {
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

    final idx = room.messages.indexWhere((m) => m.id == msgId);
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
      final memberContact = _contacts.contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == memberId, orElse: () => null);
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
    await deleteLocalMessage(contact, message.id);
    if (contact.isGroup && message.senderId == _selfId) {
      unawaited(_broadcaster.broadcastGroupDelete(
          contact, message.id, _contacts.contacts));
    }
  }

  void _handleRemoteDelete(String fromId, String msgId, {String? groupId}) {
    if (groupId != null) {
      final room = _repo.getRoomForContact(groupId);
      if (room == null) return;
      final idx = room.messages.indexWhere((m) => m.id == msgId);
      if (idx == -1) return;
      Contact? sender;
      for (final c in _contacts.contacts) {
        if (c.databaseId == fromId || c.databaseId.split('@').first == fromId) {
          sender = c;
          break;
        }
      }
      final senderId = sender?.id ?? fromId;
      if (room.messages[idx].senderId != senderId) return;
      room.messages.removeAt(idx);
      unawaited(LocalStorageService().deleteMessage(room.contact.storageKey, msgId));
      _scheduleNotify();
    } else {
      for (final room in _repo.rooms) {
        if (room.contact.isGroup) continue;
        final cId = room.contact.databaseId;
        if (cId != fromId && cId.split('@').first != fromId) continue;
        final idx = room.messages.indexWhere((m) => m.id == msgId);
        if (idx != -1) {
          room.messages.removeAt(idx);
          unawaited(LocalStorageService().deleteMessage(room.contact.storageKey, msgId));
          _scheduleNotify();
          break;
        }
      }
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
  }

  Future<void> clearRoomHistory(Contact contact) =>
      _repo.clearRoomHistory(contact, onChanged: () { if (!_disposed) notifyListeners(); });

  Future<void> retryMessage(Contact contact, Message message) async {
    if (message.status != 'failed') return;
    final room = _repo.getRoomForContact(contact.id);
    if (room == null) return;
    room.messages.removeWhere((m) => m.id == message.id);
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
        final idx = room.messages.indexWhere((m) => m.id == failedMsg.id);
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

  void _handleReadReceipt(String fromId) {
    bool changed = false;
    for (final room in _repo.rooms) {
      final contactId = room.contact.databaseId;
      if (contactId != fromId && contactId.split('@').first != fromId) continue;
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.status == 'sent' || m.status == 'delivered') {
          room.messages[i] = m.copyWith(status: 'read');
          unawaited(LocalStorageService().saveMessage(room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
        }
      }
    }
    if (changed) _scheduleNotify();
  }

  void _handleDeliveryAck(String fromId, String msgId, {String? groupId}) {
    bool changed = false;
    final roomsToSearch = groupId != null
        ? [if (_repo.getRoomForContact(groupId) != null) _repo.getRoomForContact(groupId)!]
        : _repo.rooms.where((r) {
            final cId = r.contact.databaseId;
            return cId == fromId || cId.split('@').first == fromId;
          }).toList();

    String resolvedId = fromId;
    if (groupId != null) {
      for (final c in _contacts.contacts) {
        if (c.databaseId == fromId || c.databaseId.split('@').first == fromId) {
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
          final newStatus = m.status == 'sent' ? 'delivered' : m.status;
          room.messages[i] = m.copyWith(status: newStatus, deliveredTo: newDeliveredTo);
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
          break;
        }
        if (m.status == 'sent') {
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

  Future<void> broadcastStatus(UserStatus status) =>
      _broadcaster.broadcastStatus(status, _contacts.contacts);

  Future<void> broadcastProfile(String name, String about, {String avatarB64 = ''}) =>
      _broadcaster.broadcastProfile(name, about, _contacts.contacts, avatarB64: avatarB64);

  Future<void> broadcastAddressUpdate() =>
      _broadcaster.broadcastAddressUpdate(_contacts.contacts, _selfId, _allAddresses);

  Future<void> broadcastWorkingRelays() =>
      _broadcaster.broadcastWorkingRelays(_contacts.contacts);

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
    final existing = _contacts.contacts.cast<Contact?>()
        .firstWhere((c) => c?.isGroup == true && c?.id == invite.groupId,
            orElse: () => null);
    if (existing != null) return;
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
        final memberContact = _contacts.contacts.cast<Contact?>()
            .firstWhere((c) => c?.id == memberId, orElse: () => null);
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
    _scheduleNotify();

    if (contact.isGroup) {
      for (final memberId in contact.members) {
        final memberContact = _contacts.contacts.cast<Contact?>()
            .firstWhere((c) => c?.id == memberId, orElse: () => null);
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
    final idx = room.messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;
    if (room.messages[idx].senderId != _identity!.id) return;
    final updated = room.messages[idx].copyWith(encryptedPayload: newText, isEdited: true);
    room.messages[idx] = updated;
    await LocalStorageService().saveMessage(storageKey, updated.toJson());
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
    final before = existing.length;
    for (final r in relays) {
      if (r.startsWith('wss://') || r.startsWith('ws://')) existing.add(r);
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
      final dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
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
          contact.provider == 'Waku' ? 'waku' : contact.provider == 'Oxen' ? 'oxen' : 'firebase',
      isRead: true,
      status: 'scheduled',
      scheduledAt: scheduledAt,
    );
    room.messages.add(placeholder);
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
    if (room != null) room.messages.removeWhere((m) => m.id == msg.id);
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
    if (room != null) room.messages.removeWhere((m) => m.id == msgId);
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
      for (final fid in _chunkAssembler.activeTransferIds) {
        if (!_chunkAssembler.isStalled(fid)) continue;
        final missing = _chunkAssembler.getMissingChunks(fid);
        if (missing == null || missing.isEmpty) continue;
        for (final contact in _contacts.contacts) {
          unawaited(_sendSignalTo(contact, 'chunk_req', {
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
    debugPrint('[Resume] Re-sending ${missingIndices.length} chunks for $fileId to $recipientId');
    final allChunks = MediaService.chunkIterable(pending.bytes, pending.name).toList();
    for (final idx in missingIndices) {
      if (idx < 0 || idx >= allChunks.length) continue;
      await _sendToContact(pending.contact, allChunks[idx]);
    }
  }

  // ── P2P helpers ───────────────────────────────────────────────────────────

  void _handleP2PMessage(String contactId, String encryptedPayload) {
    final contact = _contacts.contacts.cast<Contact?>()
        .firstWhere((c) => c?.id == contactId, orElse: () => null);
    if (contact == null) return;
    _handleIncomingMessages([
      Message(
        id: _uuid.v4(),
        senderId: contact.databaseId,
        receiverId: _selfId,
        encryptedPayload: encryptedPayload,
        timestamp: DateTime.now(),
        adapterType: 'p2p',
      ),
    ]);
  }

  // ── SmartRouter delivery stats ────────────────────────────────────────────

  Future<void> _loadDeliveryStats() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_kDeliveryStatsKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _deliverySuccessCount.clear();
      map.forEach((k, v) {
        if (v is int) _deliverySuccessCount[k] = v;
      });
    } catch (e) {
      debugPrint('[SmartRouter] Failed to load delivery stats: $e');
    }
  }

  Future<void> _saveDeliveryStats() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
          _kDeliveryStatsKey, jsonEncode(Map<String, int>.from(_deliverySuccessCount)));
    } catch (e) {
      debugPrint('[SmartRouter] Failed to save delivery stats: $e');
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
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
    _deliveryStatsHalveTimer?.cancel();
    _stallCheckTimer?.cancel();
    _typingStreamCtrl.close();
    _incomingCallController.close();
    _incomingGroupCallController.close();
    _signalStreamController.close();
    _newMsgController.close();
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
    _cachedWakuSender = null;
    _cachedOxenSender = null;
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
