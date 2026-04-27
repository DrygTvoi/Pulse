import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/contact.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../avatar_widget.dart';
import 'call_phase.dart';

/// Center stack: pulse rings (when waiting) → 160dp avatar → name → status.
///
/// For `connectedAudio` it also renders an animated 3-bar equalizer below the
/// status to give the user visual confirmation that audio is flowing.
class CallStatusOverlay extends StatelessWidget {
  final Contact contact;
  final CallPhase phase;
  final String statusLabel;
  final Uint8List? avatarBytes;

  const CallStatusOverlay({
    super.key,
    required this.contact,
    required this.phase,
    required this.statusLabel,
    this.avatarBytes,
  });

  @override
  Widget build(BuildContext context) {
    final showRings =
        phase == CallPhase.dialing || phase == CallPhase.ringing;

    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (showRings) ..._pulseRings(),
                AvatarWidget(
                  name: contact.name,
                  size: 160,
                  imageBytes: avatarBytes,
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing24),
            Text(
              contact.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: DesignTokens.fontDisplayLg,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: DesignTokens.spacing8),
            Text(
              statusLabel,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: DesignTokens.fontInput,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ).animate(onPlay: (c) {
              if (!phase.isConnected) c.repeat(reverse: true);
            }).fade(duration: 900.ms, begin: 0.55),
            if (phase == CallPhase.connectedAudio) ...[
              SizedBox(height: DesignTokens.spacing20),
              _equalizer(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _pulseRings() => [
        _ring(220, 0.10, 0),
        _ring(260, 0.05, 400),
      ];

  Widget _ring(double size, double opacity, int delayMs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withValues(alpha: opacity),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          delay: delayMs.ms,
          duration: 1600.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.25, 1.25),
          curve: Curves.easeInOut,
        )
        .fade(
          delay: delayMs.ms,
          duration: 1600.ms,
          begin: 1.0,
          end: 0.0,
        );
  }

  Widget _equalizer() {
    return SizedBox(
      width: 30,
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _bar(0),
          _bar(140),
          _bar(280),
        ],
      ),
    );
  }

  Widget _bar(int delayMs) {
    return Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleY(
          delay: delayMs.ms,
          duration: 600.ms,
          begin: 0.25,
          end: 1.0,
          curve: Curves.easeInOut,
        );
  }
}
