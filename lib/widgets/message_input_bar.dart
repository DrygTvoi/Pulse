import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/message.dart';
import '../services/media_service.dart';

/// The bottom input area of the chat screen with text field, attach button,
/// send/mic button, recording indicator, reply/edit banners, and scheduled
/// message count.
class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool inputFocused;
  final bool isRecording;
  final int recordingSeconds;
  final Message? replyingTo;
  final String? editingMessageId;
  final int scheduledCount;

  // Callbacks
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;
  final VoidCallback onCancelReply;
  final VoidCallback onCancelEdit;
  final VoidCallback onSchedulePicker;
  final VoidCallback onShowScheduledPanel;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.inputFocused,
    required this.isRecording,
    required this.recordingSeconds,
    required this.replyingTo,
    required this.editingMessageId,
    required this.scheduledCount,
    required this.onSend,
    required this.onAttach,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
    required this.onCancelReply,
    required this.onCancelEdit,
    required this.onSchedulePicker,
    required this.onShowScheduledPanel,
  });

  String _replyPreview() {
    final m = replyingTo;
    if (m == null) return '';
    final payload = m.encryptedPayload;
    if (MediaService.isMediaPayload(payload)) {
      final parsed = MediaService.parse(payload);
      if (parsed?.isImage == true) return '📷 Photo';
      if (parsed?.isVoice == true) return '🎙 Voice message';
      return '📎 ${parsed?.name ?? 'File'}';
    }
    return payload.length > 60 ? '${payload.substring(0, 60)}…' : payload;
  }

  String _fmtRecording(int s) =>
      '${(s ~/ 60).toString().padLeft(1, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, -1))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (scheduledCount > 0)
              GestureDetector(
                onTap: onShowScheduledPanel,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                  child: Row(children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      '$scheduledCount scheduled message${scheduledCount > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(color: Colors.amber, fontSize: 12),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.amber.withValues(alpha: 0.7)),
                  ]),
                ),
              ),
            if (replyingTo != null)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _replyPreview(),
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: Icon(Icons.close_rounded, size: 14, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            if (editingMessageId != null)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Editing message',
                          style: GoogleFonts.inter(
                              color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    GestureDetector(
                      onTap: onCancelEdit,
                      child: const Icon(Icons.close_rounded, size: 14, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 12),
              child: isRecording ? _buildRecordingBar() : _buildNormalInputBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalInputBar() {
    return Row(children: [
      // Attach button
      GestureDetector(
        onTap: onAttach,
        child: Container(
          width: 42, height: 42,
          margin: const EdgeInsets.only(left: 4, right: 4),
          decoration: BoxDecoration(color: AppTheme.surfaceVariant, shape: BoxShape.circle),
          child: Icon(Icons.attach_file_rounded, color: AppTheme.textSecondary, size: 20),
        ),
      ),
      Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: inputFocused
                  ? AppTheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
            textInputAction: TextInputAction.send,
            minLines: 1,
            maxLines: 5,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Message...',
              hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Mic button (when text field empty) or Send button
      ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final hasText = controller.text.trim().isNotEmpty;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: hasText
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: onSend,
                    onLongPress: onSchedulePicker,
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey('mic'),
                    onTap: onStartRecording,
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic_rounded, color: AppTheme.textSecondary, size: 22),
                    ),
                  ),
          );
        },
      ),
    ]);
  }

  Widget _buildRecordingBar() {
    return Row(children: [
      // Cancel
      GestureDetector(
        onTap: onCancelRecording,
        child: Container(
          width: 42, height: 42,
          margin: const EdgeInsets.only(left: 4, right: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
        ),
      ),
      Expanded(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              // Pulsing red dot
              _PulsingDot(),
              const SizedBox(width: 10),
              Text(
                _fmtRecording(recordingSeconds),
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Text('Recording…',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Send voice
      GestureDetector(
        onTap: onStopRecording,
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    ]);
  }
}

/// Pulsing red dot for the recording indicator.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: _animation.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
