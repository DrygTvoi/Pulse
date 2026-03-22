import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/user_status.dart';

void main() {
  group('UserStatus.fromJson / toJson roundtrip', () {
    test('roundtrip preserves all fields', () {
      final now = DateTime.now();
      final original = UserStatus(
        id: 'status_1',
        text: 'Hello world',
        mediaPayload: 'base64data',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );
      final json = original.toJson();
      final restored = UserStatus.fromJson(json);
      expect(restored.id, equals('status_1'));
      expect(restored.text, equals('Hello world'));
      expect(restored.mediaPayload, equals('base64data'));
      expect(restored.createdAt.millisecondsSinceEpoch,
          equals(now.millisecondsSinceEpoch));
      expect(restored.expiresAt.millisecondsSinceEpoch,
          equals(now.add(const Duration(hours: 24)).millisecondsSinceEpoch));
    });

    test('roundtrip preserves status without media', () {
      final now = DateTime.now();
      final original = UserStatus(
        id: 'status_2',
        text: 'No photo',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );
      final json = original.toJson();
      final restored = UserStatus.fromJson(json);
      expect(restored.id, equals('status_2'));
      expect(restored.text, equals('No photo'));
      expect(restored.mediaPayload, isNull);
    });

    test('toJson omits media key when mediaPayload is null', () {
      final now = DateTime.now();
      final status = UserStatus(
        id: 'id',
        text: 'text',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );
      final json = status.toJson();
      expect(json.containsKey('media'), isFalse);
    });

    test('toJson includes media key when mediaPayload is not null', () {
      final now = DateTime.now();
      final status = UserStatus(
        id: 'id',
        text: 'text',
        mediaPayload: 'data',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );
      final json = status.toJson();
      expect(json.containsKey('media'), isTrue);
      expect(json['media'], equals('data'));
    });
  });

  group('UserStatus.isExpired', () {
    test('returns false for status expiring in the future', () {
      final status = UserStatus(
        id: 'active',
        text: 'still visible',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(status.isExpired, isFalse);
    });

    test('returns true for status that expired in the past', () {
      final status = UserStatus(
        id: 'old',
        text: 'expired',
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(status.isExpired, isTrue);
    });

    test('returns true for status with expiresAt = epoch zero', () {
      final status = UserStatus(
        id: 'zero',
        text: 'zero expiry',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(status.isExpired, isTrue);
    });
  });

  group('UserStatus.hasMedia', () {
    test('returns true when mediaPayload is non-empty', () {
      final status = UserStatus(
        id: 'id',
        text: 'text',
        mediaPayload: 'base64encoded',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(status.hasMedia, isTrue);
    });

    test('returns false when mediaPayload is null', () {
      final status = UserStatus(
        id: 'id',
        text: 'text',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(status.hasMedia, isFalse);
    });

    test('returns false when mediaPayload is empty string', () {
      final status = UserStatus(
        id: 'id',
        text: 'text',
        mediaPayload: '',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(status.hasMedia, isFalse);
    });
  });

  group('UserStatus.create()', () {
    test('sets expiresAt to 24 hours after createdAt', () {
      final status = UserStatus.create(id: 'new', text: 'Fresh status');
      final diff = status.expiresAt.difference(status.createdAt);
      expect(diff.inHours, equals(24));
    });

    test('does not expire immediately', () {
      final status = UserStatus.create(id: 'new2', text: 'test');
      expect(status.isExpired, isFalse);
    });

    test('accepts optional mediaPayload', () {
      final status = UserStatus.create(
        id: 'media',
        text: 'with photo',
        mediaPayload: 'payload123',
      );
      expect(status.hasMedia, isTrue);
      expect(status.mediaPayload, equals('payload123'));
    });

    test('mediaPayload defaults to null', () {
      final status = UserStatus.create(id: 'no_media', text: 'text only');
      expect(status.mediaPayload, isNull);
      expect(status.hasMedia, isFalse);
    });
  });

  group('UserStatus.fromJson — null/zero value handling', () {
    test('createdAt defaults to epoch 0 when missing', () {
      final status = UserStatus.fromJson({
        'id': 'x',
        'text': 'y',
        'expiresAt': 1000,
      });
      expect(status.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
    });

    test('expiresAt defaults to epoch 0 when missing', () {
      final status = UserStatus.fromJson({
        'id': 'x',
        'text': 'y',
        'createdAt': 1000,
      });
      expect(status.expiresAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
    });

    test('createdAt defaults to epoch 0 when null', () {
      final status = UserStatus.fromJson({
        'id': 'x',
        'text': 'y',
        'createdAt': null,
        'expiresAt': null,
      });
      expect(status.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
      expect(status.expiresAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
    });

    test('id defaults to empty string when missing', () {
      final status = UserStatus.fromJson({
        'text': 'hello',
        'createdAt': 1000,
        'expiresAt': 2000,
      });
      expect(status.id, equals(''));
    });

    test('text defaults to empty string when missing', () {
      final status = UserStatus.fromJson({
        'id': 'x',
        'createdAt': 1000,
        'expiresAt': 2000,
      });
      expect(status.text, equals(''));
    });

    test('media field returns null when absent', () {
      final status = UserStatus.fromJson({
        'id': 'x',
        'text': 'y',
        'createdAt': 1000,
        'expiresAt': 2000,
      });
      expect(status.mediaPayload, isNull);
    });

    test('handles zero timestamps (epoch)', () {
      final status = UserStatus.fromJson({
        'id': 'zero',
        'text': 'test',
        'createdAt': 0,
        'expiresAt': 0,
      });
      expect(status.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
      expect(status.expiresAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
      expect(status.isExpired, isTrue);
    });
  });

  group('UserStatus.toJsonString / tryFromJsonString', () {
    test('toJsonString produces valid JSON', () {
      final status = UserStatus.create(id: 's1', text: 'hello');
      final jsonStr = status.toJsonString();
      expect(() => jsonDecode(jsonStr), returnsNormally);
    });

    test('tryFromJsonString roundtrip works', () {
      final original = UserStatus.create(
        id: 'roundtrip',
        text: 'test text',
        mediaPayload: 'media123',
      );
      final jsonStr = original.toJsonString();
      final restored = UserStatus.tryFromJsonString(jsonStr);
      expect(restored, isNotNull);
      expect(restored!.id, equals('roundtrip'));
      expect(restored.text, equals('test text'));
      expect(restored.mediaPayload, equals('media123'));
    });

    test('tryFromJsonString returns null for null input', () {
      expect(UserStatus.tryFromJsonString(null), isNull);
    });

    test('tryFromJsonString returns null for empty string', () {
      expect(UserStatus.tryFromJsonString(''), isNull);
    });

    test('tryFromJsonString returns null for invalid JSON', () {
      expect(UserStatus.tryFromJsonString('{broken'), isNull);
    });

    test('tryFromJsonString returns null for non-map JSON', () {
      expect(UserStatus.tryFromJsonString('"just a string"'), isNull);
    });
  });
}
