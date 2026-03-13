import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pqcrypto/pqcrypto.dart';

/// Manages the local Kyber-1024 keypair used for the PQC hybrid encryption layer.
///
/// The public key is included in the Signal bundle so contacts can encapsulate
/// a shared secret (per-message) when sending us messages.
///
/// Keys are generated once and persisted in flutter_secure_storage so they
/// survive restarts without invalidating published bundles.
class PqcService {
  static final PqcService _instance = PqcService._internal();
  factory PqcService() => _instance;
  PqcService._internal();

  static final _kem = PqcKem.kyber1024;
  static const _storage = FlutterSecureStorage();

  Uint8List? _pk;
  Uint8List? _sk;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Load or generate the Kyber-1024 keypair.
  Future<void> initialize() async {
    if (_initialized) return;
    final pkB64 = await _storage.read(key: 'pqc_kyber_pk');
    final skB64 = await _storage.read(key: 'pqc_kyber_sk');
    if (pkB64 != null && skB64 != null) {
      _pk = base64Decode(pkB64);
      _sk = base64Decode(skB64);
    } else {
      final (pk, sk) = _kem.generateKeyPair();
      _pk = Uint8List.fromList(pk);
      _sk = Uint8List.fromList(sk);
      await _storage.write(key: 'pqc_kyber_pk', value: base64Encode(_pk!));
      await _storage.write(key: 'pqc_kyber_sk', value: base64Encode(_sk!));
    }
    _initialized = true;
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
    final (ct, ss) = _kem.encapsulate(remotePk);
    return (Uint8List.fromList(ct), Uint8List.fromList(ss));
  }

  /// Decapsulate an incoming Kyber ciphertext → 32-byte shared secret.
  Uint8List decapsulate(Uint8List ciphertext) {
    if (!_initialized) throw StateError('PqcService not initialized');
    final ss = _kem.decapsulate(_sk!, ciphertext);
    return Uint8List.fromList(ss);
  }
}
