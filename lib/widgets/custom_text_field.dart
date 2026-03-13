import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSubmitted;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24), // Pill shape for chat inputs
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5), width: 1),
        ),
      ),
    );
  }
}
