import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../l10n/l10n_ext.dart';

enum ChatFilter { all, unread, groups }

class ChatFilterChips extends StatelessWidget {
  final ChatFilter selected;
  final ValueChanged<ChatFilter> onChanged;

  const ChatFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DesignTokens.filterChipHeight + 16,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing12,
          vertical: 8,
        ),
        children: [
          _buildChip(context, ChatFilter.all, context.l10n.filterAll),
          const SizedBox(width: DesignTokens.spacing8),
          _buildChip(context, ChatFilter.unread, context.l10n.filterUnread),
          const SizedBox(width: DesignTokens.spacing8),
          _buildChip(context, ChatFilter.groups, context.l10n.filterGroups),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, ChatFilter filter, String label) {
    final isActive = selected == filter;
    return GestureDetector(
      onTap: () => onChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: DesignTokens.filterChipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(DesignTokens.filterChipRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontSize: DesignTokens.fontMd,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
