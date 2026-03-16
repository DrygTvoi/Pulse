import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────
// Persistent Signal Protocol store backed by flutter_secure_storage.
// Sessions AND prekeys are persisted so they survive app restarts
// without regeneration (which would invalidate published bundles).
// ─────────────────────────────────────────────────────────────────
class _PersistentSignalStore extends InMemorySignalProtocolStore {
  final FlutterSecureStorage _storage;
  static const _sessionPrefix = 'signal_session_';
  static const _preKeyPrefix  = 'signal_prekey_';

  /// Called when any preKey is consumed (first message from a new contact).
  /// ChatController hooks this to republish the bundle with the next available preKey.
  VoidCallback? onPreKeyConsumed;

  _PersistentSignalStore(
    super.identityKeyPair,
    super.registrationId,
    this._storage,
  );

  // ── Sessions ────────────────────────────────────────────────────

  Future<void> restoreSessions() async {
    try {
      final all = await _storage.readAll();
      for (final entry in all.entries) {
        if (!entry.key.startsWith(_sessionPrefix)) continue;
        try {
          final withoutPrefix = entry.key.substring(_sessionPrefix.length);
          final lastUnderscore = withoutPrefix.lastIndexOf('_');
          if (lastUnderscore < 0) continue;
          final name = withoutPrefix.substring(0, lastUnderscore);
          final deviceId = int.parse(withoutPrefix.substring(lastUnderscore + 1));
          final address = SignalProtocolAddress(name, deviceId);
          final record = SessionRecord.fromSerialized(base64Decode(entry.value));
          await super.storeSession(address, record);
        } catch (_) {}
      }
    } catch (_) {}
  }

  @override
  Future<void> storeSession(SignalProtocolAddress address, SessionRecord record) async {
    await super.storeSession(address, record);
    final key = '$_sessionPrefix${address.getName()}_${address.getDeviceId()}';
    await _storage.write(key: key, value: base64Encode(record.serialize()));
  }

  @override
  Future<void> deleteSession(SignalProtocolAddress address) async {
    await super.deleteSession(address);
    await _storage.delete(key: '$_sessionPrefix${address.getName()}_${address.getDeviceId()}');
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    await super.deleteAllSessions(name);
    final all = await _storage.readAll();
    // Key format: signal_session_<name>_<deviceId (int)>
    // Use startsWith + int-parse to avoid false positives when one contact
    // name is a suffix of another (e.g. "abc" matching "xyz_abc_1").
    final expectedPrefix = '$_sessionPrefix${name}_';
    for (final k in all.keys) {
      if (!k.startsWith(expectedPrefix)) continue;
      final suffix = k.substring(expectedPrefix.length);
      if (int.tryParse(suffix) != null) {
        await _storage.delete(key: k);
      }
    }
  }

  // ── PreKeys — persisted so bundle stays valid across restarts ───

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) async {
    await super.storePreKey(preKeyId, record);
    // Persist as JSON {id, pub, priv} so it survives restarts.
    final kp = record.getKeyPair();
    await _storage.write(
      key: '$_preKeyPrefix$preKeyId',
      value: jsonEncode({
        'id': preKeyId,
        'pub': base64Encode(kp.publicKey.serialize()),
        'priv': base64Encode(kp.privateKey.serialize()),
      }),
    );
  }

  @override
  Future<void> removePreKey(int preKeyId) async {
    await super.removePreKey(preKeyId);
    await _storage.delete(key: '$_preKeyPrefix$preKeyId');
    onPreKeyConsumed?.call(); // trigger bundle republish in ChatController
  }

  /// Re-hydrate persisted prekeys after a restart.
  Future<void> restorePreKeys() async {
    try {
      final all = await _storage.readAll();
      for (final entry in all.entries) {
        if (!entry.key.startsWith(_preKeyPrefix)) continue;
        try {
          final map = jsonDecode(entry.value) as Map<String, dynamic>;
          final id = map['id'] as int;
          final pubBytes = base64Decode(map['pub'] as String);
          final privBytes = base64Decode(map['priv'] as String);
          final keyPair = ECKeyPair(
            Curve.decodePoint(Uint8List.fromList(pubBytes), 0),
            Curve.decodePrivatePoint(Uint8List.fromList(privBytes)),
          );
          final record = PreKeyRecord(id, keyPair);
          await super.storePreKey(id, record);
        } catch (_) {}
      }
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────

class SignalService {
  static final SignalService _instance = SignalService._internal();
  factory SignalService() => _instance;
  SignalService._internal();

  final _storage = const FlutterSecureStorage();
  late IdentityKeyPair _identityKeyPair;
  late int _registrationId;
  late _PersistentSignalStore _store;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  VoidCallback? _onPreKeyConsumed;
  /// Set by ChatController to republish the Signal bundle when a preKey is consumed.
  set onPreKeyConsumed(VoidCallback? cb) {
    _onPreKeyConsumed = cb;
    if (_isInitialized) _store.onPreKeyConsumed = cb;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final idKeyBase64 = await _storage.read(key: 'signal_id_key');
    final regIdStr = await _storage.read(key: 'signal_reg_id');

    if (idKeyBase64 != null && regIdStr != null) {
      final keyBytes = base64Decode(idKeyBase64);
      _identityKeyPair = IdentityKeyPair.fromSerialized(keyBytes);
      _registrationId = int.parse(regIdStr);
    } else {
      _identityKeyPair = generateIdentityKeyPair();
      _registrationId = generateRegistrationId(false);
      await _storage.write(
        key: 'signal_id_key',
        value: base64Encode(_identityKeyPair.serialize()),
      );
      await _storage.write(
        key: 'signal_reg_id',
        value: _registrationId.toString(),
      );
    }

    _store = _PersistentSignalStore(_identityKeyPair, _registrationId, _storage);
    await _store.restoreSessions();

    // PreKeys: first run generates and persists; subsequent runs restore from storage.
    final preKeyCheck = await _storage.read(key: 'signal_prekeys_generated');
    if (preKeyCheck == null) {
      final preKeys = generatePreKeys(0, 100);
      for (final pk in preKeys) {
        await _store.storePreKey(pk.id, pk); // also persists via override
      }
      await _storage.write(key: 'signal_prekeys_generated', value: '1');
    } else {
      // Restore the same prekeys from storage — avoids invalidating published bundles.
      await _store.restorePreKeys();
    }

    final signedPreKeyB64 = await _storage.read(key: 'signal_signed_prekey_0');
    if (signedPreKeyB64 != null) {
      final spk = SignedPreKeyRecord.fromSerialized(base64Decode(signedPreKeyB64));
      await _store.storeSignedPreKey(spk.id, spk);
    } else {
      final signedPreKey = generateSignedPreKey(_identityKeyPair, 0);
      await _store.storeSignedPreKey(signedPreKey.id, signedPreKey);
      await _storage.write(
        key: 'signal_signed_prekey_0',
        value: base64Encode(signedPreKey.serialize()),
      );
    }

    _store.onPreKeyConsumed = _onPreKeyConsumed;
    _isInitialized = true;
  }

  // ── Fingerprint ────────────────────────────────────────────────

  /// Own Signal identity fingerprint (first 10 bytes of public key, hex-colon-separated).
  String get ownFingerprint {
    if (!_isInitialized) return '';
    final bytes = _identityKeyPair.getPublicKey().serialize();
    return _formatFingerprint(bytes);
  }

  /// Contact's Signal identity fingerprint, stored when session was built.
  /// Returns null if no session has been established with this contact.
  Future<String?> getContactFingerprint(String remoteId) async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('signal_contact_idkey_$remoteId');
    if (b64 == null) return null;
    return _formatFingerprint(base64Decode(b64));
  }

  String _formatFingerprint(Uint8List bytes) {
    // Skip leading prefix byte (0x05 for DJB), take 10 bytes, format as HEX:HEX:...
    final start = bytes.length > 10 ? 1 : 0;
    final take = ((bytes.length - start).clamp(0, 10));
    return List.generate(take, (i) => bytes[start + i].toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  // ── Public bundle ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getPublicBundle() async {
    final signedPreKey = await _store.loadSignedPreKey(0);

    // Find the first still-available preKey (ID 0..99).
    // When preKey 0 is consumed, we advance to 1, then 2, etc.
    PreKeyRecord? preKey;
    for (int id = 0; id < 100; id++) {
      if (await _store.containsPreKey(id)) {
        preKey = await _store.loadPreKey(id);
        break;
      }
    }
    // All 100 consumed — regenerate a fresh batch.
    if (preKey == null) {
      final newKeys = generatePreKeys(0, 100);
      for (final pk in newKeys) { await _store.storePreKey(pk.id, pk); }
      preKey = newKeys.first;
    }

    return {
      'identityKey': _identityKeyPair.getPublicKey().serialize().toList(),
      'registrationId': _registrationId,
      'signedPreKeyId': signedPreKey.id,
      'signedPreKeyPublic': signedPreKey.getKeyPair().publicKey.serialize().toList(),
      'signedPreKeySignature': signedPreKey.signature.toList(),
      'preKeyId': preKey.id,
      'preKeyPublic': preKey.getKeyPair().publicKey.serialize().toList(),
    };
  }

  // ── Session management ─────────────────────────────────────────

  /// Builds a Signal session with a contact using their published public bundle.
  /// Returns true if the contact's identity key changed since the last session —
  /// caller should warn the user (possible reinstall or MITM).
  Future<bool> buildSession(String remoteId, Map<String, dynamic> bundle) async {
    final remoteAddress = SignalProtocolAddress(remoteId, 1);

    final idKeyBytes = Uint8List.fromList(List<int>.from(bundle['identityKey']));
    final identityKey = IdentityKey(Curve.decodePoint(idKeyBytes, 0));

    // Detect key change vs previously stored identity key.
    final prefs = await SharedPreferences.getInstance();
    final storageKey = 'signal_contact_idkey_$remoteId';
    final storedB64 = prefs.getString(storageKey);
    final newB64 = base64Encode(idKeyBytes);
    final keyChanged = storedB64 != null && storedB64 != newB64;

    final preKeyBundle = PreKeyBundle(
      bundle['registrationId'] as int,
      1,
      bundle['preKeyId'] as int,
      Curve.decodePoint(Uint8List.fromList(List<int>.from(bundle['preKeyPublic'])), 0),
      bundle['signedPreKeyId'] as int,
      Curve.decodePoint(Uint8List.fromList(List<int>.from(bundle['signedPreKeyPublic'])), 0),
      Uint8List.fromList(List<int>.from(bundle['signedPreKeySignature'])),
      identityKey,
    );

    final sessionBuilder = SessionBuilder(_store, _store, _store, _store, remoteAddress);
    await sessionBuilder.processPreKeyBundle(preKeyBundle);

    // Persist updated identity key for fingerprint display and TOFU tracking.
    try {
      await prefs.setString(storageKey, newB64);
    } catch (e) {
      debugPrint('[Signal] Failed to persist identity key for $remoteId: $e');
    }

    return keyChanged;
  }

  Future<String> encryptMessage(String remoteId, String plaintext) async {
    final remoteAddress = SignalProtocolAddress(remoteId, 1);
    final cipher = SessionCipher(_store, _store, _store, _store, remoteAddress);
    final ciphertext = await cipher.encrypt(Uint8List.fromList(utf8.encode(plaintext)));
    return 'E2EE||${ciphertext.getType()}||${base64Encode(ciphertext.serialize())}';
  }

  Future<String> decryptMessage(String remoteId, String envelope) async {
    if (!envelope.startsWith('E2EE||')) return envelope;

    final parts = envelope.split('||');
    final type = int.parse(parts[1]);
    final bytes = base64Decode(parts[2]);

    final remoteAddress = SignalProtocolAddress(remoteId, 1);
    final cipher = SessionCipher(_store, _store, _store, _store, remoteAddress);

    Uint8List plaintext;
    if (type == CiphertextMessage.prekeyType) {
      plaintext = await cipher.decrypt(PreKeySignalMessage(bytes));
    } else if (type == CiphertextMessage.whisperType) {
      plaintext = await cipher.decryptFromSignal(SignalMessage.fromSerialized(bytes));
    } else {
      throw Exception('Unknown ciphertext type: $type');
    }
    return utf8.decode(plaintext);
  }
}
