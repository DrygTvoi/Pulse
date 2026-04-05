import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../controllers/chat_controller.dart';
import '../services/signal_service.dart';
import 'avatar_widget.dart';

/// Self-contained profile editing card for use in Settings.
/// Reads / writes from SharedPreferences key `user_profile`.
class ProfileCard extends StatefulWidget {
  final bool showAddressCard;
  const ProfileCard({super.key, this.showAddressCard = true});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _saving = false;
  String _fingerprint = '';
  Uint8List? _avatarBytes; // own avatar raw JPEG bytes

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_profile');
    if (raw != null) {
      try {
        final data = jsonDecode(raw);
        _nameController.text = data['name'] ?? '';
        _aboutController.text = data['about'] ?? '';
        final avatarB64 = data['avatar'] as String?;
        if (avatarB64 != null && avatarB64.isNotEmpty) {
          _avatarBytes = base64Decode(avatarB64);
        }
      } catch (e) {
        debugPrint('[ProfileCard] Failed to parse user profile: $e');
      }
    }
    final fp = SignalService().ownFingerprint;
    if (mounted) setState(() => _fingerprint = fp);
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    // Decode, resize to 256×256, encode as JPEG
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;
    final resized = img.copyResizeCropSquare(decoded, size: 256);
    final jpeg = img.encodeJpg(resized, quality: 85);
    if (mounted) setState(() => _avatarBytes = Uint8List.fromList(jpeg));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final name = _nameController.text.trim();
    final about = _aboutController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final avatarB64 = _avatarBytes != null ? base64Encode(_avatarBytes!) : '';
    await prefs.setString('user_profile', jsonEncode({
      'name': name,
      'about': about,
      if (avatarB64.isNotEmpty) 'avatar': avatarB64,
    }));
    unawaited(ChatController().broadcastProfile(name, about, avatarB64: avatarB64));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.profileCardSaved, style: GoogleFonts.inter()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha:0.12), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ─── Avatar row ──────────────────────────────
          Row(
            children: [
              // Avatar (tappable)
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    AvatarWidget(
                      name: name,
                      size: 72,
                      imageBytes: _avatarBytes,
                      fontSize: 28,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : context.l10n.profileCardYourName,
                      style: GoogleFonts.inter(
                          color: name.isNotEmpty ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    if (_fingerprint.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _fingerprint));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(context.l10n.profileCardFingerprintCopied, style: GoogleFonts.inter(fontSize: 13)),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppTheme.surfaceVariant,
                          ));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.shield_rounded, size: 12, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _fingerprint,
                                style: GoogleFonts.jetBrainsMono(
                                    color: AppTheme.textSecondary, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha:0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.lock_rounded, size: 10, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(context.l10n.profileCardE2eeIdentity,
                            style: GoogleFonts.inter(
                                color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 18),

          // ─── Name field ─────────────────────────────
          _buildField(
            controller: _nameController,
            label: context.l10n.profileCardDisplayName,
            hint: context.l10n.profileCardDisplayNameHint,
            icon: Icons.person_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // ─── About field ─────────────────────────────
          _buildField(
            controller: _aboutController,
            label: context.l10n.profileCardAbout,
            hint: context.l10n.profileCardAboutHint,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 20),

          // ─── My Inbox Address ────────────────────────
          if (widget.showAddressCard) ...[
            const InboxAddressCard(),
            const SizedBox(height: 20),
          ],

          // ─── Save button ─────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(context.l10n.profileCardSaveButton, style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label, required String hint, required IconData icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Shows unified invite link with all addresses. Individual addresses shown
/// as compact info — one-tap share button is the primary action.
class InboxAddressCard extends StatelessWidget {
  const InboxAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatController(),
      builder: (context, _) {
        final shareableAddresses = ChatController().shareableAddresses;
        final displayAddresses = ChatController().allAddresses;
        if (displayAddresses.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Share button — primary action
              _ShareAllButton(addresses: shareableAddresses),
              const SizedBox(height: 10),
              // Compact route list
              Row(
                children: [
                  Icon(Icons.route_rounded, size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${displayAddresses.length} ${displayAddresses.length == 1 ? 'route' : 'routes'} active',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final address in displayAddresses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Address copied!', style: GoogleFonts.inter()),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    },
                    child: Text(
                      address,
                      style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textSecondary, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShareAllButton extends StatelessWidget {
  final List<String> addresses;
  const _ShareAllButton({required this.addresses});

  Future<void> _share(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_profile');
    String name = '';
    if (raw != null) {
      try { name = (jsonDecode(raw)['name'] as String?) ?? ''; } catch (e) {
        debugPrint('[ProfileCard] Failed to parse profile name: $e');
      }
    }
    final cfg = jsonEncode({'n': name, 'a': addresses});
    final link = 'pulse://add?cfg=${base64Encode(utf8.encode(cfg))}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    final n = addresses.length;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          n > 1 ? '$n addresses copied as one link!' : 'Invite link copied!',
          style: GoogleFonts.inter()),
      backgroundColor: AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unawaited(_share(context)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.link_rounded, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
              addresses.length > 1
                  ? 'Share Invite Link (${addresses.length} routes)'
                  : 'Share Invite Link',
              style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
