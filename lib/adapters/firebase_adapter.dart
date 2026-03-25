import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/psiphon_service.dart' as psiphon;
import '../services/tor_service.dart' as tor;
import 'inbox_manager.dart';

/// Returns a proxied client: Psiphon (fast) → Tor (slow) → plain.
http.Client _buildFirebaseClient() =>
    psiphon.buildPsiphonHttpClient() ?? tor.buildTorHttpClient() ?? http.Client();

/// Returns true if the Firebase target URL resolves to a private/loopback
/// address that should never be used as a cross-project relay (SSRF guard).
bool _isPrivateFirebaseUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return true;
  final h = uri.host.toLowerCase();
  if (h == 'localhost' || h == '::1') return true;
  if (h.startsWith('127.') || h.startsWith('169.254.')) return true;
  if (h.startsWith('10.') || h.startsWith('192.168.')) return true;
  if (h.startsWith('172.')) {
    final second = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 16 && second <= 31) return true;
  }
  if (h.startsWith('100.')) {
    final second = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 64 && second <= 127) return true;
  }
  if (h.startsWith('fc') || h.startsWith('fd') || h.startsWith('fe80:')) return true;
  return false;
}

class FirebaseInboxReader implements InboxReader {
  late String _dbUrl;
  late String _authKey;
  late String _selfDbId;
  http.Client? _messagesClient;
  http.Client? _signalsClient;

  final _healthCtrl = StreamController<bool>.broadcast();
  int _consecutiveFailures = 0;
  bool _isHealthy = true;
  static const _failureThreshold = 3;

  // Circuit breaker — stops infinite retries on persistent failures
  int _msgLoopFailures = 0;
  int _sigLoopFailures = 0;
  static const _maxConsecutiveFailures = 30;

  /// True when the message listener stopped after [_maxConsecutiveFailures] failures.
  bool get messagesCircuitBroken => _msgCircuitBroken;
  bool _msgCircuitBroken = false;

  /// True when the signal listener stopped after [_maxConsecutiveFailures] failures.
  bool get signalsCircuitBroken => _sigCircuitBroken;
  bool _sigCircuitBroken = false;

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  void _recordSuccess() {
    _consecutiveFailures = 0;
    if (!_isHealthy && !_healthCtrl.isClosed) {
      _isHealthy = true;
      _healthCtrl.add(true);
    }
  }

  void _recordFailure() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= _failureThreshold && _isHealthy && !_healthCtrl.isClosed) {
      _isHealthy = false;
      _healthCtrl.add(false);
    }
  }

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    // Expected apiKey format: JSON string '{"url": "https://...", "key": "AIza..."}'
    // fallback if user just pasted URL:
    try {
      final config = jsonDecode(apiKey);
      _dbUrl = config['url'] ?? apiKey;
      _authKey = config['key'] ?? '';
    } catch (_) {
      _dbUrl = apiKey;
      _authKey = '';
    }

    if (_dbUrl.endsWith('/')) {
      _dbUrl = _dbUrl.substring(0, _dbUrl.length - 1);
    }

    // Reject obviously invalid URLs (e.g. GitHub tokens stored from old config)
    if (!_dbUrl.startsWith('https://')) {
      throw ArgumentError('Firebase: invalid database URL "$_dbUrl". Go to Settings and re-enter your Firebase URL.');
    }

    _selfDbId = databaseId;
  }

  String _buildUrl(String path) => '$_dbUrl$path';

  /// Returns Authorization header when an auth key is configured.
  /// Keeps the token out of URLs (and thus out of server/proxy access logs).
  Map<String, String> _buildAuthHeaders() {
    if (_authKey.isNotEmpty) {
      return {'Authorization': 'Bearer $_authKey'};
    }
    return {};
  }

  @override
  Stream<List<Message>> listenForMessages() async* {
    int retryDelay = 5;
    while (true) {
      bool cycleSuccess = false;
      try {
        _messagesClient?.close();
        _messagesClient = _buildFirebaseClient();
        final url = _buildUrl('/inbox/$_selfDbId/messages.json');

        final request = http.Request('GET', Uri.parse(url))
          ..headers['Accept'] = 'text/event-stream'
          ..headers.addAll(_buildAuthHeaders());

        final response = await _messagesClient!.send(request);

        if (response.statusCode == 200) {
          retryDelay = 5; // reset backoff on successful connection
          cycleSuccess = true;
          _msgLoopFailures = 0; // circuit breaker: reset on success
          _recordSuccess();
          Map<String, dynamic>? dataBuffer;
          await for (final line in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
            if (line.startsWith('data: ')) {
              dataBuffer = null; // reset before parse — prevents stale buffer if JSON fails
              final dataStr = line.substring(6).trim();
              if (dataStr.isEmpty || dataStr == 'null') continue;
              if (dataStr.length > 10 * 1024 * 1024) {
                debugPrint('[Firebase] SSE message line too large (${dataStr.length} bytes), skipping');
                continue;
              }
              try {
                dataBuffer = jsonDecode(dataStr);
              } catch (e) {
                debugPrint("Error decoding Firebase SSE data: $e");
              }
            } else if (line.isEmpty && dataBuffer != null) {
              // Grab and reset buffer BEFORE processing so exceptions don't leave stale state
              final buf = dataBuffer;
              dataBuffer = null;
              List<Message> messages = [];
              try {
                if (buf.containsKey('path') && buf['path'] == '/') {
                  final data = buf['data'];
                  if (data != null && data is Map) {
                    data.forEach((key, value) {
                      if (value is Map<String, dynamic>) {
                        final msg = Message.tryFromJson(value);
                        if (msg != null) messages.add(msg);
                      }
                    });
                  }
                } else if (buf.containsKey('path') && buf['path'] != '/') {
                  final data = buf['data'];
                  if (data != null && data is Map<String, dynamic>) {
                    final msg = Message.tryFromJson(data);
                    if (msg != null) messages.add(msg);
                  }
                }
              } catch (e) {
                debugPrint("Firebase SSE flush error: $e");
              }
              if (messages.isNotEmpty) yield messages;
            }
          }
        } else {
          debugPrint("Firebase SSE stream failed with status ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Firebase listenForMessages error: $e");
      }
      if (!cycleSuccess) {
        _recordFailure();
        _msgLoopFailures++;
        if (_msgLoopFailures >= _maxConsecutiveFailures) {
          debugPrint('[Firebase] Messages: max retries ($_maxConsecutiveFailures) reached, stopping');
          _msgCircuitBroken = true;
          break;
        }
        // Tiered delay: 5s for first 5 failures, 30s up to 15, then 5min
        final delay = Duration(seconds:
            (_msgLoopFailures < 5) ? 5
            : (_msgLoopFailures < 15) ? 30
            : 300);
        await Future.delayed(delay);
      } else {
        await Future.delayed(Duration(seconds: retryDelay));
        retryDelay = (retryDelay * 2).clamp(5, 300);
      }
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() async* {
    int retryDelay = 5;
    while (true) {
      bool cycleSuccess = false;
      try {
        _signalsClient?.close();
        _signalsClient = _buildFirebaseClient();
        final url = _buildUrl('/inbox/$_selfDbId/signals.json');

        final request = http.Request('GET', Uri.parse(url))
          ..headers['Accept'] = 'text/event-stream'
          ..headers.addAll(_buildAuthHeaders());

        final response = await _signalsClient!.send(request);

        if (response.statusCode == 200) {
          retryDelay = 5; // reset backoff on successful connection
          cycleSuccess = true;
          _sigLoopFailures = 0; // circuit breaker: reset on success
          Map<String, dynamic>? dataBuffer;
          await for (final line in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6).trim();
              if (dataStr.isEmpty || dataStr == 'null') continue;
              if (dataStr.length > 10 * 1024 * 1024) {
                debugPrint('[Firebase] SSE signal line too large (${dataStr.length} bytes), skipping');
                continue;
              }
              try {
                dataBuffer = jsonDecode(dataStr);
              } catch (e) {
                debugPrint('[Firebase] SSE JSON parse failed: $e');
              }
            } else if (line.isEmpty && dataBuffer != null) {
              // Grab and reset buffer BEFORE processing
              final buf = dataBuffer;
              dataBuffer = null;
              try {
                List<Map<String, dynamic>> signals = [];
                final data = buf['data'];
                if (buf['path'] == '/' && data is Map) {
                  data.forEach((key, value) {
                    if (value is Map) signals.add(Map<String, dynamic>.from(value));
                  });
                } else if (buf['path'] != '/' && data is Map) {
                  signals.add(Map<String, dynamic>.from(data));
                }
                if (signals.isNotEmpty) yield signals;
              } catch (e) {
                debugPrint("Firebase SSE signal flush error: $e");
              }
            }
          }
        } else {
          debugPrint("Firebase signals SSE failed with status ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Firebase listenForSignals error: $e");
      }
      if (!cycleSuccess) {
        _recordFailure();
        _sigLoopFailures++;
        if (_sigLoopFailures >= _maxConsecutiveFailures) {
          debugPrint('[Firebase] Signals: max retries ($_maxConsecutiveFailures) reached, stopping');
          _sigCircuitBroken = true;
          break;
        }
        // Tiered delay: 5s for first 5 failures, 30s up to 15, then 5min
        final delay = Duration(seconds:
            (_sigLoopFailures < 5) ? 5
            : (_sigLoopFailures < 15) ? 30
            : 300);
        await Future.delayed(delay);
      } else {
        await Future.delayed(Duration(seconds: retryDelay));
        retryDelay = (retryDelay * 2).clamp(5, 300);
      }
    }
  }

  @override
  Future<String?> provisionGroup(String groupName) async {
    return _selfDbId;
  }

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    try {
      final url = _buildUrl('/inbox/$_selfDbId/signals.json');
      final client = _buildFirebaseClient();
      final res = await client.get(Uri.parse(url), headers: _buildAuthHeaders());
      client.close();
      const maxBodyBytes = 10 * 1024 * 1024; // 10 MB
      if (res.statusCode == 200 && res.body != 'null') {
        if (res.body.length > maxBodyBytes) {
          throw Exception('[Firebase] Response body too large');
        }
        final data = jsonDecode(res.body) as Map;
        for (var item in data.values) {
          if (item is Map && item['type'] == 'sys_keys') {
            final payload = item['payload'];
            if (payload is Map<String, dynamic>) return payload;
            if (payload is String) return jsonDecode(payload) as Map<String, dynamic>;
          }
        }
      }
    } catch (e) {
      debugPrint('[Firebase] fetchPublicKeys error: $e');
    }
    return null;
  }
}

class FirebaseInboxSender implements MessageSender {
  late String _dbUrl;
  late String _authKey;

  /// Returns Authorization header when an auth key is configured.
  /// Keeps the token out of URLs (and thus out of server/proxy access logs).
  Map<String, String> _buildAuthHeaders() {
    if (_authKey.isNotEmpty) {
      return {'Authorization': 'Bearer $_authKey'};
    }
    return {};
  }

  @override
  Future<void> initializeSender(String apiKey) async {
    try {
      final config = jsonDecode(apiKey);
      _dbUrl = config['url'] ?? apiKey;
      _authKey = config['key'] ?? '';
    } catch (_) {
      _dbUrl = apiKey;
      _authKey = '';
    }
    
    if (_dbUrl.endsWith('/')) {
      _dbUrl = _dbUrl.substring(0, _dbUrl.length - 1);
    }
  }

  @override
  Future<bool> sendMessage(String targetDatabaseId, String roomId, Message message) async {
    // targetDatabaseId may be "userId@https://project.firebaseio.com" or just "userId"
    String userId;
    String targetDbUrl;
    final atIdx = targetDatabaseId.indexOf('@http');
    if (atIdx != -1) {
      userId = targetDatabaseId.substring(0, atIdx);
      targetDbUrl = targetDatabaseId.substring(atIdx + 1);
      if (targetDbUrl.endsWith('/')) targetDbUrl = targetDbUrl.substring(0, targetDbUrl.length - 1);
      if (_isPrivateFirebaseUrl(targetDbUrl)) {
        debugPrint('[Firebase] SSRF rejected — private target URL: $targetDbUrl');
        return false;
      }
    } else {
      userId = targetDatabaseId;
      targetDbUrl = _dbUrl; // same Firebase project
    }

    final url = '$targetDbUrl/inbox/$userId/messages.json';
    // Only include auth header when sending to our own Firebase project.
    final authHeaders = (targetDbUrl == _dbUrl) ? _buildAuthHeaders() : <String, String>{};

    final client = _buildFirebaseClient();
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', ...authHeaders},
        body: jsonEncode(message.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Firebase send error: $e");
      return false;
    } finally {
      client.close();
    }
  }

  @override
  Future<bool> sendSignal(String targetDatabaseId, String roomId, String senderId, String type, Map<String, dynamic> payload) async {
    // Mirror the cross-project logic from sendMessage:
    // targetDatabaseId may be "userId@https://other-project.firebaseio.com" or just "userId".
    String userId;
    String targetDbUrl;
    final atIdx = targetDatabaseId.indexOf('@http');
    if (atIdx != -1) {
      userId = targetDatabaseId.substring(0, atIdx);
      targetDbUrl = targetDatabaseId.substring(atIdx + 1);
      if (targetDbUrl.endsWith('/')) targetDbUrl = targetDbUrl.substring(0, targetDbUrl.length - 1);
      if (_isPrivateFirebaseUrl(targetDbUrl)) {
        debugPrint('[Firebase] SSRF rejected — private target URL: $targetDbUrl');
        return false;
      }
    } else {
      userId = targetDatabaseId;
      targetDbUrl = _dbUrl;
    }

    final url = '$targetDbUrl/inbox/$userId/signals.json';
    // Only include auth header when writing to our own Firebase project.
    final authHeaders = (targetDbUrl == _dbUrl) ? _buildAuthHeaders() : <String, String>{};

    final client = _buildFirebaseClient();
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', ...authHeaders},
        body: jsonEncode({
          'roomId': roomId,
          'senderId': senderId,
          'type': type,
          'payload': payload,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Firebase signal send error: $e");
      return false;
    } finally {
      client.close();
    }
  }
}
