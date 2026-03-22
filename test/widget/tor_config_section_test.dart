// Widget tests for TorConfigSection (lib/widgets/tor_config_section.dart).
//
// TorConfigSection accesses TorService.instance in build() to read
// isBootstrapped, isRunning, bootstrapPercent.  Since TorService is a real
// singleton managing native tor processes, tests that render the widget need
// to accept the default state of the TorService singleton (not running).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';

import 'package:pulse_messenger/widgets/tor_config_section.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TorConfigSection', () {
    // ── Test 1: Renders Built-in Tor card title ─────────────────────────────
    testWidgets('renders Built-in Tor title', (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TorConfigSection(
          torEnabled: false,
          bundledTorEnabled: false,
          bundledTorLoading: false,
          preferredPt: 'auto',
          torHostController: hostCtrl,
          torPortController: portCtrl,
          onTorEnabledChanged: (_) {},
          onToggleBundledTor: () {},
          onPreferredPtChanged: (_) {},
          onOpenDiagnostics: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Built-in Tor'), findsOneWidget);
    });

    // ── Test 2: Shows Network Diagnostics button ────────────────────────────
    testWidgets('shows Network Diagnostics button',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TorConfigSection(
          torEnabled: false,
          bundledTorEnabled: false,
          bundledTorLoading: false,
          preferredPt: 'auto',
          torHostController: hostCtrl,
          torPortController: portCtrl,
          onTorEnabledChanged: (_) {},
          onToggleBundledTor: () {},
          onPreferredPtChanged: (_) {},
          onOpenDiagnostics: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Network Diagnostics'), findsOneWidget);
    });

    // ── Test 3: Shows manual Tor proxy section when bundled is off ───────────
    testWidgets('shows manual Tor proxy fields when bundledTorEnabled is false',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TorConfigSection(
          torEnabled: false,
          bundledTorEnabled: false,
          bundledTorLoading: false,
          preferredPt: 'auto',
          torHostController: hostCtrl,
          torPortController: portCtrl,
          onTorEnabledChanged: (_) {},
          onToggleBundledTor: () {},
          onPreferredPtChanged: (_) {},
          onOpenDiagnostics: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Section label for manual proxy
      expect(find.text('TOR PROXY (SOCKS5)'), findsOneWidget);
      expect(find.text('Route Nostr via Tor'), findsOneWidget);
    });

    // ── Test 4: Hides manual Tor proxy section when bundled is on ────────────
    testWidgets('hides manual Tor proxy fields when bundledTorEnabled is true',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TorConfigSection(
          torEnabled: false,
          bundledTorEnabled: true,
          bundledTorLoading: false,
          preferredPt: 'auto',
          torHostController: hostCtrl,
          torPortController: portCtrl,
          onTorEnabledChanged: (_) {},
          onToggleBundledTor: () {},
          onPreferredPtChanged: (_) {},
          onOpenDiagnostics: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Manual proxy section should be hidden
      expect(find.text('TOR PROXY (SOCKS5)'), findsNothing);
    });

    // ── Test 5: onOpenDiagnostics fires when diagnostics button tapped ──────
    testWidgets('onOpenDiagnostics fires when diagnostics button is tapped',
        (WidgetTester tester) async {
      bool opened = false;
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TorConfigSection(
          torEnabled: false,
          bundledTorEnabled: false,
          bundledTorLoading: false,
          preferredPt: 'auto',
          torHostController: hostCtrl,
          torPortController: portCtrl,
          onTorEnabledChanged: (_) {},
          onToggleBundledTor: () {},
          onPreferredPtChanged: (_) {},
          onOpenDiagnostics: () => opened = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Network Diagnostics'));
      expect(opened, isTrue);
    });

    // ── Test 6: PT selector visible when bundledTorEnabled ──────────────────
    testWidgets('shows PT selector chips when bundledTorEnabled is true',
        (WidgetTester tester) async {
      final hostCtrl = TextEditingController();
      final portCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TorConfigSection(
          torEnabled: false,
          bundledTorEnabled: true,
          bundledTorLoading: false,
          preferredPt: 'auto',
          torHostController: hostCtrl,
          torPortController: portCtrl,
          onTorEnabledChanged: (_) {},
          onToggleBundledTor: () {},
          onPreferredPtChanged: (_) {},
          onOpenDiagnostics: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Transport selector should be visible with options
      expect(find.text('Transport: '), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('obfs4'), findsOneWidget);
      expect(find.text('Snowflake'), findsOneWidget);
    });
  });
}
