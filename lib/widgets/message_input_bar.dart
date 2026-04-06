import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/message.dart';
import '../services/media_service.dart';
import '../l10n/l10n_ext.dart';
import '../utils/platform_utils.dart';

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
  final bool showEmojiPicker;

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
  final VoidCallback onToggleEmojiPicker;
  final VoidCallback? onRecordVideoNote;

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
    this.showEmojiPicker = false,
    required this.onSend,
    required this.onAttach,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
    required this.onCancelReply,
    required this.onCancelEdit,
    required this.onSchedulePicker,
    required this.onShowScheduledPanel,
    required this.onToggleEmojiPicker,
    this.onRecordVideoNote,
  });

  String _replyPreview() {
    final m = replyingTo;
    if (m == null) return '';
    final payload = m.encryptedPayload;
    if (MediaService.isMediaPayload(payload)) {
      final parsed = MediaService.parse(payload);
      if (parsed?.isImage == true) return '📷 Photo';
      if (parsed?.isVoice == true) return '🎙 Voice message';
      if (parsed?.isVideoNote == true) return '🎥 Video message';
      if (parsed?.isGif == true) return 'GIF';
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: DesignTokens.opacityLight), blurRadius: 8, offset: const Offset(0, -1))],
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
              padding: const EdgeInsets.fromLTRB(DesignTokens.spacing4, DesignTokens.spacing4, DesignTokens.spacing6, DesignTokens.spacing8),
              child: isRecording ? _buildRecordingBar(context) : _buildNormalInputBar(context),
            ),
          ],
        ),
      ),
    );
  }

  static const _icon = DesignTokens.iconLg;
  static const _sendSize = 44.0;

  Widget _buildBarIcon(IconData icon, VoidCallback onTap, String label) {
    return Semantics(
      label: label,
      button: true,
      child: _HoverBarIcon(icon: icon, onTap: onTap, size: _icon),
    );
  }

  Widget _buildNormalInputBar(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasText = controller.text.trim().isNotEmpty;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBarIcon(Icons.add, onAttach, context.l10n.inputAttachFile),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignTokens.chatInputRadius),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontInput)
                      .copyWith(fontFamilyFallback: const ['Noto Color Emoji']),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing10),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: hasText
                  ? Semantics(
                      key: const ValueKey('send'),
                      label: context.l10n.inputSendMessage,
                      button: true,
                      child: _HoverSendButton(
                        onTap: onSend,
                        onLongPress: onSchedulePicker,
                        size: _sendSize,
                      ),
                    )
                  : Row(
                      key: const ValueKey('actions'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBarIcon(
                          showEmojiPicker ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
                          onToggleEmojiPicker, 'Emoji',
                        ),
                        if (onRecordVideoNote != null)
                          _buildBarIcon(Icons.camera_alt_outlined, onRecordVideoNote!, context.l10n.videoNoteRecord),
                        _buildBarIcon(Icons.mic_none_rounded, onStartRecording, context.l10n.inputRecordVoice),
                      ],
                    ),
            ),
          ],
        );
      },
    );
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
            color: Colors.red.withValues(alpha: DesignTokens.opacitySubtle),
            borderRadius: BorderRadius.circular(DesignTokens.chatInputRadius),
            border: Border.all(color: Colors.red.withValues(alpha: DesignTokens.opacityMedium)),
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
      duration: const Duration(milliseconds: 400),
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

/// Bar icon with subtle hover tint on desktop.
class _HoverBarIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _HoverBarIcon({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  State<_HoverBarIcon> createState() => _HoverBarIconState();
}

class _HoverBarIconState extends State<_HoverBarIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: PlatformUtils.isDesktop ? (_) => setState(() => _hovering = true) : null,
      onExit: PlatformUtils.isDesktop ? (_) => setState(() => _hovering = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing6, vertical: DesignTokens.spacing10),
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            padding: const EdgeInsets.all(DesignTokens.spacing6),
            decoration: BoxDecoration(
              color: _hovering
                  ? AppTheme.primary.withValues(alpha: DesignTokens.opacitySubtle)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: AppTheme.textSecondary, size: widget.size),
          ),
        ),
      ),
    );
  }
}

/// Send button with subtle hover brighten on desktop.
class _HoverSendButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double size;

  const _HoverSendButton({
    required this.onTap,
    required this.onLongPress,
    required this.size,
  });

  @override
  State<_HoverSendButton> createState() => _HoverSendButtonState();
}

class _HoverSendButtonState extends State<_HoverSendButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: PlatformUtils.isDesktop ? (_) => setState(() => _hovering = true) : null,
      onExit: PlatformUtils.isDesktop ? (_) => setState(() => _hovering = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: const EdgeInsets.only(left: DesignTokens.spacing4),
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _hovering
                  ? Color.lerp(AppTheme.primary, Colors.white, 0.12)!
                  : AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: DesignTokens.iconMd),
          ),
        ),
      ),
    );
  }
}
