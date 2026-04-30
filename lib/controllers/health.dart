part of 'chat_controller.dart';

/// Adapter health monitoring + identity primary migration. When the
/// active primary transport (Nostr/Pulse/Session relay) goes unhealthy
/// for longer than [ChatController._kPrimaryMigrationGrace], we
/// silently swap to the first healthy alternate from `_allAddresses`,
/// rewriting `_selfId` / `_identity.adapterConfig` / prefs and
/// re-publishing Signal keys on the new relay so contacts can still
/// reach us. Old primary stays in the alternates pool so we keep
/// receiving on it if it recovers.
class _AdapterHealth {
  final ChatController _c;
  _AdapterHealth(this._c);

  void onChange(String addr, bool healthy) {
    _c._adapterHealth[addr] = healthy;
    sentryBreadcrumb('Adapter health: ${healthy ? "healthy" : "unhealthy"}',
        category: 'adapter');
    debugPrint('[Failover] $addr → ${healthy ? "healthy" : "UNHEALTHY"}');
    if (healthy) {
      _c._primaryUnhealthySince.remove(addr);
      return;
    }
    if (addr != _c._selfId) return;
    // Primary went unhealthy: start grace timer and re-check after the
    // grace period. A single transient failure shouldn't trigger a
    // costly identity migration (re-publish keys, broadcast
    // addr_update, update prefs). Only sustained failure does.
    _c._primaryUnhealthySince.putIfAbsent(addr, () => DateTime.now());
    Future.delayed(ChatController._kPrimaryMigrationGrace, () {
      final since = _c._primaryUnhealthySince[addr];
      if (since == null) return; // recovered
      if (_c._adapterHealth[addr] ?? false) return; // healthy now
      if (addr != _c._selfId) return; // already migrated by another path
      if (_c._migrating) return;
      final newPrimary = _c._allAddresses.firstWhere(
        (a) => a != addr && (_c._adapterHealth[a] ?? false),
        orElse: () => '',
      );
      if (newPrimary.isEmpty) {
        debugPrint('[Failover] No healthy alternate after '
            '${ChatController._kPrimaryMigrationGrace.inSeconds}s — staying on $addr');
        return;
      }
      unawaited(_migratePrimary(oldAddr: addr, newAddr: newPrimary));
    });
  }

  /// Persistently migrate the Nostr identity primary to [newAddr].
  /// Updates [_selfId], [_identity.adapterConfig], prefs.nostr_relay,
  /// and re-publishes Signal keys so contacts fetching from the new
  /// relay can still reach us. Old primary stays in [_allAddresses] as
  /// a secondary (so we keep receiving on it if it recovers).
  Future<void> _migratePrimary({
    required String oldAddr,
    required String newAddr,
  }) async {
    if (_c._migrating || _c._identity == null) return;
    _c._migrating = true;
    try {
      final atIdx = newAddr.indexOf('@');
      if (atIdx <= 0) return;
      final newRelay = newAddr.substring(atIdx + 1);
      debugPrint('[Failover] Migrating primary: $oldAddr → $newAddr');

      // Update in-memory state.
      _c._selfId = newAddr;
      _c._identity = Identity(
        id: _c._identity!.id,
        publicKey: _c._identity!.publicKey,
        privateKey: _c._identity!.privateKey,
        preferredAdapter: _c._identity!.preferredAdapter,
        adapterConfig: {
          ..._c._identity!.adapterConfig,
          'relay': newRelay,
          'dbId': newAddr,
        },
      );
      _c._primaryUnhealthySince.remove(oldAddr);

      // Persist to prefs so cold-start reads the new primary.
      final prefs = await _c._getPrefs();
      await prefs.setString('nostr_relay', newRelay);
      await prefs.setString('user_identity', jsonEncode(_c._identity!.toJson()));

      // Re-publish Signal keys on the new primary so contacts fetching
      // via NIP-65 / addr_update find our identity at the new address.
      final nostrPriv =
          await ChatController._secureStorage.read(key: 'nostr_privkey') ?? '';
      if (nostrPriv.isNotEmpty) {
        final apiKey = jsonEncode({'privkey': nostrPriv, 'relay': newRelay});
        unawaited(_c._keys.publishKeysToAdapter('Nostr', apiKey, newAddr));
      }

      if (!_c._failoverCtrl.isClosed) {
        _c._failoverCtrl.add((from: oldAddr, to: newAddr));
      }
      unawaited(_c.broadcastAddressUpdate());
      _c._scheduleNotify();
    } catch (e) {
      debugPrint('[Failover] Migration failed: $e');
    } finally {
      _c._migrating = false;
    }
  }
}
