import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../l10n/l10n_ext.dart';

class PulseBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadChats;

  const PulseBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadChats = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DesignTokens.navBarHeight,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.surfaceVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            context,
            index: 0,
            activeIcon: Icons.chat,
            inactiveIcon: Icons.chat_outlined,
            label: context.l10n.navChats,
            badge: unreadChats,
          ),
          _buildTab(
            context,
            index: 1,
            activeIcon: Icons.update,
            inactiveIcon: Icons.update_outlined,
            label: context.l10n.navUpdates,
          ),
          _buildTab(
            context,
            index: 2,
            activeIcon: Icons.call,
            inactiveIcon: Icons.call_outlined,
            label: context.l10n.navCalls,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    int badge = 0,
  }) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.navBarIndicatorRadius),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? activeIcon : inactiveIcon,
                    color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                    size: DesignTokens.iconLg,
                  ),
                  if (badge > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge > 99 ? '99+' : '$badge',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: DesignTokens.fontXxs,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: DesignTokens.fontBody,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
