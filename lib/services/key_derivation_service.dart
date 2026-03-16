import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

// ── Argon2id parameters ───────────────────────────────────────────────────────
//
// OWASP 2024 high-security profile: m=64 MiB, t=3, p=1.
// Memory-hard: requires 64 MB RAM per guess — makes GPU/ASIC brute-force
// ~1000× more expensive than PBKDF2 and impractical even with Grover's
// quantum speedup (Grover only helps on hash iterations, not memory bandwidth).
//
// DartArgon2id spawns its own worker isolate — UI stays responsive.
final _argon2 = DartArgon2id(
  parallelism: 1,
  memory:      65536, // 64 MiB
  iterations:  3,
  hashLength:  32,
);

// Fixed domain salts — same on every device so the same recovery password
// always produces the same keys (brain-wallet pattern).
// The salt is NOT secret; the password is the only secret.
final _kNostrSalt = utf8.encode('pulse_nostr_key_v1');
final _kOxenSalt  = utf8.encode('pulse_oxen_seed_v1');

/// Derives deterministic cryptographic keys from a recovery password.
///
/// Argon2id (memory-hard) with 64 MiB / 3 iterations:
///   - Same password + same salt → same 32-byte key on any device.
///   - Runs in an internal worker isolate; non-blocking on the UI thread.
class KeyDerivationService {
  KeyDerivationService._();

  /// 32-byte Nostr private key derived from [password].
  static Future<Uint8List> deriveNostrKey(String password) async {
    final sk = await _argon2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: _kNostrSalt,
    );
    return Uint8List.fromList(await sk.extractBytes());
  }

  /// 32-byte Oxen/Session seed derived from [password].
  static Future<Uint8List> deriveOxenSeed(String password) async {
    final sk = await _argon2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: _kOxenSalt,
    );
    return Uint8List.fromList(await sk.extractBytes());
  }
}
