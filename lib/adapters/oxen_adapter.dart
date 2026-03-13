import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/oxen_key_service.dart';
import 'inbox_manager.dart';

// Default Oxen storage server nodes (user can override in Settings).
// These are community-run Oxen service nodes; configure a custom node for production.
const _defaultNodes = [
  'https://storage.seed1.loki.network:4433',
  'https://storage.seed2.loki.network:4433',
  'https://storage.seed3.loki.network:4433',
];

const _ttlMs = 14 * 24 * 60 * 60 * 1000; // 14-day TTL (Session standard)

// ─── InboxReader ──────────────────────────────────────────────────────────────

/// Polls an Oxen storage-server namespace every 2 s and dispatches messages
/// and signals.  Authentication uses Ed25519 derive from the same seed as the
/// Session ID so only the key owner can retrieve.
class OxenInboxReader implements InboxReader {
  String _nodeUrl = '';
  String _sessionId = '';

  final _msgCtrl = StreamController<List<Message>>.broadcast();
  final _sigCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _seenHashes = <String>{};

  bool _loopStarted = false;
  String _lastHash = '';

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    _sessionId = databaseId;
    await OxenKeyService.instance.initialize();
    // For own inbox: use the service's Session ID
    // For ad-hoc (fetching contact keys): databaseId = contact's Session ID
    _nodeUrl = apiKey.isNotEmpty ? apiKey : _defaultNodes.first;
    if (_sessionId == OxenKeyService.instance.sessionId) {
      // Only start the poll loop for our own inbox
      _ensureLoop();
    }
  }

  void _ensureLoop() {
    if (_loopStarted) return;
    _loopStarted = true;
    unawaited(_runLoop());
  }

  Future<void> _runLoop() async {
    while (true) {
      try {
        await _poll();
      } catch (e) {
        debugPrint('[Oxen] Poll error: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _poll() async {
    final tsMs = DateTime.now().millisecondsSinceEpoch;
    final msg = 'retrieve$_sessionId$tsMs';
    final sigBytes = await OxenKeyService.instance.sign(utf8.encode(msg));
    final sig = base64.encode(sigBytes);

    final res = await http.post(
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
      // DoS guard: ~700 KB base64
      if (raw.length > 700000) return;
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

  /// Attempt unauthenticated retrieve to find a sys_keys bundle.
  /// Works with permissive servers; returns null on auth failure (graceful).
  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    try {
      final res = await http.post(
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

      // Scan newest-first for a sys_keys signal
      for (final item in messages.reversed) {
        try {
          final raw = item['data'] as String? ?? '';
          if (raw.isEmpty) continue;
          final bytes = base64.decode(raw);
          final outer =
              jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
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

  @override
  Future<void> initializeSender(String apiKey) async {
    await OxenKeyService.instance.initialize();
    _selfSessionId = OxenKeyService.instance.sessionId;
    _nodeUrl = apiKey.isNotEmpty ? apiKey : _defaultNodes.first;
  }

  /// Store [body] in [recipientSessionId]'s namespace on the storage server.
  Future<bool> _store(
      String recipientSessionId, Map<String, dynamic> body) async {
    final nodes = [_nodeUrl, ..._defaultNodes.where((n) => n != _nodeUrl)];
    for (final node in nodes) {
      if (await _tryStore(node, recipientSessionId, body)) return true;
    }
    return false;
  }

  Future<bool> _tryStore(
      String node, String recipientSessionId, Map<String, dynamic> body) async {
    try {
      final payload = base64.encode(utf8.encode(jsonEncode(body)));
      final res = await http.post(
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
      if (res.statusCode == 200) return true;
      debugPrint('[Oxen] Store ${res.statusCode} on $node: ${res.body}');
      return false;
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
      // Push key bundle to BOTH own inbox (for future fetchers) and recipient's inbox
      // so they receive it via their poll loop and can build a Signal session.
      final body = {'t': 'sig', 'type': type, 'senderId': senderId,
          'roomId': roomId, 'payload': payload};
      final toSelf = _store(_selfSessionId, body);
      // If target != self (e.g. reactive key push), also push to target
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
