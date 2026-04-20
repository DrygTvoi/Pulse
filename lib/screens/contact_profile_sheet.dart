import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../services/signal_service.dart';
import '../controllers/chat_controller.dart';
import '../l10n/l10n_ext.dart';
import 'package:provider/provider.dart';
import '../models/contact_repository.dart';
import '../utils/adaptive_sheet.dart';
import '../utils/platform_utils.dart';
import 'verify_identity_screen.dart';

/// Bottom sheet showing contact or group profile.
/// For groups: shows member list with optional kick button.
Future<void> showContactProfile(
  BuildContext context,
  Contact contact, {
  bool isAdmin = false,
  void Function(Contact updated)? onContactUpdated,
  void Function()? onDeleteContact,
  void Function()? onClearHistory,
}) {
  if (PlatformUtils.isDesktop) {
    return showDialog<void>(
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
          child: _ContactProfileSheet(
            contact: contact,
            isAdmin: isAdmin,
            onContactUpdated: onContactUpdated,
            onDeleteContact: onDeleteContact,
            onClearHistory: onClearHistory,
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ContactProfileSheet(
      contact: contact,
      isAdmin: isAdmin,
      onContactUpdated: onContactUpdated,
      onDeleteContact: onDeleteContact,
      onClearHistory: onClearHistory,
    ),
  );
}

class _ContactProfileSheet extends StatelessWidget {
  final Contact contact;
  final bool isAdmin;
  final void Function(Contact updated)? onContactUpdated;
  final void Function()? onDeleteContact;
  final void Function()? onClearHistory;

  const _ContactProfileSheet({
    required this.contact,
    required this.isAdmin,
    this.onContactUpdated,
    this.onDeleteContact,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.dialogPadding)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (PlatformUtils.isMobile)
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
            child: ContactProfileBody(
              contact: contact,
              isAdmin: isAdmin,
              isEmbeddedPanel: false,
              onContactUpdated: onContactUpdated,
              onDeleteContact: onDeleteContact,
              onClearHistory: onClearHistory,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable contact/group profile body.
/// Used both inside the bottom sheet/dialog and as an embedded side panel.
class ContactProfileBody extends StatefulWidget {
  final Contact contact;
  final bool isAdmin;
  /// When true, close actions call [onClose] instead of Navigator.pop.
  final bool isEmbeddedPanel;
  final VoidCallback? onClose;
  final void Function(Contact updated)? onContactUpdated;
  final void Function()? onDeleteContact;
  final void Function()? onClearHistory;

  const ContactProfileBody({
    super.key,
    required this.contact,
    required this.isAdmin,
    this.isEmbeddedPanel = false,
    this.onClose,
    this.onContactUpdated,
    this.onDeleteContact,
    this.onClearHistory,
  });

  @override
  State<ContactProfileBody> createState() => _ContactProfileBodyState();
}

class _ContactProfileBodyState extends State<ContactProfileBody> {
  late Contact _contact;
  String? _contactFingerprint;
  String _ownFingerprint = '';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    _loadFingerprints();
  }

  @override
  void didUpdateWidget(covariant ContactProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact.id != widget.contact.id) {
      _contact = widget.contact;
      _loadFingerprints();
    }
  }

  Future<void> _loadFingerprints() async {
    final signal = SignalService();
    final own = signal.ownFingerprint;
    final contact = !widget.contact.isGroup
        ? await signal.getContactFingerprint(widget.contact.databaseId)
        : null;
    const ss = FlutterSecureStorage();
    final storedHash = await ss.read(key: 'verified_identity_${widget.contact.databaseId}');
    final currentHash = await _computeCurrentHash();
    final verified = storedHash != null && storedHash == currentHash;
    if (mounted) {
      setState(() {
        _ownFingerprint = own;
        _contactFingerprint = contact;
        _isVerified = verified;
      });
    }
  }

  Future<String?> _computeCurrentHash() async {
    final signal = SignalService();
    final ownB64 = signal.ownIdentityKeyB64;
    final contactB64 = await signal.getContactIdentityKeyB64(widget.contact.databaseId);
    if (ownB64.isEmpty || contactB64 == null) return null;
    final combined = '$ownB64:$contactB64';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  Future<void> _toggleVerified() async {
    const ss = FlutterSecureStorage();
    if (_isVerified) {
      await ss.delete(key: 'verified_identity_${_contact.databaseId}');
      if (mounted) setState(() => _isVerified = false);
    } else {
      final hash = await _computeCurrentHash();
      if (hash == null) return;
      await ss.write(key: 'verified_identity_${_contact.databaseId}', value: hash);
      if (mounted) setState(() => _isVerified = true);
    }
  }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.buttonRadius)),
        title: Row(children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: DesignTokens.iconMd),
          const SizedBox(width: DesignTokens.spacing8),
          Text(context.l10n.profileVerifyIdentity,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.profileVerifyInstructions(_contact.name),
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
              ),
              const SizedBox(height: DesignTokens.spacing14),
              _dialogFpRow(context.l10n.profileTheirKey, _contactFingerprint ?? '—'),
              const SizedBox(height: DesignTokens.spacing6),
              _dialogFpRow(context.l10n.profileYourKey, _ownFingerprint.isEmpty ? '—' : _ownFingerprint),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isVerified ? AppTheme.error : AppTheme.online,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _toggleVerified();
            },
            child: Text(
              _isVerified ? context.l10n.profileRemoveVerification : context.l10n.profileMarkAsVerified,
              style: GoogleFonts.inter(color: AppTheme.onPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogFpRow(String label, String fp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.spacing8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontXs, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          SelectableText(fp,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: DesignTokens.fontBody, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showQrDialog(String title, String data) {
    if (data.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.buttonRadius)),
        title: Text(title,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(DesignTokens.spacing12),
                child: QrImageView(data: data, size: 220),
              ),
              const SizedBox(height: DesignTokens.spacing12),
              Text(data,
                  style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontXs),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.l10n.profileAddressCopied),
                duration: const Duration(seconds: 1),
              ));
            },
            child: Text(context.l10n.copy, style: GoogleFonts.inter(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.close, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        title: Text(context.l10n.profileLeaveGroup,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(context.l10n.profileLeaveGroupBody,
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.profileLeaveGroup,
                style: GoogleFonts.inter(color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final myId = context.read<ChatController>().identity?.id ?? '';
    final updated = _contact.copyWith(
      members: _contact.members.where((id) => id != myId).toList(),
    );
    // Notify remaining members before removing locally
    unawaited(context.read<ChatController>().broadcastGroupUpdate(updated));
    await context.read<IContactRepository>().removeContact(_contact.id);
    if (mounted) {
      _dismiss();
      widget.onDeleteContact?.call();
    }
  }

  void _kickMember(String memberId) async {
    final repo = context.read<IContactRepository>();
    final ctrl = context.read<ChatController>();
    final updated = _contact.copyWith(
      members: _contact.members.where((id) => id != memberId).toList(),
    );
    await repo.updateContact(updated);
    setState(() => _contact = updated);
    widget.onContactUpdated?.call(updated);
    // Notify remaining members of the new member list
    unawaited(ctrl.broadcastGroupUpdate(updated));
  }

  void _showTransferAdminConfirm(String memberId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(context.l10n.profileTransferAdminConfirm(name),
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(context.l10n.profileTransferAdminBody,
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _transferAdmin(memberId, name);
            },
            child: Text(context.l10n.profileTransferAdmin,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _transferAdmin(String memberId, String name) async {
    final repo = context.read<IContactRepository>();
    final ctrl = context.read<ChatController>();
    final updated = _contact.copyWith(creatorId: memberId);
    await repo.updateContact(updated);
    setState(() => _contact = updated);
    widget.onContactUpdated?.call(updated);
    unawaited(ctrl.broadcastGroupUpdate(updated));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.profileTransferAdminDone(name)),
        backgroundColor: AppTheme.surface,
      ));
    }
  }

  void _showAddMembersSheet() {
    const meshMemberLimit = 6;
    if (_contact.members.length >= meshMemberLimit) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(context.l10n.groupMemberLimitTitle,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: Text(
              context.l10n.groupMemberLimitBody(_contact.members.length),
              style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      );
      return;
    }

    final currentMemberIds = Set<String>.from(_contact.members);
    final candidates = context.read<IContactRepository>().contacts
        .where((c) => !c.isGroup && !currentMemberIds.contains(c.id))
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.profileNoContactsToAdd),
        duration: const Duration(seconds: 2),
      ));
      return;
    }
    final selected = <String>{};
    showAdaptiveSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (PlatformUtils.isMobile)
                Container(
                  width: DesignTokens.spacing40, height: DesignTokens.spacing4,
                  margin: const EdgeInsets.only(top: DesignTokens.spacing12, bottom: DesignTokens.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityMedium),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacing20, 0, DesignTokens.spacing20, DesignTokens.spacing8),
                child: Row(
                  children: [
                    Text(context.l10n.profileAddMembers,
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (selected.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          // Capture context-dependent objects before async gaps
                          final repo = context.read<IContactRepository>();
                          final ctrl = context.read<ChatController>();
                          // Dedup: filter out any IDs already in the group
                          final existingIds = Set<String>.from(_contact.members);
                          final uniqueNew = selected
                              .where((id) => !existingIds.contains(id))
                              .toList();
                          if (uniqueNew.isEmpty) return;
                          // Warn but don't block if total exceeds mesh limit
                          final total = _contact.members.length + uniqueNew.length;
                          if (total > meshMemberLimit && mounted) {
                            final proceed = await showDialog<bool>(
                              context: context,
                              builder: (dctx) => AlertDialog.adaptive(
                                backgroundColor: AppTheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        DesignTokens.dialogRadius)),
                                title: Text(context.l10n.groupMemberLimitTitle,
                                    style: GoogleFonts.inter(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w700)),
                                content: Text(
                                    context.l10n.groupMemberLimitBody(total),
                                    style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dctx, false),
                                    child: Text(context.l10n.cancel,
                                        style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dctx, true),
                                    child: Text(
                                        context.l10n.groupMemberLimitContinue,
                                        style: GoogleFonts.inter(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );
                            if (proceed != true) return;
                          }
                          final updated = _contact.copyWith(
                            members: [..._contact.members, ...uniqueNew],
                          );
                          await repo.updateContact(updated);
                          if (mounted) {
                            setState(() => _contact = updated);
                            widget.onContactUpdated?.call(updated);
                            // Notify existing members of new list
                            unawaited(ctrl.broadcastGroupUpdate(updated));
                            // Invite each newly added member so they get the group
                            for (final newId in uniqueNew) {
                              final newContact = repo
                                  .contacts
                                  .cast<Contact?>()
                                  .firstWhere((c) => c?.id == newId, orElse: () => null);
                              if (newContact != null) {
                                unawaited(ctrl.sendGroupInvite(newContact, updated));
                                unawaited(ctrl.sendGroupHistory(newContact, updated));
                              }
                            }
                          }
                        },
                        child: Text(context.l10n.profileAddCount(selected.length),
                            style: GoogleFonts.inter(
                                color: AppTheme.primary, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (_, i) {
                    final c = candidates[i];
                    final isSelected = selected.contains(c.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) => setLocal(() {
                        if (v == true) { selected.add(c.id); }
                        else { selected.remove(c.id); }
                      }),
                      title: Text(c.name,
                          style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                      subtitle: Text(c.provider,
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm)),
                      activeColor: AppTheme.primary,
                      checkColor: AppTheme.onPrimary,
                    );
                  },
                ),
              ),
              const SizedBox(height: DesignTokens.spacing8),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog() {
    final ctrl = TextEditingController(text: _contact.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.buttonRadius)),
        title: Text(context.l10n.profileRenameGroup,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: context.l10n.groupGroupName,
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.spacing10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              elevation: 0,
            ),
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final updated = _contact.copyWith(name: name);
              await context.read<IContactRepository>().updateContact(updated);
              if (mounted) {
                setState(() => _contact = updated);
                widget.onContactUpdated?.call(updated);
                if (_contact.isGroup) {
                  unawaited(context.read<ChatController>().broadcastGroupUpdate(updated));
                }
              }
            },
            child: Text(context.l10n.profileRename,
                style: GoogleFonts.inter(color: AppTheme.onPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  void _dismiss() {
    if (widget.isEmbeddedPanel) {
      widget.onClose?.call();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacing20, DesignTokens.spacing20, DesignTokens.spacing20, DesignTokens.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          const SizedBox(height: DesignTokens.spacing14),
          GestureDetector(
            onTap: _contact.isGroup && widget.isAdmin ? _showRenameDialog : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _contact.name,
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: DesignTokens.fontDisplay,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_contact.isGroup && widget.isAdmin) ...[
                  const SizedBox(width: DesignTokens.spacing6),
                  Icon(Icons.edit_rounded,
                      size: DesignTokens.fontLg, color: AppTheme.textSecondary),
                ],
              ],
            ),
          ),
          if (_contact.bio.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              _contact.bio,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
            ),
          ],
          const SizedBox(height: DesignTokens.spacing6),
          _buildProviderBadge(),
          const SizedBox(height: DesignTokens.spacing20),
          _buildAddressRow(),
          if (!_contact.isGroup && (_contactFingerprint != null || _ownFingerprint.isNotEmpty)) ...[
            const SizedBox(height: DesignTokens.spacing12),
            _buildFingerprintSection(),
          ],
          if (_contact.isGroup) ...[
            const SizedBox(height: DesignTokens.spacing20),
            _buildMembersSection(),
          ],
          const SizedBox(height: DesignTokens.spacing24),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final name = _contact.name;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
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
        child: _contact.isGroup
            ? Icon(Icons.group_rounded, color: AppTheme.onPrimary, size: 42)
            : Text(initial,
                style: GoogleFonts.inter(
                    color: AppTheme.onPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildProviderBadge() {
    final providerColors = {
      'Firebase': AppTheme.providerFirebase,
      'Nostr': AppTheme.providerNostr,
      'group': AppTheme.providerPulse,
    };
    final color = providerColors[_contact.provider] ?? AppTheme.textSecondary;
    final label = _contact.isGroup ? context.l10n.profileGroupLabel : _contact.provider;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: DesignTokens.opacityLight),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              color: color, fontSize: DesignTokens.fontBody, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildAddressRow() {
    if (_contact.transportAddresses.isEmpty) return const SizedBox.shrink();
    final transportIcons = <String, IconData>{
      'Pulse': Icons.flash_on_rounded,
      'Nostr': Icons.language_rounded,
      'Session': Icons.shield_rounded,
      'Firebase': Icons.cloud_rounded,
    };
    final transportColors = <String, Color>{
      'Pulse': AppTheme.providerPulse,
      'Nostr': AppTheme.providerNostr,
      'Session': AppTheme.providerOxen,
      'Firebase': AppTheme.providerFirebase,
    };
    return Column(
      children: [
        for (final transport in _contact.transportPriority)
          if ((_contact.transportAddresses[transport] ?? []).isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: DesignTokens.spacing6),
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.cardPadding, vertical: DesignTokens.tilePaddingV),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(transportIcons[transport] ?? Icons.inbox_rounded,
                        size: DesignTokens.fontBody,
                        color: transportColors[transport] ?? AppTheme.textSecondary),
                    const SizedBox(width: DesignTokens.spacing6),
                    Text(transport,
                        style: GoogleFonts.inter(
                            color: transportColors[transport] ?? AppTheme.textSecondary,
                            fontSize: DesignTokens.fontSm,
                            fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: DesignTokens.spacing4),
                  for (final addr in _contact.transportAddresses[transport]!)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: addr));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.profileAddressCopied),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spacing2),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              addr,
                              style: GoogleFonts.jetBrainsMono(
                                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacing8),
                          Icon(Icons.copy_rounded, size: DesignTokens.iconSm, color: AppTheme.primary),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildFingerprintSection() {
    final verifiedColor = AppTheme.online;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: _isVerified
              ? verifiedColor.withValues(alpha: 0.4)
              : AppTheme.primary.withValues(alpha: DesignTokens.opacityLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.verified_user_rounded,
                size: DesignTokens.fontMd,
                color: _isVerified ? verifiedColor : AppTheme.primary),
            const SizedBox(width: DesignTokens.spacing6),
            Text(context.l10n.profileSignalFingerprints,
                style: GoogleFonts.inter(
                    color: _isVerified ? verifiedColor : AppTheme.primary,
                    fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w700)),
            const SizedBox(width: DesignTokens.spacing6),
            if (_isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing6, vertical: DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: verifiedColor.withValues(alpha: DesignTokens.opacityLight),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(context.l10n.profileVerified,
                    style: GoogleFonts.inter(
                        color: verifiedColor, fontSize: DesignTokens.fontXxs, fontWeight: FontWeight.w700)),
              ),
            const Spacer(),
            if (_contactFingerprint != null)
              GestureDetector(
                onTap: _showVerifyDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.spacing6),
                  ),
                  child: Text(_isVerified ? context.l10n.profileEdit : context.l10n.profileVerify,
                      style: GoogleFonts.inter(
                          color: AppTheme.primary, fontSize: DesignTokens.fontXs, fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
          const SizedBox(height: DesignTokens.spacing10),
          if (_contactFingerprint != null)
            _fingerprintRow(context.l10n.profileTheirKey, _contactFingerprint!),
          if (_ownFingerprint.isNotEmpty) ...[
            if (_contactFingerprint != null) const SizedBox(height: DesignTokens.spacing6),
            _fingerprintRow(context.l10n.profileYourKey, _ownFingerprint),
          ],
          if (_contactFingerprint == null)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacing4),
              child: Text(context.l10n.profileNoSession,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm)),
            ),
        ],
      ),
    );
  }

  Widget _fingerprintRow(String label, String fp) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: fp));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.profileFingerprintCopied),
          duration: const Duration(seconds: 1),
        ));
      },
      child: Row(children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm)),
        ),
        Expanded(
          child: Text(fp,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600)),
        ),
        Icon(Icons.copy_rounded, size: DesignTokens.fontBody, color: AppTheme.textSecondary),
      ]),
    );
  }

  Widget _buildMembersSection() {
    // Always render the creator first — members[] typically excludes the
    // creator's own UUID (only people they invited end up there), so
    // without this step the admin wouldn't show up in the roster view
    // at all on peer devices.
    final creatorId = _contact.creatorId;
    final listedMembers = _contact.members;
    final seen = <String>{};
    final members = <String>[];
    if (creatorId != null && creatorId.isNotEmpty) {
      members.add(creatorId);
      seen.add(creatorId);
    }
    for (final m in listedMembers) {
      if (seen.add(m)) members.add(m);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.group_rounded, size: DesignTokens.fontLg, color: AppTheme.textSecondary),
          const SizedBox(width: DesignTokens.spacing6),
          Text(
            context.l10n.profileMemberCount(members.length),
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: DesignTokens.fontBody,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (widget.isAdmin)
            GestureDetector(
              onTap: _showAddMembersSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.person_add_rounded, size: DesignTokens.fontBody, color: AppTheme.primary),
                  const SizedBox(width: DesignTokens.spacing4),
                  Text(context.l10n.profileAddButton,
                      style: GoogleFonts.inter(
                          color: AppTheme.primary, fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: DesignTokens.spacing10),
        ...members.map((memberId) => _buildMemberTile(memberId)),
      ],
    );
  }

  Widget _buildMemberTile(String memberId) {
    final repo = context.read<IContactRepository>();
    final ctrl = context.read<ChatController>();
    // Fast path: the member's UUID matches one of our local contacts —
    // works only for the creator (whose UUIDs ARE the source of truth).
    Contact? contact = repo.findById(memberId);
    String? fallbackLabel;
    if (contact == null) {
      // Cross-device fallback: members[] holds the creator's local
      // UUIDs which never match our own. Translate UUID → Nostr pubkey
      // via the memberPubkeys map propagated in the invite/update.
      final pubkey = _contact.memberPubkeys[memberId];
      if (pubkey != null && pubkey.isNotEmpty) {
        final selfId = ctrl.selfId;
        final atIdx = selfId.indexOf('@');
        final ownPub = atIdx > 0 ? selfId.substring(0, atIdx) : selfId;
        if (ownPub == pubkey) {
          // Member is us — own identity isn't in the contacts repo.
          fallbackLabel =
              ctrl.displayName.isNotEmpty ? ctrl.displayName : 'You';
        } else {
          contact = repo.findByAddress(pubkey);
          // Unknown contact — short-pubkey placeholder. Replacing this
          // with a real display name via Nostr kind:0 profile fetch is
          // a follow-up step.
          fallbackLabel ??= '0x${pubkey.substring(0, 8).toUpperCase()}';
        }
      }
    }
    final name = contact?.name ??
        fallbackLabel ??
        memberId.substring(0, memberId.length.clamp(0, 12));
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue = (name.isNotEmpty ? name.codeUnitAt(0) * 17 + name.length * 31 : 0) % 360;
    final avatarColor = HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.35).toColor();

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing6),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.tilePaddingV),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: DesignTokens.avatarXs,
            height: DesignTokens.avatarXs,
            decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: Center(
              child: Text(initial,
                  style: GoogleFonts.inter(
                      color: AppTheme.onPrimary, fontSize: DesignTokens.fontInput, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing12),
          Expanded(
            child: Text(name,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ),
          if (memberId == _contact.creatorId)
            Tooltip(
              message: context.l10n.profileAdminBadge,
              child: Icon(Icons.workspace_premium_rounded,
                  size: DesignTokens.fontHeading, color: const Color(0xFFFFB300)),
            )
          else if (widget.isAdmin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showTransferAdminConfirm(memberId, name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                    child: Text(context.l10n.profileTransferAdmin,
                        style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontSize: DesignTokens.fontBody,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing6),
                GestureDetector(
                  onTap: () => _showKickConfirm(memberId, name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                    child: Text(context.l10n.profileKickButton,
                        style: GoogleFonts.inter(
                            color: AppTheme.error,
                            fontSize: DesignTokens.fontBody,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showKickConfirm(String memberId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        title: Text(context.l10n.profileRemoveMember,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(context.l10n.profileRemoveMemberBody(name),
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _kickMember(memberId);
            },
            child: Text(context.l10n.remove,
                style: GoogleFonts.inter(color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (!_contact.isGroup)
          _actionButton(
            icon: Icons.verified_user_rounded,
            label: context.l10n.profileVerifySafetyNumber,
            color: _isVerified ? AppTheme.online : AppTheme.primary,
            onTap: () {
              _dismiss();
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => VerifyIdentityScreen(
                  contactName: _contact.name,
                  contactId: _contact.databaseId,
                ),
              ));
            },
          ),
        if (!_contact.isGroup) const SizedBox(height: DesignTokens.spacing10),
        if (!_contact.isGroup)
          _actionButton(
            icon: Icons.qr_code_rounded,
            label: context.l10n.profileShowContactQr,
            color: AppTheme.providerNostr,
            onTap: () => _showQrDialog(context.l10n.profileContactAddress(_contact.name), _contact.databaseId),
          ),
        if (!_contact.isGroup) const SizedBox(height: DesignTokens.spacing10),
        _actionButton(
          icon: Icons.download_rounded,
          label: context.l10n.profileExportChatHistory,
          color: AppTheme.providerOxen,
          onTap: () async {
            final path = await ChatController().exportHistory(_contact);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(path != null ? context.l10n.profileSavedTo(path) : context.l10n.profileExportFailed),
                duration: const Duration(seconds: 4),
              ));
            }
          },
        ),
        const SizedBox(height: DesignTokens.spacing10),
        _actionButton(
          icon: Icons.delete_sweep_rounded,
          label: context.l10n.profileClearChatHistory,
          color: AppTheme.textSecondary,
          onTap: () {
            _dismiss();
            widget.onClearHistory?.call();
          },
        ),
        const SizedBox(height: DesignTokens.spacing10),
        if (_contact.isGroup) ...[
          _actionButton(
            icon: Icons.exit_to_app_rounded,
            label: context.l10n.profileLeaveGroup,
            color: AppTheme.error,
            onTap: _leaveGroup,
          ),
          const SizedBox(height: DesignTokens.spacing10),
        ],
        _actionButton(
          icon: Icons.person_remove_rounded,
          label: _contact.isGroup ? context.l10n.profileDeleteGroup : context.l10n.profileDeleteContact,
          color: AppTheme.error,
          onTap: () {
            _dismiss();
            widget.onDeleteContact?.call();
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.cardPadding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: DesignTokens.opacitySubtle),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: DesignTokens.fontHeading),
            const SizedBox(width: DesignTokens.spacing8),
            Text(label,
                style: GoogleFonts.inter(
                    color: color, fontWeight: FontWeight.w600, fontSize: DesignTokens.fontLg)),
          ],
        ),
      ),
    );
  }
}
