import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/models/user_status.dart';
import 'package:pulse_messenger/services/status_service.dart';

void main() {
  // ── UserStatus model tests ──────────────────────────────────────────

  group('UserStatus model: constructor', () {
    test('creates instance with all required fields', () {
      final now = DateTime.utc(2026, 3, 21, 12, 0, 0);
      final expires = now.add(const Duration(hours: 24));
      final status = UserStatus(
        id: 'status-1',
        text: 'Hello world',
        mediaPayload: 'base64data',
        createdAt: now,
        expiresAt: expires,
      );

      expect(status.id, 'status-1');
      expect(status.text, 'Hello world');
      expect(status.mediaPayload, 'base64data');
      expect(status.createdAt, now);
      expect(status.expiresAt, expires);
    });

    test('mediaPayload defaults to null', () {
      final status = UserStatus(
        id: 'id',
        text: 'text',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(status.mediaPayload, isNull);
    });

    test('create factory sets createdAt and expiresAt 24h apart', () {
      final status = UserStatus.create(id: 'u', text: 'test');
      final diff = status.expiresAt.difference(status.createdAt);
      expect(diff.inHours, 24);
    });

    test('isExpired returns true for past expiresAt', () {
      final status = UserStatus(
        id: 'old',
        text: 'expired',
        createdAt: DateTime.now().subtract(const Duration(hours: 48)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
      );
      expect(status.isExpired, isTrue);
    });

    test('isExpired returns false for future expiresAt', () {
      final status = UserStatus.create(id: 'new', text: 'fresh');
      expect(status.isExpired, isFalse);
    });

    test('hasMedia returns true for non-empty mediaPayload', () {
      final status = UserStatus.create(
        id: 'u',
        text: 't',
        mediaPayload: 'data',
      );
      expect(status.hasMedia, isTrue);
    });

    test('hasMedia returns false for null mediaPayload', () {
      final status = UserStatus.create(id: 'u', text: 't');
      expect(status.hasMedia, isFalse);
    });

    test('hasMedia returns false for empty string mediaPayload', () {
      final status = UserStatus(
        id: 'u',
        text: 't',
        mediaPayload: '',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(status.hasMedia, isFalse);
    });
  });

  // ── UserStatus toJson / fromJson ────────────────────────────────────

  group('UserStatus toJson / fromJson roundtrip', () {
    test('roundtrip preserves all fields including media', () {
      final now = DateTime.utc(2026, 3, 21, 10, 0, 0);
      final original = UserStatus(
        id: 'rt-1',
        text: 'Roundtrip test',
        mediaPayload: 'imgdata123',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );
      final json = original.toJson();
      final restored = UserStatus.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.mediaPayload, original.mediaPayload);
      expect(restored.createdAt.millisecondsSinceEpoch,
          original.createdAt.millisecondsSinceEpoch);
      expect(restored.expiresAt.millisecondsSinceEpoch,
          original.expiresAt.millisecondsSinceEpoch);
    });

    test('toJson omits media key when null', () {
      final status = UserStatus.create(id: 'u', text: 't');
      final json = status.toJson();
      expect(json.containsKey('media'), isFalse);
    });

    test('toJson includes media key when non-null', () {
      final status = UserStatus.create(
          id: 'u', text: 't', mediaPayload: 'photo');
      final json = status.toJson();
      expect(json['media'], 'photo');
    });

    test('fromJson handles missing fields with defaults', () {
      final status = UserStatus.fromJson(<String, dynamic>{});
      expect(status.id, '');
      expect(status.text, '');
      expect(status.mediaPayload, isNull);
      expect(status.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
      expect(status.expiresAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('toJsonString / tryFromJsonString roundtrip', () {
      final original = UserStatus.create(
        id: 'str-rt',
        text: 'String test',
        mediaPayload: 'payload',
      );
      final jsonStr = original.toJsonString();
      expect(() => jsonDecode(jsonStr), returnsNormally);

      final restored = UserStatus.tryFromJsonString(jsonStr);
      expect(restored, isNotNull);
      expect(restored!.id, original.id);
      expect(restored.text, original.text);
      expect(restored.mediaPayload, original.mediaPayload);
    });

    test('tryFromJsonString returns null for null input', () {
      expect(UserStatus.tryFromJsonString(null), isNull);
    });

    test('tryFromJsonString returns null for empty string', () {
      expect(UserStatus.tryFromJsonString(''), isNull);
    });

    test('tryFromJsonString returns null for malformed JSON', () {
      expect(UserStatus.tryFromJsonString('{broken'), isNull);
    });

    test('tryFromJsonString returns null for non-map JSON', () {
      expect(UserStatus.tryFromJsonString('"just a string"'), isNull);
      expect(UserStatus.tryFromJsonString('[1,2,3]'), isNull);
    });

    test('unicode text survives roundtrip', () {
      final status = UserStatus.create(
        id: 'u',
        text: 'Hello \u{1F600} \u{4F60}\u{597D}',
      );
      final restored = UserStatus.tryFromJsonString(status.toJsonString());
      expect(restored?.text, 'Hello \u{1F600} \u{4F60}\u{597D}');
    });
  });

  // ── StatusService with SharedPreferences ────────────────────────────

  group('StatusService: own status save/load', () {
    late StatusService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StatusService.instance;
    });

    test('getOwnStatus returns null when nothing saved', () async {
      final result = await service.getOwnStatus();
      expect(result, isNull);
    });

    test('setOwnStatus / getOwnStatus roundtrip', () async {
      final status = UserStatus.create(id: 'me', text: 'My status');
      await service.setOwnStatus(status);

      final loaded = await service.getOwnStatus();
      expect(loaded, isNotNull);
      expect(loaded!.id, 'me');
      expect(loaded.text, 'My status');
    });

    test('setOwnStatus overwrites previous status', () async {
      final first = UserStatus.create(id: 'me', text: 'First');
      await service.setOwnStatus(first);

      final second = UserStatus.create(id: 'me', text: 'Second');
      await service.setOwnStatus(second);

      final loaded = await service.getOwnStatus();
      expect(loaded, isNotNull);
      expect(loaded!.text, 'Second');
    });

    test('clearOwnStatus removes own status', () async {
      final status = UserStatus.create(id: 'me', text: 'To be cleared');
      await service.setOwnStatus(status);

      await service.clearOwnStatus();

      final loaded = await service.getOwnStatus();
      expect(loaded, isNull);
    });

    test('getOwnStatus returns null for expired status (auto-clear)', () async {
      final expired = UserStatus(
        id: 'me',
        text: 'Old status',
        createdAt: DateTime.now().subtract(const Duration(hours: 48)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
      );
      await service.setOwnStatus(expired);

      final loaded = await service.getOwnStatus();
      expect(loaded, isNull);

      // Verify it was actually cleared from storage
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_status'), isNull);
    });

    test('setOwnStatus with media payload roundtrips', () async {
      final status = UserStatus.create(
        id: 'me',
        text: 'Photo status',
        mediaPayload: 'base64imagedata==',
      );
      await service.setOwnStatus(status);

      final loaded = await service.getOwnStatus();
      expect(loaded, isNotNull);
      expect(loaded!.mediaPayload, 'base64imagedata==');
      expect(loaded.hasMedia, isTrue);
    });
  });

  group('StatusService: contact status save/load', () {
    late StatusService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StatusService.instance;
    });

    test('getContactStatus returns null when nothing saved', () async {
      final result = await service.getContactStatus('alice');
      expect(result, isNull);
    });

    test('saveContactStatus / getContactStatus roundtrip', () async {
      final status = UserStatus.create(id: 'alice', text: 'Alice status');
      await service.saveContactStatus('alice', status);

      final loaded = await service.getContactStatus('alice');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'alice');
      expect(loaded.text, 'Alice status');
    });

    test('getContactStatus returns null for expired status (auto-clear)', () async {
      final expired = UserStatus(
        id: 'bob',
        text: 'Expired',
        createdAt: DateTime.now().subtract(const Duration(hours: 48)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
      );
      await service.saveContactStatus('bob', expired);

      final loaded = await service.getContactStatus('bob');
      expect(loaded, isNull);

      // Verify cleared from storage
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('contact_status_bob'), isNull);
    });

    test('different contacts have separate statuses', () async {
      final aliceStatus = UserStatus.create(id: 'alice', text: 'Alice here');
      final bobStatus = UserStatus.create(id: 'bob', text: 'Bob here');

      await service.saveContactStatus('alice', aliceStatus);
      await service.saveContactStatus('bob', bobStatus);

      final loadedAlice = await service.getContactStatus('alice');
      final loadedBob = await service.getContactStatus('bob');

      expect(loadedAlice?.text, 'Alice here');
      expect(loadedBob?.text, 'Bob here');
    });

    test('saving contact status does not affect own status', () async {
      final ownStatus = UserStatus.create(id: 'me', text: 'Own');
      final contactStatus = UserStatus.create(id: 'alice', text: 'Contact');

      await service.setOwnStatus(ownStatus);
      await service.saveContactStatus('alice', contactStatus);

      final own = await service.getOwnStatus();
      final contact = await service.getContactStatus('alice');

      expect(own?.text, 'Own');
      expect(contact?.text, 'Contact');
    });
  });

  group('StatusService: getAllActiveStatuses', () {
    late StatusService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StatusService.instance;
    });

    test('returns empty map when no statuses saved', () async {
      final result = await service.getAllActiveStatuses(['a', 'b', 'c']);
      expect(result, isEmpty);
    });

    test('returns only active (non-expired) statuses', () async {
      final active = UserStatus.create(id: 'alice', text: 'Active');
      final expired = UserStatus(
        id: 'bob',
        text: 'Expired',
        createdAt: DateTime.now().subtract(const Duration(hours: 48)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
      );

      await service.saveContactStatus('alice', active);
      await service.saveContactStatus('bob', expired);

      final result = await service.getAllActiveStatuses(['alice', 'bob']);
      expect(result, hasLength(1));
      expect(result.containsKey('alice'), isTrue);
      expect(result.containsKey('bob'), isFalse);
    });

    test('returns statuses only for requested IDs', () async {
      final s1 = UserStatus.create(id: 'alice', text: 'Alice');
      final s2 = UserStatus.create(id: 'bob', text: 'Bob');
      final s3 = UserStatus.create(id: 'charlie', text: 'Charlie');

      await service.saveContactStatus('alice', s1);
      await service.saveContactStatus('bob', s2);
      await service.saveContactStatus('charlie', s3);

      // Only ask for alice and charlie
      final result = await service.getAllActiveStatuses(['alice', 'charlie']);
      expect(result, hasLength(2));
      expect(result.containsKey('alice'), isTrue);
      expect(result.containsKey('charlie'), isTrue);
      expect(result.containsKey('bob'), isFalse);
    });

    test('returns empty map for empty contact list', () async {
      final result = await service.getAllActiveStatuses([]);
      expect(result, isEmpty);
    });

    test('skips contacts with no saved status', () async {
      final s1 = UserStatus.create(id: 'alice', text: 'Alice');
      await service.saveContactStatus('alice', s1);

      final result = await service.getAllActiveStatuses(
          ['alice', 'bob', 'charlie']);
      expect(result, hasLength(1));
      expect(result['alice']?.text, 'Alice');
    });

    test('handles multiple statuses for many users', () async {
      // Save 5 active statuses
      for (var i = 0; i < 5; i++) {
        final s = UserStatus.create(id: 'user-$i', text: 'Status $i');
        await service.saveContactStatus('user-$i', s);
      }

      final ids = List.generate(5, (i) => 'user-$i');
      final result = await service.getAllActiveStatuses(ids);
      expect(result, hasLength(5));
      for (var i = 0; i < 5; i++) {
        expect(result['user-$i']?.text, 'Status $i');
      }
    });
  });

  group('StatusService: storage key format', () {
    test('own status key is my_status', () async {
      SharedPreferences.setMockInitialValues({});
      final service = StatusService.instance;

      final status = UserStatus.create(id: 'me', text: 'Own');
      await service.setOwnStatus(status);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_status'), isNotNull);
    });

    test('contact status key is contact_status_<id>', () async {
      SharedPreferences.setMockInitialValues({});
      final service = StatusService.instance;

      final status = UserStatus.create(id: 'alice', text: 'Alice');
      await service.saveContactStatus('alice', status);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('contact_status_alice'), isNotNull);
    });

    test('contact key with special characters in ID', () async {
      SharedPreferences.setMockInitialValues({});
      final service = StatusService.instance;

      const contactId = 'user@https://project.firebaseio.com';
      final status = UserStatus.create(id: contactId, text: 'Firebase user');
      await service.saveContactStatus(contactId, status);

      final loaded = await service.getContactStatus(contactId);
      expect(loaded, isNotNull);
      expect(loaded!.text, 'Firebase user');
    });
  });
}
