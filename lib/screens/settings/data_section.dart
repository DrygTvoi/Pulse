// Settings — Data section: message backup/restore and key export/import.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/key_export_service.dart';
import '../../services/local_storage_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n_ext.dart';
import 'settings_widgets.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key});

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
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                obscureText: !showPass,
                autofocus: true,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: context.l10n.settingsBackupPassword,
                  hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                    borderSide: const BorderSide(
                        color: Color(0xFF3498DB), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    onPressed: () => setS(() => showPass = !showPass),
                  ),
                ),
                onChanged: (_) => setS(() => error = null),
              ),
              if (requireConfirm) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: !showPass,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: context.l10n.passwordConfirmHint,
                    hintStyle: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 14),
                    filled: true,
                    fillColor: AppTheme.surfaceVariant,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      borderSide: const BorderSide(
                          color: Color(0xFF3498DB), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setS(() => error = null),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: GoogleFonts.inter(
                      color: const Color(0xFFF87171), fontSize: 12),
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
                if (pw.length < 4) {
                  setS(() =>
                      error = context.l10n.settingsPasswordMin4Chars);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataBackupFailed,
              style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
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
        final dir = await getDownloadsDirectory();
        savePath = '${dir?.path ?? '/tmp'}/$defaultName';
      }

      await File(savePath).writeAsBytes(bytes);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          context.l10n.dataBackupSaved(progressTotal, savePath),
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
      ));
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataBackupFailedError(e.toString()), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataInvalidBackupFile,
              style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
      }
      return;
    }

    const magic = [0x50, 0x4C, 0x42, 0x4B];
    for (int i = 0; i < 4; i++) {
      if (fileBytes[i] != magic[i]) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.dataNotValidBackupFile,
                style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
          ));
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
      final imported = await storage.importBackup(
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

      if (imported < 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataRestoreFailed,
              style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            imported > 0
                ? context.l10n.dataRestoreSuccess(imported)
                : context.l10n.dataRestoreNothingNew,
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataRestoreFailedError(e.toString()), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
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
                color: Color(0xFFE67E22), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.settingsSensitiveOperation,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.settingsSensitiveOperationBody,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataExportFailed,
              style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(context.l10n.dataKeysExportedTo(savePath),
                  style: GoogleFonts.inter()),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
            ));
          }
        }
      } catch (e) {
        debugPrint('[KeyExport] FilePicker.saveFile failed: $e');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataExportFailedError(e.toString()), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.dataNotValidKeyFile,
            style: GoogleFonts.inter()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
      ));
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
                color: Color(0xFFE74C3C), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.settingsReplaceIdentity,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.settingsReplaceIdentityBody,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataImportFailed,
              style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
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
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.dataImportFailedError(e.toString()), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsData),
        const SizedBox(height: 14),
        settingsRow(
          icon: Icons.cloud_download_rounded,
          iconColor: const Color(0xFF3498DB),
          title: context.l10n.settingsBackupMessages,
          subtitle: context.l10n.settingsBackupMessagesSubtitleV2,
          onTap: () => _backupMessages(context),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.cloud_upload_rounded,
          iconColor: const Color(0xFF2ECC71),
          title: context.l10n.settingsRestoreMessages,
          subtitle: context.l10n.settingsRestoreMessagesSubtitle,
          onTap: () => _restoreMessages(context),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.key_rounded,
          iconColor: const Color(0xFFE67E22),
          title: context.l10n.settingsExportKeys,
          subtitle: context.l10n.settingsExportKeysSubtitle,
          onTap: () => _exportKeysToFile(context),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.key_off_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: context.l10n.settingsImportKeys,
          subtitle: context.l10n.settingsImportKeysSubtitle,
          onTap: () => _importKeysFromFile(context),
        ),
      ],
    );
  }
}
