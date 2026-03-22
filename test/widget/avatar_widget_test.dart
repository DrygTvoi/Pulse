// Widget tests for AvatarWidget (lib/widgets/avatar_widget.dart).
//
// Tests focus on: initials rendering, container presence, correct sizing.
// AvatarWidget has no platform dependencies.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/widgets/avatar_widget.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AvatarWidget', () {
    // ── Test 1: Renders single initial for single-word name ────────────────────

    testWidgets('renders single initial for single-word name',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: 'Alice', size: 52),
      ));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    // ── Test 2: Renders two initials for two-word name ─────────────────────────

    testWidgets('renders two initials for two-word name',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: 'Bob Smith', size: 52),
      ));
      await tester.pumpAndSettle();

      expect(find.text('BS'), findsOneWidget);
    });

    // ── Test 3: Renders "?" for empty name ─────────────────────────────────────

    testWidgets('renders "?" when name is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: '', size: 52),
      ));
      await tester.pumpAndSettle();

      expect(find.text('?'), findsOneWidget);
    });

    // ── Test 4: Container has correct size ─────────────────────────────────────

    testWidgets('container has the specified size',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: 'Test', size: 64),
      ));
      await tester.pumpAndSettle();

      // AvatarWidget sets width and height directly on its Container.
      // Check the actual rendered size.
      final size = tester.getSize(find.byType(AvatarWidget));
      expect(size.width, 64.0);
      expect(size.height, 64.0);
    });

    // ── Test 5: Renders Container (circle shape) when no image ────────────────

    testWidgets('renders a Container with circle gradient when no image',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: 'Charlie', size: 52),
      ));
      await tester.pumpAndSettle();

      // The avatar uses a Container with BoxDecoration including a gradient
      // and shape: BoxShape.circle.
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Find the Container that has BoxDecoration with circle shape.
      bool foundCircle = false;
      for (final element in containerFinder.evaluate()) {
        final widget = element.widget;
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            foundCircle = true;
            break;
          }
        }
      }
      expect(foundCircle, isTrue);
    });

    // ── Test 6: Uses ClipRRect (rounded image) when imageBytes provided ───────

    testWidgets('renders ClipRRect when imageBytes is provided',
        (WidgetTester tester) async {
      // Create a minimal 1x1 PNG image.
      final imageBytes = Uint8List.fromList([
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

      await tester.pumpWidget(buildTestableWidget(
        AvatarWidget(name: 'Dave', size: 52, imageBytes: imageBytes),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    // ── Test 7: Different size results in different rendered size ──────────────

    testWidgets('renders at size 36 when specified',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: 'Eve', size: 36),
      ));
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(AvatarWidget));
      expect(size.width, 36.0);
      expect(size.height, 36.0);
    });

    // ── Test 8: Initials are uppercase ─────────────────────────────────────────

    testWidgets('initials are uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AvatarWidget(name: 'frank grace', size: 52),
      ));
      await tester.pumpAndSettle();

      expect(find.text('FG'), findsOneWidget);
    });
  });
}
