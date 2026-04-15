import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Numeric PIN pad with dot indicators. Accepts 4-8 digit PINs.
class PinInput extends StatefulWidget {
  /// Called when the user enters [pinLength] digits.
  final void Function(String pin) onComplete;

  /// Number of digits required (default 4).
  final int pinLength;

  /// Optional title shown above dots.
  final String? title;

  /// Optional error message shown below dots.
  final String? error;

  const PinInput({
    super.key,
    required this.onComplete,
    this.pinLength = 4,
    this.title,
    this.error,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  String _pin = '';

  void _addDigit(String digit) {
    if (_pin.length >= widget.pinLength) return;
    HapticFeedback.lightImpact();
    setState(() => _pin += digit);
    if (_pin.length == widget.pinLength) {
      widget.onComplete(_pin);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void clear() {
    setState(() => _pin = '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: DesignTokens.fontXl,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing20),
        ],
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (i) {
            final filled = i < _pin.length;
            return Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: filled ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: DesignTokens.spacing12),
          Text(
            widget.error!,
            style: GoogleFonts.inter(
              color: AppTheme.errorLight,
              fontSize: DesignTokens.fontMd,
            ),
          ),
        ],
        const SizedBox(height: DesignTokens.spacing28),
        // Numeric keypad
        _buildKeypad(),
      ],
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _keypadRow(['1', '2', '3']),
        const SizedBox(height: DesignTokens.spacing12),
        _keypadRow(['4', '5', '6']),
        const SizedBox(height: DesignTokens.spacing12),
        _keypadRow(['7', '8', '9']),
        const SizedBox(height: DesignTokens.spacing12),
        _keypadRow(['', '0', 'del']),
      ],
    );
  }

  Widget _keypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 80, height: 64);
        if (key == 'del') {
          return SizedBox(
            width: 80,
            height: 64,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: _backspace,
              onLongPress: () {
                HapticFeedback.mediumImpact();
                setState(() => _pin = '');
              },
              child: Center(
                child: Icon(Icons.backspace_outlined,
                    color: AppTheme.textSecondary, size: 24),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Material(
              color: AppTheme.surfaceVariant,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _addDigit(key),
                child: Center(
                  child: Text(
                    key,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
