import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages Session Network cryptographic identity.
///
/// A single 32-byte random seed derives two keypairs:
///   Ed25519  — for retrieve-request authentication (pubkey_ed25519 field)
///   X25519   — for Session ID derivation
///
/// Session ID = "05" + hex(X25519 public key)  [66 hex chars]
///
/// Migration: on first run checks for legacy 'oxen_seed' key and migrates it.
class SessionKeyService {
  static final instance = SessionKeyService._();
  SessionKeyService._();

  static const _storage = FlutterSecureStorage();
  static const _seedKey = 'session_seed';
  static const _legacySeedKey = 'oxen_seed'; // migration source

  String _sessionId = '';
  String _ed25519PublicKeyHex = '';
  List<int> _seed = [];

  bool get isInitialized => _sessionId.isNotEmpty;

  /// Call once at app start (idempotent).
  Future<void> initialize() async {
    if (_sessionId.isNotEmpty) return;

    // Try new key first, then migrate from legacy 'oxen_seed'
    var seedHex = await _storage.read(key: _seedKey);
    if (seedHex == null || seedHex.length != 64) {
      final legacySeed = await _storage.read(key: _legacySeedKey);
      if (legacySeed != null && legacySeed.length == 64) {
        seedHex = legacySeed;
        await _storage.write(key: _seedKey, value: seedHex);
        // Keep legacy key for backward compat during transition
      }
    }

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

    // Cache Ed25519 public key for Session Network retrieve auth
    final ed25519 = Ed25519();
    final edKp = await ed25519.newKeyPairFromSeed(_seed);
    final edPub = await edKp.extractPublicKey();
    _ed25519PublicKeyHex = hex.encode(edPub.bytes);
  }

  /// Own Session ID — "05" + 32-byte X25519 public key in hex (66 chars).
  String get sessionId => _sessionId;

  /// Ed25519 public key in hex — used as pubkey_ed25519 in retrieve requests.
  String get ed25519PublicKeyHex => _ed25519PublicKeyHex;

  /// Ed25519-sign [message] with the identity key derived from the seed.
  Future<List<int>> sign(List<int> message) async {
    final ed25519 = Ed25519();
    final kp = await ed25519.newKeyPairFromSeed(_seed);
    final sig = await ed25519.sign(message, keyPair: kp);
    return sig.bytes;
  }
}
