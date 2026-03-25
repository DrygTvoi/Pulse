import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pqcrypto/pqcrypto.dart';

/// Manages the local Kyber-1024 keypair used for the PQC hybrid encryption layer.
///
/// The public key is included in the Signal bundle so contacts can encapsulate
/// a shared secret (per-message) when sending us messages.
///
/// Keys are generated once and persisted in flutter_secure_storage so they
/// survive restarts without invalidating published bundles.
///
/// Rotation: the keypair is regenerated every 30 days to limit exposure of a
/// compromised secret key.  The previous secret key is retained for one extra
/// rotation period so in-flight messages using the old public key can still be
/// decrypted.
class PqcService {
  static PqcService _instance = PqcService._internal();
  factory PqcService() => _instance;
  PqcService._internal();

  /// Create a detached instance for unit testing (no singleton side-effects).
  @visibleForTesting
  factory PqcService.testInstance() => PqcService._internal();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(PqcService instance) =>
      _instance = instance;

  /// Inject key material directly for unit testing (skips storage + KEM).
  @visibleForTesting
  void setKeysForTesting({
    required Uint8List pk,
    required Uint8List sk,
    Uint8List? skPrev,
  }) {
    _pk = pk;
    _sk = sk;
    _skPrev = skPrev;
    _initialized = true;
  }

  static final _kem = PqcKem.kyber1024;
  static const _storage = FlutterSecureStorage();

  static const _kPk       = 'pqc_kyber_pk';
  static const _kSk       = 'pqc_kyber_sk';
  static const _kPkPrev   = 'pqc_kyber_pk_prev';
  static const _kSkPrev   = 'pqc_kyber_sk_prev';
  static const _kRotationTs = 'pqc_kyber_rotation_ts';
  static const _kRotationDays = 30;

  Uint8List? _pk;
  Uint8List? _sk;
  Uint8List? _skPrev; // previous secret key kept for one rotation period
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Load or generate the Kyber-1024 keypair.
  Future<void> initialize() async {
    if (_initialized) return;
    final pkB64 = await _storage.read(key: _kPk);
    final skB64 = await _storage.read(key: _kSk);
    if (pkB64 != null && skB64 != null) {
      _pk = base64Decode(pkB64);
      _sk = base64Decode(skB64);
    } else {
      await _generateNewKeypair(isFirst: true);
    }
    // Load previous sk if present (for decapsulating in-flight messages).
    final skPrevB64 = await _storage.read(key: _kSkPrev);
    if (skPrevB64 != null) {
      _skPrev = base64Decode(skPrevB64);
    }
    _initialized = true;
    // Rotate if due.
    await rotateIfNeeded();
  }

  /// Our Kyber-1024 public key — included in the Signal bundle we publish.
  Uint8List get publicKey {
    if (!_initialized) throw StateError('PqcService not initialized');
    return _pk!;
  }

  /// Encapsulate to a remote public key.
  /// Returns (ciphertext, sharedSecret) — both 32–1568 bytes per ML-KEM-1024 spec.
  (Uint8List, Uint8List) encapsulate(Uint8List remotePk) {
    if (!_initialized) throw StateError('PqcService not initialized');
    if (remotePk.length != 1568) {
      throw ArgumentError('Invalid ML-KEM-1024 public key: expected 1568 bytes, got ${remotePk.length}');
    }
    final (ct, ss) = _kem.encapsulate(remotePk);
    return (Uint8List.fromList(ct), Uint8List.fromList(ss));
  }

  /// Decapsulate an incoming Kyber ciphertext → 32-byte shared secret.
  /// Tries the current sk first; falls back to the previous sk (grace period).
  Uint8List decapsulate(Uint8List ciphertext) {
    if (!_initialized) throw StateError('PqcService not initialized');
    try {
      final ss = _kem.decapsulate(_sk!, ciphertext);
      return Uint8List.fromList(ss);
    } catch (e) {
      debugPrint('[PQC] Current key decapsulation failed (key rotation in progress?): $e');
      if (_skPrev != null) {
        final ss = _kem.decapsulate(_skPrev!, ciphertext);
        return Uint8List.fromList(ss);
      }
      rethrow;
    }
  }

  // ── Rotation ────────────────────────────────────────────────────────────────

  Future<void> rotateIfNeeded() async {
    try {
      final tsStr = await _storage.read(key: _kRotationTs);
      if (tsStr != null) {
        final ts = DateTime.fromMillisecondsSinceEpoch(int.tryParse(tsStr) ?? 0);
        if (DateTime.now().difference(ts).inDays < _kRotationDays) return;
      }
      await _generateNewKeypair(isFirst: false);
    } catch (e) {
      // Non-fatal — keep existing keys.
    }
  }

  /// Zero out all key material from memory (call on logout/dispose).
  void zeroize() {
    if (_pk != null) { _pk!.fillRange(0, _pk!.length, 0); _pk = null; }
    if (_sk != null) { _sk!.fillRange(0, _sk!.length, 0); _sk = null; }
    if (_skPrev != null) { _skPrev!.fillRange(0, _skPrev!.length, 0); _skPrev = null; }
    _initialized = false;
  }

  Future<void> _generateNewKeypair({required bool isFirst}) async {
    if (!isFirst && _sk != null) {
      // Promote current → previous (one rotation grace period).
      _skPrev = _sk;
      await _storage.write(key: _kSkPrev, value: base64Encode(_sk!));
      if (_pk != null) {
        await _storage.write(key: _kPkPrev, value: base64Encode(_pk!));
      }
    }
    final (pk, sk) = _kem.generateKeyPair();
    _pk = Uint8List.fromList(pk);
    _sk = Uint8List.fromList(sk);
    await _storage.write(key: _kPk, value: base64Encode(_pk!));
    await _storage.write(key: _kSk, value: base64Encode(_sk!));
    await _storage.write(
        key: _kRotationTs,
        value: DateTime.now().millisecondsSinceEpoch.toString());
  }
}
