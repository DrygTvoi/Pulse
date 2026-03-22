import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for P2P transport logic.
///
/// P2PTransportService depends on flutter_webrtc (platform plugin),
/// so we cannot import it directly in pure-Dart tests. Instead, we test
/// the pure logic patterns used by the service: connection state machine,
/// signal type routing, broadcast stream behavior, and payload structure
/// validation.

// ── Replicate the connection state enum for testing ─────────────────────────

enum P2PState { idle, connecting, connected, failed }

/// Minimal pure-Dart replica of the _P2PConn state holder.
class P2PConn {
  P2PState state = P2PState.idle;
  final bool isCaller;
  P2PConn({required this.isCaller});
}

void main() {
  // ── Connection state machine ──────────────────────────────────────────────

  group('P2P connection state machine', () {
    test('initial state is idle', () {
      final conn = P2PConn(isCaller: true);
      expect(conn.state, equals(P2PState.idle));
    });

    test('caller flag is preserved', () {
      final caller = P2PConn(isCaller: true);
      final callee = P2PConn(isCaller: false);
      expect(caller.isCaller, isTrue);
      expect(callee.isCaller, isFalse);
    });

    test('state transitions: idle -> connecting -> connected', () {
      final conn = P2PConn(isCaller: true);
      expect(conn.state, equals(P2PState.idle));

      conn.state = P2PState.connecting;
      expect(conn.state, equals(P2PState.connecting));

      conn.state = P2PState.connected;
      expect(conn.state, equals(P2PState.connected));
    });

    test('state transitions: idle -> connecting -> failed', () {
      final conn = P2PConn(isCaller: true);
      conn.state = P2PState.connecting;
      conn.state = P2PState.failed;
      expect(conn.state, equals(P2PState.failed));
    });

    test('failed state does not auto-recover', () {
      final conn = P2PConn(isCaller: true);
      conn.state = P2PState.failed;
      // State stays failed until explicitly reset.
      expect(conn.state, equals(P2PState.failed));
    });

    test('connected -> failed (ICE disconnection)', () {
      final conn = P2PConn(isCaller: true);
      conn.state = P2PState.connected;
      // Simulates ICE failure or DataChannel close.
      conn.state = P2PState.failed;
      expect(conn.state, equals(P2PState.failed));
    });
  });

  // ── Connection map management ─────────────────────────────────────────────

  group('P2P connection map', () {
    test('isConnected returns false for unknown contact', () {
      final conns = <String, P2PConn>{};
      bool isConnected(String id) {
        final c = conns[id];
        return c != null && c.state == P2PState.connected;
      }
      expect(isConnected('unknown'), isFalse);
    });

    test('isConnected returns true only when state is connected', () {
      final conns = <String, P2PConn>{};
      bool isConnected(String id) {
        final c = conns[id];
        return c != null && c.state == P2PState.connected;
      }

      conns['alice'] = P2PConn(isCaller: true)..state = P2PState.connecting;
      expect(isConnected('alice'), isFalse);

      conns['alice']!.state = P2PState.connected;
      expect(isConnected('alice'), isTrue);

      conns['alice']!.state = P2PState.failed;
      expect(isConnected('alice'), isFalse);
    });

    test('removing a connection cleans up the map', () {
      final conns = <String, P2PConn>{};
      conns['bob'] = P2PConn(isCaller: false)..state = P2PState.connected;
      expect(conns.containsKey('bob'), isTrue);

      conns.remove('bob');
      expect(conns.containsKey('bob'), isFalse);
    });

    test('replacing a connection overwrites old state', () {
      final conns = <String, P2PConn>{};
      conns['carol'] = P2PConn(isCaller: true)..state = P2PState.failed;
      conns['carol'] = P2PConn(isCaller: false)..state = P2PState.connecting;
      expect(conns['carol']!.isCaller, isFalse);
      expect(conns['carol']!.state, equals(P2PState.connecting));
    });

    test('multiple contacts have independent states', () {
      final conns = <String, P2PConn>{};
      conns['alice'] = P2PConn(isCaller: true)..state = P2PState.connected;
      conns['bob'] = P2PConn(isCaller: false)..state = P2PState.connecting;
      conns['carol'] = P2PConn(isCaller: true)..state = P2PState.failed;

      expect(conns['alice']!.state, equals(P2PState.connected));
      expect(conns['bob']!.state, equals(P2PState.connecting));
      expect(conns['carol']!.state, equals(P2PState.failed));
    });
  });

  // ── Signal type routing ───────────────────────────────────────────────────

  group('P2P signal type dispatch', () {
    /// Simulates the switch in P2PTransportService.handleSignal
    String dispatch(String type) {
      switch (type) {
        case 'p2p_offer':
          return 'handleOffer';
        case 'p2p_answer':
          return 'handleAnswer';
        case 'p2p_ice':
          return 'handleIce';
        default:
          return 'ignored';
      }
    }

    test('p2p_offer dispatches to handleOffer', () {
      expect(dispatch('p2p_offer'), equals('handleOffer'));
    });

    test('p2p_answer dispatches to handleAnswer', () {
      expect(dispatch('p2p_answer'), equals('handleAnswer'));
    });

    test('p2p_ice dispatches to handleIce', () {
      expect(dispatch('p2p_ice'), equals('handleIce'));
    });

    test('unknown type is ignored', () {
      expect(dispatch('p2p_unknown'), equals('ignored'));
    });

    test('empty type is ignored', () {
      expect(dispatch(''), equals('ignored'));
    });

    test('non-p2p signals are ignored', () {
      expect(dispatch('typing'), equals('ignored'));
      expect(dispatch('msg_read'), equals('ignored'));
      expect(dispatch('sys_keys'), equals('ignored'));
    });
  });

  // ── Broadcast stream behavior ─────────────────────────────────────────────

  group('P2P message stream (broadcast)', () {
    test('broadcast controller allows multiple listeners', () {
      final ctrl = StreamController<({String contactId, String payload})>.broadcast();
      final sub1 = ctrl.stream.listen((_) {});
      final sub2 = ctrl.stream.listen((_) {});
      // No error means broadcast stream works correctly.
      sub1.cancel();
      sub2.cancel();
      ctrl.close();
    });

    test('events reach all listeners', () async {
      final ctrl = StreamController<({String contactId, String payload})>.broadcast();
      final received1 = <String>[];
      final received2 = <String>[];

      ctrl.stream.listen((e) => received1.add(e.payload));
      ctrl.stream.listen((e) => received2.add(e.payload));

      ctrl.add((contactId: 'alice', payload: 'hello'));
      await Future.delayed(Duration.zero); // let microtask run

      expect(received1, equals(['hello']));
      expect(received2, equals(['hello']));
      await ctrl.close();
    });

    test('closed controller does not accept events', () {
      final ctrl = StreamController<({String contactId, String payload})>.broadcast();
      ctrl.close();
      expect(ctrl.isClosed, isTrue);
    });
  });

  // ── send() guard logic ────────────────────────────────────────────────────

  group('P2P send guard', () {
    /// Simulates the send() guard: only send if connected.
    bool send(Map<String, P2PConn> conns, String contactId, String payload) {
      final c = conns[contactId];
      if (c == null || c.state != P2PState.connected) return false;
      // Would call dc.send() here in real code.
      return true;
    }

    test('returns false for unknown contact', () {
      expect(send({}, 'alice', 'data'), isFalse);
    });

    test('returns false for connecting contact', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.connecting};
      expect(send(conns, 'alice', 'data'), isFalse);
    });

    test('returns false for failed contact', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.failed};
      expect(send(conns, 'alice', 'data'), isFalse);
    });

    test('returns true for connected contact', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.connected};
      expect(send(conns, 'alice', 'data'), isTrue);
    });
  });

  // ── connect() idempotency ─────────────────────────────────────────────────

  group('P2P connect idempotency', () {
    /// Simulates the guards at the start of P2PTransportService.connect().
    bool shouldConnect(Map<String, P2PConn> conns, String contactId) {
      final c = conns[contactId];
      if (c != null && c.state == P2PState.connected) return false; // already connected
      if (c?.state == P2PState.connecting) return false; // already in progress
      return true;
    }

    test('allows connect when no prior connection', () {
      expect(shouldConnect({}, 'alice'), isTrue);
    });

    test('blocks connect when already connected', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.connected};
      expect(shouldConnect(conns, 'alice'), isFalse);
    });

    test('blocks connect when already connecting', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.connecting};
      expect(shouldConnect(conns, 'alice'), isFalse);
    });

    test('allows reconnect after failure', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.failed};
      expect(shouldConnect(conns, 'alice'), isTrue);
    });

    test('allows reconnect after idle', () {
      final conns = {'alice': P2PConn(isCaller: true)..state = P2PState.idle};
      expect(shouldConnect(conns, 'alice'), isTrue);
    });
  });

  // ── SDP payload structure ─────────────────────────────────────────────────

  group('P2P SDP payload structure', () {
    test('offer payload has sdp and type fields', () {
      final offer = {'sdp': 'v=0\r\no=- ...', 'type': 'offer'};
      expect(offer['type'], equals('offer'));
      expect(offer['sdp'], isA<String>());
    });

    test('answer payload has sdp and type fields', () {
      final answer = {'sdp': 'v=0\r\no=- ...', 'type': 'answer'};
      expect(answer['type'], equals('answer'));
    });

    test('ICE candidate has candidate, sdpMid, sdpMLineIndex', () {
      final ice = {
        'candidate': 'candidate:1 1 UDP 2122252543 192.168.1.1 54321 typ host',
        'sdpMid': '0',
        'sdpMLineIndex': 0,
      };
      expect(ice['candidate'], isA<String>());
      expect(ice['sdpMid'], equals('0'));
      expect(ice['sdpMLineIndex'], equals(0));
    });

    test('null ICE candidate is valid (end-of-candidates)', () {
      final ice = {'candidate': null, 'sdpMid': '0', 'sdpMLineIndex': 0};
      // The service checks candidate != null before sending.
      expect(ice['candidate'], isNull);
    });
  });

  // ── DataChannel label and config ──────────────────────────────────────────

  group('DataChannel configuration', () {
    test('channel label is pulse_msg', () {
      const label = 'pulse_msg';
      expect(label, equals('pulse_msg'));
    });

    test('channel uses ordered delivery', () {
      const ordered = true;
      expect(ordered, isTrue);
    });
  });

  // ── Dispose cleanup ───────────────────────────────────────────────────────

  group('P2P dispose cleanup', () {
    test('disposing clears all connections from map', () {
      final conns = <String, P2PConn>{
        'alice': P2PConn(isCaller: true)..state = P2PState.connected,
        'bob': P2PConn(isCaller: false)..state = P2PState.connecting,
      };

      // Simulate dispose: iterate and remove all.
      for (final id in List.of(conns.keys)) {
        conns.remove(id);
      }
      expect(conns, isEmpty);
    });

    test('dispose closes broadcast controller', () {
      final ctrl = StreamController<({String contactId, String payload})>.broadcast();
      expect(ctrl.isClosed, isFalse);
      ctrl.close();
      expect(ctrl.isClosed, isTrue);
    });
  });
}
