import 'dart:async';
import 'dart:io';
import '../constants.dart';

/// Races [kBootstrapRelays] in parallel and returns the first relay URL
/// that accepts a WebSocket connection, or [kDefaultNostrRelay] on timeout.
///
/// Designed to run in the background while the user fills in setup fields.
/// Typical resolution: 200-800 ms on a healthy network.
Future<String> probeBootstrapRelays({
  Duration timeout = const Duration(seconds: 6),
}) async {
  final completer = Completer<String>();
  final sockets = <WebSocket>[];

  // Shuffle to avoid always hammering the same relay first.
  final relays = List<String>.from(kBootstrapRelays)..shuffle();

  for (final url in relays) {
    // Fire all connections in parallel.
    WebSocket.connect(url, headers: {'Origin': 'https://pulse.im'})
        .timeout(timeout)
        .then((ws) {
      if (!completer.isCompleted) {
        completer.complete(url);
      }
      sockets.add(ws);
      ws.close().catchError((_) {});
    }).catchError((_) {
      // This relay failed — ignore.
    });
  }

  // Fallback: if nothing responds within timeout, use default.
  Future.delayed(timeout, () {
    if (!completer.isCompleted) {
      completer.complete(kDefaultNostrRelay);
    }
  });

  final winner = await completer.future;

  // Clean up any straggler connections.
  for (final ws in sockets) {
    try { await ws.close(); } catch (_) {}
  }

  return winner;
}
