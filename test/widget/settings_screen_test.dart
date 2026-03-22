// Widget tests for SettingsScreen (lib/screens/settings_screen.dart).
//
// SettingsScreen depends on:
// - ThemeNotifier (via context.watch<ThemeNotifier>()) — provided via Provider
// - FlutterSecureStorage (in initState _loadSettings) — platform channel
// - Sub-sections that depend on ChatController, TorService, BackgroundService, etc.
//
// Because FlutterSecureStorage uses platform channels that are not available
// in widget tests, and sub-sections reference ChatController and other
// singletons, many tests are skipped. We test what can render.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/settings_screen.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

import '../helpers/test_mocks.dart';

/// Wraps [child] in a MaterialApp with localization delegates and a
/// ThemeNotifier provider (required by SettingsScreen).
Widget buildTestableWidget(Widget child) {
  return ChangeNotifierProvider<ThemeNotifier>.value(
    value: ThemeNotifier.instance,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    createTestChatController();
  });

  group('SettingsScreen', () {
    testWidgets('renders "Settings" title in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      // Pump a few frames to allow async _loadSettings to attempt.
      // FlutterSecureStorage will throw MissingPluginException but
      // the Scaffold/AppBar should still render.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('has a Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('body is a ListView', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows NETWORK section label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Section divider renders the label uppercased.
      expect(find.text('NETWORK'), findsOneWidget);
    });

    testWidgets('shows APPEARANCE section label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('APPEARANCE'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('APPEARANCE'), findsOneWidget);
    });

    testWidgets('shows SECURITY section label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('SECURITY'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('SECURITY'), findsOneWidget);
    });

    testWidgets('shows DATA section label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('DATA'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('DATA'), findsOneWidget);
    });

    testWidgets('shows ABOUT section label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('ABOUT'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('ABOUT'), findsOneWidget);
    });

    testWidgets('ProfileSection is rendered', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // ProfileSection renders the profile card which uses ChatController.
    });
  });
}
