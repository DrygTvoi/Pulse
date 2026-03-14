import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import '../services/media_service.dart';
import '../services/voice_service.dart';
import '../screens/image_viewer_screen.dart';

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
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomRight: Radius.circular(isMe && showTail ? 4 : 18),
      bottomLeft: Radius.circular(!isMe && showTail ? 4 : 18),
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
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                senderName!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _nameColor(senderName!),
                ),
              ),
            ),
          Container(
            margin: EdgeInsets.only(
              left: isMe ? 60 : 0,
              right: isMe ? 0 : 60,
            ),
            // No padding for image bubbles — image fills the bubble
            padding: media?.isImage == true
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                top: 4,
                left: isMe ? 60 : 0,
                right: isMe ? 0 : 60,
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: reactions!.entries.map((entry) {
                  final emoji = entry.key;
                  final count = entry.value.length;
                  return GestureDetector(
                    onTap: () => onReact?.call(emoji),
                    onLongPress: () => onReactLongPress?.call(emoji),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('$count',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (isMe && readBy.isNotEmpty)
            _buildReadByRow(),
        ],
      ),
    );
  }

  Widget _buildReadByRow() {
    // Resolve contactIds to names
    final names = readBy.map((id) {
      final c = ContactManager().contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == id, orElse: () => null);
      return c?.name ?? id.substring(0, id.length.clamp(0, 8));
    }).toList();

    final label = names.length == 1
        ? 'Read by ${names[0]}'
        : names.length == 2
            ? 'Read by ${names[0]} & ${names[1]}'
            : 'Read by ${names.length}';

    return Padding(
      padding: const EdgeInsets.only(top: 2, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all_rounded, size: 11, color: AppTheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500),
          ),
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
          _buildReplyQuote(),
        if (isUnencrypted)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_open_rounded, size: 12, color: Colors.orangeAccent),
              const SizedBox(width: 4),
              Text('NOT ENCRYPTED',
                  style: GoogleFonts.inter(
                    color: Colors.orangeAccent, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5,
                  )),
            ]),
          ),
        _buildLinkedText(context, displayText),
        if (isEdited)
          Text('(edited)',
              style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.45))),
        const SizedBox(height: 3),
        _buildTimestamp(),
      ],
    );
  }

  Widget _buildLinkedText(BuildContext context, String text) {
    final baseStyle = GoogleFonts.inter(color: Colors.white, fontSize: 15, height: 1.35);
    final matches = _urlRegex.allMatches(text).toList();
    if (matches.isEmpty) return Text(text, style: baseStyle);

    final spans = <InlineSpan>[];
    int last = 0;
    for (final m in matches) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final url = m.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: baseStyle.copyWith(
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
          decorationColor: Colors.lightBlueAccent,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _confirmAndLaunchUrl(context, url),
      ));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  static void _confirmAndLaunchUrl(BuildContext context, String url) {
    final display = url.length > 70 ? '${url.substring(0, 70)}…' : url;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Open Link'),
        content: Text('Open this URL in your browser?\n\n$display'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open'),
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
        builder: (ctx) => AlertDialog(
          title: const Text('Security Warning'),
          content: Text(
            '"${media.name}" is an executable file type. '
            'Saving and running it could harm your device. Save anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Save Anyway'),
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
          content: Text('Saved to ${dir.path}', style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppTheme.surfaceVariant,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Save failed: $e', style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: Colors.red.shade900,
        ));
      }
    }
  }

  Widget _buildReplyQuote() {
    // Resolve display text — friendly label for media payloads
    String displayText;
    final replyMedia = MediaService.parse(replyToText!);
    if (replyMedia != null) {
      if (replyMedia.isImage) { displayText = '📷 Photo'; }
      else if (replyMedia.isVoice) { displayText = '🎙 Voice message'; }
      else { displayText = '📎 ${replyMedia.name}'; }
    } else {
      displayText = replyToText!.length > 80 ? '${replyToText!.substring(0, 80)}…' : replyToText!;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(8),
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
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85)),
            ),
          Text(
            displayText,
            style: GoogleFonts.inter(
                fontSize: 11,
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
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.broken_image_rounded, color: Colors.white54, size: 32),
                      SizedBox(height: 6),
                      Text('[Corrupted image]',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
              // Timestamp bar over image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insert_drive_file_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      media.name,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      media.sizeLabel,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _saveFile(context, media),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download_rounded, color: Colors.white70, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              _buildTimestamp(),
            ],
          ),
          if (uploadProgress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
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
        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
      ),
      if (isMe && status.isNotEmpty) ...[
        const SizedBox(width: 4),
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
      case 'read':
        return Icon(Icons.done_all_rounded, size: 13, color: AppTheme.primary);
      case 'failed':
        return const Icon(Icons.error_outline_rounded, size: 13, color: Colors.orangeAccent);
      case 'scheduled':
        return Icon(Icons.schedule_rounded, size: 13, color: Colors.white.withValues(alpha: 0.55));
      default:
        return const SizedBox.shrink();
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(durLabel,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _cycleSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _speed == 1.0 ? '1×' : _speed == 1.5 ? '1.5×' : '2×',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
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
          borderRadius: BorderRadius.circular(2),
        ),
      )).toList(),
    );
  }
}
