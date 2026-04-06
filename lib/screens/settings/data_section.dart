// Settings — Data section: message backup/restore, key export/import,
// identity backup, and device transfer.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/key_export_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/password_hasher.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n_ext.dart';
import '../device_transfer_screen.dart';
import 'settings_widgets.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  static const _secureStorage = FlutterSecureStorage();

  // ── Shared password dialog ────────────────────────────────────────────────

  Future<String?> _showBackupPasswordDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String confirmLabel,
    required bool requireConfirm,
  }) async {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool showPass = false;
    String? error;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: DesignTokens.fontXl,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
              const SizedBox(height: DesignTokens.spacing16),
              SettingsPasswordField(
                controller: passCtrl,
                obscure: !showPass,
                onToggleObscure: () => setS(() => showPass = !showPass),
                hintText: context.l10n.settingsBackupPassword,
                autofocus: true,
                errorText: error,
                onChanged: (_) => setS(() => error = null),
              ),
              if (requireConfirm) ...[
                const SizedBox(height: DesignTokens.spacing12),
                SettingsPasswordField(
                  controller: confirmCtrl,
                  obscure: !showPass,
                  onToggleObscure: () => setS(() => showPass = !showPass),
                  hintText: context.l10n.passwordConfirmHint,
                  onChanged: (_) => setS(() => error = null),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(context.l10n.cancel,
                  style:
                      GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final pw = passCtrl.text;
                if (pw.isEmpty) {
                  setS(() => error = context.l10n.settingsPasswordCannotBeEmpty);
                  return;
                }
                // BUG-2: backup file protects all private keys (Signal, Nostr, Session,
                // PQC) — enforce the same 16-char minimum as identity creation.
                if (pw.length < 16) {
                  setS(() => error = context.l10n.settingsPasswordMin4Chars
                      .replaceAll('4', '16'));
                  return;
                }
                if (requireConfirm && pw != confirmCtrl.text) {
                  setS(() => error = context.l10n.passwordsDoNotMatch);
                  return;
                }
                Navigator.of(ctx).pop(pw);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              ),
              child: Text(
                confirmLabel,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    passCtrl.dispose();
    confirmCtrl.dispose();
    return result;
  }

  // ── Current-password gate ─────────────────────────────────────────────────
  //
  // Used before key export and plaintext identity import to confirm that the
  // person at the keyboard is the legitimate owner.  Returns true if no app
  // password is set (gate is a no-op) or if the user enters the correct
  // password.  Returns false if the user cancels or exceeds 5 attempts.

  Future<bool> _confirmWithAppPassword(BuildContext context) async {
    final hash = await _secureStorage.read(key: 'app_password_hash');
    final salt = await _secureStorage.read(key: 'app_password_salt');
    if (hash == null || salt == null) return true; // no password set
    if (!context.mounted) return false;

    final ctrl = TextEditingController();
    bool showPass = false;
    String? error;
    int attempts = 0;
    const maxAttempts = 5;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(context.l10n.settingsCurrentPassword,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: DesignTokens.fontXl)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.settingsEnterCurrentPassword,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
              const SizedBox(height: DesignTokens.spacing16),
              SettingsPasswordField(
                controller: ctrl,
                obscure: !showPass,
                onToggleObscure: () => setS(() => showPass = !showPass),
                hintText: context.l10n.settingsCurrentPassword,
                autofocus: true,
                errorText: error,
                onChanged: (_) => setS(() => error = null),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.l10n.cancel,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                if (attempts >= maxAttempts) return;
                if (await PasswordHasher.verify(ctrl.text, salt, hash)) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  attempts++;
                  if (attempts >= maxAttempts) {
                    setS(() => error = context.l10n.lockTooManyAttempts);
                    await Future.delayed(const Duration(seconds: 1));
                    if (ctx.mounted) Navigator.of(ctx).pop(false);
                  } else {
                    setS(() => error = context.l10n.securityIncorrectPassword);
                  }
                }
              },
              child: Text(context.l10n.confirm,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF60A5FA), fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    return ok == true;
  }

  // ── Identity backup ───────────────────────────────────────────────────────

  Future<void> _showBackupOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(
          context.l10n.settingsIdentityBackup,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.l10n.settingsIdentityBackupBody,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportIdentity(ctx);
            },
            child: Text(context.l10n.export,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _importIdentity(ctx);
            },
            child: Text(context.l10n.import,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportIdentity(BuildContext context) async {
    // Identity export contains private keys — require a password to encrypt.
    final password = await _showBackupPasswordDialog(
      context,
      title: context.l10n.settingsExportIdentity,
      subtitle: context.l10n.dataExportKeysPasswordSubtitle,
      confirmLabel: context.l10n.dataExportKeysConfirmLabel,
      requireConfirm: true,
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, String>{};
      for (final key in [
        'signal_id_key',
        'signal_reg_id',
        'signal_signed_prekey_0',
        'signal_prekeys_generated',
        'nostr_privkey',
        'session_seed',
      ]) {
        final val = await _secureStorage.read(key: key);
        if (val != null && val.isNotEmpty) data[key] = val;
      }
      final userIdentity = prefs.getString('user_identity');
      if (userIdentity != null) data['user_identity'] = userIdentity;
      final contacts = prefs.getString('contacts');
      if (contacts != null) data['contacts'] = contacts;

      final encrypted = await KeyExportService.encryptRawBundle(data, password);
      if (encrypted == null) {
        if (context.mounted) {
          showErrorSnackBar(context, context.l10n.dataExportFailed);
        }
        return;
      }
      final b64 = base64.encode(encrypted);

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(context.l10n.settingsExportIdentity,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.settingsExportIdentityBody,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: DesignTokens.fontMd)),
              const SizedBox(height: DesignTokens.spacing12),
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                ),
                child: SelectableText(b64,
                    style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.textPrimary,
                        fontSize: DesignTokens.fontXxs)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final dir = await getDownloadsDirectory();
                  if (dir == null) throw Exception('Downloads folder not available');
                  final path = '${dir.path}/pulse_identity_backup.enc';
                  await File(path).writeAsBytes(encrypted);
                  if (ctx.mounted) {
                    showSuccessSnackBar(ctx, ctx.l10n.appearanceSavedTo(path),
                        duration: const Duration(seconds: 3));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    showErrorSnackBar(
                        ctx, ctx.l10n.appearanceSaveFailed(e.toString()));
                  }
                }
              },
              child: Text(context.l10n.settingsSaveFile,
                  style: GoogleFonts.inter(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.done,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
            context, context.l10n.appearanceExportFailed(e.toString()));
      }
    }
  }

  Future<void> _importIdentity(BuildContext context) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(context.l10n.settingsImportIdentity,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.settingsImportIdentityBody,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontMd)),
            const SizedBox(height: DesignTokens.spacing12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary, fontSize: DesignTokens.fontXs),
              decoration: InputDecoration(
                hintText: context.l10n.settingsPasteBackupCode,
                hintStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody),
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
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final b64 = ctrl.text.trim();
                final bytes = base64.decode(b64);

                // Detect format: PLKE magic = encrypted (new); otherwise legacy plaintext.
                Map<String, dynamic> data;
                if (KeyExportService.isValidExportFile(bytes)) {
                  // Encrypted identity backup — ask for the password used during export.
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  final password = await _showBackupPasswordDialog(
                    context,
                    title: context.l10n.settingsImportIdentity,
                    subtitle: context.l10n.dataExportKeysPasswordSubtitle,
                    confirmLabel: context.l10n.settingsImportIdentity,
                    requireConfirm: false,
                  );
                  if (password == null || password.isEmpty) return;
                  final bundle = await KeyExportService.decryptRawBundle(bytes, password);
                  if (bundle == null) {
                    if (context.mounted) {
                      showErrorSnackBar(context,
                          context.l10n.appearanceImportFailed(
                              'wrong password or corrupted backup'));
                    }
                    return;
                  }
                  data = bundle;
                } else {
                  // BUG-3: Legacy plaintext backup — require current password
                  // + explicit confirmation before importing unencrypted keys.
                  // Without the password gate, a social-engineering attack
                  // (trick user into importing a crafted file) can replace all
                  // keys with attacker-controlled ones.
                  if (!context.mounted) return;
                  if (!await _confirmWithAppPassword(context)) return;
                  if (!context.mounted) return;
                  final confirmed = await showConfirmDialog(
                    context,
                    title: 'Unencrypted backup',
                    message: 'This file is an unencrypted identity backup and will '
                        'overwrite your current keys. Only import files you '
                        'created yourself. Proceed?',
                    confirmLabel: 'Import anyway',
                    destructive: true,
                  );
                  if (!confirmed) return;
                  debugPrint('[Identity] Importing legacy unencrypted backup (user confirmed)');
                  final jsonStr = utf8.decode(bytes);
                  data = jsonDecode(jsonStr) as Map<String, dynamic>;
                }

                for (final key in [
                  'signal_id_key',
                  'signal_reg_id',
                  'signal_signed_prekey_0',
                  'signal_prekeys_generated',
                  'nostr_privkey',
                  'session_seed',
                ]) {
                  if (!data.containsKey(key)) continue;
                  final value = data[key] as String? ?? '';
                  // Validate known key formats before writing.
                  if (key == 'nostr_privkey' && !_isValidHex(value, 64)) {
                    debugPrint('[Import] Invalid nostr_privkey format — skipping');
                    continue;
                  }
                  if (key == 'session_seed' && !_isValidHex(value, 64)) {
                    debugPrint('[Import] Invalid session_seed format — skipping');
                    continue;
                  }
                  if (key.startsWith('signal_') && !_isValidBase64(value)) {
                    debugPrint('[Import] Invalid signal key format for $key — skipping');
                    continue;
                  }
                  // Normalise hex keys to lowercase for internal consistency.
                  final normalised = (key == 'nostr_privkey' || key == 'session_seed')
                      ? value.toLowerCase()
                      : value;
                  await _secureStorage.write(key: key, value: normalised);
                }
                final prefs2 = await SharedPreferences.getInstance();
                if (data.containsKey('user_identity')) {
                  await prefs2.setString(
                      'user_identity', data['user_identity'] as String);
                }
                if (data.containsKey('contacts')) {
                  await prefs2.setString('contacts', data['contacts'] as String);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  showSuccessSnackBar(
                      context, context.l10n.settingsIdentityImported,
                      duration: const Duration(seconds: 4));
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  showErrorSnackBar(context,
                      context.l10n.appearanceImportFailed(e.toString()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
            ),
            child: Text(context.l10n.apply,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  // ── Message backup ────────────────────────────────────────────────────────

  Future<void> _backupMessages(BuildContext context) async {
    final password = await _showBackupPasswordDialog(
      context,
      title: context.l10n.dataBackupMessages,
      subtitle: context.l10n.dataBackupPasswordSubtitle,
      confirmLabel: context.l10n.dataBackupConfirmLabel,
      requireConfirm: true,
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    int progressTotal = 0;
    final progressKey = GlobalKey<BackupProgressDialogState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackupProgressDialog(
        key: progressKey,
        title: context.l10n.dataCreatingBackup,
        initialStatus: context.l10n.dataBackupPreparing,
      ),
    );

    try {
      final storage = LocalStorageService();
      final bytes = await storage.exportBackup(
        password,
        onProgress: (done, total) {
          progressTotal = total;
          progressKey.currentState?.updateProgress(
            context.l10n.dataBackupExporting(done, total),
            total > 0 ? done / total : 0,
          );
        },
      );

      if (!context.mounted) return;

      if (bytes == null) {
        Navigator.of(context).pop();
        showErrorSnackBar(context, context.l10n.dataBackupFailed);
        return;
      }

      progressKey.currentState?.updateProgress(context.l10n.dataBackupSavingFile, 1.0);

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final defaultName = 'pulse_backup_$timestamp.plbk';

      String? savePath;
      try {
        savePath = await FilePicker.platform.saveFile(
          dialogTitle: context.l10n.dataSaveMessageBackupDialog,
          fileName: defaultName,
          type: FileType.any,
        );
      } catch (e) {
        debugPrint('[Backup] FilePicker.saveFile failed: $e');
      }

      if (savePath == null) {
        final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        final fallbackPath = '${dir.path}/$defaultName';

        // Ask user before writing to shared Downloads folder.
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Save backup to Downloads?'),
            content: Text('No file picker available. The backup will be saved to:\n$fallbackPath'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Save')),
            ],
          ),
        );
        if (confirmed != true) return;
        savePath = fallbackPath;
      }

      await File(savePath).writeAsBytes(bytes);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      showSuccessSnackBar(
          context, context.l10n.dataBackupSaved(progressTotal, savePath),
          duration: const Duration(seconds: 4));
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showErrorSnackBar(
            context, context.l10n.dataBackupFailedError(e.toString()));
      }
    }
  }

  // ── Message restore ───────────────────────────────────────────────────────

  Future<void> _restoreMessages(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: context.l10n.dataSelectMessageBackupDialog,
      type: FileType.any,
      withData: true,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.bytes == null) {
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        final file = File(result.files.first.path!);
        if (!await file.exists()) return;
        final fileBytes = await file.readAsBytes();
        if (!context.mounted) return;
        await _doRestore(context, fileBytes); // ignore: use_build_context_synchronously
        return;
      }
      return;
    }
    if (!context.mounted) return;
    await _doRestore(context, result.files.first.bytes!); // ignore: use_build_context_synchronously
  }

  Future<void> _doRestore(BuildContext context, Uint8List fileBytes) async {
    if (fileBytes.length < 34) {
      if (context.mounted) {
        showErrorSnackBar(context, context.l10n.dataInvalidBackupFile);
      }
      return;
    }

    const magic = [0x50, 0x4C, 0x42, 0x4B];
    for (int i = 0; i < 4; i++) {
      if (fileBytes[i] != magic[i]) {
        if (context.mounted) {
          showErrorSnackBar(context, context.l10n.dataNotValidBackupFile);
        }
        return;
      }
    }

    if (!context.mounted) return;
    final password = await _showBackupPasswordDialog(
      context,
      title: context.l10n.dataRestoreMessages,
      subtitle: context.l10n.dataRestorePasswordSubtitle,
      confirmLabel: context.l10n.dataRestoreConfirmLabel,
      requireConfirm: false,
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    final progressKey = GlobalKey<BackupProgressDialogState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackupProgressDialog(
        key: progressKey,
        title: context.l10n.dataRestoringMessages,
        initialStatus: context.l10n.dataRestoreDecrypting,
      ),
    );

    try {
      final storage = LocalStorageService();
      final result = await storage.importBackup(
        fileBytes,
        password,
        onProgress: (done, total) {
          progressKey.currentState?.updateProgress(
            context.l10n.dataRestoreImporting(done, total),
            total > 0 ? done / total : 0,
          );
        },
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (result.imported < 0) {
        showErrorSnackBar(context, context.l10n.dataRestoreFailed);
      } else {
        final msg = result.imported > 0
            ? context.l10n.dataRestoreSuccess(result.imported)
            : context.l10n.dataRestoreNothingNew;
        final failedMsg = result.failed > 0
            ? ' (${result.failed} entries skipped)'
            : '';
        if (result.failed > 0) {
          showWarningSnackBar(context, '$msg$failedMsg');
        } else {
          showSuccessSnackBar(context, '$msg$failedMsg',
              duration: const Duration(seconds: 3));
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showErrorSnackBar(
            context, context.l10n.dataRestoreFailedError(e.toString()));
      }
    }
  }

  // ── Key export ────────────────────────────────────────────────────────────

  Future<void> _exportKeysToFile(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFE67E22), size: DesignTokens.iconLg),
            const SizedBox(width: DesignTokens.spacing10),
            Expanded(
              child: Text(
                context.l10n.settingsSensitiveOperation,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: DesignTokens.fontXl,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.settingsSensitiveOperationBody,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
            ),
            child: Text(
              context.l10n.settingsIUnderstandContinue,
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;

    // Require the current app lock password before exporting private keys.
    // An attacker with brief access to an unlocked device could otherwise
    // export all keys without knowing the password.
    if (!await _confirmWithAppPassword(context)) return;
    if (!context.mounted) return;

    final password = await _showBackupPasswordDialog(
      context,
      title: context.l10n.dataExportKeys,
      subtitle: context.l10n.dataExportKeysPasswordSubtitle,
      confirmLabel: context.l10n.dataExportKeysConfirmLabel,
      requireConfirm: true,
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackupProgressDialog(
        title: context.l10n.dataExportingKeys,
        initialStatus: context.l10n.dataExportingKeysStatus,
      ),
    );

    try {
      final bytes = await KeyExportService.exportKeys(password);
      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (bytes == null) {
        showErrorSnackBar(context, context.l10n.dataExportFailed);
        return;
      }

      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final defaultName = 'pulse_keys_$timestamp.plke';

      try {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: context.l10n.dataSaveKeyExportDialog,
          fileName: defaultName,
          bytes: bytes,
        );
        if (savePath != null) {
          final f = File(savePath);
          if (!await f.exists()) {
            await f.writeAsBytes(bytes);
          }
          if (context.mounted) {
            showSuccessSnackBar(
                context, context.l10n.dataKeysExportedTo(savePath),
                duration: const Duration(seconds: 4));
          }
        }
      } catch (e) {
        debugPrint('[KeyExport] FilePicker.saveFile failed: $e');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showErrorSnackBar(
            context, context.l10n.dataExportFailedError(e.toString()));
      }
    }
  }

  // ── Key import ────────────────────────────────────────────────────────────

  Future<void> _importKeysFromFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: context.l10n.dataSelectKeyExportDialog,
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final Uint8List fileBytes;

    if (file.bytes != null) {
      fileBytes = file.bytes!;
    } else if (file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    } else {
      return;
    }

    if (!context.mounted) return;

    if (!KeyExportService.isValidExportFile(fileBytes)) {
      showErrorSnackBar(context, context.l10n.dataNotValidKeyFile);
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFE74C3C), size: DesignTokens.iconLg),
            const SizedBox(width: DesignTokens.spacing10),
            Expanded(
              child: Text(
                context.l10n.settingsReplaceIdentity,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: DesignTokens.fontXl,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.settingsReplaceIdentityBody,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
            ),
            child: Text(
              context.l10n.settingsReplaceKeys,
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;

    final password = await _showBackupPasswordDialog(
      context,
      title: context.l10n.dataImportKeys,
      subtitle: context.l10n.dataImportKeysPasswordSubtitle,
      confirmLabel: context.l10n.dataImportKeysConfirmLabel,
      requireConfirm: false,
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackupProgressDialog(
        title: context.l10n.dataImportingKeys,
        initialStatus: context.l10n.dataImportingKeysStatus,
      ),
    );

    try {
      final imported = await KeyExportService.importKeys(fileBytes, password);
      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (imported < 0) {
        showErrorSnackBar(context, context.l10n.dataImportFailed);
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog.adaptive(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
            title: Text(
              context.l10n.settingsKeysImported,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
            content: Text(
              context.l10n.settingsKeysImportedBody(imported),
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
                ),
                child: Text(
                  context.l10n.settingsRestartNow,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  context.l10n.settingsLater,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showErrorSnackBar(
            context, context.l10n.dataImportFailedError(e.toString()));
      }
    }
  }

  // ── Key format validators ────────────────────────────────────────────────

  // FINDING-13 fix: accept uppercase hex (e.g. from other Nostr clients),
  // normalise to lowercase before writing.
  static bool _isValidHex(String s, int expectedLen) =>
      s.length == expectedLen && RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);

  static bool _isValidBase64(String s) {
    if (s.isEmpty) return false;
    try {
      base64.decode(s);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsData),
        const SizedBox(height: DesignTokens.spacing14),
        // ── Messages ──────────────────────────────────────────
        settingsGroup(children: [
          settingsGroupRow(
            icon: Icons.cloud_download_rounded,
            iconColor: const Color(0xFF3498DB),
            title: context.l10n.settingsBackupMessages,
            subtitle: context.l10n.settingsBackupMessagesSubtitleV2,
            onTap: () => _backupMessages(context),
          ),
          settingsGroupRow(
            icon: Icons.cloud_upload_rounded,
            iconColor: const Color(0xFF2ECC71),
            title: context.l10n.settingsRestoreMessages,
            subtitle: context.l10n.settingsRestoreMessagesSubtitle,
            onTap: () => _restoreMessages(context),
          ),
        ]),
        const SizedBox(height: DesignTokens.spacing12),
        // ── Identity ──────────────────────────────────────────
        settingsGroup(children: [
          settingsGroupRow(
            icon: Icons.backup_rounded,
            iconColor: const Color(0xFF2ECC71),
            title: context.l10n.settingsIdentityBackup,
            subtitle: context.l10n.settingsIdentityBackupSubtitle,
            onTap: () => _showBackupOptions(context),
          ),
          settingsGroupRow(
            icon: Icons.phonelink_rounded,
            iconColor: const Color(0xFF3498DB),
            title: context.l10n.settingsTransferDevice,
            subtitle: context.l10n.settingsTransferDeviceSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeviceTransferScreen()),
            ),
          ),
        ]),
        const SizedBox(height: DesignTokens.spacing12),
        // ── Keys ──────────────────────────────────────────────
        settingsGroup(children: [
          settingsGroupRow(
            icon: Icons.key_rounded,
            iconColor: const Color(0xFFE67E22),
            title: context.l10n.settingsExportKeys,
            subtitle: context.l10n.settingsExportKeysSubtitle,
            onTap: () => _exportKeysToFile(context),
          ),
          settingsGroupRow(
            icon: Icons.key_off_rounded,
            iconColor: const Color(0xFF9B59B6),
            title: context.l10n.settingsImportKeys,
            subtitle: context.l10n.settingsImportKeysSubtitle,
            onTap: () => _importKeysFromFile(context),
          ),
        ]),
      ],
    );
  }
}
