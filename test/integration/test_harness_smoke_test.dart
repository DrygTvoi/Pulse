import 'package:flutter_test/flutter_test.dart';

import '../helpers/storage_isolation.dart';
import '../helpers/test_harness.dart';

void main() {
  setUp(() {
    resetSharedPreferences();
    resetSecureStorageBuckets();
  });

  test('Alice <-> Bob round-trip via TestHarness', () async {
    final bus = InMemoryBus();
    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);

    await alice.addContact(bob);
    await bob.addContact(alice);

    final f = bob.incoming.first;
    await alice.sendText(bob, 'hello');

    final msg = await f.timeout(const Duration(seconds: 5));
    expect(msg.text, 'hello');
    expect(msg.from, contains('alice'));

    await alice.dispose();
    await bob.dispose();
    bus.dispose();
  });

  test('Bidirectional round-trip', () async {
    final bus = InMemoryBus();
    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Alice -> Bob
    final bobFut = bob.incoming.first;
    await alice.sendText(bob, 'hi bob');
    final bobMsg = await bobFut.timeout(const Duration(seconds: 5));
    expect(bobMsg.text, 'hi bob');

    // Bob -> Alice (after the inbound PreKey message bootstraps Bob's
    // session). Because Bob's session is now established we can already
    // encrypt back without an extra addContact.
    final aliceFut = alice.incoming.first;
    await bob.sendText(alice, 'hey alice');
    final aliceMsg = await aliceFut.timeout(const Duration(seconds: 5));
    expect(aliceMsg.text, 'hey alice');

    await alice.dispose();
    await bob.dispose();
    bus.dispose();
  });

  test('Bus dropNext suppresses one delivery', () async {
    final bus = InMemoryBus();
    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);

    await alice.addContact(bob);

    final received = <String>[];
    final sub = bob.incoming.listen((m) => received.add(m.text));

    bus.dropNext('bob');
    await alice.sendText(bob, 'lost');
    await alice.sendText(bob, 'kept');

    // Allow async delivery to drain.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(received, equals(['kept']));

    await sub.cancel();
    await alice.dispose();
    await bob.dispose();
    bus.dispose();
  });
}
