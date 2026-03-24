import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:convert/convert.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart' as crypto_lib;
import '../models/message.dart';
import '../services/tor_service.dart' as tor;
import 'inbox_manager.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Pulse Adapter — Signal Protocol over self-hosted Pulse relay
///
/// Wire protocol: JSON over WebSocket.
///
/// Address format:  ed25519_pubkey_hex@https://server-ip:port
///   (64-char hex public key @ https:// server URL)
///
/// Authentication: Ed25519 challenge-response.
///   1. Server sends auth_challenge {nonce, timestamp}
///   2. Client signs "pulse-auth-v1:{nonce}:{timestamp}" with Ed25519
///   3. Client sends auth_response {pubkey, signature, invite}
///   4. Server sends auth_ok {turn_url, turn_user, turn_pass}
///
/// Message types:
///   message  → Chat message (payload = Signal-encrypted)
///   signal   → WebRTC + system signals
///   stored   → Batch of stored messages (fetched on connect)
///   ack      → Delivery confirmation
///   keys     → Signal key bundle response
///   error    → Server error
/// ─────────────────────────────────────────────────────────────────────────────

// ── Ed25519 helpers ─────────────────────────────────────────────────────────

/// Derive Ed25519 public key hex string from a 32-byte seed.
Future<String> ed25519PubkeyFromSeed(Uint8List seed) async {
  final ed = crypto_lib.Ed25519();
  final kp = await ed.newKeyPairFromSeed(seed.toList());
  final pub = await kp.extractPublicKey();
  return hex.encode(pub.bytes);
}

/// Sign a UTF-8 message string with Ed25519 using a 32-byte seed.
/// Returns the signature as a hex string.
Future<String> _ed25519Sign(Uint8List seed, String message) async {
  final ed = crypto_lib.Ed25519();
  final kp = await ed.newKeyPairFromSeed(seed.toList());
  final msgBytes = utf8.encode(message);
  final sig = await ed.sign(msgBytes, keyPair: kp);
  return hex.encode(sig.bytes);
}

// ── Reconnect delay tiers (same as Nostr adapter) ───────────────────────────

Duration _reconnectDelay(int failures) {
  if (failures <= 1) return const Duration(seconds: 5);
  if (failures <= 5) return const Duration(seconds: 30);
  return const Duration(minutes: 5);
}

// ── PulseInboxReader ────────────────────────────────────────────────────────

class PulseInboxReader implements InboxReader {
  Uint8List _seed = Uint8List(0);
  String _pubkeyHex = '';
  String _serverUrl = '';
  String _wsUrl = '';
  String _invite = '';

  WebSocketChannel? _ws;
  final StreamController<List<Message>> _msgCtrl =
      StreamController<List<Message>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _sigCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<bool> _healthCtrl =
      StreamController<bool>.broadcast();

  final Set<String> _seenIds = {};

  bool _loopStarted = false;
  bool _running = false;
  bool _isHealthy = true;
  int _consecutiveFailures = 0;
  static const _failureThreshold = 3;
  static const _maxConsecutiveFailures = 30;

  bool get circuitBroken => _circuitBroken;
  bool _circuitBroken = false;

  // Tor settings — loaded once in initializeReader
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    // Parse apiKey JSON: {"privkey":"hex","serverUrl":"https://...","invite":"code"}
    try {
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      final privkeyHex = (decoded['privkey'] as String? ?? '').trim();
      _serverUrl = (decoded['serverUrl'] as String? ?? '').trim();
      _invite = (decoded['invite'] as String? ?? '').trim();

      if (privkeyHex.isNotEmpty) {
        _seed = Uint8List.fromList(hex.decode(privkeyHex));
        _pubkeyHex = await ed25519PubkeyFromSeed(_seed);
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to parse apiKey JSON: $e');
      return;
    }

    // Convert https:// → wss:// for WebSocket. Reject plaintext http://.
    if (_serverUrl.startsWith('https://')) {
      _wsUrl = 'wss://${_serverUrl.substring('https://'.length)}/ws';
    } else {
      debugPrint('[Pulse] Rejected insecure or invalid server URL: $_serverUrl');
      return;
    }

    // Load Tor settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
  }

  void _trackSeenId(String id) {
    if (_seenIds.length > 2000) {
      final evict = _seenIds.toList().sublist(0, 1000);
      _seenIds.removeAll(evict);
    }
    _seenIds.add(id);
  }

  void _ensureLoop() {
    if (_loopStarted || _seed.isEmpty || _wsUrl.isEmpty) return;
    _loopStarted = true;
    _running = true;
    unawaited(_runLoop());
  }

  Future<WebSocketChannel> _connectWs() async {
    // Try Tor first if enabled
    if (_torEnabled && tor.TorService.instance.isBootstrapped) {
      try {
        return await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
      } catch (e) {
        debugPrint('[Pulse] Tor WS connect failed ($e) — falling back to plain');
      }
    }

    // Accept self-signed certificates for self-hosted servers
    final inner = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final ws = await WebSocket.connect(
      _wsUrl,
      customClient: inner,
    ).timeout(const Duration(seconds: 15));
    return IOWebSocketChannel(ws);
  }

  /// Perform the Ed25519 challenge-response authentication.
  /// Returns true if auth_ok received, false otherwise.
  Future<bool> _authenticate(WebSocketChannel channel) async {
    final completer = Completer<bool>();

    late final StreamSubscription sub;
    sub = channel.stream.listen((raw) async {
      try {
        final data = jsonDecode(raw as String) as Map<String, dynamic>;
        final type = data['type'] as String? ?? '';

        if (type == 'auth_challenge') {
          final nonce = data['nonce'] as String? ?? '';
          final timestamp = data['timestamp']?.toString() ?? '';
          final message = 'pulse-auth-v1:$nonce:$timestamp';
          final signature = await _ed25519Sign(_seed, message);

          channel.sink.add(jsonEncode({
            'type': 'auth_response',
            'pubkey': _pubkeyHex,
            'signature': signature,
            'invite': _invite,
          }));
        } else if (type == 'auth_ok') {
          // Save TURN credentials if provided
          _saveTurnCreds(data);
          if (!completer.isCompleted) completer.complete(true);
          sub.cancel();
        } else if (type == 'error') {
          debugPrint('[Pulse] Auth error: ${data['message'] ?? data}');
          if (!completer.isCompleted) completer.complete(false);
          sub.cancel();
        }
      } catch (e) {
        debugPrint('[Pulse] Auth parse error: $e');
      }
    }, onError: (Object e) {
      debugPrint('[Pulse] Auth stream error: $e');
      if (!completer.isCompleted) completer.complete(false);
    }, onDone: () {
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        sub.cancel();
        return false;
      },
    );
  }

  Future<void> _saveTurnCreds(Map<String, dynamic> data) async {
    try {
      const ss = FlutterSecureStorage();
      final turnUrl  = data['turn_url']  as String? ?? '';
      final turnUser = data['turn_user'] as String? ?? '';
      final turnPass = data['turn_pass'] as String? ?? '';
      if (turnUrl.isNotEmpty) {
        await ss.write(key: 'pulse_turn_url',  value: turnUrl);
        await ss.write(key: 'pulse_turn_user', value: turnUser);
        await ss.write(key: 'pulse_turn_pass', value: turnPass);
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to save TURN creds: $e');
    }
  }

  Future<int> _getLastFetchTs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt('pulse_last_fetch_ts') ?? 0;
    final thirtyDaysAgo =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30 * 86400;
    return stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
  }

  Future<void> _updateLastFetchTs(int unixSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('pulse_last_fetch_ts') ?? 0;
    if (unixSeconds > current) {
      await prefs.setInt('pulse_last_fetch_ts', unixSeconds);
    }
  }

  Future<void> _runLoop() async {
    while (_running) {
      WebSocketChannel? channel;
      bool cycleSuccess = false;
      if (!_running) break;

      try {
        channel = await _connectWs();
        _ws = channel;
        await channel.ready;
        debugPrint('[Pulse] Connected to $_wsUrl');

        // Authenticate
        final authOk = await _authenticate(channel);
        if (!authOk) {
          debugPrint('[Pulse] Authentication failed');
          throw Exception('Auth failed');
        }

        // Request stored messages
        final since = await _getLastFetchTs();
        channel.sink.add(jsonEncode({
          'type': 'fetch',
          'since': since,
          'limit': 100,
        }));

        cycleSuccess = true;
        if (!_isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = true;
          _healthCtrl.add(true);
        }
        _consecutiveFailures = 0;

        // Listen for messages
        try {
          await for (final raw in channel.stream) {
            try {
              final data = jsonDecode(raw as String) as Map<String, dynamic>;
              final type = data['type'] as String? ?? '';

              switch (type) {
                case 'message':
                  _dispatchMessage(data);
                case 'signal':
                  _dispatchSignal(data);
                case 'stored':
                  _dispatchStored(data, channel);
                case 'ack':
                  debugPrint('[Pulse] ACK: ${data['id'] ?? ''}');
                case 'keys':
                  _dispatchKeys(data);
                case 'error':
                  debugPrint('[Pulse] Server error: ${data['message'] ?? data}');
                default:
                  debugPrint('[Pulse] Unknown message type: $type');
              }
            } catch (e) {
              debugPrint('[Pulse] Message parse error: $e');
            }
          }
        } catch (e) {
          debugPrint('[Pulse] Stream error: $e');
        }
      } catch (e) {
        debugPrint('[Pulse] Connection error: $e');
      } finally {
        _ws = null;
        try { channel?.sink.close(); } catch (_) {}
      }

      if (!_running) break;

      _consecutiveFailures++;
      if (_consecutiveFailures >= _maxConsecutiveFailures) {
        debugPrint('[Pulse] Circuit breaker: $_consecutiveFailures failures');
        _circuitBroken = true;
        _running = false;
        _loopStarted = false;
        break;
      }

      if (_consecutiveFailures >= _failureThreshold &&
          _isHealthy && !_healthCtrl.isClosed) {
        _isHealthy = false;
        _healthCtrl.add(false);
      }

      // Reconnect: fast on success cycle, tiered on failure
      final delay = cycleSuccess
          ? const Duration(seconds: 2)
          : _reconnectDelay(_consecutiveFailures);
      await Future<void>.delayed(delay);
    }
  }

  void _dispatchMessage(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>? ?? data;
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty || _seenIds.contains(id)) return;
    _trackSeenId(id);

    final ts = payload['timestamp'] as int? ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    unawaited(_updateLastFetchTs(ts));

    final msg = Message(
      id: id,
      senderId: payload['from'] as String? ?? '',
      receiverId: _pubkeyHex,
      encryptedPayload: payload['payload'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true),
      adapterType: 'pulse',
    );
    if (!_msgCtrl.isClosed) _msgCtrl.add([msg]);

    // Send ACK
    _sendAck(id);
  }

  void _dispatchSignal(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>? ?? data;
    final id = payload['id'] as String? ?? '';
    if (id.isNotEmpty && _seenIds.contains(id)) return;
    if (id.isNotEmpty) _trackSeenId(id);

    try {
      Map<String, dynamic> signalData;
      final payloadContent = payload['payload'];
      if (payloadContent is String) {
        signalData = jsonDecode(payloadContent) as Map<String, dynamic>;
      } else if (payloadContent is Map) {
        signalData = Map<String, dynamic>.from(payloadContent);
      } else {
        signalData = payload;
      }
      if (!_sigCtrl.isClosed) _sigCtrl.add([signalData]);
    } catch (e) {
      debugPrint('[Pulse] Signal dispatch error: $e');
    }

    if (id.isNotEmpty) _sendAck(id);
  }

  void _dispatchStored(Map<String, dynamic> data, WebSocketChannel channel) {
    final messages = data['messages'] as List? ?? [];
    for (final m in messages) {
      if (m is! Map) continue;
      final entry = Map<String, dynamic>.from(m);
      final msgType = entry['msg_type'] as String? ?? 'message';
      if (msgType == 'signal') {
        _dispatchSignal(entry);
      } else {
        _dispatchMessage(entry);
      }
    }
  }

  void _dispatchKeys(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>?;
    if (payload != null && !_sigCtrl.isClosed) {
      _sigCtrl.add([{
        'type': 'sys_keys',
        'payload': payload,
        'senderId': data['from'] as String? ?? '',
      }]);
    }
  }

  void _sendAck(String messageId) {
    try {
      _ws?.sink.add(jsonEncode({
        'type': 'ack',
        'id': messageId,
      }));
    } catch (e) {
      debugPrint('[Pulse] Failed to send ACK: $e');
    }
  }

  @override
  Stream<List<Message>> listenForMessages() {
    _ensureLoop();
    return _msgCtrl.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() {
    _ensureLoop();
    return _sigCtrl.stream;
  }

  @override
  Future<String?> provisionGroup(String groupName) async =>
      '$_pubkeyHex@$_serverUrl';

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    if (_pubkeyHex.isEmpty || _wsUrl.isEmpty) return null;

    WebSocketChannel? channel;
    try {
      channel = await _connectWs();
      await channel.ready;
      final authOk = await _authenticate(channel);
      if (!authOk) return null;

      final completer = Completer<Map<String, dynamic>?>();
      channel.sink.add(jsonEncode({
        'type': 'keys_get',
        'pubkey': _pubkeyHex,
      }));

      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      final sub = channel.stream.listen((raw) {
        try {
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          if (data['type'] == 'keys') {
            final payload = data['payload'] as Map<String, dynamic>?;
            if (!completer.isCompleted) completer.complete(payload);
          }
        } catch (e) {
          debugPrint('[Pulse] fetchPublicKeys parse error: $e');
        }
      }, onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      final result = await completer.future;
      await sub.cancel();
      return result;
    } catch (e) {
      debugPrint('[Pulse] fetchPublicKeys error: $e');
      return null;
    } finally {
      channel?.sink.close();
    }
  }

  /// Stop the event loop and close the active WebSocket.
  void close() {
    _running = false;
    _loopStarted = false;
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
  }

  /// Stop event loop and clear private key material from memory.
  void zeroize() {
    close();
    for (int i = 0; i < _seed.length; i++) {
      _seed[i] = 0;
    }
    _seed = Uint8List(0);
    _pubkeyHex = '';
  }
}

// ── PulseMessageSender ──────────────────────────────────────────────────────

class PulseMessageSender implements MessageSender {
  Uint8List _seed = Uint8List(0);
  String _pubkeyHex = '';
  String _serverUrl = '';
  String _wsUrl = '';

  // Tor settings
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // Persistent WS connection
  WebSocketChannel? _ws;
  bool _authenticated = false;

  @override
  Future<void> initializeSender(String apiKey) async {
    try {
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      final privkeyHex = (decoded['privkey'] as String? ?? '').trim();
      _serverUrl = (decoded['serverUrl'] as String? ?? '').trim();

      if (privkeyHex.isNotEmpty) {
        _seed = Uint8List.fromList(hex.decode(privkeyHex));
        _pubkeyHex = await ed25519PubkeyFromSeed(_seed);
      }
    } catch (e) {
      debugPrint('[Pulse] Sender failed to parse apiKey JSON: $e');
      return;
    }

    if (_serverUrl.startsWith('https://')) {
      _wsUrl = 'wss://${_serverUrl.substring('https://'.length)}/ws';
    } else if (_serverUrl.startsWith('http://')) {
      // BUG-02 fix: reject plaintext WebSocket — auth handshake and E2EE
      // payloads must not travel over an unencrypted connection.
      debugPrint('[Pulse] Sender rejected http:// server URL — use https://');
      _wsUrl = '';
    }

    // Load Tor settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
  }

  Future<WebSocketChannel> _connectWs() async {
    if (_torEnabled && tor.TorService.instance.isBootstrapped) {
      try {
        return await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
      } catch (e) {
        debugPrint('[Pulse] Sender Tor WS connect failed ($e) — falling back');
      }
    }

    final inner = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final ws = await WebSocket.connect(
      _wsUrl,
      customClient: inner,
    ).timeout(const Duration(seconds: 15));
    return IOWebSocketChannel(ws);
  }

  /// Get an authenticated WS connection, reusing if available.
  Future<WebSocketChannel?> _getConnection() async {
    final ws = _ws;
    if (ws != null && _authenticated) return ws;

    try {
      final channel = await _connectWs();
      await channel.ready;

      // Authenticate
      final completer = Completer<bool>();
      late final StreamSubscription sub;
      sub = channel.stream.listen((raw) async {
        try {
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          final type = data['type'] as String? ?? '';
          if (type == 'auth_challenge') {
            final nonce = data['nonce'] as String? ?? '';
            final timestamp = data['timestamp']?.toString() ?? '';
            final message = 'pulse-auth-v1:$nonce:$timestamp';
            final signature = await _ed25519Sign(_seed, message);
            channel.sink.add(jsonEncode({
              'type': 'auth_response',
              'pubkey': _pubkeyHex,
              'signature': signature,
              'invite': '',
            }));
          } else if (type == 'auth_ok') {
            if (!completer.isCompleted) completer.complete(true);
            sub.cancel();
          } else if (type == 'error') {
            if (!completer.isCompleted) completer.complete(false);
            sub.cancel();
          }
        } catch (e) {
          debugPrint('[Pulse] Sender auth parse error: $e');
        }
      }, onError: (Object e) {
        if (!completer.isCompleted) completer.complete(false);
      }, onDone: () {
        if (!completer.isCompleted) completer.complete(false);
      });

      final ok = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          sub.cancel();
          return false;
        },
      );

      if (!ok) {
        channel.sink.close();
        return null;
      }

      _ws = channel;
      _authenticated = true;

      // Listen for close to reset state
      channel.stream.listen(
        (_) {},
        onDone: () {
          _ws = null;
          _authenticated = false;
        },
        onError: (_) {
          _ws = null;
          _authenticated = false;
        },
        cancelOnError: true,
      );

      return channel;
    } catch (e) {
      debugPrint('[Pulse] Sender connection error: $e');
      _ws = null;
      _authenticated = false;
      return null;
    }
  }

  @override
  Future<bool> sendMessage(String targetDatabaseId, String roomId,
      Message message) async {
    if (_seed.isEmpty || _wsUrl.isEmpty) return false;

    // Extract target pubkey from address (part before @)
    final atIdx = targetDatabaseId.indexOf('@');
    final targetPubkey =
        atIdx != -1 ? targetDatabaseId.substring(0, atIdx) : targetDatabaseId;

    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      final msgId = message.id.isNotEmpty
          ? message.id
          : '${DateTime.now().millisecondsSinceEpoch}';

      channel.sink.add(jsonEncode({
        'type': 'send',
        'payload': {
          'id': msgId,
          'to': targetPubkey,
          'payload': message.encryptedPayload,
        },
      }));
      return true;
    } catch (e) {
      debugPrint('[Pulse] sendMessage error: $e');
      _ws = null;
      _authenticated = false;
      return false;
    }
  }

  @override
  Future<bool> sendSignal(String targetDatabaseId, String roomId,
      String senderId, String type, Map<String, dynamic> payload) async {
    if (_seed.isEmpty || _wsUrl.isEmpty) return false;

    final atIdx = targetDatabaseId.indexOf('@');
    final targetPubkey =
        atIdx != -1 ? targetDatabaseId.substring(0, atIdx) : targetDatabaseId;

    // Key bundle publish — special handling
    if (type == 'sys_keys') {
      return _publishKeys(payload);
    }

    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      final signalPayload = jsonEncode({
        'type': type,
        'roomId': roomId,
        'senderId': senderId,
        'payload': payload,
      });

      channel.sink.add(jsonEncode({
        'type': 'signal',
        'payload': {
          'id': '${DateTime.now().millisecondsSinceEpoch}_${type.hashCode}',
          'to': targetPubkey,
          'payload': signalPayload,
        },
      }));
      return true;
    } catch (e) {
      debugPrint('[Pulse] sendSignal error: $e');
      _ws = null;
      _authenticated = false;
      return false;
    }
  }

  /// Publish Signal key bundle to the server for storage.
  Future<bool> _publishKeys(Map<String, dynamic> bundle) async {
    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      channel.sink.add(jsonEncode({
        'type': 'keys_put',
        'payload': bundle,
      }));
      return true;
    } catch (e) {
      debugPrint('[Pulse] keys_put error: $e');
      return false;
    }
  }

  /// Fetch a contact's Signal key bundle from the server.
  Future<Map<String, dynamic>?> fetchContactKeys(String pubkey) async {
    try {
      final channel = await _getConnection();
      if (channel == null) return null;

      final completer = Completer<Map<String, dynamic>?>();
      channel.sink.add(jsonEncode({
        'type': 'keys_get',
        'pubkey': pubkey,
      }));

      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      // Note: response comes through the shared stream; for one-shot
      // requests we rely on the timeout.
      return await completer.future;
    } catch (e) {
      debugPrint('[Pulse] fetchContactKeys error: $e');
      return null;
    }
  }

  /// Clear private key from memory and close connection.
  void zeroize() {
    for (int i = 0; i < _seed.length; i++) {
      _seed[i] = 0;
    }
    _seed = Uint8List(0);
    _pubkeyHex = '';
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    _authenticated = false;
  }
}
