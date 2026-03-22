// Widget tests for NetworkDiagnosticsScreen (lib/screens/network_diagnostics_screen.dart).
//
// NetworkDiagnosticsScreen depends on:
// - ConnectivityProbeService.instance (singleton, stream subscription in initState)
// - TorService.instance (singleton, stream subscription in initState)
// - AdaptiveRelayService.instance (used in _runDiagnostics)
// - CloudflareIpService.instance (used in _runDiagnostics)
//
// Because these singletons are initialized in initState and cannot be mocked
// without dependency injection, all tests are skipped. The tests document
// what should be verified once mocks are available.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/network_diagnostics_screen.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

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
  });

  group('NetworkDiagnosticsScreen', () {
    // Skipped: ConnectivityProbeService.instance.status.listen() and
    // TorService.instance.stateChanges.listen() are called in initState.
    // These singletons require platform services (WebSocket, Tor binary)
    // that are not available in widget tests.
    testWidgets('has a Scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    }, skip: true);

    testWidgets('has an AppBar with "Network Diagnostics" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Network Diagnostics'), findsOneWidget);
    }, skip: true);

    testWidgets('renders "Run Diagnostics" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Run Diagnostics'), findsOneWidget);
    }, skip: true);

    testWidgets('renders "Force Re-probe" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Force Re-probe'), findsOneWidget);
    }, skip: true);

    testWidgets('renders summary cards for Nostr Relays, Tor, Infrastructure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nostr Relays'), findsOneWidget);
      expect(find.text('Tor'), findsOneWidget);
      expect(find.text('Infrastructure'), findsOneWidget);
    }, skip: true);
  });
}
