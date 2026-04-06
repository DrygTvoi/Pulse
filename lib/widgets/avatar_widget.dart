import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable avatar widget with HSL-gradient background and optional image.
///
/// Generates a consistent color from [name] hash. Shows initials when
/// no [imageBytes] are provided.
class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final Uint8List? imageBytes;
  final double fontSize;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 52,
    this.imageBytes,
    double? fontSize,
  }) : fontSize = fontSize ?? (size * 0.38);

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.memory(
          imageBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }

    final hue = _nameToHue(name);
    final initials = _initials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.65, 0.50).toColor(),
            HSLColor.fromAHSL(1, hue, 0.60, 0.38).toColor(),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }

  static double _nameToHue(String name) {
    if (name.isEmpty) return 0;
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return (hash % 360).abs().toDouble();
  }

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }
}
