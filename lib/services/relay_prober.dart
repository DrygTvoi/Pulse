import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../constants.dart';
import 'nostr_event_builder.dart' as eb;

/// Probes [kBootstrapRelays] and returns a RANDOMLY-CHOSEN relay URL among
/// those that accept a WebSocket connection AND accept BOTH kind:1059
/// (gift-wrap DMs) and kind:10009 (Signal key publish) writes.
/// Falls back to [kDefaultNostrRelay] on timeout.
///
/// Why random (not first-responder-wins): always picking the fastest relay
/// causes every new account in the same geographic region to converge on
/// the same two relays, which looks like an attack to those relays and hurts
/// network health overall.
///
/// Why both kinds: some relays accept kind:1059 but reject kind:10009 with
/// "blocked: kind not allowed" (observed with relay.nos.social). Picking
/// such a relay as primary silently breaks key publish → contacts can't
/// fetch our Signal identity and E2EE fails.
///
/// Why the fanout check: some relays ACK writes with OK=true but never
/// fan them out to active subscriptions (observed with
/// relay.layer.systems) — from the user's view messages "leave but never
/// arrive". The probe also SUBs before publishing and requires the
/// gift-wrap event to come back over the subscription.
///
/// Designed to run in the background while the user fills in setup fields.
/// Typical resolution: ~1.5 s on a healthy network.
Future<String> probeBootstrapRelays({
  Duration timeout = const Duration(seconds: 6),
  Duration gatherWindow = const Duration(milliseconds: 1200),
}) async {
  final sockets = <WebSocket>[];
  final dmCapable = <String>[];
  final firstDmHit = Completer<void>();

  // Shuffle to spread traffic uniformly across the bootstrap list.
  final relays = List<String>.from(kBootstrapRelays)..shuffle();

  // Generate one ephemeral identity for all DM probes — the events are
  // disposable, signed only by this key, and never read.
  final priv = eb.generateRandomPrivkey();
  final pub = eb.derivePubkeyHex(priv);
  final probeEvents = await Future.wait([
    eb.buildEvent(
      privkeyHex: priv,
      kind: 1059,
      content: 'AQ==',
      tags: [['p', pub]],
    ),
    eb.buildEvent(
      privkeyHex: priv,
      kind: 10009,
      content: '',
      tags: const [],
    ),
  ]);
  final dmEventId = probeEvents[0]['id'] as String;
  final expectedIdKinds = {
    dmEventId: 1059,
    probeEvents[1]['id'] as String: 10009,
  };
  final wireFrames = [
    jsonEncode(['EVENT', probeEvents[0]]),
    jsonEncode(['EVENT', probeEvents[1]]),
  ];

  for (final url in relays) {
    WebSocket.connect(url, headers: {'Origin': 'https://pulse.im'})
        .timeout(timeout)
        .then((ws) {
      sockets.add(ws);
      // Send both events; relay must (a) ACK both with OK=true AND
      // (b) fan out the gift-wrap back to our subscription.
      final results = <int, bool>{};
      var delivered = false;
      final accepted = Completer<bool>();
      final subId = 'boot_${DateTime.now().microsecondsSinceEpoch}';
      void check() {
        if (accepted.isCompleted) return;
        if (results.length == expectedIdKinds.length &&
            results.values.every((v) => v) &&
            delivered) {
          accepted.complete(true);
        }
      }
      final sub = ws.listen((data) {
        try {
          final msg = jsonDecode(data as String);
          if (msg is! List || msg.isEmpty) return;
          if (msg[0] == 'OK' && msg.length >= 3) {
            final kind = expectedIdKinds[msg[1]];
            if (kind != null) {
              results[kind] = msg[2] == true;
              if (msg[2] != true && !accepted.isCompleted) {
                accepted.complete(false);
                return;
              }
              check();
            }
          } else if (msg[0] == 'EVENT' && msg.length >= 3 && msg[1] == subId) {
            final ev = msg[2];
            if (ev is Map && ev['id'] == dmEventId) {
              delivered = true;
              check();
            }
          }
        } catch (_) {}
      }, onError: (_) {
        if (!accepted.isCompleted) accepted.complete(false);
      }, onDone: () {
        if (!accepted.isCompleted) accepted.complete(false);
      });
      try {
        // SUB before EVENT so the relay has a live subscription when
        // our own publish is processed.
        ws.add(jsonEncode(['REQ', subId, {
          '#p': [pub],
          'kinds': [1059],
          'limit': 5,
        }]));
        ws.add(wireFrames[0]);
        ws.add(wireFrames[1]);
      } catch (_) {
        if (!accepted.isCompleted) accepted.complete(false);
      }
      accepted.future
          .timeout(const Duration(seconds: 6), onTimeout: () => false)
          .then((ok) {
        sub.cancel().catchError((_) {});
        if (ok) {
          dmCapable.add(url);
          if (!firstDmHit.isCompleted) firstDmHit.complete();
        }
      });
    }).catchError((_) {
      // Relay failed WS connect — ignore.
    });
  }

  // Wait for the first DM-capable relay (not just the first WS responder),
  // or the overall timeout.
  final timeoutFuture = Future.delayed(timeout);
  await Future.any([firstDmHit.future, timeoutFuture]);

  // After the first DM-capable response, collect a few more briefly so
  // random selection has real alternatives instead of the single fastest.
  if (dmCapable.isNotEmpty) {
    await Future.delayed(gatherWindow);
  }

  // Clean up stragglers.
  for (final ws in sockets) {
    try { await ws.close(); } catch (_) {}
  }

  if (dmCapable.isEmpty) return kDefaultNostrRelay;
  return dmCapable[Random.secure().nextInt(dmCapable.length)];
}
