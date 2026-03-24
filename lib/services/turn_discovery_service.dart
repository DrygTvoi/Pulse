import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'cloudflare_ip_service.dart';

// ── NIP-117 TURN Discovery ─────────────────────────────────────────────────────
//
// NIP-117 defines kind:10010 Nostr events where TURN server operators
// self-announce their servers on the Nostr network.  By querying ANY working
// Nostr relay for these events, we discover community-operated TURN servers
// without requiring any developer infrastructure.
//
// Tag format: ["turn", "turn:server.com:3478", "username", "credential"]
//
// Flow:
//   1. Connect to any working relay (found in Phase 1)
//   2. Send REQ for kind:10010 events (limit 100)
//   3. Parse "turn" tags from each event → TURN server ICE configs
//   4. EOSE → close and return results
//   5. Cache in SharedPrefs for 6 hours to avoid repeat queries
//
// Results are saved via IceServerConfig.saveNip117TurnServers() so they are
// included in the next WebRTC call setup automatically.

class TurnDiscoveryService {
  static final instance = TurnDiscoveryService._();
  TurnDiscoveryService._();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  TurnDiscoveryService.forTesting();

  static const _kCacheKey  = 'turn_nip117_cache';
  static const _kCacheTtlH = 6;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Queries [workingRelays] for kind:10010 events and extracts TURN configs.
  ///
  /// Returns a list of ICE server maps compatible with WebRTC RTCIceServer.
  /// Results are cached for [_kCacheTtlH] hours.
  Future<List<Map<String, dynamic>>> discover(
    List<String> workingRelays, {
    int maxRelaysToQuery = 3,
    int timeoutSec = 10,
  }) async {
    // Check SharedPrefs cache first
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kCacheKey);
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        final ts = DateTime.tryParse(data['ts'] as String? ?? '');
        if (ts != null &&
            DateTime.now().difference(ts).inHours < _kCacheTtlH) {
          final servers = (data['servers'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          debugPrint('[NIP-117] Using cached ${servers.length} TURN server(s)');
          return servers;
        }
      } catch (_) {}
    }

    if (workingRelays.isEmpty) return [];

    final toQuery = workingRelays.take(maxRelaysToQuery).toList();
    debugPrint('[NIP-117] Querying ${toQuery.length} relay(s) for kind:10010…');

    final results = await Future.wait(
      toQuery.map((r) => _queryRelay(r, timeoutSec: timeoutSec)
          .timeout(
            Duration(seconds: timeoutSec + 5),
            onTimeout: () => <Map<String, dynamic>>[],
          )
          .catchError((_) => <Map<String, dynamic>>[])),
    );

    // Merge and deduplicate by TURN URL
    final seen    = <String>{};
    final servers = <Map<String, dynamic>>[];
    for (final list in results) {
      for (final s in list) {
        final url = s['urls'] as String? ?? '';
        if (url.isNotEmpty && seen.add(url)) {
          servers.add(s);
        }
      }
    }

    debugPrint('[NIP-117] Discovered ${servers.length} TURN server(s) '
        'from kind:10010');

    // Cache results (even if empty, to avoid hammering relays)
    await prefs.setString(_kCacheKey, jsonEncode({
      'ts':      DateTime.now().toIso8601String(),
      'servers': servers,
    }));

    return servers;
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  /// Connects a WebSocket using DoH-resolved IPs when possible.
  /// Falls back to plain WebSocket if DoH resolution fails.
  Future<WebSocketChannel> _connectWithDoh(
      String host, int port, String wsUrl) async {
    if (host.isNotEmpty) {
      try {
        final (_, ips) = await CloudflareIpService.instance
            .resolveAndCheck(host)
            .timeout(const Duration(seconds: 4),
                onTimeout: () => (false, <String>[]));
        if (ips.isNotEmpty) {
          final httpClient = HttpClient();
          httpClient.connectionFactory = (_, _, _) async {
            final raw = await Socket.connect(ips.first, port,
                timeout: const Duration(seconds: 4));
            return ConnectionTask.fromSocket(
                Future.value(raw), () => raw.destroy());
          };
          final ws = await WebSocket.connect(wsUrl, customClient: httpClient)
              .timeout(const Duration(seconds: 5));
          debugPrint('[NIP-117] DoH-direct: $host via ${ips.first}');
          return IOWebSocketChannel(ws);
        }
      } catch (e) {
        debugPrint('[NIP-117] DoH-direct failed for $host: $e');
      }
    }
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  Future<List<Map<String, dynamic>>> _queryRelay(
    String relayUrl, {
    required int timeoutSec,
  }) async {
    final servers = <Map<String, dynamic>>[];
    WebSocketChannel? ws;

    try {
      final uri  = Uri.parse(relayUrl);
      final port = (uri.hasPort && uri.port != 0)
          ? uri.port
          : (uri.scheme == 'wss' ? 443 : 80);
      final wsUrl = (!uri.hasPort || uri.port == 0)
          ? '${uri.scheme}://${uri.host}:$port${uri.path}'
          : relayUrl;

      ws = await _connectWithDoh(uri.host, port, wsUrl);
      await ws.ready;

      ws.sink.add(jsonEncode([
        'REQ',
        'nip117',
        {'kinds': [10010], 'limit': 100},
      ]));

      await for (final raw in ws.stream
          .timeout(Duration(seconds: timeoutSec), onTimeout: (sink) {
        sink.close();
      })) {
        try {
          final msg = jsonDecode(raw as String) as List;
          if (msg.isEmpty) continue;
          if (msg[0] == 'EOSE') break;
          if (msg[0] != 'EVENT' || msg.length < 3) continue;

          final event = msg[2] as Map<String, dynamic>;
          final tags  = event['tags'] as List? ?? [];

          for (final tag in tags) {
            if (tag is! List || tag.length < 2 || tag[0] != 'turn') continue;
            final turnUrl = tag[1] as String? ?? '';
            if (!turnUrl.startsWith('turn:') &&
                !turnUrl.startsWith('turns:')) {
              continue;
            }
            // BUG-04: reject TURN URLs pointing at localhost/private IPs.
            // A malicious relay could supply turn:127.0.0.1:3478 to exfiltrate
            // TURN credentials (username/password in tag[2]/tag[3]) to a LAN service.
            // TURN URI format (RFC 7065): turn:host[:port][?transport=...]
            final afterScheme = turnUrl.substring(turnUrl.indexOf(':') + 1);
            final turnHost = afterScheme.split('?').first.split(':').first.toLowerCase();
            if (_isTurnHostPrivate(turnHost)) {
              debugPrint('[NIP-117] Rejected private-host TURN URL: $turnUrl');
              continue;
            }
            final entry = <String, dynamic>{'urls': turnUrl};
            if (tag.length >= 3) {
              final username = tag[2] as String? ?? '';
              if (username.isNotEmpty) entry['username'] = username;
            }
            if (tag.length >= 4) {
              final credential = tag[3] as String? ?? '';
              if (credential.isNotEmpty) entry['credential'] = credential;
            }
            servers.add(entry);
          }
        } catch (e) {
          debugPrint('[NIP-117] Event parse error: $e');
        }
      }

      debugPrint(
          '[NIP-117] $relayUrl → ${servers.length} TURN server(s) in kind:10010');
    } catch (e) {
      debugPrint('[NIP-117] $relayUrl failed: $e');
    } finally {
      try {
        await ws?.sink.close();
      } catch (_) {}
    }
    return servers;
  }
}

/// Returns true if [host] is a loopback, private, or link-local address
/// that should never appear as a TURN server host in NIP-117 events.
bool _isTurnHostPrivate(String host) {
  if (host.isEmpty) return true;
  if (host == 'localhost' || host == '::1') return true;
  if (host.startsWith('127.') || host.startsWith('169.254.')) return true;
  if (host.startsWith('10.')) return true;
  if (host.startsWith('192.168.')) return true;
  if (host.startsWith('100.')) {
    // 100.64.0.0/10 — Carrier-Grade NAT (RFC 6598)
    final second = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 64 && second <= 127) return true;
  }
  // 172.16.0.0/12
  if (host.startsWith('172.')) {
    final second = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 16 && second <= 31) return true;
  }
  return false;
}
