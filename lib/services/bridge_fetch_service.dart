import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'circuit_breaker_service.dart';
import 'cloudflare_ip_service.dart';

// ── BridgeFetchService ────────────────────────────────────────────────────────
//
// Fetches fresh pluggable-transport bridge lines from the Tor Project's
// MOAT circumvention API, without requiring a CAPTCHA.
//
// Endpoint: POST /moat/circumvention/builtin
// Host:     bridges.torproject.org  (Cloudflare AS13335)
//
// Connection strategy (same as CloudflareIpService DoH):
//   1. System DNS  →  2. Known CF IPs (1.1.1.1 DNS lookup bypassed)
//   Direct TCP to CF IP; TLS SNI = bridges.torproject.org.
//
// Result is cached in SharedPreferences for 24 h.
// On failure, callers fall back to embedded static bridge lists.
//
// Supported transports: snowflake, obfs4

class BridgeFetchService {
  static final instance = BridgeFetchService._();
  BridgeFetchService._();

  static const _cacheKey    = 'bridge_fetch_v1';
  static const _cacheTtlMs  = 24 * 60 * 60 * 1000; // 24 h
  static const _staleTtlMs  = 48 * 60 * 60 * 1000; // 48 h — stale threshold
  static const _refreshInterval = Duration(hours: 12);

  // Known Cloudflare IP for bridges.torproject.org (verified CF AS13335).
  // We connect by IP to avoid DNS poisoning, SNI carries the hostname.
  static const _cfIps = ['104.21.56.28', '172.67.178.139'];

  static const _host    = 'bridges.torproject.org';
  static const _mirrorHost = 'bridges.gitlab.torproject.org';
  static const _apiPath = '/moat/circumvention/builtin';

  // ── Cached in-memory after first fetch ────────────────────────────────────
  Map<String, List<String>>? _cached;
  DateTime? _cachedAt;
  Timer? _refreshTimer;

  /// Age of the current bridge data (null if never fetched).
  DateTime? get lastFetchTime => _cachedAt;

  // ── Periodic refresh ────────────────────────────────────────────────────────

  /// Starts a 12-hour periodic background refresh. Safe to call multiple times.
  void startPeriodicRefresh() {
    if (_refreshTimer?.isActive == true) return;
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _getOrFetch(force: true).then((_) {}, onError: (e) {
        debugPrint('[BridgeFetch] Periodic refresh failed: $e');
      });
    });
    debugPrint('[BridgeFetch] Periodic refresh started (every ${_refreshInterval.inHours}h)');
  }

  /// Stops the periodic refresh timer.
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns snowflake bridge lines — fresh, cached, or embedded fallback.
  Future<List<String>> getSnowflakeBridges() async {
    final m = await _getOrFetch();
    final lines = m['snowflake'] ?? [];
    return lines.isNotEmpty ? lines : _embeddedSnowflake;
  }

  /// Returns obfs4 bridge lines — fresh, cached, or embedded fallback.
  Future<List<String>> getObfs4Bridges() async {
    final m = await _getOrFetch();
    final lines = m['obfs4'] ?? [];
    return lines.isNotEmpty ? lines : _embeddedObfs4;
  }

  /// Returns webtunnel bridge lines — fresh, cached, or embedded fallback.
  Future<List<String>> getWebTunnelBridges() async {
    final m = await _getOrFetch();
    final lines = m['webtunnel'] ?? [];
    return lines.isNotEmpty ? lines : _embeddedWebTunnel;
  }

  /// Returns a flat map transport → [bridge_lines].
  Future<Map<String, List<String>>> _getOrFetch({bool force = false}) async {
    // In-memory fast path (skipped when force=true)
    if (!force &&
        _cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!).inMilliseconds < _cacheTtlMs) {
      return _cached!;
    }

    final prefs = await SharedPreferences.getInstance();

    // SharedPrefs cache (skipped when force=true)
    if (!force) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        try {
          final j  = jsonDecode(raw) as Map<String, dynamic>;
          final ts = j['ts'] as int? ?? 0;
          if (DateTime.now().millisecondsSinceEpoch - ts < _cacheTtlMs) {
            final data = (j['data'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v as List)),
            );
            _cached   = data;
            _cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
            debugPrint('[BridgeFetch] Loaded from cache');
            return _cached!;
          }
        } catch (_) {}
      }
    }

    // Fetch fresh
    final fetched = await _fetchBuiltin();
    if (fetched.isNotEmpty) {
      _cached   = fetched;
      _cachedAt = DateTime.now();
      await prefs.setString(_cacheKey, jsonEncode({
        'ts':   DateTime.now().millisecondsSinceEpoch,
        'data': fetched,
      }));
      debugPrint('[BridgeFetch] Fetched: '
          '${fetched['snowflake']?.length ?? 0} snowflake, '
          '${fetched['obfs4']?.length ?? 0} obfs4');
      // Auto-start periodic refresh on successful fetch
      startPeriodicRefresh();
    } else {
      debugPrint('[BridgeFetch] Fetch failed — using embedded fallback');
      // Stale bridge detection: if cached data is older than 48h and fetch
      // failed, clear the cache so callers fall through to embedded bridges.
      if (_cachedAt != null &&
          DateTime.now().difference(_cachedAt!).inMilliseconds >= _staleTtlMs) {
        debugPrint('[BridgeFetch] Cache stale (>48h) + fetch failed — clearing');
        _cached   = null;
        _cachedAt = null;
        await prefs.remove(_cacheKey);
      }
    }
    return _cached ?? {};
  }

  // ── Network fetch ──────────────────────────────────────────────────────────

  Future<Map<String, List<String>>> _fetchBuiltin() async {
    // Try primary host, then mirror if primary fails all IPs.
    final breaker = CircuitBreakerService.instance;
    for (final host in [_host, _mirrorHost]) {
      final ips = await _resolveHost(host);
      for (final ip in ips) {
        if (breaker.shouldSkipSync(ip)) {
          debugPrint('[BridgeFetch] Skipping $ip (circuit breaker)');
          continue;
        }
        // Try each IP twice — transient errors (TCP reset, TLS handshake
        // timeout) are common on censored networks. One retry is cheap.
        for (var attempt = 0; attempt < 2; attempt++) {
          try {
            final result = await _doPost(ip, host: host)
                .timeout(const Duration(seconds: 12));
            if (result != null) {
              unawaited(breaker.recordSuccess(ip));
              return result;
            }
          } catch (e) {
            debugPrint('[BridgeFetch] $host/$ip attempt $attempt failed: $e');
            if (attempt == 0) {
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }
        unawaited(breaker.recordFailure(ip));
      }
      debugPrint('[BridgeFetch] All IPs failed for $host');
    }
    return {};
  }

  Future<Map<String, List<String>>?> _doPost(String ip, {String host = _host}) async {
    final httpClient = HttpClient();
    httpClient.connectionFactory = (uri, proxyHost, proxyPort) async {
      final raw = await Socket.connect(ip, 443,
          timeout: const Duration(seconds: 6));
      return ConnectionTask.fromSocket(Future.value(raw), () => raw.destroy());
    };

    try {
      final req = await httpClient
          .postUrl(Uri.parse('https://$host$_apiPath'))
          .timeout(const Duration(seconds: 8));
      req.headers
        ..contentType = ContentType.json
        ..set('Accept', 'application/vnd.api+json')
        ..set('User-Agent', 'pulse-messenger/1.0');
      req.write(jsonEncode({
        'data': [{
          'version': '0.1.0',
          'type': 'client-transports',
          'supported': ['snowflake', 'obfs4', 'webtunnel'],
        }],
      }));

      final resp = await req.close().timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        httpClient.close(force: true);
        return null;
      }
      final body = await utf8.decoder
          .bind(resp).join().timeout(const Duration(seconds: 8));
      httpClient.close(force: true);
      return _parseBuiltinResponse(body);
    } catch (e) {
      httpClient.close(force: true);
      rethrow;
    }
  }

  Map<String, List<String>>? _parseBuiltinResponse(String body) {
    try {
      final json = jsonDecode(body);

      // moat/circumvention/builtin format:
      // { "snowflake": {"bridges": {"bridge_strings": [...]}},
      //   "obfs4":     {"bridges": {"bridge_strings": [...]}} }
      if (json is Map) {
        final result = <String, List<String>>{};
        for (final transport in ['snowflake', 'obfs4', 'webtunnel']) {
          final t = json[transport];
          if (t is Map) {
            final bridges = t['bridges'];
            if (bridges is Map) {
              final lines = bridges['bridge_strings'];
              if (lines is List) {
                result[transport] = lines.cast<String>().toList();
              }
            }
          }
        }
        if (result.isNotEmpty) return result;
      }

      // Legacy/alternative format: {"data": [{"type": "...", "bridge_strings": [...]}]}
      if (json is Map && json['data'] is List) {
        final result = <String, List<String>>{};
        for (final item in json['data'] as List) {
          if (item is! Map) continue;
          final type  = item['type'] as String?;
          final lines = item['bridge_strings'];
          if (type != null && lines is List) {
            result[type] = lines.cast<String>().toList();
          }
        }
        if (result.isNotEmpty) return result;
      }
    } catch (e) {
      debugPrint('[BridgeFetch] Parse error: $e');
    }
    return null;
  }

  Future<List<String>> _resolveHost([String host = _host]) async {
    // 1. System DNS (fast on non-censored networks)
    try {
      final addrs = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      final ips = addrs
          .where((a) => a.type == InternetAddressType.IPv4)
          .map((a) => a.address)
          .where(_isPublicIp)
          .toList();
      if (ips.isNotEmpty) return [...ips, ..._cfIps];
    } catch (_) {}

    // 2. DoH resolution (bypasses GFW DNS poisoning)
    try {
      final (_, dohIps) = await CloudflareIpService.instance
          .resolveAndCheck(host)
          .timeout(const Duration(seconds: 6),
              onTimeout: () => (false, <String>[]));
      if (dohIps.isNotEmpty) {
        debugPrint('[BridgeFetch] Resolved $host via DoH: $dohIps');
        return [...dohIps, ..._cfIps];
      }
    } catch (_) {}

    // 3. Hardcoded CF IPs (last resort — works even if DNS+DoH both fail)
    debugPrint('[BridgeFetch] Using hardcoded CF IPs for $host');
    return _cfIps;
  }

  static bool _isPublicIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final b = parts.map((p) => int.tryParse(p) ?? -1).toList();
    if (b.any((x) => x < 0 || x > 255)) return false;
    if (b[0] == 10) return false;
    if (b[0] == 172 && b[1] >= 16 && b[1] <= 31) return false;
    if (b[0] == 192 && b[1] == 168) return false;
    if (b[0] == 127) return false;
    return true;
  }

  // ── Embedded fallback bridge lines ─────────────────────────────────────────
  //
  // Tor Browser's official built-in bridges (public, from torproject.org).
  // Updated from Tor Browser 13.x / Orbot 17.9.x.
  // These are fetched fresh at runtime; embedded only as last-resort fallback.

  // Expanded STUN list for embedded bridges — non-Google servers first
  // (Google STUN blocked in mainland China). Raw IP fallback at the end.
  static const _sfIce =
      'ice=stun:stun.cloudflare.com:3478,stun:global.stun.twilio.com:3478,'
      'stun:stun.relay.metered.ca:80,stun:stun.nextcloud.com:3478,'
      'stun:stun.nextcloud.com:443,stun:stun.bethesda.net:3478,'
      'stun:stun.mixvoip.com:3478,stun:stun.voipgate.com:3478,'
      'stun:stun.epygi.com:3478,stun:stun.stunprotocol.org:3478,'
      'stun:stun.services.mozilla.com:3478,stun:74.125.250.129:19302';

  static const _embeddedSnowflake = [
    'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
        'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
        'url=https://1098762253.rsc.cdn77.org/ '
        'fronts=app.datapacket.com,www.datapacket.com '
        '$_sfIce '
        'utls-imitate=hellorandomizedalpn',
    'snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA '
        'fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA '
        'url=https://1098762253.rsc.cdn77.org/ '
        'fronts=app.datapacket.com,www.datapacket.com '
        '$_sfIce '
        'utls-imitate=hellorandomizedalpn',
    // AMP-cache fronting variant (alternative CDN path)
    'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
        'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
        'url=https://snowflake.torproject.org/ '
        'fronts=www.google.com,www.gstatic.com '
        '$_sfIce '
        'utls-imitate=hellorandomizedalpn',
  ];

  // Tor Browser 13.x built-in obfs4 bridges (public, from Tor Project).
  // Used only if BridgeFetch returns empty and obfs4proxy binary is present.
  static const _embeddedObfs4 = [
    'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 '
        'cert=4TLQPJrTSaDffMK7Nbao6LC7G9OW/NHkUwIdjLSS3KYf06igE7DbfYZXne9aRzA+Lx0vTQ iat-mode=0',
    'obfs4 37.218.245.14:38224 D9A82D2F9C2F65A18407B1D2B764F130847F8B5D '
        'cert=bjRkvkvkH3bY4mNFzI4FPSUNfqnAEIFJDCPFcFjCAlVtyFqDqMFq8r/yrMcBuIaHMuDCYg iat-mode=0',
    'obfs4 85.31.186.98:443 011F2599C0E9B27EE74B353155E244813763C3E5 '
        'cert=ayq0XzCwhpdysn5o0EyDU7iank0SMa1TjJMNx7s0M2R6RHXEOdYMjCmjFBOCGq7rEE3Yeg iat-mode=0',
    'obfs4 85.31.186.26:443 91A6354697E6B02A386312F68D82CF86824D3606 '
        'cert=gI3wkHNkxqGRcQFUFMoC38HA6KgFJMmKMZ27ZBx38qvvrgGJnlb2M/f4h1oJ6kRNnEHtZg iat-mode=0',
    'obfs4 38.229.1.78:80 C8CBDB2464FC9804A69531437BCF2BE31FDD2EE4 '
        'cert=Hmyfd2ev46gGY7NoVxA9ngrPF2zCZtzskRTzoWXbxNkzeVnGFPWmrTKsuXx4z5Z/3p3E2A iat-mode=0',
  ];

  // WebTunnel bridges — fetched dynamically from MOAT API only.
  // No embedded fallback: WebTunnel bridges rotate frequently and require
  // specific server-side deployment. Stale bridges waste 90s timing out.
  // If MOAT is unreachable, the PT chain falls through to Snowflake gracefully.
  static const _embeddedWebTunnel = <String>[];
}
