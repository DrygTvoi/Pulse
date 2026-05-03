part of 'chat_controller.dart';

/// Inbox initialization: sets up all 5 transport readers (Nostr, Pulse,
/// Nostr, Session, Pulse, LAN), wires their message/signal streams into
/// [_c._handleIncomingMessages] and SignalDispatcher, and seeds secondary
/// addresses so peers can reach us on every available transport.
class _InboxInitializer {
  final ChatController _c;
  _InboxInitializer(this._c);

  Future<void> _initInbox() async {
    if (_c._identity == null) return;

    // Ensure pulse_privkey exists for cross-transport sends (migrate old accounts).
    final existingPulseKey = await ChatController._secureStorage.read(key: 'pulse_privkey');
    if (existingPulseKey == null || existingPulseKey.isEmpty) {
      final nostrKey = await ChatController._secureStorage.read(key: 'nostr_privkey');
      if (nostrKey != null && nostrKey.isNotEmpty) {
        // Derive Pulse key from Nostr key as HKDF-like fallback
        final seed = Uint8List.fromList(hex.decode(nostrKey));
        final hmac = hash_lib.Hmac(hash_lib.sha256, utf8.encode('pulse-ed25519-seed'));
        final derived = hmac.convert(seed);
        await ChatController._secureStorage.write(key: 'pulse_privkey', value: hex.encode(derived.bytes));
        seed.fillRange(0, seed.length, 0);
        debugPrint('[Chat] Derived pulse_privkey from nostr_privkey (migration)');
      }
    }

    String apiKey = _c._identity!.adapterConfig['token'] ?? '';
    String dbId;
    String providerName;

    switch (_c._identity!.preferredAdapter) {
      case 'nostr':
        providerName = 'Nostr';
        var privkey = await ChatController._secureStorage.read(key: 'nostr_privkey') ?? '';
        // Recover from recovery_key when the secure-storage privkey has been
        // wiped or never landed (Windows Keystore migration loss, fresh
        // install with imported identity, etc). Without this guard we fall
        // through to using _c._identity.id (a UUID) as the "pubkey", which
        // poisons every outgoing Nostr address: invite links carry
        // <UUID>@wss://… which BigInt.parse can't read → every sendSignal
        // dies with FormatException and the contact effectively goes dark.
        if (privkey.isEmpty) {
          privkey = await _c._recoverTransportKey('nostr_privkey');
        }
        final prefs = await _c._getPrefs();
        final relay = _c._identity!.adapterConfig['relay'] ??
            prefs.getString('nostr_relay') ?? ChatController._kDefaultNostrRelay;
        apiKey = jsonEncode({'privkey': privkey, 'relay': relay});
        dbId = relay;
        if (privkey.isNotEmpty) {
          try {
            final pubkey = deriveNostrPubkeyHex(privkey);
            _c._selfId = '$pubkey@$relay';
          } catch (e) {
            debugPrint('[ChatController] Invalid Nostr private key: $e');
            _c._connectionStatus = ConnectionStatus.disconnected;
            _c._scheduleNotify();
            return;
          }
        } else {
          // Last-resort fallback: identity has no usable Nostr key and
          // recovery failed too. Refuse to fabricate a UUID-shaped "pubkey"
          // — it's worse than no Nostr at all because it leaks broken
          // addresses into invite links. Bail and let the user re-import
          // the recovery key from Settings → Security.
          debugPrint('[ChatController] Nostr-primary identity but no privkey '
              'and recovery_key derivation failed. Refusing to fabricate a '
              'UUID-pubkey — Nostr disabled until recovery key is restored.');
          _c._connectionStatus = ConnectionStatus.disconnected;
          _c._scheduleNotify();
          return;
        }
      case 'session':
        providerName = 'Session';
        {
          await SessionKeyService.instance.initialize();
          _c._selfId = SessionKeyService.instance.sessionId;
          final prefs = await _c._getPrefs();
          final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          apiKey = nodeUrl;
          dbId = _c._selfId;
        }
      case 'pulse':
        providerName = 'Pulse';
        {
          var privkey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
          if (privkey.isEmpty) {
            privkey = await _c._recoverTransportKey('pulse_privkey');
          }
          final prefs = await _c._getPrefs();
          final serverUrl = prefs.getString('pulse_server_url') ?? '';
          final invite = prefs.getString('pulse_invite_code') ?? '';
          apiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl, 'invite': invite});
          dbId = serverUrl;
          if (privkey.isNotEmpty) {
            try {
              final seed = Uint8List.fromList(hex.decode(privkey));
              final pubkey = await ed25519PubkeyFromSeed(seed);
              _c._selfId = '$pubkey@$serverUrl';
            } catch (e) {
              debugPrint('[ChatController] Invalid Pulse private key: $e');
              _c._connectionStatus = ConnectionStatus.disconnected;
              _c._scheduleNotify();
              return;
            }
          } else {
            // Same rationale as Nostr: never fabricate a UUID-pubkey.
            debugPrint('[ChatController] Pulse-primary identity but no privkey '
                'and recovery_key derivation failed. Refusing to use UUID — '
                'Pulse disabled until recovery key is restored.');
            _c._connectionStatus = ConnectionStatus.disconnected;
            _c._scheduleNotify();
            return;
          }
        }
      default:
        providerName = 'Nostr';
        dbId = _c._identity!.adapterConfig['dbId'] ?? _c._identity!.id;
        _c._selfId = dbId;
    }

    await InboxManager().configureSelf(providerName, apiKey, dbId);
    _c._connectionStatus = ConnectionStatus.connected;
    sentryBreadcrumb('Adapter connected: $providerName', category: 'adapter');
    _c._scheduleNotify();

    // (Delivery stats removed — transport-priority routing replaces promotion)

    // Republish Signal bundle whenever a preKey is consumed.
    _c._signalService.onPreKeyConsumed = () => unawaited(_c._republishKeys());

    // Re-publish bundle to ALL transports when prekeys are exhausted.
    _c._bundleRefreshSub?.cancel();
    _c._bundleRefreshSub = _c._signalService.onBundleRefresh.listen((_) {
      debugPrint('[Chat] PreKeys exhausted — re-publishing bundle to all transports');
      unawaited(_c._republishAllKeys());
    });

    // Surface prekey exhaustion attack warnings.
    _c._signalSubs.add(_c._signalService.onPreKeyExhaustionWarning.listen((msg) {
      if (!_c._e2eeFailCtrl.isClosed) _c._e2eeFailCtrl.add('⚠️ $msg');
    }));

    unawaited(_c._keys.maybePublishOwnKeys(
        _c._identity!.preferredAdapter, _c._selfId, _c._identity!.adapterConfig['token'] ?? ''));

    unawaited(_c._restoreScheduledMessages());

    // Heartbeats via broadcaster
    _c._broadcaster.startHeartbeats(() => _c._contacts.contacts);

    final newAddresses = <String>[_c.myAddress];
    _c._adapterHealth.clear();
    for (final s in _c._healthSubs) { s.cancel(); }
    _c._healthSubs.clear();

    _c._initSignalDispatcher();

    if (InboxManager().reader != null) {
      final r = InboxManager().reader!;
      final primaryTransport = ChatController._providerFromAddress(_c.myAddress);
      _c._messageSubs.add(r.listenForMessages().listen(_c._handleIncomingMessages));
      _c._signalSubs.add(r.listenForSignals().listen(
          (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: primaryTransport)));
      _c._adapterHealth[_c.myAddress] = true;
      _c._healthSubs.add(r.healthChanges.listen((h) => _c._onAdapterHealthChange(_c.myAddress, h)));
    }

    // Register contact relays as secondary subscriptions so fallback publishes
    // (when a contact's relay rate-limits us) are still received by both sides.
    final mainReader = InboxManager().reader;
    if (mainReader is NostrInboxReader) {
      for (final c in _c._contacts.contacts) {
        if (c.provider != 'Nostr') continue;
        final dbId = c.databaseId;
        final wsIdx = dbId.indexOf('@wss://');
        final wsIdx2 = dbId.indexOf('@ws://');
        final atIdx = wsIdx != -1 ? wsIdx : (wsIdx2 != -1 ? wsIdx2 : -1);
        if (atIdx != -1) {
          final contactRelay = dbId.substring(atIdx + 1);
          mainReader.addSecondaryRelay(contactRelay);
        }
      }
      // Subscribe to probe/adaptive relays for own inbox redundancy.
      final prefs = await _c._getPrefs();
      final probeRelay = prefs.getString('probe_nostr_relay') ?? '';
      final adaptiveRelay = prefs.getString('adaptive_cf_relay') ?? '';
      if (probeRelay.isNotEmpty) {
        mainReader.addSecondaryRelay(
            probeRelay.startsWith('ws') ? probeRelay : 'wss://$probeRelay');
      }
      if (adaptiveRelay.isNotEmpty) {
        mainReader.addSecondaryRelay(adaptiveRelay);
      }
      // Always subscribe to the hardcoded default relay so that fallback
      // publishes (when primary relay rate-limits/rejects) are received.
      mainReader.addSecondaryRelay(ChatController._kDefaultNostrRelay);

      // For Nostr-primary users: also REGISTER additional DM-capable probed
      // relays as our own advertised addresses (up to 4), not just reader
      // subscriptions. Without this, _c._allAddresses had exactly one Nostr
      // entry and contacts saw only a single relay per contact.
      final atIdxOwn = _c.myAddress.indexOf('@');
      if (atIdxOwn > 0) {
        final ownPub = _c.myAddress.substring(0, atIdxOwn);
        final ownPrimaryRelay = _c.myAddress.substring(atIdxOwn + 1);
        final probeRelays = ConnectivityProbeService.instance.lastResult.nostrRelays;
        final advertised = <String>[];
        for (final r in probeRelays) {
          if (advertised.length >= 4) break;
          final relay = r.startsWith('ws') ? r : 'wss://$r';
          if (relay == ownPrimaryRelay) continue;
          mainReader.addSecondaryRelay(relay);
          final addr = '$ownPub@$relay';
          if (!newAddresses.contains(addr)) {
            newAddresses.add(addr);
            _c._adapterHealth[addr] = true;
            advertised.add(relay);
          }
        }
        if (advertised.isNotEmpty) {
          Future.delayed(const Duration(seconds: 8), () {
            _c._pruneDisconnectedSecondaries(ownPub, mainReader, advertised);
          });
          debugPrint('[Chat] Nostr-primary: registered '
              '${advertised.length} secondary relay address(es)');
        }
      }
    }

    // Subscribe to tamper warnings from the Nostr layer.
    _c._signalSubs.add(NostrInboxReader.tamperWarnings.stream.listen((senderId) {
      final short = senderId.length > 8 ? senderId.substring(0, 8) : senderId;
      debugPrint('[Security] MAC tamper warning from $senderId');
      _c._tamperWarningCtrl.add(
          'Tamper detected — a signal from $short… failed integrity check');
    }));

    // Subscribe secondary adapters
    final secondaryCfgs = await _c._loadSecondaryAdapters();
    for (final cfg in secondaryCfgs) {
      final reader = await InboxManager().createAdhocReader(
          cfg['provider']!, cfg['apiKey']!, cfg['databaseId']!);
      if (reader == null) continue;
      final secondaryTransport = cfg['provider']!;
      _c._messageSubs.add(reader.listenForMessages().listen(_c._handleIncomingMessages));
      _c._signalSubs.add(reader.listenForSignals().listen(
          (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: secondaryTransport)));
      final addr = cfg['_c.selfId'] ?? '';
      if (addr.isNotEmpty) {
        newAddresses.add(addr);
        _c._adapterHealth[addr] = true;
        _c._healthSubs.add(reader.healthChanges.listen((h) => _c._onAdapterHealthChange(addr, h)));
      }
      unawaited(_c._keys.publishKeysToAdapter(
          cfg['provider']!, cfg['apiKey']!, cfg['_c.selfId'] ?? ''));
    }

    // Auto-register Pulse inbox if configured but not primary — so we can
    // RECEIVE messages on Pulse even when primary is Nostr/Session/etc.
    // Also adds our Pulse address to allAddresses → contacts learn it via addr_update.
    if (_c._identity!.preferredAdapter != 'pulse') {
      final pulseKey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
      final pulseUrl = (await _c._getPrefs()).getString('pulse_server_url') ?? '';
      if (pulseKey.isNotEmpty && pulseUrl.isNotEmpty) {
        // REUSE existing _c._adhocPulseReader if one is alive — re-subscribe
        // streams (subs were cleared above by _c.reconnectInbox) without
        // creating a SECOND PulseInboxReader. Two readers for the same
        // pubkey would race for the server's "1 connection per pubkey"
        // slot → multi-WS storm → SFU TURN-over-WS dies → calls drop.
        if (_c._adhocPulseReader != null) {
          debugPrint('[Chat] _c._initInbox: reusing existing _c._adhocPulseReader '
              '${identityHashCode(_c._adhocPulseReader)} (re-subscribing streams)');
          final pulseReader = _c._adhocPulseReader!;
          _c._messageSubs.add(pulseReader.listenForMessages().listen(_c._handleIncomingMessages));
          _c._signalSubs.add(pulseReader.listenForSignals().listen(
              (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: 'Pulse')));
          final seed = Uint8List.fromList(hex.decode(pulseKey));
          final pulsePub = await ed25519PubkeyFromSeed(seed);
          final pulseAddr = '$pulsePub@$pulseUrl';
          newAddresses.add(pulseAddr);
          _c._adapterHealth[pulseAddr] = true;
          _c._healthSubs.add(pulseReader.healthChanges.listen((h) => _c._onAdapterHealthChange(pulseAddr, h)));
        } else {
        try {
          final pulseApiKey = jsonEncode({'privkey': pulseKey, 'serverUrl': pulseUrl});
          final pulseReader = await InboxManager().createAdhocReader('Pulse', pulseApiKey, pulseUrl);
          if (pulseReader != null) {
            _c._adhocPulseReader = pulseReader as PulseInboxReader;
            debugPrint('[Chat] _c._initInbox: CREATED new _c._adhocPulseReader '
                '${identityHashCode(pulseReader)} (none existed)');
            _c._messageSubs.add(pulseReader.listenForMessages().listen(_c._handleIncomingMessages));
            _c._signalSubs.add(pulseReader.listenForSignals().listen(
                (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: 'Pulse')));
            final seed = Uint8List.fromList(hex.decode(pulseKey));
            final pulsePub = await ed25519PubkeyFromSeed(seed);
            final pulseAddr = '$pulsePub@$pulseUrl';
            newAddresses.add(pulseAddr);
            _c._adapterHealth[pulseAddr] = true;
            _c._healthSubs.add(pulseReader.healthChanges.listen((h) => _c._onAdapterHealthChange(pulseAddr, h)));
            // Publish Signal keys to Pulse so contacts can fetch our bundle.
            unawaited(_c._keys.publishKeysToAdapter('Pulse', pulseApiKey, pulseAddr));
            debugPrint('[Chat] Auto-registered Pulse secondary inbox: $pulseAddr');
          }
        } catch (e) {
          debugPrint('[Chat] Failed to auto-register Pulse inbox: $e');
        }
        } // close else (existing reader reuse)
      }
    }

    // Auto-register Session inbox so we receive messages sent to our Session ID.
    // Session ID is derived from the same seed on all devices.
    {
      try {
        await SessionKeyService.instance.initialize();
        final sessId = SessionKeyService.instance.sessionId;
        if (sessId.isNotEmpty) {
          final prefs = await _c._getPrefs();
          final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          final sessionReader = await InboxManager().createAdhocReader('Session', nodeUrl, sessId);
          if (sessionReader != null) {
            _c._adhocSessionReader = sessionReader as SessionInboxReader;
            _c._messageSubs.add(sessionReader.listenForMessages().listen(_c._handleIncomingMessages));
            _c._signalSubs.add(sessionReader.listenForSignals().listen(
                (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: 'Session')));
            // Remove any stale Session IDs from secondary adapters — only
            // SessionKeyService's ID is real (derived from current seed).
            newAddresses.removeWhere((a) =>
                a != sessId && RegExp(r'^05[0-9a-fA-F]{64}$').hasMatch(a));
            newAddresses.add(sessId);
            _c._adapterHealth[sessId] = true;
            _c._healthSubs.add(sessionReader.healthChanges.listen((h) => _c._onAdapterHealthChange(sessId, h)));
            unawaited(_c._keys.publishKeysToAdapter('Session', nodeUrl, sessId));
            debugPrint('[Chat] Auto-registered Session secondary inbox: ${sessId.substring(0, 12)}…');
          }
        }
      } catch (e) {
        debugPrint('[Chat] Failed to auto-register Session inbox: $e');
      }
    }

    // Auto-register Nostr inbox if we have a Nostr key but primary isn't Nostr.
    // Subscribe on multiple relays (default + probe results) for redundancy.
    if (_c._identity!.preferredAdapter != 'nostr') {
      try {
        final nostrPriv = await ChatController._secureStorage.read(key: 'nostr_privkey') ?? '';
        if (nostrPriv.isNotEmpty &&
            !newAddresses.any((a) => a.contains('@wss://') || a.contains('@ws://'))) {
          final nostrPub = deriveNostrPubkeyHex(nostrPriv);
          // Primary Nostr relay: user-configured first, probe result second,
          // hardcoded default only as last resort. This keeps new accounts
          // from concentrating on the same bootstrap relay.
          final prefsForNostr = await _c._getPrefs();
          final primaryRelay = prefsForNostr.getString('nostr_relay')
              ?? prefsForNostr.getString('probe_nostr_relay')
              ?? ChatController._kDefaultNostrRelay;
          final apiKey = jsonEncode({'privkey': nostrPriv, 'relay': primaryRelay});
          final nostrReader = await InboxManager().createAdhocReader('Nostr', apiKey, primaryRelay);
          if (nostrReader != null) {
            _c._messageSubs.add(nostrReader.listenForMessages().listen(_c._handleIncomingMessages));
            _c._signalSubs.add(nostrReader.listenForSignals().listen(
                (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: 'Nostr')));
            // Subscribe to additional probed relays as secondary (up to 4 more)
            // so we have redundancy even if two relays fail simultaneously
            // and contacts see multiple usable addresses in our profile.
            final secondaryRelays = <String>[];
            if (nostrReader is NostrInboxReader) {
              final probeRelays = ConnectivityProbeService.instance.lastResult.nostrRelays;
              for (final r in probeRelays) {
                if (secondaryRelays.length >= 4) break;
                final relay = r.startsWith('ws') ? r : 'wss://$r';
                if (relay == primaryRelay) continue;
                nostrReader.addSecondaryRelay(relay);
                secondaryRelays.add(relay);
              }
            }
            // Register primary AND secondary addresses immediately so contacts
            // learn multiple fallback relays from the first addr_update. After
            // a short delay we prune any secondary that didn't actually connect.
            final primaryAddr = '$nostrPub@$primaryRelay';
            newAddresses.add(primaryAddr);
            _c._adapterHealth[primaryAddr] = true;
            _c._healthSubs.add(nostrReader.healthChanges.listen((h) =>
                _c._onAdapterHealthChange(primaryAddr, h)));
            for (final relay in secondaryRelays) {
              final addr = '$nostrPub@$relay';
              newAddresses.add(addr);
              _c._adapterHealth[addr] = true;
            }
            unawaited(_c._keys.publishKeysToAdapter('Nostr', apiKey, primaryAddr));
            if (secondaryRelays.isNotEmpty) {
              Future.delayed(const Duration(seconds: 8), () {
                _c._pruneDisconnectedSecondaries(nostrPub, nostrReader, secondaryRelays);
              });
            }
            debugPrint('[Chat] Auto-registered Nostr inbox: $primaryRelay + ${secondaryRelays.length} secondary');
          }
        }
      } catch (e) {
        debugPrint('[Chat] Failed to auto-register Nostr inbox: $e');
      }
    }

    // Assign all addresses atomically so concurrent readers see a complete list.
    _c._allAddresses = newAddresses;

    // (Session→Pulse revert removed — transport-priority routing eliminates cross-transport promotion)

    // LAN fallback
    _c._lanReader?.close();
    _c._lanSender?.close();
    _c._lanReader = null;
    _c._lanSender = null;
    final lanEnabled = (await _c._getPrefs()).getBool(ChatController._kLanModeEnabled) ?? true;
    if (lanEnabled) {
      _c._lanReader = LanInboxReader();
      _c._lanSender = LanMessageSender();
      await _c._lanReader!.initializeReader('', _c._selfId);
      await _c._lanSender!.initializeSender(_c._selfId);
      _c._messageSubs.add(_c._lanReader!.listenForMessages().listen(_c._handleIncomingMessages));
      _c._signalSubs.add(_c._lanReader!.listenForSignals().listen(
          (sigs) => _c._signalDispatcher!.dispatch(sigs, sourceTransport: 'LAN')));
    }

    NetworkMonitor.instance.startMonitoring(
      onChanged: (isAvailable) {
        if (_c._lanModeActive == isAvailable) {
          _c._lanModeActive = !isAvailable;
          _c._scheduleNotify();
        }
      },
      onNetworkChanged: () {
        debugPrint('[Chat] Network changed — re-probing relays');
        ConnectivityProbeService.instance.forceProbe().then((_) {
          _c.reconnectInbox();
          Future.delayed(const Duration(seconds: 3), _c._flushFailedMessages);
        });
      },
    );

    // P2P DataChannel transport
    P2PTransportService.instance.onSendSignal = (contactId, type, payload) {
      final contact = _c._contacts.findById(contactId);
      if (contact != null) {
        unawaited(_c._broadcaster.sendP2PSignal(contact, type, payload));
      }
    };
    _c._messageSubs.add(P2PTransportService.instance.messageStream.listen((evt) {
      _c._handleP2PMessage(evt.contactId, evt.payload);
    }));
    _c._messageSubs.add(P2PTransportService.instance.binaryStream.listen((evt) {
      _c._handleP2PBinaryFrame(evt.contactId, evt.data);
    }));

    // Broadcast our addresses on every connect so contacts learn any new
    // secondary transport IDs (e.g. changed Session ID after key derivation fix).
    unawaited(Future.delayed(const Duration(seconds: 2), () => _c.broadcastAddressUpdate()));

    _c._scheduleNotify();
  }
}
