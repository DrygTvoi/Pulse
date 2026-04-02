import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/key_derivation_service.dart';

// KeyDerivationService uses DartArgon2id from the `cryptography` package.
// DartArgon2id is pure Dart — no platform channels, no file system, no
// SharedPreferences.  Every function is deterministic for the same inputs,
// so these tests act as regression guards for the brain-wallet derivation.
//
// NOTE: each test call runs Argon2id (64 MiB / 3 iterations) in an isolate,
// which takes a few seconds.  Keep the number of calls in this file minimal.
//
// All passwords must be >= 16 characters (enforced by service).

void main() {
  // ── Output length ─────────────────────────────────────────────────────────

  group('KeyDerivationService output length', () {
    test('deriveNostrKey returns exactly 32 bytes', () async {
      final key = await KeyDerivationService.deriveNostrKey('password12345678');
      expect(key.length, equals(32));
    });

    test('deriveOxenSeed returns exactly 32 bytes', () async {
      final key = await KeyDerivationService.deriveSessionSeed('password12345678');
      expect(key.length, equals(32));
    });
  });

  // ── Determinism ───────────────────────────────────────────────────────────
  //
  // Brain-wallet guarantee: the same password must always produce the same key
  // on any device so that account recovery works without storing the key.

  group('KeyDerivationService determinism', () {
    test('deriveNostrKey is deterministic for same password', () async {
      final k1 = await KeyDerivationService.deriveNostrKey('recovery phrase!1');
      final k2 = await KeyDerivationService.deriveNostrKey('recovery phrase!1');
      expect(k1, equals(k2));
    });

    test('deriveOxenSeed is deterministic for same password', () async {
      final k1 = await KeyDerivationService.deriveSessionSeed('recovery phrase!1');
      final k2 = await KeyDerivationService.deriveSessionSeed('recovery phrase!1');
      expect(k1, equals(k2));
    });
  });

  // ── Password sensitivity ──────────────────────────────────────────────────
  //
  // Different passwords must produce different keys — a collision here would
  // mean two users derive the same Nostr identity or Oxen wallet.

  group('KeyDerivationService password sensitivity', () {
    test('different passwords produce different Nostr keys', () async {
      final k1 = await KeyDerivationService.deriveNostrKey('password1_secure!');
      final k2 = await KeyDerivationService.deriveNostrKey('password2_secure!');
      expect(k1, isNot(equals(k2)));
    });

    test('different passwords produce different Oxen seeds', () async {
      final k1 = await KeyDerivationService.deriveSessionSeed('password1_secure!');
      final k2 = await KeyDerivationService.deriveSessionSeed('password2_secure!');
      expect(k1, isNot(equals(k2)));
    });

    test('single-character change produces a completely different Nostr key', () async {
      final k1 = await KeyDerivationService.deriveNostrKey('correcthorsebatterystaple');
      final k2 = await KeyDerivationService.deriveNostrKey('Correcthorsebatterystaple');
      expect(k1, isNot(equals(k2)));
    });
  });

  // ── Domain separation ─────────────────────────────────────────────────────
  //
  // The Nostr and Oxen derivations use different fixed salts ('pulse_nostr_key_v1'
  // vs 'pulse_oxen_seed_v1').  For the same password, the two outputs must
  // differ so an attacker who obtains one key cannot derive the other.

  group('KeyDerivationService domain separation', () {
    test('same password yields different Nostr key and Oxen seed', () async {
      final nostrKey = await KeyDerivationService.deriveNostrKey('shared-password!1');
      final sessionSeed = await KeyDerivationService.deriveSessionSeed('shared-password!1');
      expect(nostrKey, isNot(equals(sessionSeed)));
    });
  });

  // ── Output is not trivial ─────────────────────────────────────────────────
  //
  // Argon2id must produce non-zero, non-trivially-repeating output.

  group('KeyDerivationService non-trivial output', () {
    test('Nostr key is not all-zero bytes', () async {
      final key = await KeyDerivationService.deriveNostrKey('any password!1234');
      expect(key.any((b) => b != 0), isTrue);
    });

    test('Oxen seed is not all-zero bytes', () async {
      final seed = await KeyDerivationService.deriveSessionSeed('any password!1234');
      expect(seed.any((b) => b != 0), isTrue);
    });

    test('Nostr key is not all-0xFF bytes', () async {
      final key = await KeyDerivationService.deriveNostrKey('any password!1234');
      expect(key.any((b) => b != 0xFF), isTrue);
    });
  });

  // ── Return type ───────────────────────────────────────────────────────────

  group('KeyDerivationService return type', () {
    test('deriveNostrKey returns Uint8List', () async {
      final key = await KeyDerivationService.deriveNostrKey('test_password_16!');
      expect(key, isA<Uint8List>());
    });

    test('deriveOxenSeed returns Uint8List', () async {
      final seed = await KeyDerivationService.deriveSessionSeed('test_password_16!');
      expect(seed, isA<Uint8List>());
    });
  });

  // ── Password validation ─────────────────────────────────────────────────

  group('KeyDerivationService password validation', () {
    test('deriveNostrKey rejects short password', () async {
      expect(
        () => KeyDerivationService.deriveNostrKey('short'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deriveOxenSeed rejects short password', () async {
      expect(
        () => KeyDerivationService.deriveSessionSeed('short'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
