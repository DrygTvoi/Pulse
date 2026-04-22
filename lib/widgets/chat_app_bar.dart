import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../controllers/chat_controller.dart';
import '../screens/call_screen.dart';
import '../screens/group_call_screen.dart';
import '../screens/media_gallery_screen.dart';
import '../services/notification_service.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/message_menu.dart' as menu;
import '../l10n/l10n_ext.dart';

/// Builds the normal (non-search) AppBar for the chat screen.
PreferredSizeWidget buildChatAppBar({
  required BuildContext context,
  required Contact contact,
  required String myId,
  required bool chatMuted,
  required int chatTtlSeconds,
  required VoidCallback onOpenProfile,
  required VoidCallback onSearchActivate,
  required void Function(bool muted) onMuteChanged,
  required void Function(int seconds) onTtlChanged,
  Uint8List? avatarBytes,
  bool embedded = false,
  bool infoPanelOpen = false,
  VoidCallback? onToggleInfoPanel,
}) {
  // Granular selectors — only rebuild when THIS contact's status changes,
  // not on every ChatController notification.
  final isOnline = context.select<ChatController, bool>((c) => c.isOnline(contact.id));
  final lastSeen = context.select<ChatController, String>((c) => c.lastSeenLabel(contact.id));
  final hasPqc = context.select<ChatController, bool>((c) => c.hasPqcKey(contact.databaseId));

  return AppBar(
    backgroundColor: AppTheme.surface,
    elevation: 0,
    scrolledUnderElevation: 2.0,
    shadowColor: Colors.black.withValues(alpha: DesignTokens.opacityMedium),
    titleSpacing: embedded ? DesignTokens.spacing16 : 0,
    automaticallyImplyLeading: !embedded,
    leading: embedded
        ? null
        : IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
            tooltip: context.l10n.back,
            onPressed: () => Navigator.pop(context),
          ),
    title: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onOpenProfile,
        child: Row(children: [
        if (embedded)
          AvatarWidget(name: contact.name, size: DesignTokens.avatarSm, imageBytes: avatarBytes)
        else
          Hero(tag: 'contact_avatar_${contact.id}', child: AvatarWidget(name: contact.name, size: DesignTokens.avatarSm, imageBytes: avatarBytes)),
        const SizedBox(width: DesignTokens.spacing10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(contact.name,
                  style: GoogleFonts.inter(fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              isOnline
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: DesignTokens.spacing8, height: DesignTokens.spacing8,
                              decoration: BoxDecoration(
                                  color: AppTheme.online, shape: BoxShape.circle)),
                          const SizedBox(width: DesignTokens.spacing4),
                          Text(context.l10n.appBarOnline,
                              style: GoogleFonts.inter(fontSize: DesignTokens.fontSm, color: AppTheme.online)),
                        ])
                      : lastSeen.isNotEmpty
                          ? Text(lastSeen,
                              style: GoogleFonts.inter(fontSize: DesignTokens.fontSm, color: AppTheme.textSecondary))
                          : Row(children: [
                              Text(context.l10n.appBarEncrypted,
                                  style: GoogleFonts.inter(fontSize: DesignTokens.fontSm, color: AppTheme.textSecondary)),
                              if (hasPqc) ...[
                                const SizedBox(width: DesignTokens.spacing4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A6B3C),
                                    borderRadius: BorderRadius.circular(DesignTokens.spacing4),
                                  ),
                                  child: Text(context.l10n.appBarKyber,
                                      style: GoogleFonts.inter(fontSize: DesignTokens.fontXxs, color: const Color(0xFF4ADE80), fontWeight: FontWeight.w700)),
                                ),
                              ],
                              const SizedBox(width: DesignTokens.spacing6),
                              _buildProviderBadge(contact.provider),
                            ]),
            ],
          ),
        ),
      ]),
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
        tooltip: context.l10n.appBarSearchTooltip,
        onPressed: onSearchActivate,
      ),
      IconButton(
        icon: Icon(Icons.call_outlined, color: AppTheme.textSecondary),
        tooltip: context.l10n.appBarVoiceCall,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => contact.isGroup
              ? GroupCallScreen(group: contact, myId: myId, isCaller: true)
              : CallScreen(contact: contact, myId: myId, isCaller: true),
        )),
      ),
      if (embedded && onToggleInfoPanel != null)
        IconButton(
          icon: Icon(
            infoPanelOpen ? Icons.view_sidebar_rounded : Icons.view_sidebar_outlined,
            color: infoPanelOpen ? AppTheme.primary : AppTheme.textSecondary,
          ),
          tooltip: infoPanelOpen ? context.l10n.close : context.l10n.moreOptions,
          onPressed: onToggleInfoPanel,
        ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
        tooltip: context.l10n.moreOptions,
        color: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLarge)),
        onSelected: (value) async {
          if (value == 'search') onSearchActivate();
          if (value == 'timer') {
            menu.showTtlDialog(
              context: context,
              currentTtlSeconds: chatTtlSeconds,
              contact: contact,
              onTtlChanged: onTtlChanged,
            );
          }
          if (value == 'admin') onOpenProfile();
          if (value == 'media') {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => MediaGalleryScreen(contact: contact),
            ));
          }
          if (value == 'mute') {
            final newMuted = !chatMuted;
            await NotificationService().setChatMuted(contact.id, newMuted);
            onMuteChanged(newMuted);
          }
          if (value == 'clear_history') {
            final ctrl = context.read<ChatController>();
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog.adaptive(
                backgroundColor: AppTheme.surface,
                title: Text(ctx.l10n.clearChatTitle,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700)),
                content: Text(ctx.l10n.clearChatBody,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(ctx.l10n.cancel,
                        style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(ctx.l10n.clearChatAction,
                        style: GoogleFonts.inter(color: AppTheme.error)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ctrl.clearRoomHistory(contact);
            }
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'mute',
            child: Row(children: [
              Icon(
                chatMuted ? Icons.notifications_rounded : Icons.notifications_off_rounded,
                color: chatMuted ? AppTheme.primary : AppTheme.textSecondary,
                size: DesignTokens.iconMd,
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Text(
                chatMuted ? context.l10n.appBarUnmute : context.l10n.appBarMute,
                style: GoogleFonts.inter(color: AppTheme.textPrimary),
              ),
            ]),
          ),
          PopupMenuItem(
            value: 'media',
            child: Row(children: [
              Icon(Icons.photo_library_outlined,
                  color: AppTheme.textSecondary, size: DesignTokens.iconMd),
              const SizedBox(width: DesignTokens.spacing12),
              Text(context.l10n.appBarMedia, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            ]),
          ),
          PopupMenuItem(
            value: 'timer',
            child: Row(children: [
              Icon(
                Icons.timer_outlined,
                color: chatTtlSeconds > 0 ? AppTheme.primary : AppTheme.textSecondary,
                size: DesignTokens.iconMd,
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Text(
                chatTtlSeconds > 0 ? context.l10n.appBarDisappearingOn : context.l10n.appBarDisappearing,
                style: GoogleFonts.inter(color: AppTheme.textPrimary),
              ),
            ]),
          ),
          if (contact.isGroup)
            PopupMenuItem(
              value: 'admin',
              child: Row(children: [
                Icon(Icons.admin_panel_settings_rounded,
                    color: AppTheme.textSecondary, size: DesignTokens.iconMd),
                const SizedBox(width: DesignTokens.spacing12),
                Text(context.l10n.appBarGroupSettings, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
              ]),
            ),
          PopupMenuItem(
            value: 'clear_history',
            child: Row(children: [
              Icon(Icons.delete_sweep_outlined,
                  color: AppTheme.error, size: DesignTokens.iconMd),
              const SizedBox(width: DesignTokens.spacing12),
              Text(context.l10n.menuClearChatHistory,
                  style: GoogleFonts.inter(color: AppTheme.error)),
            ]),
          ),
        ],
      ),
      const SizedBox(width: DesignTokens.spacing4),
    ],
  );
}

/// Builds the search-mode AppBar for the chat screen.
PreferredSizeWidget buildSearchAppBar({
  required BuildContext context,
  required TextEditingController searchController,
  required void Function(String query) onSearchChanged,
  required VoidCallback onSearchClose,
}) {
  return AppBar(
    backgroundColor: AppTheme.surface,
    elevation: 0,
    scrolledUnderElevation: 2.0,
    shadowColor: Colors.black.withValues(alpha: DesignTokens.opacityMedium),
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
      tooltip: context.l10n.closeSearch,
      onPressed: () {
        searchController.clear();
        onSearchClose();
      },
    ),
    title: TextField(
      controller: searchController,
      autofocus: true,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontXl),
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: context.l10n.searchMessages,
        hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontXl),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        filled: false,
      ),
    ),
  );
}

/// Builds a gradient circle avatar from a name.
Widget buildChatAvatar(String name, double size) {
  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
  final hue = (name.isNotEmpty ? name.codeUnitAt(0) * 17 + name.length * 31 : 180) % 360;
  return Container(
    width: size, height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          HSLColor.fromAHSL(1, hue.toDouble(), 0.65, 0.50).toColor(),
          HSLColor.fromAHSL(1, hue.toDouble(), 0.6, 0.38).toColor(),
        ],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
    ),
    child: Center(child: Text(initial,
        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.42))),
  );
}

Widget _buildProviderBadge(String provider) {
  final meta = {
    'Firebase': (icon: Icons.local_fire_department_rounded, color: AppTheme.providerFirebase),
    'Nostr': (icon: Icons.bolt_rounded, color: AppTheme.providerNostr),
    'group': (icon: Icons.group_rounded, color: AppTheme.providerPulse),
  };
  final m = meta[provider];
  if (m == null) return const SizedBox.shrink();
  final label = provider == 'group' ? 'Group' : provider;
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(m.icon, size: DesignTokens.fontXs, color: m.color),
    const SizedBox(width: DesignTokens.spacing2),
    Text(label,
        style: GoogleFonts.inter(color: m.color, fontSize: DesignTokens.fontXs, fontWeight: FontWeight.w600)),
  ]);
}

