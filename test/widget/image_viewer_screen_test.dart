// Widget tests for ImageViewerScreen (lib/screens/image_viewer_screen.dart).
//
// Tests focus on: rendering image from Uint8List, InteractiveViewer presence,
// download button, AppBar filename display, Scaffold background.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/image_viewer_screen.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

/// Minimal valid 1x1 red pixel PNG.
final _testImageBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
  0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
  0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

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

  group('ImageViewerScreen', () {
    // ── Test 1: Renders Image.memory widget from imageData ──────────────────

    testWidgets('renders Image.memory from provided imageData',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      // Image.memory creates an Image widget.
      expect(find.byType(Image), findsOneWidget);
    });

    // ── Test 2: Has InteractiveViewer for pinch-to-zoom ─────────────────────

    testWidgets('has InteractiveViewer for pinch-to-zoom',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    // ── Test 3: InteractiveViewer has maxScale 6.0 ──────────────────────────

    testWidgets('InteractiveViewer has maxScale of 6.0',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.maxScale, 6.0);
    });

    // ── Test 4: AppBar shows filename ────────────────────────────────────────

    testWidgets('AppBar displays the filename',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'my_screenshot.png',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('my_screenshot.png'), findsOneWidget);
    });

    // ── Test 5: Has download button with correct icon ───────────────────────

    testWidgets('has download button with download_rounded icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    // ── Test 6: Download button has tooltip ──────────────────────────────────

    testWidgets('download button has "Save to Downloads" tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Save to Downloads'), findsOneWidget);
    });

    // ── Test 7: Scaffold has black background ───────────────────────────────

    testWidgets('Scaffold has black background',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    // ── Test 8: Has AppBar with back button ─────────────────────────────────

    testWidgets('has AppBar with back navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ImageViewerScreen(
          imageData: _testImageBytes,
          name: 'photo.png',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      // The back button is rendered by Flutter when navigated to from
      // MaterialApp, but here it shows an IconButton leading.
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
