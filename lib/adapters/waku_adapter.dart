import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/waku_discovery_service.dart';
import 'inbox_manager.dart';

// Sentinel: no URL was explicitly configured — trigger auto-discovery.
const _autoDiscoverSentinel = '__auto__';
const _pubsubTopic = '/waku/2/default-waku/proto';

String _msgTopic(String userId) => '/aegis/1/$userId/proto';
String _sigTopic(String userId) => '/aegis/1/$userId/signals/proto';
String _keysTopic(String userId) => '/aegis/1/$userId/keys/proto';

/// ─────────────────────────────────────────────────────────────────────────────
/// Waku v2 Adapter — Signal+PQC over Waku transport
///
/// Content topics:
///   /aegis/1/{userId}/proto         → Chat messages
///   /aegis/1/{userId}/signals/proto → WebRTC + system signals
///   /aegis/1/{userId}/keys/proto    → Signal + Kyber public key bundle
///
/// Address format:  userId@http://nodeUrl
///   e.g. a1b2c3d4@http://localhost:8645
///
/// Setup:
///   Run nwaku (https://github.com/waku-org/nwaku) — default REST port 8645.
///   No relay configuration needed; the node discovers peers automatically.
/// ─────────────────────────────────────────────────────────────────────────────

// ─── InboxReader ─────────────────────────────────────────────────────────────

class WakuInboxReader implements InboxReader {
  String _nodeUrl = _autoDiscoverSentinel;
  String _userId = '';

  final _msgCtrl = StreamController<List<Message>>.broadcast();
  final _sigCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _seenHashes = <String>{};

  bool _subscribed = false;
  bool _loopStarted = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    _parseParams(apiKey, databaseId);
    if (_userId.isEmpty) return;
    // If no node URL was explicitly set, discover the fastest available one.
    if (_nodeUrl == _autoDiscoverSentinel) {
      _nodeUrl = await WakuDiscoveryService.instance.discoverBestNode();
      debugPrint('[Waku] Reader using node: $_nodeUrl');
    }
    _ensureLoop();
  }

  void _parseParams(String apiKey, String databaseId) {
    // databaseId: "userId@http://nodeUrl"
    final atHttp = databaseId.indexOf('@http');
    if (atHttp != -1) {
      _userId = databaseId.substring(0, atHttp);
      _nodeUrl = databaseId.substring(atHttp + 1);
    } else if (databaseId.startsWith('http')) {
      _nodeUrl = databaseId;
    }
    if (apiKey.startsWith('{')) {
      try {
        final m = jsonDecode(apiKey) as Map<String, dynamic>;
        final nodeUrl = m['nodeUrl'] as String?;
        // Empty string or missing = auto-discover
        if (nodeUrl != null && nodeUrl.isNotEmpty) _nodeUrl = nodeUrl;
        if ((m['userId'] as String?)?.isNotEmpty == true) _userId = m['userId'] as String;
      } catch (_) {}
    }
  }

  void _ensureLoop() {
    if (_loopStarted) return;
    _loopStarted = true;
    unawaited(_runLoop());
  }

  // ── Polling loop ──────────────────────────────────────────────────────────

  Future<void> _runLoop() async {
    while (true) {
      if (!_subscribed) await _subscribe();
      if (_subscribed) {
        await Future.wait([
          _pollTopic(_msgTopic(_userId), _dispatchMessage),
          _pollTopic(_sigTopic(_userId), _dispatchSignal),
        ]);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _subscribe() async {
    try {
      final res = await http.post(
        Uri.parse('$_nodeUrl/filter/v2/subscriptions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': 'aegis_${_userId.substring(0, min(8, _userId.length))}',
          'contentFilters': [_msgTopic(_userId), _sigTopic(_userId)],
          'pubsubTopic': _pubsubTopic,
        }),
      ).timeout(const Duration(seconds: 10));
      _subscribed = res.statusCode == 200;
      if (!_subscribed) debugPrint('[Waku] Filter subscribe failed: ${res.statusCode} — ${res.body}');
    } catch (e) {
      debugPrint('[Waku] Filter subscribe error: $e');
    }
  }

  Future<void> _pollTopic(
    String topic,
    void Function(Map<String, dynamic>) handler,
  ) async {
    try {
      final encoded = Uri.encodeComponent(topic);
      final res = await http
          .get(Uri.parse('$_nodeUrl/filter/v2/messages/$encoded'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final msgs = (data['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final msg in msgs) {
        final hash = (msg['messageHash'] as String?) ??
            (msg['timestamp'] as int?)?.toString() ?? '';
        if (hash.isNotEmpty) {
          if (_seenHashes.contains(hash)) continue;
          _seenHashes.add(hash);
          if (_seenHashes.length > 3000) {
            _seenHashes.removeAll(_seenHashes.take(1500).toList());
          }
        }
        handler(msg);
      }
    } catch (_) {} // silently ignore transient poll errors
  }

  void _dispatchMessage(Map<String, dynamic> msg) {
    try {
      final raw = msg['payload'] as String? ?? '';
      // DoS guard: ~700KB base64 ≈ 512KB decoded; reject oversized payloads
      if (raw.length > 700000) {
        debugPrint('[Waku] Oversized payload (${raw.length} chars) — dropped');
        return;
      }
      final payloadBytes = base64.decode(raw);
      final outer = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
      final senderId = outer['from'] as String? ?? '';
      final encPayload = outer['payload'] as String? ?? '';
      final tsNs = msg['timestamp'] as int? ?? 0;
      _msgCtrl.add([Message(
        id: msg['messageHash'] as String? ?? tsNs.toString(),
        senderId: senderId,
        receiverId: _userId,
        encryptedPayload: encPayload,
        timestamp: tsNs > 0
            ? DateTime.fromMicrosecondsSinceEpoch(tsNs ~/ 1000)
            : DateTime.now(),
        adapterType: 'waku',
      )]);
    } catch (e) {
      debugPrint('[Waku] Message parse error: $e');
    }
  }

  void _dispatchSignal(Map<String, dynamic> msg) {
    try {
      final payloadBytes = base64.decode(msg['payload'] as String);
      final data = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
      _sigCtrl.add([{
        'type': data['type'],
        'senderId': data['senderId'],
        'roomId': data['roomId'],
        'payload': data['payload'],
      }]);
    } catch (e) {
      debugPrint('[Waku] Signal parse error: $e');
    }
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  @override
  Stream<List<Message>> listenForMessages() => _msgCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() => _sigCtrl.stream;

  // ── Key bundle fetch via Waku Store ───────────────────────────────────────

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    if (_userId.isEmpty) return null;
    try {
      final topic = Uri.encodeComponent(_keysTopic(_userId));
      final res = await http.get(
        Uri.parse('$_nodeUrl/store/v3/messages?contentTopics=$topic&pageSize=1&ascending=false'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final msgs = (data['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (msgs.isEmpty) return null;
      final payloadBytes = base64.decode(msgs.first['payload'] as String);
      return jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[Waku] fetchPublicKeys error: $e');
      return null;
    }
  }

  @override
  Future<String?> provisionGroup(String groupName) async =>
      _userId.isNotEmpty ? '$_userId@$_nodeUrl' : null;
}

// ─── MessageSender ────────────────────────────────────────────────────────────

class WakuMessageSender implements MessageSender {
  String _nodeUrl = _autoDiscoverSentinel;
  String _userId = '';

  @override
  Future<void> initializeSender(String apiKey) async {
    if (apiKey.startsWith('{')) {
      try {
        final m = jsonDecode(apiKey) as Map<String, dynamic>;
        final nodeUrl = m['nodeUrl'] as String?;
        if (nodeUrl != null && nodeUrl.isNotEmpty) _nodeUrl = nodeUrl;
        if ((m['userId'] as String?)?.isNotEmpty == true) _userId = m['userId'] as String;
      } catch (_) {}
    }
    if (_nodeUrl == _autoDiscoverSentinel) {
      _nodeUrl = await WakuDiscoveryService.instance.discoverBestNode();
      debugPrint('[Waku] Sender using node: $_nodeUrl');
    }
  }

  Future<bool> _publish(String contentTopic, String jsonPayload) async {
    // Try current node first
    if (await _tryPublish(_nodeUrl, contentTopic, jsonPayload)) return true;

    // On failure, switch to the next best available node and retry once
    try {
      final next = await WakuDiscoveryService.instance.discoverExcluding(_nodeUrl);
      if (next != _nodeUrl) {
        _nodeUrl = next;
        debugPrint('[Waku] Sender switched to: $_nodeUrl');
        return _tryPublish(_nodeUrl, contentTopic, jsonPayload);
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _tryPublish(
      String nodeUrl, String contentTopic, String jsonPayload) async {
    try {
      final encoded = Uri.encodeComponent(_pubsubTopic);
      final res = await http.post(
        Uri.parse('$nodeUrl/relay/v1/messages/$encoded'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payload': base64.encode(utf8.encode(jsonPayload)),
          'contentTopic': contentTopic,
          'timestamp': DateTime.now().microsecondsSinceEpoch * 1000,
        }),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Waku] Publish error on $nodeUrl for $contentTopic: $e');
      return false;
    }
  }

  String _recipientId(String targetDatabaseId) {
    final atHttp = targetDatabaseId.indexOf('@http');
    return atHttp != -1
        ? targetDatabaseId.substring(0, atHttp)
        : targetDatabaseId;
  }

  @override
  Future<bool> sendMessage(
      String targetDatabaseId, String roomId, Message message) async {
    final recipientId = _recipientId(targetDatabaseId);
    return _publish(
      _msgTopic(recipientId),
      jsonEncode({'from': _userId, 'payload': message.encryptedPayload}),
    );
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
      // Publish key bundle to OWN keys topic — peers fetch via Waku Store.
      return _publish(_keysTopic(_userId), jsonEncode(payload));
    }
    final recipientId = _recipientId(targetDatabaseId);
    return _publish(
      _sigTopic(recipientId),
      jsonEncode({
        'type': type,
        'roomId': roomId,
        'senderId': senderId,
        'payload': payload,
      }),
    );
  }
}
