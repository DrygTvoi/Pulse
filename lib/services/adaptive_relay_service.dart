import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cloudflare_ip_service.dart';
import 'relay_directory_service.dart';

// ── AdaptiveRelayService ──────────────────────────────────────────────────────
//
// Races Cloudflare-hosted Nostr relays and returns the fastest one.
// Result cached in SharedPreferences (key: adaptive_cf_relay) with 15-min TTL.
//
// Usage:
//   final relay = await AdaptiveRelayService.instance.getBestRelay();
//   // → 'wss://relay.damus.io' or null
//
// Hot-swap support:
//   Call getBetterRelay(currentUrl, currentRttMs) periodically.
//   Returns null if no upgrade is needed.

class AdaptiveRelayService {
  static final instance = AdaptiveRelayService._();
  AdaptiveRelayService._();

  static const _cacheKey  = 'adaptive_cf_relay';
  static const _cacheTsKey = 'adaptive_cf_relay_ts';
  static const _ttlMs     = 15 * 60 * 1000; // 15 min

  String? _bestRelay;
  DateTime? _lastRace;

  // Seeded externally by ConnectivityProbeService so race can start early.
  List<String> _seededUrls = [];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Seeds candidate URLs from external probe so the first race starts faster.
  void seedCandidates(List<String> urls) {
    _seededUrls = urls;
  }

  /// Returns the best CF relay URL or null.
  /// [force] bypasses the 15-min TTL and forces a new race.
  Future<String?> getBestRelay({bool force = false}) async {
    // In-memory fast path
    if (!force &&
        _bestRelay != null &&
        _lastRace != null &&
        DateTime.now().difference(_lastRace!).inMilliseconds < _ttlMs) {
      return _bestRelay;
    }

    // Try SharedPrefs cache on first call
    if (!force && _bestRelay == null) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey) ?? '';
      final tsStr  = prefs.getString(_cacheTsKey);
      if (cached.isNotEmpty && tsStr != null) {
        final ts = int.tryParse(tsStr) ?? 0;
        if (DateTime.now().millisecondsSinceEpoch - ts < _ttlMs) {
          _bestRelay = cached;
          _lastRace = DateTime.fromMillisecondsSinceEpoch(ts);
          debugPrint('[Adaptive] Best relay from cache: $_bestRelay');
          return _bestRelay;
        }
      }
    }

    // Get CF relay candidates
    final candidates = await _getCfCandidates();
    if (candidates.isEmpty) {
      debugPrint('[Adaptive] No CF candidates available');
      return null;
    }

    debugPrint('[Adaptive] Racing ${candidates.length} CF relay(s)...');
    final winner = await _raceRelays(candidates);
    if (winner != null) {
      _bestRelay = winner;
      _lastRace = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, winner);
      await prefs.setString(_cacheTsKey,
          DateTime.now().millisecondsSinceEpoch.toString());
      debugPrint('[Adaptive] Best CF relay: $winner');
    }
    return winner;
  }

  /// Returns a better relay if [currentRttMs] ≥ 800ms; otherwise returns null.
  /// Triggers a forced re-race to find the fastest available relay.
  Future<String?> getBetterRelay(String currentUrl, int currentRttMs) async {
    if (currentRttMs < 800) return null;
    debugPrint('[Adaptive] Current RTT ${currentRttMs}ms — looking for better relay');
    final better = await getBestRelay(force: true);
    if (better != null && better != currentUrl) return better;
    return null;
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<List<String>> _getCfCandidates() async {
    // Use seeded URLs if available, otherwise ask RelayDirectoryService.
    final urls = _seededUrls.isNotEmpty
        ? _seededUrls
        : await RelayDirectoryService.instance.getCandidateUrls();

    if (urls.isEmpty) return [];
    return CloudflareIpService.instance.filterCloudflare(urls);
  }

  /// Races all [urls] by sending a WebSocket ping.
  /// Returns the first URL that responds, or null if all fail/timeout.
  Future<String?> _raceRelays(List<String> urls) async {
    final completer = Completer<String?>();

    int pending = urls.length;
    if (pending == 0) return null;

    for (final url in urls) {
      unawaited(_probeWs(url).then((ok) {
        if (ok && !completer.isCompleted) {
          completer.complete(url);
        } else {
          pending--;
          if (pending <= 0 && !completer.isCompleted) {
            completer.complete(null);
          }
        }
      }).catchError((_) {
        pending--;
        if (pending <= 0 && !completer.isCompleted) {
          completer.complete(null);
        }
      }));
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => null,
    );
  }

  /// Returns true if a WebSocket connection can be established and a response
  /// received within 3 seconds.
  ///
  /// Uses DoH-resolved IPs for CF-hosted relays to bypass DNS poisoning.
  /// This is critical: the adaptive relay race only runs for CF relays,
  /// and behind GFW, system DNS for CF-hosted domains may be poisoned.
  Future<bool> _probeWs(String url) async {
    WebSocket? ws;
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      final port = (uri.hasPort && uri.port != 0)
          ? uri.port
          : (uri.scheme == 'wss' ? 443 : 80);
      final normalized = (!uri.hasPort || uri.port == 0)
          ? uri.replace(port: port).toString()
          : url;

      // Resolve via DoH — these are CF relays, system DNS may be poisoned.
      final (_, ips) = await CloudflareIpService.instance
          .resolveAndCheck(host)
          .timeout(const Duration(seconds: 3),
              onTimeout: () => (false, <String>[]));

      if (ips.isNotEmpty) {
        // Connect via DoH-resolved IP (bypasses poisoned DNS)
        final httpClient = HttpClient();
        httpClient.connectionFactory = (_, _, _) async {
          final raw = await Socket.connect(ips.first, port,
              timeout: const Duration(seconds: 3));
          return ConnectionTask.fromSocket(
              Future.value(raw), () => raw.destroy());
        };
        ws = await WebSocket.connect(normalized, customClient: httpClient)
            .timeout(const Duration(seconds: 4));
      } else {
        // Fallback to plain connect (works in non-censored environments)
        ws = await WebSocket.connect(normalized)
            .timeout(const Duration(seconds: 4));
      }

      final completer = Completer<bool>();

      // Send a minimal REQ — relay must respond (NOTICE, EOSE, etc.)
      final subId = 'probe_${DateTime.now().millisecondsSinceEpoch}';
      ws.add(jsonEncode(['REQ', subId, {'kinds': [1], 'limit': 1}]));

      final sub = ws.listen(
        (data) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      final result = await completer.future
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      await sub.cancel();
      return result;
    } catch (_) {
      return false;
    } finally {
      try { ws?.close(); } catch (_) {}
    }
  }
}
