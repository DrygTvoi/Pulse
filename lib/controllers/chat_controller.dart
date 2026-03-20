import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
import '../services/signal_dispatcher.dart';
import '../models/contact_repository.dart';

enum ConnectionStatus { disconnected, connecting, connected }

class ChatController extends ChangeNotifier {
  static final ChatController _instance = ChatController._create(ContactManager());
  factory ChatController() => _instance;
  ChatController._create(this._contacts);

  /// Constructor for unit testing — pass a [MockContactRepository].
  @visibleForTesting
  factory ChatController.forTesting(IContactRepository contacts) =>
      ChatController._create(contacts);

  final IContactRepository _contacts;

  Identity? _identity;
  String _selfId = ''; // adapter-specific ID used as senderId in outgoing messages
  final Map<String, ChatRoom> _chatRooms = {}; // Key is Contact ID
  final SignalService _signalService = SignalService();
  StreamSubscription<void>? _bundleRefreshSub;
  final List<StreamSubscription> _messageSubs = [];
  final List<StreamSubscription> _signalSubs = [];
  final List<StreamSubscription> _healthSubs = [];
  final List<StreamSubscription> _dispatcherSubs = [];
  final Map<String, bool> _adapterHealth = {}; // addr → isHealthy
  List<String> _allAddresses = [];
  SignalDispatcher? _signalDispatcher;

  // Emits (from: oldAddr, to: newAddr) when automatic failover occurs.
  final StreamController<({String from, String to})> _failoverCtrl =
      StreamController.broadcast();
  Stream<({String from, String to})> get failoverEvents => _failoverCtrl.stream;

  // ── LAN fallback ──────────────────────────────────────────────────────────
  LanInboxReader?  _lanReader;
  LanMessageSender? _lanSender;
  bool _lanModeActive = false;

  /// True when all internet adapters are unreachable and LAN is being used.
  bool get lanModeActive => _lanModeActive;

  /// Whether the LAN adapter is enabled (persisted in SharedPreferences).
  static Future<bool> getLanModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLanModeEnabled) ?? true;
  }

  /// Enable or disable the LAN adapter and reconnect the inbox.
  Future<void> setLanModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLanModeEnabled, enabled);
    await reconnectInbox();
  }

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  // Emits every incoming message so UI can show in-app banners
  final StreamController<({String contactId, Message message})> _newMsgController =
      StreamController.broadcast();
  Stream<({String contactId, Message message})> get newMessages => _newMsgController.stream;

  // Emits contact name + databaseId when their Signal identity key changes (possible reinstall / MITM).
  final StreamController<({String contactName, String contactId})> _keyChangeCtrl = StreamController.broadcast();
  Stream<({String contactName, String contactId})> get keyChangeWarnings => _keyChangeCtrl.stream;

  // Emits a display message when an incoming signal fails MAC/integrity check
  // (possible tamper or malicious relay injection).
  final StreamController<String> _tamperWarningCtrl = StreamController.broadcast();
  Stream<String> get tamperWarnings => _tamperWarningCtrl.stream;

  // SmartRouter: per-address delivery success counts (in-memory + persisted).
  // Halved every 24h to de-weight stale successes.
  final Map<String, int> _deliverySuccessCount = {};
  static const _kDeliveryStatsKey = 'delivery_stats_v1';
  Timer? _deliveryStatsHalveTimer;

  // File transfer resume: map of fileId → (contact, bytes, name) for active sends.
  // Cleared after 10 min to avoid unbounded growth.
  final Map<String, ({Contact contact, Uint8List bytes, String name})> _pendingSends = {};
  // Stall detection: periodic timer checking for stalled receiver-side transfers.
  Timer? _stallCheckTimer;

  // Per-room TTL cache (seconds, 0 = off). Populated in loadRoomHistory().
  final Map<String, int> _chatTtls = {};

  // Pagination: cursor-based — track oldest loaded timestamp per room.
  static const int _historyPageSize = 50;
  final Map<String, int> _historyLoaded = {};  // loaded count
  final Map<String, int?> _oldestTimestamp = {}; // cursor: oldest msg timestamp per room
  final Map<String, bool> _historyFull = {};   // true when all history is in memory
  final Map<String, bool> _loadingMoreHistory = {};

  bool hasMoreHistory(String contactId) => _historyFull[contactId] != true;
  bool isLoadingMoreHistory(String contactId) => _loadingMoreHistory[contactId] == true;

  // Reactions: roomStorageKey → msgId → Set<'emoji_senderId'>
  final Map<String, Map<String, Set<String>>> _reactions = {};

  // Upload progress: msgId → 0.0..1.0
  final Map<String, double> _uploadProgress = {};
  double? getUploadProgress(String msgId) => _uploadProgress[msgId];

  // Online status
  final Map<String, DateTime> _lastSeen = {};
  Timer? _heartbeatTimer;

  // Auto-retry timers keyed by message ID — cancelled if contact removed or retry succeeds.
  final Map<String, Timer> _retryTimers = {};
  // TTL deletion timers keyed by message ID — cancelled when message deleted early.
  final Map<String, Timer> _ttlTimers = {};
  // PQC: in-memory cache of contacts' Kyber-1024 public keys (contactId → pk).
  // Populated when building a Signal session; persisted to SharedPreferences.
  final Map<String, Uint8List> _contactKyberPks = {};

  // Chunk assembly for multi-part file transfers
  final _chunkAssembler = ChunkAssembler();
  int getChatTtlCached(String contactId) => _chatTtls[contactId] ?? 0;

  // Global dedup: prevents the same message ID from being processed twice
  // across different transports (e.g. LAN + Nostr delivering same message).
  // Capped at 10k entries to bound memory; oldest cleared on overflow.
  // LinkedHashSet preserves insertion order for FIFO sliding window dedup.
  // ignore: prefer_collection_literals
  final _seenMsgIds = LinkedHashSet<String>();

  // Per-sender rate limiters to prevent spam flooding.
  // Messages: 30 burst, 1 per 2s sustained. Signals: 20 burst, 1 per 3s sustained.
  final _msgRateLimiter = RateLimiter(maxTokens: 30, refillInterval: Duration(seconds: 2));
  final _sigRateLimiter = RateLimiter(maxTokens: 20, refillInterval: Duration(seconds: 3));

  // Emits contact name when a message had to be sent unencrypted (E2EE session missing).
  final StreamController<String> _e2eeFailCtrl = StreamController.broadcast();
  Stream<String> get e2eeFailures => _e2eeFailCtrl.stream;

  // Emits a contactId when that contact's status is updated.
  final StreamController<String> _statusUpdatesCtrl = StreamController.broadcast();
  Stream<String> get statusUpdates => _statusUpdatesCtrl.stream;

  Identity? get identity => _identity;

  List<String> get allAddresses => List.unmodifiable(_allAddresses);

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

  ChatRoom? getRoomForContact(String contactId) => _chatRooms[contactId];

  /// Load persisted message history for a contact's room (last [_historyPageSize] messages).
  /// Called by ChatScreen on open so history is always available.
  Future<void> loadRoomHistory(Contact contact) async {
    // Groups use contact.id as storage key; direct contacts use databaseId
    final storageKey = contact.isGroup ? contact.id : contact.databaseId;
    final total = await LocalStorageService().countMessages(storageKey);
    final stored = await LocalStorageService().loadMessagesPage(
      storageKey,
      pageSize: _historyPageSize,
    );
    _historyLoaded[contact.id] = stored.length;
    _historyFull[contact.id] = stored.length >= total;
    // Track oldest loaded timestamp for cursor-based pagination.
    if (stored.isNotEmpty) {
      final firstTs = stored.first['timestamp'];
      if (firstTs is int) {
        _oldestTimestamp[contact.id] = firstTs;
      } else if (firstTs is String) {
        _oldestTimestamp[contact.id] =
            DateTime.tryParse(firstTs)?.millisecondsSinceEpoch;
      }
    }
    if (stored.isEmpty) return;

    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: storageKey,
        contact: contact,
        messages: [],
        adapterType: contact.isGroup ? 'group' : contact.provider,
        adapterConfig: {},
        updatedAt: DateTime.now(),
      );
    }
    final room = _chatRooms[contact.id]!;
    for (final m in stored) {
      final msg = Message.tryFromJson(m);
      if (msg == null) continue;
      if (!room.messages.any((x) => x.id == msg.id)) {
        room.messages.add(msg);
      }
    }
    room.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Fix messages stuck in 'sending' from a crashed session
    bool hadStuck = false;
    for (int i = 0; i < room.messages.length; i++) {
      if (room.messages[i].status == 'sending') {
        room.messages[i] = room.messages[i].copyWith(status: 'failed');
        unawaited(LocalStorageService().saveMessage(storageKey, room.messages[i].toJson()));
        hadStuck = true;
      }
    }
    if (hadStuck) notifyListeners();
    // Load reactions for this room
    await _loadReactions(storageKey);

    // Load TTL and purge expired messages
    final prefs = await SharedPreferences.getInstance();
    final ttlSeconds = prefs.getInt('chat_ttl_${contact.id}') ?? 0;
    _chatTtls[contact.id] = ttlSeconds;
    if (ttlSeconds > 0) {
      final now = DateTime.now();
      room.messages.removeWhere((m) {
        if (m.timestamp.add(Duration(seconds: ttlSeconds)).isBefore(now)) {
          unawaited(LocalStorageService().deleteMessage(storageKey, m.id));
          return true;
        }
        return false;
      });
      for (final m in room.messages) {
        _scheduleTtlDelete(contact, m, ttlSeconds);
      }
    }
    notifyListeners();
  }

  /// Load the next page of older messages for a room (triggered by scroll-to-top).
  /// Uses cursor-based pagination (timestamp < oldest loaded) for O(log N) lookups.
  Future<void> loadMoreHistory(Contact contact) async {
    if (_historyFull[contact.id] == true) return;
    if (_loadingMoreHistory[contact.id] == true) return;

    _loadingMoreHistory[contact.id] = true;
    notifyListeners();

    try {
      final storageKey = contact.isGroup ? contact.id : contact.databaseId;
      final cursor = _oldestTimestamp[contact.id];
      final older = await LocalStorageService().loadMessagesPage(
        storageKey,
        pageSize: _historyPageSize,
        beforeTimestamp: cursor,
      );

      final room = _chatRooms[contact.id];
      if (room != null && older.isNotEmpty) {
        // Prepend older messages in timestamp order
        final toInsert = older
            .map((m) => Message.tryFromJson(m))
            .whereType<Message>()
            .where((m) => !room.messages.any((x) => x.id == m.id))
            .toList();
        room.messages.insertAll(0, toInsert);
        _historyLoaded[contact.id] =
            (_historyLoaded[contact.id] ?? 0) + older.length;
        // Update cursor to the oldest message in this batch.
        final firstTs = older.first['timestamp'];
        if (firstTs is int) {
          _oldestTimestamp[contact.id] = firstTs;
        } else if (firstTs is String) {
          _oldestTimestamp[contact.id] =
              DateTime.tryParse(firstTs)?.millisecondsSinceEpoch;
        }
      }
      // Mark full when we got fewer than a full page (no more older messages).
      _historyFull[contact.id] = older.length < _historyPageSize;
    } finally {
      _loadingMoreHistory[contact.id] = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    sentryBreadcrumb('ChatController.initialize() started', category: 'lifecycle');
    await LocalStorageService().init();
    unawaited(_restoreScheduledTtls());
    _connectionStatus = ConnectionStatus.connecting;
    final prefs = await SharedPreferences.getInstance();
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
        // Validate stored Firebase URL — guard against legacy GitHub tokens or empty config
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
            _identity!.adapterConfig.remove('token');
            final prefs2 = await SharedPreferences.getInstance();
            await prefs2.setString('user_identity', jsonEncode(_identity!.toJson()));
            _connectionStatus = ConnectionStatus.disconnected;
            notifyListeners();
            return;
          }
        }
      case 'nostr':
        providerName = 'Nostr';
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
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
            notifyListeners();
            return;
          }
        } else {
          _selfId = '${_identity!.id}@$relay';
        }
      case 'waku':
        providerName = 'Waku';
        {
          final prefs = await SharedPreferences.getInstance();
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
          final prefs = await SharedPreferences.getInstance();
          final nodeUrl = prefs.getString('oxen_node_url') ?? '';
          apiKey = nodeUrl;
          dbId = _selfId;
        }
      default:
        providerName = 'Firebase';
        dbId = _identity!.adapterConfig['dbId'] ?? _identity!.id;
        _selfId = dbId;
    }

    await InboxManager().configureSelf(providerName, apiKey, dbId);
    _connectionStatus = ConnectionStatus.connected;
    sentryBreadcrumb('Adapter connected: $providerName', category: 'adapter');
    notifyListeners();

    // Load delivery stats and start 24h halving timer.
    unawaited(_loadDeliveryStats());
    _deliveryStatsHalveTimer?.cancel();
    _deliveryStatsHalveTimer = Timer.periodic(const Duration(hours: 24), (_) {
      _deliverySuccessCount.updateAll((_, v) => v ~/ 2);
      unawaited(_saveDeliveryStats());
    });

    // Republish Signal bundle whenever a preKey is consumed (new contact established session).
    _signalService.onPreKeyConsumed = () => unawaited(_republishKeys());

    // Re-publish bundle to ALL transports when prekeys are exhausted and regenerated.
    _bundleRefreshSub?.cancel();
    _bundleRefreshSub = _signalService.onBundleRefresh.listen((_) {
      debugPrint('[Chat] PreKeys exhausted — re-publishing bundle to all transports');
      unawaited(_republishAllKeys());
    });

    // Surface prekey exhaustion attack warnings via e2eeFailures stream.
    _signalSubs.add(_signalService.onPreKeyExhaustionWarning.listen((msg) {
      if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add('⚠️ $msg');
    }));

    // Publish Signal public keys to own inbox (once per adapter + selfId combination)
    unawaited(_maybePublishOwnKeys());

    // Restore scheduled messages from previous session
    unawaited(_restoreScheduledMessages());

    // Start heartbeat timer for online status
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) => unawaited(_sendHeartbeats()));

    _allAddresses = [myAddress];
    _adapterHealth.clear();
    for (final s in _healthSubs) { s.cancel(); }
    _healthSubs.clear();

    // Initialize (or re-initialize) the signal dispatcher.
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
        _allAddresses.add(addr);
        _adapterHealth[addr] = true;
        _healthSubs.add(reader.healthChanges.listen((h) => _onAdapterHealthChange(addr, h)));
      }
      unawaited(_publishKeysToAdapter(cfg['provider']!, cfg['apiKey']!, cfg['selfId'] ?? ''));
    }

    // ── LAN fallback adapter (opt-in, default on) ─────────────────────────
    _lanReader?.close();
    _lanSender?.close();
    _lanReader = null;
    _lanSender = null;
    final lanEnabled = (await SharedPreferences.getInstance()).getBool(_kLanModeEnabled) ?? true;
    if (lanEnabled) {
      _lanReader = LanInboxReader();
      _lanSender = LanMessageSender();
      await _lanReader!.initializeReader('', _selfId);
      await _lanSender!.initializeSender(_selfId);
      _messageSubs.add(_lanReader!.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(_lanReader!.listenForSignals().listen(_signalDispatcher!.dispatch));
    }

    // Monitor internet; flip lanModeActive flag when status changes.
    // Also detect network changes (WiFi↔cellular, VPN) and re-probe.
    NetworkMonitor.instance.startMonitoring(
      onChanged: (isAvailable) {
        if (_lanModeActive == isAvailable) {
          _lanModeActive = !isAvailable;
          notifyListeners();
        }
      },
      onNetworkChanged: () {
        debugPrint('[Chat] Network changed — re-probing relays');
        unawaited(ConnectivityProbeService.instance.forceProbe());
        // Reconnect after probe finds new relays, then flush failed messages
        unawaited(ConnectivityProbeService.instance.firstRunDone.then((_) {
          reconnectInbox();
          // Delay flush slightly to let new connections stabilize
          Future.delayed(const Duration(seconds: 3), _flushFailedMessages);
        }));
      },
    );

    // ── P2P DataChannel transport ─────────────────────────────────────────────
    // Signaling goes over the contact's normal adapter (Firebase/Nostr/Waku).
    // Once the DataChannel opens, all subsequent messages bypass any server.
    P2PTransportService.instance.onSendSignal = (contactId, type, payload) {
      final contact = _contacts.contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == contactId, orElse: () => null);
      if (contact != null) unawaited(_sendP2PSignal(contact, type, payload));
    };
    _messageSubs.add(P2PTransportService.instance.messageStream.listen((evt) {
      _handleP2PMessage(evt.contactId, evt.payload);
    }));

    notifyListeners();
  }

  Future<List<Map<String, String>>> _loadSecondaryAdapters() async {
    final prefs = await SharedPreferences.getInstance();
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

  Future<void> _publishKeysToAdapter(String provider, String apiKey, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final flag = 'signal_keys_published_${provider.toLowerCase()}_$selfId';
      if (prefs.getBool(flag) == true) return;
      final bundle = await _signalService.getPublicBundle();
      if (PqcService().isInitialized) {
        bundle['kyberPublicKey'] = PqcService().publicKey.toList();
      }
      MessageSender sender;
      if (provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (provider == 'Nostr') {
        try {
          final cfg = jsonDecode(apiKey);
          if ((cfg['privkey'] as String? ?? '').isEmpty) return;
        } catch (_) { return; }
        sender = NostrMessageSender();
      } else if (provider == 'Waku') {
        sender = WakuMessageSender();
      } else if (provider == 'Oxen') {
        sender = OxenMessageSender();
      } else {
        return;
      }
      await sender.initializeSender(apiKey);
      await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
      await prefs.setBool(flag, true);
      debugPrint('[ChatController] Published Signal keys to secondary $provider/$selfId');
    } catch (e) {
      debugPrint('[ChatController] Secondary key publish failed: $e');
    }
  }

  // ── Sender factory ────────────────────────────────────────────────────────
  //
  // Builds a (sender, apiKey) pair for a contact's transport provider.
  // Returns null for unknown providers. Centralises the duplicated
  // sender-init boilerplate that was previously copy-pasted into every
  // broadcast method.

  Future<({MessageSender sender, String apiKey})?> _buildSenderFor(Contact contact) async {
    switch (contact.provider) {
      case 'Firebase':
        final token = _identity!.adapterConfig['token'] ?? '';
        return (sender: FirebaseInboxSender(), apiKey: token);
      case 'Nostr':
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
        return (sender: NostrMessageSender(),
                apiKey: jsonEncode({'privkey': privkey, 'relay': relay}));
      case 'Waku':
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        return (sender: WakuMessageSender(),
                apiKey: jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
      case 'Oxen':
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('oxen_node_url') ?? '';
        return (sender: OxenMessageSender(), apiKey: nodeUrl);
      default:
        return null;
    }
  }

  /// Centralized helper: init sender for contact's provider and send a signal.
  /// Replaces 8+ duplicated sender-init-then-sendSignal blocks.
  /// For non-Nostr transports, adds HMAC-SHA256 signature using ECDH shared secret
  /// to prevent signal forgery (addr_update, bundle injection, etc.).
  Future<void> _sendSignalTo(Contact contact, String type, Map<String, dynamic> payload) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final built = await _buildSenderFor(contact);
      if (built == null) return;
      await built.sender.initializeSender(built.apiKey);

      // Sign for non-Nostr transports (Nostr signs natively via Schnorr).
      var signedPayload = payload;
      if (contact.provider != 'Nostr') {
        signedPayload = await _signPayload(contact, type, payload);
      }

      await built.sender.sendSignal(
          contact.databaseId, contact.databaseId, _selfId, type, signedPayload);
    } catch (e) {
      debugPrint('[ChatController] Signal $type to ${contact.name} failed: $e');
    }
  }

  /// Compute HMAC-SHA256 over signal payload using ECDH shared secret.
  Future<Map<String, dynamic>> _signPayload(
      Contact contact, String type, Map<String, dynamic> payload) async {
    try {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      if (privkey.isEmpty) return payload;
      // Derive recipient pubkey from contact's databaseId.
      final recipientPub = _extractPubkey(contact.databaseId);
      if (recipientPub == null) return payload;

      final senderPub = deriveNostrPubkeyHex(privkey);
      // Canonical JSON for HMAC: sorted type + payload.
      final canonical = jsonEncode({'t': type, 'p': payload});
      final hmac = signSignalPayload(privkey, recipientPub, canonical);
      return {...payload, '_sig': hmac, '_spk': senderPub};
    } catch (e) {
      debugPrint('[ChatController] Signal sign error: $e');
      return payload; // graceful fallback — unsigned
    }
  }

  /// Extract Nostr pubkey from any address format.
  /// Nostr: pubkey@wss://relay → pubkey
  /// Oxen: 66-char hex → derive from stored contact key
  /// Firebase/Waku: userId@url → look up stored contact pubkey
  String? _extractPubkey(String databaseId) {
    // Try Nostr format: 64-hex pubkey @ relay
    final atWss = databaseId.indexOf('@wss://');
    final atWs = databaseId.indexOf('@ws://');
    final atIdx = atWss != -1 ? atWss : (atWs != -1 ? atWs : -1);
    if (atIdx != -1) {
      final pub = databaseId.substring(0, atIdx);
      if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pub)) return pub;
    }
    // 64-hex pubkey standalone
    if (RegExp(r'^[0-9a-f]{64}$').hasMatch(databaseId)) return databaseId;
    // Look up stored contact Nostr pubkey
    final contact = _contacts.contacts.firstWhere(
      (c) => c.databaseId == databaseId,
      orElse: () => Contact(id: '', name: '', databaseId: '', provider: '', publicKey: ''),
    );
    // Check alternateAddresses for Nostr address
    for (final addr in [contact.databaseId, ...contact.alternateAddresses]) {
      final at = addr.indexOf('@wss://');
      if (at != -1) {
        final pub = addr.substring(0, at);
        if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pub)) return pub;
      }
    }
    return null;
  }

  /// Register a sender plugin with InboxManager for [contact]'s provider.
  Future<void> _addSenderPlugin(Contact contact) async {
    final built = await _buildSenderFor(contact);
    if (built != null) {
      await InboxManager().addSenderPlugin(contact.provider, built.sender, built.apiKey);
    }
  }

  // ── Typing indicators ─────────────────────────────────────────────────────
  final Map<String, Timer> _typingTimers = {};
  final Map<String, bool> _isTypingMap = {};
  final StreamController<String> _typingStreamCtrl = StreamController.broadcast();

  /// Emits a contactId whenever that contact's typing state changes.
  Stream<String> get typingUpdates => _typingStreamCtrl.stream;

  bool isContactTyping(String contactId) => _isTypingMap[contactId] ?? false;

  Future<void> sendTypingSignal(Contact contact) =>
      _sendSignalTo(contact, 'typing', {'from': _selfId});
  // ─────────────────────────────────────────────────────────────────────────

  /// Broadcast our own status to all non-group contacts.
  Future<void> broadcastStatus(UserStatus status) async {
    if (_identity == null || _selfId.isEmpty) return;
    for (final contact in _contacts.contacts) {
      if (contact.isGroup) continue;
      await _sendSignalTo(contact, 'status_update', status.toJson());
    }
  }

  // ── P2P relay exchange ─────────────────────────────────────────────────────

  static const _peerRelaysKey = 'peer_relays_v1';

  /// Returns all peer-learned relay URLs (from contacts who shared theirs).
  static Future<List<String>> loadPeerRelays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_peerRelaysKey) ?? [];
  }

  /// Saves newly learned relay URLs from a peer, deduplicating.
  static Future<void> savePeerRelays(List<String> relays) async {
    if (relays.isEmpty) return;
    final prefs    = await SharedPreferences.getInstance();
    final existing = Set<String>.from(prefs.getStringList(_peerRelaysKey) ?? []);
    final before   = existing.length;
    for (final r in relays) {
      if (r.startsWith('wss://') || r.startsWith('ws://')) existing.add(r);
    }
    if (existing.length > before) {
      await prefs.setStringList(_peerRelaysKey, existing.toList());
      debugPrint('[P2P] Learned ${existing.length - before} new relay(s) from peer');
    }
  }

  /// Sends our currently working relays to all non-group contacts.
  /// Called after connectivity probe completes so we share fresh data.
  Future<void> broadcastWorkingRelays() async {
    if (_identity == null || _selfId.isEmpty) return;
    final probe  = ConnectivityProbeService.instance.lastResult;
    final relays = [...probe.nostrRelays, ...probe.torNostrRelays];
    if (relays.isEmpty) return;
    final targets = _contacts.contacts
        .where((c) => !c.isGroup && (c.provider == 'Nostr' || c.provider == 'Oxen'))
        .toList();
    await Future.wait(targets.map((c) => _sendSignalTo(c, 'relay_exchange', {'relays': relays})));
    debugPrint('[P2P] Shared ${relays.length} relay(s) with ${targets.length} contact(s)');
  }

  /// Broadcast own profile (name + about) to all non-group contacts.
  Future<void> broadcastProfile(String name, String about, {String avatarB64 = ''}) async {
    if (_identity == null || _selfId.isEmpty) return;
    final payload = <String, dynamic>{'name': name, 'about': about};
    if (avatarB64.isNotEmpty) payload['avatar'] = avatarB64;
    final targets = _contacts.contacts.where((c) => !c.isGroup).toList();
    await Future.wait(targets.map((c) => _sendSignalTo(c, 'profile_update', payload)));
  }

  /// Broadcast our current addresses to all non-group contacts.
  /// Called on startup and whenever the user changes their transport settings.
  Future<void> broadcastAddressUpdate() async {
    if (_identity == null || _selfId.isEmpty || _allAddresses.isEmpty) return;
    final payload = <String, dynamic>{'primary': _selfId, 'all': _allAddresses};
    final targets = _contacts.contacts.where((c) => !c.isGroup).toList();
    await Future.wait(targets.map((c) => _sendSignalTo(c, 'addr_update', payload)));
  }

  /// Called when an adapter reports a health change (healthy=true/false).
  void _onAdapterHealthChange(String addr, bool healthy) {
    _adapterHealth[addr] = healthy;
    sentryBreadcrumb('Adapter health: ${healthy ? "healthy" : "unhealthy"}', category: 'adapter');
    debugPrint('[Failover] $addr → ${healthy ? "healthy" : "UNHEALTHY"}');
    if (!healthy && addr == _selfId) {
      // Primary adapter failed — find the first healthy secondary.
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
    notifyListeners();
  }

  /// Send a group read receipt for a specific message back to its sender.
  Future<void> _sendGroupReadReceipt(Contact senderContact, String groupId, String msgId) =>
      _sendSignalTo(senderContact, 'msg_read', {'from': _selfId, 'groupId': groupId, 'msgId': msgId});

  /// Called when opening a group chat — sends read receipts to each original sender.
  Future<void> markGroupMessagesRead(Contact group) async {
    if (!group.isGroup || _identity == null || _selfId.isEmpty) return;
    final room = _chatRooms[group.id];
    if (room == null) return;
    for (final msg in List.of(room.messages)) {
      if (msg.senderId == _selfId || msg.senderId.isEmpty) continue;
      // Find sender contact
      Contact? senderContact;
      for (final c in _contacts.contacts) {
        if (c.databaseId == msg.senderId ||
            c.databaseId.split('@').first == msg.senderId) {
          senderContact = c;
          break;
        }
      }
      if (senderContact == null) continue;
      unawaited(_sendGroupReadReceipt(senderContact, group.id, msg.id));
    }
  }

  // A StreamController to emit incoming 1-on-1 calls to the UI layer
  final StreamController<Map<String, dynamic>> _incomingCallController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingCalls => _incomingCallController.stream;

  // Incoming group calls: payload carries groupId (unencrypted) for routing
  final StreamController<Map<String, dynamic>> _incomingGroupCallController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingGroupCalls => _incomingGroupCallController.stream;

  // A StreamController to broadcast all signals (answers, candidates) for active calls
  final StreamController<Map<String, dynamic>> _signalStreamController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get signalStream => _signalStreamController.stream;

  /// Verify HMAC-SHA256 signature on an incoming signal payload.
  Future<bool> _verifySignalSignature(
      String type, Map<String, dynamic> payload, String hmac, String senderPub) async {
    try {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      if (privkey.isEmpty) return true; // can't verify without own key
      // Reconstruct canonical JSON without _sig and _spk fields.
      final cleanPayload = Map<String, dynamic>.from(payload)
        ..remove('_sig')
        ..remove('_spk');
      final canonical = jsonEncode({'t': type, 'p': cleanPayload});
      return verifySignalPayload(privkey, senderPub, canonical, hmac);
    } catch (e) {
      debugPrint('[Chat] Signature verification error: $e');
      return false;
    }
  }

  /// Build the contact-by-databaseId index used by SignalDispatcher.
  Map<String, Contact> _buildContactIndex() {
    final contactByDbId = <String, Contact>{};
    for (final c in _contacts.contacts) {
      contactByDbId[c.databaseId] = c;
      final idPart = c.databaseId.split('@').first;
      if (idPart.isNotEmpty && idPart != c.databaseId) {
        contactByDbId.putIfAbsent(idPart, () => c);
      }
    }
    return contactByDbId;
  }

  /// Create the SignalDispatcher and subscribe to its typed event streams.
  void _initSignalDispatcher() {
    _signalDispatcher?.dispose();
    for (final s in _dispatcherSubs) { s.cancel(); }
    _dispatcherSubs.clear();

    _signalDispatcher = SignalDispatcher(
      allAddressesGetter: () => _allAddresses,
      selfIdGetter: () => _selfId,
      contactIndexBuilder: _buildContactIndex,
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

    // Raw signal → broadcast to active calls
    _dispatcherSubs.add(d.rawSignals.listen((e) {
      if (!_signalStreamController.isClosed) _signalStreamController.add(e.signal);
    }));

    // Incoming 1-on-1 call
    _dispatcherSubs.add(d.incomingCalls.listen((e) {
      if (!_incomingCallController.isClosed) _incomingCallController.add(e.signal);
    }));

    // Incoming group call
    _dispatcherSubs.add(d.incomingGroupCalls.listen((e) {
      if (!_incomingGroupCallController.isClosed) {
        _incomingGroupCallController.add({...e.signal, 'groupId': e.groupId});
      }
    }));

    // Typing indicator
    _dispatcherSubs.add(d.typingEvents.listen((e) {
      final cid = e.contact.id;
      _isTypingMap[cid] = true;
      if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(cid);
      _typingTimers[cid]?.cancel();
      _typingTimers[cid] = Timer(const Duration(seconds: 4), () {
        _isTypingMap.remove(cid);
        if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(cid);
      });
    }));

    // Read receipts (1-on-1)
    _dispatcherSubs.add(d.readReceipts.listen((e) {
      _handleReadReceipt(e.fromId);
    }));

    // Group read receipts
    _dispatcherSubs.add(d.groupReadReceipts.listen((e) {
      _handleGroupReadReceipt(e.fromId, e.groupId, e.msgId);
    }));

    // Delivery ACKs
    _dispatcherSubs.add(d.deliveryAcks.listen((e) {
      _handleDeliveryAck(e.fromId, e.msgId);
    }));

    // TTL updates
    _dispatcherSubs.add(d.ttlUpdates.listen((e) {
      unawaited(setChatTtlSeconds(e.contact, e.seconds, sendSignal: false));
    }));

    // Reactions
    _dispatcherSubs.add(d.reactions.listen((e) {
      _reactions[e.storageKey] ??= {};
      _reactions[e.storageKey]![e.msgId] ??= {};
      final key = '${e.emoji}_${e.from}';
      if (e.remove) {
        _reactions[e.storageKey]![e.msgId]!.remove(key);
        unawaited(LocalStorageService().removeReaction(e.storageKey, e.msgId, e.emoji, e.from));
      } else {
        _reactions[e.storageKey]![e.msgId]!.add(key);
        unawaited(LocalStorageService().addReaction(e.storageKey, e.msgId, e.emoji, e.from));
      }
      notifyListeners();
    }));

    // Edits
    _dispatcherSubs.add(d.edits.listen((e) {
      final room = _chatRooms[e.contact.id];
      if (room != null) {
        final idx = room.messages.indexWhere((m) => m.id == e.msgId);
        if (idx != -1) {
          final storageKey = e.contact.storageKey;
          final updated = room.messages[idx].copyWith(encryptedPayload: e.text, isEdited: true);
          room.messages[idx] = updated;
          unawaited(LocalStorageService().saveMessage(storageKey, updated.toJson()));
          notifyListeners();
        }
      }
    }));

    // Heartbeats (online status)
    _dispatcherSubs.add(d.heartbeats.listen((e) {
      _lastSeen[e.contact.id] = DateTime.now();
      notifyListeners();
    }));

    // Key bundles (sys_keys)
    _dispatcherSubs.add(d.keysEvents.listen((e) async {
      final keyChanged = await _signalService.buildSession(
          e.contact.databaseId, e.payload);
      _cacheContactKyberPk(e.contact.databaseId, e.payload);
      if (keyChanged && !_keyChangeCtrl.isClosed) {
        _keyChangeCtrl.add((contactName: e.contact.name, contactId: e.contact.databaseId));
      }
      // For Oxen contacts: respond with our own keys (in-band key exchange)
      if (e.contact.provider == 'Oxen') {
        unawaited(_publishOxenKeysTo(e.contact));
      }
    }));

    // P2P signaling
    _dispatcherSubs.add(d.p2pEvents.listen((e) {
      unawaited(P2PTransportService.instance.handleSignal(
          e.contact.id, e.type, e.payload));
    }));

    // Relay exchange
    _dispatcherSubs.add(d.relayExchanges.listen((e) async {
      await savePeerRelays(e.relays);
    }));

    // Status updates
    _dispatcherSubs.add(d.statusUpdates.listen((e) async {
      await StatusService.instance.saveContactStatus(e.contact.id, e.status);
      if (!_statusUpdatesCtrl.isClosed) {
        _statusUpdatesCtrl.add(e.contact.id);
      }
    }));

    // Address updates
    _dispatcherSubs.add(d.addrUpdates.listen((e) async {
      final addrContact = e.contact;
      final primary = e.primary;
      final all = e.all;
      // Build updated alternate addresses (old primary + existing alts, deduped)
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
      debugPrint('[ChatController] addr_update: ${addrContact.name} → $primary');
      notifyListeners();
    }));

    // Profile updates
    _dispatcherSubs.add(d.profileUpdates.listen((e) async {
      final profileContact = e.contact;
      bool changed = false;
      Contact updated = profileContact;
      if (e.about != profileContact.bio) {
        updated = updated.copyWith(bio: e.about);
        changed = true;
      }
      if (e.avatarB64.isNotEmpty) {
        // Store avatar in SQLite (separate table to keep contacts JSON small)
        await LocalStorageService().saveAvatar(profileContact.id, e.avatarB64);
        changed = true;
      }
      if (changed) {
        await _contacts.updateContact(updated);
        notifyListeners();
      }
    }));

    // Chunk re-requests
    _dispatcherSubs.add(d.chunkRequests.listen((e) {
      unawaited(_resendMissingChunks(e.fid, e.missing, e.senderId));
    }));
  }

  void _handleGroupReadReceipt(String fromId, String groupId, String msgId) {
    final groupContact = _contacts.contacts.cast<Contact?>()
        .firstWhere((c) => c?.isGroup == true && c?.id == groupId, orElse: () => null);
    if (groupContact == null) return;
    final room = _chatRooms[groupContact.id];
    if (room == null) return;
    final idx = room.messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;
    final msg = room.messages[idx];
    // Resolve fromId (transport databaseId) to contactId (UUID)
    Contact? reader;
    for (final c in _contacts.contacts) {
      if (c.databaseId == fromId || c.databaseId.split('@').first == fromId) {
        reader = c;
        break;
      }
    }
    final readerId = reader?.id ?? fromId;
    if (!msg.readBy.contains(readerId)) {
      room.messages[idx] = msg.copyWith(readBy: [...msg.readBy, readerId]);
      unawaited(LocalStorageService().saveMessage(
          groupContact.storageKey, room.messages[idx].toJson()));
      notifyListeners();
    }
  }

  Future<void> _handleIncomingMessages(List<Message> newMessages) async {
    bool hasUpdates = false;

    // Build a per-batch index for O(1) contact lookup by databaseId / id-prefix.
    // Avoids O(n) contact scans for every message in the batch.
    final contactByDbId = <String, Contact>{};
    for (final c in _contacts.contacts) {
      contactByDbId[c.databaseId] = c;
      final idPart = c.databaseId.split('@').first;
      if (idPart.isNotEmpty && idPart != c.databaseId) {
        contactByDbId.putIfAbsent(idPart, () => c);
      }
    }

    for (var msg in newMessages) {
      try {
      // Global dedup: skip messages we've already processed (cross-transport duplicates).
      if (_seenMsgIds.contains(msg.id)) continue;
      if (_seenMsgIds.length >= 10000) {
        // Sliding window: remove oldest half (LinkedHashSet preserves insertion order).
        final it = _seenMsgIds.iterator;
        int removed = 0;
        final toRemove = <String>[];
        while (it.moveNext() && removed < 5000) {
          toRemove.add(it.current);
          removed++;
        }
        toRemove.forEach(_seenMsgIds.remove);
      }
      _seenMsgIds.add(msg.id);

      // Per-sender rate limiting: don't rate-limit our own messages.
      if (!_allAddresses.contains(msg.senderId) &&
          msg.senderId != _selfId &&
          !_msgRateLimiter.allow(msg.senderId)) {
        debugPrint('[Chat] Rate limited message from: ${msg.senderId}');
        continue;
      }

      // Step 1: Decrypt the payload first so we can read the federation envelope.
      // PQC: unwrap outer Kyber hybrid layer before Signal decryption.
      // If the message was wrapped by the sender, this recovers the inner E2EE||… ciphertext.
      // Falls back gracefully to the original payload on any error (backward compat).
      String rawPayload = msg.encryptedPayload;
      if (rawPayload.startsWith('PQC2||')) {
        try {
          rawPayload = CryptoLayer.unwrap(rawPayload);
        } catch (e) {
          debugPrint('[PQC] Unwrap failed for ${msg.id}: $e');
        }
      }

      String decryptedRaw = rawPayload;
      // Try Signal decryption using the transport-layer senderId as session key.
      // We'll refine the actual contact after unwrapping the envelope.
      if (rawPayload.startsWith('E2EE||')) {
        // Fast path: O(1) lookup via index — covers the common same-adapter case.
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
        // Cross-adapter fallback: try alternate addresses of known contacts.
        // We do NOT brute-force all contacts — that can corrupt Signal ratchet state.
        if (decryptedRaw == rawPayload) {
          final senderPubPrefix = msg.senderId.split('@').first;
          for (final c in _contacts.contacts) {
            // Only try contacts whose alternate addresses match the sender.
            if (c.alternateAddresses.any((a) => a.startsWith(senderPubPrefix))) {
              try {
                decryptedRaw = await _signalService.decryptMessage(c.databaseId, rawPayload);
                break;
              } catch (e) { debugPrint('[Chat] Alt-address decrypt failed for ${c.databaseId}: $e'); }
            }
          }
        }
      }

      // Step 2: Try to unwrap the federation envelope.
      // The envelope contains "_from" (sender's canonical address) and "body" (actual content).
      // This is what makes cross-adapter routing work: Firebase user's address is inside
      // the E2EE payload, not exposed to the transport layer.
      final env = MessageEnvelope.tryUnwrap(decryptedRaw);
      final canonicalSenderId = env?.from ?? msg.senderId; // envelope _from takes priority
      final bodyText = env?.body ?? decryptedRaw;

      // Step 3: Match the contact using canonical sender address (adapter-agnostic).
      // O(1) via the per-batch index; prefix-match handles "userId@relay" → "userId".
      Contact? senderContact = contactByDbId[canonicalSenderId]
          ?? contactByDbId[canonicalSenderId.split('@').first];
      // Fallback: match by transport-layer senderId (backward compat / same-adapter)
      senderContact ??= contactByDbId[msg.senderId]
          ?? contactByDbId[msg.senderId.split('@').first];

      if (senderContact != null) {
        if (!_chatRooms.containsKey(senderContact.id)) {
           _chatRooms[senderContact.id] = ChatRoom(
             id: msg.senderId,
             contact: senderContact,
             messages: [],
             adapterType: senderContact.provider,
             adapterConfig: {},
             updatedAt: DateTime.now(),
           );
        }

        final room = _chatRooms[senderContact.id]!;

        if (!room.messages.any((m) => m.id == msg.id)) {
           try {
             // bodyText is already decrypted; Signal decryption was done above.
             // For old messages without envelope, bodyText == decryptedRaw.
             String displayText = bodyText;

             // Check for group routing: {"_group": "<groupId>", "text": "..."}
             Contact targetContact = senderContact;
             String finalText = displayText;
             String? groupReplyToId, groupReplyToText, groupReplyToSender;
             try {
               final parsed = jsonDecode(displayText) as Map<String, dynamic>;
               final groupId = parsed['_group'] as String?;
               if (groupId != null) {
                 final groupContact = _contacts.contacts.cast<Contact?>()
                     .firstWhere((c) => c?.isGroup == true && c?.id == groupId,
                         orElse: () => null);
                 if (groupContact != null) {
                   targetContact = groupContact;
                   finalText = parsed['text'] as String? ?? displayText;
                   groupReplyToId = parsed['_replyToId'] as String?;
                   groupReplyToText = parsed['_replyToText'] as String?;
                   groupReplyToSender = parsed['_replyToSender'] as String?;
                   if (!_chatRooms.containsKey(groupContact.id)) {
                     _chatRooms[groupContact.id] = ChatRoom(
                       id: groupContact.id, contact: groupContact,
                       messages: [], adapterType: 'group',
                       adapterConfig: {}, updatedAt: DateTime.now(),
                     );
                   }
                 }
               }
             } catch (e) { debugPrint('[Chat] Signal JSON parse (treating as plain text): $e'); } // not JSON — plain message

             // Handle chunked file transfer: buffer chunks and assemble when complete.
             bool skipMessage = false;
             if (MediaService.isChunkPayload(finalText)) {
               final assembled = _chunkAssembler.handleChunk(finalText);
               if (assembled == null) {
                 skipMessage = true; // still waiting for remaining chunks
               } else {
                 finalText = assembled;
               }
             }

             // Reject oversized plain-text messages (64 KB limit).
             // Media payloads can legitimately be large; only plain text is capped.
             if (!skipMessage &&
                 !MediaService.isMediaPayload(finalText) &&
                 !MediaService.isChunkPayload(finalText) &&
                 finalText.length > 65536) {
               debugPrint('[ChatController] Dropped oversized message (${finalText.length} bytes)');
               skipMessage = true;
             }

             if (!skipMessage) {
               final targetRoom = _chatRooms[targetContact.id] ?? room;
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
                 targetRoom.messages.add(decryptedMsg);
                 targetRoom.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                 await LocalStorageService().saveMessage(targetContact.storageKey, decryptedMsg.toJson());
                 hasUpdates = true;
                 if (!_newMsgController.isClosed) {
                   _newMsgController.add((contactId: targetContact.id, message: decryptedMsg));
                 }
                 // Send delivery ACK back to the actual sender (not the group).
                 unawaited(_sendSignalTo(senderContact, 'msg_ack', {
                   'msgId': msg.id,
                   'from': _selfId,
                 }));
                 final ttl = _chatTtls[targetContact.id] ?? 0;
                 if (ttl > 0) _scheduleTtlDelete(targetContact, decryptedMsg, ttl);
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

    if (hasUpdates) {
      notifyListeners();
    }
  }

  Future<void> sendMessage(Contact contact, String text, {
    bool noAutoRetry = false,
    Message? replyTo,
  }) async {
    if (_identity == null) return;

    // ── Group message: mesh broadcast to each member ──────────────────────────
    if (contact.isGroup) {
      // Show message immediately in group room
      if (!_chatRooms.containsKey(contact.id)) {
        _chatRooms[contact.id] = ChatRoom(
          id: contact.id, contact: contact,
          messages: [], adapterType: 'group',
          adapterConfig: {}, updatedAt: DateTime.now(),
        );
      }
      final groupRoom = _chatRooms[contact.id]!;
      final localMsg = Message(
        id: _uuid.v4(), senderId: _identity!.id, receiverId: contact.id,
        encryptedPayload: text, timestamp: DateTime.now(),
        adapterType: 'group', isRead: true, status: 'sending',
        replyToId: replyTo?.id,
        replyToText: replyTo?.encryptedPayload.length != null
            ? replyTo!.encryptedPayload.substring(0, replyTo.encryptedPayload.length.clamp(0, 80))
            : null,
        replyToSender: replyTo?.senderId,
      );
      groupRoom.messages.add(localMsg);
      notifyListeners();

      // Encode group routing in payload (include reply info if present)
      final groupMap = <String, dynamic>{'_group': contact.id, 'text': text};
      if (replyTo != null) {
        groupMap['_replyToId'] = replyTo.id;
        groupMap['_replyToText'] = replyTo.encryptedPayload.length > 80
            ? replyTo.encryptedPayload.substring(0, 80)
            : replyTo.encryptedPayload;
        groupMap['_replyToSender'] = replyTo.senderId;
      }
      final groupPayload = jsonEncode(groupMap);

      int sent = 0;
      for (final memberId in contact.members) {
        final memberContact = _contacts.contacts.cast<Contact?>()
            .firstWhere((c) => c?.id == memberId, orElse: () => null);
        if (memberContact == null) continue;
        await _sendToContact(memberContact, groupPayload, noAutoRetry: noAutoRetry);
        sent++;
      }

      final finalStatus = sent > 0 ? 'sent' : 'failed';
      final idx = groupRoom.messages.indexWhere((m) => m.id == localMsg.id);
      final finalMsg = localMsg.copyWith(status: finalStatus);
      if (idx != -1) groupRoom.messages[idx] = finalMsg;
      await LocalStorageService().saveMessage(contact.id, finalMsg.toJson());
      final ttl = _chatTtls[contact.id] ?? 0;
      if (ttl > 0) _scheduleTtlDelete(contact, finalMsg, ttl);
      notifyListeners();
      return;
    }

    // Wrap in federation envelope so the receiver can identify us regardless
    // of which adapter transport is used (Firebase→Nostr, Nostr→Firebase, etc.)
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
      // No session yet — fetch contact's Signal public key bundle and build one
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
          final prefs = await SharedPreferences.getInstance();
          initApiKey = prefs.getString('oxen_node_url') ?? '';
          initDbId = contact.databaseId;
          // Also push our own keys to their inbox (in-band key exchange)
          unawaited(_publishOxenKeysTo(contact));
        } else {
          throw Exception('Unknown provider: ${contact.provider}');
        }
        await contactReader.initializeReader(initApiKey, initDbId);
        final bundle = await contactReader.fetchPublicKeys();
        if (bundle != null) {
          final keyChanged = await _signalService.buildSession(contact.databaseId, bundle);
          _cacheContactKyberPk(contact.databaseId, bundle);
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

    // PQC: wrap Signal ciphertext with Kyber-1024 hybrid layer (no-op if no key yet).
    if (encryptedText.startsWith('E2EE||')) {
      encryptedText = await _pqcWrap(encryptedText, contact.databaseId);
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

    // Show plaintext in local UI immediately as 'sending'
    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: contact.databaseId, contact: contact,
        messages: [], adapterType: contact.provider,
        adapterConfig: {}, updatedAt: DateTime.now(),
      );
    }
    final room = _chatRooms[contact.id]!;
    final localMsg = Message(
      id: msg.id, senderId: _identity!.id, receiverId: contact.id,
      encryptedPayload: text, timestamp: msg.timestamp,
      adapterType: msg.adapterType, isRead: true, status: 'sending',
      replyToId: replyInfo?.id,
      replyToText: replyInfo?.text,
      replyToSender: replyInfo?.sender,
    );
    room.messages.add(localMsg);
    // Schedule TTL deletion for outgoing message if configured
    final localTtl = _chatTtls[contact.id] ?? 0;
    if (localTtl > 0) _scheduleTtlDelete(contact, localMsg, localTtl);
    notifyListeners();

    // Validate provider before routing
    if (contact.provider != 'Firebase' && contact.provider != 'Nostr' && contact.provider != 'Waku' && contact.provider != 'Oxen') {
      debugPrint('[ChatController] Unknown provider "${contact.provider}" for ${contact.name}');
      final idx2 = room.messages.indexWhere((m) => m.id == msg.id);
      final failedMsg2 = localMsg.copyWith(status: 'failed');
      if (idx2 != -1) room.messages[idx2] = failedMsg2;
      await LocalStorageService().saveMessage(contact.storageKey, failedMsg2.toJson());
      notifyListeners();
      return;
    }
    // Initialize sender and deliver
    await _addSenderPlugin(contact);
    // ── P2P fast path: deliver directly if DataChannel is open ────────────────
    bool sent;
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) debugPrint('[P2P] Direct delivery to ${contact.name}');
    } else {
      sent = await InboxManager().routeMessage(
          contact.provider, contact.databaseId, contact.databaseId, msg);
      // Kick off P2P handshake in background — future messages will be serverless
      if (!contact.isGroup) {
        unawaited(P2PTransportService.instance.connect(contact.id));
      }
    }

    // Update local message status and persist with final status
    final idx = room.messages.indexWhere((m) => m.id == msg.id);
    final finalMsg = localMsg.copyWith(status: sent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    notifyListeners();
    if (!sent && !noAutoRetry) _scheduleAutoRetry(contact, finalMsg);
  }

  // ── Smart Router helpers ────────────────────────────────────────────────────

  /// Detects the provider name from an address string.
  static String _providerFromAddress(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        RegExp(r'^[0-9a-f]{66}$').hasMatch(lower)) { return 'Oxen'; }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) { return 'Nostr'; }
    if (lower.contains('@https://')) { return 'Firebase'; }
    if (lower.contains('@http://')) { return 'Waku'; }
    return 'Nostr';
  }

  /// Delivers an already-encrypted [msg] to [address] using the appropriate
  /// adapter. Does NOT re-encrypt — used for alternate-address fallback.
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
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final prefs = await SharedPreferences.getInstance();
      final atIdx = address.indexOf('@');
      final relay = atIdx != -1
          ? address.substring(atIdx + 1)
          : prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
      await InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
          jsonEncode({'privkey': privkey, 'relay': relay}));
    } else if (provider == 'Waku') {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('waku_identity') ?? '';
      final atIdx = address.indexOf('@http');
      final nodeUrl = atIdx != -1 ? address.substring(atIdx + 1) : '';
      await InboxManager().addSenderPlugin('Waku', WakuMessageSender(),
          jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
    } else if (provider == 'Oxen') {
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      await InboxManager().addSenderPlugin('Oxen', OxenMessageSender(), nodeUrl);
    } else {
      return false;
    }
    return InboxManager().routeMessage(provider, address, address, sendMsg);
  }

  // ── _sendToContact ──────────────────────────────────────────────────────────

  /// Encrypt + deliver to a contact without any local UI update.
  /// Used for group mesh broadcasts.
  Future<bool> _sendToContact(Contact contact, String plaintext, {bool noAutoRetry = false}) async {
    if (_identity == null) return false;
    // Wrap in federation envelope (handles cross-adapter identity)
    final envelope = MessageEnvelope.wrap(_selfId.isNotEmpty ? _selfId : _identity!.id, plaintext);
    String encryptedText;
    try {
      encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
    } catch (_) {
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
          final prefs = await SharedPreferences.getInstance();
          initApiKey = prefs.getString('oxen_node_url') ?? '';
          unawaited(_publishOxenKeysTo(contact));
        } else {
          return false;
        }
        await contactReader.initializeReader(initApiKey, initDbId);
        final bundle = await contactReader.fetchPublicKeys();
        if (bundle != null) {
          final keyChanged = await _signalService.buildSession(contact.databaseId, bundle);
          _cacheContactKyberPk(contact.databaseId, bundle);
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
    // PQC: wrap Signal ciphertext with Kyber-1024 hybrid layer.
    if (encryptedText.startsWith('E2EE||')) {
      encryptedText = await _pqcWrap(encryptedText, contact.databaseId);
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
    // ── P2P fast path ─────────────────────────────────────────────────────────
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

    // ── Smart Router: retry via alternate addresses (weighted by past success) ─
    if (!sent && contact.alternateAddresses.isNotEmpty) {
      // Sort by descending success count; shuffle within ties for fairness.
      final order = [...contact.alternateAddresses];
      order.shuffle(); // randomise ties
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

    // ── LAN fallback: last resort when all internet paths fail ───────────────
    if (!sent && _lanSender != null) {
      sent = await _lanSender!.sendMessage('', '', msg);
      if (sent) {
        debugPrint('[LAN] Delivered via local network multicast');
        if (!_lanModeActive) {
          _lanModeActive = true;
          notifyListeners();
        }
      }
    } else if (sent && _lanModeActive) {
      // Internet delivery succeeded — clear LAN mode flag
      _lanModeActive = false;
      notifyListeners();
    }

    return sent;
  }

  /// Send a file, splitting into ≤512 KB chunks for large files.
  /// Shows a single local bubble; chunks are sent silently via [_sendToContact].
  Future<void> sendFile(Contact contact, Uint8List bytes, String name) async {
    if (_identity == null) return;

    // Determine total chunk count upfront for progress tracking.
    final totalChunks = bytes.length <= 512 * 1024
        ? 1
        : (bytes.length / (512 * 1024)).ceil();

    if (totalChunks == 1) {
      // Small file — normal single-message path handles groups too.
      await sendMessage(contact, MediaService.chunkPayloads(bytes, name).first);
      return;
    }

    // Multi-chunk: ensure room exists.
    final isGroup = contact.isGroup;
    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: isGroup ? contact.id : contact.databaseId,
        contact: contact,
        messages: [],
        adapterType: isGroup ? 'group' : contact.provider,
        adapterConfig: {},
        updatedAt: DateTime.now(),
      );
    }
    final room = _chatRooms[contact.id]!;
    final msgId = _uuid.v4();

    // Local display payload: metadata only (empty data — not stored on sender side).
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
    final localTtl = _chatTtls[contact.id] ?? 0;
    if (localTtl > 0) _scheduleTtlDelete(contact, localMsg, localTtl);
    notifyListeners();

    bool allSent = true;
    _uploadProgress[msgId] = 0.0;
    int i = 0;
    String? fileId; // extracted from first chunk JSON
    try {
      // Use lazy iterable to avoid holding all encoded chunks in memory at once.
      for (final chunk in MediaService.chunkIterable(bytes, name)) {
        // Record fileId from first chunk for resume support.
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
        _uploadProgress[msgId] = i / totalChunks;
        notifyListeners();
      }
      // Register for resume (kept for 10 min so receiver can request missing chunks).
      if (fileId != null) {
        _pendingSends[fileId] = (contact: contact, bytes: bytes, name: name);
        Future.delayed(const Duration(minutes: 10), () => _pendingSends.remove(fileId));
        _startStallCheckTimer();
      }
    } finally {
      _uploadProgress.remove(msgId);
    }

    final idx = room.messages.indexWhere((m) => m.id == msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    final storageKey = isGroup ? contact.id : contact.storageKey;
    await LocalStorageService().saveMessage(storageKey, finalMsg.toJson());
    notifyListeners();
  }

  /// Broadcast a single chunk payload to all members of [group].
  /// Returns true if at least one member received it successfully.
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

  Future<void> deleteLocalMessage(Contact contact, String messageId) async {
    _ttlTimers[messageId]?.cancel();
    _ttlTimers.remove(messageId);
    final room = _chatRooms[contact.id];
    if (room != null) {
      room.messages.removeWhere((m) => m.id == messageId);
    }
    await LocalStorageService().deleteMessage(contact.storageKey, messageId);
    await LocalStorageService().deleteTtlExpiry(contact.storageKey, messageId);
    notifyListeners();
  }

  Future<void> markRoomAsRead(Contact contact) async {
    final room = _chatRooms[contact.id];
    if (room == null) return;
    bool changed = false;
    for (int i = 0; i < room.messages.length; i++) {
      final m = room.messages[i];
      if (!m.isRead) {
        room.messages[i] = m.copyWith(isRead: true);
        unawaited(LocalStorageService().saveMessage(contact.storageKey, room.messages[i].toJson()));
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      unawaited(_sendReadReceipt(contact));
    }
  }

  Future<void> clearRoomHistory(Contact contact) async {
    final room = _chatRooms[contact.id];
    if (room == null) return;
    final storageKey = contact.isGroup ? contact.id : contact.databaseId;
    await LocalStorageService().clearHistory(storageKey);
    room.messages.clear();
    notifyListeners();
  }

  Future<void> retryMessage(Contact contact, Message message) async {
    if (message.status != 'failed') return;
    final room = _chatRooms[contact.id];
    if (room == null) return;
    room.messages.removeWhere((m) => m.id == message.id);
    await LocalStorageService().deleteMessage(contact.storageKey, message.id);
    notifyListeners();
    await sendMessage(contact, message.encryptedPayload, noAutoRetry: true);
  }

  void _scheduleAutoRetry(Contact contact, Message failedMsg) {
    _retryTimers[failedMsg.id]?.cancel();
    _retryTimers[failedMsg.id] = Timer(const Duration(seconds: 30), () async {
      _retryTimers.remove(failedMsg.id);
      try {
        final room = _chatRooms[contact.id];
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

  /// Flush all failed messages when network is restored.
  /// Finds every message with status 'failed' across all rooms and retries.
  Future<void> _flushFailedMessages() async {
    int count = 0;
    for (final room in _chatRooms.values) {
      final failed = room.messages
          .where((m) => m.status == 'failed')
          .toList();
      if (failed.isEmpty) continue;
      for (final msg in failed) {
        // Skip if already scheduled for retry
        if (_retryTimers.containsKey(msg.id)) continue;
        count++;
        unawaited(retryMessage(room.contact, msg));
        // Stagger retries to avoid thundering herd
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    if (count > 0) {
      debugPrint('[Chat] Flushing $count failed message(s) after network change');
    }
  }

  void _handleReadReceipt(String fromId) {
    bool changed = false;
    for (final room in _chatRooms.values) {
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
    if (changed) notifyListeners();
  }

  Future<void> _sendReadReceipt(Contact contact) =>
      _sendSignalTo(contact, 'msg_read', {'from': _selfId});

  void _handleDeliveryAck(String fromId, String msgId) {
    bool changed = false;
    for (final room in _chatRooms.values) {
      final contactId = room.contact.databaseId;
      if (contactId != fromId && contactId.split('@').first != fromId) continue;
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.id == msgId && m.status == 'sent') {
          room.messages[i] = m.copyWith(status: 'delivered');
          unawaited(LocalStorageService().saveMessage(room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
          break;
        }
      }
      if (changed) break;
    }
    if (changed) notifyListeners();
  }

  // ─── Disappearing messages ────────────────────────────────────────────────

  Future<void> setChatTtlSeconds(Contact contact, int seconds, {bool sendSignal = true}) async {
    _chatTtls[contact.id] = seconds;
    final prefs = await SharedPreferences.getInstance();
    if (seconds == 0) {
      await prefs.remove('chat_ttl_${contact.id}');
    } else {
      await prefs.setInt('chat_ttl_${contact.id}', seconds);
    }
    // Notify the other side so they apply the same TTL
    if (sendSignal && !contact.isGroup) {
      unawaited(_sendTtlSignal(contact, seconds));
    }
    // Immediately purge already-expired messages and schedule the rest
    final room = _chatRooms[contact.id];
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
        _scheduleTtlDelete(contact, m, seconds);
      }
      notifyListeners();
    }
  }

  Future<void> _sendTtlSignal(Contact contact, int seconds) =>
      _sendSignalTo(contact, 'ttl_update', {'seconds': seconds});

  // ── P2P signaling helpers ───────────────────────────────────────────────────

  Future<void> _sendP2PSignal(Contact contact, String type, Map<String, dynamic> payload) =>
      _sendSignalTo(contact, type, payload);

  /// Deliver a P2P-received (Signal-encrypted) payload as if it arrived
  /// from the contact's normal adapter.
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

  void _scheduleTtlDelete(Contact contact, Message msg, int ttlSeconds) {
    if (ttlSeconds <= 0) return;
    final expiresAt = msg.timestamp.add(Duration(seconds: ttlSeconds));
    final remaining = expiresAt.difference(DateTime.now());
    _ttlTimers[msg.id]?.cancel();
    if (remaining.isNegative) {
      unawaited(deleteLocalMessage(contact, msg.id));
      return;
    }
    // Persist expiry so timers survive app restarts.
    unawaited(LocalStorageService().saveTtlExpiry(
        contact.storageKey, msg.id, expiresAt.millisecondsSinceEpoch));
    _ttlTimers[msg.id] = Timer(remaining, () {
      _ttlTimers.remove(msg.id);
      unawaited(deleteLocalMessage(contact, msg.id));
    });
  }

  /// Restores TTL deletion timers from the database after app restart.
  /// Called once during initialize() — deletes already-expired messages immediately.
  Future<void> _restoreScheduledTtls() async {
    final pending = await LocalStorageService().loadAllTtlPending();
    for (final item in pending) {
      final remaining = item.expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        // Already expired — delete immediately.
        await LocalStorageService().deleteMessage(item.roomId, item.msgId);
        await LocalStorageService().deleteTtlExpiry(item.roomId, item.msgId);
        // Remove from in-memory room if already loaded.
        for (final room in _chatRooms.values) {
          if (room.contact.storageKey == item.roomId ||
              room.contact.id == item.roomId) {
            room.messages.removeWhere((m) => m.id == item.msgId);
            break;
          }
        }
      } else {
        final roomId = item.roomId;
        final msgId  = item.msgId;
        _ttlTimers[msgId]?.cancel();
        _ttlTimers[msgId] = Timer(remaining, () async {
          _ttlTimers.remove(msgId);
          await LocalStorageService().deleteMessage(roomId, msgId);
          await LocalStorageService().deleteTtlExpiry(roomId, msgId);
          for (final room in _chatRooms.values) {
            if (room.contact.storageKey == roomId ||
                room.contact.id == roomId) {
              room.messages.removeWhere((m) => m.id == msgId);
              notifyListeners();
              break;
            }
          }
        });
      }
    }
  }

  /// Called when a preKey is consumed — clears the publish flag and republishes
  /// a fresh bundle so new contacts can still establish sessions.
  Future<void> _republishKeys() async {
    if (_identity == null || _selfId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final flag = 'signal_keys_published_${_identity!.preferredAdapter}_$_selfId';
    await prefs.remove(flag);
    await _maybePublishOwnKeys();
    debugPrint('[ChatController] Republished Signal bundle after preKey consumption');
  }

  /// Re-publish the Signal bundle to the primary adapter AND all secondary adapters.
  /// Called when prekeys are exhausted and regenerated, so every transport gets the
  /// updated bundle (identity key + signed prekey + fresh prekeys).
  Future<void> _republishAllKeys() async {
    // Re-publish to primary adapter.
    await _republishKeys();

    // Re-publish to every secondary adapter by clearing their published flags.
    final secondaryCfgs = await _loadSecondaryAdapters();
    final prefs = await SharedPreferences.getInstance();
    for (final cfg in secondaryCfgs) {
      final selfId = cfg['selfId'] ?? '';
      if (selfId.isEmpty) continue;
      final flag = 'signal_keys_published_${cfg['provider']?.toLowerCase()}_$selfId';
      await prefs.remove(flag);
      await _publishKeysToAdapter(cfg['provider']!, cfg['apiKey']!, selfId);
    }
    debugPrint('[ChatController] Republished Signal bundle to all transports after preKey exhaustion');
  }

  /// Publish only if not yet published for this adapter+selfId combination.
  Future<void> _maybePublishOwnKeys() async {
    if (_identity == null || _selfId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final flag = 'signal_keys_published_${_identity!.preferredAdapter}_$_selfId';
    if (prefs.getBool(flag) != true) {
      await _publishOwnKeys();
      await prefs.setBool(flag, true);
    }
  }

  /// Publish our Signal public bundle to our inbox so contacts can fetch it.
  /// All adapters including Nostr — for Nostr, publishes as kind 10009 on relay.
  Future<void> _publishOwnKeys() async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final bundle = await _signalService.getPublicBundle();
      // Include our Kyber-1024 public key so contacts can apply PQC hybrid wrap.
      if (PqcService().isInitialized) {
        bundle['kyberPublicKey'] = PqcService().publicKey.toList();
      }
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender sender;
      String senderApiKey = ourApiKey;
      switch (_identity!.preferredAdapter) {
        case 'firebase':
          sender = FirebaseInboxSender();
        case 'nostr':
          final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
          if (privkey.isEmpty) return;
          final prefs = await SharedPreferences.getInstance();
          final relay = _identity!.adapterConfig['relay'] ??
              prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
          sender = NostrMessageSender();
          senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        case 'waku':
          sender = WakuMessageSender();
          {
            final prefs = await SharedPreferences.getInstance();
            final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
            final userId = prefs.getString('waku_identity') ?? '';
            senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
          }
        case 'oxen':
          sender = OxenMessageSender();
          {
            final prefs = await SharedPreferences.getInstance();
            senderApiKey = prefs.getString('oxen_node_url') ?? '';
          }
        default:
          return;
      }
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(_selfId, _selfId, _selfId, 'sys_keys', bundle);
      debugPrint('[ChatController] Published Signal public keys');
    } catch (e) {
      debugPrint('[ChatController] Key publishing failed: $e');
    }
  }

  /// Push our own Signal key bundle to [contact]'s Oxen inbox so they can
  /// build a session with us.  Called on first send and when we receive their keys.
  Future<void> _publishOxenKeysTo(Contact contact) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final bundle = await _signalService.getPublicBundle();
      if (PqcService().isInitialized) {
        bundle['kyberPublicKey'] = PqcService().publicKey.toList();
      }
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      final sender = OxenMessageSender();
      await sender.initializeSender(nodeUrl);
      // Push to contact's inbox so their polling loop delivers our keys
      await sender.sendSignal(
          contact.databaseId, contact.databaseId, _selfId, 'sys_keys', bundle);
    } catch (e) {
      debugPrint('[Oxen] Key push to ${contact.name} failed: $e');
    }
  }

  // ─── Reactions ────────────────────────────────────────────────────────────

  /// Returns {emoji: [senderIds]} for a message in a room.
  Map<String, List<String>> getReactions(String storageKey, String msgId) {
    final room = _reactions[storageKey];
    if (room == null) return {};
    final msgReacts = room[msgId];
    if (msgReacts == null) return {};
    final result = <String, List<String>>{};
    for (final key in msgReacts) {
      final underscoreIdx = key.indexOf('_');
      if (underscoreIdx == -1) continue;
      final emoji = key.substring(0, underscoreIdx);
      final senderId = key.substring(underscoreIdx + 1);
      result[emoji] ??= [];
      result[emoji]!.add(senderId);
    }
    return result;
  }

  Future<void> toggleReaction(Contact contact, String msgId, String emoji) async {
    if (_identity == null || _selfId.isEmpty) return;
    final storageKey = contact.storageKey;
    _reactions[storageKey] ??= {};
    _reactions[storageKey]![msgId] ??= {};
    final key = '${emoji}_$_selfId';
    final set = _reactions[storageKey]![msgId]!;
    bool remove = false;
    if (set.contains(key)) {
      set.remove(key);
      remove = true;
      unawaited(LocalStorageService().removeReaction(storageKey, msgId, emoji, _selfId));
    } else {
      set.add(key);
      unawaited(LocalStorageService().addReaction(storageKey, msgId, emoji, _selfId));
    }
    notifyListeners();
    if (contact.isGroup) {
      // Send reaction signal to each group member individually with groupId
      for (final memberId in contact.members) {
        final memberContact = _contacts.contacts.cast<Contact?>()
            .firstWhere((c) => c?.id == memberId, orElse: () => null);
        if (memberContact == null) continue;
        unawaited(_sendReactionSignal(memberContact, msgId, emoji,
            remove: remove, groupId: contact.id));
      }
    } else {
      unawaited(_sendReactionSignal(contact, msgId, emoji, remove: remove));
    }
  }

  Future<void> _loadReactions(String storageKey) async {
    try {
      final data = await LocalStorageService().loadReactions(storageKey);
      if (data.isNotEmpty) {
        _reactions[storageKey] ??= {};
        _reactions[storageKey]!.addAll(data);
      }
    } catch (e) {
      debugPrint('[Chat] Failed to load reactions for $storageKey: $e');
      sentryBreadcrumb('Reactions load failed', category: 'storage');
    }
  }

  Future<void> _sendReactionSignal(Contact contact, String msgId, String emoji, {
    bool remove = false,
    String? groupId,
  }) => _sendSignalTo(contact, 'reaction', {
        'msgId': msgId, 'emoji': emoji, 'from': _selfId,
        if (remove) 'remove': true,
        'groupId': groupId,
      });

  // ─── Message Editing ──────────────────────────────────────────────────────

  Future<void> editMessage(Contact contact, String msgId, String newText) async {
    if (_identity == null) return;
    final storageKey = contact.storageKey;
    final room = _chatRooms[contact.id];
    if (room == null) return;
    final idx = room.messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;
    if (room.messages[idx].senderId != _identity!.id) return;
    final updated = room.messages[idx].copyWith(encryptedPayload: newText, isEdited: true);
    room.messages[idx] = updated;
    await LocalStorageService().saveMessage(storageKey, updated.toJson());
    notifyListeners();
    unawaited(_sendEditSignal(contact, msgId, newText));
  }

  Future<void> _sendEditSignal(Contact contact, String msgId, String text) =>
      _sendSignalTo(contact, 'edit', {'msgId': msgId, 'text': text, 'from': _selfId});

  // ─── Online Status ────────────────────────────────────────────────────────

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

  Future<void> _sendHeartbeats() async {
    if (_identity == null || _selfId.isEmpty) return;
    for (final contact in _contacts.contacts) {
      if (contact.isGroup) continue;
      await _sendSignalTo(contact, 'heartbeat',
          {'from': _selfId, 'ts': DateTime.now().millisecondsSinceEpoch});
    }
  }

  // ─── Export Chat History ──────────────────────────────────────────────────

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
      final file = File('${dir.path}/chat_${contact.name}_$date.txt');
      await file.writeAsString(buf.toString());
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ─── Scheduled messages ───────────────────────────────────────────────────

  /// Schedule [text] to be sent to [contact] at [scheduledAt].
  /// Shows a placeholder bubble immediately with status 'scheduled'.
  Future<void> scheduleMessage(Contact contact, String text, DateTime scheduledAt) async {
    if (_identity == null) return;
    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: contact.isGroup ? contact.id : contact.databaseId,
        contact: contact, messages: [],
        adapterType: contact.isGroup ? 'group' : contact.provider,
        adapterConfig: {}, updatedAt: DateTime.now(),
      );
    }
    final msgId = _uuid.v4();
    final placeholder = Message(
      id: msgId,
      senderId: _identity!.id,
      receiverId: contact.id,
      encryptedPayload: text,
      timestamp: DateTime.now(),
      adapterType: contact.isGroup ? 'group' : contact.provider == 'Nostr' ? 'nostr' : contact.provider == 'Waku' ? 'waku' : contact.provider == 'Oxen' ? 'oxen' : 'firebase',
      isRead: true,
      status: 'scheduled',
      scheduledAt: scheduledAt,
    );
    _chatRooms[contact.id]!.messages.add(placeholder);
    notifyListeners();

    // Persist so it survives restarts
    final prefs = await SharedPreferences.getInstance();
    final storageKey = 'scheduled_${contact.id}';
    List existing;
    try {
      existing = jsonDecode(prefs.getString(storageKey) ?? '[]') as List;
    } catch (_) {
      existing = [];
    }
    existing.add(placeholder.toJson());
    await prefs.setString(storageKey, jsonEncode(existing));

    _scheduleTimer(contact, placeholder);
  }

  void _scheduleTimer(Contact contact, Message msg) {
    final delay = msg.scheduledAt!.difference(DateTime.now());
    if (delay.isNegative) {
      // Already overdue — send immediately
      unawaited(_fireScheduled(contact, msg));
      return;
    }
    _retryTimers[msg.id] = Timer(delay, () => unawaited(_fireScheduled(contact, msg)));
  }

  Future<void> _fireScheduled(Contact contact, Message msg) async {
    _retryTimers.remove(msg.id);
    // Remove placeholder
    final room = _chatRooms[contact.id];
    if (room != null) room.messages.removeWhere((m) => m.id == msg.id);
    // Remove from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final storageKey = 'scheduled_${contact.id}';
    List list;
    try {
      list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
          .where((m) => m is Map && m['id'] != msg.id)
          .toList();
    } catch (_) {
      list = [];
    }
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
    await sendMessage(contact, msg.encryptedPayload);
  }

  /// Cancel a scheduled message — removes placeholder and timer.
  Future<void> cancelScheduledMessage(Contact contact, String msgId) async {
    _retryTimers[msgId]?.cancel();
    _retryTimers.remove(msgId);
    final room = _chatRooms[contact.id];
    if (room != null) room.messages.removeWhere((m) => m.id == msgId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final storageKey = 'scheduled_${contact.id}';
    List list;
    try {
      list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
          .where((m) => m is Map && m['id'] != msgId)
          .toList();
    } catch (_) {
      list = [];
    }
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
  }

  /// Restore scheduled messages after app restart — called from initialize().
  Future<void> _restoreScheduledMessages() async {
    final prefs = await SharedPreferences.getInstance();
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
          if (!_chatRooms.containsKey(contact.id)) {
            _chatRooms[contact.id] = ChatRoom(
              id: contact.isGroup ? contact.id : contact.databaseId,
              contact: contact, messages: [],
              adapterType: contact.isGroup ? 'group' : contact.provider,
              adapterConfig: {}, updatedAt: DateTime.now(),
            );
          }
          _chatRooms[contact.id]!.messages.add(msg);
          _scheduleTimer(contact, msg);
        }
      } catch (e) {
        debugPrint('[Scheduled] Restore error for ${contact.id}: $e');
      }
    }
  }

  // ─── PQC key helpers ──────────────────────────────────────────────────────

  /// Cache a contact's Kyber public key from their Signal bundle.
  /// Synchronous in-memory write + fire-and-forget SharedPreferences persist.
  void _cacheContactKyberPk(String contactId, Map<String, dynamic> bundle) {
    final kyberPkList = bundle['kyberPublicKey'];
    if (kyberPkList == null) return;
    try {
      final pk = Uint8List.fromList(List<int>.from(kyberPkList));
      _contactKyberPks[contactId] = pk;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('pqc_contact_pk_$contactId', base64Encode(pk));
      });
    } catch (e) {
      debugPrint('[PQC] Failed to cache kyber pk for $contactId: $e');
    }
  }

  /// True if we have a Kyber public key for this contact (PQC active).
  bool hasPqcKey(String contactId) => _contactKyberPks.containsKey(contactId);

  /// Load contact's Kyber pk: in-memory first, then SharedPreferences.
  Future<Uint8List?> _loadContactKyberPk(String contactId) async {
    if (_contactKyberPks.containsKey(contactId)) return _contactKyberPks[contactId];
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('pqc_contact_pk_$contactId');
    if (b64 == null) return null;
    final pk = base64Decode(b64);
    _contactKyberPks[contactId] = pk;
    return pk;
  }

  // ── File transfer resume ─────────────────────────────────────────────────

  /// Start a periodic stall-check timer (if not already running).
  /// Every 30s, scans active receiver-side transfers for stalls and sends
  /// a `chunk_req` signal to the original sender.
  void _startStallCheckTimer() {
    if (_stallCheckTimer?.isActive == true) return;
    _stallCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      for (final fid in _chunkAssembler.activeTransferIds) {
        if (!_chunkAssembler.isStalled(fid)) continue;
        final missing = _chunkAssembler.getMissingChunks(fid);
        if (missing == null || missing.isEmpty) continue;
        // Find which contact this transfer came from (by matching fid in pending sends).
        // If we're the receiver, send chunk_req to all contacts (sender will recognise fid).
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

  /// Re-send only the [missingIndices] chunks of [fileId] to [recipientId].
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

  // ── SmartRouter delivery stats persistence ───────────────────────────────

  Future<void> _loadDeliveryStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kDeliveryStatsKey, jsonEncode(Map<String, int>.from(_deliverySuccessCount)));
    } catch (e) {
      debugPrint('[SmartRouter] Failed to save delivery stats: $e');
    }
  }

  /// Wrap a Signal ciphertext with the PQC hybrid layer for [contactId].
  /// No-op (returns original) if no Kyber key is available for the contact.
  Future<String> _pqcWrap(String signalCt, String contactId) async {
    final pk = await _loadContactKyberPk(contactId);
    return CryptoLayer.wrap(signalCt, pk);
  }

  @override
  void dispose() {
    NetworkMonitor.instance.stopMonitoring();
    P2PTransportService.instance.dispose();
    _lanReader?.close();
    _lanSender?.close();
    _bundleRefreshSub?.cancel();
    for (final s in _messageSubs) { s.cancel(); }
    for (final s in _signalSubs) { s.cancel(); }
    for (final s in _dispatcherSubs) { s.cancel(); }
    _dispatcherSubs.clear();
    _signalDispatcher?.dispose();
    _signalDispatcher = null;
    _sigRateLimiter.clear(); // safe fallback if dispatcher was never initialized
    for (final t in _typingTimers.values) { t.cancel(); }
    _typingTimers.clear();
    for (final t in _retryTimers.values) { t.cancel(); }
    _retryTimers.clear();
    for (final t in _ttlTimers.values) { t.cancel(); }
    _ttlTimers.clear();
    _heartbeatTimer?.cancel();
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
    _msgRateLimiter.clear();
    unawaited(VoiceService().dispose());
    // Zeroize key material from memory.
    _signalService.zeroize();
    PqcService().zeroize();
    final reader = InboxManager().reader;
    if (reader is NostrInboxReader) reader.zeroize();
    for (final sender in InboxManager().senders.values) {
      if (sender is NostrMessageSender) sender.zeroize();
    }
    super.dispose();
  }
}
