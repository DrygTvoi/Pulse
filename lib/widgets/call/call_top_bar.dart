import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/l10n_ext.dart';
import '../../models/contact.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import 'call_phase.dart';

/// Glass top bar shown above the call surface.
///
/// Renders:
///   [minimize] | [name + status pill (color dot + label) + encryption icon] |
///   [signal strength dot]
class CallTopBar extends StatelessWidget {
  final Contact contact;
  final CallPhase phase;
  final String statusLabel;
  final VoidCallback onMinimize;
  final bool e2eeKyber;

  const CallTopBar({
    super.key,
    required this.contact,
    required this.phase,
    required this.statusLabel,
    required this.onMinimize,
    this.e2eeKyber = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(DesignTokens.radiusXl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spacing8,
            DesignTokens.spacing8,
            DesignTokens.spacing16,
            DesignTokens.spacing12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.background.withValues(alpha: 0.55),
                AppTheme.background.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Row(
            children: [
              Semantics(
                label: context.l10n.back,
                button: true,
                child: IconButton(
                  icon: Icon(Icons.expand_more_rounded,
                      color: AppTheme.textPrimary),
                  tooltip: context.l10n.back,
                  onPressed: onMinimize,
                ),
              ),
              SizedBox(width: DesignTokens.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontSize: DesignTokens.fontTitle,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        SizedBox(width: DesignTokens.spacing6),
                        Icon(
                          Icons.lock_rounded,
                          color: e2eeKyber
                              ? const Color(0xFF4ADE80)
                              : AppTheme.textSecondary,
                          size: 12,
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _statusDotColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: DesignTokens.spacing6),
                        Flexible(
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: DesignTokens.fontMd,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (phase.isConnected) _signalStrengthDot(),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusDotColor() {
    switch (phase) {
      case CallPhase.connectedAudio:
      case CallPhase.connectedVideo:
        return AppTheme.online;
      case CallPhase.reconnecting:
        return AppTheme.warning;
      case CallPhase.ended:
        return AppTheme.destructive;
      case CallPhase.dialing:
      case CallPhase.ringing:
      case CallPhase.connecting:
        return AppTheme.primary;
    }
  }

  Widget _signalStrengthDot() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing8,
        vertical: DesignTokens.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.online.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cell_tower_rounded,
              color: AppTheme.online, size: 13),
          SizedBox(width: DesignTokens.spacing4),
          Text(
            'HD',
            style: GoogleFonts.inter(
              color: AppTheme.online,
              fontSize: DesignTokens.fontSm,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
