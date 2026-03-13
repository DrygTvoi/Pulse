import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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

    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Color(0xFF60A5FA), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set App Password',
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    Text('Protects your messages at rest',
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Required every time you open Pulse. '
                'If forgotten, your data cannot be recovered.',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            _PasswordField(
              controller: _passController,
              hint: 'Password',
              visible: _showPass,
              accentColor: const Color(0xFF60A5FA),
              onToggle: () => setState(() => _showPass = !_showPass),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _confirmController,
              hint: 'Confirm password',
              visible: _showConfirm,
              accentColor: const Color(0xFF60A5FA),
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
              onChanged: (_) => setState(() => _error = null),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: GoogleFonts.inter(
                      color: const Color(0xFFF87171), fontSize: 12)),
            ],
            const SizedBox(height: 24),

            // Set button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Set Password',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),

            // Skip
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: _loading ? null : widget.onSkip,
                child: Text('Skip for now',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 14)),
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
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
              visible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppTheme.textSecondary,
              size: 18),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
