// Widget tests for I2pConfigSection (lib/widgets/i2p_config_section.dart).
//
// I2pConfigSection is a pure StatelessWidget with no service dependencies.
// All state is passed via constructor params: i2pEnabled, controllers, callback.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/widgets/i2p_config_section.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('I2pConfigSection', () {
    // ── Test 1: Renders section label and info text ──────────────────────────
    testWidgets('renders I2P Proxy section label and info text',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        I2pConfigSection(
          i2pEnabled: false,
          i2pHostController: hostCtrl,
          i2pPortController: portCtrl,
          onI2pEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Section label
      expect(find.text('I2P PROXY (SOCKS5)'), findsOneWidget);
      // Info text about I2P
      expect(find.textContaining('I2P uses SOCKS5'), findsOneWidget);
    });

    // ── Test 2: Renders toggle in disabled state ────────────────────────────
    testWidgets('renders switch in off state when i2pEnabled is false',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        I2pConfigSection(
          i2pEnabled: false,
          i2pHostController: hostCtrl,
          i2pPortController: portCtrl,
          onI2pEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
      // Status text shows 'Disabled'
      expect(find.text('Disabled'), findsOneWidget);
    });

    // ── Test 3: Shows host/port fields when enabled ─────────────────────────
    testWidgets('shows Proxy Host and Port fields when enabled',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController(text: '127.0.0.1');
      final portCtrl = TextEditingController(text: '4447');

      await tester.pumpWidget(buildTestableWidget(
        I2pConfigSection(
          i2pEnabled: true,
          i2pHostController: hostCtrl,
          i2pPortController: portCtrl,
          onI2pEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Both text fields are visible (text appears in controller + rendered)
      expect(find.text('127.0.0.1'), findsAtLeastNWidgets(1));
      expect(find.text('4447'), findsAtLeastNWidgets(1));
      // Helper text
      expect(find.textContaining('default SOCKS5 port: 4447'), findsOneWidget);
    });

    // ── Test 4: Toggle fires onI2pEnabledChanged ────────────────────────────
    testWidgets('onI2pEnabledChanged fires when switch is tapped',
        (WidgetTester tester) async {
      bool? changedTo;
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        I2pConfigSection(
          i2pEnabled: false,
          i2pHostController: hostCtrl,
          i2pPortController: portCtrl,
          onI2pEnabledChanged: (v) => changedTo = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      expect(changedTo, isTrue);
    });

    // ── Test 5: Hides host/port fields when disabled ────────────────────────
    testWidgets('hides host/port fields when disabled',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        I2pConfigSection(
          i2pEnabled: false,
          i2pHostController: hostCtrl,
          i2pPortController: portCtrl,
          onI2pEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // When disabled, the Proxy Host / Port text fields should not be rendered.
      // There should be no TextField at all (only the toggle row).
      expect(find.byType(TextField), findsNothing);
    });

    // ── Test 6: Shows active status text when enabled ───────────────────────
    testWidgets('shows active status text when enabled',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        I2pConfigSection(
          i2pEnabled: true,
          i2pHostController: hostCtrl,
          i2pPortController: portCtrl,
          onI2pEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Active'), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });
  });
}
