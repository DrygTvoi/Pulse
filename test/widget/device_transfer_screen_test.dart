// Widget tests for DeviceTransferScreen (lib/screens/device_transfer_screen.dart).
//
// DeviceTransferScreen depends on:
// - DeviceTransferService (created on demand for LAN/Nostr transfer)
// - Platform channels may be needed for actual transfer operations
//
// The initial role-selection step and sender config step render without any
// service calls, so structure + navigation tests can run. Transfer flow tests
// would require DeviceTransferService which needs network/platform access.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/screens/device_transfer_screen.dart';

import '../helpers/test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    setUpServiceMocks();
    createTestChatController();
  });

  group('DeviceTransferScreen', () {
    testWidgets('has a Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "Transfer to Another Device" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Transfer to Another Device'), findsOneWidget);
    });

    testWidgets('shows role selection with Send and Receive options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      // The initial step is role selection with two cards
      expect(find.text('Send from this device'), findsOneWidget);
      expect(find.text('Receive on this device'), findsOneWidget);
    });

    testWidgets('shows info box explaining transfer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      // Info box icon
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping Send shows sender config with LAN and Nostr options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const DeviceTransferScreen()));
      await tester.pumpAndSettle();

      // Tap "Send from this device"
      await tester.tap(find.text('Send from this device'));
      await tester.pumpAndSettle();

      // Sender config shows LAN and Nostr Relay method cards (no network
      // calls until the user taps a method card).
      expect(find.text('LAN (Same Network)'), findsOneWidget);
      expect(find.text('Nostr Relay'), findsWidgets);
    });
  });
}
