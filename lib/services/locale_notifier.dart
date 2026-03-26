import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton ChangeNotifier that manages the app display locale.
/// null locale means "follow system default".
class LocaleNotifier extends ChangeNotifier {
  static final LocaleNotifier instance = LocaleNotifier._internal();

  Locale? _locale;
  Locale? get locale => _locale;

  /// Language names in their native form — always displayed as-is regardless
  /// of the current app language so users can find their language.
  static const Map<String, String> nativeNames = {
    'ar': 'العربية',
    'de': 'Deutsch',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'hi': 'हिन्दी',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'pl': 'Polski',
    'pt': 'Português',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'uk': 'Українська',
    'zh': '中文',
  };

  LocaleNotifier._internal() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale');
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('app_locale');
    } else {
      await prefs.setString('app_locale', locale.languageCode);
    }
    notifyListeners();
  }
}
