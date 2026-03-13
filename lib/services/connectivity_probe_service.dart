import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tor_service.dart';
import 'ice_server_config.dart';

// ─── Status ───────────────────────────────────────────────────────────────────

enum ProbePhase {
  idle,
  directProbe,   // testing servers without Tor
  torBoot,       // starting Tor
  torProbe,      // testing servers through Tor
  done,
}

class ProbeStatus {
  final ProbePhase phase;
  final int found;          // reachable servers found so far
  final bool torUsed;
  const ProbeStatus(this.phase, {this.found = 0, this.torUsed = false});
}

// ─── Result ───────────────────────────────────────────────────────────────────

class ProbeResult {
  final List<String> nostrRelays;   // ws(s):// URLs, direct
  final List<String> oxenNodes;     // host:port strings, direct
  final List<String> turnServers;   // host:port strings, direct
  final List<String> torNostrRelays; // reachable only via Tor
  final DateTime timestamp;

  const ProbeResult({
    required this.nostrRelays,
    required this.oxenNodes,
    required this.turnServers,
    required this.torNostrRelays,
    required this.timestamp,
  });

  bool get hasNostr => nostrRelays.isNotEmpty || torNostrRelays.isNotEmpty;
  bool get hasDirectNostr => nostrRelays.isNotEmpty;

  /// Best Nostr relay: prefer direct, fall back to first tor-routed one.
  String? get bestNostrRelay =>
      nostrRelays.isNotEmpty ? nostrRelays.first : null;

  Map<String, dynamic> toJson() => {
    'nostrRelays':    nostrRelays,
    'oxenNodes':      oxenNodes,
    'turnServers':    turnServers,
    'torNostrRelays': torNostrRelays,
    'timestamp':      timestamp.toIso8601String(),
  };

  factory ProbeResult.fromJson(Map<String, dynamic> j) => ProbeResult(
    nostrRelays:    List<String>.from(j['nostrRelays']    ?? []),
    oxenNodes:      List<String>.from(j['oxenNodes']      ?? []),
    turnServers:    List<String>.from(j['turnServers']    ?? []),
    torNostrRelays: List<String>.from(j['torNostrRelays'] ?? []),
    timestamp:      DateTime.parse(j['timestamp'] as String),
  );

  static ProbeResult empty() => ProbeResult(
    nostrRelays: [], oxenNodes: [], turnServers: [],
    torNostrRelays: [], timestamp: DateTime(2000),
  );
}

// ─── Candidate lists ──────────────────────────────────────────────────────────

/// Nostr relay hostnames + port.
/// Sorted roughly by: Asian/HK first (more likely direct from CN),
/// European/US second.
const _kNostrCandidates = [
  // Japan (often accessible from CN without VPN)
  ('relay.nostr.wirednet.jp', 443),
  ('nostr-relay.nokotaro.com', 443),
  // Hong Kong / Asia-Pacific CDN
  ('nostr.mom',    443),
  ('offchain.pub', 443),
  // Global / popular
  ('relay.damus.io',         443),
  ('nos.lol',                443),
  ('relay.nostr.band',       443),
  ('nostr.wine',             443),
  ('relay.snort.social',     443),
  ('purplepag.es',           443),
  ('nostr.oxtr.dev',         443),
  ('relay.nos.social',       443),
  ('nostr.bitcoiner.social', 443),
  ('relay.current.fyi',      443),
];

/// Oxen/Session network seed nodes (public, from Session open source).
const _kOxenCandidates = [
  ('seed1.getsession.org', 22023),
  ('seed2.getsession.org', 22023),
  ('seed3.getsession.org', 22023),
  ('public.loki.foundation', 22023),
  ('storage.seed1.loki.network', 22023),
  ('storage.seed3.loki.network', 22023),
];

/// Community TURN servers with embedded credentials.
/// Each entry: (host, probePort, iceServers).
/// probePort is the TCP port we test for reachability.
/// iceServers is the list of RTCIceServer maps added when host is reachable.
///
/// Only publicly documented free credentials are used here.
/// Add more entries as new free TURN services become available.
const _kTurnCandidates = <(String, int, List<Map<String, dynamic>>)>[
  (
    'openrelay.metered.ca', 443,
    [
      {'urls': 'turn:openrelay.metered.ca:80',             'username': 'openrelayproject', 'credential': 'openrelayproject'},
      {'urls': 'turn:openrelay.metered.ca:443',            'username': 'openrelayproject', 'credential': 'openrelayproject'},
      {'urls': 'turns:openrelay.metered.ca:443?transport=tcp', 'username': 'openrelayproject', 'credential': 'openrelayproject'},
    ],
  ),
  (
    'relay.metered.ca', 443,
    [
      {'urls': 'stun:relay.metered.ca:80'},
      {'urls': 'turn:relay.metered.ca:80',                 'username': 'free', 'credential': 'free'},
      {'urls': 'turn:relay.metered.ca:443',                'username': 'free', 'credential': 'free'},
      {'urls': 'turns:relay.metered.ca:443?transport=tcp', 'username': 'free', 'credential': 'free'},
    ],
  ),
  // global.turn.twilio.com — Twilio's global anycast TURN (requires Twilio account;
  // kept here as a reachability probe target — useful in Asia)
  (
    'global.turn.twilio.com', 443,
    [
      {'urls': 'turns:global.turn.twilio.com:443?transport=tcp', 'username': 'free', 'credential': 'free'},
    ],
  ),
];

// ─── Service ──────────────────────────────────────────────────────────────────

/// Background service that:
///   1. Probes candidate servers directly (fast, ~3 s).
///   2. If direct probes are insufficient and system `tor` is available,
///      starts Tor and re-probes the rest (slow but reliable from CN/IR).
///   3. Caches the result for 24 hours.
///
/// Pluggable: add new candidate lists or new probe phases without touching
/// adapters or call logic.
class ConnectivityProbeService {
  static final instance = ConnectivityProbeService._();
  ConnectivityProbeService._();

  static const _cacheKey   = 'connectivity_probe_v1';
  static const _cacheTtlH  = 24;
  // If ≥ this many direct Nostr relays found, skip Tor entirely.
  static const _enoughDirect = 2;

  final _statusCtrl = StreamController<ProbeStatus>.broadcast();
  Stream<ProbeStatus> get status => _statusCtrl.stream;

  ProbeResult _last = ProbeResult.empty();
  ProbeResult get lastResult => _last;

  bool _running = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load cache if fresh; otherwise run probe in the background.
  /// Returns immediately — subscribe to [status] for progress.
  Future<void> runIfNeeded() async {
    if (_running) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        final cached = ProbeResult.fromJson(j);
        if (DateTime.now().difference(cached.timestamp).inHours < _cacheTtlH) {
          _last = cached;
          _statusCtrl.add(ProbeStatus(ProbePhase.done,
              found: cached.nostrRelays.length, torUsed: false));
          debugPrint('[Probe] Using cached results '
              '(${cached.nostrRelays.length} relays)');
          return;
        }
      } catch (_) {}
    }
    unawaited(_runProbe());
  }

  /// Force a fresh probe regardless of cache age.
  Future<void> forceProbe() => _runProbe();

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _runProbe() async {
    if (_running) return;
    _running = true;

    try {
      // ── Phase 1: direct probes ─────────────────────────────────────────────
      _emit(ProbePhase.directProbe);
      debugPrint('[Probe] Phase 1: direct connectivity');

      final directNostr = await _probeAll(_kNostrCandidates,
          label: 'nostr', timeoutSec: 3);
      final directOxen  = await _probeAll(_kOxenCandidates,
          label: 'oxen',  timeoutSec: 3);
      final (directTurnHosts, directTurnConfigs) =
          await _probeAllTurn(timeoutSec: 3);

      debugPrint('[Probe] Direct: nostr=${directNostr.length} '
          'oxen=${directOxen.length} turn=${directTurnHosts.length}');

      // ── Phase 2: Tor probes (only if direct Nostr insufficient) ───────────
      final torNostr = <String>[];
      bool torUsed = false;

      if (directNostr.length < _enoughDirect) {
        _emit(ProbePhase.torBoot);
        debugPrint('[Probe] Phase 2: starting Tor for bootstrap');

        final torReady = await TorService.instance.start();
        if (torReady) {
          torUsed = true;
          _emit(ProbePhase.torProbe, torUsed: true);
          debugPrint('[Probe] Tor ready — probing via SOCKS5');

          // Only probe the ones that failed directly
          final failed = _kNostrCandidates
              .where((c) => !directNostr
                  .contains('wss://${c.$1}'))
              .toList();

          for (final (host, port) in failed) {
            final viaTor = await TorService.instance.probe(host, port);
            if (viaTor) {
              // Check if also directly accessible
              final direct = await _probeOne(host, port, timeoutSec: 2);
              if (direct) {
                directNostr.add('wss://$host');
              } else {
                torNostr.add('wss://$host');
              }
            }
          }

          await TorService.instance.stop();
          debugPrint('[Probe] Tor stopped. Via-tor-only: ${torNostr.length}');
        } else {
          debugPrint('[Probe] Tor unavailable — proceeding with direct only');
        }
      }

      // ── Save result ────────────────────────────────────────────────────────
      _last = ProbeResult(
        nostrRelays:    directNostr,
        oxenNodes:      directOxen,
        turnServers:    directTurnHosts,
        torNostrRelays: torNostr,
        timestamp:      DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(_last.toJson()));

      // Persist best relay for adapters to pick up on next connect
      if (_last.bestNostrRelay != null) {
        final relay = _last.bestNostrRelay!;
        // Store as a "probe-suggested" relay; adapters prefer this over default
        await prefs.setString('probe_nostr_relay', relay);
        debugPrint('[Probe] Best Nostr relay: $relay');
      }
      if (_last.oxenNodes.isNotEmpty) {
        await prefs.setString(
            'probe_oxen_node', _last.oxenNodes.first);
      }
      // Persist full TURN ICE configs for IceServerConfig to pick up
      if (directTurnConfigs.isNotEmpty) {
        await IceServerConfig.saveProbeTurnServers(directTurnConfigs);
        debugPrint('[Probe] Saved ${directTurnConfigs.length} TURN server entries');
      }

      _emit(ProbePhase.done,
          found: directNostr.length + torNostr.length, torUsed: torUsed);
      debugPrint('[Probe] Done. Total reachable: '
          '${directNostr.length} direct + ${torNostr.length} tor-only');
    } catch (e) {
      debugPrint('[Probe] Error: $e');
      _emit(ProbePhase.done);
    } finally {
      _running = false;
    }
  }

  void _emit(ProbePhase phase, {int found = 0, bool torUsed = false}) {
    if (!_statusCtrl.isClosed) {
      _statusCtrl.add(ProbeStatus(phase, found: found, torUsed: torUsed));
    }
  }

  // ── Probe helpers ──────────────────────────────────────────────────────────

  /// Probes all candidates concurrently, returns URLs of reachable ones.
  Future<List<String>> _probeAll(
    List<(String, int)> candidates, {
    required String label,
    required int timeoutSec,
  }) async {
    final results = await Future.wait(
      candidates.map((c) async {
        final ok = await _probeOne(c.$1, c.$2, timeoutSec: timeoutSec);
        if (ok) debugPrint('[Probe] ✓ $label ${c.$1}');
        return ok ? c.$1 : null;
      }),
    );
    return results.whereType<String>().toList();
  }

  /// Probes TURN candidates concurrently.
  /// Returns (hostPortStrings, fullIceServerMaps) for reachable hosts.
  Future<(List<String>, List<Map<String, dynamic>>)> _probeAllTurn({
    required int timeoutSec,
  }) async {
    final hosts   = <String>[];
    final configs = <Map<String, dynamic>>[];

    await Future.wait(
      _kTurnCandidates.map((c) async {
        final ok = await _probeOne(c.$1, c.$2, timeoutSec: timeoutSec);
        if (ok) {
          debugPrint('[Probe] ✓ turn ${c.$1}');
          hosts.add('${c.$1}:${c.$2}');
          configs.addAll(c.$3.map((s) => Map<String, dynamic>.from(s)));
        }
      }),
    );

    return (hosts, configs);
  }

  /// Simple TCP connect probe — no data sent.
  Future<bool> _probeOne(String host, int port, {int timeoutSec = 3}) async {
    try {
      final sock = await Socket.connect(host, port,
          timeout: Duration(seconds: timeoutSec));
      sock.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
