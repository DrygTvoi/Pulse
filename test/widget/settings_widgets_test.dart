// Widget tests for shared settings helper widgets
// (lib/screens/settings/settings_widgets.dart).
//
// Tests focus on: settingsSectionLabel, settingsSectionDivider, settingsRow,
// settingsField, and BackupProgressDialog rendering.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/screens/settings/settings_widgets.dart';

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
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('settingsSectionLabel', () {
    // -- Test 1: Renders uppercased text ------------------------------------

    testWidgets('renders uppercased text', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(settingsSectionLabel('Network')));
      await tester.pumpAndSettle();

      expect(find.text('NETWORK'), findsOneWidget);
    });
  });

  group('settingsSectionDivider', () {
    // -- Test 2: Renders label and a Divider --------------------------------

    testWidgets('renders uppercased label with a Divider',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(settingsSectionDivider('Security')));
      await tester.pumpAndSettle();

      expect(find.text('SECURITY'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('settingsRow', () {
    // -- Test 3: Renders title, subtitle, and icon --------------------------

    testWidgets('renders title, subtitle, and icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        settingsRow(
          icon: Icons.lock_rounded,
          iconColor: Colors.blue,
          title: 'App Password',
          subtitle: 'Protect your data',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('App Password'), findsOneWidget);
      expect(find.text('Protect your data'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    // -- Test 4: Shows chevron when no trailing widget ----------------------

    testWidgets('shows chevron_right icon when no trailing is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        settingsRow(
          icon: Icons.info_outline,
          iconColor: Colors.green,
          title: 'About',
          subtitle: 'App info',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    // -- Test 5: Shows custom trailing widget instead of chevron ------------

    testWidgets('shows custom trailing widget instead of chevron',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        settingsRow(
          icon: Icons.shield_rounded,
          iconColor: Colors.green,
          title: 'Protocol',
          subtitle: 'E2EE',
          trailing: const Text('ACTIVE'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    // -- Test 6: onTap callback fires on GestureDetector tap ----------------

    testWidgets('onTap callback fires when row is tapped',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestableWidget(
        settingsRow(
          icon: Icons.palette_rounded,
          iconColor: Colors.purple,
          title: 'Theme',
          subtitle: 'Customize',
          onTap: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      expect(tapped, isTrue);
    });
  });

  group('settingsField', () {
    // -- Test 7: Renders a TextField with label and hint --------------------

    testWidgets('renders a TextField with label and hint',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestableWidget(
        settingsField(
          controller: controller,
          hint: 'Enter URL',
          label: 'Server URL',
          icon: Icons.dns_rounded,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Server URL'), findsOneWidget);
      expect(find.byIcon(Icons.dns_rounded), findsOneWidget);
    });
  });

  group('BackupProgressDialog', () {
    // -- Test 8: Renders title and initial status text ----------------------

    testWidgets('renders title and initial status text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeNotifier>.value(
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
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const BackupProgressDialog(
                          title: 'Backing up',
                          initialStatus: 'Preparing...',
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      // Use pump (not pumpAndSettle) — LinearProgressIndicator animates continuously.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Backing up'), findsOneWidget);
      expect(find.text('Preparing...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    // -- Test 9: updateProgress changes status text -------------------------

    testWidgets('updateProgress changes status text and progress',
        (WidgetTester tester) async {
      final dialogKey = GlobalKey<BackupProgressDialogState>();

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeNotifier>.value(
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
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BackupProgressDialog(
                          key: dialogKey,
                          title: 'Export',
                          initialStatus: 'Starting...',
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      // Use pump (not pumpAndSettle) — LinearProgressIndicator animates continuously.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Starting...'), findsOneWidget);

      // Update progress via the state's public method
      dialogKey.currentState!.updateProgress('50% done', 0.5);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('50% done'), findsOneWidget);
      expect(find.text('Starting...'), findsNothing);
    });
  });
}
