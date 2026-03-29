import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/services/key_manager.dart';
import 'package:pulse_messenger/services/signal_service.dart';
import 'package:pulse_messenger/services/pqc_service.dart';

Contact _makeContact({
  required String id,
  String provider = 'Nostr',
  String databaseId = '',
  List<String> alternateAddresses = const [],
}) =>
    Contact(
      id: id,
      name: 'Test',
      provider: provider,
      databaseId: databaseId.isEmpty ? '$id@wss://relay.test' : databaseId,
      publicKey: '',
      alternateAddresses: alternateAddresses,
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('KeyManager — PQC key cache', () {
    test('hasPqcKey returns false before caching', () {
      final km = KeyManager(SignalService(), PqcService());
      expect(km.hasPqcKey('contact1'), isFalse);
    });

    test('cacheContactKyberPk stores key in memory', () {
      final km = KeyManager(SignalService(), PqcService());
      final bundle = <String, dynamic>{
        'kyberPublicKey': List<int>.filled(1568, 0xAB),
      };
      km.cacheContactKyberPk('contact1', bundle);
      expect(km.hasPqcKey('contact1'), isTrue);
    });

    test('cacheContactKyberPk ignores bundle without kyberPublicKey', () {
      final km = KeyManager(SignalService(), PqcService());
      km.cacheContactKyberPk('contact2', {});
      expect(km.hasPqcKey('contact2'), isFalse);
    });

    test('loadContactKyberPk returns cached value', () async {
      final km = KeyManager(SignalService(), PqcService());
      final pk = List<int>.filled(1568, 0x99);
      km.cacheContactKyberPk('contact3', {'kyberPublicKey': pk});
      final loaded = await km.loadContactKyberPk('contact3');
      expect(loaded, isNotNull);
      expect(loaded!.length, equals(1568));
    });
  });

  group('KeyManager — extractPubkey', () {
    test('extracts pubkey from nostr address', () {
      final km = KeyManager(SignalService(), PqcService());
      final pubkey = 'a' * 64;
      final addr = '$pubkey@wss://relay.test';
      expect(km.extractPubkey(addr, []), equals(pubkey));
    });

    test('extracts 64-hex standalone pubkey', () {
      final km = KeyManager(SignalService(), PqcService());
      final pubkey = 'b' * 64;
      expect(km.extractPubkey(pubkey, []), equals(pubkey));
    });

    test('returns null for non-pubkey address', () {
      final km = KeyManager(SignalService(), PqcService());
      expect(km.extractPubkey('user@https://firebase.io', []), isNull);
    });

    test('extracts pubkey from contact alternate addresses', () {
      final km = KeyManager(SignalService(), PqcService());
      final pubkey = 'c' * 64;
      final contact = _makeContact(
        id: 'c1',
        provider: 'Firebase',
        databaseId: 'user@https://fb.io',
        alternateAddresses: ['$pubkey@wss://relay.test'],
      );
      final result = km.extractPubkey('user@https://fb.io', [contact]);
      expect(result, equals(pubkey));
    });

    test('returns null for unknown address with no contacts', () {
      final km = KeyManager(SignalService(), PqcService());
      expect(km.extractPubkey('unknownuser@https://fb.io', []), isNull);
    });
  });

  group('KeyManager — hasPqcKey', () {
    test('returns true only after caching', () {
      final km = KeyManager(SignalService(), PqcService());
      expect(km.hasPqcKey('x'), isFalse);
      km.cacheContactKyberPk('x', {'kyberPublicKey': List<int>.filled(1568, 0x42)});
      expect(km.hasPqcKey('x'), isTrue);
    });
  });
}
