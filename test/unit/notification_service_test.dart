import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService — isChatMuted / setChatMuted', () {
    late NotificationService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      // NotificationService is a singleton; we test its mute logic directly.
      service = NotificationService();
    });

    test('isChatMuted returns false by default', () async {
      expect(await service.isChatMuted('contact_123'), isFalse);
    });

    test('setChatMuted(true) makes isChatMuted return true', () async {
      await service.setChatMuted('contact_123', true);
      expect(await service.isChatMuted('contact_123'), isTrue);
    });

    test('setChatMuted(false) makes isChatMuted return false', () async {
      await service.setChatMuted('contact_abc', true);
      expect(await service.isChatMuted('contact_abc'), isTrue);
      await service.setChatMuted('contact_abc', false);
      expect(await service.isChatMuted('contact_abc'), isFalse);
    });

    test('muting one contact does not affect another', () async {
      await service.setChatMuted('alice', true);
      expect(await service.isChatMuted('alice'), isTrue);
      expect(await service.isChatMuted('bob'), isFalse);
    });

    test('mute key format is chat_mute_<id>', () async {
      SharedPreferences.setMockInitialValues({});
      await service.setChatMuted('myContact', true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('chat_mute_myContact'), isTrue);
    });

    test('unmuting removes the key from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      await service.setChatMuted('removeMe', true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('chat_mute_removeMe'), isTrue);
      await service.setChatMuted('removeMe', false);
      // After unmuting, the key should be removed (not set to false)
      final prefs2 = await SharedPreferences.getInstance();
      expect(prefs2.containsKey('chat_mute_removeMe'), isFalse);
    });

    test('isChatMuted reads pre-existing SharedPreferences values', () async {
      SharedPreferences.setMockInitialValues({
        'chat_mute_preexisting': true,
      });
      expect(await service.isChatMuted('preexisting'), isTrue);
    });

    test('isChatMuted returns false when prefs key is absent', () async {
      SharedPreferences.setMockInitialValues({
        'chat_mute_other': true,
      });
      expect(await service.isChatMuted('nonexistent'), isFalse);
    });

    test('can mute and unmute multiple contacts independently', () async {
      SharedPreferences.setMockInitialValues({});
      await service.setChatMuted('a', true);
      await service.setChatMuted('b', true);
      await service.setChatMuted('c', true);
      expect(await service.isChatMuted('a'), isTrue);
      expect(await service.isChatMuted('b'), isTrue);
      expect(await service.isChatMuted('c'), isTrue);

      await service.setChatMuted('b', false);
      expect(await service.isChatMuted('a'), isTrue);
      expect(await service.isChatMuted('b'), isFalse);
      expect(await service.isChatMuted('c'), isTrue);
    });

    test('mute key handles special characters in contact id', () async {
      SharedPreferences.setMockInitialValues({});
      const id = 'user@wss://relay.example.com';
      await service.setChatMuted(id, true);
      expect(await service.isChatMuted(id), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('chat_mute_$id'), isTrue);
    });

    test('mute key handles empty string contact id', () async {
      SharedPreferences.setMockInitialValues({});
      await service.setChatMuted('', true);
      expect(await service.isChatMuted(''), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('chat_mute_'), isTrue);
    });
  });
}
