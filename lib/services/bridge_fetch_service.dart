import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _cfIps = ['116.202.120.184'];

  static const _host    = 'bridges.torproject.org';
  static const _mirrorHost = 'bridges.gitlab.torproject.org';
  static const _apiPath = '/moat/circumvention/builtin';

  // ── Cached in-memory after first fetch ────────────────────────────────────
  Map<String, List<String>>? _cached;
  DateTime? _cachedAt;
  Timer? _refreshTimer;
  Completer<Map<String, List<String>>>? _inflightFetch;

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
        } catch (e) {
          debugPrint('[BridgeFetch] Failed to parse cached bridge data: $e');
        }
      }
    }

    // Fetch fresh — dedup concurrent calls via Completer
    if (_inflightFetch != null) {
      debugPrint('[BridgeFetch] Joining in-flight fetch');
      return _inflightFetch!.future;
    }
    _inflightFetch = Completer<Map<String, List<String>>>();
    late final Map<String, List<String>> fetched;
    try {
      fetched = await _fetchBuiltin();
      _inflightFetch!.complete(fetched);
    } catch (e) {
      fetched = {};
      _inflightFetch!.complete(fetched);
    } finally {
      _inflightFetch = null;
    }
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
  //
  // Bridge fetching is rare (every 12h) and critical for Tor bootstrap.
  // No circuit breaker — always try all IPs from scratch.

  Future<Map<String, List<String>>> _fetchBuiltin() async {
    // Try 1: normal HTTPS POST (works on uncensored networks, proper ALPN).
    for (final host in [_host, _mirrorHost]) {
      try {
        final result = await _doPostNormal(host)
            .timeout(const Duration(seconds: 8));
        if (result != null) {
          debugPrint('[BridgeFetch] Normal POST to $host succeeded');
          return result;
        }
        debugPrint('[BridgeFetch] Normal POST to $host: response parsed as empty');
      } catch (e) {
        debugPrint('[BridgeFetch] Normal POST to $host failed: $e');
      }
    }

    // Try 2: IP-based direct connection (bypasses DNS poisoning).
    // No circuit breaker here — bridge fetch is rare and critical.
    for (final host in [_host, _mirrorHost]) {
      final ips = await _resolveHost(host);
      for (final ip in ips) {
        for (var attempt = 0; attempt < 2; attempt++) {
          try {
            final result = await _doPostDirect(ip, host: host)
                .timeout(const Duration(seconds: 10));
            if (result != null) {
              debugPrint('[BridgeFetch] Direct POST to $host/$ip succeeded');
              return result;
            }
          } catch (e) {
            debugPrint('[BridgeFetch] $host/$ip attempt $attempt failed: $e');
            if (attempt == 0) {
              await Future.delayed(const Duration(milliseconds: 300));
            }
          }
        }
      }
      debugPrint('[BridgeFetch] All IPs failed for $host');
    }
    return {};
  }

  /// Normal HTTPS POST — lets Dart handle DNS, TLS, and ALPN natively.
  Future<Map<String, List<String>>?> _doPostNormal(String host) async {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await httpClient
          .postUrl(Uri.parse('https://$host$_apiPath'))
          .timeout(const Duration(seconds: 8));
      _setPostHeaders(req);
      req.write(_postBody());
      final resp = await req.close().timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        debugPrint('[BridgeFetch] $host returned HTTP ${resp.statusCode}');
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

  /// IP-based POST — bypasses DNS by connecting directly to [ip]:443 with
  /// TLS SNI set to [host]. Forces HTTP/1.1 via ALPN to avoid h2 mismatch.
  /// Uses \r\n line endings per HTTP/1.1 spec (RFC 7230).
  Future<Map<String, List<String>>?> _doPostDirect(String ip, {String host = _host}) async {
    final path = Uri.parse('https://$host$_apiPath').path;
    final bodyStr = _postBody();
    final bodyBytes = utf8.encode(bodyStr);
    Socket? raw;
    SecureSocket? secure;
    try {
      raw = await Socket.connect(ip, 443,
          timeout: const Duration(seconds: 6));
      secure = await SecureSocket.secure(
        raw,
        host: host,
        supportedProtocols: ['http/1.1'],
      );

      // HTTP/1.1 request with proper \r\n line endings
      final request = 'POST $path HTTP/1.1\r\n'
          'Host: $host\r\n'
          'Content-Type: application/json\r\n'
          'Accept: application/vnd.api+json\r\n'
          'User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:128.0) Gecko/20100101 Firefox/128.0\r\n'
          'Content-Length: ${bodyBytes.length}\r\n'
          'Connection: close\r\n'
          '\r\n'
          '$bodyStr';
      secure.write(request);
      await secure.flush();

      // Read response
      final responseBuf = StringBuffer();
      await for (final chunk in utf8.decoder.bind(secure)
          .timeout(const Duration(seconds: 10))) {
        responseBuf.write(chunk);
        if (responseBuf.length > 1024 * 1024) break; // 1MB safety limit
      }
      final response = responseBuf.toString();
      secure.destroy();

      // Parse HTTP response — find body after \r\n\r\n
      final headerEnd = response.indexOf('\r\n\r\n');
      if (headerEnd == -1) {
        debugPrint('[BridgeFetch] $host/$ip: no header terminator in response');
        return null;
      }
      final headers = response.substring(0, headerEnd).toLowerCase();
      final statusLine = response.substring(0, response.indexOf('\r\n'));
      if (!statusLine.contains(' 200 ')) {
        debugPrint('[BridgeFetch] $host/$ip: $statusLine');
        return null;
      }
      var body = response.substring(headerEnd + 4);

      // Decode chunked transfer encoding if present
      if (headers.contains('transfer-encoding: chunked')) {
        body = _decodeChunked(body);
      }
      return _parseBuiltinResponse(body);
    } catch (e) {
      secure?.destroy();
      raw?.destroy();
      rethrow;
    }
  }

  /// Decode HTTP chunked transfer encoding (RFC 7230 §4.1).
  /// Format: hex-size CRLF data CRLF ... 0 CRLF CRLF
  static String _decodeChunked(String raw) {
    final buf = StringBuffer();
    var pos = 0;
    while (pos < raw.length) {
      final lineEnd = raw.indexOf('\r\n', pos);
      if (lineEnd == -1) break;
      final sizeHex = raw.substring(pos, lineEnd).trim();
      // Strip chunk extensions (e.g. ";name=value")
      final size = int.tryParse(sizeHex.split(';').first.trim(), radix: 16) ?? 0;
      if (size == 0) break; // terminal chunk
      final dataStart = lineEnd + 2;
      final dataEnd = dataStart + size;
      if (dataEnd > raw.length) {
        buf.write(raw.substring(dataStart));
        break;
      }
      buf.write(raw.substring(dataStart, dataEnd));
      pos = dataEnd + 2; // skip trailing \r\n after chunk data
    }
    return buf.toString();
  }

  void _setPostHeaders(HttpClientRequest req) {
    req.headers
      ..contentType = ContentType.json
      ..set('Accept', 'application/vnd.api+json')
      ..set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; rv:128.0) Gecko/20100101 Firefox/128.0');
  }

  String _postBody() => jsonEncode({
    'data': [{
      'version': '0.1.0',
      'type': 'client-transports',
      'supported': ['snowflake', 'obfs4', 'webtunnel'],
    }],
  });

  Map<String, List<String>>? _parseBuiltinResponse(String body) {
    try {
      final json = jsonDecode(body);

      if (json is Map) {
        final result = <String, List<String>>{};
        for (final transport in ['snowflake', 'obfs4', 'webtunnel', 'meek', 'meek-azure']) {
          final t = json[transport];

          // Current format (2025+): {"obfs4": ["obfs4 IP:port ...", ...]}
          if (t is List) {
            final lines = _sanitizeBridgeLines(t.whereType<String>());
            if (lines.isNotEmpty) result[transport] = lines;
            continue;
          }

          // Legacy nested format: {"obfs4": {"bridges": {"bridge_strings": [...]}}}
          if (t is Map) {
            final bridges = t['bridges'];
            if (bridges is Map) {
              final lines = bridges['bridge_strings'];
              if (lines is List) {
                result[transport] = _sanitizeBridgeLines(lines.whereType<String>());
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
            result[type] = _sanitizeBridgeLines(lines.whereType<String>());
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
    } catch (e) {
      debugPrint('[BridgeFetch] System DNS resolution failed for $host: $e');
    }

    // 2. DoH resolution (bypasses GFW DNS poisoning)
    try {
      final (_, dohIps) = await CloudflareIpService.instance
          .resolveAndCheck(host)
          .timeout(const Duration(seconds: 6),
              onTimeout: () => (false, <String>[]));
      final cleanDoh = dohIps.where(_isPublicIp).toList();
      if (cleanDoh.isNotEmpty) {
        debugPrint('[BridgeFetch] Resolved $host via DoH: $cleanDoh');
        return [...cleanDoh, ..._cfIps];
      }
    } catch (e) {
      debugPrint('[BridgeFetch] DoH resolution failed for $host: $e');
    }

    // 3. Hardcoded CF IPs (last resort — works even if DNS+DoH both fail)
    debugPrint('[BridgeFetch] Using hardcoded CF IPs for $host');
    return _cfIps;
  }

  static bool _isPublicIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final b = parts.map((p) => int.tryParse(p) ?? -1).toList();
    if (b.any((x) => x < 0 || x > 255)) return false;
    if (b[0] == 10) return false;                                   // RFC 1918
    if (b[0] == 172 && b[1] >= 16 && b[1] <= 31) return false;     // RFC 1918
    if (b[0] == 192 && b[1] == 168) return false;                   // RFC 1918
    if (b[0] == 127) return false;                                   // loopback
    if (b[0] == 198 && (b[1] == 18 || b[1] == 19)) return false;   // RFC 2544 benchmark
    if (b[0] == 100 && b[1] >= 64 && b[1] <= 127) return false;    // RFC 6598 CGN
    if (b[0] == 0) return false;                                     // "this" network
    return true;
  }

  /// Sanitize bridge lines from MOAT/API responses against torrc injection.
  ///
  /// A malicious or compromised MOAT response could include a bridge line with
  /// embedded `\n` to inject arbitrary torrc directives (e.g. `SocksPort 0`).
  /// This strips any line that contains control characters or is too long.
  static List<String> _sanitizeBridgeLines(Iterable<String> lines) =>
      lines
          .where((l) =>
              l.isNotEmpty &&
              l.length < 512 &&
              !l.contains('\n') &&
              !l.contains('\r') &&
              !l.contains('\x00'))
          .toList();

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

  // Community-collected obfs4 bridges (diverse IP ranges, refreshed 2026-03).
  // Used only if BridgeFetch returns empty and obfs4proxy binary is present.
  // Source: Tor-Bridges-Collector + Tor Browser defaults.
  static const _embeddedObfs4 = [
    // Diverse geographic / AS distribution for maximum reachability
    'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 '
        'cert=4TLQPJrTSaDffMK7Nbao6LC7G9OW/NHkUwIdjLSS3KYf06igE7DbfYZXne9aRzA+Lx0vTQ iat-mode=0',
    'obfs4 85.31.186.98:443 011F2599C0E9B27EE74B353155E244813763C3E5 '
        'cert=ayq0XzCwhpdysn5o0EyDU7iank0SMa1TjJMNx7s0M2R6RHXEOdYMjCmjFBOCGq7rEE3Yeg iat-mode=0',
    'obfs4 85.31.186.26:443 91A6354697E6B02A386312F68D82CF86824D3606 '
        'cert=gI3wkHNkxqGRcQFUFMoC38HA6KgFJMmKMZ27ZBx38qvvrgGJnlb2M/f4h1oJ6kRNnEHtZg iat-mode=0',
    'obfs4 38.229.1.78:80 C8CBDB2464FC9804A69531437BCF2BE31FDD2EE4 '
        'cert=Hmyfd2ev46gGY7NoVxA9ngrPF2zCZtzskRTzoWXbxNkzeVnGFPWmrTKsuXx4z5Z/3p3E2A iat-mode=0',
    'obfs4 37.218.245.14:38224 D9A82D2F9C2F65A18407B1D2B764F130847F8B5D '
        'cert=bjRkvkvkH3bY4mNFzI4FPSUNfqnAEIFJDCPFcFjCAlVtyFqDqMFq8r/yrMcBuIaHMuDCYg iat-mode=0',
    // Fresh community-sourced bridges (2025+)
    'obfs4 2.59.183.64:4875 71FF3B7AB90C34646CFB80753FD758761D73927A '
        'cert=hgR5X0kiUdQPmxvrzVCpqUcnMKtcrs4tw2FNJ73EwH1Y+VUXoZZ7rJyU2J8UmWYfQo8jBQ iat-mode=0',
    'obfs4 2.200.59.69:8888 B7E8B832F055435293840D69FE476AA6143C0449 '
        'cert=X2IIgewaeED2fctW8uSAd9NTsq8fP3uhsm7yS6QUC3k/NdXvEMtJelEz/t3X5SnmFCnHJQ iat-mode=0',
    'obfs4 2.35.113.108:9906 5A3E33D354B7B7BAE5D3873EF8A68E79B4194A2A '
        'cert=IJXo/z1hPSJ0Yr2bShs3UVnBS35rweyktBxY+azSyQwSwD2qAdrVpo8VSWhVxly6wIWkDg iat-mode=0',
    'obfs4 1.2.217.144:5987 DCE57AC308CB82958C56B1B5C9C3D08D225EC942 '
        'cert=Uemn6kep2gxo9J0P81geJV3gTWQtkrNHvEh1DL3wzhvLaUaIrn0/e0a1mvyB3T4c0jmHKg iat-mode=0',
    'obfs4 2.102.149.89:5830 0346CC8DD92B635B65E46D0917395045DFA47717 '
        'cert=jq65/cNMiMPlL/Y4TjNru0KP9pAp31y3wU/Jm1mFK28OhJQ23aQne6Od4nqzUIRaIADBBw iat-mode=0',
  ];

  // WebTunnel bridges — fetched dynamically from MOAT API only.
  // No embedded fallback: WebTunnel bridges rotate frequently and require
  // specific server-side deployment. Stale bridges waste 90s timing out.
  // If MOAT is unreachable, the PT chain falls through to Snowflake gracefully.
  static const _embeddedWebTunnel = <String>[];
}
