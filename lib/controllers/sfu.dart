part of 'chat_controller.dart';

/// SFU group-call state machine — active calls, invite dedup, room
/// staleness timers, SFU probes, and Pulse-pubkey→Contact resolution.
/// Extracted from ChatController so the main file doesn't carry every
/// call-management method inline.
///
/// State (`_activeGroupCalls`, `_deadRoomIds`, …) stays on ChatController
/// itself because dispose(), SignalDispatcher integration and the
/// reconnect path all touch these fields. The helper owns the
/// *behaviour*: register / expire / clear calls, handle probes,
/// resolve participant identities, and guard against stale rooms.
class _SfuCalls {
  final ChatController _c;
  _SfuCalls(this._c);

  // ── Public accessors ─────────────────────────────────────────────────

  ActiveGroupCall? activeGroupCall(String groupId) =>
      _c._activeGroupCalls[groupId];

  bool markInviteShownIfNew(String groupId, String roomId) {
    if (groupId.isEmpty || roomId.isEmpty) return true;
    return _c._shownInviteKeys.add('$groupId|$roomId');
  }

  void forgetInvitesForGroup(String groupId) {
    _c._shownInviteKeys.removeWhere((k) => k.startsWith('$groupId|'));
  }

  void enterSfuCall(String groupId) {
    _c._inCallGroupIds.add(groupId);
    debugPrint('[Chat] enterSfuCall($groupId) — inCall=${_c._inCallGroupIds.length}');
  }

  void exitSfuCall(String groupId) {
    if (_c._inCallGroupIds.remove(groupId)) {
      _c._recentSfuExit[groupId] = DateTime.now();
      debugPrint('[Chat] exitSfuCall($groupId) — inCall=${_c._inCallGroupIds.length}');
    }
  }

  Duration? sinceLastSfuExit(String groupId) {
    final t = _c._recentSfuExit[groupId];
    if (t == null) return null;
    return DateTime.now().difference(t);
  }

  bool isRoomDead(String roomId) => _c._deadRoomIds.contains(roomId);

  void markRoomDead(String roomId) {
    if (roomId.isEmpty) return;
    if (_c._deadRoomIds.add(roomId)) {
      debugPrint('[Chat] Marked SFU room dead: $roomId');
    }
  }

  String? nostrSenderForPulsePk(String pulsePk) =>
      _c._pulsePkToNostrSender[pulsePk.toLowerCase()];

  void learnPulseFromInvite(String nostrSenderId, String pulseAddr) {
    if (pulseAddr.isEmpty || nostrSenderId.isEmpty) return;
    final at = pulseAddr.indexOf('@');
    final pulsePk = (at > 0 ? pulseAddr.substring(0, at) : pulseAddr).toLowerCase();
    if (pulsePk.isEmpty) return;
    if (_c._pulsePkToNostrSender[pulsePk] == nostrSenderId) return;
    _c._pulsePkToNostrSender[pulsePk] = nostrSenderId;
    debugPrint('[Chat] Learned Pulse pubkey for Nostr sender ${nostrSenderId.substring(0, nostrSenderId.length.clamp(0, 8))}…: ${pulsePk.substring(0, 8)}…');
  }

  // ── SFU probe + call discovery ───────────────────────────────────────

  /// Handle an incoming `sfu_probe` signal. Only respond if we're
  /// *currently* in an SFU call for this group — otherwise a
  /// just-restarted client with a stale `_activeGroupCalls` entry
  /// would echo a dead roomId back to the prober.
  void handleSfuProbe(String groupId) {
    if (!_c._inCallGroupIds.contains(groupId)) return;
    final call = _c._activeGroupCalls[groupId];
    if (call == null) return;
    final group = _c._contacts.findById(groupId);
    if (group == null || !group.isGroup) return;
    debugPrint('[Chat] sfu_probe for $groupId — rebroadcasting invite');
    unawaited(_c.broadcastSfuCallInvite(group, call.roomId, call.token,
        isVideoCall: call.isVideoCall));
  }

  /// Before creating a new SFU room, probe the group — if anyone is
  /// already in a call they'll rebroadcast their invite, letting us
  /// join instead of fragmenting the group into two parallel rooms.
  /// Returns the discovered active call, or null after [probeTimeout].
  ///
  /// Concurrent callers (double-tapping the call button, hot UI rebuild
  /// while waiting) share the SAME in-flight Future — without this we
  /// fired N probes, all timed out independently, and each issued its
  /// own `room_create`, giving the server a fresh room per tap.
  Future<ActiveGroupCall?> discoverGroupCall(Contact group,
      {Duration probeTimeout = const Duration(seconds: 2)}) {
    final existing = _c._inflightProbes[group.id];
    if (existing != null) return existing;
    final active = activeGroupCall(group.id);
    if (active != null) return Future.value(active);
    final fut = () async {
      try {
        await _c._broadcaster.broadcastSfuProbe(group, _c._contacts.contacts);
        final deadline = DateTime.now().add(probeTimeout);
        while (DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          final hit = activeGroupCall(group.id);
          if (hit != null) return hit;
        }
        return null;
      } finally {
        _c._inflightProbes.remove(group.id);
      }
    }();
    _c._inflightProbes[group.id] = fut;
    return fut;
  }

  // ── Active-call lifecycle ────────────────────────────────────────────

  void registerActiveGroupCall(
      String groupId, String roomId, String token, String hostId,
      {bool isVideoCall = false}) {
    // Refresh staleness timer on every invite — even if we already have
    // this exact (groupId, roomId) entry. Drop the entry after 45s of
    // silence so the UI doesn't keep a ghost banner.
    _c._callStalenessTimers[groupId]?.cancel();
    _c._callStalenessTimers[groupId] =
        Timer(ChatController._kCallStalenessTimeout, () {
      debugPrint('[Chat] No sfu_invite for $groupId in ${ChatController._kCallStalenessTimeout.inSeconds}s — clearing stale call');
      _c._callStalenessTimers.remove(groupId);
      clearActiveGroupCall(groupId);
    });

    if (_c._deadRoomIds.contains(roomId)) {
      debugPrint('[Chat] Ignoring activeGroupCall for dead room $roomId');
      return;
    }
    final existing = _c._activeGroupCalls[groupId];
    if (existing != null && existing.roomId == roomId) return;
    _c._activeGroupCalls[groupId] = ActiveGroupCall(
      groupId: groupId,
      roomId: roomId,
      token: token,
      hostId: hostId,
      isVideoCall: isVideoCall,
      startedAt: DateTime.now(),
    );
    if (!_c._activeCallsCtrl.isClosed) _c._activeCallsCtrl.add(groupId);
    // Auto-expire after 30 min of presumed activity unless refreshed.
    Timer(const Duration(minutes: 30), () =>
        _expireActiveGroupCall(groupId, roomId));
  }

  void _expireActiveGroupCall(String groupId, String roomId) {
    final call = _c._activeGroupCalls[groupId];
    if (call == null || call.roomId != roomId) return;
    _c._activeGroupCalls.remove(groupId);
    if (!_c._activeCallsCtrl.isClosed) _c._activeCallsCtrl.add(groupId);
  }

  /// Remove an active call entry — called from SfuCallScreen after the
  /// host taps "end for everyone" or when we get a definitive signal
  /// that the room is gone.
  void clearActiveGroupCall(String groupId) {
    _c._callStalenessTimers.remove(groupId)?.cancel();
    forgetInvitesForGroup(groupId);
    if (_c._activeGroupCalls.remove(groupId) != null) {
      if (!_c._activeCallsCtrl.isClosed) _c._activeCallsCtrl.add(groupId);
    }
  }
}
