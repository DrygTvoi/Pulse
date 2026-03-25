import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/message.dart';
import '../services/oxen_key_service.dart';
import 'inbox_manager.dart';

// Session network seed nodes — clearnet, standard TLS.
// These return the active snode pool via json_rpc.
const _seedNodes = [
  'https://seed1.getsession.org',
  'https://seed2.getsession.org',
  'https://seed3.getsession.org',
];

const _ttlMs = 14 * 24 * 60 * 60 * 1000; // 14-day TTL (Session standard)

// Standard TLS client for seed nodes (CA-signed certificates).
http.Client _newSeedClient() => http.Client();

// Snodes use self-signed certificates — accepted because payload is already
// Signal-encrypted E2E.  Session has built-in onion routing (multi-hop via
// snodes), so we never tunnel snode traffic through external proxies (Tor,
// Psiphon, etc.) — SOCKS5 proxies fail on snode connections.
http.Client _newSnodeClient() {
  final inner = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  return IOClient(inner);
}

/// Discover active snodes from Session seed nodes.
/// Returns a list of "https://ip:port" strings, or empty on failure.
/// Always uses direct clearnet — Session snodes have built-in onion routing.
Future<List<String>> _discoverSnodes() async {
  final client = _newSeedClient();
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
      const maxBodyBytes = 10 * 1024 * 1024; // 10 MB
      if (res.contentLength != null && res.contentLength! > maxBodyBytes) {
        debugPrint('[Oxen] Seed response too large — skipping $seed');
        continue;
      }
      if (res.body.length > maxBodyBytes) {
        debugPrint('[Oxen] Seed response body too large — skipping $seed');
        continue;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final states = (data['result']?['service_node_states'] as List?) ?? [];
      final nodes = <String>[];
      for (final s in states) {
        final ip = s['public_ip'] as String? ?? '';
        final port = s['storage_port'];
        if (ip.isEmpty || port == null) continue;
        // F10: Reject private/loopback IPs returned by seed nodes.
        if (_isPrivateSnodeIp(ip)) continue;
        final portNum = port is int ? port : int.tryParse(port.toString()) ?? -1;
        if (portNum < 1 || portNum > 65535) continue;
        nodes.add('https://$ip:$portNum');
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

/// Returns true if [ip] is a private, loopback, link-local, or otherwise
/// reserved address that should never appear as a public Session snode.
bool _isPrivateSnodeIp(String ip) {
  if (ip == 'localhost' || ip == '127.0.0.1' || ip == '::1') return true;
  if (ip.startsWith('10.')) return true;
  if (ip.startsWith('192.168.')) return true;
  if (ip.startsWith('169.254.')) return true;
  if (ip.startsWith('172.')) {
    final parts = ip.split('.');
    if (parts.length >= 2) {
      final second = int.tryParse(parts[1]) ?? 0;
      if (second >= 16 && second <= 31) return true;
    }
  }
  // RFC 6598 — carrier-grade NAT (100.64.0.0/10)
  if (ip.startsWith('100.')) {
    final parts = ip.split('.');
    if (parts.length >= 2) {
      final second = int.tryParse(parts[1]) ?? 0;
      if (second >= 64 && second <= 127) return true;
    }
  }
  if (ip.startsWith('0.')) return true;
  // IPv6 ULA (fc00::/7)
  if (ip.startsWith('fc') || ip.startsWith('fd')) return true;
  return false;
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

  // ── Adaptive polling — reduces bandwidth when idle ──────────────────────
  DateTime _lastActivity = DateTime.now();

  int get _adaptivePollDelay {
    final idle = DateTime.now().difference(_lastActivity);
    if (idle < const Duration(seconds: 10)) return 3;    // active
    if (idle < const Duration(seconds: 60)) return 30;   // idle
    return 300;                                            // deep idle (5 min)
  }

  final _healthCtrl = StreamController<bool>.broadcast();
  int _consecutiveFailures = 0;
  bool _isHealthy = true;
  static const _failureThreshold = 5;
  static const _maxConsecutiveFailures = 30;

  /// True when the poll loop stopped after [_maxConsecutiveFailures] failures.
  bool get circuitBroken => _circuitBroken;
  bool _circuitBroken = false;

  // Session snodes have built-in onion routing — always direct, no proxy.
  http.Client? _httpClient;

  http.Client get _client {
    _httpClient ??= _newSnodeClient();
    return _httpClient!;
  }

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  static final _sessionIdRegex = RegExp(r'^05[0-9a-fA-F]{64}$');

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    if (databaseId.isNotEmpty && !_sessionIdRegex.hasMatch(databaseId)) {
      debugPrint('[Oxen] Rejected invalid session ID format: $databaseId');
      return;
    }
    _sessionId = databaseId;
    await OxenKeyService.instance.initialize();
    if (apiKey.isNotEmpty) {
      // BUG-04 fix: validate the node URL starts with https:// before storing.
      // An attacker-controlled apiKey with a crafted URL could redirect
      // Oxen JSON-RPC calls (including auth signatures) to a malicious server.
      if (!apiKey.startsWith('https://')) {
        debugPrint('[Oxen] Rejected non-HTTPS node URL: $apiKey');
        _usingDiscovery = true;
        return;
      }
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
    // If using discovery, fetch snodes first (bounded retries)
    if (_usingDiscovery) {
      for (int attempt = 0; attempt < 10; attempt++) {
        _snodes = await _discoverSnodes();
        if (_snodes.isNotEmpty) break;
        debugPrint('[Oxen] No snodes discovered (attempt ${attempt + 1}/10)');
        await Future.delayed(const Duration(seconds: 60));
      }
      if (_snodes.isEmpty) {
        debugPrint('[Oxen] Discovery failed after 10 attempts — stopping');
        _circuitBroken = true;
        return;
      }
      _nodeUrl = _snodes[_snodeIndex];
    }

    while (true) {
      int pollDelay;
      try {
        await _poll();
        pollDelay = _adaptivePollDelay;
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
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          debugPrint('[Oxen] Max retries ($_maxConsecutiveFailures) reached, stopping');
          _circuitBroken = true;
          break;
        }
        // Tiered delay: 5s for first 5 failures, 30s up to 15, then 5min
        pollDelay = (_consecutiveFailures < 5) ? 5
            : (_consecutiveFailures < 15) ? 30
            : 300;
      }
      await Future.delayed(Duration(seconds: pollDelay));
    }
  }

  Future<void> _poll() async {
    final tsMs = DateTime.now().millisecondsSinceEpoch;
    final msg = 'retrieve$_sessionId$tsMs';
    final sigBytes = await OxenKeyService.instance.sign(utf8.encode(msg));
    final sig = base64.encode(sigBytes);

    final jsonBody = jsonEncode({
      'method': 'retrieve',
      'params': {
        'pubkey': _sessionId,
        'last_hash': _lastHash,
        'timestamp': tsMs,
        'signature': sig,
      },
    });

    final url = '$_nodeUrl/storage_rpc/v1';

    final res = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return;

    const maxBodyBytes = 10 * 1024 * 1024; // 10 MB
    if (res.contentLength != null && res.contentLength! > maxBodyBytes) {
      throw Exception('[Oxen] Response too large: ${res.contentLength} bytes');
    }
    if (res.body.length > maxBodyBytes) {
      throw Exception('[Oxen] Response body too large');
    }
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

      _lastActivity = DateTime.now(); // reset to active polling

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
      final jsonBody = jsonEncode({
        'method': 'retrieve',
        'params': {'pubkey': _sessionId, 'last_hash': ''},
      });
      final url = '$_nodeUrl/storage_rpc/v1';

      final res = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;

      const maxBodyBytes = 10 * 1024 * 1024; // 10 MB
      if (res.contentLength != null && res.contentLength! > maxBodyBytes) {
        throw Exception('[Oxen] Response too large: ${res.contentLength} bytes');
      }
      if (res.body.length > maxBodyBytes) {
        throw Exception('[Oxen] Response body too large');
      }
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
        } catch (e) {
          debugPrint('[Oxen] fetchPublicKeys item parse error: $e');
        }
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

  // Session snodes have built-in onion routing — always direct, no proxy.
  http.Client? _httpClient;

  http.Client get _client {
    _httpClient ??= _newSnodeClient();
    return _httpClient!;
  }

  @override
  Future<void> initializeSender(String apiKey) async {
    await OxenKeyService.instance.initialize();
    _selfSessionId = OxenKeyService.instance.sessionId;
    if (apiKey.isNotEmpty) {
      // FINDING-14 fix: same https:// guard as initializeReader — prevents
      // outgoing encrypted messages being sent to a plain-http attacker server.
      if (!apiKey.startsWith('https://')) {
        debugPrint('[Oxen] Rejected non-HTTPS node URL in sender: $apiKey');
        return;
      }
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
      final jsonBody = jsonEncode({
        'method': 'store',
        'params': {
          'pubkey': recipientSessionId,
          'ttl': _ttlMs,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'data': payload,
        },
      });
      final url = '$node/storage_rpc/v1';

      final res = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
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
