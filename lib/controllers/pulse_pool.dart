part of 'chat_controller.dart';

/// Per-server Pulse connection pool + reset operations. The fields
/// (`_pulseSendersByServer` / `_pulseReadersByServer`) live on
/// ChatController itself because dispose, reconnectInbox and the smart
/// router all touch them — moving the maps would just spawn extra
/// indirection. This helper owns the *behaviour*: open / close / reset
/// connections, send raw to a specific server, and rebuild a stale
/// pool entry when the underlying reader has died.
class _PulsePool {
  final ChatController _c;
  _PulsePool(this._c);

  /// Same canonicalization as `_PulseSharedWs._canonicalize` so our pool
  /// keys line up 1:1 with the pulse_adapter pool. Strips fragment,
  /// trailing slash, default ports (443 for https, 80 for http), and
  /// lower-cases scheme+host.
  ///
  /// **Stripping default ports is load-bearing**: without it, group
  /// invites carrying `https://duck.azxc.site:443` create a pool entry
  /// distinct from the pre-existing `https://duck.azxc.site` (no port)
  /// entry — same server, same pubkey, but two PulseInboxReaders
  /// trying to hold the WS at once. Server enforces one connection per
  /// pubkey so it kicks the older one ~every second; readers
  /// reconnect; cycle runs forever. And every signal sent during the
  /// kick window comes back as `signal_fail offline`.
  static String canonicalizeUrl(String serverUrl) {
    if (serverUrl.isEmpty) return '';
    var s = serverUrl.trim();
    final hash = s.indexOf('#');
    if (hash != -1) s = s.substring(0, hash);
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);
    s = s.toLowerCase();
    if (s.startsWith('https://') && s.endsWith(':443')) {
      s = s.substring(0, s.length - 4);
    } else if (s.startsWith('http://') && s.endsWith(':80')) {
      s = s.substring(0, s.length - 3);
    }
    return s;
  }

  /// Reset all Nostr connections (pool + subscription) after proxy
  /// settings change. Called from settings screen when force-Tor
  /// toggle changes.
  Future<void> resetNostr() async {
    await _c._cachedNostrSender?.resetConnections();
    final reader = InboxManager().reader;
    if (reader is NostrInboxReader) await reader.resetConnections();
    for (final sender in InboxManager().senders.values) {
      if (sender is NostrMessageSender) await sender.resetConnections();
    }
    debugPrint('[ChatController] Nostr connections reset');
  }

  /// Reset all Pulse relay connections (called when Force-Tor toggle changes).
  Future<void> resetPulse() async {
    final reader = InboxManager().reader;
    if (reader is PulseInboxReader) await reader.resetConnection();
    for (final sender in InboxManager().senders.values) {
      if (sender is PulseMessageSender) await sender.resetConnection();
    }
    debugPrint('[ChatController] Pulse connections reset');
  }

  /// Send a raw JSON SFU control message to a SPECIFIC Pulse server in
  /// the pool. Required for group calls whose `groupServerUrl` differs
  /// from the user's primary Pulse server.
  bool sendRawToServer(String serverUrl, String jsonMsg) {
    final key = canonicalizeUrl(serverUrl);
    final sender = _c._pulseSendersByServer[key];
    if (sender == null) {
      debugPrint('[Group/SFU] sendRawPulseSignalToServer: no sender for '
          '$serverUrl (call ensureGroupPulseConnection first)');
      return false;
    }
    sender.sendRaw(jsonMsg);
    return true;
  }

  /// Open (or reuse) a dedicated Pulse WebSocket connection to
  /// [serverUrl] and register a sender + reader in the per-server pool.
  ///
  /// Multi-server primitive: a client keeps its own primary Pulse
  /// connection AND any number of group-server connections in
  /// parallel, each with their own `_PulseSharedWs` pool entry inside
  /// `pulse_adapter`. Without this, group calls on a foreign Pulse
  /// server fail because:
  ///   1. the user has no primary Pulse at all (Nostr-primary identity)
  ///      — `_cachedPulseSender` is null and `sendRawPulseSignal` is a
  ///      no-op; or
  ///   2. the user has a different primary Pulse server — `sendRaw`
  ///      would land on the WRONG server's WS channel.
  ///
  /// Uses the deterministic Pulse private key (Argon2id-derived from the
  /// recovery key, identical on every server) so any client can join any
  /// open server without preregistration.
  Future<bool> ensureConnection(String serverUrl) async {
    if (serverUrl.isEmpty) return false;
    final key = canonicalizeUrl(serverUrl);
    if (_c._pulseSendersByServer.containsKey(key)) {
      // Sender cached from a previous call — but the underlying reader
      // may have died during a long laptop sleep (uTLS circuit breaker
      // tripped, _runLoop hit max consecutive failures and exited
      // permanently). The sender alone can't dispatch incoming SFU
      // signals to SignalDispatcher, so room_create replies vanish and
      // the user is stuck on "Connecting…". Detect the stale state and
      // tear it down so the path below rebuilds a fresh reader+sender.
      if (isPulseReaderHealthy(serverUrl)) return true;
      debugPrint('[Group/SFU] ensureGroupPulseConnection: cached sender '
          'present but reader is dead (post-sleep recovery) — '
          'rebuilding for $serverUrl');
      _c._pulseSendersByServer.remove(key);
      _c._pulseReadersByServer.remove(key);
      dropPulseSharedPoolFor(serverUrl);
      // Clear the uTLS breaker too, otherwise the brand-new reader's
      // first connect attempt throws StateError immediately and we end
      // up in the same broken state we just escaped.
      resetPulseUtlsBreaker();
    }

    var privkey =
        await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
    if (privkey.isEmpty) {
      privkey = await _c._recoverTransportKey('pulse_privkey');
    }
    if (privkey.isEmpty) {
      debugPrint('[Group/SFU] ensureGroupPulseConnection: no pulse_privkey '
          'and recovery_key derivation failed — cannot open SFU connection');
      return false;
    }
    try {
      final apiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});

      // Reuse an existing reader for this server if one already exists.
      // Pulse-server enforces "1 connection per pubkey" — opening a
      // second WS would make the server kick the first one (sending
      // "abnormal closure: unexpected EOF" to the dropped side), and we
      // never get to send the SFU control message. Two readers can
      // happen because:
      //   - the InboxManager's primary auto-opened an adhoc Pulse reader
      //     during _initialize when pulse_server_url was set in prefs,
      //   - then the user joins an SFU group whose groupServerUrl
      //     matches → ensureGroupPulseConnection naively opens another.
      // Detect both _pulseReadersByServer entries AND the legacy
      // _adhocPulseReader; either covers us.
      PulseInboxReader? reader = _c._pulseReadersByServer[key];
      final adhocServerKey = canonicalizeUrl(
          (await _c._getPrefs()).getString('pulse_server_url') ?? '');
      if (reader == null &&
          _c._adhocPulseReader != null &&
          adhocServerKey == key) {
        reader = _c._adhocPulseReader;
        _c._pulseReadersByServer[key] = reader!;
        debugPrint('[Group/SFU] Reusing primary adhoc Pulse reader for $serverUrl');
      }
      if (reader == null) {
        final created =
            await InboxManager().createAdhocReader('Pulse', apiKey, serverUrl);
        if (created is PulseInboxReader) {
          reader = created;
          _c._pulseReadersByServer[key] = reader;
          _c._messageSubs.add(
              reader.listenForMessages().listen(_c._handleIncomingMessages));
          _c._signalSubs.add(reader.listenForSignals().listen((sigs) =>
              _c._signalDispatcher!.dispatch(sigs, sourceTransport: 'Pulse')));
          debugPrint('[Group/SFU] Opened pool reader for $serverUrl');
        }
      }

      final sender = PulseMessageSender();
      await sender.initializeSender(apiKey);
      _c._pulseSendersByServer[key] = sender;
      // Also seed _cachedPulseSender if the user had no primary Pulse
      // at all — keeps legacy `sendRawPulseSignal` callers (broadcaster
      // etc.) working when the user is otherwise Nostr-only.
      _c._cachedPulseSender ??= sender;
      // Reader auth is async — finishes when the run loop reaches
      // auth_ok. Block here until the pool entry's `_shared.channel` is
      // populated, otherwise the very first sender.sendRaw races and
      // emits "no authenticated connection". 15s covers PoW (~2-5s) + a
      // generous margin for slow networks / Tor.
      final ready = await waitForPulseAuth(serverUrl);
      if (!ready) {
        debugPrint('[Group/SFU] ensureGroupPulseConnection: auth timed out '
            'for $serverUrl — sender created but channel not ready yet');
      }

      // Advertise our Pulse address on this server in `_allAddresses`
      // so the next addr_update broadcast carries it. Without this,
      // peers in our pulse-mode groups never learn our universal Pulse
      // pubkey and their sends to us silently fail with "No Pulse
      // pubkey for X" — the exact bootstrap dead-end that breaks the
      // very first send to a fresh pulse group. Idempotent;
      // broadcastAddressUpdate dedupes too.
      try {
        final seed = Uint8List.fromList(hex.decode(privkey));
        final pulsePub = await ed25519PubkeyFromSeed(seed);
        final selfPulseAddr = '$pulsePub@$serverUrl';
        if (!_c._allAddresses.contains(selfPulseAddr)) {
          _c._allAddresses = [..._c._allAddresses, selfPulseAddr];
          _c._adapterHealth[selfPulseAddr] = ready;
          debugPrint('[Group/SFU] ensureGroupPulseConnection: advertised '
              'self Pulse address $selfPulseAddr to peers');
          unawaited(_c.broadcastAddressUpdate());
        }
        // Publish our Signal/Kyber prekey bundle to THIS server too so
        // pulse-group peers can fetch it. CRITICAL: reuse the
        // per-server pool sender we just created — `publishKeysToAdapter`
        // would naively spawn a second `PulseMessageSender` and call
        // `initializeSender`, but the Pulse hub allows only one WS per
        // pubkey, so the second connection kicks the first (the
        // long-lived reader) and the sys_keys publish silently fails
        // with no log. Going through the existing sender ensures we
        // ride the already-authenticated WS.
        try {
          final bundle = await _c._keys.buildOwnBundle();
          final ok = await sender.sendSignal(
              selfPulseAddr, selfPulseAddr, selfPulseAddr, 'sys_keys', bundle);
          if (ok) {
            debugPrint('[Group/SFU] Published Signal bundle to $serverUrl '
                'via reused pool sender');
          } else {
            debugPrint('[Group/SFU] Failed to publish Signal bundle to '
                '$serverUrl (sender returned false)');
          }
        } catch (err) {
          debugPrint('[Group/SFU] Failed to publish Signal bundle to '
              '$serverUrl: $err');
        }
      } catch (e) {
        debugPrint('[Group/SFU] ensureGroupPulseConnection: failed to '
            'advertise self Pulse address / publish keys: $e');
      }

      return ready;
    } catch (e) {
      debugPrint('[Group/SFU] ensureGroupPulseConnection failed: $e');
      return false;
    }
  }

  /// Force-reconnect the per-server Pulse pool entry. Used by SFU when
  /// `room_create` / `room_join` retries silently timed out — usually
  /// the underlying WS sink is half-closed (Dart's `sink.add` returns
  /// without raising even when the TCP layer dropped the connection),
  /// so we tear down the old reader+sender and force a fresh
  /// authenticated channel before the caller resends.
  ///
  /// IMPORTANT: do not call `reader.resetConnection()` — that
  /// auto-restarts the runLoop, racing the new reader we open via
  /// ensureConnection and producing two competing connections (server's
  /// "1 client per pubkey" then ping-pongs between them, neither lasts
  /// long enough to deliver SFU control messages). `close()` stops the
  /// loop without restarting it.
  Future<void> resetConnection(String serverUrl) async {
    if (serverUrl.isEmpty) return;
    final key = canonicalizeUrl(serverUrl);
    debugPrint('[Group/SFU] forcing Pulse reconnect for $serverUrl');
    final reader = _c._pulseReadersByServer.remove(key);
    final sender = _c._pulseSendersByServer.remove(key);
    // Hard-stop old reader. close() sets _running=false + closes the
    // WS sink without spawning a fresh loop. Sender holds no
    // connection state (it borrows the reader's shared channel) so
    // dropping the map reference is enough.
    try { reader?.close(); } catch (_) {}
    sender; // intentionally not closed
    // Drop the shared pool entry too so the next ensureConnection
    // creates a brand-new _PulseSharedWs instead of a stale
    // `authenticated=true` shell from the dead connection.
    dropPulseSharedPoolFor(serverUrl);
    // Tiny breather so close() completes before we reopen.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Re-open. ensureConnection rebuilds reader+sender + signal
    // subscriptions and waits for auth before returning.
    await ensureConnection(serverUrl);
  }
}
