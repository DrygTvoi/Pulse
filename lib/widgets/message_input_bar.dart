import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/message.dart';
import '../services/media_service.dart';
import '../l10n/l10n_ext.dart';

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
                  padding: const EdgeInsets.fromLTRB(DesignTokens.spacing14, DesignTokens.spacing6, DesignTokens.spacing14, 0),
                  child: Row(children: [
                    const Icon(Icons.schedule_rounded, size: DesignTokens.fontMd, color: Colors.amber),
                    const SizedBox(width: DesignTokens.spacing6),
                    Text(
                      context.l10n.inputScheduledMessages(scheduledCount),
                      style: GoogleFonts.inter(color: Colors.amber, fontSize: DesignTokens.fontBody),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, size: DesignTokens.fontLg, color: Colors.amber.withValues(alpha: 0.7)),
                  ]),
                ),
              ),
            if (replyingTo != null)
              Container(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacing14, DesignTokens.spacing6, DesignTokens.spacing14, 0),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: DesignTokens.fontLg, color: AppTheme.primary),
                    const SizedBox(width: DesignTokens.spacing6),
                    Expanded(
                      child: Text(
                        _replyPreview(),
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Semantics(
                      label: context.l10n.inputCancelReply,
                      button: true,
                      child: GestureDetector(
                        onTap: onCancelReply,
                        child: Icon(Icons.close_rounded, size: DesignTokens.fontLg, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            if (editingMessageId != null)
              Container(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacing14, DesignTokens.spacing6, DesignTokens.spacing14, 0),
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: DesignTokens.fontLg, color: Colors.amber),
                    const SizedBox(width: DesignTokens.spacing6),
                    Expanded(
                      child: Text(context.l10n.inputEditingMessage,
                          style: GoogleFonts.inter(
                              color: Colors.amber, fontSize: DesignTokens.fontBody, fontWeight: FontWeight.w500)),
                    ),
                    Semantics(
                      label: context.l10n.inputCancelEdit,
                      button: true,
                      child: GestureDetector(
                        onTap: onCancelEdit,
                        child: const Icon(Icons.close_rounded, size: DesignTokens.fontLg, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spacing8, DesignTokens.spacing6, DesignTokens.spacing12, DesignTokens.spacing12),
              child: isRecording ? _buildRecordingBar(context) : _buildNormalInputBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalInputBar(BuildContext context) {
    return Row(children: [
      // Attach button
      Semantics(
        label: context.l10n.inputAttachFile,
        button: true,
        child: GestureDetector(
          onTap: onAttach,
          child: Container(
            width: 42, height: 42,
            margin: const EdgeInsets.only(left: DesignTokens.spacing4, right: DesignTokens.spacing4),
            decoration: BoxDecoration(color: AppTheme.surfaceVariant, shape: BoxShape.circle),
            child: Icon(Icons.attach_file_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
          ),
        ),
      ),
      Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(DesignTokens.chatInputRadius),
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
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontInput),
            textInputAction: TextInputAction.send,
            minLines: 1,
            maxLines: 5,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: context.l10n.inputMessage,
              hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontInput),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.chatInputPaddingH, vertical: DesignTokens.chatInputPaddingV),
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ),
      const SizedBox(width: DesignTokens.spacing8),
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
                ? Semantics(
                    label: context.l10n.inputSendMessage,
                    button: true,
                    child: GestureDetector(
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
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: DesignTokens.iconMd),
                      ),
                    ),
                  )
                : Semantics(
                    label: context.l10n.inputRecordVoice,
                    button: true,
                    child: GestureDetector(
                      key: const ValueKey('mic'),
                      onTap: onStartRecording,
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mic_rounded, color: AppTheme.textSecondary, size: DesignTokens.fontDisplay),
                      ),
                    ),
                  ),
          );
        },
      ),
    ]);
  }

  Widget _buildRecordingBar(BuildContext context) {
    return Row(children: [
      // Cancel
      Semantics(
        label: context.l10n.inputCancelRecording,
        button: true,
        child: GestureDetector(
          onTap: onCancelRecording,
          child: Container(
            width: 42, height: 42,
            margin: const EdgeInsets.only(left: DesignTokens.spacing4, right: DesignTokens.spacing8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: DesignTokens.iconMd),
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DesignTokens.chatInputRadius),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(width: DesignTokens.spacing14),
              // Pulsing red dot
              const _PulsingDot(),
              const SizedBox(width: DesignTokens.spacing10),
              Text(
                _fmtRecording(recordingSeconds),
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.red, fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: DesignTokens.spacing10),
              Text(context.l10n.inputRecording,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
            ],
          ),
        ),
      ),
      const SizedBox(width: DesignTokens.spacing8),
      // Send voice
      Semantics(
        label: context.l10n.inputSendVoice,
        button: true,
        child: GestureDetector(
          onTap: onStopRecording,
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: DesignTokens.iconMd),
          ),
        ),
      ),
    ]);
  }
}

/// Pulsing red dot for the recording indicator.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

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
        width: DesignTokens.spacing8, height: DesignTokens.spacing8,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: _animation.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
