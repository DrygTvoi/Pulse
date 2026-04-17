import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../services/session_key_service.dart';
import 'inbox_manager.dart';

// Session Network seed nodes — clearnet, standard TLS.
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
        debugPrint('[Session] Seed response too large — skipping $seed');
        continue;
      }
      if (res.body.length > maxBodyBytes) {
        debugPrint('[Session] Seed response body too large — skipping $seed');
        continue;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final states = (data['result']?['service_node_states'] as List?) ?? [];
      final nodes = <String>[];
      for (final s in states) {
        if (nodes.length >= 500) break; // cap snode count per seed response
        final ip = s['public_ip'] as String? ?? '';
        final port = s['storage_port'];
        if (ip.isEmpty || port == null) continue;
        if (_isPrivateSnodeIp(ip)) continue;
        final portNum = port is int ? port : int.tryParse(port.toString()) ?? -1;
        if (portNum < 1 || portNum > 65535) continue;
        nodes.add('https://$ip:$portNum');
      }
      if (nodes.isNotEmpty) {
        debugPrint('[Session] Discovered ${nodes.length} snodes via $seed');
        return nodes;
      }
    } catch (e) {
      debugPrint('[Session] Seed ${seed.length > 30 ? '${seed.substring(0, 30)}...' : seed} error: $e');
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
  // IPv6 link-local (fe80::/10)
  if (RegExp(r'^fe[89ab]', caseSensitive: false).hasMatch(ip)) return true;
  return false;
}

/// Resolve the swarm responsible for [pubkey] by querying known snodes.
/// Returns a list of "https://ip:port" strings for the responsible swarm.
/// Cached per-pubkey for the lifetime of the process.
final Map<String, List<String>> _swarmCache = {};

Future<List<String>> _getSwarm(String pubkey, List<String> askNodes) async {
  if (_swarmCache.containsKey(pubkey)) return _swarmCache[pubkey]!;
  final client = _newSnodeClient();
  try {
    for (final node in askNodes.take(3)) {
      try {
        final res = await client.post(
          Uri.parse('$node/storage_rpc/v1'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'method': 'get_swarm',
            'params': {'pubkey': pubkey},
          }),
        ).timeout(const Duration(seconds: 5));
        if (res.statusCode != 200) continue;
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final snodes = (data['snodes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final urls = <String>[];
        for (final s in snodes) {
          final ip = s['ip'] as String? ?? '';
          final port = s['port'] ?? s['storage_port'];
          if (ip.isEmpty || port == null) continue;
          final p = port is int ? port : int.tryParse(port.toString()) ?? -1;
          if (p < 1 || p > 65535) continue;
          urls.add('https://$ip:$p');
        }
        if (urls.isNotEmpty) {
          debugPrint('[Session] Swarm for ${pubkey.substring(0, 8)}…: ${urls.length} snodes');
          _swarmCache[pubkey] = urls;
          return urls;
        }
      } catch (e) {
        debugPrint('[Session] get_swarm error on $node: $e');
      }
    }
  } finally {
    client.close();
  }
  return [];
}

// ─── InboxReader ──────────────────────────────────────────────────────────────

/// Polls a Session Network storage snode every 2–300 s and dispatches messages
/// and signals. Authentication uses Ed25519 derived from the same seed as the
/// Session ID so only the key owner can retrieve.
class SessionInboxReader implements InboxReader {
  String _nodeUrl = '';
  String _sessionId = '';
  bool _usingDiscovery = false; // true when using auto-discovered snodes
  List<String> _snodes = [];
  int _snodeIndex = 0;

  final _msgCtrl = StreamController<List<Message>>.broadcast();
  final _sigCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _seenHashes = <String>{};

  bool _loopStarted = false;
  bool _stopped = false;
  String _lastHash = '';

  // ── Adaptive polling — reduces bandwidth when idle ──────────────────────
  DateTime _lastActivity = DateTime.now();

  int get _adaptivePollDelay {
    final idle = DateTime.now().difference(_lastActivity);
    if (idle < const Duration(seconds: 10)) return 4;    // active
    if (idle < const Duration(seconds: 60)) return 10;   // idle
    return 30;                                             // deep idle
  }

  final _healthCtrl = StreamController<bool>.broadcast();
  int _consecutiveFailures = 0;
  int _pollCount = 0;
  bool _isHealthy = true;
  static const _failureThreshold = 5;
  static const _maxConsecutiveFailures = 30;

  /// True when the poll loop stopped after [_maxConsecutiveFailures] failures.
  bool get circuitBroken => _circuitBroken;
  bool _circuitBroken = false;

  /// Stop the poll loop and release resources.
  void close() {
    _stopped = true;
    _httpClient?.close();
    _httpClient = null;
    _msgCtrl.close();
    _sigCtrl.close();
    _healthCtrl.close();
  }

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
      debugPrint('[Session] Rejected invalid session ID format: $databaseId');
      return;
    }
    _sessionId = databaseId;
    await SessionKeyService.instance.initialize();
    if (apiKey.isNotEmpty) {
      if (!apiKey.startsWith('https://')) {
        debugPrint('[Session] Rejected non-HTTPS node URL: ${apiKey.length > 20 ? '${apiKey.substring(0, 20)}...' : apiKey}');
        _usingDiscovery = true;
        return;
      }
      _nodeUrl = apiKey;
      _usingDiscovery = false;
    } else {
      _usingDiscovery = true;
    }
    if (_sessionId == SessionKeyService.instance.sessionId) {
      _ensureLoop();
    }
  }

  void _ensureLoop() {
    if (_loopStarted) return;
    _loopStarted = true;
    unawaited(_runLoop());
  }

  Future<void> _runLoop() async {
    // Restore last-hash so we skip already-seen messages across restarts.
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastHash = prefs.getString('session_last_hash_${_sessionId.substring(0, 8)}') ?? '';
    } catch (_) {}

    // Always discover snodes for swarm resolution.
    if (_snodes.isEmpty) {
      for (int attempt = 0; attempt < 10; attempt++) {
        _snodes = await _discoverSnodes();
        if (_snodes.isNotEmpty) break;
        debugPrint('[Session] No snodes discovered (attempt ${attempt + 1}/10)');
        await Future.delayed(const Duration(seconds: 60));
      }
      if (_snodes.isEmpty) {
        debugPrint('[Session] Discovery failed after 10 attempts — stopping');
        _circuitBroken = true;
        return;
      }
    }
    // Resolve our own swarm — polling random snodes returns 421.
    if (_sessionId.isNotEmpty) {
      final swarm = await _getSwarm(_sessionId, _snodes);
      if (swarm.isNotEmpty) {
        _snodes = swarm;
        _snodeIndex = 0;
        _nodeUrl = swarm.first;
        debugPrint('[Session] Reader using swarm node: $_nodeUrl');
      } else if (_usingDiscovery) {
        _nodeUrl = _snodes[_snodeIndex];
      }
    } else if (_usingDiscovery) {
      _nodeUrl = _snodes[_snodeIndex];
    }

    while (!_stopped) {
      int pollDelay;
      try {
        await _poll();
        _pollCount++;
        if (_pollCount == 1 || _pollCount % 20 == 0) {
          debugPrint('[Session] Poll #$_pollCount OK (id=${_sessionId.substring(0, 8)}… node=$_nodeUrl delay=${_adaptivePollDelay}s)');
        }
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
          debugPrint('[Session] Switching snode → $_nodeUrl');
        } else {
          debugPrint('[Session] Poll error: $e');
        }
        _consecutiveFailures++;
        if (_consecutiveFailures >= _failureThreshold && _isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = false;
          _healthCtrl.add(false);
        }
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          debugPrint('[Session] Max retries ($_maxConsecutiveFailures) reached, stopping');
          _circuitBroken = true;
          break;
        }
        pollDelay = (_consecutiveFailures < 5) ? 5
            : (_consecutiveFailures < 15) ? 30
            : 300;
      }
      await Future.delayed(Duration(seconds: pollDelay));
    }
  }

  Future<void> _poll() async {
    final tsMs = DateTime.now().millisecondsSinceEpoch;

    // Session Network signature format (namespace 0 = default DM inbox):
    // sign("retrieve" + timestamp)  — namespace omitted when 0
    const namespace = 0;
    final msgToSign = 'retrieve${namespace == 0 ? '' : namespace}$tsMs';
    final sigBytes = await SessionKeyService.instance.sign(utf8.encode(msgToSign));
    final sig = base64.encode(sigBytes);

    final jsonBody = jsonEncode({
      'method': 'retrieve',
      'params': {
        'pubkey': _sessionId,
        'pubkey_ed25519': SessionKeyService.instance.ed25519PublicKeyHex,
        'namespace': namespace,
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
    if (res.statusCode != 200) {
      debugPrint('[Session] Poll error ${res.statusCode} from $_nodeUrl');
      return;
    }

    const maxBodyBytes = 10 * 1024 * 1024; // 10 MB
    if (res.contentLength != null && res.contentLength! > maxBodyBytes) {
      throw Exception('[Session] Response too large: ${res.contentLength} bytes');
    }
    if (res.body.length > maxBodyBytes) {
      throw Exception('[Session] Response body too large');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // Storage RPC v1 returns messages at top level, not inside 'result'.
    final messagesList = (data['messages'] as List?) ?? [];
    final messages = messagesList.whereType<Map<String, dynamic>>().toList();
    if (messages.isNotEmpty) {
      debugPrint('[Session] Poll: ${messages.length} messages from $_nodeUrl');
    } else if (_pollCount < 3) {
      // Log first few empty polls for diagnostics.
      final keys = data.keys.toList();
      debugPrint('[Session] Poll empty — response keys: $keys');
    }

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
    // Persist last-hash so restarts skip already-processed messages.
    if (messages.isNotEmpty && _lastHash.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'session_last_hash_${_sessionId.substring(0, 8)}', _lastHash);
      } catch (_) {}
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
        final sigType   = outer['type']     as String? ?? '';
        final sigSender = outer['senderId'] as String? ?? '';
        final sigRoom   = outer['roomId']   as String? ?? '';
        if (sigType.isEmpty || sigSender.isEmpty) return; // malformed signal
        _sigCtrl.add([{
          'type': sigType,
          'senderId': sigSender,
          'roomId': sigRoom,
          'payload': outer['payload'],
        }]);
      } else {
        _msgCtrl.add([Message(
          id: item['hash'] as String? ?? ts.toString(),
          senderId: outer['from'] as String? ?? '',
          receiverId: _sessionId,
          encryptedPayload: outer['payload'] as String? ?? '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
          adapterType: 'session',
        )]);
      }
    } catch (e) {
      debugPrint('[Session] Dispatch error: $e');
    }
  }

  @override
  Stream<List<Message>> listenForMessages() => _msgCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() => _sigCtrl.stream;

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    var nodeUrl = _nodeUrl;
    // If no node URL configured, discover via swarm lookup.
    if (nodeUrl.isEmpty && _sessionId.isNotEmpty) {
      final seeds = await _discoverSnodes();
      if (seeds.isEmpty) {
        debugPrint('[Session] fetchPublicKeys: no snodes discovered');
        return null;
      }
      final swarm = await _getSwarm(_sessionId, seeds);
      if (swarm.isEmpty) {
        debugPrint('[Session] fetchPublicKeys: no swarm for ${_sessionId.substring(0, 8)}…');
        return null;
      }
      nodeUrl = swarm.first;
      debugPrint('[Session] fetchPublicKeys: discovered node $nodeUrl for ${_sessionId.substring(0, 8)}…');
    }
    if (nodeUrl.isEmpty) return null;
    try {
      final jsonBody = jsonEncode({
        'method': 'retrieve',
        'params': {'pubkey': _sessionId, 'last_hash': ''},
      });
      final url = '$nodeUrl/storage_rpc/v1';

      debugPrint('[Session] fetchPublicKeys: querying $url for ${_sessionId.substring(0, 8)}…');
      final res = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        debugPrint('[Session] fetchPublicKeys: HTTP ${res.statusCode} from $nodeUrl');
        return null;
      }

      const maxBodyBytes = 10 * 1024 * 1024; // 10 MB
      if (res.contentLength != null && res.contentLength! > maxBodyBytes) {
        throw Exception('[Session] Response too large: ${res.contentLength} bytes');
      }
      if (res.body.length > maxBodyBytes) {
        throw Exception('[Session] Response body too large');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      // Storage RPC v1 returns messages at top level.
      final messages =
          ((data['messages'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
      debugPrint('[Session] fetchPublicKeys: ${messages.length} messages from $nodeUrl');

      for (final item in messages.reversed) {
        try {
          final raw = item['data'] as String? ?? '';
          if (raw.isEmpty) continue;
          if (raw.length > 700000) continue; // DoS guard — matches _dispatch
          final bytes = base64.decode(raw);
          final outer = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
          debugPrint('[Session] fetchPublicKeys item: t=${outer['t']} type=${outer['type']}');
          if (outer['t'] == 'sig' && outer['type'] == 'sys_keys') {
            final p = outer['payload'];
            if (p is Map<String, dynamic>) return p;
          }
        } catch (e) {
          debugPrint('[Session] fetchPublicKeys item parse error: $e');
        }
      }
    } catch (e) {
      debugPrint('[Session] fetchPublicKeys error: $e');
    }
    return null;
  }

  @override
  Future<String?> provisionGroup(String groupName) async => _sessionId;
}

// ─── MessageSender ────────────────────────────────────────────────────────────

class SessionMessageSender implements MessageSender {
  String _nodeUrl = '';
  String _selfSessionId = '';
  List<String> _snodes = [];

  http.Client? _httpClient;
  http.Client get _client {
    _httpClient ??= _newSnodeClient();
    return _httpClient!;
  }

  @override
  Future<void> initializeSender(String apiKey) async {
    await SessionKeyService.instance.initialize();
    _selfSessionId = SessionKeyService.instance.sessionId;
    if (apiKey.isNotEmpty && apiKey.startsWith('https://')) {
      _nodeUrl = apiKey;
    }
    // Always discover snodes for fallback — configured node may be down.
    if (_snodes.isEmpty) {
      _snodes = await _discoverSnodes();
      if (_nodeUrl.isEmpty && _snodes.isNotEmpty) _nodeUrl = _snodes.first;
    }
  }

  Future<bool> _store(
      String recipientSessionId, Map<String, dynamic> body) async {
    // Resolve the recipient's swarm first — random snodes return 421.
    final askNodes = <String>[if (_nodeUrl.isNotEmpty) _nodeUrl, ..._snodes];
    final swarm = await _getSwarm(recipientSessionId, askNodes);
    for (final node in swarm.take(3)) {
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
          'namespace': 0,
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
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        debugPrint('[Session] Stored OK on $node');
        return true;
      }
      debugPrint('[Session] Store rejected on $node: ${res.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[Session] Store error on $node: $e');
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
