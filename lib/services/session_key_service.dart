import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Convert Ed25519 public key → X25519 public key.
/// Equivalent to libsodium's crypto_sign_ed25519_pk_to_curve25519.
/// Formula: u = (1 + y) / (1 - y) mod p, where p = 2^255 - 19.
Uint8List _ed25519PkToX25519(List<int> edPk) {
  final p = BigInt.two.pow(255) - BigInt.from(19);

  // Decode y-coordinate (little-endian, clear top bit = sign of x).
  final yCopy = Uint8List.fromList(edPk);
  yCopy[31] &= 0x7F;
  BigInt y = BigInt.zero;
  for (var i = 31; i >= 0; i--) {
    y = (y << 8) | BigInt.from(yCopy[i]);
  }

  // Montgomery u = (1 + y) * modInverse(1 - y) mod p
  final num_ = (BigInt.one + y) % p;
  final den = (p + BigInt.one - y) % p; // (1 - y) mod p, avoid negative
  final u = (num_ * den.modPow(p - BigInt.two, p)) % p;

  // Encode as 32-byte little-endian.
  final result = Uint8List(32);
  var val = u;
  for (var i = 0; i < 32; i++) {
    result[i] = (val & BigInt.from(0xFF)).toInt();
    val >>= 8;
  }
  return result;
}

/// Manages Session Network cryptographic identity.
///
/// A single 32-byte random seed derives an Ed25519 keypair.
/// The X25519 public key (for Session ID) is converted from the Ed25519
/// public key, matching libsodium's crypto_sign_ed25519_pk_to_curve25519.
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

    // Ed25519 keypair — master identity
    final ed25519 = Ed25519();
    final edKp = await ed25519.newKeyPairFromSeed(_seed);
    final edPub = await edKp.extractPublicKey();
    _ed25519PublicKeyHex = hex.encode(edPub.bytes);

    // Session ID = "05" + X25519 pubkey converted FROM Ed25519 pubkey
    // (matches libsodium crypto_sign_ed25519_pk_to_curve25519)
    final x25519Pub = _ed25519PkToX25519(edPub.bytes);
    _sessionId = '05${hex.encode(x25519Pub)}';
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
