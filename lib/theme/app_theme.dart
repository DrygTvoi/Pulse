import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';
import 'theme_manager.dart';

class AppTheme {
  static Color get background => ThemeNotifier.instance.background;
  static Color get surface => ThemeNotifier.instance.surface;
  static Color get surfaceVariant => ThemeNotifier.instance.surfaceVariant;
  static Color get primary => ThemeNotifier.instance.primary;
  static Color get primaryLight => ThemeNotifier.instance.primaryLight;
  static Color get accent => ThemeNotifier.instance.accent;
  static Color get error => ThemeNotifier.instance.error;
  static Color get textPrimary => ThemeNotifier.instance.textPrimary;
  static Color get textSecondary => ThemeNotifier.instance.textSecondary;
  static Color get outgoingBubble => ThemeNotifier.instance.outgoingBubble;
  static Color get incomingBubble => ThemeNotifier.instance.incomingBubble;

  static ThemeData get darkTheme => ThemeNotifier.instance.themeData;

  // ── Provider badge colors (deduplicated) ──────────────
  static const Color providerFirebase = Color(0xFFFFAB00);
  static const Color providerNostr = Color(0xFF9B59B6);
  static const Color providerPulse = Color(0xFF26A69A);
  static const Color providerOxen = Color(0xFF2196F3);

  // ── Status colors ─────────────────────────────────────
  static const Color online = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFE65100);
  static const Color warningDark = Color(0xFF7A3000);
  static const Color errorDeep = Color(0xFF8B0000);
  static const Color destructive = Colors.red;

  // ── Semantic text styles ──────────────────────────────
  // Display — large screen titles
  static TextStyle get displayLarge  => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontDisplayLg, fontWeight: FontWeight.w700);
  static TextStyle get display       => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontDisplay, fontWeight: FontWeight.w700);

  // Heading — section/dialog titles
  static TextStyle get headingLarge  => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontXxl, fontWeight: FontWeight.w700);
  static TextStyle get heading       => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontHeading, fontWeight: FontWeight.w700);

  // Title — appbar, card titles
  static TextStyle get titleLarge    => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700);
  static TextStyle get title         => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w600);

  // Body — main content text
  static TextStyle get bodyLarge     => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontLg);
  static TextStyle get body          => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontMd);
  static TextStyle get bodySecondary => GoogleFonts.inter(color: textSecondary, fontSize: DesignTokens.fontLg);

  // Caption — secondary/supporting text
  static TextStyle get caption       => GoogleFonts.inter(color: textSecondary, fontSize: DesignTokens.fontMd);
  static TextStyle get captionSmall  => GoogleFonts.inter(color: textSecondary, fontSize: DesignTokens.fontBody);

  // Label — buttons, chips, actions
  static TextStyle get labelLarge    => GoogleFonts.inter(color: textPrimary, fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600);
  static TextStyle get label         => GoogleFonts.inter(fontWeight: FontWeight.w600);

  // Menu — drawer items, popup menu entries
  static TextStyle get menuItem      => GoogleFonts.inter(color: textPrimary);
  static TextStyle get menuItemDestructive => GoogleFonts.inter(color: destructive);
}
