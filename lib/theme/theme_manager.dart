import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FluffyChat-style theme: pure Material 3 with one seed color, the rest is
/// derived tonally. Custom overrides are kept only for the seed (so users can
/// repaint the app with a single color) and for the global border radius.
///
/// The legacy palette getters (`background`, `surface`, `outgoingBubble`, …)
/// are mapped onto ColorScheme tokens so existing widgets keep working without
/// touching every call site.
class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier instance = ThemeNotifier._internal();

  // ── Mode ─────────────────────────────────────────────────────────────────
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get themeMode => _mode;

  // ── Seed-driven palette ──────────────────────────────────────────────────
  /// Default seed = Pulse brand teal. One value drives the entire ColorScheme
  /// via Material 3 tonal palette generation — surface tints, container
  /// colors, and accents are all derived. To "rebrand" the app: change this.
  static const Color _defaultSeed = Color(0xFF26A69A);
  Color _seed = _defaultSeed;

  /// FluffyChat uses 16. Input/popup/outlined-button radii are derived as
  /// `borderRadius / 2`. Dialog/sheet stay larger via separate constants.
  static const double _defaultRadius = 16.0;
  double _borderRadius = _defaultRadius;

  String _fontFamily = 'Inter';
  TargetPlatform? _customPlatform;

  double get borderRadius => _borderRadius;
  String get fontFamily => _fontFamily;
  TargetPlatform? get customPlatform => _customPlatform;
  bool get isDark => _mode == ThemeMode.dark;

  /// Cached ColorScheme — recomputed only when seed/mode changes.
  ColorScheme? _cachedScheme;
  ColorScheme get _scheme {
    return _cachedScheme ??= ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  // ── Legacy palette getters (mapped to ColorScheme tokens) ────────────────
  // These keep the old AppTheme.* API working without rewriting call sites.
  Color get primary        => _scheme.primary;
  Color get primaryLight   => _scheme.primaryContainer;
  Color get accent         => _scheme.secondary;
  Color get error          => _scheme.error;
  Color get background     => _scheme.surface;
  Color get surface        => _scheme.surfaceContainer;
  Color get surfaceVariant => _scheme.surfaceContainerHigh;
  Color get textPrimary    => _scheme.onSurface;
  Color get textSecondary  => _scheme.onSurfaceVariant;

  /// Bubble colors — mirror FluffyChat's BubbleColorTheme extension.
  Color get outgoingBubble => isDark ? _scheme.primaryContainer : _scheme.primary;
  Color get incomingBubble => _scheme.surfaceContainerHigh;

  ThemeNotifier._internal() {
    _loadFromPrefs();
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = _modeFromString(prefs.getString('theme_mode') ?? 'dark');
    if (prefs.containsKey('theme_seed')) {
      _seed = Color(prefs.getInt('theme_seed')!);
    } else if (prefs.containsKey('theme_primary')) {
      // Migrate legacy "theme_primary" key — same semantic as seed.
      _seed = Color(prefs.getInt('theme_primary')!);
    }
    _borderRadius =
        prefs.getDouble('theme_radius') ?? _defaultRadius;
    _fontFamily = prefs.getString('theme_font') ?? 'Inter';
    _customPlatform = _platformFromString(prefs.getString('theme_platform'));
    _cachedScheme = null;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _modeToString(_mode));
    await prefs.setInt('theme_seed', _seed.toARGB32());
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
    _cachedScheme = null;
    notifyListeners();
    _save();
  }

  /// Set the seed color — recomputes the entire palette tonally.
  void setSeed(Color seed) {
    _seed = seed;
    _cachedScheme = null;
    _save();
    notifyListeners();
  }

  /// Legacy alias — `primary` is conceptually our seed.
  void updateColors({Color? primary, Color? accent}) {
    if (primary != null) {
      _seed = primary;
      _cachedScheme = null;
    }
    _save();
    notifyListeners();
  }

  void updateRadius(double radius) {
    _borderRadius = radius;
    _save();
    notifyListeners();
  }

  // ── Legacy no-ops kept for the dynamic-theme picker UI ───────────────────
  // FluffyChat-style architecture has only one knob (the seed), so the
  // separate background/surface/bubble pickers no longer make sense — the
  // values are derived tonally. These stubs keep the existing settings
  // screen compilable; we'll redesign that screen to a single-seed picker
  // in a follow-up.
  void updateBackground(Color c) {}
  void updateSurface(Color c) {}
  void updateSurfaceVariant(Color c) {}
  void updateBubbleColors({Color? outgoing, Color? incoming}) {}

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
    _seed = _defaultSeed;
    _customPlatform = null;
    _borderRadius = _defaultRadius;
    _fontFamily = 'Inter';
    _mode = ThemeMode.dark;
    _cachedScheme = null;
    _save();
    notifyListeners();
  }

  TextStyle getTextStyle(TextStyle baseStyle) =>
      GoogleFonts.inter(textStyle: baseStyle);

  // ── ThemeData builders ────────────────────────────────────────────────────
  ThemeData get lightThemeData => _buildThemeData(brightness: Brightness.light);
  ThemeData get darkThemeData  => _buildThemeData(brightness: Brightness.dark);
  ThemeData get themeData      =>
      _buildThemeData(brightness: isDark ? Brightness.dark : Brightness.light);

  ThemeData _buildThemeData({required Brightness brightness}) {
    final colorScheme = brightness == (isDark ? Brightness.dark : Brightness.light)
        ? _scheme
        : ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);

    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    // Inter as global font; on Linux fall back to Noto Color Emoji so emojis
    // render in colour instead of as white tofu boxes.
    final emojiFallback = Platform.isLinux
        ? const ['Noto Color Emoji'] : const <String>[];

    TextStyle font(TextStyle? s) =>
        GoogleFonts.inter(textStyle: s).copyWith(fontFamilyFallback: emojiFallback);

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
      fontFamilyFallback: emojiFallback,
    );

    final radius = _borderRadius;

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      platform: _customPlatform,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      // FluffyChat: in column mode they use surfaceContainerHighest, but for
      // the single-column phone layout that we ship by default they keep the
      // softer surfaceContainer as a divider tint.
      dividerColor: brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainer,
      // Selection — same alpha as FluffyChat (128/255).
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.onSurface.withValues(alpha: 0.5),
        selectionHandleColor: colorScheme.secondary,
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: 56,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: font(TextStyle(
          color: colorScheme.onSurface,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        )),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: colorScheme.surface,
        ),
      ),
      // Inputs are noticeably "softer" — smaller radius (half of bubble
      // radius), filled with surfaceContainerHighest, no visible border at
      // rest, accent-tinted underline on focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius / 2),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius / 2),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius / 2),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: font(TextStyle(color: colorScheme.onSurfaceVariant)),
        labelStyle: font(TextStyle(color: colorScheme.onSurfaceVariant)),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: colorScheme.surfaceContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      // Elevated buttons: zero elevation, secondaryContainer background — a
      // subtle "pill" rather than a strong primary call-to-action. Strong CTAs
      // use FilledButton (which uses primary by default).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          textStyle: font(const TextStyle(fontSize: 16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(width: 1, color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.primary),
            borderRadius: BorderRadius.circular(radius / 2),
          ),
          textStyle: font(const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: font(const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        strokeCap: StrokeCap.round,
        color: colorScheme.primary,
        refreshBackgroundColor: colorScheme.primaryContainer,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerLow,
        iconColor: colorScheme.onSurface,
        textStyle: font(TextStyle(color: colorScheme.onSurface)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius / 2),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius * 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius * 1.5),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 2,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(radius / 2),
        ),
        textStyle: font(TextStyle(color: colorScheme.onSurface, fontSize: 12)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
            colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
        thickness: WidgetStateProperty.all(6.0),
        radius: const Radius.circular(3.0),
        thumbVisibility: WidgetStateProperty.all(
            Platform.isLinux || Platform.isWindows || Platform.isMacOS),
      ),
    );
  }

  // ── Preset helper (kept for backwards compat with settings UI) ───────────
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
    // In the FluffyChat-style architecture only the seed and the radius
    // matter — the other colors are derived. We honour the seed (= primary)
    // and the radius, and ignore the rest of the call so old settings UI
    // doesn't crash. Modes and font are still respected.
    _seed = primary;
    _cachedScheme = null;
    if (mode   != null) _mode         = mode;
    if (radius != null) _borderRadius = radius;
    if (font   != null) _fontFamily   = font;
    _save();
    notifyListeners();
  }
}

/// FluffyChat-style ThemeData extension — pairs a small set of "bubble"
/// colors to the primary/secondary/tertiary tonal triple so chat widgets
/// don't have to compute brightness branches themselves.
extension BubbleColorTheme on ThemeData {
  Color get bubbleColor => brightness == Brightness.light
      ? colorScheme.primary
      : colorScheme.primaryContainer;

  Color get onBubbleColor => brightness == Brightness.light
      ? colorScheme.onPrimary
      : colorScheme.onPrimaryContainer;

  Color get secondaryBubbleColor => HSLColor.fromColor(
        brightness == Brightness.light
            ? colorScheme.tertiary
            : colorScheme.tertiaryContainer,
      ).withSaturation(0.5).toColor();
}
