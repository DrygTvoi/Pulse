import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'nostr_event_builder.dart' as neb;
import 'psiphon_service.dart' as psiphon;
import 'tor_service.dart' as tor;

/// Blossom blob storage client (BUD-01/BUD-02).
///
/// Upload flow:  encrypt file → SHA-256 → kind:24242 auth → PUT /upload
/// Download flow: GET /sha256hex → verify hash
///
/// Servers are discovered via kind:10063 relay queries and peer exchange.
class BlossomService {
  BlossomService._();
  static final instance = BlossomService._();

  static const _prefsKey = 'blossom_servers_v1';
  static const _secureStorage = FlutterSecureStorage();

  static const _defaultServers = [
    'https://blossom.primal.net',
    'https://cdn.hzrd149.com',
    'https://blossom.band',
  ];

  /// Known servers sorted by health (failures push to back).
  List<String> _servers = [..._defaultServers];
  final Map<String, int> _failCount = {};
  bool _loaded = false;

  // ── Public API ──────────────────────────────────────────────────────────────

  bool get isAvailable => _servers.isNotEmpty;

  List<String> get servers => List.unmodifiable(_servers);

  /// Load persisted servers from SharedPreferences.
  Future<void> loadServers() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        // Merge: persisted first, then defaults (deduped)
        final seen = <String>{};
        final merged = <String>[];
        for (final s in [...raw, ..._defaultServers]) {
          if (seen.add(s)) merged.add(s);
        }
        _servers = merged;
      }
    } catch (e) {
      debugPrint('[Blossom] loadServers error: $e');
    }
  }

  /// Add servers discovered from peers (blossom_exchange signal).
  Future<void> addPeerServers(List<String> urls) async {
    bool changed = false;
    for (final url in urls) {
      if (!_isValidServerUrl(url)) continue;
      if (!_servers.contains(url)) {
        _servers.add(url);
        changed = true;
      }
    }
    if (changed) await _persist();
  }

  /// Upload encrypted bytes to the best available Blossom server.
  /// Returns the server URL and SHA-256 hash on success, or null.
  Future<({String server, String hash})?> upload(Uint8List encryptedBytes) async {
    await loadServers();
    final hash = crypto.sha256.convert(encryptedBytes).toString();
    final privkey = await _secureStorage.read(key: 'nostr_privkey');
    if (privkey == null || privkey.isEmpty) {
      debugPrint('[Blossom] No Nostr privkey — cannot sign upload auth');
      return null;
    }

    final ranked = _rankedServers();
    for (final server in ranked) {
      try {
        final uploadUrl = '$server/upload';
        final authEvent = await _buildAuthEvent(
          privkey: privkey,
          url: uploadUrl,
          method: 'PUT',
          payloadHash: hash,
        );
        final authHeader = 'Nostr ${base64Encode(utf8.encode(jsonEncode(authEvent)))}';

        final client = _httpClient();
        try {
          final resp = await client
              .put(
                Uri.parse(uploadUrl),
                headers: {
                  'Authorization': authHeader,
                  'Content-Type': 'application/octet-stream',
                },
                body: encryptedBytes,
              )
              .timeout(const Duration(seconds: 60));

          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            _recordSuccess(server);
            debugPrint('[Blossom] Uploaded ${encryptedBytes.length}B to $server ($hash)');
            return (server: server, hash: hash);
          }
          debugPrint('[Blossom] Upload to $server failed: ${resp.statusCode} ${resp.body}');
          _recordFailure(server);
        } finally {
          client.close();
        }
      } catch (e) {
        debugPrint('[Blossom] Upload to $server error: $e');
        _recordFailure(server);
      }
    }
    return null;
  }

  /// Download blob by SHA-256 hash. Tries preferredServers first, then all known.
  /// Returns null on failure. Verifies hash of downloaded bytes.
  Future<Uint8List?> download(String hash, {List<String>? preferredServers}) async {
    await loadServers();
    final tryOrder = <String>[];
    final seen = <String>{};
    for (final s in [...?preferredServers, ..._rankedServers()]) {
      if (seen.add(s)) tryOrder.add(s);
    }

    for (final server in tryOrder) {
      try {
        final url = '$server/$hash';
        final client = _httpClient();
        try {
          final resp = await client
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 60));
          if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
            // Verify integrity
            final dlHash = crypto.sha256.convert(resp.bodyBytes).toString();
            if (dlHash != hash) {
              debugPrint('[Blossom] Hash mismatch from $server: expected $hash, got $dlHash');
              _recordFailure(server);
              continue;
            }
            _recordSuccess(server);
            debugPrint('[Blossom] Downloaded ${resp.bodyBytes.length}B from $server');
            return resp.bodyBytes;
          }
          if (resp.statusCode != 404) _recordFailure(server);
        } finally {
          client.close();
        }
      } catch (e) {
        debugPrint('[Blossom] Download from $server error: $e');
        _recordFailure(server);
      }
    }
    return null;
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  /// Build kind:24242 authorization event (BUD-01).
  Future<Map<String, dynamic>> _buildAuthEvent({
    required String privkey,
    required String url,
    required String method,
    required String payloadHash,
  }) async {
    final expiration = (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60).toString();
    return neb.buildEvent(
      privkeyHex: privkey,
      kind: 24242,
      content: 'Upload $payloadHash',
      tags: [
        ['t', 'upload'],
        ['u', url],
        ['method', method],
        ['payload', payloadHash],
        ['expiration', expiration],
      ],
    );
  }

  http.Client _httpClient() {
    return psiphon.buildPsiphonHttpClient() ??
        tor.buildTorHttpClient() ??
        http.Client();
  }

  List<String> _rankedServers() {
    final sorted = [..._servers];
    sorted.sort((a, b) => (_failCount[a] ?? 0).compareTo(_failCount[b] ?? 0));
    return sorted;
  }

  void _recordSuccess(String server) {
    _failCount[server] = 0;
  }

  void _recordFailure(String server) {
    _failCount[server] = (_failCount[server] ?? 0) + 1;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _servers);
    } catch (e) {
      debugPrint('[Blossom] persist error: $e');
    }
  }

  /// Validate server URL: must be https://, not private IP, not localhost.
  static bool _isValidServerUrl(String url) {
    if (!url.startsWith('https://')) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return false;
    final host = uri.host;
    if (host == 'localhost' || host == '127.0.0.1' || host == '::1' ||
        host == '0.0.0.0') {
      return false;
    }
    if (host.startsWith('10.') || host.startsWith('192.168.') ||
        host.startsWith('169.254.')) {
      return false;
    }
    if (host.startsWith('172.')) {
      final seg = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
      if (seg != null && seg >= 16 && seg <= 31) return false;
    }
    return true;
  }

  /// Exposed for testing.
  @visibleForTesting
  static bool isValidServerUrl(String url) => _isValidServerUrl(url);
}
