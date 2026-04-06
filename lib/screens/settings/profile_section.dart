// Settings — Profile section: profile card, inbox address, QR code.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/chat_controller.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/profile_card.dart';
import 'settings_widgets.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  String _buildInviteLink(List<String> addresses, String name) {
    final payload = addresses.length == 1
        ? jsonEncode({'a': addresses.first, 'n': name})
        : jsonEncode({'a': addresses, 'n': name});
    final cfg = base64Encode(utf8.encode(payload));
    return 'pulse://add?cfg=$cfg';
  }

  void _showMyQrDialog(BuildContext context) {
    final addresses = ChatController().shareableAddresses;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.settingsNoAddressYet),
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        String myName = '';
        SharedPreferences.getInstance().then((p) {
          try {
            final profile = jsonDecode(p.getString('user_profile') ?? '{}');
            myName = (profile['name'] as String?) ?? '';
          } catch (e) {
            debugPrint('[Settings] Failed to parse profile name: $e');
          }
        });

        final inviteLink = _buildInviteLink(addresses, myName);

        return AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(
            context.l10n.settingsShareMyAddress,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: DesignTokens.fontXl,
            ),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  padding: const EdgeInsets.all(DesignTokens.cardPadding),
                  child: QrImageView(data: inviteLink, size: 220),
                ),
                const SizedBox(height: DesignTokens.spacing12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.spacing6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route_rounded, size: DesignTokens.fontMd, color: AppTheme.primary),
                      const SizedBox(width: DesignTokens.spacing6),
                      Text(
                        '${addresses.length} ${addresses.length == 1 ? 'route' : 'routes'} included',
                        style: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontSize: DesignTokens.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing12),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctx.l10n.settingsInviteLink,
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: DesignTokens.fontXs,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      SelectableText(
                        inviteLink,
                        style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.textPrimary, fontSize: DesignTokens.fontXs),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteLink));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(context.l10n.settingsInviteLinkCopied,
                      style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: AppTheme.primary,
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Text(
                context.l10n.settingsCopyLink,
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.l10n.close,
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileCard(showAddressCard: false),
        const SizedBox(height: DesignTokens.spacing12),
        const InboxAddressCard(),
        const SizedBox(height: DesignTokens.spacing10),
        settingsRow(
          icon: Icons.qr_code_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: context.l10n.settingsMyQrCode,
          subtitle: context.l10n.settingsMyQrSubtitle,
          onTap: () => _showMyQrDialog(context),
        ),
      ],
    );
  }
}
