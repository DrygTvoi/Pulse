import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier instance = ThemeNotifier._internal();

  // ── Mode ─────────────────────────────────────────────────────────────────
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get themeMode => _mode;

  // ── Custom accent / style overrides (apply to both light & dark) ─────────
  Color? _customPrimary;   // null = palette default
  Color? _customAccent;
  double _borderRadius = 12.0;
  String _fontFamily = 'Inter';

  double get borderRadius => _borderRadius;
  String get fontFamily => _fontFamily;

  // ── Convenience getters (match current effective palette) ─────────────────
  bool get isDark => _mode == ThemeMode.dark;

  Color get primary     => _customPrimary ?? const Color(0xFF00A884);
  Color get primaryLight => Color.lerp(primary, Colors.white, 0.3)!;
  Color get accent      => _customAccent ?? (isDark ? const Color(0xFF53BDEB) : const Color(0xFF027EB5));
  Color get error       => isDark ? const Color(0xFFFF2D55) : const Color(0xFFD93025);

  Color get background  => isDark ? const Color(0xFF111B21) : const Color(0xFFF0F2F5);
  Color get surface     => isDark ? const Color(0xFF202C33) : const Color(0xFFFFFFFF);
  Color get surfaceVariant => isDark ? const Color(0xFF2A3942) : const Color(0xFFE9ECEF);
  Color get textPrimary => isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21);
  Color get textSecondary => isDark ? const Color(0xFF8696A0) : const Color(0xFF667781);

  ThemeNotifier._internal() {
    _loadFromPrefs();
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('theme_mode') ?? 'dark';
    _mode = _modeFromString(modeStr);

    if (prefs.getBool('theme_user_customized') == true) {
      if (prefs.containsKey('theme_primary')) {
        _customPrimary = Color(prefs.getInt('theme_primary')!);
      }
      if (prefs.containsKey('theme_accent')) {
        _customAccent = Color(prefs.getInt('theme_accent')!);
      }
      _borderRadius = prefs.getDouble('theme_radius') ?? 12.0;
      _fontFamily = prefs.getString('theme_font') ?? 'Inter';
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _modeToString(_mode));
    await prefs.setBool('theme_user_customized', true);
    if (_customPrimary != null) await prefs.setInt('theme_primary', _customPrimary!.toARGB32());
    if (_customAccent  != null) await prefs.setInt('theme_accent',  _customAccent!.toARGB32());
    await prefs.setDouble('theme_radius', _borderRadius);
    await prefs.setString('theme_font', _fontFamily);
  }

  static ThemeMode _modeFromString(String s) {
    switch (s) {
      case 'light':  return ThemeMode.light;
      case 'system': return ThemeMode.system;
      default:       return ThemeMode.dark;
    }
  }

  static String _modeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.system: return 'system';
      default:               return 'dark';
    }
  }

  // ── Public setters ────────────────────────────────────────────────────────
  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners(); // update UI immediately
    _save();           // persist in background (fire-and-forget)
  }

  void updateColors({Color? primary, Color? accent}) {
    if (primary != null) _customPrimary = primary;
    if (accent  != null) _customAccent  = accent;
    _save();
    notifyListeners();
  }

  void updateRadius(double radius) {
    _borderRadius = radius;
    _save();
    notifyListeners();
  }

  void updateFont(String font) {
    _fontFamily = font;
    _save();
    notifyListeners();
  }

  /// Reset custom overrides (called when switching to a preset).
  void resetCustom() {
    _customPrimary = null;
    _customAccent  = null;
    _borderRadius  = 12.0;
    _fontFamily    = 'Inter';
  }

  TextStyle getTextStyle(TextStyle baseStyle) {
    if (_fontFamily == 'Roboto')    return GoogleFonts.roboto(textStyle: baseStyle);
    if (_fontFamily == 'Fira Code') return GoogleFonts.firaCode(textStyle: baseStyle);
    if (_fontFamily == 'Outfit')    return GoogleFonts.outfit(textStyle: baseStyle);
    return GoogleFonts.inter(textStyle: baseStyle);
  }

  // ── ThemeData builders ────────────────────────────────────────────────────

  /// Used by MaterialApp.theme (light branch).
  ThemeData get lightThemeData => _buildThemeData(isDark: false);

  /// Used by MaterialApp.darkTheme (dark branch).
  ThemeData get darkThemeData  => _buildThemeData(isDark: true);

  /// Legacy getter — returns the currently active theme data.
  ThemeData get themeData => _buildThemeData(isDark: isDark);

  ThemeData _buildThemeData({required bool isDark}) {
    final bg          = isDark ? const Color(0xFF111B21) : const Color(0xFFF0F2F5);
    final surf        = isDark ? const Color(0xFF202C33) : const Color(0xFFFFFFFF);
    final surfVar     = isDark ? const Color(0xFF2A3942) : const Color(0xFFE9ECEF);
    final txtPrimary  = isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21);
    final txtSecondary= isDark ? const Color(0xFF8696A0) : const Color(0xFF667781);
    final err         = isDark ? const Color(0xFFFF2D55) : const Color(0xFFD93025);
    final pri         = _customPrimary ?? const Color(0xFF00A884);
    final acc         = _customAccent  ?? (isDark ? const Color(0xFF53BDEB) : const Color(0xFF027EB5));

    final base = isDark ? ThemeData.dark(useMaterial3: false) : ThemeData.light(useMaterial3: false);
    TextStyle Function({TextStyle? textStyle}) fontFn;
    TextTheme Function(TextTheme) themeFn;
    switch (_fontFamily) {
      case 'Roboto':
        fontFn = ({TextStyle? textStyle}) => GoogleFonts.roboto(textStyle: textStyle);
        themeFn = GoogleFonts.robotoTextTheme;
        break;
      case 'Fira Code':
        fontFn = ({TextStyle? textStyle}) => GoogleFonts.firaCode(textStyle: textStyle);
        themeFn = GoogleFonts.firaCodeTextTheme;
        break;
      case 'Outfit':
        fontFn = ({TextStyle? textStyle}) => GoogleFonts.outfit(textStyle: textStyle);
        themeFn = GoogleFonts.outfitTextTheme;
        break;
      default:
        fontFn = ({TextStyle? textStyle}) => GoogleFonts.inter(textStyle: textStyle);
        themeFn = GoogleFonts.interTextTheme;
    }
    final textTheme = themeFn(base.textTheme).copyWith(
      displayLarge:  fontFn(textStyle: TextStyle(color: txtPrimary,   fontWeight: FontWeight.bold, fontSize: 32)),
      displayMedium: fontFn(textStyle: TextStyle(color: txtPrimary,   fontWeight: FontWeight.bold, fontSize: 26)),
      titleLarge:    fontFn(textStyle: TextStyle(color: txtPrimary,   fontWeight: FontWeight.w600, fontSize: 20)),
      titleMedium:   fontFn(textStyle: TextStyle(color: txtPrimary,   fontWeight: FontWeight.w500, fontSize: 17)),
      titleSmall:    fontFn(textStyle: TextStyle(color: txtSecondary, fontWeight: FontWeight.w500, fontSize: 14)),
      bodyLarge:     fontFn(textStyle: TextStyle(color: txtPrimary,   fontSize: 16, height: 1.4)),
      bodyMedium:    fontFn(textStyle: TextStyle(color: txtSecondary, fontSize: 14, height: 1.4)),
      bodySmall:     fontFn(textStyle: TextStyle(color: txtSecondary, fontSize: 12)),
      labelLarge:    fontFn(textStyle: TextStyle(color: txtPrimary,   fontWeight: FontWeight.w600, fontSize: 16)),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: pri,
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: pri,
        secondary: acc,
        surface: surf,
        error: err,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: txtPrimary,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: txtSecondary),
        titleTextStyle: fontFn(textStyle: TextStyle(color: txtPrimary, fontSize: 19, fontWeight: FontWeight.w600)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pri,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: fontFn(textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: pri,
          textStyle: fontFn(textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfVar,
        hintStyle: fontFn(textStyle: TextStyle(color: txtSecondary, fontSize: 15)),
        labelStyle: fontFn(textStyle: TextStyle(color: txtSecondary, fontSize: 15)),
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
          borderSide: BorderSide(color: pri, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: surfVar,
      cardColor: surf,
      dialogTheme: DialogThemeData(backgroundColor: surf),
    );
  }

  // ── Preset helper (used by DynamicThemeScreen) ────────────────────────────
  void applyPreset({
    required Color primary,
    Color? accent,
    Color? background,
    Color? surface,
    double? radius,
    String? font,
  }) {
    _customPrimary = primary;
    if (accent != null) _customAccent = accent;
    if (radius != null) _borderRadius = radius;
    if (font   != null) _fontFamily   = font;
    _save();
    notifyListeners();
  }
}
