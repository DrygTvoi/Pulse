import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pqc_service.dart';
import 'sentry_service.dart';

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

  /// In-memory cache of all secure storage entries.
  /// Populated on first read, updated on writes/deletes.
  /// Avoids reading ALL 300+ keys from disk on every prefix scan.
  Map<String, String>? _secureStorageCache;

  /// Returns all entries from secure storage, using a cached copy after the
  /// first call. Subsequent calls are O(1) instead of a full disk read.
  Future<Map<String, String>> _getAllCached() async {
    if (_secureStorageCache != null) return _secureStorageCache!;
    _secureStorageCache = await _storage.readAll();
    return _secureStorageCache!;
  }

  /// Read only entries matching [prefix] from the cached secure storage.
  /// Avoids leaking unrelated secrets (nostr_privkey, oxen_seed, etc.) into callers.
  Future<Map<String, String>> _readByPrefix(String prefix) async {
    final all = await _getAllCached();
    final filtered = <String, String>{};
    for (final entry in all.entries) {
      if (entry.key.startsWith(prefix)) filtered[entry.key] = entry.value;
    }
    return filtered;
  }

  /// Write to secure storage and update the in-memory cache.
  Future<void> _secureWrite(String key, String value) async {
    await _storage.write(key: key, value: value);
    _secureStorageCache?[key] = value;
  }

  /// Delete from secure storage and update the in-memory cache.
  Future<void> _secureDelete(String key) async {
    await _storage.delete(key: key);
    _secureStorageCache?.remove(key);
  }

  _PersistentSignalStore(
    super.identityKeyPair,
    super.registrationId,
    this._storage,
  );

  // ── Sessions ────────────────────────────────────────────────────

  Future<void> restoreSessions() async {
    try {
      final all = await _readByPrefix(_sessionPrefix);
      for (final entry in all.entries) {
        try {
          final withoutPrefix = entry.key.substring(_sessionPrefix.length);
          final lastUnderscore = withoutPrefix.lastIndexOf('_');
          if (lastUnderscore < 0) continue;
          final name = withoutPrefix.substring(0, lastUnderscore);
          final deviceId = int.tryParse(withoutPrefix.substring(lastUnderscore + 1)) ?? 1;
          final address = SignalProtocolAddress(name, deviceId);
          final record = SessionRecord.fromSerialized(base64Decode(entry.value));
          await super.storeSession(address, record);
        } catch (e) {
          debugPrint('[Signal] Failed to restore session ${entry.key}: $e');
          sentryBreadcrumb('Session restore failed: ${entry.key}', category: 'signal');
        }
      }
    } catch (e) {
      debugPrint('[Signal] Failed to restore sessions: $e');
      sentryBreadcrumb('Session restore batch failed', category: 'signal');
    }
  }

  @override
  Future<void> storeSession(SignalProtocolAddress address, SessionRecord record) async {
    await super.storeSession(address, record);
    final key = '$_sessionPrefix${address.getName()}_${address.getDeviceId()}';
    await _secureWrite(key, base64Encode(record.serialize()));
  }

  @override
  Future<void> deleteSession(SignalProtocolAddress address) async {
    await super.deleteSession(address);
    await _secureDelete('$_sessionPrefix${address.getName()}_${address.getDeviceId()}');
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    await super.deleteAllSessions(name);
    final expectedPrefix = '$_sessionPrefix${name}_';
    final all = await _readByPrefix(expectedPrefix);
    for (final k in all.keys) {
      final suffix = k.substring(expectedPrefix.length);
      if (int.tryParse(suffix) != null) {
        await _secureDelete(k);
      }
    }
  }

  // ── PreKeys — persisted so bundle stays valid across restarts ───

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) async {
    await super.storePreKey(preKeyId, record);
    // Persist as JSON {id, pub, priv} so it survives restarts.
    final kp = record.getKeyPair();
    await _secureWrite(
      '$_preKeyPrefix$preKeyId',
      jsonEncode({
        'id': preKeyId,
        'pub': base64Encode(kp.publicKey.serialize()),
        'priv': base64Encode(kp.privateKey.serialize()),
      }),
    );
  }

  @override
  Future<void> removePreKey(int preKeyId) async {
    await super.removePreKey(preKeyId);
    await _secureDelete('$_preKeyPrefix$preKeyId');
    onPreKeyConsumed?.call(); // trigger bundle republish in ChatController
  }

  /// Re-hydrate persisted prekeys after a restart.
  Future<void> restorePreKeys() async {
    try {
      final all = await _readByPrefix(_preKeyPrefix);
      for (final entry in all.entries) {
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
        } catch (e) {
          debugPrint('[Signal] Failed to restore prekey ${entry.key}: $e');
          sentryBreadcrumb('PreKey restore failed: ${entry.key}', category: 'signal');
        }
      }
    } catch (e) {
      debugPrint('[Signal] Failed to restore prekeys: $e');
      sentryBreadcrumb('PreKey restore batch failed', category: 'signal');
    }
  }
}

// ─────────────────────────────────────────────────────────────────

class SignalService {
  static SignalService _instance = SignalService._internal();
  factory SignalService() => _instance;
  SignalService._internal();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(SignalService instance) =>
      _instance = instance;

  final _storage = const FlutterSecureStorage();
  late IdentityKeyPair _identityKeyPair;
  late int _registrationId;
  late _PersistentSignalStore _store;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Fires when all 100 prekeys are exhausted and a fresh batch is regenerated.
  /// ChatController subscribes to re-publish the updated bundle to all transports.
  final _bundleRefreshCtrl = StreamController<void>.broadcast();
  Stream<void> get onBundleRefresh => _bundleRefreshCtrl.stream;

  /// Fires when prekey exhaustion happens suspiciously often (>3× in 24h).
  /// ChatController can surface this as a security warning to the user.
  final _preKeyExhaustionWarnCtrl = StreamController<String>.broadcast();
  Stream<String> get onPreKeyExhaustionWarning => _preKeyExhaustionWarnCtrl.stream;

  static const _kExhaustionTsKey = 'signal_prekey_exhaustion_ts';
  static const _exhaustionWindow = Duration(hours: 24);
  static const _exhaustionThreshold = 3;

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
      _registrationId = int.tryParse(regIdStr) ?? generateRegistrationId(false);
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

    // Load the current signed prekey by its persisted ID (not hardcoded 0).
    // Hardcoding 0 caused InvalidKeyIdException after rotation when ID > 0.
    final currentIdStr = await _storage.read(key: _kSignedPreKeyIdKey);
    final currentSpkId = currentIdStr != null ? (int.tryParse(currentIdStr) ?? 0) : 0;
    final signedPreKeyB64 = await _storage.read(key: 'signal_signed_prekey_$currentSpkId');
    if (signedPreKeyB64 != null) {
      final spk = SignedPreKeyRecord.fromSerialized(base64Decode(signedPreKeyB64));
      await _store.storeSignedPreKey(spk.id, spk);
    } else {
      final signedPreKey = generateSignedPreKey(_identityKeyPair, currentSpkId);
      await _store.storeSignedPreKey(signedPreKey.id, signedPreKey);
      await _storage.write(
        key: 'signal_signed_prekey_$currentSpkId',
        value: base64Encode(signedPreKey.serialize()),
      );
      // Record creation timestamp for rotation tracking.
      await _storage.write(
        key: _kSignedPreKeyTsKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    _store.onPreKeyConsumed = _onPreKeyConsumed;
    _isInitialized = true;

    // Rotate signed prekey and PQC keypair if due.
    unawaited(_rotateSignedPreKeyIfNeeded());
    unawaited(PqcService().rotateIfNeeded());
  }

  static const _kSignedPreKeyRotationDays = 7;
  static const _kSignedPreKeyTsKey = 'signal_signed_prekey_ts';
  static const _kSignedPreKeyIdKey = 'signal_signed_prekey_current_id';

  Future<void> _rotateSignedPreKeyIfNeeded() async {
    try {
      final tsStr = await _storage.read(key: _kSignedPreKeyTsKey);
      if (tsStr != null) {
        final ts = DateTime.fromMillisecondsSinceEpoch(int.tryParse(tsStr) ?? 0);
        if (DateTime.now().difference(ts).inDays < _kSignedPreKeyRotationDays) {
          return; // not due for rotation
        }
      }
      // Get current ID and increment.
      final idStr = await _storage.read(key: _kSignedPreKeyIdKey);
      final currentId = idStr != null ? (int.tryParse(idStr) ?? 0) : 0;
      final newId = currentId + 1;

      final newSpk = generateSignedPreKey(_identityKeyPair, newId);
      await _store.storeSignedPreKey(newId, newSpk);
      await _storage.write(
        key: 'signal_signed_prekey_$newId',
        value: base64Encode(newSpk.serialize()),
      );
      await _storage.write(key: _kSignedPreKeyIdKey, value: newId.toString());
      await _storage.write(
        key: _kSignedPreKeyTsKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      debugPrint('[Signal] Rotated signed prekey: $currentId → $newId');

      // Keep old key for 2 rotation periods (grace for in-flight messages).
      final oldestKeep = newId - 2;
      for (int id = 0; id < oldestKeep; id++) {
        try {
          await _store.removeSignedPreKey(id);
          await _storage.delete(key: 'signal_signed_prekey_$id');
        } catch (e) {
          debugPrint('[Signal] Failed to remove old signed prekey $id: $e');
        }
      }

      // Trigger bundle republish so contacts get the new signed prekey.
      _bundleRefreshCtrl.add(null);
    } catch (e) {
      debugPrint('[Signal] Signed prekey rotation failed: $e');
    }
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

  /// Returns the raw base64 of the contact's stored identity key.
  /// Used by VerifyIdentityScreen to store a hash for auto-invalidation.
  Future<String?> getContactIdentityKeyB64(String remoteId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('signal_contact_idkey_$remoteId');
  }

  /// Own identity key as base64 (for verification hash).
  String get ownIdentityKeyB64 {
    if (!_isInitialized) return '';
    return base64Encode(_identityKeyPair.getPublicKey().serialize());
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
    final idStr = await _storage.read(key: _kSignedPreKeyIdKey);
    final spkId = idStr != null ? (int.tryParse(idStr) ?? 0) : 0;
    final signedPreKey = await _store.loadSignedPreKey(spkId);

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
      debugPrint('[Signal] All prekeys exhausted — regenerating fresh batch');
      final newKeys = generatePreKeys(0, 100);
      for (final pk in newKeys) { await _store.storePreKey(pk.id, pk); }
      preKey = newKeys.first;
      _bundleRefreshCtrl.add(null);
      unawaited(_trackExhaustionEvent());
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

  // ── Prekey exhaustion monitoring ────────────────────────────────

  /// Records a prekey exhaustion event and emits a warning if > [_exhaustionThreshold]
  /// events occurred within [_exhaustionWindow]. Possible signs of an active attack.
  Future<void> _trackExhaustionEvent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_kExhaustionTsKey) ?? [];
      final now = DateTime.now();
      final cutoff = now.subtract(_exhaustionWindow);
      // Keep only events within the window + add new one.
      final recent = stored
          .map((s) => DateTime.tryParse(s))
          .whereType<DateTime>()
          .where((t) => t.isAfter(cutoff))
          .toList()
        ..add(now);
      await prefs.setStringList(
          _kExhaustionTsKey, recent.map((t) => t.toIso8601String()).toList());
      if (recent.length >= _exhaustionThreshold) {
        debugPrint('[Signal] WARNING: prekey exhausted ${recent.length}× in 24h — possible attack');
        _preKeyExhaustionWarnCtrl.add(
            'Prekeys exhausted ${recent.length}× in 24h — possible replay attack');
      }
    } catch (e) {
      debugPrint('[Signal] Failed to track exhaustion event: $e');
    }
  }

  // ── Session management ─────────────────────────────────────────

  /// Builds a Signal session with a contact using their published public bundle.
  /// Returns true if the contact's identity key changed since the last session —
  /// caller should warn the user (possible reinstall or MITM).
  Future<bool> buildSession(String remoteId, Map<String, dynamic> bundle) async {
    final remoteAddress = SignalProtocolAddress(remoteId, 1);

    final Uint8List idKeyBytes;
    final IdentityKey identityKey;
    final PreKeyBundle preKeyBundle;
    try {
      idKeyBytes = Uint8List.fromList(List<int>.from(bundle['identityKey'] as List));
      identityKey = IdentityKey(Curve.decodePoint(idKeyBytes, 0));
      preKeyBundle = PreKeyBundle(
        (bundle['registrationId'] as num).toInt(),
        1,
        (bundle['preKeyId'] as num).toInt(),
        Curve.decodePoint(Uint8List.fromList(List<int>.from(bundle['preKeyPublic'] as List)), 0),
        (bundle['signedPreKeyId'] as num).toInt(),
        Curve.decodePoint(Uint8List.fromList(List<int>.from(bundle['signedPreKeyPublic'] as List)), 0),
        Uint8List.fromList(List<int>.from(bundle['signedPreKeySignature'] as List)),
        identityKey,
      );
    } catch (e) {
      throw FormatException('[Signal] Malformed key bundle from $remoteId: $e');
    }

    // Detect key change vs previously stored identity key.
    final prefs = await SharedPreferences.getInstance();
    final storageKey = 'signal_contact_idkey_$remoteId';
    final storedB64 = prefs.getString(storageKey);
    final newB64 = base64Encode(idKeyBytes);
    final keyChanged = storedB64 != null && storedB64 != newB64;

    final sessionBuilder = SessionBuilder(_store, _store, _store, _store, remoteAddress);
    await sessionBuilder.processPreKeyBundle(preKeyBundle);

    // Persist updated identity key for fingerprint display and TOFU tracking.
    try {
      await prefs.setString(storageKey, newB64);
      // Invalidate verification status when key changes — safety number is no longer valid.
      if (keyChanged) {
        await prefs.remove('verified_identity_$remoteId');
      }
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
    final type = int.tryParse(parts[1]) ?? -1;
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

  /// Clear sensitive key material from memory.
  void zeroize() {
    _isInitialized = false;
    // Dart strings are immutable and GC'd, but we can drop references.
    // IdentityKeyPair holds byte arrays — zero them out.
    try {
      final pubBytes = _identityKeyPair.getPublicKey().serialize();
      for (int i = 0; i < pubBytes.length; i++) { pubBytes[i] = 0; }
      final privBytes = _identityKeyPair.serialize();
      for (int i = 0; i < privBytes.length; i++) { privBytes[i] = 0; }
    } catch (e) {
      // Best-effort: Dart byte arrays may be read-only; log but don't crash.
      debugPrint('[Signal] Key zeroization incomplete: $e');
    }
  }
}
