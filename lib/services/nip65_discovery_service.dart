import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'cloudflare_ip_service.dart';
import 'nostr_event_builder.dart' as eb;

// ── NIP-65 Relay Discovery ─────────────────────────────────────────────────────
//
// NIP-65 (Relay List Metadata) defines kind:10002 Nostr events where users
// publish the list of relays they use. By querying ANY working Nostr relay for
// these events, we discover all other relays that real users are actively using.
//
// This is the most self-contained discovery mechanism possible:
//   — No external APIs or services beyond the Nostr relays we already use
//   — Zero developer infrastructure required
//   — Self-updating: as users add/change their relays, discovery improves
//   — Works in censored environments as long as even ONE relay is reachable
//
// Flow:
//   1. Connect to any working relay (found in Phase 1)
//   2. Send REQ for kind:10002 events (limit 200)
//   3. Parse "r" tags from each event — these are relay URLs
//   4. EOSE (End of Stored Events) → close and return results
//   5. Run results through TCP probe to check reachability

class Nip65DiscoveryService {
  static final instance = Nip65DiscoveryService._();
  Nip65DiscoveryService._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Queries [workingRelays] for kind:10002 events and extracts relay URLs.
  ///
  /// Queries up to [maxRelaysToQuery] bootstrap relays in parallel (using
  /// more would be wasteful — results overlap). Returns deduplicated (host, port)
  /// candidates that are NOT already in [knownHosts], ready for TCP probing.
  Future<List<(String, int)>> discover(
    List<String> workingRelays, {
    Set<String>  knownHosts       = const {},
    int          maxRelaysToQuery = 3,
    int          timeoutSec       = 10,
    int          limit            = 200,
  }) async {
    if (workingRelays.isEmpty) return [];

    final toQuery = workingRelays.take(maxRelaysToQuery).toList();
    debugPrint('[NIP-65] Querying ${toQuery.length} relay(s) for kind:10002…');

    // Each relay query has its own timeout — one slow relay doesn't block others.
    final results = await Future.wait(
      toQuery.map((r) => _queryRelay(r, timeoutSec: timeoutSec, limit: limit)
          .timeout(Duration(seconds: timeoutSec + 5),
              onTimeout: () {
                debugPrint('[NIP-65] $r timed out');
                return <String>{};
              })
          .catchError((_) => <String>{})),
    );

    // Merge, remove already-known hosts
    final all = <String>{};
    for (final set in results) { all.addAll(set); }

    final candidates = <(String, int)>[];
    for (final url in all) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) continue;
      if (knownHosts.contains(uri.host)) continue;
      // Reject private/loopback hosts — a malicious kind:10002 event could
      // inject wss://127.0.0.1:9999 and cause TCP probing of localhost services.
      if (_isNip65HostPrivate(uri.host)) continue;
      final port = (uri.hasPort && uri.port != 0) ? uri.port : 443;
      candidates.add((uri.host, port));
    }

    debugPrint('[NIP-65] Discovered ${candidates.length} new relay candidate(s)');
    return candidates;
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
          debugPrint('[NIP-65] DoH-direct: $host via ${ips.first}');
          return IOWebSocketChannel(ws);
        }
      } catch (e) {
        debugPrint('[NIP-65] DoH-direct failed for $host: $e');
      }
    }
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  Future<Set<String>> _queryRelay(
    String relayUrl, {
    required int timeoutSec,
    required int limit,
  }) async {
    final relays = <String>{};
    WebSocketChannel? ws;

    try {
      // Normalize URL — some relays drop connections if port is missing
      final uri = Uri.parse(relayUrl);
      final port = (uri.hasPort && uri.port != 0)
          ? uri.port
          : (uri.scheme == 'wss' ? 443 : 80);
      // Build wsUrl manually to avoid Dart's Uri.replace() adding a trailing
      // '#' (empty fragment) that causes HTTP 400 on WebSocket upgrade.
      final wsUrl = (!uri.hasPort || uri.port == 0)
          ? '${uri.scheme}://${uri.host}:$port${uri.path}'
          : relayUrl;

      // Try CF-direct with DoH-resolved IPs (bypasses GFW DNS poisoning)
      ws = await _connectWithDoh(uri.host, port, wsUrl);

      // Await connection establishment so errors surface inside this try-catch
      // rather than as unhandled exceptions on ws.ready or ws.sink.done.
      await ws.ready;

      // NIP-01 REQ for kind:10002 — relay list metadata (NIP-65)
      // "since" set to 30 days ago so we get recent relay lists from active users.
      final since = DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch ~/ 1000;

      ws.sink.add(jsonEncode([
        'REQ',
        'nip65',
        {'kinds': [10002], 'limit': limit, 'since': since},
      ]));

      await for (final raw in ws.stream
          .timeout(Duration(seconds: timeoutSec), onTimeout: (sink) {
        sink.close();
      })) {
        try {
          final msg = jsonDecode(raw as String) as List;
          if (msg.isEmpty) continue;

          if (msg[0] == 'EOSE') break; // End of stored events — done

          if (msg[0] != 'EVENT' || msg.length < 3) continue;
          final event = msg[2] as Map<String, dynamic>;
          // BUG-03: verify Schnorr signature before trusting relay URLs.
          // A malicious relay can inject kind:10002 events with arbitrary 'r'
          // tags under any pubkey, poisoning relay discovery without this check.
          if (!eb.verifyEventSignature(event)) {
            debugPrint('[NIP-65] Dropped event with invalid signature');
            continue;
          }
          final tags  = event['tags'] as List? ?? [];

          for (final tag in tags) {
            if (tag is! List || tag.length < 2 || tag[0] != 'r') continue;
            final url = tag[1] as String? ?? '';
            if (url.isEmpty || url.length > 2048) continue; // guard oversized URLs
            // BUG-02: reject ws:// (cleartext); only accept encrypted wss://
            if (url.startsWith('wss://')) {
              relays.add(url);
            }
          }
        } catch (e) {
          debugPrint('[NIP-65] Event parse error: $e');
        }
      }

      debugPrint('[NIP-65] $relayUrl → ${relays.length} relay URL(s) in kind:10002');
    } catch (e) {
      debugPrint('[NIP-65] $relayUrl failed: $e');
    } finally {
      // Await close so its Future's error is handled here, not as unhandled.
      try { await ws?.sink.close(); } catch (_) {}
    }
    return relays;
  }
}

/// Returns true if [host] is a loopback, private, or link-local address.
/// Prevents SSRF via malicious kind:10002 events supplying private-IP relay URLs.
bool _isNip65HostPrivate(String host) {
  if (host.isEmpty || host == 'localhost' || host == '::1') return true;
  if (host.startsWith('127.') || host.startsWith('169.254.')) return true;
  if (host.startsWith('10.') || host.startsWith('192.168.')) return true;
  if (host.startsWith('172.')) {
    final second = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 16 && second <= 31) return true;
  }
  if (host.startsWith('100.')) {
    final second = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 64 && second <= 127) return true;
  }
  if (host.startsWith('fc') || host.startsWith('fd')) return true;
  return false;
}
