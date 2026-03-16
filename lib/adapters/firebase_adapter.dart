import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/tor_service.dart' as tor;
import 'inbox_manager.dart';

/// Returns a Tor-proxied client when Tor is running, else a plain http.Client.
http.Client _buildFirebaseClient() =>
    tor.buildTorHttpClient() ?? http.Client();

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

  String _buildUrl(String path) {
    if (_authKey.isNotEmpty) {
      return '$_dbUrl$path?auth=$_authKey';
    }
    return '$_dbUrl$path';
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
          ..headers['Accept'] = 'text/event-stream';

        final response = await _messagesClient!.send(request);

        if (response.statusCode == 200) {
          retryDelay = 5; // reset backoff on successful connection
          cycleSuccess = true;
          _recordSuccess();
          Map<String, dynamic>? dataBuffer;
          await for (final line in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6).trim();
              if (dataStr.isEmpty || dataStr == 'null') continue;
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
                      try {
                        messages.add(Message.fromJson(value as Map<String, dynamic>));
                      } catch (e) {
                        debugPrint("Error parsing Firebase message snapshot: $e");
                      }
                    });
                  }
                } else if (buf.containsKey('path') && buf['path'] != '/') {
                  final data = buf['data'];
                  if (data != null && data is Map) {
                    try {
                      messages.add(Message.fromJson(data as Map<String, dynamic>));
                    } catch (e) {
                      debugPrint("Error parsing Firebase message delta: $e");
                    }
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
      if (!cycleSuccess) _recordFailure();
      await Future.delayed(Duration(seconds: retryDelay));
      retryDelay = (retryDelay * 2).clamp(5, 300);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() async* {
    int retryDelay = 5;
    while (true) {
      try {
        _signalsClient?.close();
        _signalsClient = _buildFirebaseClient();
        final url = _buildUrl('/inbox/$_selfDbId/signals.json');

        final request = http.Request('GET', Uri.parse(url))
          ..headers['Accept'] = 'text/event-stream';

        final response = await _signalsClient!.send(request);

        if (response.statusCode == 200) {
          retryDelay = 5; // reset backoff on successful connection
          Map<String, dynamic>? dataBuffer;
          await for (final line in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6).trim();
              if (dataStr.isEmpty || dataStr == 'null') continue;
              try {
                dataBuffer = jsonDecode(dataStr);
              } catch (_) {}
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
      await Future.delayed(Duration(seconds: retryDelay));
      retryDelay = (retryDelay * 2).clamp(5, 300);
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
      final res = await client.get(Uri.parse(url));
      client.close();
      if (res.statusCode == 200 && res.body != 'null') {
        final data = jsonDecode(res.body) as Map;
        for (var item in data.values) {
          if (item is Map && item['type'] == 'sys_keys') {
            final payload = item['payload'];
            if (payload is Map<String, dynamic>) return payload;
            if (payload is String) return jsonDecode(payload) as Map<String, dynamic>;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}

class FirebaseInboxSender implements MessageSender {
  late String _dbUrl;
  late String _authKey;

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
    } else {
      userId = targetDatabaseId;
      targetDbUrl = _dbUrl; // same Firebase project
    }

    // Only include auth param when sending to our own Firebase project
    final authSuffix = (_authKey.isNotEmpty && targetDbUrl == _dbUrl) ? '?auth=$_authKey' : '';
    final url = '$targetDbUrl/inbox/$userId/messages.json$authSuffix';

    final client = _buildFirebaseClient();
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
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
    } else {
      userId = targetDatabaseId;
      targetDbUrl = _dbUrl;
    }

    // Only include auth when writing to our own Firebase project.
    final authSuffix = (_authKey.isNotEmpty && targetDbUrl == _dbUrl) ? '?auth=$_authKey' : '';
    final url = '$targetDbUrl/inbox/$userId/signals.json$authSuffix';

    final client = _buildFirebaseClient();
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
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
