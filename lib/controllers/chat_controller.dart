import 'dart:async';
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

enum ConnectionStatus { disconnected, connecting, connected }

class ChatController extends ChangeNotifier {
  static final ChatController _instance = ChatController._internal();
  factory ChatController() => _instance;
  ChatController._internal();

  Identity? _identity;
  String _selfId = ''; // adapter-specific ID used as senderId in outgoing messages
  final Map<String, ChatRoom> _chatRooms = {}; // Key is Contact ID
  final SignalService _signalService = SignalService();
  final List<StreamSubscription> _messageSubs = [];
  final List<StreamSubscription> _signalSubs = [];
  List<String> _allAddresses = [];

  // ── LAN fallback ──────────────────────────────────────────────────────────
  LanInboxReader?  _lanReader;
  LanMessageSender? _lanSender;
  bool _lanModeActive = false;

  /// True when all internet adapters are unreachable and LAN is being used.
  bool get lanModeActive => _lanModeActive;

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  // Emits every incoming message so UI can show in-app banners
  final StreamController<({String contactId, Message message})> _newMsgController =
      StreamController.broadcast();
  Stream<({String contactId, Message message})> get newMessages => _newMsgController.stream;

  // Emits contact name when their Signal identity key changes (possible reinstall / MITM).
  final StreamController<String> _keyChangeCtrl = StreamController.broadcast();
  Stream<String> get keyChangeWarnings => _keyChangeCtrl.stream;

  // Per-room TTL cache (seconds, 0 = off). Populated in loadRoomHistory().
  final Map<String, int> _chatTtls = {};

  // Pagination: how many messages from the end we have already loaded per room.
  static const int _historyPageSize = 50;
  final Map<String, int> _historyLoaded = {};  // loaded count
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

  // Chunk assembly buffers (keyed by file ID from sender)
  final Map<String, Map<int, Uint8List>> _pendingChunks = {};
  final Map<String, ({String name, int total, int size, String mediaType})> _chunkMeta = {};
  int getChatTtlCached(String contactId) => _chatTtls[contactId] ?? 0;

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
        } catch (_) {}
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
      final msg = Message.fromJson(m);
      if (!room.messages.any((x) => x.id == msg.id)) {
        room.messages.add(msg);
      }
    }
    room.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Fix messages stuck in 'sending' from a crashed session
    for (int i = 0; i < room.messages.length; i++) {
      if (room.messages[i].status == 'sending') {
        room.messages[i] = room.messages[i].copyWith(status: 'failed');
        unawaited(LocalStorageService().saveMessage(storageKey, room.messages[i].toJson()));
      }
    }
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
  Future<void> loadMoreHistory(Contact contact) async {
    if (_historyFull[contact.id] == true) return;
    if (_loadingMoreHistory[contact.id] == true) return;

    _loadingMoreHistory[contact.id] = true;
    notifyListeners();

    try {
      final storageKey = contact.isGroup ? contact.id : contact.databaseId;
      final offset = _historyLoaded[contact.id] ?? _historyPageSize;
      final total = await LocalStorageService().countMessages(storageKey);
      final older = await LocalStorageService().loadMessagesPage(
        storageKey,
        pageSize: _historyPageSize,
        offset: offset,
      );

      final room = _chatRooms[contact.id];
      if (room != null && older.isNotEmpty) {
        // Prepend older messages in timestamp order
        final toInsert = older
            .map((m) => Message.fromJson(m))
            .where((m) => !room.messages.any((x) => x.id == m.id))
            .toList();
        room.messages.insertAll(0, toInsert);
        _historyLoaded[contact.id] = offset + older.length;
      }
      _historyFull[contact.id] = (_historyLoaded[contact.id] ?? 0) >= total;
    } finally {
      _loadingMoreHistory[contact.id] = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    await LocalStorageService().init();
    _connectionStatus = ConnectionStatus.connecting;
    final prefs = await SharedPreferences.getInstance();
    final identityJson = prefs.getString('user_identity');
    if (identityJson != null) {
      _identity = Identity.fromJson(jsonDecode(identityJson));
      await _signalService.initialize();
      await PqcService().initialize();
      await _initInbox();
    } else {
      _connectionStatus = ConnectionStatus.disconnected;
    }
  }

  Future<void> reconnectInbox() async {
    _connectionStatus = ConnectionStatus.connecting;
    notifyListeners();
    for (final s in _messageSubs) { s.cancel(); }
    _messageSubs.clear();
    for (final s in _signalSubs) { s.cancel(); }
    _signalSubs.clear();
    await _initInbox();
  }

  static const _secureStorage = FlutterSecureStorage();
  static const _uuid = Uuid();

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
            prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
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
          } catch (_) {}
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

    InboxManager().configureSelf(providerName, apiKey, dbId);
    _connectionStatus = ConnectionStatus.connected;
    notifyListeners();

    // Republish Signal bundle whenever a preKey is consumed (new contact established session).
    _signalService.onPreKeyConsumed = () => unawaited(_republishKeys());

    // Publish Signal public keys to own inbox (once per adapter + selfId combination)
    unawaited(_maybePublishOwnKeys());

    // Restore scheduled messages from previous session
    unawaited(_restoreScheduledMessages());

    // Start heartbeat timer for online status
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) => unawaited(_sendHeartbeats()));

    _allAddresses = [myAddress];
    if (InboxManager().reader != null) {
      _messageSubs.add(InboxManager().reader!.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(InboxManager().reader!.listenForSignals().listen(_handleIncomingSignals));
    }

    // Subscribe secondary adapters
    final secondaryCfgs = await _loadSecondaryAdapters();
    for (final cfg in secondaryCfgs) {
      final reader = InboxManager().createAdhocReader(
          cfg['provider']!, cfg['apiKey']!, cfg['databaseId']!);
      if (reader == null) continue;
      _messageSubs.add(reader.listenForMessages().listen(_handleIncomingMessages));
      _signalSubs.add(reader.listenForSignals().listen(_handleIncomingSignals));
      final addr = cfg['selfId'] ?? '';
      if (addr.isNotEmpty) _allAddresses.add(addr);
      unawaited(_publishKeysToAdapter(cfg['provider']!, cfg['apiKey']!, cfg['selfId'] ?? ''));
    }

    // ── LAN fallback adapter (always listening) ───────────────────────────
    _lanReader?.close();
    _lanSender?.close();
    _lanReader = LanInboxReader();
    _lanSender = LanMessageSender();
    await _lanReader!.initializeReader('', _selfId);
    await _lanSender!.initializeSender(_selfId);
    _messageSubs.add(_lanReader!.listenForMessages().listen(_handleIncomingMessages));
    _signalSubs.add(_lanReader!.listenForSignals().listen(_handleIncomingSignals));

    // Monitor internet; flip lanModeActive flag when status changes
    NetworkMonitor.instance.startMonitoring(
      onChanged: (isAvailable) {
        if (_lanModeActive == isAvailable) {
          _lanModeActive = !isAvailable;
          notifyListeners();
        }
      },
    );

    // ── P2P DataChannel transport ─────────────────────────────────────────────
    // Signaling goes over the contact's normal adapter (Firebase/Nostr/Waku).
    // Once the DataChannel opens, all subsequent messages bypass any server.
    P2PTransportService.instance.onSendSignal = (contactId, type, payload) {
      final contact = ContactManager().contacts.cast<Contact?>()
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
          } catch (_) {}
        }
        result.add(entry);
      }
      return result;
    } catch (_) {
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

  // ── Typing indicators ─────────────────────────────────────────────────────
  final Map<String, Timer> _typingTimers = {};
  final Map<String, bool> _isTypingMap = {};
  final StreamController<String> _typingStreamCtrl = StreamController.broadcast();

  /// Emits a contactId whenever that contact's typing state changes.
  Stream<String> get typingUpdates => _typingStreamCtrl.stream;

  bool isContactTyping(String contactId) => _isTypingMap[contactId] ?? false;

  Future<void> sendTypingSignal(Contact contact) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (contact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (contact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        // Empty privkey → throwaway key used by NostrMessageSender (cross-adapter case).
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (contact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (contact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(
          contact.databaseId, contact.databaseId, _selfId, 'typing', {'from': _selfId});
    } catch (_) {}
  }
  // ─────────────────────────────────────────────────────────────────────────

  /// Broadcast our own status to all non-group contacts.
  Future<void> broadcastStatus(UserStatus status) async {
    if (_identity == null || _selfId.isEmpty) return;
    for (final contact in ContactManager().contacts) {
      if (contact.isGroup) continue;
      try {
        final ourApiKey = _identity!.adapterConfig['token'] ?? '';
        MessageSender? sender;
        String senderApiKey = ourApiKey;
        if (contact.provider == 'Firebase') {
          sender = FirebaseInboxSender();
        } else if (contact.provider == 'Nostr') {
          final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
          final prefs = await SharedPreferences.getInstance();
          final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
          senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
          sender = NostrMessageSender();
        } else if (contact.provider == 'Waku') {
          final prefs = await SharedPreferences.getInstance();
          final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
          final userId = prefs.getString('waku_identity') ?? '';
          senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
          sender = WakuMessageSender();
        } else if (contact.provider == 'Oxen') {
          final prefs = await SharedPreferences.getInstance();
          senderApiKey = prefs.getString('oxen_node_url') ?? '';
          sender = OxenMessageSender();
        }
        if (sender == null) continue;
        await sender.initializeSender(senderApiKey);
        await sender.sendSignal(
            contact.databaseId, contact.databaseId, _selfId,
            'status_update', status.toJson());
      } catch (e) {
        debugPrint('[ChatController] broadcastStatus to ${contact.name} failed: $e');
      }
    }
  }

  /// Broadcast own profile (name + about) to all non-group contacts.
  Future<void> broadcastProfile(String name, String about, {String avatarB64 = ''}) async {
    if (_identity == null || _selfId.isEmpty) return;
    final payload = <String, dynamic>{'name': name, 'about': about};
    if (avatarB64.isNotEmpty) payload['avatar'] = avatarB64;
    for (final contact in ContactManager().contacts) {
      if (contact.isGroup) continue;
      try {
        final ourApiKey = _identity!.adapterConfig['token'] ?? '';
        MessageSender? sender;
        String senderApiKey = ourApiKey;
        if (contact.provider == 'Firebase') {
          sender = FirebaseInboxSender();
        } else if (contact.provider == 'Nostr') {
          final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
          final prefs = await SharedPreferences.getInstance();
          final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
          senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
          sender = NostrMessageSender();
        } else if (contact.provider == 'Waku') {
          final prefs = await SharedPreferences.getInstance();
          final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
          final userId = prefs.getString('waku_identity') ?? '';
          senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
          sender = WakuMessageSender();
        } else if (contact.provider == 'Oxen') {
          final prefs = await SharedPreferences.getInstance();
          senderApiKey = prefs.getString('oxen_node_url') ?? '';
          sender = OxenMessageSender();
        }
        if (sender == null) continue;
        await sender.initializeSender(senderApiKey);
        await sender.sendSignal(
            contact.databaseId, contact.databaseId, _selfId,
            'profile_update', payload);
      } catch (e) {
        debugPrint('[ChatController] broadcastProfile to ${contact.name} failed: $e');
      }
    }
  }

  /// Send a group read receipt for a specific message back to its sender.
  Future<void> _sendGroupReadReceipt(Contact senderContact, String groupId, String msgId) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (senderContact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (senderContact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (senderContact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (senderContact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(
        senderContact.databaseId, senderContact.databaseId, _selfId,
        'msg_read', {'from': _selfId, 'groupId': groupId, 'msgId': msgId},
      );
    } catch (e) {
      debugPrint('[ChatController] Group read receipt failed: $e');
    }
  }

  /// Called when opening a group chat — sends read receipts to each original sender.
  Future<void> markGroupMessagesRead(Contact group) async {
    if (!group.isGroup || _identity == null || _selfId.isEmpty) return;
    final room = _chatRooms[group.id];
    if (room == null) return;
    for (final msg in List.of(room.messages)) {
      if (msg.senderId == _selfId || msg.senderId.isEmpty) continue;
      // Find sender contact
      Contact? senderContact;
      for (final c in ContactManager().contacts) {
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

  Future<void> _handleIncomingSignals(List<Map<String, dynamic>> signals) async {
    for (var sig in signals) {
       _signalStreamController.add(sig); // Broadcast to active calls
       if (sig['type'] == 'webrtc_offer') {
          final rawPayload = sig['payload'];
          final groupId = rawPayload is Map ? rawPayload['groupId'] as String? : null;
          if (groupId != null) {
            _incomingGroupCallController.add({...sig, 'groupId': groupId});
          } else {
            _incomingCallController.add(sig);
          }
       } else if (sig['type'] == 'typing') {
          final fromId = sig['senderId'] as String? ?? '';
          Contact? typingContact;
          for (final c in ContactManager().contacts) {
            if (c.databaseId == fromId || c.databaseId.split('@').first == fromId) {
              typingContact = c;
              break;
            }
          }
          if (typingContact != null) {
            final cid = typingContact.id;
            _isTypingMap[cid] = true;
            if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(cid);
            _typingTimers[cid]?.cancel();
            _typingTimers[cid] = Timer(const Duration(seconds: 4), () {
              _isTypingMap.remove(cid);
              if (!_typingStreamCtrl.isClosed) _typingStreamCtrl.add(cid);
            });
          }
       } else if (sig['type'] == 'msg_read') {
          final payload = sig['payload'];
          final from = (payload is Map ? payload['from'] as String? : null)
              ?? sig['from'] as String? ?? '';
          final groupId = payload is Map ? payload['groupId'] as String? : null;
          final msgId = payload is Map ? payload['msgId'] as String? : null;
          if (groupId != null && msgId != null && from.isNotEmpty) {
            _handleGroupReadReceipt(from, groupId, msgId);
          } else if (from.isNotEmpty) {
            _handleReadReceipt(from);
          }
       } else if (sig['type'] == 'ttl_update') {
          final payload = sig['payload'];
          final seconds = (payload is Map ? payload['seconds'] : null) as int? ?? 0;
          final fromId = sig['senderId'] as String? ?? '';
          Contact? sender;
          for (final c in ContactManager().contacts) {
            if (c.databaseId == fromId || c.databaseId.split('@').first == fromId) {
              sender = c;
              break;
            }
          }
          if (sender != null) {
            unawaited(setChatTtlSeconds(sender, seconds, sendSignal: false));
          }
       } else if (sig['type'] == 'reaction') {
          final payload = sig['payload'];
          if (payload is Map) {
            final msgId = payload['msgId'] as String? ?? '';
            final emoji = payload['emoji'] as String? ?? '';
            final from = payload['from'] as String? ?? sig['senderId'] as String? ?? '';
            final remove = payload['remove'] == true;
            final groupId = payload['groupId'] as String?;
            if (msgId.isNotEmpty && emoji.isNotEmpty && from.isNotEmpty) {
              // Route to group room if groupId present
              String storageKey;
              if (groupId != null) {
                final groupContact = ContactManager().contacts.cast<Contact?>()
                    .firstWhere((c) => c?.isGroup == true && c?.id == groupId, orElse: () => null);
                storageKey = groupContact?.storageKey ?? groupId;
              } else {
                Contact? reactionContact;
                for (final c in ContactManager().contacts) {
                  if (c.databaseId == from || c.databaseId.split('@').first == from) {
                    reactionContact = c; break;
                  }
                }
                storageKey = reactionContact?.storageKey ?? '';
              }
              if (storageKey.isNotEmpty) {
                _reactions[storageKey] ??= {};
                _reactions[storageKey]![msgId] ??= {};
                final key = '${emoji}_$from';
                if (remove) {
                  _reactions[storageKey]![msgId]!.remove(key);
                } else {
                  _reactions[storageKey]![msgId]!.add(key);
                }
                unawaited(_persistReactions(storageKey));
                notifyListeners();
              }
            }
          }
       } else if (sig['type'] == 'edit') {
          final payload = sig['payload'];
          if (payload is Map) {
            final msgId = payload['msgId'] as String? ?? '';
            final text = payload['text'] as String? ?? '';
            final from = payload['from'] as String? ?? sig['senderId'] as String? ?? '';
            if (msgId.isNotEmpty && text.isNotEmpty) {
              Contact? editContact;
              for (final c in ContactManager().contacts) {
                if (c.databaseId == from || c.databaseId.split('@').first == from) {
                  editContact = c; break;
                }
              }
              if (editContact != null) {
                final room = _chatRooms[editContact.id];
                if (room != null) {
                  final idx = room.messages.indexWhere((m) => m.id == msgId);
                  if (idx != -1) {
                    final storageKey = editContact.storageKey;
                    final updated = room.messages[idx].copyWith(encryptedPayload: text, isEdited: true);
                    room.messages[idx] = updated;
                    unawaited(LocalStorageService().saveMessage(storageKey, updated.toJson()));
                    notifyListeners();
                  }
                }
              }
            }
          }
       } else if (sig['type'] == 'heartbeat') {
          final payload = sig['payload'];
          final from = (payload is Map ? payload['from'] as String? : null)
              ?? sig['senderId'] as String? ?? '';
          Contact? hbContact;
          for (final c in ContactManager().contacts) {
            if (c.databaseId == from || c.databaseId.split('@').first == from) {
              hbContact = c; break;
            }
          }
          if (hbContact != null) {
            _lastSeen[hbContact.id] = DateTime.now();
            notifyListeners();
          }
       } else if (sig['type'] == 'sys_keys') {
          // Reactive session build: contact pushed their key bundle to us.
          final senderId = sig['senderId'] as String? ?? '';
          final payload = sig['payload'];
          if (payload is Map<String, dynamic> && senderId.isNotEmpty) {
            Contact? keyContact;
            for (final c in ContactManager().contacts) {
              if (c.databaseId == senderId ||
                  c.databaseId.split('@').first == senderId) {
                keyContact = c; break;
              }
            }
            if (keyContact != null) {
              final keyChanged = await _signalService.buildSession(
                  keyContact.databaseId, Map<String, dynamic>.from(payload));
              _cacheContactKyberPk(keyContact.databaseId, Map<String, dynamic>.from(payload));
              if (keyChanged && !_keyChangeCtrl.isClosed) {
                _keyChangeCtrl.add(keyContact.name);
              }
              // For Oxen contacts: respond with our own keys (in-band key exchange)
              if (keyContact.provider == 'Oxen') {
                unawaited(_publishOxenKeysTo(keyContact));
              }
            }
          }
       } else if ((sig['type'] as String? ?? '').startsWith('p2p_')) {
          // WebRTC DataChannel signaling — route to P2PTransportService
          final senderId = sig['senderId'] as String? ?? '';
          Contact? p2pContact;
          for (final c in ContactManager().contacts) {
            if (c.databaseId == senderId ||
                c.databaseId.split('@').first == senderId) {
              p2pContact = c;
              break;
            }
          }
          if (p2pContact != null) {
            final rawPayload = sig['payload'];
            if (rawPayload is Map<String, dynamic>) {
              unawaited(P2PTransportService.instance.handleSignal(
                  p2pContact.id, sig['type'] as String, rawPayload));
            }
          }
       } else if (sig['type'] == 'status_update') {
          final rawPayload = sig['payload'];
          final statusJson = rawPayload is Map<String, dynamic> ? rawPayload : null;
          final senderId = sig['senderId'] as String? ?? '';
          if (statusJson is Map<String, dynamic>) {
            Contact? senderContact;
            for (final c in ContactManager().contacts) {
              if (c.databaseId == senderId ||
                  c.databaseId.split('@').first == senderId) {
                senderContact = c;
                break;
              }
            }
            if (senderContact != null) {
              try {
                final status = UserStatus.fromJson(statusJson);
                if (!status.isExpired) {
                  await StatusService.instance.saveContactStatus(senderContact.id, status);
                  if (!_statusUpdatesCtrl.isClosed) {
                    _statusUpdatesCtrl.add(senderContact.id);
                  }
                }
              } catch (e) {
                debugPrint('[ChatController] status_update parse error: $e');
              }
            }
          }
       } else if (sig['type'] == 'profile_update') {
          final payload = sig['payload'];
          if (payload is Map) {
            final senderId = sig['senderId'] as String? ?? '';
            final about = payload['about'] as String? ?? '';
            final avatarB64 = payload['avatar'] as String? ?? '';
            Contact? profileContact;
            for (final c in ContactManager().contacts) {
              if (c.databaseId == senderId ||
                  c.databaseId.split('@').first == senderId) {
                profileContact = c;
                break;
              }
            }
            if (profileContact != null) {
              bool changed = false;
              Contact updated = profileContact;
              if (about != profileContact.bio) {
                updated = updated.copyWith(bio: about);
                changed = true;
              }
              if (avatarB64.isNotEmpty) {
                // Store avatar separately to keep contacts JSON small
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('contact_avatar_${profileContact.id}', avatarB64);
                changed = true;
              }
              if (changed) {
                await ContactManager().updateContact(updated);
                notifyListeners();
              }
            }
          }
       }
    }
  }

  void _handleGroupReadReceipt(String fromId, String groupId, String msgId) {
    final groupContact = ContactManager().contacts.cast<Contact?>()
        .firstWhere((c) => c?.isGroup == true && c?.id == groupId, orElse: () => null);
    if (groupContact == null) return;
    final room = _chatRooms[groupContact.id];
    if (room == null) return;
    final idx = room.messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;
    final msg = room.messages[idx];
    // Resolve fromId (transport databaseId) to contactId (UUID)
    Contact? reader;
    for (final c in ContactManager().contacts) {
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

  void _handleIncomingMessages(List<Message> newMessages) async {
    bool hasUpdates = false;
    for (var msg in newMessages) {
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
        // Fast path: try contacts whose databaseId matches the transport senderId.
        for (final c in ContactManager().contacts) {
          final idPart = c.databaseId.split('@').first;
          if (c.databaseId == msg.senderId || idPart == msg.senderId) {
            try {
              decryptedRaw = await _signalService.decryptMessage(c.databaseId, rawPayload);
              break;
            } catch (_) {}
          }
        }
        // Fallback (cross-adapter): transport senderId is a throwaway key (e.g. Firebase→Nostr).
        // Try ALL contacts — Signal decrypt throws for wrong sessions, safe to brute-force.
        if (decryptedRaw == rawPayload) {
          for (final c in ContactManager().contacts) {
            try {
              decryptedRaw = await _signalService.decryptMessage(c.databaseId, rawPayload);
              break; // correct session found
            } catch (_) {}
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
      Contact? senderContact;
      for (var c in ContactManager().contacts) {
        if (c.databaseId == canonicalSenderId) { senderContact = c; break; }
        // Also try prefix match: "userId" matches "userId@https://..."
        final idPart = c.databaseId.split('@').first;
        if (idPart.isNotEmpty && idPart == canonicalSenderId.split('@').first) {
          senderContact = c; break;
        }
      }
      // Fallback: match by transport-layer senderId (backward compat / same-adapter)
      if (senderContact == null) {
        for (var c in ContactManager().contacts) {
          if (c.databaseId == msg.senderId) { senderContact = c; break; }
          final idPart = c.databaseId.split('@').first;
          if (idPart.isNotEmpty && idPart == msg.senderId) { senderContact = c; break; }
        }
      }

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
                 final groupContact = ContactManager().contacts.cast<Contact?>()
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
             } catch (_) {} // not JSON — plain message

             // Handle chunked file transfer: buffer chunks and assemble when complete.
             bool skipMessage = false;
             if (MediaService.isChunkPayload(finalText)) {
               final assembled = _handleChunk(finalText);
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
                 final ttl = _chatTtls[targetContact.id] ?? 0;
                 if (ttl > 0) _scheduleTtlDelete(targetContact, decryptedMsg, ttl);
               }
             }
           } catch (e) {
             debugPrint("Decryption failed for message ${msg.id}: $e");
           }
        }
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
        final memberContact = ContactManager().contacts.cast<Contact?>()
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
            _keyChangeCtrl.add(contact.name);
          }
          encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
        } else {
          debugPrint('Could not fetch public keys for ${contact.name}, sending plaintext');
          if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add(contact.name);
          encryptedText = envelope; // unencrypted but still has _from for routing
        }
      } catch (e2) {
        debugPrint('Session build failed, sending plaintext: $e2');
        if (!_e2eeFailCtrl.isClosed) _e2eeFailCtrl.add(contact.name);
        encryptedText = '⚠️ UNENCRYPTED: $text';
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
      await LocalStorageService().saveMessage(contact.databaseId, failedMsg2.toJson());
      notifyListeners();
      return;
    }
    // Initialize sender and deliver
    final ourApiKey = _identity!.adapterConfig['token'] ?? '';
    if (contact.provider == 'Firebase') {
      InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
    } else if (contact.provider == 'Nostr') {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final prefs = await SharedPreferences.getInstance();
      final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
      final nostrApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
      InboxManager().addSenderPlugin('Nostr', NostrMessageSender(), nostrApiKey);
    } else if (contact.provider == 'Waku') {
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      final userId = prefs.getString('waku_identity') ?? '';
      InboxManager().addSenderPlugin('Waku', WakuMessageSender(),
          jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
    } else if (contact.provider == 'Oxen') {
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      InboxManager().addSenderPlugin('Oxen', OxenMessageSender(), nodeUrl);
    }
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
    await LocalStorageService().saveMessage(contact.databaseId, finalMsg.toJson());
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
      InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
    } else if (provider == 'Nostr') {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final prefs = await SharedPreferences.getInstance();
      final atIdx = address.indexOf('@');
      final relay = atIdx != -1
          ? address.substring(atIdx + 1)
          : prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
      InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
          jsonEncode({'privkey': privkey, 'relay': relay}));
    } else if (provider == 'Waku') {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('waku_identity') ?? '';
      final atIdx = address.indexOf('@http');
      final nodeUrl = atIdx != -1 ? address.substring(atIdx + 1) : '';
      InboxManager().addSenderPlugin('Waku', WakuMessageSender(),
          jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
    } else if (provider == 'Oxen') {
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      InboxManager().addSenderPlugin('Oxen', OxenMessageSender(), nodeUrl);
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
            _keyChangeCtrl.add(contact.name);
          }
          encryptedText = await _signalService.encryptMessage(contact.databaseId, envelope);
        } else {
          encryptedText = '⚠️ UNENCRYPTED: $plaintext';
        }
      } catch (e2) {
        encryptedText = '⚠️ UNENCRYPTED: $plaintext';
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
    final ourApiKey = _identity!.adapterConfig['token'] ?? '';
    if (contact.provider == 'Firebase') {
      InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
    } else if (contact.provider == 'Nostr') {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final prefs = await SharedPreferences.getInstance();
      final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
      InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
          jsonEncode({'privkey': privkey, 'relay': relay}));
    } else if (contact.provider == 'Waku') {
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      final userId = prefs.getString('waku_identity') ?? '';
      InboxManager().addSenderPlugin('Waku', WakuMessageSender(),
          jsonEncode({'nodeUrl': nodeUrl, 'userId': userId}));
    } else if (contact.provider == 'Oxen') {
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      InboxManager().addSenderPlugin('Oxen', OxenMessageSender(), nodeUrl);
    }
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

    // ── Smart Router: retry via alternate addresses ──────────────────────────
    if (!sent && contact.alternateAddresses.isNotEmpty) {
      final order = [...contact.alternateAddresses]..shuffle();
      for (final alt in order) {
        debugPrint('[SmartRouter] Primary failed, trying alternate: $alt');
        sent = await _deliverEncryptedMessage(alt, msg);
        if (sent) {
          debugPrint('[SmartRouter] Delivered via alternate: $alt');
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
  /// Groups only support files ≤ 512 KB (single chunk).
  Future<void> sendFile(Contact contact, Uint8List bytes, String name) async {
    if (_identity == null) return;
    final chunks = MediaService.chunkPayloads(bytes, name);

    if (chunks.length == 1) {
      // Small file — normal single-message path handles groups too.
      await sendMessage(contact, chunks.first);
      return;
    }

    // Multi-chunk: groups not supported.
    if (contact.isGroup) return;

    // Ensure room exists.
    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: contact.databaseId, contact: contact,
        messages: [], adapterType: contact.provider,
        adapterConfig: {}, updatedAt: DateTime.now(),
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
      adapterType: contact.provider == 'Nostr' ? 'nostr' : 'firebase',
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    final localTtl = _chatTtls[contact.id] ?? 0;
    if (localTtl > 0) _scheduleTtlDelete(contact, localMsg, localTtl);
    notifyListeners();

    bool allSent = true;
    _uploadProgress[msgId] = 0.0;
    for (int i = 0; i < chunks.length; i++) {
      final ok = await _sendToContact(contact, chunks[i]);
      if (!ok) { allSent = false; break; }
      _uploadProgress[msgId] = (i + 1) / chunks.length;
      notifyListeners();
    }
    _uploadProgress.remove(msgId);

    final idx = room.messages.indexWhere((m) => m.id == msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    notifyListeners();
  }

  /// Buffer an incoming chunk and return the assembled media payload once all
  /// chunks for a file ID have arrived, or null if more chunks are expected.
  String? _handleChunk(String chunkPayload) {
    try {
      final map = jsonDecode(chunkPayload) as Map<String, dynamic>;
      final fid = map['fid'] as String;
      final idx = map['idx'] as int;
      final total = map['total'] as int;
      final data = map['d'] as String;

      _pendingChunks[fid] ??= {};
      _pendingChunks[fid]![idx] = base64Decode(data);

      if (idx == 0) {
        _chunkMeta[fid] = (
          name: map['n'] as String? ?? 'file',
          total: total,
          size: (map['sz'] as num?)?.toInt() ?? 0,
          mediaType: map['mt'] as String? ?? 'file',
        );
      }

      if ((_pendingChunks[fid]?.length ?? 0) < total) return null;

      final meta = _chunkMeta[fid];
      if (meta == null) return null;

      final partsList = <Uint8List>[];
      for (int i = 0; i < total; i++) {
        final part = _pendingChunks[fid]![i];
        if (part == null) return null;
        partsList.add(part);
      }
      final totalSize = partsList.fold(0, (s, b) => s + b.length);
      final assembled = Uint8List(totalSize);
      int offset = 0;
      for (final part in partsList) {
        assembled.setRange(offset, offset + part.length, part);
        offset += part.length;
      }

      _pendingChunks.remove(fid);
      _chunkMeta.remove(fid);

      return jsonEncode({
        't': meta.mediaType,
        'd': base64Encode(assembled),
        'n': meta.name,
        'sz': assembled.length,
      });
    } catch (e) {
      debugPrint('[ChatController] Chunk assembly error: $e');
      return null;
    }
  }

  Future<void> deleteLocalMessage(Contact contact, String messageId) async {
    _ttlTimers[messageId]?.cancel();
    _ttlTimers.remove(messageId);
    final room = _chatRooms[contact.id];
    if (room == null) return;
    room.messages.removeWhere((m) => m.id == messageId);
    await LocalStorageService().deleteMessage(contact.storageKey, messageId);
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

  void _handleReadReceipt(String fromId) {
    bool changed = false;
    for (final room in _chatRooms.values) {
      final contactId = room.contact.databaseId;
      if (contactId != fromId && contactId.split('@').first != fromId) continue;
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.status == 'sent') {
          room.messages[i] = m.copyWith(status: 'read');
          unawaited(LocalStorageService().saveMessage(room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> _sendReadReceipt(Contact contact) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      final payload = <String, dynamic>{'from': _selfId};
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (contact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (contact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (contact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (contact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(contact.databaseId, contact.databaseId, _selfId, 'msg_read', payload);
    } catch (e) {
      debugPrint('[ChatController] Read receipt failed: $e');
    }
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

  /// Sends a TTL sync signal directly to the contact's inbox.
  /// Creates a fresh sender each time so it works cross-adapter
  /// (e.g. Firebase user → Nostr contact, where no privkey is available).
  Future<void> _sendTtlSignal(Contact contact, int seconds) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (contact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (contact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (contact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (contact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(
        contact.databaseId, contact.databaseId, _selfId,
        'ttl_update', {'seconds': seconds},
      );
    } catch (e) {
      debugPrint('[ChatController] TTL signal to ${contact.name} failed: $e');
    }
  }

  // ── P2P signaling helpers ───────────────────────────────────────────────────

  /// Send a WebRTC signaling message (offer/answer/ICE) to a contact.
  /// Uses the same fresh-sender pattern as [_sendTtlSignal].
  Future<void> _sendP2PSignal(
    Contact contact,
    String type,
    Map<String, dynamic> payload,
  ) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (contact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (contact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (contact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (contact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(
          contact.databaseId, contact.databaseId, _selfId, type, payload);
    } catch (e) {
      debugPrint('[P2P] Signal $type to ${contact.name} failed: $e');
    }
  }

  /// Deliver a P2P-received (Signal-encrypted) payload as if it arrived
  /// from the contact's normal adapter.
  void _handleP2PMessage(String contactId, String encryptedPayload) {
    final contact = ContactManager().contacts.cast<Contact?>()
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
    final remaining = msg.timestamp
        .add(Duration(seconds: ttlSeconds))
        .difference(DateTime.now());
    _ttlTimers[msg.id]?.cancel();
    if (remaining.isNegative) {
      unawaited(deleteLocalMessage(contact, msg.id));
      return;
    }
    _ttlTimers[msg.id] = Timer(remaining, () {
      _ttlTimers.remove(msg.id);
      unawaited(deleteLocalMessage(contact, msg.id));
    });
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
              prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
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
    } else {
      set.add(key);
    }
    await _persistReactions(storageKey);
    notifyListeners();
    if (contact.isGroup) {
      // Send reaction signal to each group member individually with groupId
      for (final memberId in contact.members) {
        final memberContact = ContactManager().contacts.cast<Contact?>()
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
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reactions_$storageKey');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _reactions[storageKey] ??= {};
      for (final entry in decoded.entries) {
        final list = (entry.value as List).cast<String>();
        _reactions[storageKey]![entry.key] = Set<String>.from(list);
      }
    } catch (_) {}
  }

  Future<void> _persistReactions(String storageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final room = _reactions[storageKey];
    if (room == null || room.isEmpty) {
      await prefs.remove('reactions_$storageKey');
      return;
    }
    final encoded = <String, dynamic>{};
    for (final entry in room.entries) {
      if (entry.value.isNotEmpty) encoded[entry.key] = entry.value.toList();
    }
    await prefs.setString('reactions_$storageKey', jsonEncode(encoded));
  }

  Future<void> _sendReactionSignal(Contact contact, String msgId, String emoji, {
    bool remove = false,
    String? groupId,
  }) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final payload = <String, dynamic>{
        'msgId': msgId, 'emoji': emoji, 'from': _selfId,
        if (remove) 'remove': true,
        'groupId': groupId,
      };
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (contact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (contact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (contact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (contact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(contact.databaseId, contact.databaseId, _selfId, 'reaction', payload);
    } catch (e) {
      debugPrint('[ChatController] Reaction signal failed: $e');
    }
  }

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

  Future<void> _sendEditSignal(Contact contact, String msgId, String text) async {
    if (_identity == null || _selfId.isEmpty) return;
    try {
      final ourApiKey = _identity!.adapterConfig['token'] ?? '';
      MessageSender? sender;
      String senderApiKey = ourApiKey;
      if (contact.provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (contact.provider == 'Nostr') {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final prefs = await SharedPreferences.getInstance();
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        sender = NostrMessageSender();
      } else if (contact.provider == 'Waku') {
        final prefs = await SharedPreferences.getInstance();
        final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
        final userId = prefs.getString('waku_identity') ?? '';
        senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
        sender = WakuMessageSender();
      } else if (contact.provider == 'Oxen') {
        final prefs = await SharedPreferences.getInstance();
        senderApiKey = prefs.getString('oxen_node_url') ?? '';
        sender = OxenMessageSender();
      }
      if (sender == null) return;
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(
        contact.databaseId, contact.databaseId, _selfId,
        'edit', {'msgId': msgId, 'text': text, 'from': _selfId},
      );
    } catch (e) {
      debugPrint('[ChatController] Edit signal failed: $e');
    }
  }

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
    if (diff.inSeconds < 90) return 'online';
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    return 'last seen ${diff.inHours}h ago';
  }

  Future<void> _sendHeartbeats() async {
    if (_identity == null || _selfId.isEmpty) return;
    for (final contact in ContactManager().contacts) {
      if (contact.isGroup) continue;
      try {
        final ourApiKey = _identity!.adapterConfig['token'] ?? '';
        MessageSender? sender;
        String senderApiKey = ourApiKey;
        if (contact.provider == 'Firebase') {
          sender = FirebaseInboxSender();
        } else if (contact.provider == 'Nostr') {
          final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
          final prefs = await SharedPreferences.getInstance();
          final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
          senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
          sender = NostrMessageSender();
        } else if (contact.provider == 'Waku') {
          final prefs = await SharedPreferences.getInstance();
          final nodeUrl = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
          final userId = prefs.getString('waku_identity') ?? '';
          senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
          sender = WakuMessageSender();
        } else if (contact.provider == 'Oxen') {
          final prefs = await SharedPreferences.getInstance();
          senderApiKey = prefs.getString('oxen_node_url') ?? '';
          sender = OxenMessageSender();
        }
        if (sender == null) continue;
        await sender.initializeSender(senderApiKey);
        await sender.sendSignal(
          contact.databaseId, contact.databaseId, _selfId,
          'heartbeat', {'from': _selfId, 'ts': DateTime.now().millisecondsSinceEpoch},
        );
      } catch (_) {}
    }
  }

  // ─── Export Chat History ──────────────────────────────────────────────────

  Future<String?> exportHistory(Contact contact) async {
    final storageKey = contact.storageKey;
    final all = await LocalStorageService().loadMessages(storageKey);
    final myId = _identity?.id ?? '';
    final buf = StringBuffer('=== Chat with ${contact.name} ===\n\n');
    for (final m in all) {
      final msg = Message.fromJson(m);
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
    final existing = jsonDecode(prefs.getString(storageKey) ?? '[]') as List;
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
    final list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
        .where((m) => m['id'] != msg.id)
        .toList();
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
    final list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
        .where((m) => m['id'] != msgId)
        .toList();
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
  }

  /// Restore scheduled messages after app restart — called from initialize().
  Future<void> _restoreScheduledMessages() async {
    final prefs = await SharedPreferences.getInstance();
    for (final contact in ContactManager().contacts) {
      final storageKey = 'scheduled_${contact.id}';
      final raw = prefs.getString(storageKey);
      if (raw == null) continue;
      try {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          final msg = Message.fromJson(item as Map<String, dynamic>);
          if (msg.scheduledAt == null) continue;
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
    for (final s in _messageSubs) { s.cancel(); }
    for (final s in _signalSubs) { s.cancel(); }
    for (final t in _typingTimers.values) { t.cancel(); }
    _typingTimers.clear();
    for (final t in _retryTimers.values) { t.cancel(); }
    _retryTimers.clear();
    for (final t in _ttlTimers.values) { t.cancel(); }
    _ttlTimers.clear();
    _heartbeatTimer?.cancel();
    _typingStreamCtrl.close();
    _incomingCallController.close();
    _incomingGroupCallController.close();
    _signalStreamController.close();
    _newMsgController.close();
    _e2eeFailCtrl.close();
    _statusUpdatesCtrl.close();
    super.dispose();
  }
}
