import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier instance = ThemeNotifier._internal();

  // ── Mode ─────────────────────────────────────────────────────────────────
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get themeMode => _mode;

  // ── Custom overrides ──────────────────────────────────────────────────────
  Color? _customPrimary;
  Color? _customAccent;
  Color? _customBg;
  Color? _customSurf;
  Color? _customSurfVar;
  Color? _customTextPrimary;
  Color? _customTextSecondary;
  Color? _customOutgoingBubble;
  Color? _customIncomingBubble;
  double _borderRadius = 12.0;
  String _fontFamily = 'Inter';
  TargetPlatform? _customPlatform; // null = use device platform

  double get borderRadius => _borderRadius;
  String get fontFamily => _fontFamily;
  TargetPlatform? get customPlatform => _customPlatform;
  bool get isDark => _mode == ThemeMode.dark;

  // ── Effective palette getters ─────────────────────────────────────────────
  Color get primary       => _customPrimary    ?? const Color(0xFF00A884);
  Color get primaryLight  => Color.lerp(primary, Colors.white, 0.3)!;
  Color get accent        => _customAccent     ?? (isDark ? const Color(0xFF53BDEB) : const Color(0xFF027EB5));
  Color get error         => isDark ? const Color(0xFFFF2D55) : const Color(0xFFD93025);

  Color get background    => _customBg         ?? (isDark ? const Color(0xFF111B21) : const Color(0xFFF0F2F5));
  Color get surface       => _customSurf       ?? (isDark ? const Color(0xFF202C33) : const Color(0xFFFFFFFF));
  Color get surfaceVariant=> _customSurfVar    ?? (isDark ? const Color(0xFF2A3942) : const Color(0xFFE9ECEF));
  Color get textPrimary   => _customTextPrimary    ?? (isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21));
  Color get textSecondary => _customTextSecondary  ?? (isDark ? const Color(0xFF8696A0) : const Color(0xFF667781));

  // ── Bubble colors (WhatsApp 2025) ───────────────────────────────────────
  Color get outgoingBubble => _customOutgoingBubble ?? (isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3));
  Color get incomingBubble => _customIncomingBubble ?? (isDark ? surfaceVariant : const Color(0xFFFFFFFF));

  ThemeNotifier._internal() {
    _loadFromPrefs();
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = _modeFromString(prefs.getString('theme_mode') ?? 'dark');

    if (prefs.getBool('theme_user_customized') == true) {
      if (prefs.containsKey('theme_primary'))    _customPrimary    = Color(prefs.getInt('theme_primary')!);
      if (prefs.containsKey('theme_accent'))     _customAccent     = Color(prefs.getInt('theme_accent')!);
      if (prefs.containsKey('theme_bg'))         _customBg         = Color(prefs.getInt('theme_bg')!);
      if (prefs.containsKey('theme_surf'))       _customSurf       = Color(prefs.getInt('theme_surf')!);
      if (prefs.containsKey('theme_surfvar'))    _customSurfVar    = Color(prefs.getInt('theme_surfvar')!);
      if (prefs.containsKey('theme_text_pri'))   _customTextPrimary    = Color(prefs.getInt('theme_text_pri')!);
      if (prefs.containsKey('theme_text_sec'))   _customTextSecondary  = Color(prefs.getInt('theme_text_sec')!);
      if (prefs.containsKey('theme_bubble_out')) _customOutgoingBubble = Color(prefs.getInt('theme_bubble_out')!);
      if (prefs.containsKey('theme_bubble_in'))  _customIncomingBubble = Color(prefs.getInt('theme_bubble_in')!);
      _borderRadius = prefs.getDouble('theme_radius') ?? 12.0;
      _fontFamily   = prefs.getString('theme_font')   ?? 'Inter';
      _customPlatform = _platformFromString(prefs.getString('theme_platform'));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _modeToString(_mode));
    await prefs.setBool('theme_user_customized', true);
    if (_customPrimary != null) await prefs.setInt('theme_primary', _customPrimary!.toARGB32());
    if (_customAccent  != null) await prefs.setInt('theme_accent',  _customAccent!.toARGB32());
    if (_customBg      != null) await prefs.setInt('theme_bg',      _customBg!.toARGB32());
    if (_customSurf    != null) await prefs.setInt('theme_surf',    _customSurf!.toARGB32());
    if (_customSurfVar != null) await prefs.setInt('theme_surfvar', _customSurfVar!.toARGB32());
    if (_customTextPrimary   != null) await prefs.setInt('theme_text_pri', _customTextPrimary!.toARGB32());
    if (_customTextSecondary != null) await prefs.setInt('theme_text_sec', _customTextSecondary!.toARGB32());
    if (_customOutgoingBubble != null) await prefs.setInt('theme_bubble_out', _customOutgoingBubble!.toARGB32());
    if (_customIncomingBubble != null) await prefs.setInt('theme_bubble_in', _customIncomingBubble!.toARGB32());
    await prefs.setDouble('theme_radius', _borderRadius);
    await prefs.setString('theme_font', _fontFamily);
    if (_customPlatform != null) {
      await prefs.setString('theme_platform', _platformToString(_customPlatform!));
    } else {
      await prefs.remove('theme_platform');
    }
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

  static TargetPlatform? _platformFromString(String? s) {
    switch (s) {
      case 'android': return TargetPlatform.android;
      case 'ios':     return TargetPlatform.iOS;
      default:        return null;
    }
  }

  static String _platformToString(TargetPlatform p) =>
      p == TargetPlatform.iOS ? 'ios' : 'android';

  // ── Public setters ────────────────────────────────────────────────────────
  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
    _save();
  }

  void updateColors({Color? primary, Color? accent}) {
    if (primary != null) _customPrimary = primary;
    if (accent  != null) _customAccent  = accent;
    _save();
    notifyListeners();
  }

  void updateBubbleColors({Color? outgoing, Color? incoming}) {
    if (outgoing != null) _customOutgoingBubble = outgoing;
    if (incoming != null) _customIncomingBubble = incoming;
    _save();
    notifyListeners();
  }

  void updateBackground(Color c) { _customBg = c; _save(); notifyListeners(); }
  void updateSurface(Color c) { _customSurf = c; _save(); notifyListeners(); }
  void updateSurfaceVariant(Color c) { _customSurfVar = c; _save(); notifyListeners(); }

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

  void updatePlatform(TargetPlatform? platform) {
    _customPlatform = platform;
    _save();
    notifyListeners();
  }

  void resetCustom() {
    _customPrimary = _customAccent = null;
    _customBg = _customSurf = _customSurfVar = null;
    _customTextPrimary = _customTextSecondary = null;
    _customOutgoingBubble = _customIncomingBubble = null;
    _customPlatform = null;
    _borderRadius = 12.0;
    _fontFamily = 'Inter';
    _mode = ThemeMode.dark;
    _save();
    notifyListeners();
  }

  TextStyle getTextStyle(TextStyle baseStyle) =>
      GoogleFonts.inter(textStyle: baseStyle);

  // ── ThemeData builders ────────────────────────────────────────────────────
  ThemeData get lightThemeData => _buildThemeData(isDark: false);
  ThemeData get darkThemeData  => _buildThemeData(isDark: true);
  ThemeData get themeData      => _buildThemeData(isDark: isDark);

  ThemeData _buildThemeData({required bool isDark}) {
    // Use custom overrides if set, otherwise use default dark/light palette.
    final bg       = _customBg      ?? (isDark ? const Color(0xFF111B21) : const Color(0xFFF0F2F5));
    final surf     = _customSurf    ?? (isDark ? const Color(0xFF202C33) : const Color(0xFFFFFFFF));
    final surfVar  = _customSurfVar ?? (isDark ? const Color(0xFF2A3942) : const Color(0xFFE9ECEF));
    final txtPri   = _customTextPrimary    ?? (isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21));
    final txtSec   = _customTextSecondary  ?? (isDark ? const Color(0xFF8696A0) : const Color(0xFF667781));
    final err      = isDark ? const Color(0xFFFF2D55) : const Color(0xFFD93025);
    final pri      = _customPrimary ?? const Color(0xFF00A884);
    final acc      = _customAccent  ?? (isDark ? const Color(0xFF53BDEB) : const Color(0xFF027EB5));

    final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

    TextStyle Function({TextStyle? textStyle}) fontFn;
    TextTheme Function(TextTheme) themeFn;
    fontFn  = ({TextStyle? textStyle}) => GoogleFonts.inter(textStyle: textStyle);
    themeFn = GoogleFonts.interTextTheme;

    // On Linux, add Noto Color Emoji as fallback so emoji glyphs render
    // correctly instead of showing as white tofu boxes.
    final emojiFallback = Platform.isLinux
        ? const ['Noto Color Emoji'] : const <String>[];

    TextTheme applyFallback(TextTheme t) {
      if (emojiFallback.isEmpty) return t;
      TextStyle fb(TextStyle? s) =>
          (s ?? const TextStyle()).copyWith(fontFamilyFallback: emojiFallback);
      return t.copyWith(
        displayLarge: fb(t.displayLarge),
        displayMedium: fb(t.displayMedium),
        displaySmall: fb(t.displaySmall),
        headlineLarge: fb(t.headlineLarge),
        headlineMedium: fb(t.headlineMedium),
        headlineSmall: fb(t.headlineSmall),
        titleLarge: fb(t.titleLarge),
        titleMedium: fb(t.titleMedium),
        titleSmall: fb(t.titleSmall),
        bodyLarge: fb(t.bodyLarge),
        bodyMedium: fb(t.bodyMedium),
        bodySmall: fb(t.bodySmall),
        labelLarge: fb(t.labelLarge),
        labelMedium: fb(t.labelMedium),
        labelSmall: fb(t.labelSmall),
      );
    }

    final textTheme = applyFallback(themeFn(base.textTheme).copyWith(
      displayLarge:  fontFn(textStyle: TextStyle(color: txtPri, fontWeight: FontWeight.bold, fontSize: 32)),
      displayMedium: fontFn(textStyle: TextStyle(color: txtPri, fontWeight: FontWeight.bold, fontSize: 26)),
      titleLarge:    fontFn(textStyle: TextStyle(color: txtPri, fontWeight: FontWeight.w600, fontSize: 20)),
      titleMedium:   fontFn(textStyle: TextStyle(color: txtPri, fontWeight: FontWeight.w500, fontSize: 17)),
      titleSmall:    fontFn(textStyle: TextStyle(color: txtSec, fontWeight: FontWeight.w500, fontSize: 14)),
      bodyLarge:     fontFn(textStyle: TextStyle(color: txtPri, fontSize: 16, height: 1.4)),
      bodyMedium:    fontFn(textStyle: TextStyle(color: txtSec, fontSize: 14, height: 1.4)),
      bodySmall:     fontFn(textStyle: TextStyle(color: txtSec, fontSize: 12)),
      labelLarge:    fontFn(textStyle: TextStyle(color: txtPri, fontWeight: FontWeight.w600, fontSize: 16)),
    ));

    return ThemeData(
      useMaterial3: true,
      platform: _customPlatform,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: pri,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: pri,
        onPrimary: Colors.white,
        primaryContainer: pri.withValues(alpha: 0.15),
        onPrimaryContainer: pri,
        secondary: acc,
        onSecondary: Colors.white,
        secondaryContainer: acc.withValues(alpha: 0.15),
        onSecondaryContainer: acc,
        surface: surf,
        onSurface: txtPri,
        surfaceContainerHighest: surfVar,
        onSurfaceVariant: txtSec,
        error: err,
        onError: Colors.white,
        outline: txtSec.withValues(alpha: 0.3),
        outlineVariant: surfVar,
        shadow: Colors.black,
        inverseSurface: txtPri,
        onInverseSurface: bg,
        surfaceTint: Colors.transparent,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: txtSec),
        titleTextStyle: fontFn(textStyle: TextStyle(color: txtPri, fontSize: 19, fontWeight: FontWeight.w600)),
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
        hintStyle:  fontFn(textStyle: TextStyle(color: txtSec, fontSize: 15)),
        labelStyle: fontFn(textStyle: TextStyle(color: txtSec, fontSize: 15)),
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: pri,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      dividerColor: surfVar,
      cardColor: surf,
      cardTheme: CardThemeData(
        color: surf,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: surfVar,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surf,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surf,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        indicatorColor: pri.withValues(alpha: 0.15),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfVar,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: fontFn(textStyle: TextStyle(color: txtPri, fontSize: 12)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(txtSec.withValues(alpha: 0.3)),
        thickness: WidgetStateProperty.all(6.0),
        radius: const Radius.circular(3.0),
        thumbVisibility: WidgetStateProperty.all(Platform.isLinux || Platform.isWindows || Platform.isMacOS),
      ),
    );
  }

  // ── Preset helper ─────────────────────────────────────────────────────────
  void applyPreset({
    required Color primary,
    Color? accent,
    Color? bg,
    Color? surf,
    Color? surfVar,
    Color? textPrimary,
    Color? textSecondary,
    Color? outgoingBubble,
    Color? incomingBubble,
    ThemeMode? mode,
    double? radius,
    String? font,
  }) {
    _customPrimary = primary;
    if (accent      != null) _customAccent      = accent;
    if (bg          != null) _customBg          = bg;
    if (surf        != null) _customSurf        = surf;
    if (surfVar     != null) _customSurfVar     = surfVar;
    if (textPrimary != null) _customTextPrimary = textPrimary;
    if (textSecondary != null) _customTextSecondary = textSecondary;
    _customOutgoingBubble = outgoingBubble;
    _customIncomingBubble = incomingBubble;
    if (mode        != null) _mode              = mode;
    if (radius      != null) _borderRadius      = radius;
    if (font        != null) _fontFamily        = font;
    _save();
    notifyListeners();
  }
}
