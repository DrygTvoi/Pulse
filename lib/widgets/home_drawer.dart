import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/avatar_widget.dart';
import '../l10n/l10n_ext.dart';
import '../controllers/chat_controller.dart';

class HomeDrawer extends StatelessWidget {
  final String ownName;
  final Uint8List? ownAvatarBytes;
  final ConnectionStatus connectionStatus;
  final VoidCallback onNewChat;
  final VoidCallback onNewGroup;
  final VoidCallback onAddContact;
  final VoidCallback onSettings;
  final bool torRunning;
  final int torBootPercent;
  final String torPtLabel;
  final bool showNoEch;

  const HomeDrawer({
    super.key,
    required this.ownName,
    required this.ownAvatarBytes,
    required this.connectionStatus,
    required this.onNewChat,
    required this.onNewGroup,
    required this.onAddContact,
    required this.onSettings,
    this.torRunning = false,
    this.torBootPercent = 0,
    this.torPtLabel = '',
    this.showNoEch = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75 < 300 ? screenWidth * 0.75 : 300.0;
    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: AppTheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: avatar + name + connection dot
              GestureDetector(
                onTap: onSettings,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacing16, DesignTokens.spacing20,
                    DesignTokens.spacing16, DesignTokens.spacing16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.surfaceVariant, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64, height: 64,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarWidget(
                              name: ownName.isNotEmpty ? ownName : 'Me',
                              size: 64,
                              imageBytes: ownAvatarBytes,
                            ),
                            Positioned(
                              right: 0, bottom: 0,
                              child: _buildConnectionDot(context, connectionStatus),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ownName.isNotEmpty ? ownName : 'Me',
                              style: AppTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (torRunning || showNoEch) ...[
                              const SizedBox(height: DesignTokens.spacing4),
                              Wrap(
                                spacing: DesignTokens.spacing4,
                                children: [
                                  if (torRunning) _buildTorBadge(),
                                  if (showNoEch) _buildNoEchBadge(),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: DesignTokens.spacing8),
              // Menu items
              ListTile(
                leading: Icon(Icons.chat_rounded, color: AppTheme.textSecondary),
                title: Text(context.l10n.homeNewChat, style: AppTheme.menuItem),
                onTap: onNewChat,
              ),
              ListTile(
                leading: Icon(Icons.group_add_rounded, color: AppTheme.textSecondary),
                title: Text(context.l10n.contactsNewGroup, style: AppTheme.menuItem),
                onTap: onNewGroup,
              ),
              ListTile(
                leading: Icon(Icons.person_add_rounded, color: AppTheme.textSecondary),
                title: Text(context.l10n.contactsAddContact, style: AppTheme.menuItem),
                onTap: onAddContact,
              ),
              Divider(color: AppTheme.surfaceVariant, height: 1),
              ListTile(
                leading: Icon(Icons.settings_rounded, color: AppTheme.textSecondary),
                title: Text(context.l10n.settingsTitle, style: AppTheme.menuItem),
                onTap: onSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTorBadge() {
    final isActive = torBootPercent == 100;
    final color = isActive ? AppTheme.primary : Colors.orange;
    final ptSuffix = switch (torPtLabel) {
      'obfs4'     => '\u00B7obfs4',
      'snowflake' => '\u00B7SF',
      'webtunnel' => '\u00B7WT',
      _           => '',
    };
    final label = isActive ? 'Tor$ptSuffix' : 'Tor $torBootPercent%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security_rounded, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildNoEchBadge() {
    final color = Colors.amber.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text('No ECH', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildConnectionDot(BuildContext context, ConnectionStatus status) {
    final label = switch (status) {
      ConnectionStatus.connected   => context.l10n.connected,
      ConnectionStatus.connecting  => context.l10n.connecting,
      ConnectionStatus.disconnected => context.l10n.disconnected,
    };
    if (status == ConnectionStatus.connecting) {
      return Tooltip(
        message: label,
        child: SizedBox(
          width: 9, height: 9,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.orange),
        ),
      );
    }
    return Tooltip(
      message: label,
      child: Container(
        width: DesignTokens.spacing8, height: DesignTokens.spacing8,
        decoration: BoxDecoration(
          color: status == ConnectionStatus.connected ? AppTheme.primary : AppTheme.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
