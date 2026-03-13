import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages Oxen/Session cryptographic identity.
///
/// A single 32-byte random seed derives two keypairs:
///   Ed25519  — for retrieve-request authentication
///   X25519   — for Session ID derivation
///
/// Session ID = "05" + hex(X25519 public key)  [66 hex chars]
class OxenKeyService {
  static final instance = OxenKeyService._();
  OxenKeyService._();

  static const _storage = FlutterSecureStorage();
  static const _seedKey = 'oxen_seed';

  String _sessionId = '';
  List<int> _seed = [];

  bool get isInitialized => _sessionId.isNotEmpty;

  /// Call once at app start (idempotent).
  Future<void> initialize() async {
    if (_sessionId.isNotEmpty) return;

    var seedHex = await _storage.read(key: _seedKey);
    if (seedHex == null || seedHex.length != 64) {
      final rng = Random.secure();
      final bytes = Uint8List(32);
      for (var i = 0; i < 32; i++) { bytes[i] = rng.nextInt(256); }
      seedHex = hex.encode(bytes);
      await _storage.write(key: _seedKey, value: seedHex);
    }
    _seed = hex.decode(seedHex);

    // Derive Session ID from X25519 public key
    final x25519 = X25519();
    final xKp = await x25519.newKeyPairFromSeed(_seed);
    final xPub = await xKp.extractPublicKey();
    _sessionId = '05${hex.encode(xPub.bytes)}';
  }

  /// Own Session ID — "05" + 32-byte X25519 public key in hex (66 chars).
  String get sessionId => _sessionId;

  /// Ed25519-sign [message] with the identity key derived from the seed.
  Future<List<int>> sign(List<int> message) async {
    final ed25519 = Ed25519();
    final kp = await ed25519.newKeyPairFromSeed(_seed);
    final sig = await ed25519.sign(message, keyPair: kp);
    return sig.bytes;
  }
}
