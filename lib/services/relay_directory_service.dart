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

  /// Create a detached instance for unit testing.
  @visibleForTesting
  factory RelayDirectoryService.forTesting() => RelayDirectoryService._();

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
      } catch (e) {
        debugPrint('[RelayDir] Failed to parse cached relay URLs: $e');
      }
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
        } catch (e) {
          debugPrint('[RelayDir] Failed to parse cached candidates: $e');
        }
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
    // Try system DNS first, fall back to DoH if it fails (GFW DNS poisoning)
    final result = await _fetchFromApiDirect(name, url);
    if (result.isNotEmpty) return result;
    return _fetchFromApiViaDoh(name, url);
  }

  Future<List<String>> _fetchFromApiDirect(String name, String url) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final req  = await client.getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 6));
      req.headers.set('Accept',     'application/json');
      req.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; rv:128.0) Gecko/20100101 Firefox/128.0');
      final resp = await req.close().timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) { client.close(force: true); return []; }
      // BUG-01: cap body at 4 MB to prevent OOM from a giant API response.
      const maxBodyBytes = 4 * 1024 * 1024;
      final bodyBuf = StringBuffer();
      var bodyOk = true;
      await for (final chunk in utf8.decoder.bind(resp)
          .timeout(const Duration(seconds: 5), onTimeout: (s) => s.close())) {
        bodyBuf.write(chunk);
        if (bodyBuf.length > maxBodyBytes) { bodyOk = false; break; }
      }
      client.close(force: true);
      if (!bodyOk) {
        debugPrint('[RelayDir] $name: body exceeded 4 MB, discarding');
        return [];
      }
      final body = bodyBuf.toString();
      final relays = _parseApiResponse(body);
      if (relays.isNotEmpty) {
        debugPrint('[RelayDir] $name: ${relays.length} relay(s)');
      }
      return relays;
    } catch (e) {
      debugPrint('[RelayDir] $name direct failed: $e');
      return [];
    }
  }

  /// Fetch relay directory API using DoH-resolved IPs (bypasses DNS poisoning).
  Future<List<String>> _fetchFromApiViaDoh(String name, String url) async {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      // Resolve via DoH
      final (_, ips) = await CloudflareIpService.instance
          .resolveAndCheck(host)
          .timeout(const Duration(seconds: 5),
              onTimeout: () => (false, <String>[]));
      // resolveAndCheck may return non-CF IPs too — we just need the IPs
      List<String> resolvedIps = ips;
      if (resolvedIps.isEmpty) {
        // Try a plain DoH resolve without CF check
        resolvedIps = await CloudflareIpService.instance
            .resolveViaDoh(host)
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
      }
      if (resolvedIps.isEmpty) return [];

      final ip = resolvedIps.first;
      final port = uri.hasPort ? uri.port : 443;
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      client.connectionFactory = (cfUri, proxyHost, proxyPort) async {
        final raw = await Socket.connect(ip, port,
            timeout: const Duration(seconds: 4));
        return ConnectionTask.fromSocket(
            Future.value(raw), () => raw.destroy());
      };
      final req = await client.getUrl(uri)
          .timeout(const Duration(seconds: 6));
      req.headers.set('Accept', 'application/json');
      req.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; rv:128.0) Gecko/20100101 Firefox/128.0');
      final resp = await req.close().timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) { client.close(force: true); return []; }
      const maxBodyBytes = 4 * 1024 * 1024;
      final bodyBuf = StringBuffer();
      var bodyOk = true;
      await for (final chunk in utf8.decoder.bind(resp)
          .timeout(const Duration(seconds: 5), onTimeout: (s) => s.close())) {
        bodyBuf.write(chunk);
        if (bodyBuf.length > maxBodyBytes) { bodyOk = false; break; }
      }
      client.close(force: true);
      if (!bodyOk) {
        debugPrint('[RelayDir] $name (DoH): body exceeded 4 MB, discarding');
        return [];
      }
      final body = bodyBuf.toString();
      final relays = _parseApiResponse(body);
      if (relays.isNotEmpty) {
        debugPrint('[RelayDir] $name (DoH): ${relays.length} relay(s)');
      }
      return relays;
    } catch (e) {
      debugPrint('[RelayDir] $name DoH failed: $e');
      return [];
    }
  }

  /// Parses nostr.watch-style (array) and nostr.band-style (object) responses.
  /// Exposed for unit testing.
  @visibleForTesting
  List<String> parseApiResponse(String body) => _parseApiResponse(body);

  /// Exposed for unit testing.
  @visibleForTesting
  List<(String, int)> urlsToCandidates(List<String> urls) =>
      _urlsToCandidates(urls);

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

      const maxRelays = 500;
      final relays = <String>[];
      for (final item in list) {
        if (relays.length >= maxRelays) break;
        final url = item is String ? item : (item is Map ? item['url'] as String? ?? '' : '');
        if (url.isEmpty || url.length > 256) continue;
        final uri = Uri.tryParse(url);
        if (uri == null || uri.host.isEmpty) continue;
        // BUG-02: reject ws:// (cleartext Nostr traffic visible to observer)
        if (uri.scheme != 'wss') continue;
        // BUG-03: strip embedded credentials to prevent Authorization header leakage
        final cleanUrl = uri.userInfo.isEmpty ? url : uri.replace(userInfo: '').toString();
        relays.add(cleanUrl);
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
