import 'dart:async';
import 'dart:convert';
import 'dart:io' show WebSocket;

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
  static const _discoveryCacheKey = 'blossom_disc_ts';
  static const _discoveryCacheTtlH = 24;
  static const _secureStorage = FlutterSecureStorage();

  /// Bootstrap defaults — always reachable, used before discovery runs.
  static const _defaultServers = [
    'https://blossom.primal.net',
    'https://cdn.hzrd149.com',
    'https://blossom.band',
  ];

  /// Broader seed list probed during discovery.
  static const _seedServers = [
    'https://blossom.primal.net',
    'https://cdn.hzrd149.com',
    'https://blossom.band',
    'https://cdn.satellite.earth',
    'https://blossom.nostr.build',
    'https://media.nostr.band',
    'https://blossom.oxtr.dev',
    'https://files.sovbit.host',
    'https://blossom.swarmstr.com',
    'https://nostr.download',
  ];

  /// Nostr relays used for kind:10063 queries when no app relay is available.
  static const _bootstrapRelays = [
    'wss://relay.damus.io',
    'wss://relay.nostr.wirednet.jp',
    'wss://nos.lol',
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

  /// Discover Blossom servers in the background.
  ///
  /// Strategy (mirrors RelayDirectoryService):
  /// 1. Probe all known seed servers with a lightweight HEAD request.
  /// 2. Query Nostr relays for kind:10063 events (user server preference lists)
  ///    and probe any URLs found there.
  /// 3. Results are cached for 24 h — safe to call on every app launch.
  ///
  /// [nostrRelays] — the app's current active relay URLs; used as primary
  /// query targets. Falls back to a set of bootstrap public relays.
  Future<void> discoverServers({List<String> nostrRelays = const []}) async {
    await loadServers();

    // Throttle: skip if discovery ran within the last 24 hours.
    final prefs = await SharedPreferences.getInstance();
    final lastTsStr = prefs.getString(_discoveryCacheKey);
    if (lastTsStr != null) {
      final last = DateTime.tryParse(lastTsStr);
      if (last != null &&
          DateTime.now().difference(last).inHours < _discoveryCacheTtlH) {
        return;
      }
    }

    debugPrint('[Blossom] Starting server discovery...');
    final candidates = <String>{..._seedServers};

    // Query Nostr for kind:10063 server-preference events.
    final relaysToQuery = [
      ...nostrRelays.where((r) => r.startsWith('wss://')).take(2),
      ..._bootstrapRelays,
    ].toSet().take(4).toList();

    final nostrResults = await Future.wait(
      relaysToQuery.map((r) => _fetchFromNostr(r).catchError((_) => <String>[])),
    );
    for (final list in nostrResults) {
      candidates.addAll(list);
    }

    debugPrint('[Blossom] Probing ${candidates.length} candidate(s)...');

    // Parallel health probe — keep only servers that respond.
    final probeResults = await Future.wait(
      candidates.map((url) async {
        if (!_isValidServerUrl(url)) return null;
        return await _probeServer(url) ? url : null;
      }),
    );

    int added = 0;
    for (final url in probeResults.whereType<String>()) {
      if (!_servers.contains(url)) {
        _servers.add(url);
        added++;
      }
    }

    if (added > 0) {
      await _persist();
      debugPrint('[Blossom] Discovery done: +$added server(s), total ${_servers.length}');
    } else {
      debugPrint('[Blossom] Discovery done: no new servers found');
    }
    await prefs.setString(_discoveryCacheKey, DateTime.now().toIso8601String());
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
    required String payloadHash,
  }) async {
    final expiration = (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60).toString();
    return neb.buildEvent(
      privkeyHex: privkey,
      kind: 24242,
      content: 'Upload $payloadHash',
      tags: [
        ['t', 'upload'],
        ['x', payloadHash],
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

  /// Query a Nostr relay for kind:10063 events and extract server URLs.
  /// Closes the WS and returns whatever was found within 8 seconds.
  static Future<List<String>> _fetchFromNostr(String relayUrl) async {
    final servers = <String>{};
    final subId = 'bdisc_${DateTime.now().millisecondsSinceEpoch}';
    final completer = Completer<List<String>>();
    WebSocket? ws;

    void finish() {
      if (!completer.isCompleted) completer.complete(servers.toList());
      ws?.close().catchError((_) {});
    }

    try {
      ws = await WebSocket.connect(relayUrl)
          .timeout(const Duration(seconds: 5));
      ws.add(jsonEncode([
        'REQ', subId,
        {'kinds': [10063], 'limit': 200},
      ]));

      late StreamSubscription sub;
      sub = ws.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String);
            if (msg is! List || msg.isEmpty) return;
            if (msg[0] == 'EOSE') { sub.cancel(); finish(); return; }
            if (msg[0] != 'EVENT' || msg.length < 3) return;
            final event = msg[2];
            if (event is! Map) return;
            final tags = event['tags'];
            if (tags is! List) return;
            for (final tag in tags) {
              if (tag is! List || tag.length < 2) continue;
              if (tag[0] == 'server') {
                var url = tag[1];
                if (url is! String || !url.startsWith('https://')) continue;
                if (url.endsWith('/')) url = url.substring(0, url.length - 1);
                servers.add(url);
              }
            }
          } catch (_) {}
        },
        onDone: finish,
        onError: (_) => finish(),
      );
    } catch (e) {
      debugPrint('[Blossom] Nostr query $relayUrl: $e');
      finish();
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () { finish(); return servers.toList(); },
    );
  }

  /// HEAD-probe a server. Returns true if it responds with HTTP < 500.
  Future<bool> _probeServer(String url) async {
    try {
      final client = _httpClient();
      try {
        final resp = await client
            .head(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        return resp.statusCode < 500;
      } finally {
        client.close();
      }
    } catch (_) {
      return false;
    }
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
