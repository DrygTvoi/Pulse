import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../theme/app_theme.dart';
import '../theme/theme_manager.dart';
import '../controllers/chat_controller.dart';
import '../services/background_service.dart';
import '../services/ice_server_config.dart';
import '../services/psiphon_service.dart';
import '../services/psiphon_turn_proxy.dart';
import '../services/tor_service.dart';
import 'settings/profile_section.dart';
import 'settings/provider_section.dart';
import 'settings/network_section.dart';
import 'settings/appearance_identity_section.dart';
import 'settings/data_section.dart';
import 'settings/security_section.dart';
import 'settings/about_section.dart';

// Re-export for backward compatibility — InboxAddressCard is defined in profile_card.dart
export '../widgets/profile_card.dart' show InboxAddressCard;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _secureStorage = FlutterSecureStorage();
  static const _nostrPrivkeyStorageKey = 'nostr_privkey';

  String _selectedProvider = 'Firebase';
  final _firebaseUrlController = TextEditingController();
  final _firebaseKeyController = TextEditingController();
  final _nostrKeyController = TextEditingController();
  final _nostrRelayController = TextEditingController();
  final _wakuNodeUrlController =
      TextEditingController(text: 'http://127.0.0.1:8645');
  final _oxenNodeUrlController = TextEditingController();
  bool _isSaving = false;
  List<Map<String, String>> _secondaryAdapters = [];

  // TURN state
  List<String> _enabledPresets = ['openrelay'];
  final _turnUrlController = TextEditingController();
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();

  // LAN state
  bool _lanModeEnabled = true;

  // Tor state
  bool _torEnabled = false;
  bool _bundledTorEnabled = false;
  bool _bundledTorLoading = false;
  String _preferredPt = 'auto';
  final _torHostController = TextEditingController(text: '127.0.0.1');
  final _torPortController = TextEditingController(text: '9050');
  StreamSubscription<void>? _torStateSub;

  // Psiphon state
  bool _psiphonEnabled = false;
  bool _psiphonLoading = false;

  // I2P state
  bool _i2pEnabled = false;
  final _i2pHostController = TextEditingController(text: '127.0.0.1');
  final _i2pPortController = TextEditingController(text: '4447');

  // Custom proxy state
  bool _customProxyEnabled = false;
  final _customProxyHostController =
      TextEditingController(text: '127.0.0.1');
  final _customProxyPortController =
      TextEditingController(text: '10808');
  final _cfWorkerRelayController = TextEditingController();

  // Background service
  bool _bgServiceEnabled = false;

  // Security state
  bool _passwordEnabled = false;
  bool _panicKeyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _torStateSub = TorService.instance.stateChanges.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _torStateSub?.cancel();
    _firebaseUrlController.dispose();
    _firebaseKeyController.dispose();
    _nostrKeyController.dispose();
    _nostrRelayController.dispose();
    _wakuNodeUrlController.dispose();
    _oxenNodeUrlController.dispose();
    _turnUrlController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    _torHostController.dispose();
    _torPortController.dispose();
    _i2pHostController.dispose();
    _i2pPortController.dispose();
    _customProxyHostController.dispose();
    _customProxyPortController.dispose();
    _cfWorkerRelayController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString('byod_provider') ?? 'Firebase';
    final savedKey = prefs.getString('byod_api_key') ?? '';

    String nostrPrivkey = '';
    String nostrRelay = kDefaultNostrRelay;

    if (provider == 'Nostr') {
      if (savedKey.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedKey);
          nostrPrivkey = decoded['privkey'] ?? '';
          nostrRelay = decoded['relay'] ?? kDefaultNostrRelay;
        } catch (e) {
          debugPrint('[Settings] Failed to parse Nostr key JSON: $e');
        }
        if (nostrPrivkey.isNotEmpty) {
          await _secureStorage.write(
              key: _nostrPrivkeyStorageKey, value: nostrPrivkey);
          await prefs.remove('byod_api_key');
        }
      } else {
        nostrPrivkey =
            await _secureStorage.read(key: _nostrPrivkeyStorageKey) ?? '';
        nostrRelay =
            prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
      }
    }

    final secondaryAdapters = await _loadSecondaryAdaptersFromPrefs();
    final enabledPresets = await IceServerConfig.loadEnabledPresets();
    final customTurn = await IceServerConfig.loadCustomTurn();
    final torEnabled = prefs.getBool('tor_enabled') ?? false;
    final torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    final torPort = prefs.getInt('tor_port') ?? 9050;
    final i2pEnabled = prefs.getBool('i2p_enabled') ?? false;
    final i2pHost = prefs.getString('i2p_host') ?? '127.0.0.1';
    final i2pPort = prefs.getInt('i2p_port') ?? 4447;
    final customProxyEnabled =
        prefs.getBool('custom_proxy_enabled') ?? false;
    final customProxyHost =
        prefs.getString('custom_proxy_host') ?? '127.0.0.1';
    final customProxyPort = prefs.getInt('custom_proxy_port') ?? 10808;
    final cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';
    final passwordEnabled =
        await _secureStorage.read(key: 'app_password_enabled') == 'true';
    final panicKeyEnabled =
        (await _secureStorage.read(key: 'app_panic_key_hash')) != null;
    final bundledTorEnabled =
        prefs.getBool('bundled_tor_enabled') ?? false;
    final psiphonEnabled =
        prefs.getBool('bundled_psiphon_enabled') ?? false;
    final preferredPt = prefs.getString('preferred_pt') ?? 'auto';
    final lanModeEnabled = await ChatController.getLanModeEnabled();
    final bgServiceEnabled = await BackgroundService.instance.isEnabled();

    setState(() {
      _bgServiceEnabled = bgServiceEnabled;
      _lanModeEnabled = lanModeEnabled;
      _torEnabled = torEnabled;
      _bundledTorEnabled = bundledTorEnabled;
      _psiphonEnabled = psiphonEnabled;
      _preferredPt = preferredPt;
      _torHostController.text = torHost;
      _torPortController.text = torPort.toString();
      _i2pEnabled = i2pEnabled;
      _i2pHostController.text = i2pHost;
      _i2pPortController.text = i2pPort.toString();
      _customProxyEnabled = customProxyEnabled;
      _customProxyHostController.text = customProxyHost;
      _customProxyPortController.text = customProxyPort.toString();
      _cfWorkerRelayController.text = cfWorkerRelay;
      _passwordEnabled = passwordEnabled;
      _panicKeyEnabled = panicKeyEnabled;
      _enabledPresets = enabledPresets;
      _turnUrlController.text = customTurn.url;
      _turnUsernameController.text = customTurn.username;
      _turnPasswordController.text = customTurn.password;
      _selectedProvider = provider;
      if (provider == 'Firebase') {
        try {
          final decoded = jsonDecode(savedKey);
          _firebaseUrlController.text = decoded['url'] ?? '';
          _firebaseKeyController.text = decoded['key'] ?? '';
        } catch (_) {
          _firebaseUrlController.text = savedKey;
        }
      } else if (provider == 'Nostr') {
        _nostrKeyController.text = nostrPrivkey;
        _nostrRelayController.text = nostrRelay;
      } else if (provider == 'Waku') {
        _wakuNodeUrlController.text =
            prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      } else if (provider == 'Oxen') {
        _oxenNodeUrlController.text =
            prefs.getString('oxen_node_url') ?? '';
      }
      _secondaryAdapters = secondaryAdapters;
    });
  }

  Future<List<Map<String, String>>> _loadSecondaryAdaptersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('secondary_adapters');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Map<String, String>.from(
              (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    String finalApiKey;
    String finalDbId;
    if (_selectedProvider == 'Firebase') {
      finalApiKey = jsonEncode({
        'url': _firebaseUrlController.text.trim(),
        'key': _firebaseKeyController.text.trim(),
      });
      final identity = ChatController().identity;
      finalDbId = identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
    } else if (_selectedProvider == 'Nostr') {
      await _secureStorage.write(
          key: _nostrPrivkeyStorageKey,
          value: _nostrKeyController.text.trim());
      await prefs.setString(
          'nostr_relay', _nostrRelayController.text.trim());
      finalApiKey =
          jsonEncode({'relay': _nostrRelayController.text.trim()});
      finalDbId = _nostrRelayController.text.trim();
    } else if (_selectedProvider == 'Waku') {
      final nodeUrl = _wakuNodeUrlController.text.trim().isNotEmpty
          ? _wakuNodeUrlController.text.trim()
          : 'http://127.0.0.1:8645';
      await prefs.setString('waku_node_url', nodeUrl);
      finalApiKey = jsonEncode({'nodeUrl': nodeUrl});
      finalDbId = nodeUrl;
    } else {
      final nodeUrl = _oxenNodeUrlController.text.trim();
      await prefs.setString('oxen_node_url', nodeUrl);
      finalApiKey = nodeUrl;
      finalDbId = ChatController().myAddress;
    }

    await prefs.setString('byod_provider', _selectedProvider);
    if (_selectedProvider != 'Nostr' &&
        _selectedProvider != 'Waku' &&
        _selectedProvider != 'Oxen') {
      await prefs.setString('byod_api_key', finalApiKey);
    }
    await prefs.setString('byod_db_id', finalDbId);

    final chatCtrl = ChatController();
    if (chatCtrl.identity != null) {
      const adapterMap = {
        'Firebase': 'firebase',
        'Nostr': 'nostr',
        'Waku': 'waku',
        'Oxen': 'oxen',
      };
      chatCtrl.identity!.preferredAdapter =
          adapterMap[_selectedProvider] ?? 'firebase';
      chatCtrl.identity!.adapterConfig['token'] = finalApiKey;
      await prefs.setString(
          'user_identity', jsonEncode(chatCtrl.identity!.toJson()));
    }

    await prefs.setBool('tor_enabled', _torEnabled);
    await prefs.setString(
        'tor_host', _torHostController.text.trim());
    final torPortVal =
        int.tryParse(_torPortController.text.trim()) ?? 9050;
    await prefs.setInt('tor_port', torPortVal);

    await prefs.setBool('i2p_enabled', _i2pEnabled);
    await prefs.setString(
        'i2p_host', _i2pHostController.text.trim());
    final i2pPortVal =
        int.tryParse(_i2pPortController.text.trim()) ?? 4447;
    await prefs.setInt('i2p_port', i2pPortVal);

    await prefs.setBool('custom_proxy_enabled', _customProxyEnabled);
    await prefs.setString(
        'custom_proxy_host', _customProxyHostController.text.trim());
    final cpPortVal =
        int.tryParse(_customProxyPortController.text.trim()) ?? 10808;
    await prefs.setInt('custom_proxy_port', cpPortVal);
    final workerRelay = _cfWorkerRelayController.text.trim();
    if (workerRelay.isNotEmpty) {
      await prefs.setString('cf_worker_relay', workerRelay);
    } else {
      await prefs.remove('cf_worker_relay');
    }

    await IceServerConfig.saveEnabledPresets(_enabledPresets);
    await IceServerConfig.saveCustomTurn(
      url: _turnUrlController.text.trim(),
      username: _turnUsernameController.text.trim(),
      password: _turnPasswordController.text.trim(),
    );

    await chatCtrl.reconnectInbox();
    unawaited(chatCtrl.broadcastAddressUpdate());

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Saved & connected to $_selectedProvider 🔐',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
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
            const SnackBar(
                content: Text('Built-in Tor failed to start')),
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
            const SnackBar(content: Text('Psiphon failed to start')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeNotifier>(); // rebuild when theme changes
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Settings',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          // ─── Profile + Inbox Address + QR ────────────────────
          ProfileSection(),
          const SizedBox(height: 28),

          // ─── Provider + Connection Details + Secondary Inboxes
          ProviderSection(
            selectedProvider: _selectedProvider,
            firebaseUrlController: _firebaseUrlController,
            firebaseKeyController: _firebaseKeyController,
            nostrKeyController: _nostrKeyController,
            nostrRelayController: _nostrRelayController,
            wakuNodeUrlController: _wakuNodeUrlController,
            oxenNodeUrlController: _oxenNodeUrlController,
            isSaving: _isSaving,
            secondaryAdapters: _secondaryAdapters,
            onSave: _saveSettings,
            onProviderChanged: (p) => setState(() => _selectedProvider = p),
            onSecondaryAdaptersChanged: (list) =>
                setState(() => _secondaryAdapters = list),
          ),
          const SizedBox(height: 32),

          // ─── Network (TURN, LAN, BG service, Tor, Proxy, I2P)
          NetworkSection(
            enabledPresets: _enabledPresets,
            turnUrlController: _turnUrlController,
            turnUsernameController: _turnUsernameController,
            turnPasswordController: _turnPasswordController,
            onPresetsChanged: (presets) =>
                setState(() => _enabledPresets = presets),
            lanModeEnabled: _lanModeEnabled,
            onLanModeChanged: (v) => setState(() => _lanModeEnabled = v),
            bgServiceEnabled: _bgServiceEnabled,
            onBgServiceChanged: (v) =>
                setState(() => _bgServiceEnabled = v),
            torEnabled: _torEnabled,
            bundledTorEnabled: _bundledTorEnabled,
            bundledTorLoading: _bundledTorLoading,
            preferredPt: _preferredPt,
            torHostController: _torHostController,
            torPortController: _torPortController,
            onTorEnabledChanged: (v) => setState(() => _torEnabled = v),
            onToggleBundledTor: _toggleBundledTor,
            onPreferredPtChanged: (val) =>
                setState(() => _preferredPt = val),
            customProxyEnabled: _customProxyEnabled,
            customProxyHostController: _customProxyHostController,
            customProxyPortController: _customProxyPortController,
            onCustomProxyEnabledChanged: (v) =>
                setState(() => _customProxyEnabled = v),
            cfWorkerRelayController: _cfWorkerRelayController,
            psiphonEnabled: _psiphonEnabled,
            psiphonLoading: _psiphonLoading,
            onTogglePsiphon: _togglePsiphon,
            i2pEnabled: _i2pEnabled,
            i2pHostController: _i2pHostController,
            i2pPortController: _i2pPortController,
            onI2pEnabledChanged: (v) => setState(() => _i2pEnabled = v),
          ),
          const SizedBox(height: 32),

          // ─── Appearance + Identity ────────────────────────────
          AppearanceIdentitySection(),
          const SizedBox(height: 32),

          // ─── Data ─────────────────────────────────────────────
          DataSection(),
          const SizedBox(height: 32),

          // ─── Security ─────────────────────────────────────────
          SecuritySection(
            passwordEnabled: _passwordEnabled,
            panicKeyEnabled: _panicKeyEnabled,
            onPasswordEnabledChanged: (v) =>
                setState(() => _passwordEnabled = v),
            onPanicKeyEnabledChanged: (v) =>
                setState(() => _panicKeyEnabled = v),
          ),
          const SizedBox(height: 32),

          // ─── About ────────────────────────────────────────────
          AboutSection(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
