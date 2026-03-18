// Settings — Network section: Calls/TURN, LAN, background service,
// censorship resistance (Tor, custom proxy, I2P).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/chat_controller.dart';
import '../../services/background_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/turn_config_section.dart';
import '../../widgets/tor_config_section.dart';
import '../../widgets/i2p_config_section.dart';
import '../../widgets/custom_proxy_section.dart';
import '../../widgets/psiphon_config_section.dart';
import '../network_diagnostics_screen.dart';
import 'settings_widgets.dart';

class NetworkSection extends StatelessWidget {
  final List<String> enabledPresets;
  final TextEditingController turnUrlController;
  final TextEditingController turnUsernameController;
  final TextEditingController turnPasswordController;
  final ValueChanged<List<String>> onPresetsChanged;

  final bool lanModeEnabled;
  final ValueChanged<bool> onLanModeChanged;

  final bool bgServiceEnabled;
  final ValueChanged<bool> onBgServiceChanged;

  final bool torEnabled;
  final bool bundledTorEnabled;
  final bool bundledTorLoading;
  final String preferredPt;
  final TextEditingController torHostController;
  final TextEditingController torPortController;
  final ValueChanged<bool> onTorEnabledChanged;
  final VoidCallback onToggleBundledTor;
  final ValueChanged<String> onPreferredPtChanged;

  final bool customProxyEnabled;
  final TextEditingController customProxyHostController;
  final TextEditingController customProxyPortController;
  final ValueChanged<bool> onCustomProxyEnabledChanged;
  final TextEditingController cfWorkerRelayController;

  final bool psiphonEnabled;
  final bool psiphonLoading;
  final VoidCallback onTogglePsiphon;

  final bool i2pEnabled;
  final TextEditingController i2pHostController;
  final TextEditingController i2pPortController;
  final ValueChanged<bool> onI2pEnabledChanged;

  const NetworkSection({
    super.key,
    required this.enabledPresets,
    required this.turnUrlController,
    required this.turnUsernameController,
    required this.turnPasswordController,
    required this.onPresetsChanged,
    required this.lanModeEnabled,
    required this.onLanModeChanged,
    required this.bgServiceEnabled,
    required this.onBgServiceChanged,
    required this.torEnabled,
    required this.bundledTorEnabled,
    required this.bundledTorLoading,
    required this.preferredPt,
    required this.torHostController,
    required this.torPortController,
    required this.onTorEnabledChanged,
    required this.onToggleBundledTor,
    required this.onPreferredPtChanged,
    required this.customProxyEnabled,
    required this.customProxyHostController,
    required this.customProxyPortController,
    required this.onCustomProxyEnabledChanged,
    required this.cfWorkerRelayController,
    required this.psiphonEnabled,
    required this.psiphonLoading,
    required this.onTogglePsiphon,
    required this.i2pEnabled,
    required this.i2pHostController,
    required this.i2pPortController,
    required this.onI2pEnabledChanged,
  });

  Widget _buildLanToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_rounded,
              color: Color(0xFF25D366), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAN Fallback',
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Broadcast presence and deliver messages on the local network when internet is unavailable. '
                  'Disable on untrusted networks (public Wi-Fi).',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: lanModeEnabled,
            activeThumbColor: const Color(0xFF25D366),
            onChanged: (v) async {
              onLanModeChanged(v);
              await ChatController().setLanModeEnabled(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBgServiceToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: Color(0xFF3498DB), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Background Delivery',
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep receiving messages when the app is minimized. '
                  'Shows a persistent notification.',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: bgServiceEnabled,
            activeThumbColor: const Color(0xFF3498DB),
            onChanged: (v) async {
              onBgServiceChanged(v);
              await BackgroundService.instance.setEnabled(v);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Calls & TURN ─────────────────────────────────────
        settingsSectionDivider('Calls & TURN'),
        const SizedBox(height: 6),
        TurnConfigSection(
          enabledPresets: enabledPresets,
          turnUrlController: turnUrlController,
          turnUsernameController: turnUsernameController,
          turnPasswordController: turnPasswordController,
          onPresetsChanged: onPresetsChanged,
        ),

        const SizedBox(height: 32),

        // ─── Local Network ────────────────────────────────────
        settingsSectionDivider('Local Network'),
        const SizedBox(height: 10),
        _buildLanToggle(context),
        if (Platform.isAndroid) ...[
          const SizedBox(height: 12),
          _buildBgServiceToggle(context),
        ],

        const SizedBox(height: 32),

        // ─── Censorship Resistance ────────────────────────────
        settingsSectionDivider('Censorship Resistance'),
        const SizedBox(height: 6),
        TorConfigSection(
          torEnabled: torEnabled,
          bundledTorEnabled: bundledTorEnabled,
          bundledTorLoading: bundledTorLoading,
          preferredPt: preferredPt,
          torHostController: torHostController,
          torPortController: torPortController,
          onTorEnabledChanged: onTorEnabledChanged,
          onToggleBundledTor: onToggleBundledTor,
          onPreferredPtChanged: (val) async {
            onPreferredPtChanged(val);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('preferred_pt', val);
          },
          onOpenDiagnostics: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const NetworkDiagnosticsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        PsiphonConfigSection(
          psiphonEnabled: psiphonEnabled,
          psiphonLoading: psiphonLoading,
          onToggle: onTogglePsiphon,
        ),
        const SizedBox(height: 12),
        CustomProxySection(
          proxyEnabled: customProxyEnabled,
          proxyHostController: customProxyHostController,
          proxyPortController: customProxyPortController,
          onProxyEnabledChanged: onCustomProxyEnabledChanged,
          workerRelayController: cfWorkerRelayController,
        ),
        if (!bundledTorEnabled) ...[
          const SizedBox(height: 12),
          I2pConfigSection(
            i2pEnabled: i2pEnabled,
            i2pHostController: i2pHostController,
            i2pPortController: i2pPortController,
            onI2pEnabledChanged: onI2pEnabledChanged,
          ),
        ],
      ],
    );
  }
}
