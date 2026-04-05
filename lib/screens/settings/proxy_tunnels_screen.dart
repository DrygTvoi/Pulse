// Proxy & Tunnels screen — Tor, Psiphon, I2P, custom proxy, CF Worker.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/psiphon_service.dart';
import '../../services/psiphon_turn_proxy.dart';
import '../../services/tor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_proxy_section.dart';
import '../../widgets/i2p_config_section.dart';
import '../../widgets/psiphon_config_section.dart';
import '../../widgets/tor_config_section.dart';
import '../../controllers/chat_controller.dart';
import '../network_diagnostics_screen.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class ProxyTunnelsScreen extends StatefulWidget {
  const ProxyTunnelsScreen({super.key});

  @override
  State<ProxyTunnelsScreen> createState() => _ProxyTunnelsScreenState();
}

class _ProxyTunnelsScreenState extends State<ProxyTunnelsScreen> {
  bool _torEnabled = false;
  bool _bundledTorEnabled = false;
  bool _bundledTorLoading = false;
  String _preferredPt = 'auto';
  int _torTimeoutSec = 60;
  final _torHostController = TextEditingController(text: '127.0.0.1');
  final _torPortController = TextEditingController(text: '9050');

  bool _forceNostrTor = false;
  bool _forcePulseTor = false;

  bool _psiphonEnabled = false;
  bool _psiphonLoading = false;

  bool _i2pEnabled = false;
  final _i2pHostController = TextEditingController(text: '127.0.0.1');
  final _i2pPortController = TextEditingController(text: '4447');

  bool _customProxyEnabled = false;
  final _customProxyHostController =
      TextEditingController(text: '127.0.0.1');
  final _customProxyPortController = TextEditingController(text: '10808');
  final _cfWorkerRelayController = TextEditingController();

  StreamSubscription<void>? _torStateSub;

  // BUG-4: settings loaded flag — prevents saving during initial field population.
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _torStateSub = TorService.instance.stateChanges.listen((_) {
      if (mounted) setState(() {});
    });
    // Save text field values to SharedPreferences whenever they change.
    for (final c in [
      _torHostController, _torPortController,
      _i2pHostController, _i2pPortController,
      _customProxyHostController, _customProxyPortController,
      _cfWorkerRelayController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _torStateSub?.cancel();
    for (final c in [
      _torHostController, _torPortController,
      _i2pHostController, _i2pPortController,
      _customProxyHostController, _customProxyPortController,
      _cfWorkerRelayController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_settingsLoaded) return;
    _saveFieldSettings();
  }

  Future<void> _saveFieldSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tor_host', _torHostController.text.trim());
    await prefs.setInt('tor_port',
        (int.tryParse(_torPortController.text) ?? 9050).clamp(1, 65535));
    await prefs.setString('i2p_host', _i2pHostController.text.trim());
    await prefs.setInt('i2p_port',
        (int.tryParse(_i2pPortController.text) ?? 4447).clamp(1, 65535));
    await prefs.setString('custom_proxy_host',
        _customProxyHostController.text.trim());
    await prefs.setInt('custom_proxy_port',
        (int.tryParse(_customProxyPortController.text) ?? 10808).clamp(1, 65535));
    // Cap CF Worker relay URL length to prevent storage bloat
    final cfWorkerRelay = _cfWorkerRelayController.text.trim();
    if (cfWorkerRelay.length <= 512) {
      await prefs.setString('cf_worker_relay', cfWorkerRelay);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final torEnabled = prefs.getBool('tor_enabled') ?? false;
    final torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    final torPort = prefs.getInt('tor_port') ?? 9050;
    final i2pEnabled = prefs.getBool('i2p_enabled') ?? false;
    final i2pHost = prefs.getString('i2p_host') ?? '127.0.0.1';
    final i2pPort = prefs.getInt('i2p_port') ?? 4447;
    final customProxyEnabled = prefs.getBool('custom_proxy_enabled') ?? false;
    final customProxyHost = prefs.getString('custom_proxy_host') ?? '127.0.0.1';
    final customProxyPort = prefs.getInt('custom_proxy_port') ?? 10808;
    final cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';
    final bundledTorEnabled = prefs.getBool('bundled_tor_enabled') ?? false;
    final psiphonEnabled = prefs.getBool('bundled_psiphon_enabled') ?? false;
    final preferredPt = prefs.getString('preferred_pt') ?? 'auto';
    final torTimeoutSec = prefs.getInt('tor_timeout_sec') ?? 60;
    final forceNostrTor = prefs.getBool('nostr_force_tor') ?? false;
    final forcePulseTor = prefs.getBool('pulse_force_tor') ?? false;

    if (!mounted) return;
    setState(() {
      _torEnabled = torEnabled;
      _bundledTorEnabled = bundledTorEnabled;
      _psiphonEnabled = psiphonEnabled;
      _preferredPt = preferredPt;
      _torTimeoutSec = torTimeoutSec;
      _forceNostrTor = forceNostrTor;
      _forcePulseTor = forcePulseTor;
      _torHostController.text = torHost;
      _torPortController.text = torPort.toString();
      _i2pEnabled = i2pEnabled;
      _i2pHostController.text = i2pHost;
      _i2pPortController.text = i2pPort.toString();
      _customProxyEnabled = customProxyEnabled;
      _customProxyHostController.text = customProxyHost;
      _customProxyPortController.text = customProxyPort.toString();
      _cfWorkerRelayController.text = cfWorkerRelay;
      _settingsLoaded = true; // BUG-4: allow listeners to save from this point
    });
  }

  Future<void> _toggleBundledTor() async {
    if (_bundledTorLoading) return;
    final prefs = await SharedPreferences.getInstance();
    if (_bundledTorEnabled) {
      await TorService.instance.stop();
      setState(() => _bundledTorEnabled = false);
      await prefs.setBool('bundled_tor_enabled', false);
    } else {
      setState(() => _bundledTorLoading = true);
      final ok = await TorService.instance.startPersistent();
      if (!mounted) return;
      if (ok) {
        setState(() {
          _bundledTorEnabled = true;
          _bundledTorLoading = false;
          _torEnabled = true;
          _torHostController.text = '127.0.0.1';
          _torPortController.text = '9250';
        });
        await prefs.setBool('bundled_tor_enabled', true);
        await prefs.setBool('tor_enabled', true);
        await prefs.setString('tor_host', '127.0.0.1');
        await prefs.setInt('tor_port', 9250);
      } else {
        setState(() => _bundledTorLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.settingsTorFailedToStart)),
          );
        }
      }
    }
  }

  Future<void> _togglePsiphon() async {
    if (_psiphonLoading) return;
    final prefs = await SharedPreferences.getInstance();
    if (_psiphonEnabled) {
      await PsiphonTurnProxy.stopAll();
      await PsiphonService.instance.stop();
      setState(() => _psiphonEnabled = false);
      await prefs.setBool('bundled_psiphon_enabled', false);
    } else {
      setState(() => _psiphonLoading = true);
      await PsiphonService.instance.ensureRunning();
      if (!mounted) return;
      if (PsiphonService.instance.isRunning) {
        PsiphonTurnProxy.startAll();
        setState(() {
          _psiphonEnabled = true;
          _psiphonLoading = false;
        });
        await prefs.setBool('bundled_psiphon_enabled', true);
      } else {
        setState(() => _psiphonLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(context.l10n.settingsPsiphonFailedToStart)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.settingsProxyTunnels,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          TorConfigSection(
            torEnabled: _torEnabled,
            bundledTorEnabled: _bundledTorEnabled,
            bundledTorLoading: _bundledTorLoading,
            preferredPt: _preferredPt,
            torHostController: _torHostController,
            torPortController: _torPortController,
            onTorEnabledChanged: (v) async {
              setState(() => _torEnabled = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('tor_enabled', v);
            },
            onToggleBundledTor: _toggleBundledTor,
            onPreferredPtChanged: (val) async {
              setState(() => _preferredPt = val);
              // Capture context-derived values before any await.
              final messenger = ScaffoldMessenger.of(context);
              final failMsg = context.l10n.settingsTorFailedToStart;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('preferred_pt', val);
              // Auto-restart Tor so new PT takes effect immediately.
              if (_bundledTorEnabled && TorService.instance.isRunning) {
                setState(() => _bundledTorLoading = true);
                final ok = await TorService.instance.restartPersistent();
                if (!mounted) return;
                setState(() {
                  _bundledTorLoading = false;
                  _bundledTorEnabled = ok;
                });
                if (!ok) {
                  messenger.showSnackBar(
                      SnackBar(content: Text(failMsg)));
                }
              }
            },
            forceNostrTor: _forceNostrTor,
            onForceNostrTorChanged: (v) async {
              debugPrint('[Settings] Force-Tor Nostr toggled: $v');
              setState(() => _forceNostrTor = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('nostr_force_tor', v);
              // Reset all Nostr connections so new route takes effect immediately
              unawaited(ChatController().resetNostrConnections());
            },
            forcePulseTor: _forcePulseTor,
            onForcePulseTorChanged: (v) async {
              debugPrint('[Settings] Force-Tor Pulse toggled: $v');
              setState(() => _forcePulseTor = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pulse_force_tor', v);
              unawaited(ChatController().resetPulseConnections());
            },
            torTimeoutSec: _torTimeoutSec,
            onTorTimeoutChanged: (val) async {
              setState(() => _torTimeoutSec = val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('tor_timeout_sec', val);
            },
            onOpenDiagnostics: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NetworkDiagnosticsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          PsiphonConfigSection(
            psiphonEnabled: _psiphonEnabled,
            psiphonLoading: _psiphonLoading,
            onToggle: _togglePsiphon,
          ),
          const SizedBox(height: 12),
          CustomProxySection(
            proxyEnabled: _customProxyEnabled,
            proxyHostController: _customProxyHostController,
            proxyPortController: _customProxyPortController,
            onProxyEnabledChanged: (v) async {
              setState(() => _customProxyEnabled = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('custom_proxy_enabled', v);
            },
            workerRelayController: _cfWorkerRelayController,
          ),
          if (!_bundledTorEnabled) ...[
            const SizedBox(height: 12),
            I2pConfigSection(
              i2pEnabled: _i2pEnabled,
              i2pHostController: _i2pHostController,
              i2pPortController: _i2pPortController,
              onI2pEnabledChanged: (v) async {
                setState(() => _i2pEnabled = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('i2p_enabled', v);
              },
            ),
          ],
        ],
      ),
    );
  }
}
