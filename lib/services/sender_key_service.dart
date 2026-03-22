import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────
// Persistent SenderKeyStore backed by SharedPreferences.
//
// Each sender key record is stored under the key:
//   sk_{groupId}_{senderName}_{deviceId}
//
// This mirrors the approach used by _PersistentSignalStore in
// signal_service.dart, but uses SharedPreferences since sender key
// records don't contain long-lived identity secrets.
// ─────────────────────────────────────────────────────────────────

class PersistentSenderKeyStore extends SenderKeyStore {
  PersistentSenderKeyStore([SharedPreferences? prefs]) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Visible for testing — allows injecting a mock SharedPreferences.
  @visibleForTesting
  void setPrefsForTesting(SharedPreferences prefs) => _prefs = prefs;

  static String _key(SenderKeyName senderKeyName) {
    final g = senderKeyName.groupId;
    final s = senderKeyName.sender.getName();
    final d = senderKeyName.sender.getDeviceId();
    return 'sk_${g}_${s}_$d';
  }

  @override
  Future<void> storeSenderKey(
      SenderKeyName senderKeyName, SenderKeyRecord record) async {
    final prefs = await _getPrefs();
    await prefs.setString(_key(senderKeyName), base64Encode(record.serialize()));
  }

  @override
  Future<SenderKeyRecord> loadSenderKey(SenderKeyName senderKeyName) async {
    final prefs = await _getPrefs();
    final b64 = prefs.getString(_key(senderKeyName));
    if (b64 == null || b64.isEmpty) return SenderKeyRecord();
    try {
      return SenderKeyRecord.fromSerialized(base64Decode(b64));
    } catch (e) {
      debugPrint('[SenderKey] Failed to deserialize record for ${senderKeyName.serialize()}: $e');
      return SenderKeyRecord();
    }
  }

  /// Remove a specific sender key record.
  Future<void> removeSenderKey(SenderKeyName senderKeyName) async {
    final prefs = await _getPrefs();
    await prefs.remove(_key(senderKeyName));
  }

  /// Remove all sender key records whose key starts with 'sk_{groupId}_'.
  Future<void> removeAllForGroup(String groupId) async {
    final prefs = await _getPrefs();
    final prefix = 'sk_${groupId}_';
    final keysToRemove = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keysToRemove) {
      await prefs.remove(k);
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// SenderKeyService — singleton managing Signal Sender Keys for
// group E2EE. Uses GroupSessionBuilder + GroupCipher from
// libsignal_protocol_dart.
//
// Flow:
//   1. Creator calls createDistribution(groupId, selfId) → gets
//      serialized SenderKeyDistributionMessage bytes.
//   2. Those bytes are sent to each group member as a
//      'sender_key_dist' signal.
//   3. Receiver calls processDistribution(groupId, senderId, bytes)
//      to ingest the distribution.
//   4. Sender encrypts via encrypt(groupId, selfId, plaintext).
//   5. Receiver decrypts via decrypt(groupId, senderId, ciphertext).
// ─────────────────────────────────────────────────────────────────

class SenderKeyService {
  SenderKeyService._internal();

  static final SenderKeyService _instance = SenderKeyService._internal();
  static SenderKeyService get instance => _instance;

  /// Visible for testing — allows injecting a custom store.
  @visibleForTesting
  SenderKeyService.forTesting(this._store);

  PersistentSenderKeyStore _store = PersistentSenderKeyStore();

  /// Cached SharedPreferences instance for distribution tracking methods.
  SharedPreferences? _cachedPrefs;

  /// Returns the cached SharedPreferences, loading once on first access.
  Future<SharedPreferences> _getPrefs() async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  /// Cached GroupSessionBuilder instances per group.
  final Map<String, GroupSessionBuilder> _builders = {};

  /// Cached GroupCipher instances keyed by '{groupId}::{senderId}'.
  final Map<String, GroupCipher> _ciphers = {};

  /// Device ID used for our own SenderKeyName entries. Constant 1
  /// matches the convention used elsewhere in signal_service.dart.
  static const int _deviceId = 1;

  // ── Helpers ─────────────────────────────────────────────────────

  GroupSessionBuilder _getBuilder() {
    return _builders.putIfAbsent('_global', () => GroupSessionBuilder(_store));
  }

  GroupCipher _getCipher(String groupId, String senderId) {
    final key = '$groupId::$senderId';
    return _ciphers.putIfAbsent(key, () {
      final senderKeyName = SenderKeyName(
          groupId, SignalProtocolAddress(senderId, _deviceId));
      return GroupCipher(_store, senderKeyName);
    });
  }

  SenderKeyName _senderKeyName(String groupId, String senderId) =>
      SenderKeyName(groupId, SignalProtocolAddress(senderId, _deviceId));

  // ── Distribution ────────────────────────────────────────────────

  /// Creates a new sender key distribution message for [groupId] from [selfId].
  /// Returns the serialized bytes to be sent to group members.
  Future<Uint8List> createDistribution(String groupId, String selfId) async {
    final builder = _getBuilder();
    final senderKeyName = _senderKeyName(groupId, selfId);
    final skdm = await builder.create(senderKeyName);
    return skdm.serialize();
  }

  /// Processes an incoming sender key distribution from [senderId] for [groupId].
  Future<void> processDistribution(
      String groupId, String senderId, Uint8List skdmBytes) async {
    final builder = _getBuilder();
    final senderKeyName = _senderKeyName(groupId, senderId);
    final skdm = SenderKeyDistributionMessageWrapper.fromSerialized(skdmBytes);
    await builder.process(senderKeyName, skdm);
    // Invalidate cached cipher so it picks up the new state.
    _ciphers.remove('$groupId::$senderId');
    debugPrint('[SenderKey] Processed distribution from $senderId for group $groupId');
  }

  // ── Encrypt / Decrypt ──────────────────────────────────────────

  /// Encrypts [plaintext] using the sender key for [groupId] owned by [selfId].
  /// Throws [NoSessionException] if no sender key session exists yet.
  Future<Uint8List> encrypt(
      String groupId, String selfId, Uint8List plaintext) async {
    final cipher = _getCipher(groupId, selfId);
    return cipher.encrypt(plaintext);
  }

  /// Decrypts [ciphertext] from [senderId] in [groupId].
  /// Throws [NoSessionException] if the sender's key hasn't been distributed.
  Future<Uint8List> decrypt(
      String groupId, String senderId, Uint8List ciphertext) async {
    final cipher = _getCipher(groupId, senderId);
    return cipher.decrypt(ciphertext);
  }

  // ── Distribution tracking ──────────────────────────────────────
  //
  // We track which members have received our sender key distribution
  // via SharedPreferences flags: 'sk_dist_{groupId}_{memberId}'.
  // This avoids re-sending the distribution on every message.

  static String _distKey(String groupId, String memberId) =>
      'sk_dist_${groupId}_$memberId';

  /// Returns true if all [memberIds] have received our sender key
  /// distribution for [groupId].
  Future<bool> allMembersHaveKey(
      String groupId, List<String> memberIds) async {
    final prefs = await _getPrefs();
    for (final id in memberIds) {
      if (prefs.getBool(_distKey(groupId, id)) != true) return false;
    }
    return true;
  }

  /// Marks that [memberId] has received our sender key distribution
  /// for [groupId].
  Future<void> markDistributed(String groupId, String memberId) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_distKey(groupId, memberId), true);
  }

  /// Clears all distribution flags for [groupId] (used after key rotation).
  Future<void> _clearDistributedFlags(String groupId) async {
    final prefs = await _getPrefs();
    final prefix = 'sk_dist_${groupId}_';
    final keysToRemove =
        prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keysToRemove) {
      await prefs.remove(k);
    }
  }

  // ── Key rotation ───────────────────────────────────────────────

  /// Rotates the sender key for [groupId] owned by [selfId].
  /// Deletes the old key, creates a new distribution, and clears all
  /// distribution flags so the new key is sent to all members.
  /// Returns the new distribution bytes.
  Future<Uint8List> rotateKey(String groupId, String selfId) async {
    // Remove old sender key from store.
    final senderKeyName = _senderKeyName(groupId, selfId);
    await _store.removeSenderKey(senderKeyName);

    // Invalidate cached cipher.
    _ciphers.remove('$groupId::$selfId');

    // Clear distribution tracking.
    await _clearDistributedFlags(groupId);

    // Create fresh distribution.
    final skdmBytes = await createDistribution(groupId, selfId);
    debugPrint('[SenderKey] Rotated key for group $groupId');
    return skdmBytes;
  }

  // ── Cleanup ────────────────────────────────────────────────────

  /// Removes all sender key state for [groupId] — call when deleting a group.
  Future<void> clearGroup(String groupId) async {
    await _store.removeAllForGroup(groupId);
    await _clearDistributedFlags(groupId);
    // Remove cached ciphers for this group.
    _ciphers.removeWhere((k, _) => k.startsWith('$groupId::'));
    debugPrint('[SenderKey] Cleared all state for group $groupId');
  }

  /// Clears all in-memory caches. Does NOT touch persisted data.
  void clearCaches() {
    _builders.clear();
    _ciphers.clear();
  }
}
