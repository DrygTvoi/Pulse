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
      height: 36 + 16,
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
    return _ScaleOnTapChip(
      isActive: isActive,
      label: label,
      onTap: () => onChanged(filter),
    );
  }
}

class _ScaleOnTapChip extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _ScaleOnTapChip({
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ScaleOnTapChip> createState() => _ScaleOnTapChipState();
}

class _ScaleOnTapChipState extends State<_ScaleOnTapChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: DesignTokens.durationFast,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: widget.isActive ? AppTheme.primary : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(DesignTokens.filterChipRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: widget.isActive ? Colors.white : AppTheme.textSecondary,
              fontSize: DesignTokens.fontMd,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
