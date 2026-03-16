import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tor_service.dart';
import 'cloudflare_ip_service.dart';

// ── Relay Directory Service ────────────────────────────────────────────────────
//
// Queries multiple community-maintained Nostr relay directories in parallel.
// Zero developer infrastructure required — these are public community services.
//
// If direct fetches fail (censored environment), retries via Tor SOCKS5.
//
// Result: a deduplicated list of (host, port) relay candidates ready for
// TCP probing.

class RelayDirectoryService {
  static final instance = RelayDirectoryService._();
  RelayDirectoryService._();

  static const _cacheKey  = 'relay_dir_v1';
  static const _cacheTtlH = 6;

  // Community-maintained relay directories — no developer setup needed.
  // Queried in parallel; any successful response is useful.
  static const _apis = <(String, String)>[
    ('nostr.watch/online', 'https://api.nostr.watch/v1/online'),
    ('nostr.watch/public', 'https://api.nostr.watch/v1/public'),
    ('nostr.band',         'https://api.nostr.band/v0/relays'),
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns raw URL strings from cached or freshly fetched candidates.
  /// Used by AdaptiveRelayService to get URLs for CF-filtering.
  Future<List<String>> getCandidateUrls() async {
    final prefs  = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final j  = jsonDecode(cached) as Map<String, dynamic>;
        final ts = DateTime.parse(j['ts'] as String);
        if (DateTime.now().difference(ts).inHours < _cacheTtlH) {
          return List<String>.from(j['relays'] as List);
        }
      } catch (_) {}
    }
    // Fetch fresh and return URLs
    final candidates = await _fetchDirect();
    return candidates.map((c) => 'wss://${c.$1}').toList();
  }

  /// Returns (host, port) candidates from all community directories.
  /// Uses cache if fresh. Never throws.
  Future<List<(String, int)>> getCandidates({bool viaTor = false}) async {
    if (!viaTor) {
      // Try cache first
      final prefs  = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        try {
          final j  = jsonDecode(cached) as Map<String, dynamic>;
          final ts = DateTime.parse(j['ts'] as String);
          if (DateTime.now().difference(ts).inHours < _cacheTtlH) {
            final urls = List<String>.from(j['relays'] as List);
            debugPrint('[RelayDir] ${urls.length} relay(s) from cache');
            return _urlsToCandidates(urls);
          }
        } catch (_) {}
      }
    }
    return viaTor ? _fetchViaTor() : _fetchDirect();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<List<(String, int)>> _fetchDirect() async {
    final results = await Future.wait(
      _apis.map(((String name, String url) p) =>
          _fetchFromApi(p.$1, p.$2).catchError((_) => <String>[])),
    );

    final all = <String>{};
    for (final list in results) { all.addAll(list); }
    final urls = all.toList();

    if (urls.isNotEmpty) {
      // Put CF-hosted relays first (faster in censored regions)
      final cfUrls = await CloudflareIpService.instance.filterCloudflare(urls);
      final cfSet  = cfUrls.toSet();
      final ordered = [...cfUrls, ...urls.where((u) => !cfSet.contains(u))];
      if (cfUrls.isNotEmpty) {
        debugPrint('[RelayDir] ${cfUrls.length} CF-hosted relay(s) moved to front');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode({
        'ts':     DateTime.now().toIso8601String(),
        'relays': ordered,
      }));
      debugPrint('[RelayDir] Discovered ${ordered.length} relay(s) from directories');
      return _urlsToCandidates(ordered);
    } else {
      debugPrint('[RelayDir] All directories failed');
    }
    return _urlsToCandidates(urls);
  }

  Future<List<(String, int)>> _fetchViaTor() async {
    debugPrint('[RelayDir] Fetching directories via Tor...');
    final results = await Future.wait(
      _apis.map(((String name, String url) p) async {
        try {
          final body = await TorService.instance.fetchUrl(p.$2, timeoutSec: 20);
          if (body == null) return <String>[];
          return _parseApiResponse(body);
        } catch (_) {
          return <String>[];
        }
      }),
    );
    final all = <String>{};
    for (final list in results) { all.addAll(list); }
    debugPrint('[RelayDir] Via Tor: ${all.length} relay(s)');
    return _urlsToCandidates(all.toList());
  }

  Future<List<String>> _fetchFromApi(String name, String url) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final req  = await client.getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 6));
      req.headers.set('Accept',     'application/json');
      req.headers.set('User-Agent', 'pulse-messenger/1.0');
      final resp = await req.close().timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) { client.close(force: true); return []; }
      final body = await utf8.decoder
          .bind(resp).join().timeout(const Duration(seconds: 5));
      client.close(force: true);
      final relays = _parseApiResponse(body);
      if (relays.isNotEmpty) {
        debugPrint('[RelayDir] $name: ${relays.length} relay(s)');
      }
      return relays;
    } catch (e) {
      debugPrint('[RelayDir] $name failed: $e');
      return [];
    }
  }

  /// Parses nostr.watch-style (array) and nostr.band-style (object) responses.
  List<String> _parseApiResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        // nostr.band: {"relays": [...]} or {"data": [...]}
        list = (decoded['relays'] as List?) ??
               (decoded['data']   as List?) ??
               [];
      } else {
        return [];
      }

      final relays = <String>[];
      for (final item in list) {
        final url = item is String ? item : (item is Map ? item['url'] as String? ?? '' : '');
        if (url.isEmpty) continue;
        final uri = Uri.tryParse(url);
        if (uri == null || uri.host.isEmpty) continue;
        if (!uri.scheme.startsWith('ws')) continue;
        relays.add(url);
      }
      return relays;
    } catch (_) {
      return [];
    }
  }

  List<(String, int)> _urlsToCandidates(List<String> urls) {
    final candidates = <(String, int)>[];
    for (final url in urls) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) continue;
      final port = (uri.hasPort && uri.port != 0) ? uri.port : 443;
      candidates.add((uri.host, port));
    }
    return candidates;
  }
}
