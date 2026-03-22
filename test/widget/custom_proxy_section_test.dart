// Widget tests for CustomProxySection (lib/widgets/custom_proxy_section.dart).
//
// Tests focus on: rendering SOCKS5 proxy fields, toggle enable/disable,
// text field input, CF Worker field, help section expand/collapse.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/custom_proxy_section.dart';

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
      home: Scaffold(
        body: SingleChildScrollView(child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        )),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TextEditingController hostController;
  late TextEditingController portController;
  late TextEditingController workerController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    hostController = TextEditingController();
    portController = TextEditingController();
    workerController = TextEditingController();
  });

  tearDown(() {
    hostController.dispose();
    portController.dispose();
    workerController.dispose();
  });

  group('CustomProxySection', () {
    // ── Test 1: Renders proxy section label ──────────────────────────────────

    testWidgets('renders CUSTOM PROXY (SOCKS5) section label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM PROXY (SOCKS5)'), findsOneWidget);
    });

    // ── Test 2: Renders CF Worker section label ─────────────────────────────

    testWidgets('renders CF WORKER RELAY section label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CF WORKER RELAY'), findsOneWidget);
    });

    // ── Test 3: Switch reflects proxyEnabled state ──────────────────────────

    testWidgets('shows switch in off state when proxyEnabled is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
    });

    // ── Test 4: Proxy fields hidden when disabled ───────────────────────────

    testWidgets('proxy host and port fields are hidden when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      // When disabled, the Proxy Host and Port fields should not be visible.
      expect(find.text('Proxy Host'), findsNothing);
      expect(find.text('Port'), findsNothing);
    });

    // ── Test 5: Proxy fields visible when enabled ───────────────────────────

    testWidgets('proxy host and port fields are visible when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: true,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Proxy Host'), findsOneWidget);
      expect(find.text('Port'), findsOneWidget);
    });

    // ── Test 6: Toggle fires onProxyEnabledChanged callback ─────────────────

    testWidgets('toggle fires onProxyEnabledChanged callback',
        (WidgetTester tester) async {
      bool? newValue;

      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (v) => newValue = v,
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      expect(newValue, isTrue);
    });

    // ── Test 7: Text fields accept input ────────────────────────────────────

    testWidgets('host text field accepts input when proxy enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: true,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      // Find the TextField with 'Proxy Host' label and enter text.
      final hostField = find.widgetWithText(TextField, 'Proxy Host');
      await tester.enterText(hostField, '192.168.1.100');
      expect(hostController.text, '192.168.1.100');
    });

    // ── Test 8: Worker relay field renders ───────────────────────────────────

    testWidgets('worker relay field renders with correct hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Worker Domain (optional)'), findsOneWidget);
    });

    // ── Test 9: Help section expands on tap ──────────────────────────────────

    testWidgets('CF Worker help section expands when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      // The help toggle text.
      final helpToggle =
          find.text('How to deploy a CF Worker relay (free)');
      expect(helpToggle, findsOneWidget);

      // Before tapping, the expanded help content should not be visible.
      expect(find.text('Create Worker'), findsNothing);

      // Tap to expand.
      await tester.tap(helpToggle);
      await tester.pumpAndSettle();

      // After tapping, the detailed instructions should be visible.
      expect(find.textContaining('Create Worker'), findsOneWidget);
    });

    // ── Test 10: Shows info box with shield icon ────────────────────────────

    testWidgets('shows info box with shield icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        CustomProxySection(
          proxyEnabled: false,
          proxyHostController: hostController,
          proxyPortController: portController,
          onProxyEnabledChanged: (_) {},
          workerRelayController: workerController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
      expect(find.textContaining('Custom proxy routes traffic'), findsOneWidget);
    });
  });
}
