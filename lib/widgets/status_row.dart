import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import '../models/user_status.dart';
import 'avatar_widget.dart';

/// Horizontal scrollable row of status avatars (own + contacts with active statuses).
class StatusRow extends StatelessWidget {
  final List<Contact> contacts;
  final UserStatus? ownStatus;
  final Map<String, UserStatus> contactStatuses;
  final VoidCallback onOwnStatusTap;
  final void Function(Contact contact, List<Contact> contactsWithStatus) onContactStatusTap;

  const StatusRow({
    super.key,
    required this.contacts,
    required this.ownStatus,
    required this.contactStatuses,
    required this.onOwnStatusTap,
    required this.onContactStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final nonGroupContacts = contacts.where((c) => !c.isGroup).toList();
    final contactsWithStatus = nonGroupContacts
        .where((c) => contactStatuses.containsKey(c.id))
        .toList();
    final hasAnyStatus = ownStatus != null || contactsWithStatus.isNotEmpty;

    if (!hasAnyStatus) return const SizedBox.shrink();

    return Container(
      color: AppTheme.surface,
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        children: [
          // Own status item
          _StatusAvatar(
            name: 'My Status',
            initial: '+',
            hasStatus: ownStatus != null,
            isOwn: true,
            onTap: onOwnStatusTap,
          ),
          // Contacts with active statuses
          ...contactsWithStatus.map((c) {
            return _StatusAvatar(
              name: c.name,
              initial: c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
              hasStatus: true,
              isOwn: false,
              onTap: () => onContactStatusTap(c, contactsWithStatus),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusAvatar extends StatelessWidget {
  final String name;
  final String initial;
  final bool hasStatus;
  final bool isOwn;
  final VoidCallback onTap;

  const _StatusAvatar({
    required this.name,
    required this.initial,
    required this.hasStatus,
    required this.isOwn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: hasStatus
                    ? Border.all(color: AppTheme.primary, width: 2.5)
                    : Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: isOwn
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary.withValues(alpha: 0.7), AppTheme.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(initial,
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22)),
                        ),
                      )
                    : AvatarWidget(name: name, size: 44, fontSize: 18),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 58,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
