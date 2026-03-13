import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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

  Future<void> _submit() async {
    final key = _keyController.text;
    final confirm = _confirmController.text;

    if (key.length < 4) {
      setState(() => _error = 'Panic key must be at least 4 characters');
      return;
    }
    if (key != confirm) {
      setState(() => _error = 'Keys do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSet(key);
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
                  color: const Color(0xFFF87171).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFF87171), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Panic Key',
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    Text('Emergency self-destruct',
                        style: GoogleFonts.inter(
                            color: const Color(0xFFF87171), fontSize: 12)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Warning banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF87171).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.dangerous_rounded,
                        color: Color(0xFFF87171), size: 13),
                    const SizedBox(width: 6),
                    Text('This action is irreversible',
                        style: GoogleFonts.inter(
                            color: const Color(0xFFF87171),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Entering this key at the lock screen instantly wipes ALL data — '
                    'messages, contacts, keys, identity. '
                    'Use a key different from your regular password.',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _PanicField(
              controller: _keyController,
              hint: 'Panic key',
              visible: _showKey,
              onToggle: () => setState(() => _showKey = !_showKey),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
            _PanicField(
              controller: _confirmController,
              hint: 'Confirm panic key',
              visible: _showConfirm,
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
                  backgroundColor: const Color(0xFFF87171),
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
                    : Text('Set Panic Key',
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
                child: Text('Skip',
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
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
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
