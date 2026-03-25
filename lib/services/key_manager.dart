import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import '../adapters/inbox_manager.dart';
import '../adapters/firebase_adapter.dart';
import '../adapters/nostr_adapter.dart';
import '../adapters/waku_adapter.dart';
import '../adapters/oxen_adapter.dart';
import '../constants.dart';
import 'signal_service.dart';
import 'pqc_service.dart';
import 'crypto_layer.dart';

/// Manages cryptographic keys:
/// - PQC (Kyber-1024) per-contact key cache
/// - Signal bundle publishing / republishing
/// - HMAC-SHA256 payload signing (ECDH-based)
/// - Pubkey extraction helpers
class KeyManager {
  final SignalService _signalService;
  final PqcService _pqcService;
  static const _secureStorage = FlutterSecureStorage();
  static const _kDefaultNostrRelay = kDefaultNostrRelay;

  // In-memory PQC key cache: contactId → Kyber-1024 public key
  // LinkedHashMap preserves insertion order for oldest-first eviction.
  static const _kyberCacheMaxSize = 2000;
  final LinkedHashMap<String, Uint8List> _contactKyberPks =
      LinkedHashMap<String, Uint8List>();

  KeyManager(this._signalService, this._pqcService);

  // ── PQC key helpers ──────────────────────────────────────────────────────

  /// Cache a contact's Kyber public key from their Signal bundle.
  void cacheContactKyberPk(String contactId, Map<String, dynamic> bundle) {
    final kyberPkList = bundle['kyberPublicKey'];
    if (kyberPkList == null) return;
    try {
      final pk = Uint8List.fromList(List<int>.from(kyberPkList));
      // ML-KEM-1024 public key is always 1568 bytes — reject anything else to
      // prevent a malicious relay from injecting a wrong-sized key that would
      // crash encapsulate() and DoS outbound messages to this contact.
      if (pk.length != 1568) {
        debugPrint('[KeyManager] Rejected invalid Kyber PK for $contactId: ${pk.length} bytes (expected 1568)');
        return;
      }
      _contactKyberPks[contactId] = pk;
      if (_contactKyberPks.length > _kyberCacheMaxSize) {
        _contactKyberPks.remove(_contactKyberPks.keys.first);
      }
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('pqc_contact_pk_$contactId', base64Encode(pk));
      });
    } catch (e) {
      debugPrint('[KeyManager] Failed to cache kyber pk for $contactId: $e');
    }
  }

  /// True if a Kyber public key is cached for this contact.
  bool hasPqcKey(String contactId) =>
      _contactKyberPks.containsKey(contactId);

  /// Load contact's Kyber pk: in-memory first, then SharedPreferences.
  Future<Uint8List?> loadContactKyberPk(String contactId) async {
    if (_contactKyberPks.containsKey(contactId)) {
      return _contactKyberPks[contactId];
    }
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('pqc_contact_pk_$contactId');
    if (b64 == null) return null;
    final pk = base64Decode(b64);
    _contactKyberPks[contactId] = pk;
    if (_contactKyberPks.length > _kyberCacheMaxSize) {
      _contactKyberPks.remove(_contactKyberPks.keys.first);
    }
    return pk;
  }

  /// Wrap a Signal ciphertext with the PQC hybrid layer for [contactId].
  /// No-op if no Kyber key is available.
  Future<String> pqcWrap(String signalCt, String contactId) async {
    final pk = await loadContactKyberPk(contactId);
    return CryptoLayer.wrap(signalCt, pk);
  }

  // ── Key publishing ───────────────────────────────────────────────────────

  /// Publish Signal bundle to own inbox only if not yet published for this
  /// adapter+selfId combination.
  Future<void> maybePublishOwnKeys(
      String preferredAdapter, String selfId, String adapterApiKey) async {
    if (selfId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final flag = 'signal_keys_published_${preferredAdapter}_$selfId';
    if (prefs.getBool(flag) != true) {
      await publishOwnKeys(preferredAdapter, adapterApiKey, selfId);
      await prefs.setBool(flag, true);
    }
  }

  /// Publish Signal+PQC public bundle to own inbox.
  Future<void> publishOwnKeys(
      String provider, String apiKey, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final bundle = await _signalService.getPublicBundle();
      if (_pqcService.isInitialized) {
        bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
      }
      MessageSender sender;
      String senderApiKey = apiKey;
      switch (provider.toLowerCase()) {
        case 'firebase':
          sender = FirebaseInboxSender();
        case 'nostr':
          final privkey =
              await _secureStorage.read(key: 'nostr_privkey') ?? '';
          if (privkey.isEmpty) return;
          final prefs = await SharedPreferences.getInstance();
          final relay =
              prefs.getString('nostr_relay') ?? _kDefaultNostrRelay;
          sender = NostrMessageSender();
          senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        case 'waku':
          sender = WakuMessageSender();
          {
            final prefs = await SharedPreferences.getInstance();
            final nodeUrl =
                prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
            final userId = prefs.getString('waku_identity') ?? '';
            senderApiKey = jsonEncode({'nodeUrl': nodeUrl, 'userId': userId});
          }
        case 'oxen':
          sender = OxenMessageSender();
          {
            final prefs = await SharedPreferences.getInstance();
            senderApiKey = prefs.getString('oxen_node_url') ?? '';
          }
        default:
          return;
      }
      await sender.initializeSender(senderApiKey);
      await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
      debugPrint('[KeyManager] Published Signal keys for $provider/$selfId');
    } catch (e) {
      debugPrint('[KeyManager] Key publishing failed: $e');
    }
  }

  /// Clear the published flag so next [maybePublishOwnKeys] call re-publishes.
  Future<void> clearPublishedFlag(
      String preferredAdapter, String selfId) async {
    final prefs = await SharedPreferences.getInstance();
    final flag = 'signal_keys_published_${preferredAdapter}_$selfId';
    await prefs.remove(flag);
  }

  /// Re-publish bundle to a specific secondary adapter.
  Future<void> publishKeysToAdapter(
      String provider, String apiKey, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final flag = 'signal_keys_published_${provider.toLowerCase()}_$selfId';
      if (prefs.getBool(flag) == true) return;
      final bundle = await _signalService.getPublicBundle();
      if (_pqcService.isInitialized) {
        bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
      }
      MessageSender sender;
      if (provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (provider == 'Nostr') {
        try {
          final cfg = jsonDecode(apiKey);
          if ((cfg['privkey'] as String? ?? '').isEmpty) return;
        } catch (e) {
          debugPrint('[KeyManager] publishKeysToAdapter: malformed Nostr config: $e');
          return;
        }
        sender = NostrMessageSender();
      } else if (provider == 'Waku') {
        sender = WakuMessageSender();
      } else if (provider == 'Oxen') {
        sender = OxenMessageSender();
      } else {
        return;
      }
      await sender.initializeSender(apiKey);
      await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
      await prefs.setBool(flag, true);
      debugPrint('[KeyManager] Published Signal keys to secondary $provider/$selfId');
    } catch (e) {
      debugPrint('[KeyManager] Secondary key publish failed: $e');
    }
  }

  /// Push our own Signal bundle to [contact]'s Oxen inbox (in-band key exchange).
  Future<void> publishOxenKeysTo(Contact contact, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final bundle = await _signalService.getPublicBundle();
      if (_pqcService.isInitialized) {
        bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
      }
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('oxen_node_url') ?? '';
      final sender = OxenMessageSender();
      await sender.initializeSender(nodeUrl);
      await sender.sendSignal(
          contact.databaseId, contact.databaseId, selfId, 'sys_keys', bundle);
    } catch (e) {
      debugPrint('[KeyManager] Oxen key push to ${contact.name} failed: $e');
    }
  }

  // ── HMAC signing ─────────────────────────────────────────────────────────

  /// Compute HMAC-SHA256 over signal payload using ECDH shared secret.
  /// Returns the original payload enriched with `_sig` and `_spk` fields.
  Future<Map<String, dynamic>> signPayload(
      Contact contact,
      String type,
      Map<String, dynamic> payload,
      String? selfPubkey) async {
    try {
      final privkey =
          await _secureStorage.read(key: 'nostr_privkey') ?? '';
      if (privkey.isEmpty) return payload;
      final recipientPub = extractPubkey(contact.databaseId, [contact]);
      if (recipientPub == null) return payload;
      final senderPub = selfPubkey ?? deriveNostrPubkeyHex(privkey);
      final canonical = jsonEncode({'t': type, 'p': payload});
      final hmac = signSignalPayload(privkey, recipientPub, canonical);
      return {...payload, '_sig': hmac, '_spk': senderPub};
    } catch (e) {
      debugPrint('[KeyManager] Signal sign error: $e');
      return payload;
    }
  }

  /// Verify HMAC-SHA256 signature on an incoming signal payload.
  Future<bool> verifySignalSignature(
      String type, Map<String, dynamic> payload, String hmac,
      String senderPub) async {
    try {
      final privkey =
          await _secureStorage.read(key: 'nostr_privkey') ?? '';
      // FINDING-9 fix: empty privkey must REJECT, not accept all signatures.
      // Returning true here would let any forged signal pass after key loss.
      if (privkey.isEmpty) return false;
      final cleanPayload = Map<String, dynamic>.from(payload)
        ..remove('_sig')
        ..remove('_spk');
      final canonical = jsonEncode({'t': type, 'p': cleanPayload});
      return verifySignalPayload(privkey, senderPub, canonical, hmac);
    } catch (e) {
      debugPrint('[KeyManager] Signature verification error: $e');
      return false;
    }
  }

  // ── Pubkey extraction ────────────────────────────────────────────────────

  /// Extract Nostr pubkey from any address format.
  String? extractPubkey(String databaseId, List<Contact> contacts) {
    final atWss = databaseId.indexOf('@wss://');
    final atWs = databaseId.indexOf('@ws://');
    final atIdx = atWss != -1 ? atWss : (atWs != -1 ? atWs : -1);
    if (atIdx != -1) {
      final pub = databaseId.substring(0, atIdx);
      if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pub)) return pub;
    }
    if (RegExp(r'^[0-9a-f]{64}$').hasMatch(databaseId)) return databaseId;
    final contact = contacts.cast<Contact?>().firstWhere(
          (c) => c?.databaseId == databaseId,
          orElse: () => null,
        );
    if (contact == null) return null;
    for (final addr in [contact.databaseId, ...contact.alternateAddresses]) {
      final at = addr.indexOf('@wss://');
      if (at != -1) {
        final pub = addr.substring(0, at);
        if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pub)) return pub;
      }
    }
    return null;
  }
}
