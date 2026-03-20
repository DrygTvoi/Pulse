// Settings — Appearance & Identity section: theme picker, Signal Protocol badge,
// identity backup, and device transfer.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n_ext.dart';
import '../../widgets/theme_picker_widget.dart';
import '../dynamic_theme_screen.dart';
import '../device_transfer_screen.dart';
import 'settings_widgets.dart';

class AppearanceIdentitySection extends StatelessWidget {
  const AppearanceIdentitySection({super.key});

  static const _secureStorage = FlutterSecureStorage();

  Future<void> _showBackupOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(
          context.l10n.settingsIdentityBackup,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.l10n.settingsIdentityBackupBody,
          style:
              GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportIdentity(ctx);
            },
            child: Text(
              context.l10n.export,
              style: GoogleFonts.inter(
                  color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _importIdentity(ctx);
            },
            child: Text(
              context.l10n.import,
              style: GoogleFonts.inter(
                  color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportIdentity(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, String>{};
      for (final key in [
        'signal_id_key',
        'signal_reg_id',
        'signal_signed_prekey_0',
        'signal_prekeys_generated',
        'nostr_privkey',
      ]) {
        final val = await _secureStorage.read(key: key);
        if (val != null && val.isNotEmpty) data[key] = val;
      }
      final userIdentity = prefs.getString('user_identity');
      if (userIdentity != null) data['user_identity'] = userIdentity;
      final contacts = prefs.getString('contacts');
      if (contacts != null) data['contacts'] = contacts;

      final b64 = base64.encode(utf8.encode(jsonEncode(data)));

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(
            context.l10n.settingsExportIdentity,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.settingsExportIdentityBody,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                ),
                child: SelectableText(
                  b64,
                  style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textPrimary, fontSize: DesignTokens.fontXxs),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // copy to clipboard handled via ClipboardData — needs context
                // keep using context here
              },
              child: Text(
                context.l10n.copy,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final dir = await getDownloadsDirectory();
                  final path =
                      '${dir?.path ?? '/tmp'}/messenger_identity_backup.txt';
                  await File(path).writeAsString(b64);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content:
                          Text(ctx.l10n.appearanceSavedTo(path), style: GoogleFonts.inter()),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
                    ));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(ctx.l10n.appearanceSaveFailed(e.toString()),
                          style: GoogleFonts.inter()),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
                    ));
                  }
                }
              },
              child: Text(
                context.l10n.settingsSaveFile,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.l10n.done,
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.appearanceExportFailed(e.toString()), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
      }
    }
  }

  Future<void> _importIdentity(BuildContext context) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(
          context.l10n.settingsImportIdentity,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.settingsImportIdentityBody,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: 10),
              decoration: InputDecoration(
                hintText: context.l10n.settingsPasteBackupCode,
                hintStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final b64 = ctrl.text.trim();
                final jsonStr = utf8.decode(base64.decode(b64));
                final data =
                    jsonDecode(jsonStr) as Map<String, dynamic>;
                for (final key in [
                  'signal_id_key',
                  'signal_reg_id',
                  'signal_signed_prekey_0',
                  'signal_prekeys_generated',
                  'nostr_privkey',
                ]) {
                  if (data.containsKey(key)) {
                    await _secureStorage.write(
                        key: key, value: data[key] as String);
                  }
                }
                final prefs2 = await SharedPreferences.getInstance();
                if (data.containsKey('user_identity')) {
                  await prefs2.setString(
                      'user_identity', data['user_identity'] as String);
                }
                if (data.containsKey('contacts')) {
                  await prefs2.setString(
                      'contacts', data['contacts'] as String);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      context.l10n.settingsIdentityImported,
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
                  ));
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.appearanceImportFailed(e.toString()),
                        style: GoogleFonts.inter()),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
            ),
            child: Text(
              context.l10n.apply,
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Appearance ───────────────────────────────────────
        settingsSectionDivider(context.l10n.settingsAppearance),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: const ThemePickerWidget(),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.palette_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: context.l10n.settingsThemeEngine,
          subtitle: context.l10n.settingsThemeEngineSubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DynamicThemeScreen()),
          ),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.shield_rounded,
          iconColor: AppTheme.primary,
          title: context.l10n.settingsSignalProtocol,
          subtitle: context.l10n.settingsSignalProtocolSubtitle,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.spacing6),
            ),
            child: Text(
              context.l10n.settingsActive,
              style: GoogleFonts.inter(
                color: AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.backup_rounded,
          iconColor: const Color(0xFF2ECC71),
          title: context.l10n.settingsIdentityBackup,
          subtitle: context.l10n.settingsIdentityBackupSubtitle,
          onTap: () => _showBackupOptions(context),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.phonelink_rounded,
          iconColor: const Color(0xFF3498DB),
          title: context.l10n.settingsTransferDevice,
          subtitle: context.l10n.settingsTransferDeviceSubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeviceTransferScreen()),
          ),
        ),
      ],
    );
  }
}
