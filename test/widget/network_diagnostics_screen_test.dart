// Widget tests for NetworkDiagnosticsScreen (lib/screens/network_diagnostics_screen.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/screens/network_diagnostics_screen.dart';
import '../helpers/test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    setUpServiceMocks();
    createTestChatController();
  });

  group('NetworkDiagnosticsScreen', () {
    testWidgets('has a Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "Network Diagnostics" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Network Diagnostics'), findsOneWidget);
    });

    testWidgets('renders "Run Diagnostics" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Run Diagnostics'), findsOneWidget);
    });

    testWidgets('renders "Force Re-probe" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Re-probe'), findsOneWidget);
    });

    testWidgets('renders summary cards for Nostr Relays, Tor, Infrastructure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(const NetworkDiagnosticsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nostr Relays'), findsOneWidget);
      expect(find.text('Tor'), findsOneWidget);
      expect(find.text('Infrastructure'), findsOneWidget);
    });
  });
}
