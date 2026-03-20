import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../services/connectivity_probe_service.dart';
import '../services/tor_service.dart';
import '../services/adaptive_relay_service.dart';
import '../services/cloudflare_ip_service.dart';
import 'dart:async';

class NetworkDiagnosticsScreen extends StatefulWidget {
  const NetworkDiagnosticsScreen({super.key});

  @override
  State<NetworkDiagnosticsScreen> createState() =>
      _NetworkDiagnosticsScreenState();
}

class _NetworkDiagnosticsScreenState extends State<NetworkDiagnosticsScreen> {
  StreamSubscription? _probeSub;
  StreamSubscription? _torSub;
  bool _probing = false;
  final _log = <String>[];

  @override
  void initState() {
    super.initState();
    _probeSub = ConnectivityProbeService.instance.status.listen((s) {
      if (mounted) setState(() {});
    });
    _torSub = TorService.instance.stateChanges.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _probeSub?.cancel();
    _torSub?.cancel();
    super.dispose();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _probing = true;
      _log.clear();
    });

    void log(String msg) {
      if (!mounted) return;
      setState(() => _log.add(msg));
    }

    // 1. DoH providers
    log('--- DoH Resolution Test ---');
    for (final host in ['relay.damus.io', 'nos.lol', 'google.com']) {
      try {
        final (isCf, ips) = await CloudflareIpService.instance
            .resolveAndCheck(host)
            .timeout(const Duration(seconds: 6),
                onTimeout: () => (false, <String>[]));
        final cfLabel = isCf ? ' [CF]' : '';
        if (ips.isNotEmpty) {
          log('  $host → ${ips.join(", ")}$cfLabel');
        } else {
          log('  $host → FAILED (no IPs resolved)');
        }
      } catch (e) {
        log('  $host → ERROR: $e');
      }
    }

    // 2. Adaptive relay
    log('');
    log('--- Adaptive Relay ---');
    final best = await AdaptiveRelayService.instance.getBestRelay();
    log('  Best CF relay: ${best ?? "none"}');

    // 3. Tor status
    log('');
    log('--- Tor Status ---');
    final tor = TorService.instance;
    log('  Running: ${tor.isRunning}');
    log('  Bootstrapped: ${tor.isBootstrapped}');
    log('  Bootstrap %: ${tor.bootstrapPercent}');
    log('  Active PT: ${tor.activePtLabel.isEmpty ? "none" : tor.activePtLabel}');

    // 4. Probe results
    log('');
    log('--- Probe Results ---');
    final probe = ConnectivityProbeService.instance.lastResult;
    log('  Direct Nostr: ${probe.nostrRelays.length}');
    for (final r in probe.nostrRelays.take(10)) {
      log('    $r');
    }
    if (probe.torNostrRelays.isNotEmpty) {
      log('  Tor-only Nostr: ${probe.torNostrRelays.length}');
      for (final r in probe.torNostrRelays.take(5)) {
        log('    $r');
      }
    }
    log('  Oxen nodes: ${probe.oxenNodes.length}');
    log('  TURN servers: ${probe.turnServers.length}');
    log('  Last probe: ${probe.timestamp}');

    setState(() => _probing = false);
  }

  @override
  Widget build(BuildContext context) {
    final probe = ConnectivityProbeService.instance.lastResult;
    final tor = TorService.instance;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('Network Diagnostics',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: DesignTokens.fontHeading)),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        children: [
          // Summary cards
          _card('Nostr Relays', [
            _kv('Direct', '${probe.nostrRelays.length}'),
            _kv('Tor-only', '${probe.torNostrRelays.length}'),
            _kv('Best', probe.bestNostrRelay ?? 'none'),
          ]),
          const SizedBox(height: DesignTokens.spacing10),
          _card('Tor', [
            _kv('Status', tor.isBootstrapped
                ? 'Connected'
                : tor.isRunning
                    ? 'Connecting ${tor.bootstrapPercent}%'
                    : 'Off'),
            _kv('Transport', tor.activePtLabel.isEmpty
                ? 'none'
                : tor.activePtLabel),
          ]),
          const SizedBox(height: DesignTokens.spacing10),
          _card('Infrastructure', [
            _kv('Oxen nodes', '${probe.oxenNodes.length}'),
            _kv('TURN servers', '${probe.turnServers.length}'),
            _kv('Last probe', _formatAge(probe.timestamp)),
          ]),
          const SizedBox(height: DesignTokens.spacing16),

          // Run diagnostics button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _probing ? null : _runDiagnostics,
              icon: _probing
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.speed_rounded, size: 18),
              label: Text(_probing ? 'Running...' : 'Run Diagnostics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _probing ? null : () async {
                setState(() => _probing = true);
                await ConnectivityProbeService.instance.forceProbe();
                if (mounted) setState(() => _probing = false);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Force Full Re-probe'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(color: AppTheme.surfaceVariant),
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              ),
            ),
          ),

          // Log output
          if (_log.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacing16),
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(DesignTokens.spacing10),
              ),
              child: SelectableText(
                _log.join('\n'),
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.greenAccent, fontSize: DesignTokens.fontSm, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: DesignTokens.fontLg)),
          const SizedBox(height: DesignTokens.spacing8),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: DesignTokens.fontBody)),
          ),
        ],
      ),
    );
  }

  String _formatAge(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
