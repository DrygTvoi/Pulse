import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/identity.dart';

void main() {
  Identity makeIdentity({
    String id = 'user-1',
    String publicKey = 'pub123',
    String privateKey = 'priv123',
    String preferredAdapter = 'nostr',
    Map<String, String>? adapterConfig,
  }) =>
      Identity(
        id: id,
        publicKey: publicKey,
        privateKey: privateKey,
        preferredAdapter: preferredAdapter,
        adapterConfig: adapterConfig ?? {'relay': 'wss://relay.test'},
      );

  group('Identity.copyWith()', () {
    test('returns new instance with updated preferredAdapter', () {
      final original = makeIdentity(preferredAdapter: 'nostr');
      final updated = original.copyWith(preferredAdapter: 'firebase');
      expect(updated.preferredAdapter, equals('firebase'));
      expect(original.preferredAdapter, equals('nostr')); // original unchanged
    });

    test('returns new instance with updated adapterConfig', () {
      final original = makeIdentity(adapterConfig: {'token': 'abc', 'dbId': 'x'});
      final newConfig = Map<String, String>.from(original.adapterConfig)
        ..remove('token');
      final updated = original.copyWith(adapterConfig: newConfig);
      expect(updated.adapterConfig.containsKey('token'), isFalse);
      expect(updated.adapterConfig['dbId'], equals('x'));
    });

    test('original adapterConfig is not mutated when copyWith is used', () {
      final original = makeIdentity(adapterConfig: {'token': 'secret'});
      final newConfig = Map<String, String>.from(original.adapterConfig)
        ..remove('token');
      original.copyWith(adapterConfig: newConfig);
      // Original must still have its token
      expect(original.adapterConfig['token'], equals('secret'));
    });

    test('preserves unchanged fields', () {
      final original = makeIdentity(id: 'u1', publicKey: 'pk', privateKey: 'sk');
      final updated = original.copyWith(preferredAdapter: 'nostr');
      expect(updated.id, equals('u1'));
      expect(updated.publicKey, equals('pk'));
      expect(updated.privateKey, equals('sk'));
    });

    test('with no args returns equivalent identity', () {
      final original = makeIdentity();
      final copy = original.copyWith();
      expect(copy.id, equals(original.id));
      expect(copy.publicKey, equals(original.publicKey));
      expect(copy.preferredAdapter, equals(original.preferredAdapter));
      expect(copy.adapterConfig, equals(original.adapterConfig));
    });
  });

  group('Identity.toJson() / fromJson()', () {
    test('round-trip preserves all fields', () {
      final original = makeIdentity(
        id: 'u1',
        publicKey: 'pk1',
        privateKey: 'sk1',
        preferredAdapter: 'nostr',
        adapterConfig: {'relay': 'wss://relay.damus.io'},
      );
      final json = original.toJson()
        ..['privateKey'] = 'sk1'; // toJson intentionally omits privateKey
      final restored = Identity.fromJson(json);
      expect(restored.id, equals(original.id));
      expect(restored.publicKey, equals(original.publicKey));
      expect(restored.preferredAdapter, equals(original.preferredAdapter));
      expect(restored.adapterConfig, equals(original.adapterConfig));
    });
  });
}
