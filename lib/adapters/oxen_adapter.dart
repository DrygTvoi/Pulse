import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/message.dart';
import '../services/oxen_key_service.dart';
import '../services/tor_service.dart' as tor;
import 'inbox_manager.dart';

// Session network seed nodes — clearnet, standard TLS.
// These return the active snode pool via json_rpc.
const _seedNodes = [
  'https://seed1.getsession.org',
  'https://seed2.getsession.org',
  'https://seed3.getsession.org',
];

const _ttlMs = 14 * 24 * 60 * 60 * 1000; // 14-day TTL (Session standard)

// Snodes use self-signed certificates — accepted because payload is already
// Signal-encrypted E2E. When Tor is running, connections are tunneled through it.
http.Client _newSnodeClient() {
  final inner = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  return IOClient(inner);
}

/// Discover active snodes from Session seed nodes.
/// Returns a list of "https://ip:port" strings, or empty on failure.
Future<List<String>> _discoverSnodes() async {
  final client = tor.buildTorHttpClient() ?? http.Client();
  try {
  for (final seed in _seedNodes) {
    try {
      final res = await client.post(
        Uri.parse('$seed/json_rpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'get_n_service_nodes',
          'params': {
            'active_only': true,
            'limit': 20,
            'fields': {'public_ip': true, 'storage_port': true},
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) continue;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final states = (data['result']?['service_node_states'] as List?) ?? [];
      final nodes = <String>[];
      for (final s in states) {
        final ip = s['public_ip'] as String? ?? '';
        final port = s['storage_port'];
        if (ip.isNotEmpty && port != null) {
          nodes.add('https://$ip:$port');
        }
      }
      if (nodes.isNotEmpty) {
        debugPrint('[Oxen] Discovered ${nodes.length} snodes via $seed');
        return nodes;
      }
    } catch (e) {
      debugPrint('[Oxen] Seed $seed error: $e');
    }
  }
  } finally {
    client.close();
  }
  return [];
}

// ─── InboxReader ──────────────────────────────────────────────────────────────

/// Polls an Oxen/Session storage snode every 2 s and dispatches messages
/// and signals. Authentication uses Ed25519 derived from the same seed as the
/// Session ID so only the key owner can retrieve.
class OxenInboxReader implements InboxReader {
  String _nodeUrl = '';
  String _sessionId = '';
  bool _usingDiscovery = false; // true when using auto-discovered snodes
  List<String> _snodes = [];
  int _snodeIndex = 0;

  final _msgCtrl = StreamController<List<Message>>.broadcast();
  final _sigCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _seenHashes = <String>{};

  bool _loopStarted = false;
  String _lastHash = '';
  int _pollDelay = 2;

  final _healthCtrl = StreamController<bool>.broadcast();
  int _consecutiveFailures = 0;
  bool _isHealthy = true;
  static const _failureThreshold = 5;

  // ── Persistent HTTP client — reused across polls; rebuilt when Tor status changes
  http.Client? _httpClient;
  bool _torActive = false;

  http.Client get _client {
    final torNow = tor.TorService.instance.isRunning;
    if (_httpClient == null || torNow != _torActive) {
      _httpClient?.close();
      _torActive = torNow;
      _httpClient = torNow
          ? (tor.buildTorHttpClient(acceptBadCertificate: true) ?? _newSnodeClient())
          : _newSnodeClient();
    }
    return _httpClient!;
  }

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    _sessionId = databaseId;
    await OxenKeyService.instance.initialize();
    if (apiKey.isNotEmpty) {
      _nodeUrl = apiKey;
      _usingDiscovery = false;
    } else {
      _usingDiscovery = true;
      // Discovery happens lazily in _runLoop
    }
    if (_sessionId == OxenKeyService.instance.sessionId) {
      _ensureLoop();
    }
  }

  void _ensureLoop() {
    if (_loopStarted) return;
    _loopStarted = true;
    unawaited(_runLoop());
  }

  Future<void> _runLoop() async {
    // If using discovery, fetch snodes first
    if (_usingDiscovery) {
      _snodes = await _discoverSnodes();
      if (_snodes.isEmpty) {
        debugPrint('[Oxen] No snodes discovered — check network connectivity');
        // Retry discovery after 60s
        await Future.delayed(const Duration(seconds: 60));
        unawaited(_runLoop());
        return;
      }
      _nodeUrl = _snodes[_snodeIndex];
    }

    while (true) {
      try {
        await _poll();
        _pollDelay = 2;
        _consecutiveFailures = 0;
        if (!_isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = true;
          _healthCtrl.add(true);
        }
      } catch (e) {
        final isConnErr = e.toString().contains('HandshakeException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException');
        if (isConnErr && _usingDiscovery && _snodes.isNotEmpty) {
          _snodeIndex = (_snodeIndex + 1) % _snodes.length;
          _nodeUrl = _snodes[_snodeIndex];
          debugPrint('[Oxen] Switching snode → $_nodeUrl');
        } else {
          debugPrint('[Oxen] Poll error: $e');
        }
        _consecutiveFailures++;
        if (_consecutiveFailures >= _failureThreshold && _isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = false;
          _healthCtrl.add(false);
        }
        _pollDelay = (_pollDelay * 2).clamp(2, 30);
      }
      await Future.delayed(Duration(seconds: _pollDelay));
    }
  }

  Future<void> _poll() async {
    final tsMs = DateTime.now().millisecondsSinceEpoch;
    final msg = 'retrieve$_sessionId$tsMs';
    final sigBytes = await OxenKeyService.instance.sign(utf8.encode(msg));
    final sig = base64.encode(sigBytes);

    final res = await _client.post(
      Uri.parse('$_nodeUrl/storage_rpc/v1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'method': 'retrieve',
        'params': {
          'pubkey': _sessionId,
          'last_hash': _lastHash,
          'timestamp': tsMs,
          'signature': sig,
        },
      }),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>? ?? {};
    final messages =
        (result['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    for (final item in messages) {
      final hash = item['hash'] as String? ?? '';
      if (hash.isNotEmpty) {
        if (_seenHashes.contains(hash)) continue;
        _seenHashes.add(hash);
        _lastHash = hash;
        if (_seenHashes.length > 3000) {
          _seenHashes.removeAll(_seenHashes.take(1500).toList());
        }
      }
      _dispatch(item);
    }
  }

  void _dispatch(Map<String, dynamic> item) {
    try {
      final raw = item['data'] as String? ?? '';
      if (raw.isEmpty) return;
      if (raw.length > 700000) return; // DoS guard ~700 KB
      final bytes = base64.decode(raw);
      final outer = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final ts = (item['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch;

      if (outer['t'] == 'sig') {
        _sigCtrl.add([{
          'type': outer['type'],
          'senderId': outer['senderId'],
          'roomId': outer['roomId'],
          'payload': outer['payload'],
        }]);
      } else {
        _msgCtrl.add([Message(
          id: item['hash'] as String? ?? ts.toString(),
          senderId: outer['from'] as String? ?? '',
          receiverId: _sessionId,
          encryptedPayload: outer['payload'] as String? ?? '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
          adapterType: 'oxen',
        )]);
      }
    } catch (e) {
      debugPrint('[Oxen] Dispatch error: $e');
    }
  }

  @override
  Stream<List<Message>> listenForMessages() => _msgCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() => _sigCtrl.stream;

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    if (_nodeUrl.isEmpty) return null;
    try {
      final res = await _client.post(
        Uri.parse('$_nodeUrl/storage_rpc/v1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'method': 'retrieve',
          'params': {'pubkey': _sessionId, 'last_hash': ''},
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>? ?? {};
      final messages =
          (result['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      for (final item in messages.reversed) {
        try {
          final raw = item['data'] as String? ?? '';
          if (raw.isEmpty) continue;
          final bytes = base64.decode(raw);
          final outer = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
          if (outer['t'] == 'sig' && outer['type'] == 'sys_keys') {
            final p = outer['payload'];
            if (p is Map<String, dynamic>) return p;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[Oxen] fetchPublicKeys error: $e');
    }
    return null;
  }

  @override
  Future<String?> provisionGroup(String groupName) async => _sessionId;
}

// ─── MessageSender ────────────────────────────────────────────────────────────

class OxenMessageSender implements MessageSender {
  String _nodeUrl = '';
  String _selfSessionId = '';
  List<String> _snodes = [];

  // ── Persistent HTTP client — reused across stores; rebuilt when Tor status changes
  http.Client? _httpClient;
  bool _torActive = false;

  http.Client get _client {
    final torNow = tor.TorService.instance.isRunning;
    if (_httpClient == null || torNow != _torActive) {
      _httpClient?.close();
      _torActive = torNow;
      _httpClient = torNow
          ? (tor.buildTorHttpClient(acceptBadCertificate: true) ?? _newSnodeClient())
          : _newSnodeClient();
    }
    return _httpClient!;
  }

  @override
  Future<void> initializeSender(String apiKey) async {
    await OxenKeyService.instance.initialize();
    _selfSessionId = OxenKeyService.instance.sessionId;
    if (apiKey.isNotEmpty) {
      _nodeUrl = apiKey;
    } else {
      // Discover snodes lazily on first send
      _snodes = await _discoverSnodes();
      if (_snodes.isNotEmpty) _nodeUrl = _snodes.first;
    }
  }

  Future<bool> _store(
      String recipientSessionId, Map<String, dynamic> body) async {
    // Build candidate list: configured node first, then discovered snodes
    final candidates = <String>{
      if (_nodeUrl.isNotEmpty) _nodeUrl,
      ..._snodes,
    }.toList();
    for (final node in candidates) {
      if (await _tryStore(node, recipientSessionId, body)) return true;
    }
    return false;
  }

  Future<bool> _tryStore(
      String node, String recipientSessionId, Map<String, dynamic> body) async {
    try {
      final payload = base64.encode(utf8.encode(jsonEncode(body)));
      final res = await _client.post(
        Uri.parse('$node/storage_rpc/v1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'method': 'store',
          'params': {
            'pubkey': recipientSessionId,
            'ttl': _ttlMs,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'data': payload,
          },
        }),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Oxen] Store error on $node: $e');
      return false;
    }
  }

  @override
  Future<bool> sendMessage(
      String targetDatabaseId, String roomId, Message message) async {
    return _store(targetDatabaseId, {
      't': 'msg',
      'from': _selfSessionId,
      'payload': message.encryptedPayload,
    });
  }

  @override
  Future<bool> sendSignal(
    String targetDatabaseId,
    String roomId,
    String senderId,
    String type,
    Map<String, dynamic> payload,
  ) async {
    if (type == 'sys_keys') {
      final body = {'t': 'sig', 'type': type, 'senderId': senderId,
          'roomId': roomId, 'payload': payload};
      final toSelf = _store(_selfSessionId, body);
      if (targetDatabaseId != _selfSessionId) {
        await _store(targetDatabaseId, body);
      }
      return toSelf;
    }
    return _store(targetDatabaseId, {
      't': 'sig',
      'type': type,
      'senderId': senderId,
      'roomId': roomId,
      'payload': payload,
    });
  }
}
