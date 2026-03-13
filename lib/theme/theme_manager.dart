import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier instance = ThemeNotifier._internal();

  // WhatsApp-style premium dark palette
  Color _background = const Color(0xFF111B21);
  Color _surface = const Color(0xFF202C33);
  final Color _surfaceVariant = const Color(0xFF2A3942);
  Color _primary = const Color(0xFF00A884); // WhatsApp green
  Color _primaryLight = const Color(0xFF25D366);
  Color _accent = const Color(0xFF53BDEB);
  final Color _error = const Color(0xFFFF2D55);
  final Color _textPrimary = const Color(0xFFE9EDEF);
  final Color _textSecondary = const Color(0xFF8696A0);

  double _borderRadius = 12.0;
  String _fontFamily = 'Inter';

  // Getters
  Color get background => _background;
  Color get surface => _surface;
  Color get surfaceVariant => _surfaceVariant;
  Color get primary => _primary;
  Color get primaryLight => _primaryLight;
  Color get accent => _accent;
  Color get error => _error;
  Color get textPrimary => _textPrimary;
  Color get textSecondary => _textSecondary;
  double get borderRadius => _borderRadius;
  String get fontFamily => _fontFamily;

  ThemeNotifier._internal() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Only load if user explicitly customized via Theme Sandbox
    if (prefs.getBool('theme_user_customized') == true) {
      if (prefs.containsKey('theme_primary')) {
        _primary = Color(prefs.getInt('theme_primary')!);
        _primaryLight = Color.lerp(_primary, Colors.white, 0.3)!;
        _background = Color(prefs.getInt('theme_background') ?? _background.toARGB32());
        _surface = Color(prefs.getInt('theme_surface') ?? _surface.toARGB32());
        _accent = Color(prefs.getInt('theme_accent') ?? _accent.toARGB32());
        _borderRadius = prefs.getDouble('theme_radius') ?? 12.0;
        _fontFamily = prefs.getString('theme_font') ?? 'Inter';
        notifyListeners();
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_user_customized', true);
    await prefs.setInt('theme_primary', _primary.toARGB32());
    await prefs.setInt('theme_background', _background.toARGB32());
    await prefs.setInt('theme_surface', _surface.toARGB32());
    await prefs.setInt('theme_accent', _accent.toARGB32());
    await prefs.setDouble('theme_radius', _borderRadius);
    await prefs.setString('theme_font', _fontFamily);
  }

  void updateColors({
    Color? primary,
    Color? background,
    Color? surface,
    Color? accent,
  }) {
    if (primary != null) {
      _primary = primary;
      _primaryLight = Color.lerp(primary, Colors.white, 0.3)!;
    }
    if (background != null) _background = background;
    if (surface != null) _surface = surface;
    if (accent != null) _accent = accent;

    _saveToPrefs();
    notifyListeners();
  }

  void updateRadius(double radius) {
    _borderRadius = radius;
    _saveToPrefs();
    notifyListeners();
  }

  void updateFont(String font) {
    _fontFamily = font;
    _saveToPrefs();
    notifyListeners();
  }

  TextStyle getTextStyle(TextStyle baseStyle) {
    if (_fontFamily == 'Roboto') return GoogleFonts.roboto(textStyle: baseStyle);
    if (_fontFamily == 'Fira Code') return GoogleFonts.firaCode(textStyle: baseStyle);
    if (_fontFamily == 'Outfit') return GoogleFonts.outfit(textStyle: baseStyle);
    return GoogleFonts.inter(textStyle: baseStyle);
  }

  ThemeData get themeData {
    final base = ThemeData.dark(useMaterial3: false);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge:  GoogleFonts.inter(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: GoogleFonts.inter(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 26),
      titleLarge:    GoogleFonts.inter(color: _textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium:   GoogleFonts.inter(color: _textPrimary, fontWeight: FontWeight.w500, fontSize: 17),
      titleSmall:    GoogleFonts.inter(color: _textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge:     GoogleFonts.inter(color: _textPrimary, fontSize: 16, height: 1.4),
      bodyMedium:    GoogleFonts.inter(color: _textSecondary, fontSize: 14, height: 1.4),
      bodySmall:     GoogleFonts.inter(color: _textSecondary, fontSize: 12),
      labelLarge:    GoogleFonts.inter(color: _textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      primaryColor: _primary,
      colorScheme: ColorScheme.dark(
        primary: _primary,
        secondary: _accent,
        surface: _surface,
        error: _error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimary,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _textSecondary),
        titleTextStyle: GoogleFonts.inter(
            color: _textPrimary, fontSize: 19, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        hintStyle: GoogleFonts.inter(color: _textSecondary, fontSize: 15),
        labelStyle: GoogleFonts.inter(color: _textSecondary, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: _surfaceVariant,
      cardColor: _surface,
      dialogTheme: DialogThemeData(backgroundColor: _surface),
    );
  }
}
