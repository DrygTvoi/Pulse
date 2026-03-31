import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../models/message.dart';
import 'avatar_widget.dart';
import '../l10n/l10n_ext.dart';

/// A single chat list tile showing avatar, name, last message preview,
/// unread count, mute icon, and SmartRouter badge.
class ChatTile extends StatelessWidget {
  final Contact contact;
  final Message? lastMsg;
  final int unreadCount;
  final String myId;
  final bool isOnline;
  final bool isMuted;
  final Uint8List? avatarBytes;
  final VoidCallback onTap;
  final bool selected;

  const ChatTile({
    super.key,
    required this.contact,
    required this.lastMsg,
    required this.unreadCount,
    required this.myId,
    required this.isOnline,
    required this.isMuted,
    required this.avatarBytes,
    required this.onTap,
    this.selected = false,
  });

  String _formatTime(BuildContext context, DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(t.year, t.month, t.day);
    if (msgDay == today) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (msgDay == yesterday) return context.l10n.chatYesterday;
    if (now.year == t.year) return '${t.day}/${t.month}';
    return '${t.day}/${t.month}/${t.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = context.l10n.chatTileTapToStart;
    String? timeStr;
    bool isMe = false;

    if (lastMsg != null) {
      isMe = lastMsg!.senderId == myId;
      timeStr = _formatTime(context, lastMsg!.timestamp);
      final text = lastMsg!.encryptedPayload;
      if (text.startsWith('\u26A0\uFE0F UNENCRYPTED: ')) {
        subtitle = '\u26A0\uFE0F ${text.substring('\u26A0\uFE0F UNENCRYPTED: '.length)}';
      } else if (text.startsWith('E2EE||')) {
        subtitle = isMe ? context.l10n.chatTileMessageSent : context.l10n.chatTileEncryptedMessage;
      } else if (text.startsWith('{"t":"blossom"')) {
        subtitle = isMe ? context.l10n.chatTileYouPrefix('\uD83D\uDCCE Media') : '\uD83D\uDCCE Media';
      } else if (text.startsWith('{"t":"img"') || text.startsWith('{"t":"gif"') ||
                 text.startsWith('{"t":"voice"') || text.startsWith('{"t":"file"') ||
                 text.startsWith('{"t":"video_note"') || text.startsWith('{"t":"chunk"')) {
        subtitle = isMe ? context.l10n.chatTileYouPrefix('\uD83D\uDCCE Media') : '\uD83D\uDCCE Media';
      } else {
        subtitle = isMe ? context.l10n.chatTileYouPrefix(text) : text;
      }
    }

    return Material(
      color: selected ? AppTheme.primary.withValues(alpha: 0.10) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primary.withValues(alpha: 0.07),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing8),
              child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'contact_avatar_${contact.id}',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarWidget(
                      name: contact.name,
                      size: DesignTokens.avatarMd,
                      imageBytes: avatarBytes,
                      fontSize: DesignTokens.fontDisplay,
                    ),
                    if (contact.isGroup)
                      Positioned(bottom: -1, right: -1,
                        child: Container(
                          padding: const EdgeInsets.all(DesignTokens.spacing2),
                          decoration: BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
                          child: Icon(Icons.group_rounded, size: DesignTokens.fontMd, color: AppTheme.primary),
                        ),
                      ),
                    if (!contact.isGroup && isOnline)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.background, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spacing14),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontSize: DesignTokens.fontXl,
                              fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                            )),
                      ),
                      if (isMuted) ...[
                        Icon(Icons.notifications_off_rounded, size: DesignTokens.fontLg, color: AppTheme.textSecondary),
                        const SizedBox(width: DesignTokens.spacing4),
                      ],
                      if (timeStr != null)
                        Text(timeStr,
                            style: GoogleFonts.inter(
                              color: unreadCount > 0 ? AppTheme.primary : AppTheme.textSecondary,
                              fontSize: DesignTokens.fontBody,
                              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            )),
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      Expanded(
                        child: Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: DesignTokens.fontMd,
                              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                            ).copyWith(fontFamilyFallback: const ['Noto Color Emoji'])),
                      ),
                      // Unread badge
                      if (unreadCount > 0) ...[
                        const SizedBox(width: DesignTokens.spacing6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: DesignTokens.spacing2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                          ),
                          child: Text('$unreadCount',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w700)),
                        ),
                      ],
                      // SmartRouter badge: show route count if contact has alternates
                      if (unreadCount == 0 && contact.alternateAddresses.isNotEmpty) ...[
                        const SizedBox(width: DesignTokens.spacing6),
                        Container(
                          width: DesignTokens.iconSm, height: DesignTokens.iconSm,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.shuffle_rounded,
                                size: 9, color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
            // Subtle indented divider (past avatar)
            Padding(
              padding: const EdgeInsets.only(left: DesignTokens.avatarMd + DesignTokens.spacing12 + DesignTokens.spacing14),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
