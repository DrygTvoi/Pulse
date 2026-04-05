import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tor_service.dart';
import 'psiphon_service.dart';
import 'psiphon_turn_proxy.dart';
import 'ice_server_config.dart';
import 'relay_directory_service.dart';
import 'nip65_discovery_service.dart';
import 'turn_discovery_service.dart';
import 'adaptive_relay_service.dart';
import 'circuit_breaker_service.dart';
// Peer relays key — matches ChatController._peerRelaysKey.
// Read directly from SharedPreferences to avoid circular dependency.
const _peerRelaysKey = 'peer_relays_v1';

// ─── Status ───────────────────────────────────────────────────────────────────

enum ProbePhase {
  idle,
  directProbe,   // testing static servers + nostr.watch
  dohProbe,      // querying DNS TXT + CDN relay list + peer relays
  torBoot,       // starting Tor (only if < 2 direct relays found)
  torProbe,      // testing servers through Tor + nostr.watch via Tor
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
  final List<String> sessionNodes;     // host:port strings, direct
  final List<String> turnServers;   // host:port strings, direct
  final List<String> torNostrRelays; // reachable only via Tor
  final DateTime timestamp;

  const ProbeResult({
    required this.nostrRelays,
    required this.sessionNodes,
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
    'sessionNodes':    sessionNodes,
    'turnServers':    turnServers,
    'torNostrRelays': torNostrRelays,
    'timestamp':      timestamp.toIso8601String(),
  };

  factory ProbeResult.fromJson(Map<String, dynamic> j) => ProbeResult(
    nostrRelays:    List<String>.from(j['nostrRelays']    ?? []),
    sessionNodes:    List<String>.from(j['sessionNodes']      ?? []),
    turnServers:    List<String>.from(j['turnServers']    ?? []),
    torNostrRelays: List<String>.from(j['torNostrRelays'] ?? []),
    timestamp:      DateTime.parse(j['timestamp'] as String),
  );

  static ProbeResult empty() => ProbeResult(
    nostrRelays: [], sessionNodes: [], turnServers: [],
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
  ('nostr.vin',               443), // Japan
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
  ('strfry.iris.to',         443), // high-traffic global
  ('nostr.fmt.wired.mn',     443), // global
];

/// Session Network seed nodes (public, from Session open source).
const _kSessionCandidates = [
  ('seed1.getsession.org', 22023),
  ('seed2.getsession.org', 22023),
  ('seed3.getsession.org', 22023),
  ('public.loki.foundation', 22023),
  ('storage.seed1.loki.network', 22023),
  ('storage.seed3.loki.network', 22023),
];

/// Community TURN servers probed for direct reachability.
/// Each entry: (host, probePort, iceServers).
/// probePort — TCP port used for the TCP-connect reachability test.
/// iceServers — RTCIceServer maps added to ICE config when reachable.
///
/// Only verifiably-free credentials are included.
/// metered.ca and Twilio TURN require account registration → STUN-only here.
const _kTurnCandidates = <(String, int, List<Map<String, dynamic>>)>[
  // openrelay.metered.ca — free community TURN, no account required.
  // TLS/TCP port 443 reliably passes strict firewalls.
  (
    'openrelay.metered.ca', 443,
    [
      {'urls': 'turn:openrelay.metered.ca:80',                  'username': 'openrelayproject', 'credential': 'openrelayproject'},
      {'urls': 'turn:openrelay.metered.ca:443',                 'username': 'openrelayproject', 'credential': 'openrelayproject'},
      {'urls': 'turns:openrelay.metered.ca:443?transport=tcp',  'username': 'openrelayproject', 'credential': 'openrelayproject'},
    ],
  ),
  // freestun.net — independent community TURN, no account required.
  // Separate provider from openrelay — if one is down, the other may work.
  (
    'freestun.net', 3479,
    [
      {'urls': 'turn:freestun.net:3479',                        'username': 'free', 'credential': 'free'},
      {'urls': 'turns:freestun.net:5350',                       'username': 'free', 'credential': 'free'},
    ],
  ),
  // relay.metered.ca — STUN is public; TURN requires account (omitted).
  (
    'relay.metered.ca', 80,
    [
      {'urls': 'stun:relay.metered.ca:80'},
    ],
  ),
  // global.turn.twilio.com — probe only (TURN requires Twilio account).
  // Reachability check is still useful: confirms Twilio CDN is accessible
  // from this network, so users know adding their Twilio credentials will work.
  (
    'global.turn.twilio.com', 443,
    [], // no usable ICE entries without account credentials
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
  static ConnectivityProbeService instance = ConnectivityProbeService._();
  ConnectivityProbeService._();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  ConnectivityProbeService.forTesting();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(ConnectivityProbeService inst) =>
      instance = inst;

  static const _cacheKeyBase  = 'connectivity_probe_v1';
  static const _cacheKey      = 'connectivity_probe_v1'; // kept for fallback reads
  static const _cacheTtlH     = 6; // match RelayDirectoryService TTL
  static const _lastNetworkKey = 'probe_last_network';
  // If ≥ this many direct Nostr relays found, skip Tor entirely.
  static const _enoughDirect = 2;

  final _statusCtrl = StreamController<ProbeStatus>.broadcast();
  Stream<ProbeStatus> get status => _statusCtrl.stream;

  /// Completes (once) when the first probe run finishes, so ChatController
  /// can reconnect with the newly discovered best relay.
  Completer<ProbeResult> _firstRunCompleter = Completer<ProbeResult>();

  /// Resolves after the first probe run finishes.  Callers that start
  /// before the probe can `await` this to get the freshest result.
  Future<ProbeResult> get firstRunDone => _firstRunCompleter.future;

  ProbeResult _last = ProbeResult.empty();
  ProbeResult get lastResult => _last;

  bool _running = false;
  Timer? _refreshTimer;

  // ── Network-aware cache key ─────────────────────────────────────────────

  /// Compute a short key identifying the active network (first 8 hex chars of
  /// SHA-256 of sorted interface names).  Falls back to empty string on error.
  Future<String> _getNetworkKey() async {
    try {
      final ifaces = await NetworkInterface.list();
      final names = ifaces.map((i) => i.name).toList()..sort();
      final digest = crypto.sha256.convert(names.join(',').codeUnits);
      return digest.toString().substring(0, 8);
    } catch (_) {
      return '';
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load cache if fresh; otherwise run probe in the background.
  /// Returns immediately — subscribe to [status] for progress.
  Future<void> runIfNeeded() async {
    if (_running) return;
    final prefs = await SharedPreferences.getInstance();

    // Invalidate cache when network changes (e.g. WiFi ↔ mobile/VPN switch).
    final netKey = await _getNetworkKey();
    final lastNet = prefs.getString(_lastNetworkKey) ?? '';
    final networkChanged = netKey.isNotEmpty && netKey != lastNet;
    if (networkChanged) {
      debugPrint('[Probe] Network changed ($lastNet → $netKey) — forcing fresh probe');
    }
    if (netKey.isNotEmpty) {
      await prefs.setString(_lastNetworkKey, netKey);
    }

    // Try per-network cache first; fall back to global cache key.
    final cacheKey = netKey.isNotEmpty ? '${_cacheKeyBase}_$netKey' : _cacheKey;
    final raw = !networkChanged ? prefs.getString(cacheKey) ?? prefs.getString(_cacheKey) : null;
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
          if (!_firstRunCompleter.isCompleted) {
            _firstRunCompleter.complete(_last);
          }
          // Start censorship-bypass transports even from cache —
          // otherwise Psiphon/Tor never launch until cache expires.
          _startBypassIfCensored(cached.nostrRelays.length);
          return;
        }
      } catch (e) {
        debugPrint('[Probe] Failed to parse cached probe result: $e');
      }
    }
    unawaited(_runProbe());
  }

  /// Force a fresh probe regardless of cache age.
  Future<void> forceProbe() async {
    // BUG-08: previously completeError() was called on the old _firstRunCompleter,
    // which meant main.dart's unawaited(firstRunDone.then(...)) never fired after
    // a forceProbe triggered by a network change — ChatController never reconnected.
    // Fix: complete with current _last so existing waiters are notified immediately.
    if (!_firstRunCompleter.isCompleted) {
      _firstRunCompleter.complete(_last);
    }
    _firstRunCompleter = Completer<ProbeResult>();
    await CircuitBreakerService.instance.reset();
    return _runProbe();
  }

  /// Starts a periodic background refresh every [_cacheTtlH] hours.
  /// Also runs a quick health check of cached relays halfway through.
  void startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(hours: _cacheTtlH), (_) {
      debugPrint('[Probe] Periodic refresh triggered');
      unawaited(_runProbe());
    });
    // Health check at half the TTL — removes dead relays from cache
    Future.delayed(Duration(hours: _cacheTtlH ~/ 2), () {
      if (_refreshTimer != null) unawaited(_healthCheck());
    });
  }

  /// Stops the periodic refresh.
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Quick health check — re-probes cached relays and removes dead ones.
  /// Probes in batches of 10 to avoid opening hundreds of simultaneous
  /// TCP connections (same DoH-storm fix applied to filterCloudflare).
  Future<void> _healthCheck() async {
    // Don't clobber _last while a full probe is in progress.
    if (_running || _last.nostrRelays.isEmpty) return;
    debugPrint('[Probe/Health] Checking ${_last.nostrRelays.length} cached relays');

    const healthBatchSize = 10;
    final alive = <String>[];
    final urls = _last.nostrRelays;

    for (var i = 0; i < urls.length; i += healthBatchSize) {
      final batch = urls.sublist(i, (i + healthBatchSize).clamp(0, urls.length));
      await Future.wait(batch.map((url) async {
        final uri = Uri.tryParse(url);
        if (uri == null || uri.host.isEmpty) return;
        final port = (uri.hasPort && uri.port != 0) ? uri.port : 443;
        final ok = await _probeOne(uri.host, port, timeoutSec: 3);
        if (ok) {
          alive.add(url);
        } else {
          debugPrint('[Probe/Health] ✗ dead: $url');
        }
      }));
    }

    if (alive.length < _last.nostrRelays.length) {
      debugPrint('[Probe/Health] ${_last.nostrRelays.length - alive.length} dead relay(s) removed');
      _last = ProbeResult(
        nostrRelays: alive,
        sessionNodes: _last.sessionNodes,
        turnServers: _last.turnServers,
        torNostrRelays: _last.torNostrRelays,
        timestamp: _last.timestamp,
      );
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_last.toJson());
      await prefs.setString(_cacheKey, json);
      final netKey = await _getNetworkKey();
      if (netKey.isNotEmpty) {
        await prefs.setString('${_cacheKeyBase}_$netKey', json);
      }

      // Trigger re-probe if too few relays remain
      if (alive.length < _enoughDirect) {
        debugPrint('[Probe/Health] Too few relays — triggering full re-probe');
        unawaited(_runProbe());
      }
    } else {
      debugPrint('[Probe/Health] All ${alive.length} relays healthy');
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _runProbe() async {
    if (_running) return;
    _running = true;

    try {
      // ── Phase 1: static TCP probes ────────────────────────────────────────
      _emit(ProbePhase.directProbe);
      debugPrint('[Probe] Phase 1: static relay probes');

      final directNostrHosts = await _probeAll(_kNostrCandidates,
          label: 'nostr', timeoutSec: 3);
      // IMPORTANT: convert to full wss:// URLs — _probeAll returns bare hostnames
      final directNostr = directNostrHosts.map((h) => 'wss://$h').toList();
      final directSession = await _probeAll(_kSessionCandidates,
          label: 'session', timeoutSec: 3);
      final (directTurnHosts, directTurnConfigs) =
          await _probeAllTurn(timeoutSec: 3);

      debugPrint('[Probe] Static: nostr=${directNostr.length} '
          'session=${directSession.length} turn=${directTurnHosts.length}');

      // ── Early Tor start (parallel with phase 1.5) ────────────────────────
      // If direct probes found fewer than enough relays, the network is likely
      // censored. Start Tor NOW — in the background — so it bootstraps
      // concurrently with relay discovery (phase 1.5) instead of after it.
      // Tor+Snowflake takes 60-120s; starting early saves all of that wait.
      Future<bool>? earlyTorFuture;
      final looksCensored = directNostr.length < _enoughDirect;
      if (looksCensored &&
          !TorService.instance.isBootstrapped &&
          !TorService.instance.isRunning) {
        debugPrint('[Probe] Network looks censored — starting Tor early');
        earlyTorFuture = TorService.instance.start();
      }
      // Start Psiphon in parallel with Tor — bootstraps in 3-5s,
      // provides faster message relay + TURN proxy for calls.
      if (looksCensored && !PsiphonService.instance.isRunning) {
        debugPrint('[Probe] Starting Psiphon (parallel with Tor)');
        PsiphonService.instance.ensureRunning().then((_) {
          if (PsiphonService.instance.isRunning) PsiphonTurnProxy.startAll();
        });
      }

      // ── Phase 1.5: Autonomous relay + TURN discovery ──────────────────────
      //
      // Four parallel sources — zero developer infrastructure required:
      //   A. Community relay directories (nostr.watch, nostr.band)
      //   B. NIP-65 (kind:10002) events from any working Nostr relay
      //      → the Nostr network IS its own relay directory
      //   C. Peer relays shared by contacts via P2P exchange
      //   D. NIP-117 (kind:10010) + peer TURN exchange — discovers community
      //      TURN servers that self-announce on the Nostr network
      //
      // All four run in parallel; results are TCP-probed and joined.
      // NOTE: Tor bootstrap is also running in background during this phase.
      //
      // If phase 1 already found enough relays, emit early done so the UI
      // stops showing the spinner.  Phase 1.5 continues silently in the
      // background to discover additional relays for future reconnects.
      final earlyDone = directNostr.length >= _enoughDirect;
      if (earlyDone) {
        _emit(ProbePhase.done, found: directNostr.length);
        if (!_firstRunCompleter.isCompleted) {
          _firstRunCompleter.complete(ProbeResult(
            nostrRelays: List.of(directNostr),
            sessionNodes: directSession,
            turnServers: directTurnHosts,
            torNostrRelays: [],
            timestamp: DateTime.now(),
          ));
        }
      } else {
        _emit(ProbePhase.dohProbe, found: directNostr.length);
      }
      debugPrint('[Probe] Phase 1.5: autonomous relay + TURN discovery');

      final knownHosts1 = <String>{
        ..._kNostrCandidates.map((c) => c.$1),
        ...directNostr.map((u) => Uri.parse(u).host),
      };

      // Phase 1.5D: NIP-117 kind:10010 TURN discovery — runs in parallel
      // with relay regen.  Discovers community TURN servers self-announced
      // on Nostr; persisted to IceServerConfig for the next call.
      final turnDiscoveryFuture = TurnDiscoveryService.instance
          .discover(directNostr)
          .catchError((_) => <Map<String, dynamic>>[]);

      final regenResults = await Future.wait([
        RelayDirectoryService.instance.getCandidates(),
        Nip65DiscoveryService.instance.discover(
          directNostr, knownHosts: knownHosts1),
        _loadPeerRelayCandidates(knownHosts1),
      ]);

      // Merge + deduplicate against known hosts; skip .onion (Tor-only)
      final regenCandidates = <(String, int)>[];
      final seenHosts       = Set<String>.from(knownHosts1);
      for (final list in regenResults) {
        for (final c in list) {
          if (c.$1.endsWith('.onion')) continue;
          // Relay directory APIs could return RFC-1918 / loopback entries.
          // Reject them to avoid probing internal network services.
          final h = c.$1;
          if (h == 'localhost' || h == '127.0.0.1' || h == '::1' ||
              h.startsWith('192.168.') || h.startsWith('10.') ||
              h.startsWith('172.16.') || h.startsWith('169.254.')) { continue; }
          if (seenHosts.add(c.$1)) regenCandidates.add(c);
        }
      }

      if (regenCandidates.isNotEmpty) {
        debugPrint('[Probe] Probing ${regenCandidates.length} autonomously discovered relay(s)');
        final extraHosts = await _probeAll(regenCandidates, label: 'regen', timeoutSec: 3);
        directNostr.addAll(extraHosts.map((h) => 'wss://$h'));
        debugPrint('[Probe] Regen: +${extraHosts.length} reachable (total ${directNostr.length})');
      } else {
        debugPrint('[Probe] Regen: no new candidates found');
      }

      // Seed AdaptiveRelayService with all known reachable relay URLs so the
      // CF race can start immediately without waiting for a separate fetch.
      // Cap to 500 URLs to avoid racing thousands of connections at once.
      // Statically-probed URLs come first (known-good); regen candidates fill
      // the remainder up to the cap.
      {
        const maxAdaptiveCandidates = 500;
        final allKnownUrls = <String>{
          ...directNostr,
          ..._kNostrCandidates.map((c) => 'wss://${c.$1}'),
          ...regenCandidates.map((c) => 'wss://${c.$1}'),
        }.take(maxAdaptiveCandidates).toList();
        AdaptiveRelayService.instance.seedCandidates(allKnownUrls);
        // Kick off background race so best relay is cached before first connect
        unawaited(AdaptiveRelayService.instance.getBestRelay());
      }

      // Await Phase 1.5D: NIP-117 TURN discovery results
      final nip117TurnServers = await turnDiscoveryFuture;
      if (nip117TurnServers.isNotEmpty) {
        await IceServerConfig.saveNip117TurnServers(nip117TurnServers);
        debugPrint('[Probe] Phase 1.5D: '
            '${nip117TurnServers.length} NIP-117 TURN server(s) saved');
      }

      // ── Phase 2: Tor probes (only if direct Nostr insufficient) ───────────
      final torNostr = <String>[];
      bool torUsed = false;

      if (directNostr.length < _enoughDirect) {
        _emit(ProbePhase.torBoot);
        debugPrint('[Probe] Phase 2: waiting for Tor...');

        // Re-use the early-start future if we already kicked it off,
        // otherwise start now (edge case: regen found 0 new relays quickly).
        final torReady = earlyTorFuture != null
            ? await earlyTorFuture
            : await TorService.instance.start();
        if (torReady) {
          torUsed = true;
          _emit(ProbePhase.torProbe, torUsed: true);
          debugPrint('[Probe] Tor ready — probing via SOCKS5');

          // Retry all directory fetches via Tor (for censored environments).
          debugPrint('[Probe] Retrying relay directories via Tor...');
          final torDirCandidates = await RelayDirectoryService.instance
              .getCandidates(viaTor: true);
          if (torDirCandidates.isNotEmpty) {
            final knownNow = <String>{
              ..._kNostrCandidates.map((c) => c.$1),
              ...directNostr.map((u) => Uri.parse(u).host),
            };
            final newViaTor = torDirCandidates
                .where((c) => !knownNow.contains(c.$1))
                .toList();
            if (newViaTor.isNotEmpty) {
              debugPrint('[Probe] Probing ${newViaTor.length} Tor-directory relay(s) directly');
              final extraTorHosts = await _probeAll(
                  newViaTor, label: 'regen+tor', timeoutSec: 4);
              directNostr.addAll(extraTorHosts.map((h) => 'wss://$h'));
            }
          }

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

          // ── Tor TURN probe ───────────────────────────────────────────────
          // Check which TURN servers are reachable via Tor.
          // Ones that failed the direct probe may work here.
          // TorTurnProxy already runs for our static list; this confirms
          // connectivity and discovers any extra working TURN configs.
          debugPrint('[Probe] Tor TURN probe...');
          final torTurnConfigs = <Map<String, dynamic>>[];
          final directTurnHostSet = Set<String>.from(directTurnHosts
              .map((h) => h.split(':').first));
          for (final (host, port, iceServers) in _kTurnCandidates) {
            if (iceServers.isEmpty) continue; // probe-only entry, no usable ICE
            if (directTurnHostSet.contains(host)) {
              // Already reachable directly — Tor path redundant but valid
              continue;
            }
            final viaTor = await TorService.instance.probe(host, port);
            if (viaTor) {
              debugPrint('[Probe] ✓ turn via Tor: $host');
              torTurnConfigs.addAll(
                  iceServers.map((s) => Map<String, dynamic>.from(s)));
            }
          }
          if (torTurnConfigs.isNotEmpty) {
            await IceServerConfig.saveProbeTurnServers(
                [...directTurnConfigs, ...torTurnConfigs]);
            debugPrint('[Probe] Saved '
                '${directTurnConfigs.length} direct + '
                '${torTurnConfigs.length} Tor TURN entries');
          }

          if (!TorService.instance.persistent) {
            if (torNostr.isNotEmpty || directNostr.isEmpty) {
              // Network is censored — keep Tor + Psiphon running so
              // Firebase/Session adapters can work too.
              debugPrint('[Probe] Censored network — keeping Tor/Psiphon alive');
            } else {
              await TorService.instance.stop();
              await PsiphonTurnProxy.stopAll();
              await PsiphonService.instance.stop();
              debugPrint('[Probe] Tor/Psiphon stopped.');
            }
          }
          debugPrint('[Probe] Via-tor-only: ${torNostr.length}');
        } else {
          debugPrint('[Probe] Tor unavailable — proceeding with direct only');
        }
      }

      // ── Save result ────────────────────────────────────────────────────────
      _last = ProbeResult(
        nostrRelays:    directNostr,
        sessionNodes:    directSession,
        turnServers:    directTurnHosts,
        torNostrRelays: torNostr,
        timestamp:      DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_last.toJson());
      await prefs.setString(_cacheKey, json);
      final netKey = await _getNetworkKey();
      if (netKey.isNotEmpty) {
        await prefs.setString('${_cacheKeyBase}_$netKey', json);
      }

      // Persist best relay for adapters to pick up on next connect
      if (_last.bestNostrRelay != null) {
        var relay = _last.bestNostrRelay!;
        // Ensure relay is stored with scheme so adapters can use it directly
        if (!relay.startsWith('ws://') && !relay.startsWith('wss://')) {
          relay = 'wss://$relay';
        }
        // Store as a "probe-suggested" relay; adapters prefer this over default
        await prefs.setString('probe_nostr_relay', relay);
        // Also update the active relay so future QR/links use the best route.
        // The identity config is NOT changed — it's just the initial seed.
        await prefs.setString('nostr_relay', relay);
        debugPrint('[Probe] Best Nostr relay: $relay');
      }
      if (_last.sessionNodes.isNotEmpty) {
        await prefs.setString(
            'probe_session_node', _last.sessionNodes.first);
      }
      // Persist full TURN ICE configs for IceServerConfig to pick up
      if (directTurnConfigs.isNotEmpty) {
        await IceServerConfig.saveProbeTurnServers(directTurnConfigs);
        debugPrint('[Probe] Saved ${directTurnConfigs.length} TURN server entries');
      }

      // Only emit final done if we didn't already emit an early done above.
      // (earlyDone already signalled the UI; here we just update the counter.)
      if (!earlyDone) {
        _emit(ProbePhase.done,
            found: directNostr.length + torNostr.length, torUsed: torUsed);
      }
      debugPrint('[Probe] Done. Total reachable: '
          '${directNostr.length} direct + ${torNostr.length} tor-only');

      // Notify waiters (ChatController) that probe finished
      if (!_firstRunCompleter.isCompleted) {
        _firstRunCompleter.complete(_last);
      }

      // Start periodic background refresh + health checks
      startPeriodicRefresh();
    } catch (e) {
      debugPrint('[Probe] Error: $e');
      _emit(ProbePhase.done);
      if (!_firstRunCompleter.isCompleted) {
        _firstRunCompleter.complete(_last);
      }
    } finally {
      _running = false;
    }
  }

  /// Start Tor + Psiphon if the network looks censored.
  /// Called from both cached and fresh probe paths.
  void _startBypassIfCensored(int directRelayCount) {
    if (directRelayCount >= _enoughDirect) return;
    debugPrint('[Probe] Looks censored ($directRelayCount direct) — ensuring bypass transports');
    if (!TorService.instance.isBootstrapped && !TorService.instance.isRunning) {
      TorService.instance.start();
    }
    if (!PsiphonService.instance.isRunning) {
      PsiphonService.instance.ensureRunning().then((_) {
        if (PsiphonService.instance.isRunning) PsiphonTurnProxy.startAll();
      });
    }
  }

  void _emit(ProbePhase phase, {int found = 0, bool torUsed = false}) {
    if (!_statusCtrl.isClosed) {
      _statusCtrl.add(ProbeStatus(phase, found: found, torUsed: torUsed));
    }
  }

  // ── Probe helpers ──────────────────────────────────────────────────────────

  /// Probes candidates with bounded concurrency, returns URLs of reachable ones.
  Future<List<String>> _probeAll(
    List<(String, int)> candidates, {
    required String label,
    required int timeoutSec,
    int maxConcurrent = 20,
  }) async {
    final breaker = CircuitBreakerService.instance;
    final reachable = <String>[];
    int skipped = 0;
    int failed = 0;

    // Pool: process candidates in chunks of [maxConcurrent].
    for (int i = 0; i < candidates.length; i += maxConcurrent) {
      final chunk = candidates.sublist(
        i,
        (i + maxConcurrent).clamp(0, candidates.length),
      );
      await Future.wait(chunk.map((c) async {
        final relay = c.$1;
        if (await breaker.shouldSkip(relay)) {
          skipped++;
          return;
        }
        final ok = await _probeOne(relay, c.$2, timeoutSec: timeoutSec);
        if (ok) {
          reachable.add(relay);
          await breaker.recordSuccess(relay);
        } else {
          failed++;
          await breaker.recordFailure(relay);
        }
      }));
    }

    debugPrint('[Probe] $label: ${reachable.length} reachable, '
        '$failed failed, $skipped skipped / ${candidates.length} total');
    return reachable;
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
          hosts.add('${c.$1}:${c.$2}');
          configs.addAll(c.$3.map((s) => Map<String, dynamic>.from(s)));
        }
      }),
    );
    debugPrint('[Probe] turn: ${hosts.length}/${_kTurnCandidates.length} reachable');

    return (hosts, configs);
  }

  /// TLS handshake probe — verifies GFW isn't blocking at the TLS layer.
  ///
  /// Pure TCP connect passes even when GFW blocks TLS (RST after ClientHello).
  /// This does a real TLS handshake so we know the relay is actually reachable.
  Future<bool> _probeOne(String host, int port, {int timeoutSec = 3}) async {
    try {
      if (port == 443 || port == 8443) {
        // TLS probe — catches GFW TLS-level RST on ClientHello.
        // MED-2 fix: validate certs. A MITM that accepts all TLS connections
        // with fake certs would otherwise make every probe succeed, suppressing
        // Tor bootstrap entirely even when all real connections are blocked.
        final sock = await SecureSocket.connect(host, port,
            timeout: Duration(seconds: timeoutSec));
        sock.destroy();
      } else {
        final sock = await Socket.connect(host, port,
            timeout: Duration(seconds: timeoutSec));
        sock.destroy();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Loads peer-shared relay URLs from SharedPreferences and converts to candidates.
  Future<List<(String, int)>> _loadPeerRelayCandidates(Set<String> knownHosts) async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList(_peerRelaysKey) ?? [];
    final candidates = <(String, int)>[];
    for (final url in urls) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) continue;
      // Reject non-WSS and private/loopback relay hosts stored via peer exchange
      if (uri.scheme != 'wss') continue;
      if (IceServerConfig.isPrivateHost(uri.host)) continue;
      if (knownHosts.contains(uri.host)) continue;
      final port = (uri.hasPort && uri.port != 0) ? uri.port : 443;
      candidates.add((uri.host, port));
    }
    return candidates;
  }

}
