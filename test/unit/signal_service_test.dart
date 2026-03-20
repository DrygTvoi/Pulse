import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

// ── Why this file does not import SignalService directly ─────────────────────
//
// SignalService is a singleton that on initialize() calls:
//   - FlutterSecureStorage (platform channel → fails in pure Dart test)
//   - SharedPreferences (platform channel → fails in pure Dart test)
//   - libsignal_protocol_dart (safe, but unusable without a store)
//
// What IS testable here without any platform dependency:
//
//   1. encryptMessage / decryptMessage envelope format — the "E2EE||type||b64"
//      wire format has parsing logic we can test by mirroring it.
//
//   2. decryptMessage passthrough — messages not starting with "E2EE||" are
//      returned verbatim; we can verify this without initialising any store.
//
//   3. Signal bundle field structure — buildSession validates the bundle map
//      shape with typed casts; we can verify the expected field names and types
//      by mirroring the validation logic.
//
//   4. Prekey exhaustion window filtering — the 24h window logic is pure.
//
// NOTE: _formatFingerprint is already fully covered in fingerprint_format_test.dart.

// ── Mirror of SignalService.encryptMessage envelope format ─────────────────
//
// Production (signal_service.dart line 450):
//   'E2EE||${ciphertext.getType()}||${base64Encode(ciphertext.serialize())}'
//
// We test the parsing side only (no Signal session needed).
String? _parseEnvelopeType(String envelope) {
  if (!envelope.startsWith('E2EE||')) return null;
  final parts = envelope.split('||');
  if (parts.length != 3) return null;
  return parts[1]; // the numeric type string
}

Uint8List? _parseEnvelopePayload(String envelope) {
  if (!envelope.startsWith('E2EE||')) return null;
  final parts = envelope.split('||');
  if (parts.length != 3) return null;
  try {
    return base64Decode(parts[2]);
  } catch (_) {
    return null;
  }
}

// ── Mirror of decryptMessage passthrough guard ────────────────────────────────
//
// Production (signal_service.dart line 454):
//   if (!envelope.startsWith('E2EE||')) return envelope;
String _decryptPassthrough(String envelope) {
  if (!envelope.startsWith('E2EE||')) return envelope;
  throw StateError('Would decrypt — requires initialized SignalService store');
}

// ── Mirror of bundle field validation ────────────────────────────────────────
//
// buildSession performs typed casts on these fields; if any is missing or
// wrongly typed it throws FormatException('[Signal] Malformed key bundle …').
// We mirror the type assertions to verify which fields are required.
bool _bundleIsValid(Map<String, dynamic> bundle) {
  try {
    List<int>.from(bundle['identityKey'] as List);
    (bundle['registrationId'] as num).toInt();
    (bundle['preKeyId'] as num).toInt();
    List<int>.from(bundle['preKeyPublic'] as List);
    (bundle['signedPreKeyId'] as num).toInt();
    List<int>.from(bundle['signedPreKeyPublic'] as List);
    List<int>.from(bundle['signedPreKeySignature'] as List);
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  // ── E2EE envelope parsing (wire format) ──────────────────────────────────
  //
  // The E2EE envelope "E2EE||<type>||<base64>" is the wire format for all
  // Signal protocol messages.  Correct parsing is critical: an off-by-one in
  // the split or an unguarded cast causes silent decryption failures.

  group('Signal E2EE envelope format', () {
    test('parses a valid prekey message envelope (type 3)', () {
      final payload = base64Encode(Uint8List.fromList([1, 2, 3, 4]));
      final envelope = 'E2EE||3||$payload';
      expect(_parseEnvelopeType(envelope), equals('3'));
      expect(_parseEnvelopePayload(envelope), equals([1, 2, 3, 4]));
    });

    test('parses a valid whisper message envelope (type 1)', () {
      final payload = base64Encode(Uint8List.fromList([0xAA, 0xBB]));
      final envelope = 'E2EE||1||$payload';
      expect(_parseEnvelopeType(envelope), equals('1'));
      expect(_parseEnvelopePayload(envelope), equals([0xAA, 0xBB]));
    });

    test('round-trip: base64 payload bytes are recovered exactly', () {
      final originalBytes = Uint8List.fromList(
          List.generate(64, (i) => (i * 37 + 13) & 0xFF));
      final envelope = 'E2EE||3||${base64Encode(originalBytes)}';
      expect(_parseEnvelopePayload(envelope), equals(originalBytes));
    });

    test('non-E2EE message → parseEnvelopeType returns null', () {
      expect(_parseEnvelopeType('plain text message'), isNull);
    });

    test('non-E2EE message → parseEnvelopePayload returns null', () {
      expect(_parseEnvelopePayload('not an envelope'), isNull);
    });

    test('malformed envelope (2 parts) → null type', () {
      expect(_parseEnvelopeType('E2EE||3'), isNull);
    });

    test('malformed envelope (4 parts) → null type', () {
      expect(_parseEnvelopeType('E2EE||3||AAAA||extra'), isNull);
    });

    test('invalid base64 in payload slot → null payload', () {
      final envelope = 'E2EE||3||!!!notbase64!!!';
      expect(_parseEnvelopePayload(envelope), isNull);
    });

    test('empty payload slot → empty byte array', () {
      // base64 of empty bytes = ""
      final envelope = 'E2EE||1||';
      final payload = _parseEnvelopePayload(envelope);
      expect(payload, equals(Uint8List(0)));
    });

    test('type field is a string (not yet parsed to int at this layer)', () {
      final envelope = 'E2EE||3||AAAA';
      expect(_parseEnvelopeType(envelope), isA<String>());
    });

    test('PQC2 prefix is not an E2EE envelope', () {
      final envelope = 'PQC2||AAAA||BBBB||CCCC';
      expect(_parseEnvelopeType(envelope), isNull);
    });
  });

  // ── decryptMessage passthrough ────────────────────────────────────────────
  //
  // Messages that do not start with "E2EE||" must be returned verbatim by
  // decryptMessage.  This is critical for backward compatibility with legacy
  // or plaintext transports.

  group('Signal decryptMessage passthrough', () {
    test('plain text is returned unchanged', () {
      const msg = 'hello world';
      expect(_decryptPassthrough(msg), equals(msg));
    });

    test('PQC2 envelope (not yet unwrapped) passes through', () {
      const msg = 'PQC2||AAA||BBB||CCC';
      expect(_decryptPassthrough(msg), equals(msg));
    });

    test('empty string passes through', () {
      expect(_decryptPassthrough(''), equals(''));
    });

    test('almost-E2EE prefix is not decrypted ("E2EE|" with single bar)', () {
      const msg = 'E2EE|3|AAAA';
      expect(_decryptPassthrough(msg), equals(msg));
    });

    test('lowercase "e2ee||" does not trigger decryption (case-sensitive)', () {
      const msg = 'e2ee||3||AAAA';
      expect(_decryptPassthrough(msg), equals(msg));
    });

    test('unicode plain text passes through unchanged', () {
      const msg = 'Привет мир 🌍';
      expect(_decryptPassthrough(msg), equals(msg));
    });
  });

  // ── Signal bundle field validation ────────────────────────────────────────
  //
  // buildSession requires exactly these 7 fields with the listed types.
  // A missing or mis-typed field triggers FormatException (documented in
  // signal_service.dart line 418: '[Signal] Malformed key bundle from …').
  // This is a critical security boundary: accepting a malformed bundle could
  // cause a session to be built against the wrong identity key.

  group('Signal bundle field validation', () {
    Map<String, dynamic> validBundle() => {
      'identityKey': [1, 2, 3, 4, 5],
      'registrationId': 12345,
      'preKeyId': 1,
      'preKeyPublic': [10, 20, 30],
      'signedPreKeyId': 0,
      'signedPreKeyPublic': [40, 50, 60],
      'signedPreKeySignature': [70, 80, 90],
    };

    test('complete and correctly typed bundle is valid', () {
      expect(_bundleIsValid(validBundle()), isTrue);
    });

    test('missing identityKey is invalid', () {
      final b = validBundle()..remove('identityKey');
      expect(_bundleIsValid(b), isFalse);
    });

    test('missing registrationId is invalid', () {
      final b = validBundle()..remove('registrationId');
      expect(_bundleIsValid(b), isFalse);
    });

    test('missing preKeyId is invalid', () {
      final b = validBundle()..remove('preKeyId');
      expect(_bundleIsValid(b), isFalse);
    });

    test('missing preKeyPublic is invalid', () {
      final b = validBundle()..remove('preKeyPublic');
      expect(_bundleIsValid(b), isFalse);
    });

    test('missing signedPreKeyId is invalid', () {
      final b = validBundle()..remove('signedPreKeyId');
      expect(_bundleIsValid(b), isFalse);
    });

    test('missing signedPreKeyPublic is invalid', () {
      final b = validBundle()..remove('signedPreKeyPublic');
      expect(_bundleIsValid(b), isFalse);
    });

    test('missing signedPreKeySignature is invalid', () {
      final b = validBundle()..remove('signedPreKeySignature');
      expect(_bundleIsValid(b), isFalse);
    });

    test('identityKey as string instead of List is invalid', () {
      final b = validBundle()..['identityKey'] = 'not-a-list';
      expect(_bundleIsValid(b), isFalse);
    });

    test('registrationId as string instead of num is invalid', () {
      final b = validBundle()..['registrationId'] = 'not-a-number';
      expect(_bundleIsValid(b), isFalse);
    });

    test('null value for any required field is invalid', () {
      final b = validBundle()..['preKeyPublic'] = null;
      expect(_bundleIsValid(b), isFalse);
    });

    test('empty bundle is invalid', () {
      expect(_bundleIsValid(<String, dynamic>{}), isFalse);
    });

    test('registrationId as double is still valid (num.toInt() succeeds)', () {
      final b = validBundle()..['registrationId'] = 12345.0;
      expect(_bundleIsValid(b), isTrue);
    });

    test('all list fields accept empty lists without throwing', () {
      // An empty list is syntactically valid (structural parse succeeds).
      // Semantic validation happens deeper in libsignal.
      final b = validBundle()
        ..['identityKey'] = <int>[]
        ..['preKeyPublic'] = <int>[]
        ..['signedPreKeyPublic'] = <int>[]
        ..['signedPreKeySignature'] = <int>[];
      expect(_bundleIsValid(b), isTrue);
    });
  });

  // ── Prekey exhaustion tracking logic (pure) ───────────────────────────────
  //
  // The exhaustion tracking in _trackExhaustionEvent filters events by a
  // 24h window and emits a security warning when >= 3 exhaustions occur.
  // Rapid exhaustion is a sign of a replay-attack or contact spoofing.
  // We mirror the pure filtering logic to test it in isolation.

  group('Signal prekey exhaustion window filtering', () {
    const exhaustionWindow = Duration(hours: 24);
    const exhaustionThreshold = 3;

    List<DateTime> filterRecent(List<DateTime> events, DateTime now) {
      final cutoff = now.subtract(exhaustionWindow);
      return events.where((t) => t.isAfter(cutoff)).toList();
    }

    test('events within 24h are kept', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final events = [
        now.subtract(const Duration(hours: 1)),
        now.subtract(const Duration(hours: 12)),
        now.subtract(const Duration(hours: 23, minutes: 59)),
      ];
      final recent = filterRecent(events, now);
      expect(recent.length, equals(3));
    });

    test('event exactly at 24h boundary is excluded (isAfter, not isAtOrAfter)', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final exactly24hAgo = now.subtract(exhaustionWindow);
      final recent = filterRecent([exactly24hAgo], now);
      expect(recent, isEmpty);
    });

    test('events older than 24h are filtered out', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final old = now.subtract(const Duration(hours: 25));
      final recent = filterRecent([old], now);
      expect(recent, isEmpty);
    });

    test('warning threshold is reached at exactly 3 events', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final events = List.generate(3, (i) => now.subtract(Duration(hours: i)));
      final recent = filterRecent(events, now);
      expect(recent.length >= exhaustionThreshold, isTrue);
    });

    test('2 events in window does not meet threshold', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final events = [
        now.subtract(const Duration(hours: 1)),
        now.subtract(const Duration(hours: 2)),
      ];
      final recent = filterRecent(events, now);
      expect(recent.length >= exhaustionThreshold, isFalse);
    });

    test('mix of old and recent: only recent count toward threshold', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final events = [
        now.subtract(const Duration(hours: 1)),  // recent
        now.subtract(const Duration(hours: 48)), // old
        now.subtract(const Duration(hours: 72)), // old
      ];
      final recent = filterRecent(events, now);
      expect(recent.length, equals(1));
      expect(recent.length >= exhaustionThreshold, isFalse);
    });

    test('empty event list never triggers warning', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final recent = filterRecent([], now);
      expect(recent.length >= exhaustionThreshold, isFalse);
    });

    test('100 events all within window all count', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final events =
          List.generate(100, (i) => now.subtract(Duration(minutes: i)));
      final recent = filterRecent(events, now);
      expect(recent.length, equals(100));
      expect(recent.length >= exhaustionThreshold, isTrue);
    });
  });
}
