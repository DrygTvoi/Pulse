import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/psiphon_service.dart';

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

    String subtitle;
    Color subtitleColor;
    if (isConnected && psiphonEnabled) {
      final port = svc.proxyPort;
      subtitle = 'Connected \u2014 SOCKS5 on 127.0.0.1:$port';
      subtitleColor = teal;
    } else if (psiphonLoading) {
      subtitle = 'Connecting\u2026';
      subtitleColor = teal.withValues(alpha: 0.7);
    } else if (psiphonEnabled) {
      subtitle = 'Not running \u2014 tap switch to restart';
      subtitleColor = AppTheme.textSecondary;
    } else {
      subtitle = 'Fast tunnel (~3s bootstrap, 2000+ rotating VPS)';
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
                  Text('Psiphon',
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
