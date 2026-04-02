import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/theme_manager.dart';
import '../l10n/l10n_ext.dart';
import 'settings/profile_section.dart';
import 'settings/network_section.dart';
import 'settings/appearance_identity_section.dart';
import 'settings/language_section.dart';
import 'settings/data_section.dart';
import 'settings/security_section.dart';
import 'settings/about_section.dart';
import 'settings/developer_section.dart';

// Re-export for backward compatibility — InboxAddressCard is defined in profile_card.dart
export '../widgets/profile_card.dart' show InboxAddressCard;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _secureStorage = FlutterSecureStorage();

  bool _passwordEnabled = false;
  bool _panicKeyEnabled = false;
  bool _devModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final passwordEnabled =
        await _secureStorage.read(key: 'app_password_enabled') == 'true';
    final panicKeyEnabled =
        (await _secureStorage.read(key: 'app_panic_key_hash')) != null;
    final prefs = await SharedPreferences.getInstance();
    final devMode = prefs.getBool('dev_mode_enabled') ?? false;
    if (!mounted) return;
    setState(() {
      _passwordEnabled = passwordEnabled;
      _panicKeyEnabled = panicKeyEnabled;
      _devModeEnabled = devMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          // ─── Profile ───────────────────────────────────────────
          ProfileSection(),
          const SizedBox(height: 28),

          // ─── Network (Provider, TURN, Proxy, LAN, BG) ─────────
          const NetworkSection(),
          const SizedBox(height: 32),

          // ─── Language ──────────────────────────────────────────
          const LanguageSection(),
          const SizedBox(height: 12),

          // ─── Appearance ────────────────────────────────────────
          const AppearanceIdentitySection(),
          const SizedBox(height: 32),

          // ─── Security ──────────────────────────────────────────
          SecuritySection(
            passwordEnabled: _passwordEnabled,
            panicKeyEnabled: _panicKeyEnabled,
            onPasswordEnabledChanged: (v) =>
                setState(() => _passwordEnabled = v),
            onPanicKeyEnabledChanged: (v) =>
                setState(() => _panicKeyEnabled = v),
          ),
          const SizedBox(height: 32),

          // ─── Data ──────────────────────────────────────────────
          const DataSection(),
          const SizedBox(height: 32),

          // ─── About ─────────────────────────────────────────────
          AboutSection(onDevModeUnlocked: () => setState(() => _devModeEnabled = true)),
          const SizedBox(height: 12),

          // ─── Developer (hidden until unlocked) ─────────────────
          if (_devModeEnabled) ...[
            const SizedBox(height: 20),
            const DeveloperSection(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
