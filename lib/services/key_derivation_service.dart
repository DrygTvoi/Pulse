import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

// ── Argon2id parameters ───────────────────────────────────────────────────────
//
// OWASP 2024 high-security profile: m=64 MiB, t=3, p=1.
// Memory-hard: requires 64 MB RAM per guess — makes GPU/ASIC brute-force
// ~1000× more expensive than PBKDF2 and impractical even with Grover's
// quantum speedup (Grover only helps on hash iterations, not memory bandwidth).
//
// DartArgon2id is the pure-Dart fallback; it claims worker-isolate but in
// practice runs on the calling isolate. We wrap each derive call in
// `compute()` to keep the UI responsive (5-15 s of pure CPU otherwise).

class _Argon2Args {
  final List<int> password;
  final List<int> salt;
  const _Argon2Args(this.password, this.salt);
}

Future<Uint8List> _argon2DeriveIsolate(_Argon2Args args) async {
  final argon = DartArgon2id(
    parallelism: 1,
    memory: 65536, // 64 MiB
    iterations: 3,
    hashLength: 32,
  );
  final sk = await argon.deriveKey(
    secretKey: SecretKey(args.password),
    nonce: args.salt,
  );
  return Uint8List.fromList(await sk.extractBytes());
}

// Fixed domain salts — same on every device so the same recovery password
// always produces the same keys (brain-wallet pattern).
// The salt is NOT secret; the password is the only secret.
final _kNostrSalt = utf8.encode('pulse_nostr_key_v1');
final _kSessionSalt = utf8.encode('pulse_oxen_seed_v1'); // salt value MUST NOT change — brain-wallet determinism
final _kPulseSalt = utf8.encode('pulse_server_key_v1');

/// Derives deterministic cryptographic keys from a recovery password.
///
/// Argon2id (memory-hard) with 64 MiB / 3 iterations:
///   - Same password + same salt → same 32-byte key on any device.
///   - Runs in an internal worker isolate; non-blocking on the UI thread.
class KeyDerivationService {
  KeyDerivationService._();

  /// 32-byte Nostr private key derived from [password].
  static Future<Uint8List> deriveNostrKey(String password) async {
    if (password.length < 16) {
      throw ArgumentError('Password must be at least 16 characters for secure key derivation');
    }
    return compute(
        _argon2DeriveIsolate, _Argon2Args(utf8.encode(password), _kNostrSalt));
  }

  /// 32-byte Session Network seed derived from [password].
  static Future<Uint8List> deriveSessionSeed(String password) async {
    if (password.length < 16) {
      throw ArgumentError('Password must be at least 16 characters for secure key derivation');
    }
    return compute(_argon2DeriveIsolate,
        _Argon2Args(utf8.encode(password), _kSessionSalt));
  }

  /// 32-byte Ed25519 seed derived from [password] for Pulse server auth.
  static Future<Uint8List> derivePulseKey(String password) async {
    if (password.length < 16) {
      throw ArgumentError('Password must be at least 16 characters');
    }
    return compute(_argon2DeriveIsolate,
        _Argon2Args(utf8.encode(password), _kPulseSalt));
  }
}
