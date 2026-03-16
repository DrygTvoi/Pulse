import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/tor_service.dart';

/// Extracted Tor/censorship-resistance configuration section from SettingsScreen.
/// Displays bundled Tor card, diagnostics button, PT selector, and manual SOCKS5 proxy fields.
class TorConfigSection extends StatelessWidget {
  const TorConfigSection({
    super.key,
    required this.torEnabled,
    required this.bundledTorEnabled,
    required this.bundledTorLoading,
    required this.preferredPt,
    required this.torHostController,
    required this.torPortController,
    required this.onTorEnabledChanged,
    required this.onToggleBundledTor,
    required this.onPreferredPtChanged,
    required this.onOpenDiagnostics,
  });

  final bool torEnabled;
  final bool bundledTorEnabled;
  final bool bundledTorLoading;
  final String preferredPt;
  final TextEditingController torHostController;
  final TextEditingController torPortController;
  final ValueChanged<bool> onTorEnabledChanged;
  final VoidCallback onToggleBundledTor;
  final ValueChanged<String> onPreferredPtChanged;
  final VoidCallback onOpenDiagnostics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBundledTorCard(),
        const SizedBox(height: 8),
        _buildDiagnosticsButton(),
        // Manual Tor proxy settings -- hidden when Built-in Tor is active
        if (!bundledTorEnabled) ...[
          const SizedBox(height: 14),
          _buildTorInfo(),
          const SizedBox(height: 14),
          _sectionLabel('Tor Proxy (SOCKS5)'),
          const SizedBox(height: 10),
          _buildTorSettings(),
        ],
      ],
    );
  }

  Widget _buildBundledTorCard() {
    const purple = Color(0xFF7D4698);
    final tor = TorService.instance;
    final isConnected = tor.isBootstrapped;
    final isConnecting = tor.isRunning && !tor.isBootstrapped;
    final pct = tor.bootstrapPercent;

    String subtitle;
    Color subtitleColor;
    if (isConnected) {
      subtitle = 'Connected \u2014 Nostr routed via 127.0.0.1:9250';
      subtitleColor = purple;
    } else if (isConnecting) {
      subtitle = 'Connecting\u2026 $pct%';
      subtitleColor = purple.withValues(alpha: 0.7);
    } else if (bundledTorEnabled) {
      subtitle = 'Not running \u2014 tap switch to restart';
      subtitleColor = AppTheme.textSecondary;
    } else {
      subtitle = 'Routes Nostr via Tor (Snowflake for censored networks)';
      subtitleColor = AppTheme.textSecondary;
    }

    final active = bundledTorEnabled;
    return GestureDetector(
      onTap: bundledTorLoading ? null : onToggleBundledTor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? purple.withValues(alpha: 0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? purple.withValues(alpha: 0.4)
                : AppTheme.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub_rounded, color: purple, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Built-in Tor',
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: subtitleColor, fontSize: 12)),
                  if (active) ...[
                    const SizedBox(height: 8),
                    _buildPtSelector(purple),
                  ],
                ],
              ),
            ),
            if (bundledTorLoading || isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(purple)),
              )
            else
              Switch(
                value: active,
                onChanged: (_) => onToggleBundledTor(),
                activeThumbColor: purple,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticsButton() {
    return GestureDetector(
      onTap: onOpenDiagnostics,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.speed_rounded,
                color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text('Network Diagnostics',
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 13)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPtSelector(Color purple) {
    const items = [
      ('auto',      'Auto'),
      ('obfs4',     'obfs4'),
      ('webtunnel', 'WebTunnel'),
      ('snowflake', 'Snowflake'),
      ('plain',     'Plain'),
    ];
    return Row(
      children: [
        Text('Transport: ',
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary, fontSize: 11)),
        ...items.map((e) {
          final (val, label) = e;
          final selected = preferredPt == val;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => onPreferredPtChanged(val),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? purple.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? purple.withValues(alpha: 0.5)
                        : AppTheme.surfaceVariant,
                  ),
                ),
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: selected ? purple : AppTheme.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTorInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF7D4698).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7D4698).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.privacy_tip_rounded, size: 15, color: Color(0xFF7D4698)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'When enabled, Nostr WebSocket connections are routed through Tor '
              '(SOCKS5). Tor Browser listens on 127.0.0.1:9150. '
              'The standalone tor daemon uses port 9050. '
              'Firebase connections are not affected.',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorSettings() {
    const purple = Color(0xFF7D4698);
    final managedByBundled = bundledTorEnabled;
    return Column(
      children: [
        // Toggle row
        GestureDetector(
          onTap: managedByBundled ? null : () => onTorEnabledChanged(!torEnabled),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: torEnabled
                  ? purple.withValues(alpha: 0.08)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: torEnabled
                    ? purple.withValues(alpha: 0.4)
                    : AppTheme.surfaceVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.security_rounded,
                      color: purple, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route Nostr via Tor',
                          style: GoogleFonts.inter(
                              color: managedByBundled
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text(
                          managedByBundled
                              ? 'Managed by Built-in Tor'
                              : (torEnabled ? 'Active \u2014 Nostr traffic routed through Tor' : 'Disabled'),
                          style: GoogleFonts.inter(
                              color: torEnabled
                                  ? purple
                                  : AppTheme.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: torEnabled,
                  onChanged: managedByBundled ? null : (v) => onTorEnabledChanged(v),
                  activeThumbColor: purple,
                ),
              ],
            ),
          ),
        ),
        if (torEnabled) ...[
          const SizedBox(height: 10),
          if (managedByBundled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.surfaceVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text('127.0.0.1 : 9250',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _field(
                    controller: torHostController,
                    hint: '127.0.0.1',
                    label: 'Proxy Host',
                    icon: Icons.router_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _field(
                    controller: torPortController,
                    hint: '9050',
                    label: 'Port',
                    icon: Icons.electrical_services_rounded,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.info_outline_rounded,
                size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Tor Browser: port 9150  \u2022  tor daemon: port 9050',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
          ]),
        ],
      ],
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 0.8));
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
}
