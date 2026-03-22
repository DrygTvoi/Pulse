// Widget tests for StatusCreatorScreen (lib/screens/status_creator_screen.dart).
//
// StatusCreatorScreen depends on:
// - StatusService.instance (for setOwnStatus in _publish)
// - ChatController() (for broadcastStatus in _publish)
// - MediaService().pickImage (for _pickPhoto)
//
// The screen renders a text field and buttons without calling services until
// user interaction. However, _publish() calls ChatController() which is a
// singleton requiring platform dependencies (SQLite, secure storage).
// Basic rendering tests can pass; interaction tests are skipped.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/status_creator_screen.dart';
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

  group('StatusCreatorScreen', () {
    testWidgets('has a Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const StatusCreatorScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "New Status" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const StatusCreatorScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('New Status'), findsOneWidget);
    });

    testWidgets('has a text field with hint "What\'s on your mind?"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const StatusCreatorScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("What's on your mind?"), findsOneWidget);
    });

    testWidgets('has a "Publish" button in the AppBar actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const StatusCreatorScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Publish'), findsOneWidget);
    });

    testWidgets('shows "Status expires in 24 hours" info text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const StatusCreatorScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Status expires in 24 hours'), findsOneWidget);
    });
  });
}
