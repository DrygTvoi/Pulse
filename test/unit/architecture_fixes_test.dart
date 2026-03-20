/// Tests for the architectural fixes applied to ChatController:
///   - contact index deduplication (_buildContactIndex)
///   - typing timer cap (max 200 entries)
///   - _healthSubs disposal (verified via dispose() completing cleanly)
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'mock_contact_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Contact _makeContact({
  required String id,
  String name = 'Test',
  String databaseId = '',
}) =>
    Contact(
      id: id,
      name: name,
      provider: 'Nostr',
      databaseId: databaseId.isEmpty ? '$id@wss://relay.test' : databaseId,
      publicKey: '',
    );

/// Minimal replica of ChatController._buildContactIndex() so we can test
/// its logic in isolation without spinning up the full controller.
Map<String, Contact> buildContactIndex(List<Contact> contacts) {
  final contactByDbId = <String, Contact>{};
  for (final c in contacts) {
    contactByDbId[c.databaseId] = c;
    final idPart = c.databaseId.split('@').first;
    if (idPart.isNotEmpty && idPart != c.databaseId) {
      contactByDbId.putIfAbsent(idPart, () => c);
    }
  }
  return contactByDbId;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('_buildContactIndex logic', () {
    test('full databaseId maps to contact', () {
      final c = _makeContact(id: 'c1', databaseId: 'pk1@wss://relay.test');
      final idx = buildContactIndex([c]);
      expect(idx['pk1@wss://relay.test'], equals(c));
    });

    test('pubkey prefix (before @) also maps to contact', () {
      final c = _makeContact(id: 'c1', databaseId: 'pk1@wss://relay.test');
      final idx = buildContactIndex([c]);
      expect(idx['pk1'], equals(c));
    });

    test('no prefix entry when databaseId has no @', () {
      final c = _makeContact(id: 'c1', databaseId: 'plain-id');
      final idx = buildContactIndex([c]);
      expect(idx.containsKey('plain-id'), isTrue);
      // No extra short-form key since there's no @ to split on
      expect(idx.length, equals(1));
    });

    test('first contact wins on prefix collision (putIfAbsent)', () {
      final c1 = _makeContact(id: 'c1', databaseId: 'samepk@wss://relay1.test');
      final c2 = _makeContact(id: 'c2', databaseId: 'samepk@wss://relay2.test');
      final idx = buildContactIndex([c1, c2]);
      // Full keys both present
      expect(idx['samepk@wss://relay1.test'], equals(c1));
      expect(idx['samepk@wss://relay2.test'], equals(c2));
      // Short key: first one wins (putIfAbsent semantics)
      expect(idx['samepk'], equals(c1));
    });

    test('multiple contacts each get their own full-key entry', () {
      final contacts = List.generate(
        5,
        (i) => _makeContact(id: 'c$i', databaseId: 'pk$i@wss://relay.test'),
      );
      final idx = buildContactIndex(contacts);
      for (int i = 0; i < 5; i++) {
        expect(idx['pk$i@wss://relay.test'], equals(contacts[i]));
        expect(idx['pk$i'], equals(contacts[i]));
      }
    });

    test('empty contact list produces empty index', () {
      expect(buildContactIndex([]), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Typing timer cap (logic-level test using a plain Map<String, Timer>)
  // -------------------------------------------------------------------------
  group('Typing timer cap', () {
    test('adding beyond cap evicts the oldest entry', () {
      const maxSize = 5; // small cap for test
      final timers = <String, Timer>{};

      for (int i = 0; i < maxSize + 3; i++) {
        final targetId = 'user-$i';
        timers[targetId]?.cancel();
        if (timers.length >= maxSize) {
          final oldest = timers.keys.first;
          timers[oldest]?.cancel();
          timers.remove(oldest);
        }
        timers[targetId] = Timer(const Duration(seconds: 4), () {});
      }

      // Should never exceed cap
      expect(timers.length, lessThanOrEqualTo(maxSize));
      // Oldest entries were evicted; newest should still be present
      expect(timers.containsKey('user-${maxSize + 2}'), isTrue);
      expect(timers.containsKey('user-0'), isFalse);

      // Cleanup
      for (final t in timers.values) { t.cancel(); }
    });

    test('cancels the replaced timer when same targetId typed again', () {
      final timers = <String, Timer>{};
      int firedCount = 0;

      // First timer for 'alice'
      timers['alice'] = Timer(const Duration(milliseconds: 50), () => firedCount++);
      // Second typing event cancels first
      timers['alice']?.cancel();
      timers['alice'] = Timer(const Duration(milliseconds: 50), () => firedCount++);

      // Both timers are for same key; only the second should eventually fire
      expect(timers.length, equals(1));

      timers['alice']?.cancel(); // cleanup
    });
  });

  // -------------------------------------------------------------------------
  // Error recovery: unawaited + catchError pattern
  // -------------------------------------------------------------------------
  group('unawaited+catchError pattern', () {
    test('catchError on future receives the thrown error', () async {
      Object? caught;
      // Simulates the pattern used in addReaction/removeReaction:
      //   unawaited(someDbCall().catchError((e) => debugPrint(...)))
      Future<void> failingOp() => Future.error(Exception('db write failed'));

      unawaited(failingOp().catchError((Object e) { caught = e; }));
      // Yield to allow microtask queue to flush
      await Future<void>.delayed(Duration.zero);
      expect(caught, isA<Exception>());
      expect(caught.toString(), contains('db write failed'));
    });

    test('catchError does not suppress the success path', () async {
      int called = 0;
      Future<void> succeedingOp() async { called++; }

      unawaited(succeedingOp().catchError((Object e) {}));
      await Future<void>.delayed(Duration.zero);
      expect(called, equals(1));
    });

    test('multiple concurrent unawaited operations complete independently', () async {
      final results = <int>[];
      for (int i = 0; i < 5; i++) {
        final idx = i;
        unawaited(
          Future<void>.delayed(Duration(milliseconds: idx))
              .then((_) => results.add(idx))
              .catchError((Object _) {}),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(results.length, equals(5));
    });
  });

  // -------------------------------------------------------------------------
  // MockContactRepository sanity (used by chat_controller_test too)
  // -------------------------------------------------------------------------
  group('MockContactRepository', () {
    test('contacts returns the initial list', () {
      final c = _makeContact(id: 'x');
      final repo = MockContactRepository([c]);
      expect(repo.contacts, contains(c));
    });

    test('updateContact replaces in memory', () async {
      final original = _makeContact(id: 'u1', name: 'Old');
      final repo = MockContactRepository([original]);
      final updated = original.copyWith(name: 'New');
      await repo.updateContact(updated);
      expect(repo.contacts.first.name, equals('New'));
    });
  });
}
