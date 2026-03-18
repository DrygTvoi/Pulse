import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/screens/add_contact_dialog.dart';

void main() {
  String makeLink(Map<String, dynamic> cfg) {
    final encoded = base64Encode(utf8.encode(jsonEncode(cfg)));
    return 'pulse://add?cfg=$encoded';
  }

  group('parsePulseLink()', () {
    test('single address string (legacy format)', () {
      final link = makeLink({'a': 'abc123@wss://relay.test', 'n': 'Alice'});
      final result = parsePulseLink(link);
      expect(result, isNotNull);
      expect(result!.addresses, equals(['abc123@wss://relay.test']));
      expect(result.name, equals('Alice'));
    });

    test('array of addresses (multi-transport format)', () {
      final link = makeLink({
        'a': ['pubkey1@wss://relay1.test', 'pubkey2@wss://relay2.test'],
        'n': 'Bob',
      });
      final result = parsePulseLink(link);
      expect(result, isNotNull);
      expect(result!.addresses.length, equals(2));
      expect(result.addresses[0], equals('pubkey1@wss://relay1.test'));
      expect(result.addresses[1], equals('pubkey2@wss://relay2.test'));
      expect(result.name, equals('Bob'));
    });

    test('messenger:// scheme also works', () {
      final cfg = base64Encode(utf8.encode(jsonEncode({'a': 'addr@wss://r.io', 'n': 'C'})));
      final link = 'messenger://add?cfg=$cfg';
      final result = parsePulseLink(link);
      expect(result, isNotNull);
      expect(result!.addresses, equals(['addr@wss://r.io']));
    });

    test('missing name returns empty string for name', () {
      final link = makeLink({'a': 'addr@wss://relay.test'});
      final result = parsePulseLink(link);
      expect(result, isNotNull);
      expect(result!.name, equals(''));
      expect(result.addresses, equals(['addr@wss://relay.test']));
    });

    test('empty address array returns null', () {
      final link = makeLink({'a': [], 'n': 'Dave'});
      expect(parsePulseLink(link), isNull);
    });

    test('missing a field returns null', () {
      final link = makeLink({'n': 'Eve'});
      expect(parsePulseLink(link), isNull);
    });

    test('invalid base64 returns null', () {
      expect(parsePulseLink('pulse://add?cfg=!!!invalid!!!'), isNull);
    });

    test('missing cfg param returns null', () {
      expect(parsePulseLink('pulse://add'), isNull);
    });

    test('array with empty strings filters them out', () {
      final link = makeLink({'a': ['valid@wss://r.test', '', '  '], 'n': 'Frank'});
      final result = parsePulseLink(link);
      expect(result, isNotNull);
      // Empty/whitespace entries are kept if non-empty (trimmed at contact add time).
      // Only truly empty strings are filtered.
      expect(result!.addresses.where((a) => a.isEmpty), isEmpty);
    });

    test('first address in array is primary', () {
      final link = makeLink({
        'a': ['primary@wss://r1.test', 'secondary@wss://r2.test', 'tertiary@wss://r3.test'],
        'n': 'Multi',
      });
      final result = parsePulseLink(link);
      expect(result!.addresses.first, equals('primary@wss://r1.test'));
      expect(result.addresses.length, equals(3));
    });
  });
}
