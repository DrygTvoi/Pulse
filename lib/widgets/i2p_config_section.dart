import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Extracted I2P configuration section from SettingsScreen.
/// Displays the I2P info banner, toggle, and SOCKS5 host/port fields.
class I2pConfigSection extends StatelessWidget {
  const I2pConfigSection({
    super.key,
    required this.i2pEnabled,
    required this.i2pHostController,
    required this.i2pPortController,
    required this.onI2pEnabledChanged,
  });

  final bool i2pEnabled;
  final TextEditingController i2pHostController;
  final TextEditingController i2pPortController;
  final ValueChanged<bool> onI2pEnabledChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildI2pInfo(),
        const SizedBox(height: 14),
        _sectionLabel('I2P Proxy (SOCKS5)'),
        const SizedBox(height: 10),
        _buildI2pSettings(),
      ],
    );
  }

  Widget _buildI2pInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.vpn_lock_rounded, size: 15, color: Color(0xFF00897B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'I2P uses SOCKS5 on port 4447 by default. Connect to a Nostr relay via '
              'I2P outproxy (e.g. relay.damus.i2p) to communicate with users on any transport. '
              'Tor takes priority when both are enabled.',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildI2pSettings() {
    const teal = Color(0xFF00897B);
    return Column(
      children: [
        GestureDetector(
          onTap: () => onI2pEnabledChanged(!i2pEnabled),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: i2pEnabled
                  ? teal.withValues(alpha: 0.08)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: i2pEnabled
                    ? teal.withValues(alpha: 0.4)
                    : AppTheme.surfaceVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.vpn_lock_rounded, color: teal, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route Nostr via I2P',
                          style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text(
                          i2pEnabled ? 'Active \u2014 Nostr traffic routed through I2P' : 'Disabled',
                          style: GoogleFonts.inter(
                              color: i2pEnabled ? teal : AppTheme.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: i2pEnabled,
                  onChanged: (v) => onI2pEnabledChanged(v),
                  activeThumbColor: teal,
                ),
              ],
            ),
          ),
        ),
        if (i2pEnabled) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _field(
                  controller: i2pHostController,
                  hint: '127.0.0.1',
                  label: 'Proxy Host',
                  icon: Icons.router_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: _field(
                  controller: i2pPortController,
                  hint: '4447',
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
                'I2P Router default SOCKS5 port: 4447',
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
