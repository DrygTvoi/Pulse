import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import 'avatar_widget.dart';

/// Maps provider name to icon + color
Map<String, ({IconData icon, Color color})> _providerMeta = {
  'Firebase': (icon: Icons.local_fire_department_rounded, color: const Color(0xFFFFAB00)),
  'Nostr':    (icon: Icons.bolt_rounded,                  color: const Color(0xFF9B59B6)),
  'group':    (icon: Icons.group_rounded,                  color: const Color(0xFF26A69A)),
};

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final String? subtitleOverride;
  final String? trailing;
  final bool isE2eeActive;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.subtitleOverride,
    this.trailing,
    this.isE2eeActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primary.withValues(alpha: 0.08),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trailing != null)
                          Text(
                            trailing!,
                            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildProviderBadge(),
                        const SizedBox(width: 6),
                        if (isE2eeActive) ...[
                          Icon(Icons.lock_rounded, size: 11, color: AppTheme.primary),
                          const SizedBox(width: 3),
                          Text('E2EE',
                              style: GoogleFonts.inter(
                                  color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            subtitleOverride ?? 'Tap to chat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
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

  Widget _buildProviderBadge() {
    final meta = _providerMeta[contact.provider] ??
        (icon: Icons.cloud_rounded, color: AppTheme.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 10, color: meta.color),
          const SizedBox(width: 3),
          Text(
            _shortName(contact.provider),
            style: GoogleFonts.inter(color: meta.color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _shortName(String provider) {
    if (provider == 'group') return 'Group';
    return provider;
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AvatarWidget(name: contact.name, size: 52, fontSize: 21),
        // Group indicator
        if (contact.isGroup)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_rounded, size: 12, color: AppTheme.primary),
            ),
          ),
      ],
    );
  }
}
