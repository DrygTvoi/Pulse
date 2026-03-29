import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Compact chip showing Tor status in the app bar (bootstrap % or active PT label).
class TorChip extends StatelessWidget {
  final bool isRunning;
  final int bootstrapPercent;
  final String activePtLabel;

  const TorChip({
    super.key,
    required this.isRunning,
    required this.bootstrapPercent,
    required this.activePtLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRunning) return const SizedBox.shrink();
    final isActive = bootstrapPercent == 100;
    final color = isActive ? AppTheme.primary : Colors.orange;
    // Show which PT is active: "Tor·obfs4", "Tor·SF", "Tor·WT", "Tor" (plain)
    final ptSuffix = switch (activePtLabel) {
      'obfs4'     => '\u00B7obfs4',
      'snowflake' => '\u00B7SF',
      'webtunnel' => '\u00B7WT',
      _           => '',
    };
    final label = isActive ? 'Tor$ptSuffix' : 'Tor $bootstrapPercent%';
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Chip(
        avatar: Icon(Icons.security_rounded, size: 14, color: color),
        label: Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: color)),
        backgroundColor: color.withValues(alpha: 0.12),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
