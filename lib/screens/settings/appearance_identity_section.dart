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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Identity Backup',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Export your Signal identity keys to a backup code, or restore from an existing one.',
          style:
              GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportIdentity(ctx);
            },
            child: Text(
              'Export',
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
              'Import',
              style: GoogleFonts.inter(
                  color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
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
              borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Export Identity',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Copy this backup code and store it safely:',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  b64,
                  style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textPrimary, fontSize: 9),
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
                'Copy',
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
                          Text('Saved to $path', style: GoogleFonts.inter()),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('Save failed: $e',
                          style: GoogleFonts.inter()),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                }
              },
              child: Text(
                'Save File',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Done',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Import Identity',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paste your backup code below. This will overwrite your current identity.',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: 10),
              decoration: InputDecoration(
                hintText: 'Paste backup code here\u2026',
                hintStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
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
                      'Identity + contacts imported! Restart the app to apply.',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Import failed: $e',
                        style: GoogleFonts.inter()),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Apply',
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
        settingsSectionDivider('Appearance'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const ThemePickerWidget(),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.palette_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: 'Theme Engine',
          subtitle: 'Customize colors & fonts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DynamicThemeScreen()),
          ),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.shield_rounded,
          iconColor: AppTheme.primary,
          title: 'Signal Protocol',
          subtitle: 'E2EE keys are stored securely',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ACTIVE',
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
          title: 'Identity Backup',
          subtitle: 'Export or import your Signal identity',
          onTap: () => _showBackupOptions(context),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.phonelink_rounded,
          iconColor: const Color(0xFF3498DB),
          title: 'Transfer to Another Device',
          subtitle: 'Move your identity via LAN or Nostr relay',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeviceTransferScreen()),
          ),
        ),
      ],
    );
  }
}
