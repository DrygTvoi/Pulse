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

  static ThemeData get darkTheme => ThemeNotifier.instance.themeData;
}
