// Shared UI helper widgets used by multiple settings sections.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';

Widget settingsSectionLabel(String text) {
  return Text(
    text.toUpperCase(),
    style: GoogleFonts.inter(
      color: AppTheme.textSecondary,
      fontSize: DesignTokens.fontSm,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );
}

Widget settingsSectionDivider(String label) {
  return Row(children: [
    Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        color: AppTheme.textSecondary,
        fontSize: DesignTokens.fontSm,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
    const SizedBox(width: DesignTokens.spacing10),
    Expanded(child: Divider(color: AppTheme.surfaceVariant, thickness: 1)),
  ]);
}

Widget settingsRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
  Widget? trailing,
}) {
  return Material(
    color: AppTheme.surface,
    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(DesignTokens.cardPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.spacing10),
            ),
            child: Icon(icon, color: iconColor, size: DesignTokens.iconMd),
          ),
          const SizedBox(width: DesignTokens.spacing14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: DesignTokens.fontLg,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontBody,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary, size: DesignTokens.iconMd),
        ],
      ),
    ),
    ),
  );
}

Widget settingsField({
  required TextEditingController controller,
  required String hint,
  required String label,
  required IconData icon,
  bool obscure = false,
}) {
  return TextField(
    controller: controller,
    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontLg),
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle:
          GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: DesignTokens.fontHeading),
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: DesignTokens.inputContentPaddingH, vertical: DesignTokens.inputContentPaddingV),
    ),
  );
}

/// Groups multiple settings rows into a rounded card with dividers between them.
Widget settingsGroup({required List<Widget> children}) {
  return DecoratedBox(
    decoration: BoxDecoration(boxShadow: DesignTokens.shadowSm),
    child: Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, thickness: 0.5, color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                  indent: DesignTokens.spacing16, endIndent: DesignTokens.spacing16),
          ],
        ],
      ),
    ),
  );
}

/// A row inside a settingsGroup — no standalone card background.
Widget settingsGroupRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
  Widget? trailing,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(DesignTokens.cardPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.spacing10),
            ),
            child: Icon(icon, color: iconColor, size: DesignTokens.iconMd),
          ),
          const SizedBox(width: DesignTokens.spacing14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: DesignTokens.fontLg,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontBody,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary, size: DesignTokens.iconMd),
        ],
      ),
    ),
  );
}

// ── Backup progress dialog ────────────────────────────────────────────────────

class BackupProgressDialog extends StatefulWidget {
  final String title;
  final String initialStatus;

  const BackupProgressDialog({
    super.key,
    required this.title,
    required this.initialStatus,
  });

  @override
  State<BackupProgressDialog> createState() => BackupProgressDialogState();
}

class BackupProgressDialogState extends State<BackupProgressDialog> {
  late String _status;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  void updateProgress(String status, double progress) {
    if (mounted) {
      setState(() {
        _status = status;
        _progress = progress.clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
      title: Text(
        widget.title,
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: DesignTokens.fontXl,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: DesignTokens.spacing8),
          LinearProgressIndicator(
            value: _progress > 0 ? _progress : null,
            backgroundColor: AppTheme.surfaceVariant,
            color: const Color(0xFF3498DB),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Text(
            _status,
            style:
                GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── SnackBar helpers ──────────────────────────────────────────────────────────

void showSuccessSnackBar(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2)}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,
        style: GoogleFonts.inter(fontSize: DesignTokens.fontBody)),
    backgroundColor: AppTheme.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
    duration: duration,
  ));
}

void showErrorSnackBar(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 3)}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,
        style: GoogleFonts.inter(fontSize: DesignTokens.fontBody)),
    backgroundColor: AppTheme.error,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
    duration: duration,
  ));
}

void showWarningSnackBar(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 3)}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,
        style: GoogleFonts.inter(fontSize: DesignTokens.fontBody)),
    backgroundColor: AppTheme.warningDark,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
    duration: duration,
  ));
}

// ── Password field widget ─────────────────────────────────────────────────────

class SettingsPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? hintText;
  final String? errorText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const SettingsPasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.hintText,
    this.errorText,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          autofocus: autofocus,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontSize: DesignTokens.fontInput),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: DesignTokens.fontLg),
            filled: true,
            fillColor: AppTheme.surfaceVariant,
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusMedium),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusMedium),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide:
                  const BorderSide(color: Color(0xFF60A5FA), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing14,
                vertical: DesignTokens.spacing12),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: AppTheme.textSecondary,
                size: DesignTokens.fontHeading,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          onChanged: onChanged,
        ),
        if (errorText != null) ...[
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            errorText!,
            style: GoogleFonts.inter(
                color: const Color(0xFFF87171),
                fontSize: DesignTokens.fontBody),
          ),
        ],
      ],
    );
  }
}

// ── Confirmation dialog helper ────────────────────────────────────────────────

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog.adaptive(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
      title: Text(
        title,
        style: GoogleFonts.inter(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
      ),
      content: Text(
        message,
        style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: DesignTokens.fontMd,
            height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel ?? 'Confirm',
            style: GoogleFonts.inter(
              color: destructive
                  ? const Color(0xFFF87171)
                  : AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result == true;
}
