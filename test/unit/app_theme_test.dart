import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/theme/app_theme.dart';

void main() {
  setUp(() {
    // Provide empty mock SharedPreferences so ThemeNotifier._loadFromPrefs()
    // succeeds without hitting the real plugin.
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeNotifier defaults', () {
    test('instance is a singleton', () {
      final a = ThemeNotifier.instance;
      final b = ThemeNotifier.instance;
      expect(identical(a, b), isTrue);
    });

    test('default theme mode is dark', () {
      expect(ThemeNotifier.instance.themeMode, equals(ThemeMode.dark));
      expect(ThemeNotifier.instance.isDark, isTrue);
    });

    test('default border radius is 12.0', () {
      expect(ThemeNotifier.instance.borderRadius, equals(12.0));
    });

    test('default font family is Inter', () {
      expect(ThemeNotifier.instance.fontFamily, equals('Inter'));
    });

    test('default custom platform is null (device platform)', () {
      expect(ThemeNotifier.instance.customPlatform, isNull);
    });
  });

  group('WhatsApp dark palette colors', () {
    // The app uses a WhatsApp-inspired dark palette per MEMORY.md.

    test('dark primary is WhatsApp green (#00A884)', () {
      // Reset to defaults to ensure no custom overrides
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.primary, equals(const Color(0xFF00A884)));
    });

    test('dark background is #111B21', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.background, equals(const Color(0xFF111B21)));
    });

    test('dark surface is #202C33', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.surface, equals(const Color(0xFF202C33)));
    });

    test('dark surfaceVariant is #2A3942', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.surfaceVariant, equals(const Color(0xFF2A3942)));
    });

    test('dark accent is #53BDEB', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.accent, equals(const Color(0xFF53BDEB)));
    });

    test('dark error is #FF2D55', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.error, equals(const Color(0xFFFF2D55)));
    });

    test('dark textPrimary is #E9EDEF', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.textPrimary, equals(const Color(0xFFE9EDEF)));
    });

    test('dark textSecondary is #8696A0', () {
      ThemeNotifier.instance.resetCustom();
      expect(ThemeNotifier.instance.textSecondary, equals(const Color(0xFF8696A0)));
    });

    test('primaryLight is a lighter variant of primary', () {
      ThemeNotifier.instance.resetCustom();
      final pri = ThemeNotifier.instance.primary;
      final priLight = ThemeNotifier.instance.primaryLight;
      // primaryLight = Color.lerp(primary, white, 0.3) — strictly lighter
      expect(priLight, isNot(equals(pri)));
      // The lightened color should have higher brightness
      final priHsl = HSLColor.fromColor(pri);
      final priLightHsl = HSLColor.fromColor(priLight);
      expect(priLightHsl.lightness, greaterThan(priHsl.lightness));
    });
  });

  group('AppTheme static delegation', () {
    test('AppTheme.background delegates to ThemeNotifier.instance', () {
      ThemeNotifier.instance.resetCustom();
      expect(AppTheme.background, equals(ThemeNotifier.instance.background));
    });

    test('AppTheme.primary delegates to ThemeNotifier.instance', () {
      ThemeNotifier.instance.resetCustom();
      expect(AppTheme.primary, equals(ThemeNotifier.instance.primary));
    });

    test('AppTheme.darkTheme returns a ThemeData', () {
      final td = AppTheme.darkTheme;
      expect(td, isA<ThemeData>());
    }, skip: true); // GoogleFonts requires asset bundle not available in unit tests

    test('all AppTheme color getters are non-null', () {
      ThemeNotifier.instance.resetCustom();
      expect(AppTheme.background, isNotNull);
      expect(AppTheme.surface, isNotNull);
      expect(AppTheme.surfaceVariant, isNotNull);
      expect(AppTheme.primary, isNotNull);
      expect(AppTheme.primaryLight, isNotNull);
      expect(AppTheme.accent, isNotNull);
      expect(AppTheme.error, isNotNull);
      expect(AppTheme.textPrimary, isNotNull);
      expect(AppTheme.textSecondary, isNotNull);
    });
  });

  group('Theme mode switching', () {
    test('setThemeMode changes the mode', () {
      ThemeNotifier.instance.setThemeMode(ThemeMode.light);
      expect(ThemeNotifier.instance.themeMode, equals(ThemeMode.light));
      expect(ThemeNotifier.instance.isDark, isFalse);

      // Restore to dark for other tests
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
      expect(ThemeNotifier.instance.isDark, isTrue);
    });

    test('light mode uses different palette values', () {
      ThemeNotifier.instance.resetCustom();
      ThemeNotifier.instance.setThemeMode(ThemeMode.light);

      // Light background should be #F0F2F5, not #111B21
      expect(ThemeNotifier.instance.background, equals(const Color(0xFFF0F2F5)));
      expect(ThemeNotifier.instance.surface, equals(const Color(0xFFFFFFFF)));
      expect(ThemeNotifier.instance.surfaceVariant, equals(const Color(0xFFE9ECEF)));
      expect(ThemeNotifier.instance.accent, equals(const Color(0xFF027EB5)));
      expect(ThemeNotifier.instance.error, equals(const Color(0xFFD93025)));
      expect(ThemeNotifier.instance.textPrimary, equals(const Color(0xFF111B21)));
      expect(ThemeNotifier.instance.textSecondary, equals(const Color(0xFF667781)));

      // Primary stays the same across modes
      expect(ThemeNotifier.instance.primary, equals(const Color(0xFF00A884)));

      // Restore
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
    });

    test('setThemeMode notifies listeners', () {
      int callCount = 0;
      void listener() => callCount++;
      ThemeNotifier.instance.addListener(listener);

      ThemeNotifier.instance.setThemeMode(ThemeMode.system);
      expect(callCount, equals(1));

      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
      expect(callCount, equals(2));

      ThemeNotifier.instance.removeListener(listener);
    });
  });

  group('Custom color overrides', () {
    test('updateColors overrides primary and accent', () {
      const customPrimary = Color(0xFFFF0000);
      const customAccent = Color(0xFF0000FF);

      ThemeNotifier.instance.updateColors(
          primary: customPrimary, accent: customAccent);

      expect(ThemeNotifier.instance.primary, equals(customPrimary));
      expect(ThemeNotifier.instance.accent, equals(customAccent));

      // Clean up
      ThemeNotifier.instance.resetCustom();
    });

    test('resetCustom restores default palette', () {
      ThemeNotifier.instance
          .updateColors(primary: const Color(0xFFFF0000));
      ThemeNotifier.instance.resetCustom();

      // After reset, should be back to WhatsApp green
      expect(ThemeNotifier.instance.primary, equals(const Color(0xFF00A884)));
      expect(ThemeNotifier.instance.borderRadius, equals(12.0));
      expect(ThemeNotifier.instance.fontFamily, equals('Inter'));
    });
  });

  // ThemeData generation tests require GoogleFonts asset loading which is
  // not available in pure unit tests (needs ServicesBinding + asset bundle).
  group('ThemeData generation', () {
    test('dark ThemeData has correct brightness', () {
      ThemeNotifier.instance.resetCustom();
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
      final td = ThemeNotifier.instance.themeData;
      expect(td.brightness, equals(Brightness.dark));
    }, skip: true);

    test('light ThemeData has correct brightness', () {
      ThemeNotifier.instance.setThemeMode(ThemeMode.light);
      final td = ThemeNotifier.instance.themeData;
      expect(td.brightness, equals(Brightness.light));
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
    }, skip: true);

    test('ThemeData scaffoldBackgroundColor matches background', () {
      ThemeNotifier.instance.resetCustom();
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
      final td = ThemeNotifier.instance.themeData;
      expect(td.scaffoldBackgroundColor,
          equals(ThemeNotifier.instance.background));
    }, skip: true);

    test('ThemeData colorScheme primary matches palette primary', () {
      ThemeNotifier.instance.resetCustom();
      final td = ThemeNotifier.instance.themeData;
      expect(td.colorScheme.primary,
          equals(ThemeNotifier.instance.primary));
    }, skip: true);
  });
}
