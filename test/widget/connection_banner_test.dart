// Widget tests for OfflineBanner (lib/widgets/connection_banner.dart).
//
// Tests focus on: visibility when disconnected vs connected.
// OfflineBanner uses ConnectionStatus from chat_controller.dart.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/controllers/chat_controller.dart';
import 'package:pulse_messenger/widgets/connection_banner.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineBanner', () {
    // ── Test 1: Shows offline message when disconnected ───────────────────────

    testWidgets('shows offline message when status is disconnected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OfflineBanner(status: ConnectionStatus.disconnected),
      ));
      await tester.pumpAndSettle();

      // The l10n key offlineBanner produces:
      // "No connection — messages will queue and send when back online"
      expect(find.textContaining('No connection'), findsOneWidget);
    });

    // ── Test 2: Shows cloud_off icon when disconnected ────────────────────────

    testWidgets('shows cloud_off icon when disconnected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OfflineBanner(status: ConnectionStatus.disconnected),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    // ── Test 3: Hidden when connected ─────────────────────────────────────────

    testWidgets('renders SizedBox.shrink when status is connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OfflineBanner(status: ConnectionStatus.connected),
      ));
      await tester.pumpAndSettle();

      // When connected, OfflineBanner returns SizedBox.shrink().
      expect(find.textContaining('No connection'), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });

    // ── Test 4: Hidden when connecting ─────────────────────────────────────────

    testWidgets('renders SizedBox.shrink when status is connecting',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OfflineBanner(status: ConnectionStatus.connecting),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('No connection'), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });
  });
}
