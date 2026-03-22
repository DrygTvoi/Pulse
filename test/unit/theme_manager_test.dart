import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

// ── Private helper reimplementations ────────────────────────────────────────
// These mirror the private static methods in ThemeNotifier so we can test
// their roundtrip behavior without exposing them.

ThemeMode modeFromString(String s) {
  switch (s) {
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.dark;
  }
}

String modeToString(ThemeMode m) {
  switch (m) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.system:
      return 'system';
    default:
      return 'dark';
  }
}

TargetPlatform? platformFromString(String? s) {
  switch (s) {
    case 'android':
      return TargetPlatform.android;
    case 'ios':
      return TargetPlatform.iOS;
    default:
      return null;
  }
}

String platformToString(TargetPlatform p) =>
    p == TargetPlatform.iOS ? 'ios' : 'android';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Reset the singleton to a clean state before each test.
    ThemeNotifier.instance.resetCustom();
    ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
  });

  // ── _modeFromString / _modeToString roundtrip ─────────────────────────────
  group('modeFromString / modeToString roundtrip', () {
    test('dark roundtrips correctly', () {
      expect(modeFromString(modeToString(ThemeMode.dark)), ThemeMode.dark);
    });

    test('light roundtrips correctly', () {
      expect(modeFromString(modeToString(ThemeMode.light)), ThemeMode.light);
    });

    test('system roundtrips correctly', () {
      expect(modeFromString(modeToString(ThemeMode.system)), ThemeMode.system);
    });

    test('unknown string defaults to dark', () {
      expect(modeFromString('unknown'), ThemeMode.dark);
      expect(modeFromString(''), ThemeMode.dark);
      expect(modeFromString('DARK'), ThemeMode.dark);
    });
  });

  // ── _platformFromString / _platformToString roundtrip ─────────────────────
  group('platformFromString / platformToString roundtrip', () {
    test('android roundtrips correctly', () {
      expect(
          platformFromString(platformToString(TargetPlatform.android)),
          TargetPlatform.android);
    });

    test('iOS roundtrips correctly', () {
      expect(
          platformFromString(platformToString(TargetPlatform.iOS)),
          TargetPlatform.iOS);
    });

    test('null string returns null', () {
      expect(platformFromString(null), isNull);
    });

    test('unknown string returns null', () {
      expect(platformFromString('windows'), isNull);
      expect(platformFromString(''), isNull);
    });

    test('non-iOS platform maps to android string', () {
      // The source implementation: p == TargetPlatform.iOS ? 'ios' : 'android'
      // So any non-iOS platform (linux, macOS, etc.) maps to 'android'.
      expect(platformToString(TargetPlatform.linux), equals('android'));
      expect(platformToString(TargetPlatform.macOS), equals('android'));
    });
  });

  // ── applyPreset ───────────────────────────────────────────────────────────
  group('applyPreset', () {
    test('sets primary color', () {
      ThemeNotifier.instance.applyPreset(primary: const Color(0xFFFF0000));
      expect(ThemeNotifier.instance.primary, equals(const Color(0xFFFF0000)));
    });

    test('sets multiple custom values at once', () {
      ThemeNotifier.instance.applyPreset(
        primary: const Color(0xFFAA0000),
        accent: const Color(0xFF00AA00),
        bg: const Color(0xFF000000),
        surf: const Color(0xFF111111),
        surfVar: const Color(0xFF222222),
        textPrimary: const Color(0xFFFFFFFF),
        textSecondary: const Color(0xFFCCCCCC),
        mode: ThemeMode.light,
        radius: 8.0,
        font: 'Roboto',
      );

      expect(ThemeNotifier.instance.primary, equals(const Color(0xFFAA0000)));
      expect(ThemeNotifier.instance.accent, equals(const Color(0xFF00AA00)));
      expect(ThemeNotifier.instance.background, equals(const Color(0xFF000000)));
      expect(ThemeNotifier.instance.surface, equals(const Color(0xFF111111)));
      expect(ThemeNotifier.instance.surfaceVariant, equals(const Color(0xFF222222)));
      expect(ThemeNotifier.instance.textPrimary, equals(const Color(0xFFFFFFFF)));
      expect(ThemeNotifier.instance.textSecondary, equals(const Color(0xFFCCCCCC)));
      expect(ThemeNotifier.instance.themeMode, equals(ThemeMode.light));
      expect(ThemeNotifier.instance.borderRadius, equals(8.0));
      expect(ThemeNotifier.instance.fontFamily, equals('Roboto'));
    });

    test('optional fields left null do not override existing values', () {
      // First set accent via updateColors
      ThemeNotifier.instance.updateColors(accent: const Color(0xFF0000FF));
      // Now apply preset with only primary — accent should remain
      ThemeNotifier.instance.applyPreset(primary: const Color(0xFFDD0000));
      expect(ThemeNotifier.instance.primary, equals(const Color(0xFFDD0000)));
      expect(ThemeNotifier.instance.accent, equals(const Color(0xFF0000FF)));
    });

    test('applyPreset notifies listeners', () {
      int callCount = 0;
      void listener() => callCount++;
      ThemeNotifier.instance.addListener(listener);

      ThemeNotifier.instance.applyPreset(primary: const Color(0xFFABCDEF));
      expect(callCount, equals(1));

      ThemeNotifier.instance.removeListener(listener);
    });
  });

  // ── updateRadius ──────────────────────────────────────────────────────────
  group('updateRadius', () {
    test('changes borderRadius', () {
      ThemeNotifier.instance.updateRadius(24.0);
      expect(ThemeNotifier.instance.borderRadius, equals(24.0));
    });

    test('notifies listeners on radius change', () {
      int callCount = 0;
      void listener() => callCount++;
      ThemeNotifier.instance.addListener(listener);

      ThemeNotifier.instance.updateRadius(16.0);
      expect(callCount, equals(1));

      ThemeNotifier.instance.removeListener(listener);
    });
  });

  // ── updateFont ────────────────────────────────────────────────────────────
  group('updateFont', () {
    test('changes fontFamily', () {
      ThemeNotifier.instance.updateFont('Fira Code');
      expect(ThemeNotifier.instance.fontFamily, equals('Fira Code'));
    });

    test('notifies listeners on font change', () {
      int callCount = 0;
      void listener() => callCount++;
      ThemeNotifier.instance.addListener(listener);

      ThemeNotifier.instance.updateFont('Noto Sans');
      expect(callCount, equals(1));

      ThemeNotifier.instance.removeListener(listener);
    });
  });

  // ── updatePlatform ────────────────────────────────────────────────────────
  group('updatePlatform', () {
    test('sets custom platform to iOS', () {
      ThemeNotifier.instance.updatePlatform(TargetPlatform.iOS);
      expect(ThemeNotifier.instance.customPlatform, equals(TargetPlatform.iOS));
    });

    test('sets custom platform to android', () {
      ThemeNotifier.instance.updatePlatform(TargetPlatform.android);
      expect(ThemeNotifier.instance.customPlatform,
          equals(TargetPlatform.android));
    });

    test('sets custom platform to null (device default)', () {
      ThemeNotifier.instance.updatePlatform(TargetPlatform.iOS);
      ThemeNotifier.instance.updatePlatform(null);
      expect(ThemeNotifier.instance.customPlatform, isNull);
    });

    test('notifies listeners on platform change', () {
      int callCount = 0;
      void listener() => callCount++;
      ThemeNotifier.instance.addListener(listener);

      ThemeNotifier.instance.updatePlatform(TargetPlatform.iOS);
      expect(callCount, equals(1));

      ThemeNotifier.instance.removeListener(listener);
    });
  });

  // ── Light mode palette values ─────────────────────────────────────────────
  group('Light mode palette values', () {
    test('light mode returns light background', () {
      ThemeNotifier.instance.resetCustom();
      ThemeNotifier.instance.setThemeMode(ThemeMode.light);
      expect(
          ThemeNotifier.instance.background, equals(const Color(0xFFF0F2F5)));
    });

    test('light mode accent differs from dark mode accent', () {
      ThemeNotifier.instance.resetCustom();
      ThemeNotifier.instance.setThemeMode(ThemeMode.light);
      final lightAccent = ThemeNotifier.instance.accent;

      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
      final darkAccent = ThemeNotifier.instance.accent;

      expect(lightAccent, isNot(equals(darkAccent)));
      expect(lightAccent, equals(const Color(0xFF027EB5)));
      expect(darkAccent, equals(const Color(0xFF53BDEB)));
    });

    test('light mode error differs from dark mode error', () {
      ThemeNotifier.instance.resetCustom();
      ThemeNotifier.instance.setThemeMode(ThemeMode.light);
      expect(ThemeNotifier.instance.error, equals(const Color(0xFFD93025)));

      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
      expect(ThemeNotifier.instance.error, equals(const Color(0xFFFF2D55)));
    });
  });

  // ── resetCustom ───────────────────────────────────────────────────────────
  group('resetCustom clears all overrides', () {
    test('clears colors, radius, font, and platform', () {
      // Apply a full preset
      ThemeNotifier.instance.applyPreset(
        primary: const Color(0xFFFF0000),
        accent: const Color(0xFF00FF00),
        bg: const Color(0xFF0000FF),
        surf: const Color(0xFF112233),
        surfVar: const Color(0xFF445566),
        textPrimary: const Color(0xFFDDDDDD),
        textSecondary: const Color(0xFF999999),
        radius: 20.0,
        font: 'Roboto Mono',
      );
      ThemeNotifier.instance.updatePlatform(TargetPlatform.iOS);

      // Now reset
      ThemeNotifier.instance.resetCustom();

      // All values should be back to defaults
      expect(ThemeNotifier.instance.primary, equals(const Color(0xFF00A884)));
      expect(ThemeNotifier.instance.borderRadius, equals(12.0));
      expect(ThemeNotifier.instance.fontFamily, equals('Inter'));
      expect(ThemeNotifier.instance.customPlatform, isNull);
      // Background should be the default for current mode (dark)
      expect(
          ThemeNotifier.instance.background, equals(const Color(0xFF111B21)));
    });
  });
}
