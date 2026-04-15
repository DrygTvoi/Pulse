import 'dart:math';
import 'package:flutter/services.dart';

/// Generates, validates, and formats 24-character alphanumeric recovery keys.
/// Format: XXXX-XXXX-XXXX-XXXX-XXXX-XXXX (~124 bits entropy from [A-Z0-9]).
class RecoveryKeyService {
  RecoveryKeyService._();

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const _rawLength = 24;
  static const _groupSize = 4;

  /// Generate a new random recovery key (formatted with dashes).
  static String generate() {
    final rng = Random.secure();
    final raw = String.fromCharCodes(
      List.generate(_rawLength, (_) => _chars.codeUnitAt(rng.nextInt(_chars.length))),
    );
    return format(raw);
  }

  /// Strip dashes and uppercase → 24-char string for key derivation input.
  static String normalize(String key) =>
      key.replaceAll('-', '').toUpperCase().trim();

  /// Insert dashes every 4 chars for display: XXXX-XXXX-XXXX-XXXX-XXXX-XXXX.
  static String format(String raw) {
    final clean = normalize(raw);
    final buf = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      if (i > 0 && i % _groupSize == 0) buf.write('-');
      buf.write(clean[i]);
    }
    return buf.toString();
  }

  /// True if [key] contains exactly 24 alphanumeric characters (ignoring dashes).
  static bool isValid(String key) {
    final clean = normalize(key);
    if (clean.length != _rawLength) return false;
    return RegExp(r'^[A-Z0-9]+$').hasMatch(clean);
  }
}

/// TextInputFormatter that auto-uppercases, strips invalid chars, and inserts
/// dashes every 4 characters. Max 24 alphanumeric chars (29 with dashes).
class RecoveryKeyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip everything except alphanumeric, uppercase, limit to 24.
    var raw = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (raw.length > 24) raw = raw.substring(0, 24);
    // Insert dashes.
    final formatted = RecoveryKeyService.format(raw);
    // Compute new cursor position.
    final cursor = formatted.length.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}
