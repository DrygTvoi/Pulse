import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/screens/home_screen.dart';
import '../helpers/test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    setUpServiceMocks();
    createTestChatController();
  });

  group('HomeScreen', () {
    testWidgets('renders chat list', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows empty state', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // The empty state shows a chat_bubble_outline_rounded icon and
      // "No chats yet" text. In wide mode (>700px) the icon may appear
      // twice (empty list + empty detail pane), so verify at least one.
      expect(find.byIcon(Icons.chat_bubble_outline_rounded),
          findsAtLeastNWidgets(1));
      expect(find.text('No chats yet'), findsOneWidget);
    });

    testWidgets('FAB is present', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
