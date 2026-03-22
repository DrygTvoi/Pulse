// Widget tests for TurnScreen (lib/screens/settings/turn_screen.dart).
//
// TurnScreen loads IceServerConfig (SharedPreferences-based) and renders
// TurnConfigSection. IceServerConfig.loadEnabledPresets and loadCustomTurn
// use SharedPreferences which is mockable. However the TurnConfigSection
// itself references kTurnPresets from ice_server_config.dart.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/screens/settings/turn_screen.dart';
import 'package:pulse_messenger/widgets/turn_config_section.dart';

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

  group('TurnScreen', () {
    // -- Test 1: Renders AppBar with TURN Servers title --------------------

    testWidgets('renders AppBar with TURN Servers title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const TurnScreen()));
      await tester.pumpAndSettle();

      expect(find.text('TURN Servers'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    // -- Test 2: Contains TurnConfigSection --------------------------------

    testWidgets('contains TurnConfigSection widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const TurnScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TurnConfigSection), findsOneWidget);
    });

    // -- Test 3: Shows Community TURN Servers section label -----------------

    testWidgets('shows Community TURN Servers section label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const TurnScreen()));
      await tester.pumpAndSettle();

      expect(find.text('COMMUNITY TURN SERVERS'), findsOneWidget);
    });

    // -- Test 4: Shows Custom TURN Server section label --------------------

    testWidgets('shows Custom TURN Server section label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const TurnScreen()));
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM TURN SERVER (BYOD)'), findsOneWidget);
    });

    // -- Test 5: Shows TURN info box about encryption ----------------------

    testWidgets('shows TURN info box explaining encryption',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const TurnScreen()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('TURN servers only relay already-encrypted'),
        findsOneWidget,
      );
    });

    // -- Test 6: Shows preset names (Open Relay, FreeTURN) -----------------

    testWidgets('shows preset names from kTurnPresets',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const TurnScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Open Relay'), findsOneWidget);
      expect(find.textContaining('FreeTURN'), findsOneWidget);
    });
  });
}
