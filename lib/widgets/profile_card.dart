import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../controllers/chat_controller.dart';
import '../services/signal_service.dart';
import 'avatar_widget.dart';

/// Self-contained profile editing card for use in Settings.
/// Reads / writes from SharedPreferences key `user_profile`.
class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

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

  String _buildInviteLink(List<String> addresses, String name) {
    final payload = addresses.length == 1
        ? jsonEncode({'a': addresses.first, 'n': name})
        : jsonEncode({'a': addresses, 'n': name});
    final cfg = base64Encode(utf8.encode(payload));
    return 'pulse://add?cfg=$cfg';
  }

  void _showMyQrDialog() {
    final addresses = ChatController().shareableAddresses;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.settingsNoAddressYet),
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    final myName = _nameController.text.trim();
    final inviteLink = _buildInviteLink(addresses, myName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(
          context.l10n.settingsShareMyAddress,
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: DesignTokens.fontXl,
          ),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                padding: const EdgeInsets.all(DesignTokens.cardPadding),
                child: QrImageView(data: inviteLink, size: 220),
              ),
              const SizedBox(height: DesignTokens.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing10,
                    vertical: DesignTokens.spacing6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route_rounded,
                        size: DesignTokens.fontMd, color: AppTheme.primary),
                    const SizedBox(width: DesignTokens.spacing6),
                    Text(
                      '${addresses.length} ${addresses.length == 1 ? 'route' : 'routes'} included',
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontSize: DesignTokens.fontSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacing12),
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.spacing10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctx.l10n.settingsInviteLink,
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: DesignTokens.fontXs,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing4),
                    SelectableText(
                      inviteLink,
                      style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textPrimary,
                          fontSize: DesignTokens.fontXs),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteLink));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.l10n.settingsInviteLinkCopied,
                    style: GoogleFonts.inter(color: AppTheme.onPrimary)),
                backgroundColor: AppTheme.primary,
                duration: const Duration(seconds: 2),
              ));
            },
            child: Text(
              context.l10n.settingsCopyLink,
              style: GoogleFonts.inter(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.close,
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
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
                        child: Icon(Icons.camera_alt_rounded, size: 11, color: AppTheme.onPrimary),
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

          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 18),

          // ─── Share QR + Save buttons ──────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _showMyQrDialog,
                    icon: Icon(Icons.qr_code_rounded, size: 18, color: AppTheme.primary),
                    label: Text(context.l10n.settingsMyQrCode, style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: AppTheme.primary, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
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
                            fontWeight: FontWeight.w700, color: AppTheme.onPrimary, fontSize: 15)),
                  ),
                ),
              ),
            ],
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

/// Inline address list without its own card background — used inside ProfileCard.
class _InlineInboxAddresses extends StatelessWidget {
  const _InlineInboxAddresses();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatController(),
      builder: (context, _) {
        final displayAddresses = ChatController().allAddresses;
        if (displayAddresses.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 14),
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
        );
      },
    );
  }
}

/// Standalone address card — kept for backward compat (used outside settings).
class InboxAddressCard extends StatelessWidget {
  const InboxAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatController(),
      builder: (context, _) {
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
