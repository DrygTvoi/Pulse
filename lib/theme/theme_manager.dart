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
  /// Default seed — soft deep "Ocean" blue. One value drives the entire
  /// ColorScheme via Material 3 tonal palette generation: surface tints,
  /// container colours, and accents all derive from this hue. To "rebrand"
  /// the app: change this.
  static const Color _defaultSeed = Color(0xFF5288C1);
  Color _seed = _defaultSeed;

  /// FluffyChat uses 16. Input/popup/outlined-button radii are derived as
  /// `borderRadius / 2`. Dialog/sheet stay larger via separate constants.
  static const double _defaultRadius = 16.0;
  double _borderRadius = _defaultRadius;

  // ── Tunable surface/accent knobs ────────────────────────────────────────
  // Three fine-tune sliders that let the user shape the dark theme without
  // picking a different seed. Defaults match the proven "Ocean" feel.
  /// Saturation of dark surfaces, 0.0 (pure grey) → 0.45 (heavily tinted).
  static const double _defaultSurfaceTint = 0.28;
  double _surfaceTint = _defaultSurfaceTint;
  /// Lightness offset for the entire dark surface ramp, -0.05 (deeper)
  /// to +0.05 (lighter). Default 0 = the original Telegram-Ocean ramp.
  static const double _defaultSurfaceDepth = 0.0;
  double _surfaceDepth = _defaultSurfaceDepth;
  /// Lightness of `primaryContainer` (own chat bubble in dark). 0.15
  /// (deep) → 0.40 (loud). Default 0.22 keeps bubbles calm.
  static const double _defaultAccentDepth = 0.22;
  double _accentDepth = _defaultAccentDepth;

  String _fontFamily = 'Inter';
  TargetPlatform? _customPlatform;

  double get borderRadius => _borderRadius;
  double get surfaceTint => _surfaceTint;
  double get surfaceDepth => _surfaceDepth;
  double get accentDepth => _accentDepth;
  String get fontFamily => _fontFamily;
  TargetPlatform? get customPlatform => _customPlatform;
  bool get isDark => _mode == ThemeMode.dark;

  // ── Seed-tinted dark surface ramp — derived from seed hue ─────────────
  // Saturation comes from `_surfaceTint` (slider), lightness from a
  // base ramp + `_surfaceDepth` offset (slider). Makes the "Telegram
  // tinted dark" recipe fully tunable without hex-editing constants.
  Color _darkBgFor(double hue) => HSLColor.fromAHSL(
        1.0, hue, _surfaceTint, (0.13 + _surfaceDepth).clamp(0.04, 0.30),
      ).toColor();
  Color _darkSurfLowFor(double hue) => HSLColor.fromAHSL(
        1.0, hue, _surfaceTint, (0.16 + _surfaceDepth).clamp(0.05, 0.32),
      ).toColor();
  Color _darkSurfFor(double hue) => HSLColor.fromAHSL(
        1.0, hue, _surfaceTint, (0.19 + _surfaceDepth).clamp(0.06, 0.35),
      ).toColor();
  Color _darkSurfHighFor(double hue) => HSLColor.fromAHSL(
        1.0, hue, _surfaceTint, (0.24 + _surfaceDepth).clamp(0.08, 0.40),
      ).toColor();
  Color _darkSurfHighestFor(double hue) => HSLColor.fromAHSL(
        1.0, hue, _surfaceTint, (0.30 + _surfaceDepth).clamp(0.10, 0.46),
      ).toColor();
  static const _darkOnSurface            = Color(0xFFEEF0F1);
  static const _darkOnSurfaceVariant     = Color(0xFF8FA0AE);
  Color _darkOutlineFor(double hue) =>
      HSLColor.fromAHSL(1.0, hue, _surfaceTint * 0.7, 0.32).toColor();
  Color _darkOutlineVariantFor(double hue) =>
      HSLColor.fromAHSL(1.0, hue, _surfaceTint * 0.9, 0.20).toColor();

  // Light ramp — clean warm-neutral whites for symmetry with dark.
  static const _lightSurface              = Color(0xFFFCFCFD);
  static const _lightSurfaceContainerLow  = Color(0xFFF5F6F8);
  static const _lightSurfaceContainer     = Color(0xFFEEEFF2);
  static const _lightSurfaceContainerHigh = Color(0xFFE6E8EC);
  static const _lightSurfaceContainerHighest = Color(0xFFDDE0E5);
  static const _lightOnSurface            = Color(0xFF181A1F);
  static const _lightOnSurfaceVariant     = Color(0xFF5C6168);
  static const _lightOutline              = Color(0xFFC8CCD2);
  static const _lightOutlineVariant       = Color(0xFFE0E2E6);

  /// Cached ColorScheme — recomputed only when seed/mode changes. Built by
  /// taking M3's seed-derived palette but ONLY keeping its accent tokens
  /// (primary, secondary, tertiary, error and their containers); surfaces
  /// come from the hand-tuned ramps above.
  ColorScheme? _cachedScheme;
  ColorScheme get _scheme => _cachedScheme ??= _buildScheme(
        isDark ? Brightness.dark : Brightness.light,
      );

  ColorScheme _buildScheme(Brightness brightness) {
    final isD = brightness == Brightness.dark;
    final fromSeed = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      // Vibrant keeps accent tokens punchy — important since we're throwing
      // away M3's surface palette and only using the accent triple. Without
      // vibrant, primary/secondary read as muted on our pure-grey base.
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    // Cap accent brightness — M3 dark mode generates `primary` as a very
    // light tonal step of the seed (Ocean #5288C1 → ~#B4C7FF pastel sky),
    // which makes buttons / FAB / focus rings glare. We override primary
    // to the user-picked seed itself: a deeper colour that reads as a
    // calm accent. `primaryContainer` (used for own bubbles in dark
    // mode) gets darkened to ~22% lightness via HSL so chat doesn't get
    // a glowing blue stripe down the right side.
    //
    // Same treatment for secondary tokens: vibrant variant shifts the
    // secondary hue ~60° from the seed (blue → magenta zone), which made
    // the active-chat-tile background read as purple even on an Ocean-blue
    // theme. Pin secondary tokens to the SEED hue too, just at lower
    // saturation, so taps stay in the seed's colour family.
    final primaryDimmed = isD ? _seed : fromSeed.primary;
    final onPrimaryDimmed = isD
        ? (_lightnessOf(_seed) < 0.55 ? Colors.white : Colors.black)
        : fromSeed.onPrimary;
    final primaryContainerDimmed = isD
        ? _withLightness(_seed, _accentDepth)
        : fromSeed.primaryContainer;
    final onPrimaryContainerDimmed = isD
        ? _withLightness(_seed, 0.88)
        : fromSeed.onPrimaryContainer;
    final secondaryDimmed = isD
        ? _withSatLight(_seed, 0.30, 0.65)
        : fromSeed.secondary;
    final secondaryContainerDimmed = isD
        ? _withSatLight(_seed, 0.30, 0.20)
        : fromSeed.secondaryContainer;
    final onSecondaryContainerDimmed = isD
        ? _withLightness(_seed, 0.85)
        : fromSeed.onSecondaryContainer;
    final seedHue = HSLColor.fromColor(_seed).hue;
    return fromSeed.copyWith(
      primary:                  primaryDimmed,
      onPrimary:                onPrimaryDimmed,
      primaryContainer:         primaryContainerDimmed,
      onPrimaryContainer:       onPrimaryContainerDimmed,
      secondary:                secondaryDimmed,
      onSecondary:              isD ? Colors.white : fromSeed.onSecondary,
      secondaryContainer:       secondaryContainerDimmed,
      onSecondaryContainer:     onSecondaryContainerDimmed,
      surface:                  isD ? _darkBgFor(seedHue) : _lightSurface,
      surfaceContainerLowest:   isD
          ? HSLColor.fromAHSL(1.0, seedHue, _surfaceTint,
                  (0.10 + _surfaceDepth).clamp(0.02, 0.28))
              .toColor()
          : const Color(0xFFFFFFFF),
      surfaceContainerLow:      isD ? _darkSurfLowFor(seedHue) : _lightSurfaceContainerLow,
      surfaceContainer:         isD ? _darkSurfFor(seedHue) : _lightSurfaceContainer,
      surfaceContainerHigh:     isD ? _darkSurfHighFor(seedHue) : _lightSurfaceContainerHigh,
      surfaceContainerHighest:  isD ? _darkSurfHighestFor(seedHue) : _lightSurfaceContainerHighest,
      onSurface:                isD ? _darkOnSurface : _lightOnSurface,
      onSurfaceVariant:         isD ? _darkOnSurfaceVariant : _lightOnSurfaceVariant,
      outline:                  isD ? _darkOutlineFor(seedHue) : _lightOutline,
      outlineVariant:           isD ? _darkOutlineVariantFor(seedHue) : _lightOutlineVariant,
      surfaceTint:              Colors.transparent,
    );
  }

  static double _lightnessOf(Color c) => HSLColor.fromColor(c).lightness;
  static Color _withLightness(Color c, double l) =>
      HSLColor.fromColor(c).withLightness(l.clamp(0.0, 1.0)).toColor();
  static Color _withSatLight(Color c, double s, double l) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withSaturation(s.clamp(0.0, 1.0))
        .withLightness(l.clamp(0.0, 1.0))
        .toColor();
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
    _surfaceTint =
        prefs.getDouble('theme_surface_tint') ?? _defaultSurfaceTint;
    _surfaceDepth =
        prefs.getDouble('theme_surface_depth') ?? _defaultSurfaceDepth;
    _accentDepth =
        prefs.getDouble('theme_accent_depth') ?? _defaultAccentDepth;
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
    await prefs.setDouble('theme_surface_tint', _surfaceTint);
    await prefs.setDouble('theme_surface_depth', _surfaceDepth);
    await prefs.setDouble('theme_accent_depth', _accentDepth);
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

  /// Tunes how saturated dark surfaces are (0 = pure grey, 0.45 = strong tint).
  void setSurfaceTint(double v) {
    _surfaceTint = v.clamp(0.0, 0.45);
    _cachedScheme = null;
    _save();
    notifyListeners();
  }

  /// Shifts the entire dark surface ramp lighter/darker (-0.05 to +0.05).
  void setSurfaceDepth(double v) {
    _surfaceDepth = v.clamp(-0.05, 0.05);
    _cachedScheme = null;
    _save();
    notifyListeners();
  }

  /// Lightness of own-bubble / `primaryContainer` (0.10 deep → 0.40 loud).
  void setAccentDepth(double v) {
    _accentDepth = v.clamp(0.10, 0.40);
    _cachedScheme = null;
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
    _surfaceTint = _defaultSurfaceTint;
    _surfaceDepth = _defaultSurfaceDepth;
    _accentDepth = _defaultAccentDepth;
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
        : _buildScheme(brightness);

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
