import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/signal_broadcaster.dart';
import 'package:pulse_messenger/services/key_manager.dart';
import 'package:pulse_messenger/services/signal_service.dart';
import 'package:pulse_messenger/services/pqc_service.dart';
import 'package:pulse_messenger/models/identity.dart';

SignalBroadcaster _makeBroadcaster({
  Identity? identity,
  String selfId = 'self@wss://relay.test',
}) {
  final keys = KeyManager(SignalService(), PqcService());
  return SignalBroadcaster(
    keys: keys,
    getIdentity: () => identity,
    getSelfId: () => selfId,
  );
}

void main() {
  group('SignalBroadcaster — isOnline / lastSeen', () {
    test('isOnline returns false when no heartbeat received', () {
      final sb = _makeBroadcaster();
      expect(sb.isOnline('contact1'), isFalse);
    });

    test('isOnline returns true immediately after updateLastSeen', () {
      final sb = _makeBroadcaster();
      sb.updateLastSeen('contact1');
      expect(sb.isOnline('contact1'), isTrue);
    });

    test('lastSeenLabel returns empty string for unknown contact', () {
      final sb = _makeBroadcaster();
      expect(sb.lastSeenLabel('nobody'), isEmpty);
    });

    test('lastSeenLabel returns "online" right after update', () {
      final sb = _makeBroadcaster();
      sb.updateLastSeen('c1');
      expect(sb.lastSeenLabel('c1'), equals('online'));
    });
  });

  group('SignalBroadcaster — typing state', () {
    test('isContactTyping returns false initially', () {
      final sb = _makeBroadcaster();
      expect(sb.isContactTyping('c2'), isFalse);
    });

    test('handleTypingEvent sets typing to true and calls callback', () {
      final sb = _makeBroadcaster();
      final emitted = <String>[];
      sb.handleTypingEvent('c3', emitted.add);
      expect(sb.isContactTyping('c3'), isTrue);
      expect(emitted, contains('c3'));
    });

    test('handleTypingEvent timeout clears typing after 4s', () async {
      final sb = _makeBroadcaster();
      final emitted = <String>[];
      sb.handleTypingEvent('c4', emitted.add);
      expect(sb.isContactTyping('c4'), isTrue);
      // Advance time by 4+ seconds
      await Future.delayed(const Duration(milliseconds: 4100));
      expect(sb.isContactTyping('c4'), isFalse);
      // Callback should have been called with 'c4' twice: start + end
      expect(emitted.where((e) => e == 'c4').length, greaterThanOrEqualTo(2));
    }, timeout: Timeout(const Duration(seconds: 10)));

    test('handleTypingEvent resets timer on re-entry', () {
      final sb = _makeBroadcaster();
      final emitted = <String>[];
      sb.handleTypingEvent('c5', emitted.add);
      sb.handleTypingEvent('c5', emitted.add);
      expect(sb.isContactTyping('c5'), isTrue);
      // Should still be typing (timer was reset)
    });

    test('handles 200+ concurrent typing entries (eviction)', () {
      final sb = _makeBroadcaster();
      // Fill up to the eviction threshold
      for (int i = 0; i < 210; i++) {
        sb.handleTypingEvent('contact_$i', (_) {});
      }
      // Should not throw; eviction should have kicked in
      expect(sb.isContactTyping('contact_209'), isTrue);
    });
  });

  group('SignalBroadcaster — dispose', () {
    test('dispose cancels timers without error', () {
      final sb = _makeBroadcaster();
      sb.handleTypingEvent('cx', (_) {});
      expect(() => sb.dispose(), returnsNormally);
    });

    test('isContactTyping returns false after dispose', () {
      final sb = _makeBroadcaster();
      sb.handleTypingEvent('cy', (_) {});
      sb.dispose();
      expect(sb.isContactTyping('cy'), isFalse);
    });
  });

  group('SignalBroadcaster — heartbeats', () {
    test('stopHeartbeats can be called before startHeartbeats', () {
      final sb = _makeBroadcaster();
      expect(() => sb.stopHeartbeats(), returnsNormally);
    });

    test('startHeartbeats and stopHeartbeats lifecycle', () {
      final sb = _makeBroadcaster();
      sb.startHeartbeats(() => []);
      sb.stopHeartbeats();
      // No throw expected
    });
  });
}
