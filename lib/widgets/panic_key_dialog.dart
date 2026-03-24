import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/password_hasher.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../l10n/l10n_ext.dart';

/// Dialog shown after password setup to configure an emergency panic key.
/// Entering this key at the lock screen instantly wipes all app data.
class PanicKeyDialog extends StatefulWidget {
  final Future<void> Function(String key) onSet;
  final VoidCallback onSkip;

  const PanicKeyDialog({
    super.key,
    required this.onSet,
    required this.onSkip,
  });

  @override
  State<PanicKeyDialog> createState() => _PanicKeyDialogState();
}

class _PanicKeyDialogState extends State<PanicKeyDialog> {
  final _keyController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showKey = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _keyController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  static const _ss = FlutterSecureStorage();

  Future<void> _submit() async {
    final key = _keyController.text;
    final confirm = _confirmController.text;

    if (key.length < 8) {
      setState(() => _error = context.l10n.panicMinChars);
      return;
    }
    if (key != confirm) {
      setState(() => _error = context.l10n.panicKeysDoNotMatch);
      return;
    }

    // Reject panic key == app password (would wipe data on normal unlock).
    final pwHash = await _ss.read(key: 'app_password_hash');
    final pwSalt = await _ss.read(key: 'app_password_salt');
    if (pwHash != null && pwSalt != null) {
      if (await PasswordHasher.verify(key, pwSalt, pwHash)) {
        if (mounted) {
          setState(() => _error = 'Panic key must differ from your app password');
        }
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSet(key);
    } catch (e) {
      debugPrint('[PanicKey] Failed to save panic key: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = context.l10n.panicSetFailed;
        });
      }
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
                  color: const Color(0xFFF87171).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFF87171), size: DesignTokens.fontDisplay),
              ),
              const SizedBox(width: DesignTokens.spacing14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.panicSetPanicKey,
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: DesignTokens.fontTitle,
                            fontWeight: FontWeight.w700)),
                    Text(context.l10n.panicEmergencySelfDestruct,
                        style: GoogleFonts.inter(
                            color: const Color(0xFFF87171), fontSize: DesignTokens.fontBody)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: DesignTokens.spacing20),

            // Warning banner
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing12),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                border: Border.all(
                    color: const Color(0xFFF87171).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.dangerous_rounded,
                        color: Color(0xFFF87171), size: DesignTokens.fontMd),
                    const SizedBox(width: DesignTokens.spacing6),
                    Text(context.l10n.panicIrreversible,
                        style: GoogleFonts.inter(
                            color: const Color(0xFFF87171),
                            fontSize: DesignTokens.fontBody,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: DesignTokens.spacing6),
                  Text(
                    context.l10n.panicWarningBody,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: DesignTokens.fontBody,
                        height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing20),

            _PanicField(
              controller: _keyController,
              hint: context.l10n.panicKeyHint,
              visible: _showKey,
              onToggle: () => setState(() => _showKey = !_showKey),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: DesignTokens.spacing12),
            _PanicField(
              controller: _confirmController,
              hint: context.l10n.panicConfirmHint,
              visible: _showConfirm,
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
                  backgroundColor: const Color(0xFFF87171),
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
                    : Text(context.l10n.panicSetPanicKey,
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
                child: Text(context.l10n.skip,
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

// ─── Local password field ─────────────────────────────────────────────────────

class _PanicField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool visible;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;

  const _PanicField({
    required this.controller,
    required this.hint,
    required this.visible,
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
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
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
