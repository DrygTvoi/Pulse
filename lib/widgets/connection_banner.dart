import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../services/connectivity_probe_service.dart';
import 'avatar_widget.dart';

/// Toast-style banner showing a new message preview (slides in from top).
class NewMessageBanner extends StatelessWidget {
  final Contact contact;
  final Message message;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NewMessageBanner({
    super.key,
    required this.contact,
    required this.message,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    String preview = message.encryptedPayload;
    if (preview.startsWith('E2EE||')) {
      preview = '\uD83D\uDD12 Encrypted message';
    } else if (preview.startsWith('\u26A0\uFE0F UNENCRYPTED: ')) {
      preview = preview.substring('\u26A0\uFE0F UNENCRYPTED: '.length);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarWidget(name: contact.name, size: 40, fontSize: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(contact.name,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: -1.5, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);
  }
}

/// Bottom banner showing connectivity probe progress.
class ProbeBanner extends StatelessWidget {
  final ProbeStatus status;

  const ProbeBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (status.phase) {
      ProbePhase.directProbe => (
          Icons.wifi_find_rounded,
          'Checking network connectivity\u2026',
          const Color(0xFF546E7A),
        ),
      ProbePhase.dohProbe => (
          Icons.travel_explore_rounded,
          'Discovering relays via community directories\u2026',
          const Color(0xFF455A64),
        ),
      ProbePhase.torBoot => (
          Icons.security_rounded,
          'Starting Tor for bootstrap\u2026',
          const Color(0xFF37474F),
        ),
      ProbePhase.torProbe => (
          Icons.vpn_lock_rounded,
          'Finding reachable relays via Tor\u2026',
          const Color(0xFF37474F),
        ),
      ProbePhase.done => status.found > 0
          ? (
              Icons.check_circle_outline_rounded,
              'Network ready \u2014 ${status.found} relay${status.found == 1 ? '' : 's'} found',
              const Color(0xFF2E7D32),
            )
          : (
              Icons.warning_amber_rounded,
              'No reachable relays found \u2014 messages may be delayed',
              const Color(0xFFB71C1C),
            ),
      _ => (Icons.wifi_find_rounded, '', const Color(0xFF546E7A)),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: color.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(icon, color: Colors.white70, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        if (status.phase != ProbePhase.done)
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white60),
          ),
      ]),
    );
  }
}

/// Bottom banner for LAN-only mode.
class LanBanner extends StatelessWidget {
  const LanBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB45309), // amber-700
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'LAN Mode \u2014 No internet \u00B7 Local network only',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.5, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);
  }
}
