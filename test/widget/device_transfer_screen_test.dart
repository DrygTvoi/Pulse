// Widget tests for DeviceTransferScreen (lib/screens/device_transfer_screen.dart).
//
// DeviceTransferScreen depends on:
// - DeviceTransferService (created on demand for LAN/Nostr transfer)
// - Platform channels may be needed for actual transfer operations
//
// The initial role-selection step renders without any service calls, so
// basic structure tests can run. Transfer flow tests are skipped because
// they invoke DeviceTransferService which requires network/platform access.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/device_transfer_screen.dart';
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

  group('DeviceTransferScreen', () {
    testWidgets('has a Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "Transfer to Another Device" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Transfer to Another Device'), findsOneWidget);
    });

    testWidgets('shows role selection with Send and Receive options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      // The initial step is role selection with two cards
      expect(find.text('Send from this device'), findsOneWidget);
      expect(find.text('Receive on this device'), findsOneWidget);
    });

    testWidgets('shows info box explaining transfer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      // Info box icon
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    // Skipped: tapping Send navigates to sender config which calls
    // DeviceTransferService methods requiring network access.
    testWidgets('tapping Send shows sender config with LAN and Nostr options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      // Tap "Send from this device"
      await tester.tap(find.text('Send from this device'));
      await tester.pumpAndSettle();

      expect(find.text('LAN'), findsOneWidget);
    }, skip: true);
  });
}
