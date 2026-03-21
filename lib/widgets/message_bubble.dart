import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../services/media_service.dart';
import '../services/voice_service.dart';
import '../screens/image_viewer_screen.dart';
import '../l10n/l10n_ext.dart';

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
  });

  static const _unencryptedPrefix = '⚠️ UNENCRYPTED: ';

  @override
  Widget build(BuildContext context) {
    final isUnencrypted = message.startsWith(_unencryptedPrefix);
    final rawText = isUnencrypted ? message.substring(_unencryptedPrefix.length) : message;

    // Detect media payload
    final media = MediaService.parse(rawText);

    final Color bgColor = isUnencrypted
        ? const Color(0xFF8B1A1A)
        : (isMe ? AppTheme.primary : AppTheme.surfaceVariant);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(DesignTokens.chatBubbleRadius),
      topRight: const Radius.circular(DesignTokens.chatBubbleRadius),
      bottomRight: Radius.circular(isMe && showTail ? DesignTokens.chatBubbleTailRadius : DesignTokens.chatBubbleRadius),
      bottomLeft: Radius.circular(!isMe && showTail ? DesignTokens.chatBubbleTailRadius : DesignTokens.chatBubbleRadius),
    );

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
            // No padding for image bubbles — image fills the bubble
            padding: media?.isImage == true
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: DesignTokens.chatBubblePaddingH, vertical: DesignTokens.chatBubblePaddingV),
            decoration: BoxDecoration(
              color: media?.isImage == true ? Colors.transparent : bgColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: media != null
                ? _buildMediaContent(context, media, bgColor, radius)
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
                  return GestureDetector(
                    onTap: () => onReact?.call(emoji),
                    onLongPress: () => onReactLongPress?.call(emoji),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
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

  Widget _buildDeliveredToRow(BuildContext context) {
    final names = deliveredTo.map((id) {
      final c = context.read<IContactRepository>().contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == id, orElse: () => null);
      return c?.name ?? id.substring(0, id.length.clamp(0, 8));
    }).toList();
    final label = names.length <= 2
        ? context.l10n.bubbleDeliveredTo(names.join(' & '))
        : context.l10n.bubbleDeliveredToCount(names.length);
    return _buildStatusRow(
        context, label: label, iconColor: AppTheme.textSecondary.withValues(alpha: 0.6));
  }

  Widget _buildReadByRow(BuildContext context) {
    final names = readBy.map((id) {
      final c = context.read<IContactRepository>().contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == id, orElse: () => null);
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
              const Icon(Icons.lock_open_rounded, size: DesignTokens.fontBody, color: Colors.orangeAccent),
              const SizedBox(width: DesignTokens.spacing4),
              Text(context.l10n.bubbleNotEncrypted,
                  style: GoogleFonts.inter(
                    color: Colors.orangeAccent, fontSize: DesignTokens.fontXs,
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
    final baseStyle = GoogleFonts.inter(color: Colors.white, fontSize: DesignTokens.fontInput, height: 1.35);
    final matches = _urlRegex.allMatches(text).toList();
    if (matches.isEmpty) return Text(text, style: baseStyle);
    return _LinkedText(text: text, matches: matches, baseStyle: baseStyle);
  }

  static void _confirmAndLaunchUrl(BuildContext context, String url) {
    final display = url.length > 70 ? '${url.substring(0, 70)}…' : url;
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
      final file = File('${dir.path}/${ts}_${media.name}');
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
      else { displayText = '\u{1F4CE} ${replyMedia.name}'; }
    } else {
      displayText = replyToText!.length > 80 ? '${replyToText!.substring(0, 80)}…' : replyToText!;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing6),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
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
                  color: Colors.white.withValues(alpha: 0.85)),
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
    );
  }

  Widget _buildMediaContent(BuildContext context, MediaPayload media, Color bgColor, BorderRadius radius) {
    if (media.isVoice) {
      return _VoiceBubble(media: media, isMe: isMe, bgColor: bgColor, radius: radius, buildTimestamp: _buildTimestamp);
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
                  color: Colors.white.withValues(alpha: 0.15),
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
        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: DesignTokens.fontSm),
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

  const _LinkedText({required this.text, required this.matches, required this.baseStyle});

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
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
          decorationColor: Colors.lightBlueAccent,
        ),
        recognizer: recognizer,
      ));
      last = m.end;
    }
    if (last < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(last)));
    }

    return RichText(text: TextSpan(style: widget.baseStyle, children: spans));
  }
}

// ─── Voice bubble ─────────────────────────────────────────────────────────────

class _VoiceBubble extends StatefulWidget {
  final MediaPayload media;
  final bool isMe;
  final Color bgColor;
  final BorderRadius radius;
  final Widget Function() buildTimestamp;

  const _VoiceBubble({
    required this.media,
    required this.isMe,
    required this.bgColor,
    required this.radius,
    required this.buildTimestamp,
  });

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;
  String? _tmpPath;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _total = Duration(seconds: widget.media.durationSeconds);
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((dur) {
      if (!mounted) return;
      setState(() => _total = dur);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
      // Delete temp file after playback ends; it will be re-created on replay.
      if (_tmpPath != null) {
        File(_tmpPath!).delete().catchError((_) => File(_tmpPath!));
        _tmpPath = null;
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    if (_tmpPath != null) {
      File(_tmpPath!).delete().catchError((_) => File(_tmpPath!));
    }
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    _tmpPath ??= await VoiceService.writeTempAudio(widget.media.data);
    if (_tmpPath == null) return; // security rejection
    if (_position > Duration.zero) {
      await _player.resume();
    } else {
      await _player.play(DeviceFileSource(_tmpPath!));
    }
    await _player.setPlaybackRate(_speed);
  }

  Future<void> _cycleSpeed() async {
    setState(() {
      _speed = _speed == 1.0 ? 1.5 : _speed == 1.5 ? 2.0 : 1.0;
    });
    if (_isPlaying) {
      await _player.setPlaybackRate(_speed);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total.inMilliseconds > 0
        ? (_position.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final durLabel = _isPlaying || _position > Duration.zero
        ? _fmt(_position)
        : _fmt(_total);

    return Container(
      decoration: BoxDecoration(color: widget.bgColor, borderRadius: widget.radius),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.chatBubblePaddingV),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: DesignTokens.avatarXs,
              height: DesignTokens.avatarXs,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: DesignTokens.iconMd,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Waveform progress bar
              SizedBox(
                width: 120,
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background bars
                    _WaveformBars(progress: 0.0, color: Colors.white.withValues(alpha: 0.25),
                        amplitudes: widget.media.amplitudes),
                    // Foreground bars (played portion)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: _WaveformBars(progress: 1.0, color: Colors.white.withValues(alpha: 0.9),
                            amplitudes: widget.media.amplitudes),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacing2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(durLabel,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: DesignTokens.fontXs)),
                  const SizedBox(width: DesignTokens.spacing6),
                  GestureDetector(
                    onTap: _cycleSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: DesignTokens.spacing2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignTokens.spacing4),
                      ),
                      child: Text(
                        _speed == 1.0 ? '1×' : _speed == 1.5 ? '1.5×' : '2×',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: DesignTokens.fontXxs,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing6),
                  widget.buildTimestamp(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Waveform bars. Uses real amplitude data when available, static pattern otherwise.
class _WaveformBars extends StatelessWidget {
  final double progress;
  final Color color;
  final List<double>? amplitudes;

  const _WaveformBars({required this.progress, required this.color, this.amplitudes});

  static const _static = [6.0, 10.0, 16.0, 12.0, 20.0, 14.0, 8.0, 18.0,
    22.0, 12.0, 16.0, 8.0, 20.0, 14.0, 10.0, 18.0, 6.0, 14.0, 22.0, 10.0,
    16.0, 8.0, 20.0, 12.0, 18.0, 6.0, 14.0, 22.0, 10.0, 16.0];

  @override
  Widget build(BuildContext context) {
    final heights = amplitudes != null
        // Map 0..1 amplitude to 4..24 px height
        ? amplitudes!.map((v) => 4.0 + v * 20.0).toList()
        : _static;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights.map((h) => Container(
        width: 3,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
        ),
      )).toList(),
    );
  }
}
