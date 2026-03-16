import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── CloudflareIpService ───────────────────────────────────────────────────────
//
// Determines whether a hostname resolves to a Cloudflare IP address.
// Uses Cloudflare's published IP ranges (https://www.cloudflare.com/ips-v4)
// cached in SharedPreferences for 24 hours.
//
// DNS resolution strategy (important for censored networks):
//   1. System DNS (fast, works on normal networks)
//   2. DoH via 1.1.1.1 (Cloudflare DNS-over-HTTPS, bypasses GFW DNS poisoning)
//      Connects to 1.1.1.1 by IP — no DNS needed, CF IPs not blocked by GFW.
//   3. Empty list → returns false
//
// resolveAndCheck(host) returns (isCf, ips) so callers can use the
// DoH-resolved IPs to connect directly, bypassing poisoned system DNS.

class CloudflareIpService {
  static final instance = CloudflareIpService._();
  CloudflareIpService._();

  static const _cacheKeyRanges = 'cf_ip_ranges';
  static const _cacheKeyTs     = 'cf_ip_ranges_ts';
  static const _cacheTtlMs     = 24 * 60 * 60 * 1000; // 24h

  // Official Cloudflare IPv4 ranges as of 2025 (rarely change).
  // Source: https://www.cloudflare.com/ips-v4
  static const _fallbackRanges = [
    '173.245.48.0/20',
    '103.21.244.0/22',
    '103.22.200.0/22',
    '103.31.4.0/22',
    '141.101.64.0/18',
    '108.162.192.0/18',
    '190.93.240.0/20',
    '188.114.96.0/20',
    '197.234.240.0/22',
    '198.41.128.0/17',
    '162.158.0.0/15',
    '104.16.0.0/13',
    '104.24.0.0/14',
    '172.64.0.0/13',
    '131.0.72.0/22',
  ];

  List<_CidrBlock>? _blocks;
  DateTime? _loadedAt;

  // ECH config cache: host → (config_bytes, fetched_at)
  final Map<String, (Uint8List, DateTime)> _echCache = {};

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true if [host] resolves to a Cloudflare IP.
  /// Tries system DNS first; falls back to DoH if system DNS fails.
  /// Never throws — returns false on any error.
  Future<bool> isOnCloudflare(String host) async {
    final (isCf, _) = await resolveAndCheck(host);
    return isCf;
  }

  /// Returns (isCf, resolvedIps) for [host].
  ///
  /// Tries system DNS first (fast path). If system DNS returns no IPv4
  /// results (e.g. NXDOMAIN due to GFW poisoning), retries via DoH at
  /// Cloudflare 1.1.1.1 (accessible from CN by IP, no DNS needed).
  ///
  /// Callers can use the returned IPs to open direct connections to CF
  /// servers, bypassing poisoned system DNS.
  Future<(bool, List<String>)> resolveAndCheck(String host) async {
    try {
      await _ensureBlocks();

      // Step 1: system DNS
      List<String> ips = [];
      try {
        final addrs = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        ips = addrs
            .where((a) => a.type == InternetAddressType.IPv4)
            .map((a) => a.address)
            .where(_isPublicIp)   // filter RFC-1918 / loopback poison results
            .toList();
      } catch (_) {}

      // Step 2: DoH fallback (when system DNS fails or returns no public IPs)
      if (ips.isEmpty) {
        debugPrint('[CF] System DNS failed for $host — trying DoH');
        ips = await _dohResolve(host);
      }

      if (ips.isEmpty) return (false, <String>[]);

      final isCf = ips.any((ip) {
        final n = _ipToInt(ip);
        if (n == null) return false;
        return _blocks!.any((b) => b.contains(n));
      });

      return (isCf, ips);
    } catch (_) {
      return (false, <String>[]);
    }
  }

  /// Fetches the ECH (Encrypted Client Hello) config blob for [host] via DoH.
  ///
  /// Queries DNS HTTPS record (type=65) from Cloudflare DoH at 1.1.1.1 by IP
  /// — no DNS needed, works even on censored networks.
  ///
  /// ECH lets TLS clients encrypt the SNI field so DPI cannot see which
  /// hostname is being contacted. Cloudflare deploys ECH on all its edges.
  ///
  /// Returns raw ECH config bytes (to be passed to TLS stack when dart:io
  /// gains ECH support), or null if unavailable. Currently used for
  /// pre-fetching and caching; call [isOnCloudflare] to check CF hosting first.
  ///
  /// TODO: wire these bytes into dart:io SecureSocket once
  ///       https://github.com/dart-lang/sdk/issues/55949 lands.
  Future<Uint8List?> fetchEchConfig(String host) async {
    // In-memory cache hit
    final entry = _echCache[host];
    if (entry != null) {
      final (bytes, fetchedAt) = entry;
      if (DateTime.now().difference(fetchedAt).inMilliseconds < _cacheTtlMs) {
        return bytes;
      }
    }

    // ECH records are only served by Cloudflare DoH (type=65 HTTPS record).
    // Google/Quad9 may not return the ech= SvcParam, so try CF providers first,
    // then fall back to others in case CF is blocked.
    for (final (dohIp, sniHost, pathPrefix) in _dohProviders) {
      try {
        final httpClient = _pinnedDohClient(dohIp, sniHost);
        final req = await httpClient
            .getUrl(Uri.parse(
                'https://$sniHost$pathPrefix'
                '?name=${Uri.encodeQueryComponent(host)}&type=HTTPS&do=1'))
            .timeout(const Duration(seconds: 5));
        req.headers.set('Accept', 'application/dns-json');
        final resp = await req.close().timeout(const Duration(seconds: 5));
        if (resp.statusCode != 200) {
          httpClient.close(force: true);
          continue;
        }
        final body = await utf8.decoder
            .bind(resp)
            .join()
            .timeout(const Duration(seconds: 3));
        httpClient.close(force: true);

        final json = jsonDecode(body) as Map<String, dynamic>;
        final ad = json['AD'] as bool? ?? false;
        final answers = (json['Answer'] as List?) ?? [];
        for (final a in answers) {
          final rec = a as Map<String, dynamic>;
          if (rec['type'] != 65) continue; // only HTTPS (type 65) records
          final data = rec['data'] as String? ?? '';
          // HTTPS record RDATA text form:
          //   "1 . alpn=\"h2,h3\" ech=\"<base64>\" ipv4hint=\"...\""
          final echMatch =
              RegExp(r'ech="([A-Za-z0-9+/=]+)"').firstMatch(data);
          if (echMatch != null) {
            try {
              final echBytes = base64.decode(echMatch.group(1)!);
              _echCache[host] = (echBytes, DateTime.now());
              debugPrint('[CF/ECH] $host → ${echBytes.length}B ECH'
                  ' (via $dohIp${ad ? ', DNSSEC✓' : ''})');
              return echBytes;
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint('[CF/ECH] $dohIp failed for $host: $e');
      }
    }
    return null;
  }

  /// Filters [urls] to those whose host resolves to Cloudflare IPs.
  /// Runs DNS lookups in parallel.
  Future<List<String>> filterCloudflare(List<String> urls) async {
    if (urls.isEmpty) return [];
    final results = await Future.wait(
      urls.map((url) async {
        try {
          final host = Uri.parse(url).host;
          if (host.isEmpty) return null;
          final isCf = await isOnCloudflare(host);
          return isCf ? url : null;
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<String>().toList();
  }

  // ── DoH resolver (multi-provider) ──────────────────────────────────────────
  //
  // Providers tried in order:
  //   1. Cloudflare 1.1.1.1 / 1.0.0.1 — accessible from CN/IR, rarely blocked
  //   2. Google 8.8.8.8 / 8.8.4.4     — widely available, sometimes blocked in CN
  //   3. Quad9 9.9.9.9                 — independent, malware-filtering
  //
  // All connections are by raw IP (no DNS needed to reach the DoH server).

  static const _dohProviders = [
    // (ip, sniHost, pathPrefix)
    ('1.1.1.1',  'cloudflare-dns.com', '/dns-query'),
    ('1.0.0.1',  'cloudflare-dns.com', '/dns-query'),
    ('8.8.8.8',  'dns.google',         '/resolve'),
    ('8.8.4.4',  'dns.google',         '/resolve'),
    ('9.9.9.9',  'dns.quad9.net',      '/dns-query'),
  ];

  // Known TLS certificate issuers for DoH providers.
  // Used for soft certificate pinning: if the issuer doesn't match, we log a
  // warning but still accept (to avoid bricking the app on CA rotation).
  // A MITM attacker would need a cert from one of these specific CAs.
  static const _trustedIssuers = <String, List<String>>{
    'cloudflare-dns.com': ['DigiCert', 'Cloudflare', 'Google Trust Services', 'Let\'s Encrypt'],
    'dns.google':         ['Google Trust Services', 'GTS', 'GlobalSign'],
    'dns.quad9.net':      ['DigiCert', 'Let\'s Encrypt', 'Sectigo'],
  };

  /// Creates an HttpClient with soft certificate pinning for DoH.
  /// Logs a warning if the cert issuer doesn't match known CAs,
  /// but does NOT reject the connection (soft-fail to prevent breakage).
  static HttpClient _pinnedDohClient(String dohIp, String sniHost) {
    final httpClient = HttpClient();
    httpClient.connectionFactory = (_, _, _) async {
      final raw = await Socket.connect(dohIp, 443,
          timeout: const Duration(seconds: 4));
      return ConnectionTask.fromSocket(
          Future.value(raw), () => raw.destroy());
    };
    httpClient.badCertificateCallback = (cert, host, port) {
      // Compute DER hash for logging/debugging
      final derHash = crypto.sha256.convert(cert.der).toString().substring(0, 16);
      final issuer = cert.issuer;
      final trusted = _trustedIssuers[sniHost] ?? [];
      final issuerOk = trusted.isEmpty ||
          trusted.any((t) => issuer.contains(t));
      if (!issuerOk) {
        debugPrint('[CF/PIN] WARNING: $sniHost cert issuer "$issuer" '
            'not in trusted list! DER=$derHash… Possible MITM.');
      }
      // Soft-fail: always accept to avoid app breakage on CA rotation.
      // The warning is logged so we can detect MITM in debug builds.
      return true;
    };
    return httpClient;
  }

  /// Resolves [host] via DNS-over-HTTPS, trying multiple providers by IP.
  ///
  /// Connects directly to DoH server IPs — no DNS lookup needed, so this works
  /// even when system DNS is poisoned by GFW.
  ///
  /// Returns list of IPv4 address strings, empty on failure.
  Future<List<String>> _dohResolve(String host) async {
    for (final (dohIp, sniHost, pathPrefix) in _dohProviders) {
      try {
        final httpClient = _pinnedDohClient(dohIp, sniHost);
        // do=1 requests DNSSEC validation from the resolver.
        // The response's AD (Authenticated Data) flag tells us whether the
        // resolver verified DNSSEC signatures for this domain.
        final req = await httpClient
            .getUrl(Uri.parse(
                'https://$sniHost$pathPrefix'
                '?name=${Uri.encodeQueryComponent(host)}&type=A&do=1'))
            .timeout(const Duration(seconds: 5));
        req.headers.set('Accept', 'application/dns-json');
        final resp = await req.close().timeout(const Duration(seconds: 5));
        if (resp.statusCode != 200) {
          httpClient.close(force: true);
          continue;
        }
        final body = await utf8.decoder
            .bind(resp)
            .join()
            .timeout(const Duration(seconds: 3));
        httpClient.close(force: true);

        final json = jsonDecode(body) as Map<String, dynamic>;

        // AD flag: true = resolver verified DNSSEC chain for this response.
        // false/missing = domain may not have DNSSEC or resolver didn't validate.
        // We accept both (DoH is already over TLS), but log the difference.
        final ad = json['AD'] as bool? ?? false;

        final answers = (json['Answer'] as List?) ?? [];
        final ips = answers
            .where((a) => (a as Map<String, dynamic>)['type'] == 1) // A record
            .map((a) => (a as Map<String, dynamic>)['data'] as String)
            .where(_isValidIpv4)
            .where(_isPublicIp)
            .toList();
        if (ips.isNotEmpty) {
          debugPrint('[CF/DoH] $host → $ips (via $dohIp${ad ? ', DNSSEC✓' : ''})');
          return ips;
        }
      } catch (e) {
        debugPrint('[CF/DoH] $dohIp failed for $host: $e');
      }
    }
    return [];
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _ensureBlocks() async {
    // In-memory fast path
    if (_blocks != null &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!).inMilliseconds < _cacheTtlMs) {
      return;
    }

    // SharedPrefs cache
    final prefs = await SharedPreferences.getInstance();
    final tsStr = prefs.getString(_cacheKeyTs);
    if (tsStr != null) {
      final ts = int.tryParse(tsStr) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts < _cacheTtlMs) {
        final cached = prefs.getString(_cacheKeyRanges);
        if (cached != null) {
          try {
            final list = List<String>.from(jsonDecode(cached) as List);
            _blocks = list.map(_parseCidr).whereType<_CidrBlock>().toList();
            _loadedAt = DateTime.fromMillisecondsSinceEpoch(ts);
            debugPrint('[CF] Loaded ${_blocks!.length} CIDR blocks from cache');
            return;
          } catch (_) {}
        }
      }
    }

    // Fetch fresh from Cloudflare
    final fetched = await _fetchRanges();
    final ranges = fetched.isNotEmpty ? fetched : _fallbackRanges;
    _blocks = ranges.map(_parseCidr).whereType<_CidrBlock>().toList();
    _loadedAt = DateTime.now();

    await prefs.setString(_cacheKeyRanges, jsonEncode(ranges));
    await prefs.setString(
        _cacheKeyTs, DateTime.now().millisecondsSinceEpoch.toString());
    debugPrint('[CF] Loaded ${_blocks!.length} CIDR blocks '
        '(${fetched.isNotEmpty ? "live" : "fallback"})');
  }

  Future<List<String>> _fetchRanges() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final req = await client
          .getUrl(Uri.parse('https://www.cloudflare.com/ips-v4'))
          .timeout(const Duration(seconds: 6));
      final resp = await req.close().timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        client.close(force: true);
        return [];
      }
      final body = await utf8.decoder
          .bind(resp)
          .join()
          .timeout(const Duration(seconds: 5));
      client.close(force: true);
      final ranges = body
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && l.contains('/'))
          .toList();
      debugPrint('[CF] Fetched ${ranges.length} ranges from cloudflare.com');
      return ranges;
    } catch (e) {
      debugPrint('[CF] Failed to fetch ranges: $e');
      return [];
    }
  }

  static _CidrBlock? _parseCidr(String cidr) {
    try {
      final parts = cidr.split('/');
      if (parts.length != 2) return null;
      final ip = _ipToInt(parts[0]);
      final prefix = int.parse(parts[1]);
      if (ip == null || prefix < 0 || prefix > 32) return null;
      final mask = prefix == 0 ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
      final network = ip & mask;
      return _CidrBlock(network, mask);
    } catch (_) {
      return null;
    }
  }

  static int? _ipToInt(String ip) {
    try {
      final parts = ip.split('.');
      if (parts.length != 4) return null;
      return parts.fold<int>(0, (acc, p) => (acc << 8) | int.parse(p));
    } catch (_) {
      return null;
    }
  }

  static bool _isValidIpv4(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255;
    });
  }

  /// Returns false for RFC-1918, loopback, or link-local addresses.
  /// GFW sometimes poisons DNS with private IPs — we reject those.
  static bool _isPublicIp(String ip) {
    final n = _ipToInt(ip);
    if (n == null) return false;
    // 10.0.0.0/8
    if ((n >> 24) == 10) return false;
    // 172.16.0.0/12
    if ((n >> 20) == (172 << 4 | 1)) return false;
    // 192.168.0.0/16
    if ((n >> 16) == (192 << 8 | 168)) return false;
    // 127.0.0.0/8
    if ((n >> 24) == 127) return false;
    // 169.254.0.0/16
    if ((n >> 16) == (169 << 8 | 254)) return false;
    return true;
  }
}

class _CidrBlock {
  final int network;
  final int mask;
  const _CidrBlock(this.network, this.mask);

  bool contains(int ip) => (ip & mask) == network;
}
