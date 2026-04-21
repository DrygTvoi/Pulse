import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FluffyChat-style avatar: a `RoundedSuperellipseBorder` (iOS-squircle)
/// rather than a circle, with a solid HSL fallback color derived from the
/// `name` (so the same person always lands on the same color across devices).
///
/// Hue algorithm — sum of code units, modulo 12 distinct hues, scaled to
/// [0..360]. Saturation 1.0, lightness 0.45 — matches FluffyChat exactly.
class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final Uint8List? imageBytes;
  final double fontSize;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 48,
    this.imageBytes,
    double? fontSize,
  }) : fontSize = fontSize ?? 0; // 0 = derive in build()

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(size / 2),
      side: BorderSide.none,
    );
    final fallbackBg = _hashColor(name);

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Material(
          shape: shape,
          clipBehavior: Clip.antiAlias,
          color: fallbackBg,
          child: Image.memory(
            imageBytes!,
            width: size,
            height: size,
            cacheWidth: (size * 2).toInt(),
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
      );
    }

    final effectiveFontSize =
        fontSize > 0 ? fontSize : (size / 2.5).roundToDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        shape: shape,
        color: fallbackBg,
        child: Center(
          child: Text(
            _initials(name),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: effectiveFontSize,
            ),
          ),
        ),
      ),
    );
  }

  /// FluffyChat name→color: sum codeUnits, % 12 → 12 distinct hues at 30°
  /// spacing. HSL(.45 lightness, 1.0 saturation) gives saturated mid-tones
  /// that read well on both light and dark surfaces.
  static Color _hashColor(String name) {
    if (name.isEmpty) return const Color(0xFF607D8B);
    var n = 0.0;
    for (var i = 0; i < name.length; i++) {
      n += name.codeUnitAt(i);
    }
    final hue = (n % 12) * 25.5;
    return HSLColor.fromAHSL(1.0, hue, 1.0, 0.45).toColor();
  }

  static final _whitespace = RegExp(r'\s+');

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(_whitespace).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }
}
