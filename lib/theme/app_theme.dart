import 'package:flutter/material.dart';
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
  static const Color destructive = Colors.red;
}
