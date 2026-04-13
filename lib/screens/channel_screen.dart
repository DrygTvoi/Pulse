import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/channel.dart';
import '../models/channel_post.dart';
import '../services/channel_service.dart';
import '../l10n/l10n_ext.dart';
import '../utils/platform_utils.dart';

class ChannelScreen extends StatefulWidget {
  final Channel channel;
  final bool embedded;
  final VoidCallback? onCloseEmbedded;

  const ChannelScreen({
    super.key,
    required this.channel,
    this.embedded = false,
    this.onCloseEmbedded,
  });

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final ChannelService _service;
  bool _showScrollFab = false;
  bool _searching = false;
  String _searchQuery = '';
  bool _infoPanelOpen = false;
  final Set<String> _viewedPosts = {};

  // Rebuild guards — avoid full-screen rebuild on unrelated ChannelService changes
  List<dynamic>? _lastPostsRef;
  bool _lastLoading = false;

  @override
  void initState() {
    super.initState();
    _service = ChannelService();
    _service.addListener(_onServiceChanged);
    _service.connectFeed(widget.channel.id);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _service.disconnectFeed(widget.channel.id);
    _service.removeListener(_onServiceChanged);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    final newPosts = _service.postsFor(widget.channel.id);
    final newLoading = _service.isLoading(widget.channel.id);
    // Quick identity check — if the list reference changed, posts were mutated
    if (!identical(newPosts, _lastPostsRef) || newLoading != _lastLoading) {
      _lastPostsRef = newPosts;
      _lastLoading = newLoading;
      setState(() {});
    }
  }

  void _onScroll() {
    final showFab = _scrollController.offset > 300;
    if (showFab != _showScrollFab) {
      setState(() => _showScrollFab = showFab);
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_service.hasMore(widget.channel.id) && !_service.isLoading(widget.channel.id)) {
        _service.fetchPosts(widget.channel.id, loadMore: true);
      }
    }
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(t.year, t.month, t.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (now.year == t.year) return '${months[t.month - 1]} ${t.day}';
    return '${months[t.month - 1]} ${t.day}, ${t.year}';
  }

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.dialogRadius),
        ),
        title: Text(
          context.l10n.channelLeave,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.l10n.channelLeaveConfirm,
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.removeChannel(widget.channel.id);
              if (mounted) {
                if (widget.embedded) {
                  widget.onCloseEmbedded?.call();
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: Text(context.l10n.channelLeave,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showChannelInfo(Channel channel) {
    if (PlatformUtils.isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: _ChannelInfoBody(
              channel: channel,
              postCount: _service.postsFor(channel.id).length,
              onLeave: _showLeaveDialog,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: DesignTokens.spacing12),
                width: DesignTokens.avatarXs,
                height: DesignTokens.spacing4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityMedium),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                ),
              ),
              Flexible(
                child: _ChannelInfoBody(
                  channel: channel,
                  postCount: _service.postsFor(channel.id).length,
                  onLeave: _showLeaveDialog,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: DesignTokens.opacityMedium),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
        onPressed: () {
          _searchController.clear();
          setState(() {
            _searching = false;
            _searchQuery = '';
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontXl),
        onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
        decoration: InputDecoration(
          hintText: context.l10n.channelSearchPosts,
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

  PreferredSizeWidget _buildNormalAppBar(Channel channel) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: DesignTokens.opacityMedium),
      leading: widget.embedded
          ? IconButton(
              icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
              onPressed: widget.onCloseEmbedded,
            )
          : IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
      title: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showChannelInfo(channel),
          child: Row(
            children: [
              _ChannelAvatarSmall(name: channel.name, avatarUrl: channel.avatarUrl),
              const SizedBox(width: DesignTokens.spacing10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: DesignTokens.fontXl,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (channel.description.isNotEmpty)
                      Text(
                        channel.description,
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: DesignTokens.fontSm,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
          tooltip: context.l10n.channelSearchPosts,
          onPressed: () => setState(() => _searching = true),
        ),
        IconButton(
          icon: Icon(
            _infoPanelOpen ? Icons.info_rounded : Icons.info_outline_rounded,
            color: _infoPanelOpen ? AppTheme.primary : AppTheme.textSecondary,
          ),
          tooltip: context.l10n.channelInfo,
          onPressed: () => setState(() => _infoPanelOpen = !_infoPanelOpen),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
          color: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          onSelected: (value) {
            if (value == 'leave') _showLeaveDialog();
            if (value == 'info') _showChannelInfo(channel);
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
                  const SizedBox(width: DesignTokens.spacing12),
                  Text(context.l10n.channelInfo,
                      style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'leave',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app_rounded, color: AppTheme.error, size: DesignTokens.iconMd),
                  const SizedBox(width: DesignTokens.spacing12),
                  Text(context.l10n.channelLeave,
                      style: GoogleFonts.inter(color: AppTheme.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = _service.postsFor(widget.channel.id);
    final loading = _service.isLoading(widget.channel.id);
    final channel = _service.channels
        .cast<Channel?>()
        .firstWhere((c) => c?.id == widget.channel.id, orElse: () => null) ?? widget.channel;

    final posts = _searchQuery.isEmpty
        ? allPosts
        : allPosts.where((p) => p.content.toLowerCase().contains(_searchQuery)).toList();

    final feedBody = loading && allPosts.isEmpty
        ? Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          )
        : posts.isEmpty
            ? Center(
                child: Text(
                  _searchQuery.isNotEmpty
                      ? context.l10n.channelNoResults
                      : context.l10n.channelFeedEmpty,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontXl,
                  ),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing12,
                  vertical: DesignTokens.spacing8,
                ),
                itemCount: posts.length + (loading && _searchQuery.isEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(DesignTokens.spacing16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  final post = posts[index];
                  if (_searchQuery.isEmpty && !_viewedPosts.contains(post.id)) {
                    _viewedPosts.add(post.id);
                    _service.recordView(widget.channel.id, post.id);
                  }

                  Widget? dateSeparator;
                  if (index == 0 || _isDifferentDay(post.createdAt, posts[index - 1].createdAt)) {
                    dateSeparator = _buildDateSeparator(post.createdAt);
                  }

                  return Column(
                    children: [
                      if (dateSeparator != null) dateSeparator,
                      _PostCard(
                        post: post,
                        channelUrl: channel.url,
                        reactions: _service.reactionsFor(widget.channel.id, post.id),
                        onReactionTap: (emoji) => _service.toggleReaction(widget.channel.id, post.id, emoji),
                        formatTime: _formatTime,
                        formatViewCount: _formatViewCount,
                        searchQuery: _searchQuery,
                      ),
                    ],
                  );
                },
              );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _searching ? _buildSearchAppBar() : _buildNormalAppBar(channel),
      body: Row(children: [
        Expanded(child: feedBody),
        if (_infoPanelOpen) _buildInfoPanel(channel),
      ]),
      floatingActionButton: _showScrollFab
          ? FloatingActionButton.small(
              backgroundColor: AppTheme.surface,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward_rounded, color: AppTheme.primary),
            )
          : null,
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing12,
            vertical: DesignTokens.spacing4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(DesignTokens.spacing10),
          ),
          child: Text(
            _formatDate(date),
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: DesignTokens.fontSm,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPanel(Channel channel) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 340,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(left: BorderSide(color: AppTheme.surfaceVariant, width: 0.5)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                const SizedBox(width: DesignTokens.spacing14),
                Expanded(
                  child: Text(
                    context.l10n.channelInfo,
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: DesignTokens.fontXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  onPressed: () => setState(() => _infoPanelOpen = false),
                ),
                const SizedBox(width: DesignTokens.spacing4),
              ],
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: AppTheme.surfaceVariant),
          Expanded(
            child: _ChannelInfoBody(
              channel: channel,
              postCount: _service.postsFor(channel.id).length,
              onLeave: _showLeaveDialog,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Channel Info Body ─────────────────────

class _ChannelInfoBody extends StatelessWidget {
  final Channel channel;
  final int postCount;
  final VoidCallback onLeave;

  const _ChannelInfoBody({
    required this.channel,
    required this.postCount,
    required this.onLeave,
  });

  String _formatJoinedDate(int millis) {
    final t = DateTime.fromMillisecondsSinceEpoch(millis);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[t.month - 1]} ${t.day}, ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacing20, DesignTokens.spacing20,
        DesignTokens.spacing20, DesignTokens.spacing32,
      ),
      child: Column(
        children: [
          // Large avatar
          _ChannelAvatarLarge(name: channel.name, avatarUrl: channel.avatarUrl),
          const SizedBox(height: DesignTokens.spacing14),

          // Name
          Text(
            channel.name,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: DesignTokens.fontDisplay,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          // Channel badge
          const SizedBox(height: DesignTokens.spacing6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing10,
              vertical: DesignTokens.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: DesignTokens.opacityLight),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cell_tower_rounded, size: DesignTokens.fontBody, color: AppTheme.primary),
                const SizedBox(width: DesignTokens.spacing4),
                Text(
                  context.l10n.channelInfo,
                  style: GoogleFonts.inter(
                    color: AppTheme.primary,
                    fontSize: DesignTokens.fontBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Description
          if (channel.description.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacing16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.cardPadding),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Text(
                channel.description,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: DesignTokens.fontMd,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Info rows
          const SizedBox(height: DesignTokens.spacing16),
          _infoRow(
            context,
            icon: Icons.link_rounded,
            label: context.l10n.channelUrl,
            value: channel.url,
            onTap: () {
              Clipboard.setData(ClipboardData(text: channel.url));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.l10n.channelCopyUrl),
                duration: const Duration(seconds: 1),
              ));
            },
            trailing: Icon(Icons.copy_rounded, size: DesignTokens.iconSm, color: AppTheme.primary),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          _infoRow(
            context,
            icon: Icons.article_outlined,
            label: context.l10n.channelPostCount(postCount),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          _infoRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: context.l10n.channelCreated,
            value: _formatJoinedDate(channel.createdAt),
          ),

          // Leave button
          const SizedBox(height: DesignTokens.spacing24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onLeave();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.cardPadding),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: DesignTokens.opacitySubtle),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app_rounded, color: AppTheme.error, size: DesignTokens.fontHeading),
                  const SizedBox(width: DesignTokens.spacing8),
                  Text(
                    context.l10n.channelLeave,
                    style: GoogleFonts.inter(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: DesignTokens.fontLg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.cardPadding,
          vertical: DesignTokens.tilePaddingV,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, size: DesignTokens.iconMd, color: AppTheme.textSecondary),
            const SizedBox(width: DesignTokens.spacing12),
            Expanded(
              child: value != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: DesignTokens.fontSm,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(value,
                            style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontSize: DesignTokens.fontMd),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    )
                  : Text(label,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: DesignTokens.fontMd)),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Channel Avatars ─────────────────────

class _ChannelAvatarLarge extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const _ChannelAvatarLarge({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 90,
          height: 90,
          cacheWidth: 180,
          cacheHeight: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final hue = (name.isNotEmpty ? name.codeUnitAt(0) * 17 + name.length * 31 : 0) % 360;
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
            HSLColor.fromAHSL(1, hue.toDouble(), 0.50, 0.30).toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.40).toColor().withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.cell_tower_rounded, color: Colors.white, size: 42),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ChannelPost post;
  final String channelUrl;
  final List<PostReaction> reactions;
  final void Function(String emoji) onReactionTap;
  final String Function(DateTime) formatTime;
  final String Function(int) formatViewCount;
  final String searchQuery;

  const _PostCard({
    required this.post,
    required this.channelUrl,
    required this.reactions,
    required this.onReactionTap,
    required this.formatTime,
    required this.formatViewCount,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: AppTheme.incomingBubble,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DesignTokens.chatBubbleRadius),
              topRight: Radius.circular(DesignTokens.chatBubbleRadius),
              bottomLeft: Radius.circular(DesignTokens.bubbleTailRadius),
              bottomRight: Radius.circular(DesignTokens.chatBubbleRadius),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              if (post.content.isNotEmpty)
                searchQuery.isNotEmpty
                    ? _buildHighlightedText(post.content)
                    : SelectableText(
                        post.content,
                        style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: DesignTokens.fontLg,
                        height: 1.4,
                      ).copyWith(fontFamilyFallback: const ['Noto Color Emoji']),
                    ),

            // Media
            if (post.media.isNotEmpty) ...[
              if (post.content.isNotEmpty) const SizedBox(height: DesignTokens.spacing10),
              _buildMediaGrid(post.media),
            ],

            // Footer
            const SizedBox(height: DesignTokens.spacing10),
            Row(
              children: [
                Text(
                  formatTime(post.createdAt),
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontSm,
                  ),
                ),
                if (post.isEdited) ...[
                  Text(
                    ' \u00b7 ',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
                  ),
                  Text(
                    context.l10n.channelEdited,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: DesignTokens.fontSm,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (post.viewCount > 0) ...[
                  Text(
                    ' \u00b7 ',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
                  ),
                  Icon(Icons.visibility_outlined, size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    formatViewCount(post.viewCount),
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: DesignTokens.fontSm,
                    ),
                  ),
                ],
                const Spacer(),
                // Reaction chips
                ...reactions.map((r) => Padding(
                  padding: const EdgeInsets.only(left: DesignTokens.spacing4),
                  child: InkWell(
                    onTap: () => onReactionTap(r.emoji),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${r.emoji} ${r.count}',
                        style: GoogleFonts.inter(fontSize: DesignTokens.fontSm),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + searchQuery.length),
        style: TextStyle(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.3),
          fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + searchQuery.length;
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: DesignTokens.fontLg,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildMediaGrid(List<String> mediaUrls) {
    final urls = mediaUrls.map((u) {
      if (u.startsWith('http')) return u;
      return '$channelUrl/media/$u';
    }).toList();

    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          urls[0],
          width: double.infinity,
          cacheWidth: 600,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _mediaError(),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: urls.map((url) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          cacheWidth: 400,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _mediaError(),
        ),
      )).toList(),
    );
  }

  Widget _mediaError() {
    return Container(
      height: 100,
      color: AppTheme.surfaceVariant,
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: AppTheme.textSecondary),
      ),
    );
  }
}

class _ChannelAvatarSmall extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const _ChannelAvatarSmall({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 36,
          height: 36,
          cacheWidth: 72,
          cacheHeight: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            color: AppTheme.primary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
