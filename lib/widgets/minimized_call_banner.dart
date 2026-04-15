import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../services/active_call_service.dart';

/// Full-width teal banner shown at the top of HomeScreen when a call is
/// minimized.  The duration updates live via [ListenableBuilder].
class MinimizedCallBanner extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onHangUp;

  const MinimizedCallBanner({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onHangUp,
  });

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ActiveCallService.instance,
      builder: (context, _) {
        final elapsed = ActiveCallService.instance.elapsed;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              color: AppTheme.providerPulse,
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing8),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_rounded, color: Colors.white, size: DesignTokens.fontHeading),
                      const SizedBox(width: DesignTokens.spacing8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              contact.name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: DesignTokens.fontMd,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _fmt(elapsed),
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: DesignTokens.fontSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                        tooltip: context.l10n.callEndCallBanner,
                        onPressed: onHangUp,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.destructive,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
