part of 'chat_controller.dart';

/// Key (re)publish + session-reset push helpers. Most of the actual
/// work lives in `KeyManager` — this layer is the thin orchestrator
/// that knows about the controller's own identity, secondary
/// adapters, and the broadcaster.
class _KeyRepublisher {
  final ChatController _c;
  _KeyRepublisher(this._c);

  /// Republish our Signal+Kyber prekey bundle on the primary
  /// transport. Called after the local one-time prekey count drops
  /// below the publish threshold (consumed by inbound messages) so
  /// peers always have a fresh prekey to bootstrap a session against.
  Future<void> republishPrimary() async {
    if (_c._identity == null || _c._selfId.isEmpty) return;
    await _c._keys
        .clearPublishedFlag(_c._identity!.preferredAdapter, _c._selfId);
    await _c._keys.maybePublishOwnKeys(
        _c._identity!.preferredAdapter,
        _c._selfId,
        _c._identity!.adapterConfig['token'] ?? '');
    debugPrint('[ChatController] Republished Signal bundle after preKey consumption');
  }

  /// Republish on every transport (primary + every secondary the user
  /// has configured). Used by the session-reset recovery path so peers
  /// reaching us via any of our addresses see the fresh bundle.
  Future<void> republishAll() async {
    await republishPrimary();
    final secondaryCfgs = await _c._loadSecondaryAdapters();
    for (final cfg in secondaryCfgs) {
      final selfId = cfg['selfId'] ?? '';
      if (selfId.isEmpty) continue;
      await _c._keys
          .clearPublishedFlag(cfg['provider']?.toLowerCase() ?? '', selfId);
      await _c._keys
          .publishKeysToAdapter(cfg['provider']!, cfg['apiKey']!, selfId);
    }
    debugPrint('[ChatController] Republished Signal bundle to all transports');
  }

  /// Push our current Signal+Kyber bundle directly to [contact] as a
  /// `session_reset` signal carrying the bundle in its payload.
  ///
  /// Why inline bundle instead of relying on relay republish: the
  /// receiver's SignalDispatcher pre-builds a fresh session from the
  /// embedded bundle BEFORE the next encrypt. Eliminates the race
  /// where the receiver re-fetched our published bundle from a relay
  /// that hadn't yet propagated our most recent kind:10009 update —
  /// empirically that race burned ~50% of stale-prekey recoveries.
  ///
  /// Recovery sequence after a stale-prekey / Bad-Mac decrypt:
  ///   1. AWAIT `republishAll()` so the published bundle is on record
  ///      before the peer might refetch via legacy path.
  ///   2. Snapshot the bundle right after publish.
  ///   3. Send `session_reset` carrying the bundle directly. Peer
  ///      builds session from the inline payload, no relay round-trip.
  ///
  /// `pqcWrap: false` because the inline bundle includes the Kyber
  /// public key — wrapping the unwrap-key in PQC would be circular.
  Future<void> pushOwnBundleTo(Contact contact) async {
    try {
      // CRITICAL: AWAIT the republish, otherwise the session_reset
      // signal beats our own publish to the peer's relay and they
      // refetch a stale bundle.
      await republishAll();
      Map<String, dynamic>? bundle;
      try {
        bundle = await _c._keys.buildOwnBundle();
      } catch (e) {
        debugPrint('[ChatController] _pushOwnBundleTo: buildOwnBundle failed: $e');
      }
      final payload = <String, dynamic>{
        'ts': DateTime.now().toUtc().toIso8601String(),
        if (bundle != null) 'bundle': bundle,
      };
      await _c._broadcaster.sendSignalToAllTransports(
          contact, 'session_reset', payload, pqcWrap: false);
      debugPrint('[ChatController] Pushed session_reset to ${contact.name} '
          'with inline bundle=${bundle != null} after stale-prekey failure');
    } catch (e) {
      debugPrint('[ChatController] Failed to push session_reset to ${contact.name}: $e');
    }
  }
}
