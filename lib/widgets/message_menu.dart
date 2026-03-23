import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_pkg;
import '../theme/app_theme.dart';
import '../models/message.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../controllers/chat_controller.dart';
import '../services/media_service.dart';
import '../l10n/l10n_ext.dart';

/// Shows the long-press context menu for a message (reply, forward, react,
/// copy, edit, retry, cancel scheduled, delete).
void showMessageMenu({
  required BuildContext context,
  required Message message,
  required String myId,
  required VoidCallback onReply,
  required void Function(Message) onForward,
  required void Function(String msgId) onShowEmojiPicker,
  required void Function(Message) onDelete,
  required void Function(String id, String text) onEdit,
  required Contact contact,
}) {
  HapticFeedback.mediumImpact();
  final chatController = context.read<ChatController>();
  final isMe = message.senderId == myId;
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(Icons.reply_rounded, color: AppTheme.textSecondary),
            title: Text(context.l10n.menuReply, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              onReply();
            },
          ),
          ListTile(
            leading: Icon(Icons.forward_rounded, color: AppTheme.textSecondary),
            title: Text(context.l10n.menuForward, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              onForward(message);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_reaction_outlined, color: AppTheme.textSecondary),
            title: Text(context.l10n.menuReact, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              onShowEmojiPicker(message.id);
            },
          ),
          ListTile(
            leading: Icon(Icons.copy_rounded, color: AppTheme.textSecondary),
            title: Text(context.l10n.menuCopy, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: message.encryptedPayload));
            },
          ),
          if (isMe && !MediaService.isMediaPayload(message.encryptedPayload))
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppTheme.primary),
              title: Text(context.l10n.menuEdit, style: GoogleFonts.inter(color: AppTheme.primary)),
              onTap: () {
                Navigator.pop(context);
                onEdit(message.id, message.encryptedPayload);
              },
            ),
          if (message.status == 'failed')
            ListTile(
              leading: Icon(Icons.refresh_rounded, color: AppTheme.primary),
              title: Text(context.l10n.menuRetry, style: GoogleFonts.inter(color: AppTheme.primary)),
              onTap: () {
                Navigator.pop(context);
                chatController.retryMessage(contact, message);
              },
            ),
          if (message.status == 'scheduled')
            ListTile(
              leading: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
              title: Text(context.l10n.menuCancelScheduled, style: GoogleFonts.inter(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                chatController.cancelScheduledMessage(contact, message.id);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            title: Text(context.l10n.menuDelete, style: GoogleFonts.inter(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              onDelete(message);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Shows a forward-to-contact picker bottom sheet.
void showForwardPicker({
  required BuildContext context,
  required Message message,
  required Contact currentContact,
  required Widget Function(String name, double size) avatarBuilder,
}) {
  final contacts = context.read<IContactRepository>().contacts
      .where((c) => c.id != currentContact.id)
      .toList();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(context.l10n.menuForwardTo,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (ctx, i) {
                final c = contacts[i];
                return ListTile(
                  leading: avatarBuilder(c.name, 36),
                  title: Text(c.name, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                  subtitle: c.isGroup
                      ? Text(context.l10n.profileGroupLabel,
                          style: GoogleFonts.inter(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600))
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await context.read<ChatController>().sendMessage(c, message.encryptedPayload);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(context.l10n.menuForwardedTo(c.name)),
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Shows an emoji reaction picker bottom sheet with quick reactions + full picker.
void showEmojiPicker({
  required BuildContext context,
  required String messageId,
  required Contact contact,
}) {
  const emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '👎'];
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...emojis.map((emoji) => GestureDetector(
              onTap: () {
                Navigator.pop(sheetCtx);
                context.read<ChatController>().toggleReaction(contact, messageId, emoji);
              },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
              ),
            )),
            GestureDetector(
              onTap: () {
                Navigator.pop(sheetCtx);
                _showFullReactionPicker(context, messageId, contact);
              },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: AppTheme.textSecondary, size: 22),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showFullReactionPicker(BuildContext context, String messageId, Contact contact) {
  // Import done at file level
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: SizedBox(
        height: 340,
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: _FullEmojiReactionPicker(
                onSelected: (emoji) {
                  Navigator.pop(context);
                  context.read<ChatController>().toggleReaction(contact, messageId, emoji);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows the details of who reacted with a given emoji.
void showReactionDetails({
  required BuildContext context,
  required String emoji,
  required List<String> senderIds,
}) {
  final myId = context.read<ChatController>().identity?.id ?? '';
  final names = senderIds.map((id) {
    if (id == myId) return context.l10n.chatYou;
    final c = context.read<IContactRepository>().contacts.cast<Contact?>().firstWhere(
      (c) => c?.databaseId == id || c?.databaseId.split('@').first == id,
      orElse: () => null,
    );
    return c?.name ?? id.substring(0, id.length.clamp(0, 10));
  }).toList();

  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          ...names.map((name) => ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
              child: Text(name[0].toUpperCase(),
                  style: GoogleFonts.inter(
                      color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            title: Text(name, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
          )),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Shows the scheduled messages panel.
void showScheduledPanel({
  required BuildContext context,
  required List<Message> scheduled,
  required Contact contact,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        final items = scheduled.where((m) => m.status == 'scheduled').toList();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(children: [
                  const Icon(Icons.schedule_rounded, size: 18, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(ctx.l10n.menuScheduledMessages,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(ctx.l10n.menuNoScheduledMessages,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final m = items[i];
                      final t = m.scheduledAt;
                      final label = t != null
                          ? '${t.day}/${t.month} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
                          : '';
                      return ListTile(
                        leading: const Icon(Icons.schedule_rounded,
                            color: Colors.amber, size: 20),
                        title: Text(
                          m.encryptedPayload,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: AppTheme.textPrimary, fontSize: 14),
                        ),
                        subtitle: label.isNotEmpty
                            ? Text(ctx.l10n.menuSendsOn(label),
                                style: GoogleFonts.inter(
                                    color: Colors.amber, fontSize: 12))
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel_rounded,
                              color: Colors.redAccent, size: 20),
                          tooltip: ctx.l10n.cancel,
                          onPressed: () async {
                            await context
                                .read<ChatController>()
                                .cancelScheduledMessage(contact, m.id);
                            setLocal(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ),
  );
}

/// Shows the attach options (Photo / Video / File) bottom sheet.
void showAttachMenu({
  required BuildContext context,
  required VoidCallback onPickImage,
  required VoidCallback onPickFile,
  required VoidCallback onPickVideo,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AttachOption(
              icon: Icons.image_rounded,
              label: context.l10n.menuAttachPhoto,
              color: const Color(0xFF4CAF50),
              onTap: () { Navigator.pop(context); onPickImage(); },
            ),
            _AttachOption(
              icon: Icons.videocam_rounded,
              label: context.l10n.menuAttachVideo,
              color: const Color(0xFF9C27B0),
              onTap: () { Navigator.pop(context); onPickVideo(); },
            ),
            _AttachOption(
              icon: Icons.insert_drive_file_rounded,
              label: context.l10n.menuAttachFile,
              color: const Color(0xFF2196F3),
              onTap: () { Navigator.pop(context); onPickFile(); },
            ),
          ],
        ),
      ),
    ),
  );
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }
}

/// Shows the TTL / disappearing messages dialog.
void showTtlDialog({
  required BuildContext context,
  required int currentTtlSeconds,
  required Contact contact,
  required void Function(int seconds) onTtlChanged,
}) {
  final ctrl = context.read<ChatController>();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => StatefulBuilder(
      builder: (ctx, setLocal) {
        final options = [
          (label: ctx.l10n.menuTtlOff, seconds: 0),
          (label: ctx.l10n.menuTtl1h, seconds: 3600),
          (label: ctx.l10n.menuTtl24h, seconds: 86400),
          (label: ctx.l10n.menuTtl7d, seconds: 604800),
        ];
        return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(ctx.l10n.menuDisappearingMessages,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(ctx.l10n.menuDisappearingSubtitle,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
            ),
            ...options.map((opt) => ListTile(
              title: Text(opt.label,
                  style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15)),
              trailing: currentTtlSeconds == opt.seconds
                  ? Icon(Icons.check_rounded, color: AppTheme.primary)
                  : null,
              onTap: () async {
                await ctrl.setChatTtlSeconds(contact, opt.seconds);
                onTtlChanged(opt.seconds);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
        );
      },
    ),
  );
}

class _FullEmojiReactionPicker extends StatelessWidget {
  final void Function(String emoji) onSelected;
  const _FullEmojiReactionPicker({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return emoji_pkg.EmojiPicker(
      onEmojiSelected: (_, emoji) => onSelected(emoji.emoji),
      config: emoji_pkg.Config(
        height: 280,
        emojiViewConfig: emoji_pkg.EmojiViewConfig(
          columns: 8,
          emojiSizeMax: 28,
          backgroundColor: AppTheme.surface,
          noRecents: Text(context.l10n.emojiNoRecent,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ),
        categoryViewConfig: emoji_pkg.CategoryViewConfig(
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary,
          iconColorSelected: AppTheme.primary,
          iconColor: AppTheme.textSecondary,
        ),
        bottomActionBarConfig: const emoji_pkg.BottomActionBarConfig(enabled: false),
        searchViewConfig: emoji_pkg.SearchViewConfig(
          backgroundColor: AppTheme.surface,
          buttonIconColor: AppTheme.textSecondary,
          hintText: context.l10n.emojiSearchHint,
        ),
      ),
    );
  }
}
