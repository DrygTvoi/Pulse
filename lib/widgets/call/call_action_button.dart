import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';

/// A round, glass-style action button used by the call action bar.
///
/// - Idle: subtle blur + white12 fill + white border (true "glass").
/// - Active: solid [activeColor] (defaults to AppTheme.primary).
/// - End-call variant (`endCall: true`): 64dp red circle with red glow.
///
/// `size` controls the diameter (44 / 56 / 64 supported).
class CallActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool active;
  final bool endCall;
  final double size;
  final Color? activeColor;

  const CallActionButton({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.active = false,
    this.endCall = false,
    this.size = 56,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final fillActive = activeColor ?? AppTheme.primary;
    final iconSize = endCall ? 30.0 : (size >= 56 ? 26.0 : 22.0);

    Widget circle;

    if (endCall) {
      circle = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.destructive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.destructive.withValues(alpha: 0.55),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
    } else if (active) {
      circle = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fillActive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: fillActive.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      );
    } else {
      // Glass / idle.
      circle = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white
                  .withValues(alpha: disabled ? 0.35 : 0.95),
              size: iconSize,
            ),
          ),
        ),
      );
    }

    final tappable = Semantics(
      label: label,
      button: true,
      enabled: !disabled,
      child: InkResponse(
        onTap: disabled ? null : onTap,
        radius: size / 2 + 6,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        child: circle,
      ),
    );

    if (label == null || label!.isEmpty) return tappable;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tappable,
        SizedBox(height: DesignTokens.spacing6),
        Text(
          label!,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: disabled ? 0.45 : 0.85),
            fontSize: DesignTokens.fontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
