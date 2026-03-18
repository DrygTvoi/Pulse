import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../services/signal_service.dart';
import '../controllers/chat_controller.dart';
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

class _ContactProfileSheet extends StatefulWidget {
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
  State<_ContactProfileSheet> createState() => _ContactProfileSheetState();
}

class _ContactProfileSheetState extends State<_ContactProfileSheet> {
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

  Future<void> _loadFingerprints() async {
    final signal = SignalService();
    final own = signal.ownFingerprint;
    final contact = !widget.contact.isGroup
        ? await signal.getContactFingerprint(widget.contact.databaseId)
        : null;
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('verified_identity_${widget.contact.databaseId}');
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
    final prefs = await SharedPreferences.getInstance();
    if (_isVerified) {
      await prefs.remove('verified_identity_${_contact.databaseId}');
      if (mounted) setState(() => _isVerified = false);
    } else {
      final hash = await _computeCurrentHash();
      if (hash == null) return;
      await prefs.setString('verified_identity_${_contact.databaseId}', hash);
      if (mounted) setState(() => _isVerified = true);
    }
  }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Text('Verify Identity',
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compare these fingerprints with ${_contact.name} over a voice call or in person. '
                'If both values match on both devices, tap "Mark as Verified".',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              _dialogFpRow('Their key', _contactFingerprint ?? '—'),
              const SizedBox(height: 6),
              _dialogFpRow('Your key', _ownFingerprint.isEmpty ? '—' : _ownFingerprint),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isVerified ? AppTheme.error : const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _toggleVerified();
            },
            child: Text(
              _isVerified ? 'Remove Verification' : 'Mark as Verified',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogFpRow(String label, String fp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          SelectableText(fp,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showQrDialog(String title, String data) {
    if (data.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: QrImageView(data: data, size: 220),
              ),
              const SizedBox(height: 12),
              Text(data,
                  style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textSecondary, fontSize: 10),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Address copied'),
                duration: Duration(seconds: 1),
              ));
            },
            child: Text('Copy', style: GoogleFonts.inter(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _kickMember(String memberId) async {
    final updated = _contact.copyWith(
      members: _contact.members.where((id) => id != memberId).toList(),
    );
    await ContactManager().updateContact(updated);
    setState(() => _contact = updated);
    widget.onContactUpdated?.call(updated);
  }

  void _showAddMembersSheet() {
    final currentMemberIds = Set<String>.from(_contact.members);
    final candidates = ContactManager().contacts
        .where((c) => !c.isGroup && !currentMemberIds.contains(c.id))
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No contacts to add — all are already members'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    final selected = <String>{};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Text('Add Members',
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (selected.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final updated = _contact.copyWith(
                            members: [..._contact.members, ...selected],
                          );
                          await ContactManager().updateContact(updated);
                          if (mounted) {
                            setState(() => _contact = updated);
                            widget.onContactUpdated?.call(updated);
                          }
                        },
                        child: Text('Add (${selected.length})',
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
                  shrinkWrap: true,
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
                              color: AppTheme.textSecondary, fontSize: 11)),
                      activeColor: AppTheme.primary,
                      checkColor: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Group',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Group name',
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final updated = _contact.copyWith(name: name);
              await ContactManager().updateContact(updated);
              if (mounted) {
                setState(() => _contact = updated);
                widget.onContactUpdated?.call(updated);
              }
            },
            child: Text('Rename',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 14),
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
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_contact.isGroup && widget.isAdmin) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.edit_rounded,
                              size: 14, color: AppTheme.textSecondary),
                        ],
                      ],
                    ),
                  ),
                  if (_contact.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _contact.bio,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildProviderBadge(),
                  const SizedBox(height: 20),
                  _buildAddressRow(),
                  if (!_contact.isGroup && (_contactFingerprint != null || _ownFingerprint.isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    _buildFingerprintSection(),
                  ],
                  if (_contact.isGroup) ...[
                    const SizedBox(height: 20),
                    _buildMembersSection(),
                  ],
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            ),
          ),
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
            ? Icon(Icons.group_rounded, color: Colors.white, size: 42)
            : Text(initial,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildProviderBadge() {
    final providerColors = {
      'Firebase': const Color(0xFFFFAB00),
      'Nostr': const Color(0xFF9B59B6),
      'group': const Color(0xFF26A69A),
    };
    final color = providerColors[_contact.provider] ?? AppTheme.textSecondary;
    final label = _contact.isGroup ? 'Group' : _contact.provider;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildAddressRow() {
    final addr = _contact.databaseId;
    if (addr.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.inbox_rounded, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              addr,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textSecondary, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: addr));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Icon(Icons.copy_rounded, size: 16, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintSection() {
    final verifiedColor = const Color(0xFF4CAF50);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVerified
              ? verifiedColor.withValues(alpha: 0.4)
              : AppTheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.verified_user_rounded,
                size: 13,
                color: _isVerified ? verifiedColor : AppTheme.primary),
            const SizedBox(width: 6),
            Text('Signal Fingerprints',
                style: GoogleFonts.inter(
                    color: _isVerified ? verifiedColor : AppTheme.primary,
                    fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            if (_isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: verifiedColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('VERIFIED',
                    style: GoogleFonts.inter(
                        color: verifiedColor, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            const Spacer(),
            if (_contactFingerprint != null)
              GestureDetector(
                onTap: _showVerifyDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_isVerified ? 'Edit' : 'Verify',
                      style: GoogleFonts.inter(
                          color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
          const SizedBox(height: 10),
          if (_contactFingerprint != null)
            _fingerprintRow('Their key', _contactFingerprint!),
          if (_ownFingerprint.isNotEmpty) ...[
            if (_contactFingerprint != null) const SizedBox(height: 6),
            _fingerprintRow('Your key', _ownFingerprint),
          ],
          if (_contactFingerprint == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('No session established yet — send a message first.',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _fingerprintRow(String label, String fp) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: fp));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fingerprint copied'),
          duration: Duration(seconds: 1),
        ));
      },
      child: Row(children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        ),
        Expanded(
          child: Text(fp,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        Icon(Icons.copy_rounded, size: 12, color: AppTheme.textSecondary),
      ]),
    );
  }

  Widget _buildMembersSection() {
    final members = _contact.members;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.group_rounded, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            '${members.length} member${members.length == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (widget.isAdmin)
            GestureDetector(
              onTap: _showAddMembersSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.person_add_rounded, size: 12, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text('Add',
                      style: GoogleFonts.inter(
                          color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 10),
        ...members.map((memberId) => _buildMemberTile(memberId)),
      ],
    );
  }

  Widget _buildMemberTile(String memberId) {
    final contact = ContactManager().contacts.cast<Contact?>()
        .firstWhere((c) => c?.id == memberId, orElse: () => null);
    final name = contact?.name ?? memberId.substring(0, memberId.length.clamp(0, 12));
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue = (name.isNotEmpty ? name.codeUnitAt(0) * 17 + name.length * 31 : 0) % 360;
    final avatarColor = HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.35).toColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: Center(
              child: Text(initial,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ),
          if (widget.isAdmin)
            GestureDetector(
              onTap: () => _showKickConfirm(memberId, name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Kick',
                    style: GoogleFonts.inter(
                        color: AppTheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  void _showKickConfirm(String memberId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Remove member?',
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Remove $name from this group?',
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _kickMember(memberId);
            },
            child: Text('Remove',
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
            label: 'Verify Safety Number',
            color: _isVerified ? const Color(0xFF4CAF50) : AppTheme.primary,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => VerifyIdentityScreen(
                  contactName: _contact.name,
                  contactId: _contact.databaseId,
                ),
              ));
            },
          ),
        if (!_contact.isGroup) const SizedBox(height: 10),
        if (!_contact.isGroup)
          _actionButton(
            icon: Icons.qr_code_rounded,
            label: 'Show Contact QR',
            color: const Color(0xFF9B59B6),
            onTap: () => _showQrDialog("${_contact.name}'s Address", _contact.databaseId),
          ),
        if (!_contact.isGroup) const SizedBox(height: 10),
        _actionButton(
          icon: Icons.download_rounded,
          label: 'Export Chat History',
          color: const Color(0xFF2196F3),
          onTap: () async {
            final path = await ChatController().exportHistory(_contact);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(path != null ? 'Saved to $path' : 'Export failed'),
                duration: const Duration(seconds: 4),
              ));
            }
          },
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.delete_sweep_rounded,
          label: 'Clear chat history',
          color: AppTheme.textSecondary,
          onTap: () {
            Navigator.pop(context);
            widget.onClearHistory?.call();
          },
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.person_remove_rounded,
          label: _contact.isGroup ? 'Delete group' : 'Delete contact',
          color: AppTheme.error,
          onTap: () {
            Navigator.pop(context);
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
