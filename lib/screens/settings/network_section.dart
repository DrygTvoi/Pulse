// Settings — Network section: 3 tap-rows + 2 inline toggles.
// All state is self-contained; no params needed from settings_screen.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/chat_controller.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/background_service.dart';
import '../../services/tor_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import 'settings_widgets.dart';
import 'provider_screen.dart';
import 'proxy_tunnels_screen.dart';
import 'turn_screen.dart';

class NetworkSection extends StatefulWidget {
  const NetworkSection({super.key});

  @override
  State<NetworkSection> createState() => _NetworkSectionState();
}

class _NetworkSectionState extends State<NetworkSection> {
  bool _lanModeEnabled = true;
  bool _bgServiceEnabled = false;
  String _currentProvider = 'Firebase';


  @override
  void initState() {
    super.initState();
    _load();
    TorService.instance.stateChanges.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lan = await ChatController.getLanModeEnabled();
    final bg = await BackgroundService.instance.isEnabled();
    final provider = prefs.getString('byod_provider') ?? 'Firebase';
    if (!mounted) return;
    setState(() {
      _lanModeEnabled = lan;
      _bgServiceEnabled = bg;
      _currentProvider = provider;
    });
  }

  String _proxySubtitle() {
    if (TorService.instance.isRunning) return 'Tor';
    return '';
  }

  Widget _buildToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    height: 1.4)),
          ]),
        ),
        const SizedBox(width: 10),
        Switch.adaptive(
          value: value,
          activeThumbColor: iconColor,
          onChanged: onChanged,
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsNetwork),
        const SizedBox(height: 14),

        // ── Provider ──────────────────────────────────────────
        settingsRow(
          icon: Icons.swap_horiz_rounded,
          iconColor: const Color(0xFFFFAB00),
          title: context.l10n.settingsProviderTitle,
          subtitle: _currentProvider,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProviderScreen()),
            );
            // Refresh provider label after returning
            final prefs = await SharedPreferences.getInstance();
            if (mounted) {
              setState(() => _currentProvider =
                  prefs.getString('byod_provider') ?? 'Firebase');
            }
          },
        ),
        const SizedBox(height: 12),

        // ── TURN ──────────────────────────────────────────────
        settingsRow(
          icon: Icons.phone_in_talk_rounded,
          iconColor: const Color(0xFF3498DB),
          title: context.l10n.settingsTurnServers,
          subtitle: '',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TurnScreen()),
          ),
        ),
        const SizedBox(height: 12),

        // ── Proxy & Tunnels ───────────────────────────────────
        settingsRow(
          icon: Icons.vpn_lock_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: context.l10n.settingsProxyTunnels,
          subtitle: _proxySubtitle(),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ProxyTunnelsScreen()),
            );
            if (mounted) setState(() {});
          },
        ),
        const SizedBox(height: 12),

        // ── LAN toggle ────────────────────────────────────────
        _buildToggle(
          icon: Icons.wifi_rounded,
          iconColor: const Color(0xFF25D366),
          title: context.l10n.settingsLanFallback,
          subtitle: context.l10n.settingsLanFallbackSubtitle,
          value: _lanModeEnabled,
          onChanged: (v) async {
            setState(() => _lanModeEnabled = v);
            await ChatController().setLanModeEnabled(v);
          },
        ),

        // ── Background service (Android only) ─────────────────
        if (Platform.isAndroid) ...[
          const SizedBox(height: 12),
          _buildToggle(
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFF3498DB),
            title: context.l10n.settingsBgDelivery,
            subtitle: context.l10n.settingsBgDeliverySubtitle,
            value: _bgServiceEnabled,
            onChanged: (v) async {
              setState(() => _bgServiceEnabled = v);
              await BackgroundService.instance.setEnabled(v);
            },
          ),
        ],

      ],
    );
  }

}
