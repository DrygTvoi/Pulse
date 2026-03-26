import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/contact.dart';

// ── Helpers that mirror the production logic ──────────────────────────────────
//
// These functions extract the pure algorithmic logic from ChatController so we
// can test it without standing up the full singleton and its dependencies.

/// Mirrors ChatController._sendToContact's alternate-address ordering:
/// shuffle for fairness among ties, then stable-sort by descending success count.
List<String> sortAlternates(
  List<String> alternates,
  Map<String, int> successCount, {
  int? seed, // fixed seed → deterministic shuffle in tests
}) {
  final order = [...alternates];
  // Deterministic shuffle for tests (production uses random).
  if (seed != null) {
    // Simple Fisher-Yates with fixed seed.
    var rng = seed;
    int next(int max) {
      rng = (rng * 1664525 + 1013904223) & 0xFFFFFFFF;
      return rng % max;
    }
    for (var i = order.length - 1; i > 0; i--) {
      final j = next(i + 1);
      final tmp = order[i]; order[i] = order[j]; order[j] = tmp;
    }
  }
  order.sort((a, b) =>
      (successCount[b] ?? 0).compareTo(successCount[a] ?? 0));
  return order;
}

/// Mirrors the addr_update handler in ChatController._initSignalDispatcher.
Contact applyAddrUpdate(Contact contact, String newPrimary, List<String> all) {
  final alts = <String>{...contact.alternateAddresses};
  if (contact.databaseId.isNotEmpty && contact.databaseId != newPrimary) {
    alts.add(contact.databaseId);
  }
  alts.addAll(all.where((a) => a != newPrimary));
  alts.remove(newPrimary);
  return contact.copyWith(
    databaseId: newPrimary,
    alternateAddresses: alts.toList(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── SmartRouter: alternate address ordering ──────────────────────────────

  group('SmartRouter ordering', () {
    const nostr1 = 'pk@wss://relay1.com';
    const nostr2 = 'pk@wss://relay2.com';
    const oxen   = 'abc123def456';
    const firebase = 'user@https://project.firebaseio.com';

    test('higher success count goes first', () {
      final counts = {nostr1: 5, nostr2: 2, oxen: 8, firebase: 1};
      final result = sortAlternates([nostr1, nostr2, oxen, firebase], counts, seed: 42);
      expect(result.first, oxen);   // 8 successes
      expect(result[1], nostr1);    // 5 successes
      expect(result[2], nostr2);    // 2 successes
      expect(result.last, firebase);    // 1 success
    });

    test('zero-count addresses all appear (not skipped)', () {
      final counts = <String, int>{};
      final result = sortAlternates([nostr1, nostr2, oxen], counts, seed: 1);
      expect(result, hasLength(3));
      expect(result, containsAll([nostr1, nostr2, oxen]));
    });

    test('single alternate returned as-is', () {
      final result = sortAlternates([nostr1], {nostr1: 3}, seed: 0);
      expect(result, [nostr1]);
    });

    test('equal counts preserves all addresses', () {
      final counts = {nostr1: 3, nostr2: 3, oxen: 3};
      final result = sortAlternates([nostr1, nostr2, oxen], counts, seed: 7);
      expect(result, hasLength(3));
      expect(result, containsAll([nostr1, nostr2, oxen]));
    });

    test('new address with no history sorted last', () {
      final counts = {nostr1: 10, nostr2: 7};
      final result = sortAlternates([nostr1, nostr2, oxen], counts, seed: 0);
      // oxen has no count (0) → last
      expect(result.last, oxen);
      expect(result.first, nostr1);
    });

    test('success count update raises address priority', () {
      final counts = {nostr1: 1, nostr2: 5};
      final before = sortAlternates([nostr1, nostr2], counts, seed: 0);
      expect(before.first, nostr2);

      counts[nostr1] = 10; // nostr1 delivered successfully many times
      final after = sortAlternates([nostr1, nostr2], counts, seed: 0);
      expect(after.first, nostr1);
    });
  });

  // ── addr_update: contact merge logic ────────────────────────────────────

  group('addr_update contact merge', () {
    late Contact bob;

    setUp(() {
      bob = Contact(
        id: 'bob-id',
        name: 'Bob',
        provider: 'Nostr',
        databaseId: 'pk@wss://relay.damus.io',
        publicKey: 'pk',
        alternateAddresses: [
          'pk@wss://nostr.wine',
          'pk123@wss://relay.snort.social',
        ],
      );
    });

    test('new primary is set correctly', () {
      final updated = applyAddrUpdate(
        bob,
        'pk@wss://relay.snort.social',
        ['pk@wss://relay.snort.social', 'pk@wss://relay.damus.io'],
      );
      expect(updated.databaseId, 'pk@wss://relay.snort.social');
    });

    test('old primary is preserved as alternate', () {
      final updated = applyAddrUpdate(
        bob,
        'pk@wss://relay.snort.social',
        ['pk@wss://relay.snort.social', 'pk@wss://relay.damus.io'],
      );
      expect(updated.alternateAddresses, contains('pk@wss://relay.damus.io'));
    });

    test('new primary is NOT in alternates (no duplicates)', () {
      final newPrimary = 'pk@wss://relay.snort.social';
      final updated = applyAddrUpdate(bob, newPrimary, [newPrimary]);
      expect(updated.alternateAddresses, isNot(contains(newPrimary)));
    });

    test('existing alternates are preserved', () {
      final updated = applyAddrUpdate(
        bob,
        'pk@wss://relay.snort.social',
        ['pk@wss://relay.snort.social'],
      );
      expect(updated.alternateAddresses, contains('pk@wss://nostr.wine'));
      expect(updated.alternateAddresses, contains('pk123@wss://relay.snort.social'));
    });

    test('all addresses from update are added to alternates', () {
      final updated = applyAddrUpdate(
        bob,
        'pk@wss://relay.snort.social',
        [
          'pk@wss://relay.snort.social', // new primary
          'pk@wss://new-relay.com',       // new alternate
        ],
      );
      expect(updated.alternateAddresses, contains('pk@wss://new-relay.com'));
    });

    test('same primary update is idempotent', () {
      // Bob sends addr_update with same primary he already has
      final updated = applyAddrUpdate(
        bob,
        bob.databaseId,
        [bob.databaseId, ...bob.alternateAddresses],
      );
      expect(updated.databaseId, bob.databaseId);
      expect(updated.alternateAddresses, hasLength(bob.alternateAddresses.length));
    });

    test('after update: contact can still be reached via old primary', () {
      final updated = applyAddrUpdate(
        bob,
        'pk@wss://relay.snort.social',
        ['pk@wss://relay.snort.social'],
      );
      // All delivery paths: primary + alternates
      final allPaths = [updated.databaseId, ...updated.alternateAddresses];
      expect(allPaths, contains('pk@wss://relay.damus.io')); // original primary still reachable
    });

    test('multiple consecutive updates accumulate alternates', () {
      // First update: damus → snort
      final step1 = applyAddrUpdate(
        bob,
        'pk@wss://relay.snort.social',
        ['pk@wss://relay.snort.social'],
      );
      // Second update: snort → nos.lol
      final step2 = applyAddrUpdate(
        step1,
        'pk@wss://nos.lol',
        ['pk@wss://nos.lol'],
      );
      final allPaths = [step2.databaseId, ...step2.alternateAddresses];
      // All three addresses should be known
      expect(allPaths, contains('pk@wss://nos.lol'));          // current primary
      expect(allPaths, contains('pk@wss://relay.snort.social')); // 1st update
      expect(allPaths, contains('pk@wss://relay.damus.io'));      // original
    });
  });

  // ── Failover: _promoteAddress trigger logic ──────────────────────────────

  group('Failover: address promotion logic', () {
    test('healthy alternate is selected when primary fails', () {
      final allAddresses = [
        'pk@wss://relay.damus.io',  // primary — failed
        'pk@wss://nostr.wine',       // healthy
        'pk@oxen://abc123',          // healthy
      ];
      final adapterHealth = {
        'pk@wss://relay.damus.io': false,
        'pk@wss://nostr.wine': true,
        'pk@oxen://abc123': true,
      };
      final failedAddr = allAddresses.first;

      final newPrimary = allAddresses.firstWhere(
        (a) => a != failedAddr && (adapterHealth[a] ?? true),
        orElse: () => '',
      );
      expect(newPrimary, 'pk@wss://nostr.wine');
    });

    test('no promotion when no healthy alternate exists', () {
      final allAddresses = ['pk@wss://damus.io', 'pk@wss://nostr.wine'];
      final adapterHealth = {
        'pk@wss://damus.io': false,
        'pk@wss://nostr.wine': false,
      };
      final newPrimary = allAddresses.firstWhere(
        (a) => a != allAddresses.first && (adapterHealth[a] ?? true),
        orElse: () => '',
      );
      expect(newPrimary, isEmpty); // no promotion → stay on broken primary
    });

    test('secondary adapter failure does not trigger promotion', () {
      // Promotion logic: find a new primary only when the CURRENT primary fails.
      // If a secondary fails but the primary is still healthy, primary stays.
      const primary = 'pk@wss://damus.io';
      const secondary = 'pk@wss://nostr.wine';
      final allAddresses = [primary, secondary];
      final adapterHealth = {primary: true, secondary: false};

      // Simulate: secondary failed, try to find a new primary.
      // (In production, _onAdapterHealthChange only promotes when the failed
      //  address IS the current primary. Here we mirror that guard.)
      final failedAddr = secondary;
      final currentPrimary = primary;

      final newPrimary = (failedAddr == currentPrimary)
          ? allAddresses.firstWhere(
              (a) => a != currentPrimary && (adapterHealth[a] ?? true),
              orElse: () => '',
            )
          : currentPrimary; // not the primary — no change

      expect(newPrimary, primary); // primary is unchanged
      expect(newPrimary, isNot(secondary)); // we did not promote secondary
    });

    test('first healthy alternate in list wins promotion', () {
      final allAddresses = [
        'pk@wss://primary.com',
        'pk@wss://alt1.com', // unhealthy
        'pk@wss://alt2.com', // healthy ← should win
        'pk@wss://alt3.com', // healthy
      ];
      final adapterHealth = {
        'pk@wss://primary.com': false,
        'pk@wss://alt1.com': false,
        'pk@wss://alt2.com': true,
        'pk@wss://alt3.com': true,
      };
      final newPrimary = allAddresses.firstWhere(
        (a) => a != allAddresses.first && (adapterHealth[a] ?? true),
        orElse: () => '',
      );
      expect(newPrimary, 'pk@wss://alt2.com');
    });
  });
}
