import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/chat_tile.dart';
import '../l10n/l10n_ext.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';

class HomeSearchBody extends StatelessWidget {
  final List<Contact> contacts;
  final ChatController chatCtrl;
  final bool isWide;
  final String searchQuery;
  final bool globalSearching;
  final bool globalSearchDone;
  final List<({String roomId, Map<String, dynamic> message})> globalSearchResults;
  final Map<String, Uint8List> avatarCache;
  final Set<String> mutedContactIds;
  final Contact? selectedContact;
  final void Function(Contact) onChatOpen;
  final void Function(Contact) onChatOpenWide;
  final void Function(Offset position, Contact contact, ChatController chatCtrl) onContextMenu;

  const HomeSearchBody({
    super.key,
    required this.contacts,
    required this.chatCtrl,
    required this.isWide,
    required this.searchQuery,
    required this.globalSearching,
    required this.globalSearchDone,
    required this.globalSearchResults,
    required this.avatarCache,
    required this.mutedContactIds,
    required this.selectedContact,
    required this.onChatOpen,
    required this.onChatOpenWide,
    required this.onContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Contact name matches (instant, no decryption needed).
    final contactMatches = contacts
        .where((c) => c.name.toLowerCase().contains(searchQuery))
        .toList();

    // 2. Build a roomId -> Contact lookup for message results.
    final contactByStorageKey = <String, Contact>{};
    for (final c in contacts) {
      contactByStorageKey[c.storageKey] = c;
    }

    // 3. Group message results by roomId.
    final groupedMessages = <String, List<Map<String, dynamic>>>{};
    for (final r in globalSearchResults) {
      groupedMessages.putIfAbsent(r.roomId, () => []).add(r.message);
    }

    // Total section count.
    final hasContactSection = contactMatches.isNotEmpty;
    final hasMessageSection = groupedMessages.isNotEmpty;
    final bool showEmpty = globalSearchDone && !globalSearching &&
        !hasContactSection && !hasMessageSection;

    return ListView(
      padding: const EdgeInsets.only(bottom: DesignTokens.navBarHeight),
      children: [
        // Loading indicator.
        if (globalSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: DesignTokens.iconSm, height: DesignTokens.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing10),
                  Text(context.l10n.homeSearching,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
                ],
              ),
            ),
          ),

        // Contact name matches section.
        if (hasContactSection) ...[
          _buildSectionHeader(context, context.l10n.homeSectionChats),
          ...contactMatches.map((c) {
            final room = chatCtrl.getRoomForContact(c.id);
            final messages = room?.messages ?? [];
            final lastMsg = messages.isNotEmpty ? messages.last : null;
            final myId = chatCtrl.identity?.id ?? '';
            final unread = _getUnreadCount(c.id, myId);
            return ChatTile(
              contact: c,
              lastMsg: lastMsg,
              unreadCount: unread,
              myId: myId,
              isOnline: chatCtrl.isOnline(c.id),
              isMuted: mutedContactIds.contains(c.id),
              avatarBytes: avatarCache[c.id],
              selected: isWide && selectedContact?.id == c.id,
              onTap: () => isWide ? onChatOpenWide(c) : onChatOpen(c),
              onSecondaryTapUp: (details) {
                onContextMenu(details.globalPosition, c, chatCtrl);
              },
            );
          }),
        ],

        // Message search results section.
        if (hasMessageSection) ...[
          _buildSectionHeader(context, context.l10n.homeSectionMessages),
          ...groupedMessages.entries.expand((entry) {
            final contact = contactByStorageKey[entry.key];
            if (contact == null) return <Widget>[];
            return entry.value.map((msgJson) =>
                _buildMessageSearchTile(context, contact, msgJson));
          }),
        ],

        // No results.
        if (showEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: DesignTokens.spacing48,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: DesignTokens.spacing12),
                  Text(context.l10n.homeNoResults,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  int _getUnreadCount(String contactId, String myId) {
    return chatCtrl.getUnreadCount(contactId);
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacing16, DesignTokens.spacing14, DesignTokens.spacing16, DesignTokens.spacing6),
      child: Text(title,
          style: GoogleFonts.inter(
            color: AppTheme.primary,
            fontSize: DesignTokens.fontMd,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )),
    );
  }

  Widget _buildMessageSearchTile(BuildContext context, Contact contact, Map<String, dynamic> msgJson) {
    final payload = msgJson['encryptedPayload'] as String? ?? '';
    final timestampStr = msgJson['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime(2000);
    final timeStr = _formatSearchTime(context, timestamp);

    // Build a snippet with the match highlighted.
    final snippet = _buildSnippet(payload, searchQuery);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isWide) {
            onChatOpenWide(contact);
          } else {
            onChatOpen(contact);
          }
        },
        splashColor: AppTheme.primary.withValues(alpha: 0.07),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing10),
          child: Row(
            children: [
              AvatarWidget(
                name: contact.name,
                size: 44,
                imageBytes: avatarCache[contact.id],
                fontSize: DesignTokens.fontHeading,
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(contact.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontSize: DesignTokens.fontLg,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        Text(timeStr,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: DesignTokens.fontSm,
                            )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: snippet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _buildSnippet(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final idx = lowerText.indexOf(lowerQuery);
    if (idx < 0) {
      // Shouldn't happen, but safety fallback.
      return TextSpan(
        text: text.length > 100 ? '${text.substring(0, 100)}...' : text,
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
      );
    }

    // Show context around the match: up to 20 chars before, the match, then after.
    final start = (idx - 20).clamp(0, text.length);
    final end = (idx + query.length + 40).clamp(0, text.length);
    final prefix = start > 0 ? '...' : '';
    final suffix = end < text.length ? '...' : '';

    final before = text.substring(start, idx);
    final match = text.substring(idx, idx + query.length);
    final after = text.substring(idx + query.length, end);

    return TextSpan(
      children: [
        TextSpan(
          text: '$prefix$before',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
        ),
        TextSpan(
          text: match,
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: DesignTokens.fontMd,
            fontWeight: FontWeight.w700,
            backgroundColor: AppTheme.primary.withValues(alpha: DesignTokens.opacityLight),
          ),
        ),
        TextSpan(
          text: '$after$suffix',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
        ),
      ],
    );
  }

  String _formatSearchTime(BuildContext context, DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(t.year, t.month, t.day);
    if (msgDay == today) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (msgDay == yesterday) return context.l10n.chatYesterday;
    if (now.year == t.year) return '${t.day}/${t.month}';
    return '${t.day}/${t.month}/${t.year % 100}';
  }
}
