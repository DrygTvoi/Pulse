// Shared UI helper widgets used by multiple settings sections.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

Widget settingsSectionLabel(String text) {
  return Text(
    text.toUpperCase(),
    style: GoogleFonts.inter(
      color: AppTheme.textSecondary,
      fontSize: 11,
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
    const SizedBox(width: 10),
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
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary, size: 20),
        ],
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
    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle:
          GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress > 0 ? _progress : null,
            backgroundColor: AppTheme.surfaceVariant,
            color: const Color(0xFF3498DB),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(
            _status,
            style:
                GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
