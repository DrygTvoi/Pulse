import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/psiphon_service.dart';
import '../l10n/l10n_ext.dart';

/// Psiphon toggle card for the Settings → Censorship Resistance section.
class PsiphonConfigSection extends StatelessWidget {
  const PsiphonConfigSection({
    super.key,
    required this.psiphonEnabled,
    required this.psiphonLoading,
    required this.onToggle,
  });

  final bool psiphonEnabled;
  final bool psiphonLoading;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00897B);
    final svc = PsiphonService.instance;
    final isConnected = svc.isRunning;
    final l = context.l10n;

    String subtitle;
    Color subtitleColor;
    if (isConnected && psiphonEnabled) {
      final port = svc.proxyPort;
      subtitle = l.psiphonConnectedSubtitle(port ?? 0);
      subtitleColor = teal;
    } else if (psiphonLoading) {
      subtitle = l.psiphonConnecting;
      subtitleColor = teal.withValues(alpha: 0.7);
    } else if (psiphonEnabled) {
      subtitle = l.psiphonNotRunning;
      subtitleColor = AppTheme.textSecondary;
    } else {
      subtitle = l.psiphonDescription;
      subtitleColor = AppTheme.textSecondary;
    }

    final active = psiphonEnabled;
    return GestureDetector(
      onTap: psiphonLoading ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? teal.withValues(alpha: 0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
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
              child:
                  const Icon(Icons.rocket_launch_rounded, color: teal, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.psiphonTitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: subtitleColor, fontSize: 12)),
                ],
              ),
            ),
            if (psiphonLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: teal),
              )
            else
              Switch.adaptive(
                value: active,
                onChanged: (_) => onToggle(),
                activeThumbColor: teal,
              ),
          ],
        ),
      ),
    );
  }
}
