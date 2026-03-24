import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kIterations = 200000; // OWASP 2023 recommendation for PBKDF2-HMAC-SHA256
const _kKeyLength  = 32;     // 256-bit output
const _kPrefix     = 'pbkdf2v1:';

// ── Isolate entry point (must be top-level for compute()) ─────────────────────

/// Runs PBKDF2-HMAC-SHA256 in an isolate.
/// [params] = {'password': String, 'salt': String (hex)}
String _computePbkdf2(Map<String, String> params) {
  final salt     = Uint8List.fromList(hex.decode(params['salt']!));
  final password = Uint8List.fromList(utf8.encode(params['password']!));

  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  derivator.init(Pbkdf2Parameters(salt, _kIterations, _kKeyLength));
  final key = derivator.process(password);

  return '$_kPrefix${hex.encode(key)}';
}

// ── Public API ─────────────────────────────────────────────────────────────────

/// Secure password hashing with PBKDF2-HMAC-SHA256.
///
/// New hashes are prefixed `pbkdf2v1:` and computed in an isolate so the UI
/// thread is never blocked.  Legacy SHA-256 hashes (no prefix) are still
/// accepted for verification and transparently migrated on first successful
/// login.
class PasswordHasher {
  PasswordHasher._();

  /// Hash [password] with a hex-encoded [salt].
  /// Always returns a `pbkdf2v1:`-prefixed string.
  static Future<String> hash(String password, String salt) {
    return compute(_computePbkdf2, {'password': password, 'salt': salt});
  }

  /// Verify [entered] against [storedHash] (with [salt]).
  /// Handles both PBKDF2 (new) and legacy SHA-256 hashes transparently.
  /// Uses constant-time comparison to prevent timing side-channels.
  static Future<bool> verify(
      String entered, String salt, String storedHash) async {
    final String computed;
    if (storedHash.startsWith(_kPrefix)) {
      computed = await hash(entered, salt);
    } else {
      computed = _legacySha256(entered, salt);
    }
    return _constantTimeEquals(computed, storedHash);
  }

  /// Constant-time string comparison to prevent timing attacks.
  /// Always iterates through max(a.length, b.length) to avoid leaking
  /// information about the hash length or algorithm via response timing.
  static bool _constantTimeEquals(String a, String b) {
    final maxLen = a.length > b.length ? a.length : b.length;
    int result = a.length ^ b.length; // non-zero if lengths differ
    for (int i = 0; i < maxLen; i++) {
      final ca = i < a.length ? a.codeUnitAt(i) : 0;
      final cb = i < b.length ? b.codeUnitAt(i) : 0;
      result |= ca ^ cb;
    }
    return result == 0;
  }

  /// Returns true if [storedHash] was produced with the legacy SHA-256 scheme.
  /// Use this to trigger migration after a successful verify().
  static bool isLegacy(String storedHash) => !storedHash.startsWith(_kPrefix);

  // ── Internal ─────────────────────────────────────────────────────────────────

  /// Legacy: SHA-256(salt:password) — kept only for migration compatibility.
  static String _legacySha256(String password, String salt) {
    final combined = utf8.encode('$salt:$password');
    return crypto.sha256.convert(combined).toString();
  }
}
