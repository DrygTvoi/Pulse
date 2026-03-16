import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../services/password_hasher.dart';
import 'package:convert/convert.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_picker_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dynamic_theme_screen.dart';
import 'device_transfer_screen.dart';
import '../controllers/chat_controller.dart';
import '../adapters/nostr_adapter.dart';
import '../widgets/profile_card.dart';
import '../widgets/password_setup_dialog.dart';
import '../widgets/panic_key_dialog.dart';
import '../services/ice_server_config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/waku_discovery_service.dart';
import '../services/tor_service.dart';
import 'network_diagnostics_screen.dart';
import '../widgets/turn_config_section.dart';
import '../widgets/tor_config_section.dart';
import '../widgets/i2p_config_section.dart';

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
  final _wakuNodeUrlController = TextEditingController(text: 'http://127.0.0.1:8645');
  final _oxenNodeUrlController = TextEditingController();
  bool _isSaving = false;
  List<Map<String, String>> _secondaryAdapters = [];

  // TURN state
  List<String> _enabledPresets = ['openrelay'];
  final _turnUrlController      = TextEditingController();
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();

  // Waku discovery state
  bool _wakuDiscovering = false;
  List<WakuNodeInfo>? _wakuNodes;

  // LAN state
  bool _lanModeEnabled = true;

  // Tor state
  bool _torEnabled = false;
  bool _bundledTorEnabled = false;
  bool _bundledTorLoading = false;
  String _preferredPt = 'auto'; // auto, obfs4, webtunnel, snowflake, plain
  final _torHostController = TextEditingController(text: '127.0.0.1');
  final _torPortController = TextEditingController(text: '9050');
  StreamSubscription<void>? _torStateSub;

  // I2P state
  bool _i2pEnabled = false;
  final _i2pHostController = TextEditingController(text: '127.0.0.1');
  final _i2pPortController = TextEditingController(text: '4447');

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
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString('byod_provider') ?? 'Firebase';
    final savedKey = prefs.getString('byod_api_key') ?? '';

    String nostrPrivkey = '';
    String nostrRelay = 'wss://relay.damus.io';

    if (provider == 'Nostr') {
      // Migrate legacy key from SharedPreferences to secure storage
      if (savedKey.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedKey);
          nostrPrivkey = decoded['privkey'] ?? '';
          nostrRelay = decoded['relay'] ?? 'wss://relay.damus.io';
        } catch (_) {}
        // Persist to secure storage and clear from prefs
        if (nostrPrivkey.isNotEmpty) {
          await _secureStorage.write(key: _nostrPrivkeyStorageKey, value: nostrPrivkey);
          await prefs.remove('byod_api_key');
        }
      } else {
        nostrPrivkey = await _secureStorage.read(key: _nostrPrivkeyStorageKey) ?? '';
        nostrRelay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
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
    final passwordEnabled =
        await _secureStorage.read(key: 'app_password_enabled') == 'true';
    final panicKeyEnabled =
        (await _secureStorage.read(key: 'app_panic_key_hash')) != null;

    final bundledTorEnabled = prefs.getBool('bundled_tor_enabled') ?? false;
    final preferredPt = prefs.getString('preferred_pt') ?? 'auto';
    final lanModeEnabled = await ChatController.getLanModeEnabled();
    setState(() {
      _lanModeEnabled = lanModeEnabled;
      _torEnabled = torEnabled;
      _bundledTorEnabled = bundledTorEnabled;
      _preferredPt = preferredPt;
      _torHostController.text = torHost;
      _torPortController.text = torPort.toString();
      _i2pEnabled = i2pEnabled;
      _i2pHostController.text = i2pHost;
      _i2pPortController.text = i2pPort.toString();
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
        _wakuNodeUrlController.text = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      } else if (provider == 'Oxen') {
        _oxenNodeUrlController.text = prefs.getString('oxen_node_url') ?? '';
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
      finalApiKey = jsonEncode({'url': _firebaseUrlController.text.trim(), 'key': _firebaseKeyController.text.trim()});
      final identity = ChatController().identity;
      finalDbId = identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
    } else if (_selectedProvider == 'Nostr') {
      await _secureStorage.write(key: _nostrPrivkeyStorageKey, value: _nostrKeyController.text.trim());
      await prefs.setString('nostr_relay', _nostrRelayController.text.trim());
      finalApiKey = jsonEncode({'relay': _nostrRelayController.text.trim()});
      finalDbId = _nostrRelayController.text.trim();
    } else if (_selectedProvider == 'Waku') {
      final nodeUrl = _wakuNodeUrlController.text.trim().isNotEmpty
          ? _wakuNodeUrlController.text.trim()
          : 'http://127.0.0.1:8645';
      await prefs.setString('waku_node_url', nodeUrl);
      finalApiKey = jsonEncode({'nodeUrl': nodeUrl});
      finalDbId = nodeUrl;
    } else {
      // Oxen: key-derived identity, node URL optional
      final nodeUrl = _oxenNodeUrlController.text.trim();
      await prefs.setString('oxen_node_url', nodeUrl);
      finalApiKey = nodeUrl;
      finalDbId = ChatController().myAddress; // Session ID (set after init)
    }

    await prefs.setString('byod_provider', _selectedProvider);
    if (_selectedProvider != 'Nostr' && _selectedProvider != 'Waku' && _selectedProvider != 'Oxen') {
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
      chatCtrl.identity!.preferredAdapter = adapterMap[_selectedProvider] ?? 'firebase';
      chatCtrl.identity!.adapterConfig['token'] = finalApiKey;
      // Persist updated identity so it survives app restarts
      await prefs.setString('user_identity', jsonEncode(chatCtrl.identity!.toJson()));
    }

    // Save Tor settings
    await prefs.setBool('tor_enabled', _torEnabled);
    await prefs.setString('tor_host', _torHostController.text.trim());
    final torPortVal = int.tryParse(_torPortController.text.trim()) ?? 9050;
    await prefs.setInt('tor_port', torPortVal);

    // Save I2P settings
    await prefs.setBool('i2p_enabled', _i2pEnabled);
    await prefs.setString('i2p_host', _i2pHostController.text.trim());
    final i2pPortVal = int.tryParse(_i2pPortController.text.trim()) ?? 4447;
    await prefs.setInt('i2p_port', i2pPortVal);

    // Save TURN settings
    await IceServerConfig.saveEnabledPresets(_enabledPresets);
    await IceServerConfig.saveCustomTurn(
      url:      _turnUrlController.text.trim(),
      username: _turnUsernameController.text.trim(),
      password: _turnPasswordController.text.trim(),
    );

    // Re-initialise inbox with updated config (also re-publishes Signal keys if needed)
    await chatCtrl.reconnectInbox();
    unawaited(chatCtrl.broadcastAddressUpdate());

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saved & connected to $_selectedProvider 🔐', style: GoogleFonts.inter()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          // ─── My Profile ───────────────────────────────────────
          _sectionLabel('My Profile'),
          const SizedBox(height: 12),
          const ProfileCard(showAddressCard: false),
          const SizedBox(height: 32),

          // ─── Provider selection ───────────────────────────────
          _sectionLabel('Your Inbox Provider'),
          const SizedBox(height: 12),
          _buildProviderChips(),
          const SizedBox(height: 28),

          // ─── Provider-specific config ─────────────────────────
          _sectionLabel('Connection Details'),
          const SizedBox(height: 12),
          _buildProviderConfig(),

          const SizedBox(height: 32),

          // ─── Save button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('Save & Connect',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 28),

          // ─── Active inbox address ──────────────────────────────
          _sectionLabel('Your Inbox Address'),
          const SizedBox(height: 10),
          const InboxAddressCard(),
          const SizedBox(height: 10),
          _settingRow(
            icon: Icons.qr_code_rounded,
            iconColor: const Color(0xFF9B59B6),
            title: 'My QR Code',
            subtitle: 'Share your address as a scannable QR',
            onTap: _showMyQrDialog,
          ),

          const SizedBox(height: 28),

          // ─── Secondary Inboxes ────────────────────────────────
          _sectionLabel('Secondary Inboxes'),
          const SizedBox(height: 10),
          _buildSecondaryInboxesSection(),

          const SizedBox(height: 32),
          _sectionDivider('Calls & TURN'),
          const SizedBox(height: 6),
          TurnConfigSection(
            enabledPresets: _enabledPresets,
            turnUrlController: _turnUrlController,
            turnUsernameController: _turnUsernameController,
            turnPasswordController: _turnPasswordController,
            onPresetsChanged: (presets) => setState(() => _enabledPresets = presets),
          ),

          const SizedBox(height: 32),
          _sectionDivider('Local Network'),
          const SizedBox(height: 10),
          _buildLanToggle(),

          const SizedBox(height: 32),
          _sectionDivider('Censorship Resistance'),
          const SizedBox(height: 6),
          TorConfigSection(
            torEnabled: _torEnabled,
            bundledTorEnabled: _bundledTorEnabled,
            bundledTorLoading: _bundledTorLoading,
            preferredPt: _preferredPt,
            torHostController: _torHostController,
            torPortController: _torPortController,
            onTorEnabledChanged: (v) => setState(() => _torEnabled = v),
            onToggleBundledTor: _toggleBundledTor,
            onPreferredPtChanged: (val) async {
              setState(() => _preferredPt = val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('preferred_pt', val);
            },
            onOpenDiagnostics: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NetworkDiagnosticsScreen())),
          ),
          // I2P proxy settings — hidden when Built-in Tor is active
          if (!_bundledTorEnabled) ...[
            const SizedBox(height: 12),
            I2pConfigSection(
              i2pEnabled: _i2pEnabled,
              i2pHostController: _i2pHostController,
              i2pPortController: _i2pPortController,
              onI2pEnabledChanged: (v) => setState(() => _i2pEnabled = v),
            ),
          ],

          const SizedBox(height: 32),
          _sectionDivider('Appearance'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const ThemePickerWidget(),
          ),
          const SizedBox(height: 12),
          _settingRow(
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFF9B59B6),
            title: 'Theme Engine',
            subtitle: 'Customize colors & fonts',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DynamicThemeScreen())),
          ),
          const SizedBox(height: 12),
          _settingRow(
            icon: Icons.shield_rounded,
            iconColor: AppTheme.primary,
            title: 'Signal Protocol',
            subtitle: 'E2EE keys are stored securely',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('ACTIVE', style: GoogleFonts.inter(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          _settingRow(
            icon: Icons.backup_rounded,
            iconColor: const Color(0xFF2ECC71),
            title: 'Identity Backup',
            subtitle: 'Export or import your Signal identity',
            onTap: _showBackupOptions,
          ),
          const SizedBox(height: 12),
          _settingRow(
            icon: Icons.phonelink_rounded,
            iconColor: const Color(0xFF3498DB),
            title: 'Transfer to Another Device',
            subtitle: 'Move your identity via LAN or Nostr relay',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DeviceTransferScreen())),
          ),

          // ─── Security ─────────────────────────────────────────
          const SizedBox(height: 32),
          _sectionDivider('Security'),
          const SizedBox(height: 14),
          _buildSecuritySection(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Security section ──────────────────────────────────────────────────────

  Widget _buildSecuritySection() {
    return Column(
      children: [
        // App Password row
        GestureDetector(
          onTap: _passwordEnabled ? null : _enablePassword,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Color(0xFF60A5FA), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App Password',
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(
                      _passwordEnabled
                          ? 'Enabled — required on every launch'
                          : 'Disabled — app opens without password',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _passwordEnabled,
                onChanged: (val) =>
                    val ? _enablePassword() : _disablePassword(),
                activeThumbColor: const Color(0xFF60A5FA),
              ),
            ]),
          ),
        ),

        if (_passwordEnabled) ...[
          const SizedBox(height: 10),
          _settingRow(
            icon: Icons.password_rounded,
            iconColor: const Color(0xFF34D399),
            title: 'Change Password',
            subtitle: 'Update your app lock password',
            onTap: _changePassword,
          ),
          const SizedBox(height: 10),
          _settingRow(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF87171),
            title: _panicKeyEnabled ? 'Change Panic Key' : 'Set Panic Key',
            subtitle: _panicKeyEnabled
                ? 'Update emergency wipe key'
                : 'One key that instantly erases all data',
            onTap: _managePanicKey,
          ),
          if (_panicKeyEnabled) ...[
            const SizedBox(height: 10),
            _settingRow(
              icon: Icons.remove_circle_outline_rounded,
              iconColor: AppTheme.textSecondary,
              title: 'Remove Panic Key',
              subtitle: 'Disable emergency self-destruct',
              onTap: _removePanicKey,
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _enablePassword() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PasswordSetupDialog(
        onSet: (password) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(password, salt);
          await _secureStorage.write(key: 'app_password_hash', value: hash);
          await _secureStorage.write(key: 'app_password_salt', value: salt);
          await _secureStorage.write(
              key: 'app_password_enabled', value: 'true');
          if (ctx.mounted) Navigator.of(ctx).pop();
          if (mounted) setState(() => _passwordEnabled = true);
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
    // Offer panic key if password was just enabled
    if (_passwordEnabled && !_panicKeyEnabled) {
      await _managePanicKey();
    }
  }

  Future<void> _disablePassword() async {
    // Require current password confirmation before disabling
    final confirmed = await _showConfirmPasswordDialog(
        title: 'Disable App Password',
        subtitle: 'Enter your current password to confirm');
    if (!confirmed) return;

    await _secureStorage.delete(key: 'app_password_hash');
    await _secureStorage.delete(key: 'app_password_salt');
    await _secureStorage.delete(key: 'app_password_enabled');
    await _secureStorage.delete(key: 'app_panic_key_hash');
    await _secureStorage.delete(key: 'app_panic_key_salt');
    if (mounted) {
      setState(() {
        _passwordEnabled = false;
        _panicKeyEnabled = false;
      });
    }
  }

  Future<void> _changePassword() async {
    final confirmed = await _showConfirmPasswordDialog(
        title: 'Change Password',
        subtitle: 'Enter your current password to proceed');
    if (!confirmed) return;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PasswordSetupDialog(
        onSet: (password) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(password, salt);
          await _secureStorage.write(key: 'app_password_hash', value: hash);
          await _secureStorage.write(key: 'app_password_salt', value: salt);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFF34D399),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _managePanicKey() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PanicKeyDialog(
        onSet: (key) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(key, salt);
          await _secureStorage.write(key: 'app_panic_key_hash', value: hash);
          await _secureStorage.write(key: 'app_panic_key_salt', value: salt);
          if (ctx.mounted) Navigator.of(ctx).pop();
          if (mounted) setState(() => _panicKeyEnabled = true);
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _removePanicKey() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Remove Panic Key',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Emergency self-destruct will be disabled. '
          'You can re-enable it at any time.',
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style:
                    GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Remove',
                style: GoogleFonts.inter(
                    color: const Color(0xFFF87171),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _secureStorage.delete(key: 'app_panic_key_hash');
    await _secureStorage.delete(key: 'app_panic_key_salt');
    if (mounted) setState(() => _panicKeyEnabled = false);
  }

  /// Shows a dialog asking for the current password and returns true if correct.
  Future<bool> _showConfirmPasswordDialog(
      {required String title, required String subtitle}) async {
    final controller = TextEditingController();
    bool showPass = false;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(title,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: !showPass,
                autofocus: true,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Current password',
                  hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF60A5FA), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPass
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppTheme.textSecondary,
                        size: 18),
                    onPressed: () => setS(() => showPass = !showPass),
                  ),
                ),
                onChanged: (_) => setS(() => error = null),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style: GoogleFonts.inter(
                        color: const Color(0xFFF87171), fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style:
                      GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final hash =
                    await _secureStorage.read(key: 'app_password_hash');
                final salt =
                    await _secureStorage.read(key: 'app_password_salt');
                if (hash == null || salt == null) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                  return;
                }
                if (await PasswordHasher.verify(controller.text, salt, hash)) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  setS(() => error = 'Incorrect password');
                }
              },
              child: Text('Confirm',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF60A5FA),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result == true;
  }

  // ── Crypto helpers ────────────────────────────────────────────────────────

  String _generateSalt() {
    final rng = Random.secure();
    final saltBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    return hex.encode(saltBytes);
  }

  Widget _buildSecondaryInboxesSection() {
    return Column(
      children: [
        for (int i = 0; i < _secondaryAdapters.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _secondaryAdapters[i]['provider'] == 'Nostr'
                        ? Icons.bolt_rounded
                        : Icons.local_fire_department_rounded,
                    size: 16,
                    color: _secondaryAdapters[i]['provider'] == 'Nostr'
                        ? const Color(0xFF9B59B6)
                        : const Color(0xFFFFAB00),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _secondaryAdapters[i]['provider'] ?? '',
                          style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                        Text(
                          _secondaryAdapters[i]['selfId'] ??
                              _secondaryAdapters[i]['databaseId'] ?? '',
                          style: GoogleFonts.jetBrainsMono(
                              color: AppTheme.textSecondary, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final updated =
                          List<Map<String, String>>.from(_secondaryAdapters)
                            ..removeAt(i);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'secondary_adapters', jsonEncode(updated));
                      setState(() => _secondaryAdapters = updated);
                      await ChatController().reconnectInbox();
                      unawaited(ChatController().broadcastAddressUpdate());
                    },
                    child: Icon(Icons.close_rounded,
                        size: 18, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: _showAddSecondaryDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Add Secondary Inbox',
                    style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddSecondaryDialog() async {
    String provider = 'Firebase';
    final fbUrlCtrl = TextEditingController();
    final fbKeyCtrl = TextEditingController();
    final nostrRelayCtrl =
        TextEditingController(text: 'wss://relay.damus.io');
    final nostrKeyCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Secondary Inbox',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  for (final p in ['Firebase', 'Nostr']) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => provider = p),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: provider == p
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: provider == p
                                    ? AppTheme.primary
                                    : AppTheme.surfaceVariant),
                          ),
                          child: Center(
                            child: Text(p,
                                style: GoogleFonts.inter(
                                    color: provider == p
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    fontWeight: provider == p
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13)),
                          ),
                        ),
                      ),
                    ),
                    if (p != 'Nostr') const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 16),
                if (provider == 'Firebase') ...[
                  _field(
                      controller: fbUrlCtrl,
                      hint: 'https://project.firebaseio.com',
                      label: 'Database URL',
                      icon: Icons.link_rounded),
                  const SizedBox(height: 10),
                  _field(
                      controller: fbKeyCtrl,
                      hint: 'Optional',
                      label: 'Web API Key',
                      icon: Icons.key_rounded,
                      obscure: true),
                ] else ...[
                  _field(
                      controller: nostrRelayCtrl,
                      hint: 'wss://relay.damus.io',
                      label: 'Relay URL',
                      icon: Icons.bolt_rounded),
                  const SizedBox(height: 10),
                  _field(
                      controller: nostrKeyCtrl,
                      hint: 'nsec1... or hex',
                      label: 'Private Key',
                      icon: Icons.vpn_key_rounded,
                      obscure: true),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style:
                      GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;
                final currentRaw =
                    prefs.getString('secondary_adapters') ?? '[]';
                List<dynamic> current;
                try {
                  current = jsonDecode(currentRaw);
                } catch (_) {
                  current = [];
                }
                Map<String, String> newEntry;
                if (provider == 'Firebase') {
                  final url = fbUrlCtrl.text.trim();
                  if (url.isEmpty) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final key = fbKeyCtrl.text.trim();
                  final identity = ChatController().identity;
                  final userId =
                      identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
                  final selfId = userId.isNotEmpty ? '$userId@$url' : url;
                  final apiKey = jsonEncode({'url': url, 'key': key});
                  newEntry = {
                    'provider': 'Firebase',
                    'databaseId': userId,
                    'selfId': selfId,
                    'apiKey': apiKey,
                  };
                } else {
                  final relay = nostrRelayCtrl.text.trim();
                  if (relay.isEmpty) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final privkey = nostrKeyCtrl.text.trim();
                  if (privkey.isNotEmpty) {
                    final keySuffix = relay
                        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
                    await _secureStorage.write(
                        key: 'secondary_nostr_privkey_$keySuffix',
                        value: privkey);
                  }
                  String selfId = '';
                  try {
                    if (privkey.isNotEmpty) {
                      final pubkey = deriveNostrPubkeyHex(privkey);
                      selfId = '$pubkey@$relay';
                    }
                  } catch (_) {}
                  newEntry = {
                    'provider': 'Nostr',
                    'databaseId': relay,
                    'selfId': selfId,
                  };
                }
                current.add(newEntry);
                await prefs.setString(
                    'secondary_adapters', jsonEncode(current));
                final updated = await _loadSecondaryAdaptersFromPrefs();
                setState(() => _secondaryAdapters = updated);
                await ChatController().reconnectInbox();
                unawaited(ChatController().broadcastAddressUpdate());
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Add',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    fbUrlCtrl.dispose();
    fbKeyCtrl.dispose();
    nostrRelayCtrl.dispose();
    nostrKeyCtrl.dispose();
  }

  Future<void> _showBackupOptions() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Identity Backup',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
            'Export your Signal identity keys to a backup code, or restore from an existing one.',
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportIdentity();
            },
            child: Text('Export',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _importIdentity();
            },
            child: Text('Import',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportIdentity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, String>{};
      for (final key in [
        'signal_id_key',
        'signal_reg_id',
        'signal_signed_prekey_0',
        'signal_prekeys_generated',
        'nostr_privkey',
      ]) {
        final val = await _secureStorage.read(key: key);
        if (val != null && val.isNotEmpty) data[key] = val;
      }
      final userIdentity = prefs.getString('user_identity');
      if (userIdentity != null) data['user_identity'] = userIdentity;
      final contacts = prefs.getString('contacts');
      if (contacts != null) data['contacts'] = contacts;

      final b64 = base64.encode(utf8.encode(jsonEncode(data)));

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text('Export Identity',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Copy this backup code and store it safely:',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  b64,
                  style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textPrimary, fontSize: 9),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: b64));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Backup copied to clipboard',
                      style: GoogleFonts.inter()),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              },
              child: Text('Copy',
                  style: GoogleFonts.inter(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final dir = await getDownloadsDirectory();
                  final path =
                      '${dir?.path ?? '/tmp'}/messenger_identity_backup.txt';
                  await File(path).writeAsString(b64);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('Saved to $path',
                          style: GoogleFonts.inter()),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('Save failed: $e',
                          style: GoogleFonts.inter()),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                }
              },
              child: Text('Save File',
                  style: GoogleFonts.inter(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Done',
                  style:
                      GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _importIdentity() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Import Identity',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Paste your backup code below. This will overwrite your current identity.',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: 10),
              decoration: InputDecoration(
                hintText: 'Paste backup code here…',
                hintStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final b64 = ctrl.text.trim();
                final jsonStr = utf8.decode(base64.decode(b64));
                final data = jsonDecode(jsonStr) as Map<String, dynamic>;
                for (final key in [
                  'signal_id_key',
                  'signal_reg_id',
                  'signal_signed_prekey_0',
                  'signal_prekeys_generated',
                  'nostr_privkey',
                ]) {
                  if (data.containsKey(key)) {
                    await _secureStorage.write(
                        key: key, value: data[key] as String);
                  }
                }
                final prefs2 = await SharedPreferences.getInstance();
                if (data.containsKey('user_identity')) {
                  await prefs2.setString(
                      'user_identity', data['user_identity'] as String);
                }
                if (data.containsKey('contacts')) {
                  await prefs2.setString('contacts', data['contacts'] as String);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Identity + contacts imported! Restart the app to apply.',
                        style: GoogleFonts.inter()),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Import failed: $e',
                        style: GoogleFonts.inter()),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Apply',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<void> _discoverWakuNodes() async {
    setState(() {
      _wakuDiscovering = true;
      _wakuNodes = null;
    });
    await WakuDiscoveryService.instance.clearCache();
    final nodes = await WakuDiscoveryService.instance.probeAll();
    if (!mounted) return;
    setState(() {
      _wakuDiscovering = false;
      _wakuNodes = nodes;
      // Auto-select best online node if field is empty
      if (_wakuNodeUrlController.text.trim().isEmpty) {
        final best = nodes.firstWhere((n) => n.online,
            orElse: () => nodes.first);
        if (best.online) _wakuNodeUrlController.text = best.url;
      }
    });
  }

  /// Builds a `pulse://add?cfg=<base64(json)>` invite link for [address].
  String _buildInviteLink(String address, String name) {
    final payload = jsonEncode({'a': address, 'n': name});
    final cfg = base64Encode(utf8.encode(payload));
    return 'pulse://add?cfg=$cfg';
  }

  void _showMyQrDialog() {
    final identity = ChatController().identity;
    final dbId = identity?.adapterConfig['dbId'];
    final selfId = (dbId is String ? dbId : null) ?? identity?.id ?? '';
    if (selfId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No address yet — save settings first'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // name loaded below via StatefulBuilder
    showDialog(
      context: context,
      builder: (ctx) {
        String? myName;
        SharedPreferences.getInstance().then((p) {
          try {
            final profile = jsonDecode(p.getString('user_profile') ?? '{}');
            myName = (profile['name'] as String?) ?? '';
          } catch (_) {}
        });

        final inviteLink = _buildInviteLink(selfId, myName ?? '');

        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Share My Address',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR code
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: QrImageView(data: inviteLink, size: 220),
                ),
                const SizedBox(height: 16),

                // Invite link box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invite Link',
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      SelectableText(
                        inviteLink,
                        style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.textPrimary, fontSize: 10),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Raw address box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Raw Address',
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      SelectableText(
                        selfId,
                        style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.textPrimary, fontSize: 10),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteLink));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Invite link copied',
                      style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: AppTheme.primary,
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Text('Copy Link',
                  style: GoogleFonts.inter(color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: selfId));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Address copied',
                      style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: AppTheme.primary,
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Text('Copy Address',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close',
                  style:
                      GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleBundledTor() async {
    if (_bundledTorLoading) return;
    final prefs = await SharedPreferences.getInstance();
    if (_bundledTorEnabled) {
      // Turn off
      await TorService.instance.stop();
      setState(() => _bundledTorEnabled = false);
      await prefs.setBool('bundled_tor_enabled', false);
    } else {
      // Turn on
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
            const SnackBar(content: Text('Built-in Tor failed to start')),
          );
        }
      }
    }
  }

  Widget _buildLanToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_rounded, color: Color(0xFF25D366), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LAN Fallback',
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Broadcast presence and deliver messages on the local network when internet is unavailable. '
                  'Disable on untrusted networks (public Wi-Fi).',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: _lanModeEnabled,
            activeThumbColor: const Color(0xFF25D366),
            onChanged: (v) async {
              setState(() => _lanModeEnabled = v);
              await ChatController().setLanModeEnabled(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChips() {
    const providers = [
      (name: 'Firebase', icon: Icons.local_fire_department_rounded, color: Color(0xFFFFAB00)),
      (name: 'Nostr', icon: Icons.bolt_rounded, color: Color(0xFF9B59B6)),
      (name: 'Waku', icon: Icons.hub_rounded, color: Color(0xFF00BCD4)),
      (name: 'Oxen', icon: Icons.security_rounded, color: Color(0xFF00695C)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in providers)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 40 - 24) / 4,
            child: _providerChip(p.name, p.icon, p.color),
          ),
      ],
    );
  }

  Widget _providerChip(String name, IconData icon, Color color) {
    final selected = _selectedProvider == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedProvider = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : AppTheme.surfaceVariant,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? color : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              _shortName(name),
              style: GoogleFonts.inter(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderConfig() {
    if (_selectedProvider == 'Firebase') {
      return Column(children: [
        _field(controller: _firebaseUrlController, hint: 'https://project.firebaseio.com', label: 'Database URL', icon: Icons.link_rounded),
        const SizedBox(height: 12),
        _field(controller: _firebaseKeyController, hint: 'Optional for public DB', label: 'Web API Key', icon: Icons.key_rounded, obscure: true),
      ]);
    } else if (_selectedProvider == 'Nostr') {
      return Column(children: [
        _field(controller: _nostrRelayController, hint: 'wss://relay.damus.io', label: 'Relay URL', icon: Icons.bolt_rounded),
        const SizedBox(height: 12),
        _field(controller: _nostrKeyController, hint: 'nsec1... or hex private key', label: 'Private Key (nsec)', icon: Icons.vpn_key_rounded, obscure: true),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text('Your key is stored locally in secure storage — never sent to any server.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11))),
        ]),
      ]);
    } else if (_selectedProvider == 'Waku') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // URL field + Discover button
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: _field(
              controller: _wakuNodeUrlController,
              hint: 'Leave empty for auto-discovery',
              label: 'nwaku Node URL (optional)',
              icon: Icons.hub_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Probe all known public nodes',
            child: SizedBox(
              height: 48,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4).withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: _wakuDiscovering ? null : _discoverWakuNodes,
                child: _wakuDiscovering
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BCD4)),
                      )
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.radar_rounded, size: 16, color: Color(0xFF00BCD4)),
                        const SizedBox(width: 6),
                        Text('Discover',
                            style: GoogleFonts.inter(
                                color: const Color(0xFF00BCD4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),

        // Discovery results
        if (_wakuNodes != null) ...[
          ..._wakuNodes!.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: InkWell(
              onTap: n.online
                  ? () => setState(() => _wakuNodeUrlController.text = n.url)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: _wakuNodeUrlController.text == n.url
                      ? Border.all(color: const Color(0xFF00BCD4), width: 1.5)
                      : null,
                ),
                child: Row(children: [
                  Icon(
                    n.online ? Icons.circle : Icons.circle_outlined,
                    size: 8,
                    color: n.online ? const Color(0xFF4CAF50) : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(n.label,
                        style: GoogleFonts.jetBrainsMono(
                            color: n.online ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontSize: 11)),
                  ),
                  Text(n.latencyLabel,
                      style: GoogleFonts.inter(
                          color: n.online ? const Color(0xFF4CAF50) : AppTheme.textSecondary,
                          fontSize: 11)),
                  if (n.online) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 10, color: AppTheme.textSecondary),
                  ],
                ]),
              ),
            ),
          )),
          const SizedBox(height: 4),
        ],

        Row(children: [
          Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Leave URL empty to auto-discover the fastest public node. '
              'Or run nwaku locally (port 8645) for maximum privacy.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
        ]),
      ]);
    } else if (_selectedProvider == 'Oxen') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field(
          controller: _oxenNodeUrlController,
          hint: 'Leave empty for built-in seed nodes',
          label: 'Storage Node URL (optional)',
          icon: Icons.security_rounded,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 13, color: const Color(0xFF00695C)),
          const SizedBox(width: 6),
          Expanded(child: Text(
            'Oxen/Session network — onion-routed E2EE. '
            'Your Session ID is auto-generated and stored securely. '
            'Leave the node URL empty to use built-in community nodes.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
          )),
        ]),
        const SizedBox(height: 8),
        // Show own Session ID if available
        Builder(builder: (ctx) {
          final sessionId = ChatController().myAddress;
          if (sessionId.startsWith('05') && sessionId.length == 66) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00695C).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00695C).withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.fingerprint_rounded, size: 14, color: Color(0xFF00695C)),
                const SizedBox(width: 8),
                Expanded(child: Text(sessionId,
                    style: GoogleFonts.robotoMono(
                        color: const Color(0xFF00695C), fontSize: 10))),
              ]),
            );
          }
          return const SizedBox.shrink();
        }),
      ]);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _field({required TextEditingController controller, required String hint,
      required String label, required IconData icon, bool obscure = false}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 0.8));
  }

  Widget _sectionDivider(String label) {
    return Row(children: [
      Text(label.toUpperCase(),
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: AppTheme.surfaceVariant, thickness: 1)),
    ]);
  }

  Widget _settingRow({required IconData icon, required Color iconColor, required String title,
      required String subtitle, VoidCallback? onTap, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              ]),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  String _shortName(String provider) => provider;
}
