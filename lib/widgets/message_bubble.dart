import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_manager.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../services/media_service.dart';
import '../services/media_validator.dart';
import '../screens/image_viewer_screen.dart';
import '../utils/platform_utils.dart';
import '../l10n/l10n_ext.dart';
import 'message_bubble_media.dart';
import 'call_record_bubble.dart';

final _urlRegex = RegExp(r'https?://[^\s<>"]+[^\s<>".!?,)]', caseSensitive: false);

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final String status;     // 'sending', 'sent', 'failed', '' (received)
  final bool showTail;     // true = last message in a consecutive group
  final String? senderName; // shown above bubble in group chats (non-me only)
  final bool isEdited;
  final Map<String, List<String>>? reactions; // {emoji: [senderIds]}
  final void Function(String emoji)? onReact;
  final void Function(String emoji)? onReactLongPress;
  final String? replyToText;
  final String? replyToSender;
  final double? uploadProgress; // 0.0..1.0 while uploading chunks
  /// For group messages sent by self: contactIds who have read this message.
  final List<String> readBy;
  /// For group messages sent by self: contactIds who have received (delivered) this message.
  final List<String> deliveredTo;
  /// Called when the user taps the failed-status icon to retry sending.
  final VoidCallback? onRetry;
  /// Called when user taps the delivery-status row to see per-member detail.
  final VoidCallback? onGroupStatusTap;
  /// Pre-built contact lookup index — avoids rebuilding per bubble.
  final Map<String, Contact>? contactIndex;
  /// Current user's selfId — used to highlight own reactions.
  final String? selfId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.status = '',
    this.showTail = true,
    this.senderName,
    this.isEdited = false,
    this.reactions,
    this.onReact,
    this.onReactLongPress,
    this.replyToText,
    this.replyToSender,
    this.uploadProgress,
    this.readBy = const [],
    this.deliveredTo = const [],
    this.onRetry,
    this.onGroupStatusTap,
    this.contactIndex,
    this.selfId,
  });

  static const _unencryptedPrefix = '\u26A0\uFE0F UNENCRYPTED: ';

  @override
  Widget build(BuildContext context) {
    final isUnencrypted = message.startsWith(_unencryptedPrefix);
    final rawText = isUnencrypted ? message.substring(_unencryptedPrefix.length) : message;

    // Call history record — render as centered system row, not a bubble.
    final callRecord = tryParseCallRecord(rawText);
    if (callRecord != null) {
      return CallRecordBubble(message: rawText, timestamp: timestamp, isMe: isMe);
    }

    // Detect media payload
    final media = MediaService.parse(rawText);
    final blossomPayload = media == null ? BlossomPayloadHelpers.parseBlossomPayload(rawText) : null;

    final Color bgColor = isUnencrypted
        ? const Color(0xFF8B1A1A)
        : (isMe ? AppTheme.outgoingBubble : AppTheme.incomingBubble);

    final radius = showTail
        ? BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.chatBubbleRadius),
            topRight: Radius.circular(DesignTokens.chatBubbleRadius),
            bottomLeft: Radius.circular(isMe ? DesignTokens.chatBubbleRadius : DesignTokens.bubbleTailRadius),
            bottomRight: Radius.circular(isMe ? DesignTokens.bubbleTailRadius : DesignTokens.chatBubbleRadius),
          )
        : BorderRadius.circular(DesignTokens.chatBubbleRadius);

    final hasReactions = reactions != null && reactions!.isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (senderName != null && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: DesignTokens.spacing4, bottom: DesignTokens.spacing2),
              child: Text(
                senderName!,
                style: GoogleFonts.inter(
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w700,
                  color: _nameColor(senderName!),
                ),
              ),
            ),
          Container(
            margin: EdgeInsets.only(
              left: isMe ? DesignTokens.chatBubbleMarginOpposite : 0,
              right: isMe ? 0 : DesignTokens.chatBubbleMarginOpposite,
            ),
            // No padding for media bubbles that fill the bubble
            padding: (media?.isImage == true || media?.isGif == true || media?.isVideoNote == true ||
                      (blossomPayload != null && (blossomPayload.mediaType == 'img' || blossomPayload.mediaType == 'gif')))
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: DesignTokens.chatBubblePaddingH, vertical: DesignTokens.chatBubblePaddingV),
            decoration: BoxDecoration(
              color: (media?.isImage == true || media?.isGif == true || media?.isVideoNote == true ||
                      (blossomPayload != null && (blossomPayload.mediaType == 'img' || blossomPayload.mediaType == 'gif')))
                  ? Colors.transparent : bgColor,
              borderRadius: radius,
              boxShadow: (media?.isImage == true || media?.isGif == true || media?.isVideoNote == true ||
                  (blossomPayload != null && (blossomPayload.mediaType == 'img' || blossomPayload.mediaType == 'gif')))
                  ? null : DesignTokens.shadowSm,
            ),
            child: media != null
                ? _buildMediaContent(context, media, bgColor, radius)
                : blossomPayload != null
                    ? BlossomMediaWidget(payload: blossomPayload, radius: radius, isMe: isMe)
                    : _buildTextContent(context, isUnencrypted, rawText),
          ),
          if (hasReactions)
            Padding(
              padding: EdgeInsets.only(
                top: DesignTokens.spacing4,
                left: isMe ? DesignTokens.chatBubbleMarginOpposite : 0,
                right: isMe ? 0 : DesignTokens.chatBubbleMarginOpposite,
              ),
              child: Wrap(
                spacing: DesignTokens.spacing4,
                runSpacing: DesignTokens.spacing4,
                children: reactions!.entries.map((entry) {
                  final emoji = entry.key;
                  final count = entry.value.length;
                  final selfBare = selfId != null && selfId!.contains('@')
                      ? selfId!.split('@').first : selfId;
                  final isMine = selfId != null && entry.value.any((s) =>
                      s == selfId || s == selfBare);
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onReact?.call(emoji),
                      onLongPress: () => onReactLongPress?.call(emoji),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMine
                              ? AppTheme.primary.withValues(alpha: DesignTokens.opacityMedium)
                              : AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                          boxShadow: DesignTokens.shadowSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: DesignTokens.fontLg)),
                            const SizedBox(width: DesignTokens.spacing4),
                            Text('$count',
                                style: GoogleFonts.inter(
                                    fontSize: DesignTokens.fontSm,
                                    color: Colors.white.withValues(alpha: 0.55))),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (isMe && (readBy.isNotEmpty || deliveredTo.isNotEmpty))
            GestureDetector(
              onTap: onGroupStatusTap,
              child: readBy.isNotEmpty
                  ? _buildReadByRow(context)
                  : _buildDeliveredToRow(context),
            ),
        ],
      ),
    );
  }

  /// Build an O(1) lookup index from the contacts list.
  /// Called once per status-row build instead of O(n) per ID.
  static Map<String, Contact> _buildContactIndex(BuildContext context) {
    final contacts = context.read<IContactRepository>().contacts;
    return {for (final c in contacts) c.id: c};
  }

  Widget _buildDeliveredToRow(BuildContext context) {
    final index = contactIndex ?? _buildContactIndex(context);
    final names = deliveredTo.map((id) {
      final c = index[id];
      return c?.name ?? id.substring(0, id.length.clamp(0, 8));
    }).toList();
    final label = names.length <= 2
        ? context.l10n.bubbleDeliveredTo(names.join(' & '))
        : context.l10n.bubbleDeliveredToCount(names.length);
    return _buildStatusRow(
        context, label: label, iconColor: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityHeavy));
  }

  Widget _buildReadByRow(BuildContext context) {
    final index = contactIndex ?? _buildContactIndex(context);
    final names = readBy.map((id) {
      final c = index[id];
      return c?.name ?? id.substring(0, id.length.clamp(0, 8));
    }).toList();
    final label = names.length <= 2
        ? context.l10n.bubbleReadBy(names.join(' & '))
        : context.l10n.bubbleReadByCount(names.length);
    return _buildStatusRow(
        context, label: label, iconColor: AppTheme.primary.withValues(alpha: 0.8));
  }

  Widget _buildStatusRow(BuildContext context,
      {required String label, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacing2, right: DesignTokens.spacing4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all_rounded, size: DesignTokens.fontSm, color: iconColor),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: DesignTokens.fontXs,
                  fontWeight: FontWeight.w500)),
          if (onGroupStatusTap != null) ...[
            const SizedBox(width: DesignTokens.spacing4),
            Icon(Icons.info_outline_rounded,
                size: DesignTokens.fontSm,
                color: AppTheme.textSecondary.withValues(alpha: 0.45)),
          ],
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isUnencrypted, String displayText) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyToText != null && replyToText!.isNotEmpty)
          _buildReplyQuote(context),
        if (isUnencrypted)
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacing4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_open_rounded, size: DesignTokens.fontBody, color: AppTheme.warning),
              const SizedBox(width: DesignTokens.spacing4),
              Text(context.l10n.bubbleNotEncrypted,
                  style: GoogleFonts.inter(
                    color: AppTheme.warning, fontSize: DesignTokens.fontXs,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5,
                  )),
            ]),
          ),
        _buildLinkedText(context, displayText),
        if (isEdited)
          Text('(${context.l10n.chatEdited})',
              style: GoogleFonts.inter(
                  fontSize: DesignTokens.fontXs, color: Colors.white.withValues(alpha: 0.45))),
        const SizedBox(height: 3),
        _buildTimestamp(),
      ],
    );
  }

  Widget _buildLinkedText(BuildContext context, String text) {
    final bubbleTextColor = isMe
        ? (ThemeNotifier.instance.isDark ? Colors.white : const Color(0xFF111B21))
        : (ThemeNotifier.instance.isDark ? Colors.white : const Color(0xFF111B21));
    final baseStyle = GoogleFonts.inter(color: bubbleTextColor, fontSize: DesignTokens.fontInput, height: 1.35)
        .copyWith(fontFamilyFallback: const ['Noto Color Emoji']);
    final matches = _urlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      if (PlatformUtils.isDesktop) {
        return SelectableText(text, style: baseStyle, contextMenuBuilder: (_, __) => const SizedBox.shrink());
      }
      return Text(text, style: baseStyle);
    }
    return _LinkedText(text: text, matches: matches, baseStyle: baseStyle, isDesktop: PlatformUtils.isDesktop);
  }

  static void _confirmAndLaunchUrl(BuildContext context, String url) {
    final display = url.length > 70 ? '${url.substring(0, 70)}\u2026' : url;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(ctx.l10n.bubbleOpenLink),
        content: Text(ctx.l10n.bubbleOpenLinkBody(display)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.chatCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.bubbleOpen),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    });
  }

  static Future<void> _saveFile(BuildContext context, MediaPayload media) async {
    const dangerousExts = {
      '.exe', '.sh', '.bat', '.cmd', '.ps1', '.vbs',
      '.apk', '.deb', '.dmg', '.msi', '.pkg',
    };
    final dotIdx = media.name.lastIndexOf('.');
    final ext = dotIdx >= 0 ? media.name.substring(dotIdx).toLowerCase() : '';

    if (dangerousExts.contains(ext)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog.adaptive(
          title: Text(ctx.l10n.bubbleSecurityWarning),
          content: Text(ctx.l10n.bubbleExecutableWarning(media.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.l10n.chatCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(ctx.l10n.bubbleSaveAnyway),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      // Defense-in-depth: re-sanitize at write time to guard against any
      // path separator that survived upstream processing.
      final safeName = MediaValidator.sanitizeFilename(media.name);
      final file = File('${dir.path}/${ts}_$safeName');
      await file.writeAsBytes(media.data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.bubbleSavedTo(dir.path), style: GoogleFonts.inter(fontSize: DesignTokens.fontMd)),
          backgroundColor: AppTheme.surfaceVariant,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.bubbleSaveFailed('$e'), style: GoogleFonts.inter(fontSize: DesignTokens.fontMd)),
          backgroundColor: Colors.red.shade900,
        ));
      }
    }
  }

  Widget _buildReplyQuote(BuildContext context) {
    // Resolve display text — friendly label for media payloads
    String displayText;
    final replyMedia = MediaService.parse(replyToText!);
    if (replyMedia != null) {
      if (replyMedia.isImage) { displayText = '\u{1F4F7} ${context.l10n.bubbleReplyPhoto}'; }
      else if (replyMedia.isVoice) { displayText = '\u{1F399} ${context.l10n.bubbleReplyVoice}'; }
      else if (replyMedia.isVideoNote) { displayText = '\u{1F3A5} ${context.l10n.bubbleReplyVideo}'; }
      else if (replyMedia.isGif) { displayText = 'GIF'; }
      else { displayText = '\u{1F4CE} ${replyMedia.name}'; }
    } else {
      displayText = replyToText!.length > 80 ? '${replyToText!.substring(0, 80)}\u2026' : replyToText!;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing6),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: DesignTokens.opacityMedium),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (replyToSender != null && replyToSender!.isNotEmpty)
                  Text(
                    replyToSender!.length > 20
                        ? replyToSender!.substring(0, 20)
                        : replyToSender!,
                    style: GoogleFonts.inter(
                        fontSize: DesignTokens.fontXs,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: DesignTokens.opacityFull)),
                  ),
                Text(
                  displayText,
                  style: GoogleFonts.inter(
                      fontSize: DesignTokens.fontSm,
                      color: Colors.white.withValues(alpha: 0.65)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context, MediaPayload media, Color bgColor, BorderRadius radius) {
    if (media.isVoice) {
      return VoiceBubble(media: media, isMe: isMe, bgColor: bgColor, radius: radius, buildTimestamp: _buildTimestamp);
    }
    if (media.isVideoNote) {
      return VideoNoteBubble(media: media, isMe: isMe, buildTimestamp: _buildTimestamp,
          status: status, uploadProgress: uploadProgress);
    }
    if (media.isGif) {
      return GifBubble(media: media, isMe: isMe, radius: radius, buildTimestamp: _buildTimestamp);
    }
    if (media.isImage) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(imageData: media.data, name: media.name),
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260, maxHeight: 320),
                child: Image.memory(
                  media.data,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stack) => Container(
                    width: 260,
                    height: 120,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.broken_image_rounded, color: Colors.white54, size: DesignTokens.iconXl),
                      const SizedBox(height: DesignTokens.spacing6),
                      Text(context.l10n.bubbleCorruptedImage,
                          style: const TextStyle(color: Colors.white54, fontSize: DesignTokens.fontBody)),
                    ]),
                  ),
                ),
              ),
              // Timestamp bar over image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: DesignTokens.spacing4),
                color: Colors.black.withValues(alpha: 0.35),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [_buildTimestamp()],
                ),
              ),
            ],
          ),
        ),
      );
    }
    // File attachment
    return Container(
      decoration: BoxDecoration(color: bgColor, borderRadius: radius),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.chatBubblePaddingH, vertical: DesignTokens.spacing10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacing8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: DesignTokens.opacityLight),
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                ),
                child: const Icon(Icons.insert_drive_file_rounded, color: Colors.white, size: DesignTokens.iconLg),
              ),
              const SizedBox(width: DesignTokens.spacing10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      media.name,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: DesignTokens.fontMd),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignTokens.spacing2),
                    Text(
                      media.sizeLabel,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.65), fontSize: DesignTokens.fontSm),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spacing6),
              GestureDetector(
                onTap: () => _saveFile(context, media),
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: const Icon(Icons.download_rounded, color: Colors.white70, size: DesignTokens.fontHeading),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing6),
              _buildTimestamp(),
            ],
          ),
          if (uploadProgress != null) ...[
            const SizedBox(height: DesignTokens.spacing6),
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
              child: LinearProgressIndicator(
                value: uploadProgress,
                minHeight: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.70), fontSize: DesignTokens.fontSm),
      ),
      if (isMe && status.isNotEmpty) ...[
        const SizedBox(width: DesignTokens.spacing4),
        _buildStatusIcon(),
      ],
    ]);
  }

  Color _nameColor(String name) {
    const palette = [
      Color(0xFF00BCD4), Color(0xFF9C27B0), Color(0xFF4CAF50),
      Color(0xFFFF9800), Color(0xFFE91E63), Color(0xFF2196F3),
      Color(0xFF009688), Color(0xFFFF5722),
    ];
    final idx = (name.isNotEmpty ? name.codeUnitAt(0) + name.length : 0) % palette.length;
    return palette[idx];
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case 'sending':
        return SizedBox(
          width: 11, height: 11,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white.withValues(alpha: 0.55)),
        );
      case 'sent':
        return Icon(Icons.done_rounded, size: 13, color: Colors.white.withValues(alpha: 0.7));
      case 'delivered':
        return Icon(Icons.done_all_rounded, size: 13, color: Colors.white.withValues(alpha: 0.7));
      case 'read':
        return Icon(Icons.done_all_rounded, size: 13, color: AppTheme.primary);
      case 'failed':
        return GestureDetector(
          onTap: onRetry,
          child: const Icon(Icons.error_outline_rounded, size: 13, color: Colors.orangeAccent),
        );
      case 'scheduled':
        return Icon(Icons.schedule_rounded, size: 13, color: Colors.white.withValues(alpha: 0.55));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Linked text with proper gesture recognizer lifecycle ─────────────────────

class _LinkedText extends StatefulWidget {
  final String text;
  final List<RegExpMatch> matches;
  final TextStyle baseStyle;
  final bool isDesktop;

  const _LinkedText({required this.text, required this.matches, required this.baseStyle, this.isDesktop = false});

  @override
  State<_LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<_LinkedText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];
    int last = 0;
    for (final m in widget.matches) {
      if (m.start > last) {
        spans.add(TextSpan(text: widget.text.substring(last, m.start)));
      }
      final url = m.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => MessageBubble._confirmAndLaunchUrl(context, url);
      _recognizers.add(recognizer);
      spans.add(TextSpan(
        text: url,
        style: widget.baseStyle.copyWith(
          color: AppTheme.info,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.info,
        ),
        recognizer: recognizer,
      ));
      last = m.end;
    }
    if (last < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(last)));
    }

    if (widget.isDesktop) {
      return SelectableText.rich(
        TextSpan(style: widget.baseStyle, children: spans),
        contextMenuBuilder: (_, __) => const SizedBox.shrink(),
      );
    }
    return RichText(text: TextSpan(style: widget.baseStyle, children: spans));
  }
}
