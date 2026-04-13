import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Skeleton/shimmer loading placeholder for the chat list.
/// Shows 7 placeholder tiles that pulse with a shimmer animation.
class ChatListSkeleton extends StatefulWidget {
  const ChatListSkeleton({super.key});

  @override
  State<ChatListSkeleton> createState() => _ChatListSkeletonState();
}

class _ChatListSkeletonState extends State<ChatListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing8),
      itemBuilder: (context, index) {
        return _SkeletonTile(animation: _ctrl);
      },
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  final Animation<double> animation;
  const _SkeletonTile({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16, vertical: DesignTokens.spacing6),
      child: Row(
        children: [
          // Avatar circle
          _shimmerBox(width: 54, height: 54, circular: true),
          const SizedBox(width: DesignTokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name placeholder
                _shimmerBox(width: 120, height: 14),
                const SizedBox(height: DesignTokens.spacing8),
                // Message preview placeholder
                _shimmerBox(width: double.infinity, height: 12),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          // Timestamp placeholder
          _shimmerBox(width: 40, height: 10),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    bool circular = false,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: circular
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(DesignTokens.radiusXs),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * animation.value, 0),
              end: Alignment(-1.0 + 2 * animation.value + 1, 0),
              colors: [
                AppTheme.surface,
                AppTheme.surfaceVariant.withValues(alpha: 0.5),
                AppTheme.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}
