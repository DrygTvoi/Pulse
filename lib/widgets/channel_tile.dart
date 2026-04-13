import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/channel.dart';
import '../utils/platform_utils.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  final String? latestPostPreview;
  final DateTime? latestPostTime;
  final bool selected;
  final VoidCallback onTap;

  const ChannelTile({
    super.key,
    required this.channel,
    this.latestPostPreview,
    this.latestPostTime,
    this.selected = false,
    required this.onTap,
  });

  String _formatTime(BuildContext context, DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(t.year, t.month, t.day);
    if (msgDay == today) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (msgDay == yesterday) return 'Yesterday';
    if (now.year == t.year) return '${t.day}/${t.month}';
    return '${t.day}/${t.month}/${t.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = latestPostPreview ?? channel.description;
    final timeStr = latestPostTime != null ? _formatTime(context, latestPostTime!) : null;
    final avatarSize = PlatformUtils.isDesktop ? DesignTokens.avatarMdDesktop : DesignTokens.avatarMd;

    return GestureDetector(
      child: Material(
        color: selected ? AppTheme.primary.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          hoverColor: AppTheme.primary.withValues(alpha: 0.04),
          splashColor: AppTheme.primary.withValues(alpha: 0.07),
          highlightColor: AppTheme.primary.withValues(alpha: 0.04),
          child: Row(
            children: [
              AnimatedContainer(
                duration: DesignTokens.durationFast,
                width: selected ? 3 : 0,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing12,
                        vertical: DesignTokens.spacing8,
                      ),
                      child: Row(
                        children: [
                          // Channel avatar with broadcast badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _ChannelAvatar(
                                name: channel.name,
                                avatarUrl: channel.avatarUrl,
                                size: avatarSize,
                              ),
                              Positioned(
                                bottom: -1,
                                right: -1,
                                child: Container(
                                  padding: const EdgeInsets.all(DesignTokens.spacing2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.cell_tower_rounded,
                                    size: DesignTokens.fontMd,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: DesignTokens.spacing14),
                          // Text info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        channel.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: AppTheme.textPrimary,
                                          fontSize: DesignTokens.fontXl,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (timeStr != null)
                                      Text(
                                        timeStr,
                                        style: GoogleFonts.inter(
                                          color: AppTheme.textSecondary,
                                          fontSize: DesignTokens.fontBody,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textSecondary,
                                    fontSize: DesignTokens.fontMd,
                                  ).copyWith(fontFamilyFallback: const ['Noto Color Emoji']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Padding(
                      padding: EdgeInsets.only(left: avatarSize + DesignTokens.spacing12 + DesignTokens.spacing14),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                      ),
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
}

class _ChannelAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double size;

  const _ChannelAvatar({
    required this.name,
    required this.avatarUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: (size * 2).toInt(),
          cacheHeight: (size * 2).toInt(),
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            color: AppTheme.primary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
