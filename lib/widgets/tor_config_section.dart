import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/tor_service.dart';
import '../l10n/l10n_ext.dart';

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
    this.torTimeoutSec = 60,
    this.onTorTimeoutChanged,
    this.forceNostrTor = false,
    this.onForceNostrTorChanged,
    this.forcePulseTor = false,
    this.onForcePulseTorChanged,
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
  final int torTimeoutSec;
  final ValueChanged<int>? onTorTimeoutChanged;
  final bool forceNostrTor;
  final ValueChanged<bool>? onForceNostrTorChanged;
  final bool forcePulseTor;
  final ValueChanged<bool>? onForcePulseTorChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBundledTorCard(context),
        const SizedBox(height: 8),
        _buildForceNostrTorCard(context),
        const SizedBox(height: 8),
        _buildForcePulseTorCard(context),
        const SizedBox(height: 8),
        _buildDiagnosticsButton(context),
        // Manual Tor proxy settings -- hidden when Built-in Tor is active
        if (!bundledTorEnabled) ...[
          const SizedBox(height: 14),
          _buildTorInfo(context),
          const SizedBox(height: 14),
          _sectionLabel(context.l10n.torProxySocks5),
          const SizedBox(height: 10),
          _buildTorSettings(context),
        ],
      ],
    );
  }

  Widget _buildBundledTorCard(BuildContext context) {
    const purple = Color(0xFF7D4698);
    final tor = TorService.instance;
    final isConnected = tor.isBootstrapped;
    final isConnecting = tor.isRunning && !tor.isBootstrapped;
    final pct = tor.bootstrapPercent;
    final l = context.l10n;

    String subtitle;
    Color subtitleColor;
    if (isConnected) {
      subtitle = l.torConnectedSubtitle;
      subtitleColor = purple;
    } else if (isConnecting) {
      subtitle = l.torConnectingSubtitle(pct);
      subtitleColor = purple.withValues(alpha: 0.7);
    } else if (bundledTorEnabled) {
      subtitle = l.torNotRunning;
      subtitleColor = AppTheme.textSecondary;
    } else {
      subtitle = l.torDescription;
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
                  Text(l.torBuiltInTitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: subtitleColor, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildPtSelector(context, purple),
                  const SizedBox(height: 6),
                  _buildTimeoutRow(context, purple),
                ],
              ),
            ),
            if (bundledTorLoading || isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: purple),
              )
            else
              Switch.adaptive(
                value: active,
                onChanged: (_) => onToggleBundledTor(),
                activeThumbColor: purple,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForceNostrTorCard(BuildContext context) {
    const purple = Color(0xFF7D4698);
    final torActive = bundledTorEnabled || torEnabled;
    final enabled = torActive && onForceNostrTorChanged != null;
    final l = context.l10n;

    return GestureDetector(
      onTap: enabled ? () => onForceNostrTorChanged!(!forceNostrTor) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: forceNostrTor && enabled
                ? purple.withValues(alpha: 0.08)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: forceNostrTor && enabled
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
                child: const Icon(Icons.shield_rounded, color: purple, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.torForceNostrTitle,
                        style: GoogleFonts.inter(
                            color: enabled
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(
                        enabled
                            ? l.torForceNostrSubtitle
                            : l.torForceNostrDisabled,
                        style: GoogleFonts.inter(
                            color: forceNostrTor && enabled
                                ? purple
                                : AppTheme.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: forceNostrTor && enabled,
                onChanged: enabled
                    ? (v) => onForceNostrTorChanged!(v)
                    : null,
                activeThumbColor: purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForcePulseTorCard(BuildContext context) {
    const purple = Color(0xFF7D4698);
    final torActive = bundledTorEnabled || torEnabled;
    final enabled = torActive && onForcePulseTorChanged != null;
    final l = context.l10n;

    return GestureDetector(
      onTap: enabled ? () => onForcePulseTorChanged!(!forcePulseTor) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: forcePulseTor && enabled
                ? purple.withValues(alpha: 0.08)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: forcePulseTor && enabled
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
                child: const Icon(Icons.shield_rounded, color: purple, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.torForcePulseTitle,
                        style: GoogleFonts.inter(
                            color: enabled
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(
                        enabled
                            ? l.torForcePulseSubtitle
                            : l.torForcePulseDisabled,
                        style: GoogleFonts.inter(
                            color: forcePulseTor && enabled
                                ? purple
                                : AppTheme.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: forcePulseTor && enabled,
                onChanged: enabled
                    ? (v) => onForcePulseTorChanged!(v)
                    : null,
                activeThumbColor: purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticsButton(BuildContext context) {
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
            Text(context.l10n.torNetworkDiagnostics,
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

  Widget _buildPtSelector(BuildContext context, Color purple) {
    final l = context.l10n;
    final items = [
      ('auto',      l.torPtAuto),
      ('obfs4',     l.torPtObfs4),
      ('webtunnel', l.torPtWebTunnel),
      ('snowflake', l.torPtSnowflake),
      ('plain',     l.torPtPlain),
    ];
    return Row(
      children: [
        Text(l.torTransportLabel,
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

  Widget _buildTimeoutRow(BuildContext context, Color purple) {
    return Row(
      children: [
        Text(context.l10n.torTimeoutLabel,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary, fontSize: 11)),
        Text('${torTimeoutSec}s',
            style: GoogleFonts.inter(
                color: purple,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: purple,
              inactiveTrackColor: purple.withValues(alpha: 0.15),
              thumbColor: purple,
              overlayColor: purple.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: torTimeoutSec.toDouble(),
              min: 15,
              max: 120,
              divisions: 21,
              onChanged: onTorTimeoutChanged != null
                  ? (v) => onTorTimeoutChanged!(v.round())
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTorInfo(BuildContext context) {
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
              context.l10n.torInfoDescription,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorSettings(BuildContext context) {
    const purple = Color(0xFF7D4698);
    final managedByBundled = bundledTorEnabled;
    final l = context.l10n;
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
                      Text(l.torRouteNostrTitle,
                          style: GoogleFonts.inter(
                              color: managedByBundled
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text(
                          managedByBundled
                              ? l.torManagedByBuiltin
                              : (torEnabled ? l.torActiveRouting : l.torDisabled),
                          style: GoogleFonts.inter(
                              color: torEnabled
                                  ? purple
                                  : AppTheme.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Switch.adaptive(
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
                    hint: l.torProxyHostHint,
                    label: l.torProxyHostLabel,
                    icon: Icons.router_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _field(
                    controller: torPortController,
                    hint: l.torProxyPortHint,
                    label: l.torProxyPortLabel,
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
                l.torPortInfo,
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
