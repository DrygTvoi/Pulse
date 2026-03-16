import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'tor_service.dart' as tor;

/// Probes known public Waku REST nodes and returns the fastest reachable one.
///
/// Node priority order:
///   1. Local nwaku (127.0.0.1:8645) — always tried first
///   2. Status.im production fleet  — geographically distributed
///   3. Status.im test fleet        — fallback
///
/// Results are cached in SharedPreferences for [_cacheDuration] to avoid
/// hitting the network on every app start.
class WakuDiscoveryService {
  WakuDiscoveryService._();
  static final instance = WakuDiscoveryService._();

  // ── Known nodes ───────────────────────────────────────────────────────────

  static const knownNodes = [
    'http://127.0.0.1:8645',
    'https://node-01.ac-cn-hongkong-c.wakuv2.prod.statusim.net:8645',
    'https://node-01.do-ams3.wakuv2.prod.statusim.net:8645',
    'https://node-01.gc-us-central1-a.wakuv2.prod.statusim.net:8645',
    'https://node-01.ac-cn-hongkong-c.wakuv2.test.statusim.net:8645',
    'https://node-01.do-ams3.wakuv2.test.statusim.net:8645',
  ];

  static const _prefBestNode = 'waku_best_node_url';
  static const _prefCacheTs  = 'waku_best_node_ts';
  static const _cacheDuration = Duration(minutes: 5);
  static const _probeTimeout  = Duration(seconds: 4);

  String? _cachedNode;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the fastest responding node, or the local default if all fail.
  /// Result is cached for [_cacheDuration]; pass [forceRefresh] to bypass.
  Future<String> discoverBestNode({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedNode != null) return _cachedNode!;

    final prefs = await SharedPreferences.getInstance();

    // Use cached prefs value if still fresh
    if (!forceRefresh) {
      final ts = prefs.getInt(_prefCacheTs) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age < _cacheDuration.inMilliseconds) {
        final saved = prefs.getString(_prefBestNode);
        if (saved != null) {
          _cachedNode = saved;
          return saved;
        }
      }
    }

    final best = await _raceToBest();
    _cachedNode = best;
    await prefs.setString(_prefBestNode, best);
    await prefs.setInt(_prefCacheTs, DateTime.now().millisecondsSinceEpoch);
    debugPrint('[WakuDiscovery] Best node: $best');
    return best;
  }

  /// Probes all known nodes concurrently and returns their status + latency.
  /// Useful for the settings UI "Discover nodes" panel.
  Future<List<WakuNodeInfo>> probeAll() async {
    final futures = knownNodes.map(_probeWithLatency);
    final results = await Future.wait(futures);
    results.sort((a, b) {
      if (a.online != b.online) return a.online ? -1 : 1;
      return a.latencyMs.compareTo(b.latencyMs);
    });
    return results;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Races all nodes; resolves with the first one that responds successfully.
  Future<String> _raceToBest() async {
    final completer = Completer<String>();
    var remaining = knownNodes.length;

    for (final url in knownNodes) {
      _probeNode(url).then((ok) {
        remaining--;
        if (ok && !completer.isCompleted) {
          completer.complete(url);
        } else if (remaining == 0 && !completer.isCompleted) {
          // All failed — default to local
          completer.complete(knownNodes.first);
        }
      });
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => knownNodes.first,
    );
  }

  Future<bool> _probeNode(String url) async {
    final client = tor.buildTorHttpClient() ?? http.Client();
    try {
      final res = await client
          .get(Uri.parse('$url/health'))
          .timeout(_probeTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  Future<WakuNodeInfo> _probeWithLatency(String url) async {
    final sw = Stopwatch()..start();
    final ok = await _probeNode(url);
    sw.stop();
    return WakuNodeInfo(
      url: url,
      online: ok,
      latencyMs: ok ? sw.elapsedMilliseconds : -1,
    );
  }

  /// Returns the best reachable node, skipping [excludeUrl].
  /// Used for automatic failover when the current node stops responding.
  Future<String> discoverExcluding(String excludeUrl) async {
    final candidates = knownNodes.where((u) => u != excludeUrl).toList();
    if (candidates.isEmpty) return excludeUrl; // no alternative

    final completer = Completer<String>();
    var remaining = candidates.length;

    for (final url in candidates) {
      _probeNode(url).then((ok) {
        remaining--;
        if (ok && !completer.isCompleted) {
          completer.complete(url);
        } else if (remaining == 0 && !completer.isCompleted) {
          completer.complete(candidates.first);
        }
      });
    }

    final next = await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => candidates.first,
    );
    _cachedNode = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefBestNode, next);
    await prefs.setInt(_prefCacheTs, DateTime.now().millisecondsSinceEpoch);
    debugPrint('[WakuDiscovery] Failover node: $next');
    return next;
  }

  /// Clears the cache — forces a fresh probe on next [discoverBestNode] call.
  Future<void> clearCache() async {
    _cachedNode = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefBestNode);
    await prefs.remove(_prefCacheTs);
  }
}

/// Result of probing a single Waku node.
class WakuNodeInfo {
  final String url;
  final bool online;
  final int latencyMs; // -1 if offline

  const WakuNodeInfo({
    required this.url,
    required this.online,
    required this.latencyMs,
  });

  /// Human-readable label (strips protocol + port).
  String get label {
    try {
      final uri = Uri.parse(url);
      return uri.host == '127.0.0.1' ? 'Local nwaku' : uri.host;
    } catch (_) {
      return url;
    }
  }

  String get latencyLabel =>
      online ? '${latencyMs}ms' : 'offline';
}
