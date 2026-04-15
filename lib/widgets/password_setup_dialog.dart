import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../l10n/l10n_ext.dart';

/// Dialog shown after account creation to set an app-level password.
/// The password hash + salt are stored by the caller via [onSet].
class PasswordSetupDialog extends StatefulWidget {
  final Future<void> Function(String password) onSet;
  final VoidCallback onSkip;

  const PasswordSetupDialog({
    super.key,
    required this.onSet,
    required this.onSkip,
  });

  @override
  State<PasswordSetupDialog> createState() => _PasswordSetupDialogState();
}

class _PasswordSetupDialogState extends State<PasswordSetupDialog> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPass = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pass = _passController.text;
    final confirm = _confirmController.text;

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(pass);
    final hasDigit = RegExp(r'\d').hasMatch(pass);
    final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(pass);
    if (pass.length < 8) {
      setState(() => _error = context.l10n.passwordMinChars);
      return;
    }
    if (!hasLetter || !hasDigit || !hasSpecial) {
      setState(() => _error = context.l10n.passwordNeedsVariety);
      return;
    }
    if (pass != confirm) {
      setState(() => _error = context.l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSet(pass);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacing28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Container(
                width: DesignTokens.avatarSm + DesignTokens.spacing4,
                height: DesignTokens.avatarSm + DesignTokens.spacing4,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Color(0xFF60A5FA), size: DesignTokens.fontDisplay),
              ),
              const SizedBox(width: DesignTokens.spacing14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.passwordSetAppPassword,
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: DesignTokens.fontTitle,
                            fontWeight: FontWeight.w700)),
                    Text(context.l10n.passwordProtectsMessages,
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: DesignTokens.spacing20),

            // Info banner
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing12),
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignTokens.spacing10),
              ),
              child: Text(
                context.l10n.passwordInfoBanner,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontBody,
                    height: 1.5),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing20),

            _PasswordField(
              controller: _passController,
              hint: context.l10n.passwordHint,
              visible: _showPass,
              accentColor: const Color(0xFF60A5FA),
              onToggle: () => setState(() => _showPass = !_showPass),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: DesignTokens.spacing12),
            _PasswordField(
              controller: _confirmController,
              hint: context.l10n.passwordConfirmHint,
              visible: _showConfirm,
              accentColor: const Color(0xFF60A5FA),
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
              onChanged: (_) => setState(() => _error = null),
            ),

            if (_error != null) ...[
              const SizedBox(height: DesignTokens.spacing10),
              Text(_error!,
                  style: GoogleFonts.inter(
                      color: const Color(0xFFF87171), fontSize: DesignTokens.fontBody)),
            ],
            const SizedBox(height: DesignTokens.spacing24),

            // Set button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(context.l10n.passwordSetButton,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: DesignTokens.fontInput,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),

            // Skip
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: _loading ? null : widget.onSkip,
                child: Text(context.l10n.passwordSkipForNow,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared password text field ───────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool visible;
  final Color accentColor;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.visible,
    required this.accentColor,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontInput),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg),
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
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: DesignTokens.inputContentPaddingH, vertical: DesignTokens.inputContentPaddingV),
        suffixIcon: IconButton(
          icon: Icon(
              visible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppTheme.textSecondary,
              size: DesignTokens.fontHeading),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
