import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/services/circuit_breaker_service.dart';

void main() {
  late CircuitBreakerService cb;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cb = CircuitBreakerService.instance;
    await cb.reset();
  });

  group('CircuitBreakerService', () {
    test('initially, no endpoint is skipped', () async {
      expect(await cb.shouldSkip('relay.example.com'), isFalse);
      expect(await cb.shouldSkip('bridge.example.com'), isFalse);
    });

    test('initially, getFailures returns 0', () {
      expect(cb.getFailures('relay.example.com'), 0);
    });

    test('after 1 failure, endpoint is NOT skipped', () async {
      await cb.recordFailure('relay.example.com');
      expect(await cb.shouldSkip('relay.example.com'), isFalse);
      expect(cb.getFailures('relay.example.com'), 1);
    });

    test('after 2 failures (under threshold), endpoint is NOT skipped',
        () async {
      await cb.recordFailure('relay.example.com');
      await cb.recordFailure('relay.example.com');
      expect(await cb.shouldSkip('relay.example.com'), isFalse);
      expect(cb.getFailures('relay.example.com'), 2);
    });

    test(
        'after 3 failures (maxFailures), endpoint IS skipped within backoff window',
        () async {
      await cb.recordFailure('relay.example.com');
      await cb.recordFailure('relay.example.com');
      await cb.recordFailure('relay.example.com');
      expect(cb.getFailures('relay.example.com'), 3);
      // Within the 5-min backoff window, endpoint should be skipped
      expect(await cb.shouldSkip('relay.example.com'), isTrue);
    });

    test('shouldSkipSync returns same result as shouldSkip for loaded state',
        () async {
      // Trigger load by calling an async method
      await cb.shouldSkip('test.endpoint');

      // Under threshold
      await cb.recordFailure('test.endpoint');
      await cb.recordFailure('test.endpoint');
      expect(cb.shouldSkipSync('test.endpoint'), isFalse);

      // At threshold
      await cb.recordFailure('test.endpoint');
      expect(cb.shouldSkipSync('test.endpoint'), isTrue);
    });

    test('shouldSkipSync returns false when state not loaded', () async {
      // For a never-seen endpoint, shouldSkipSync returns false
      expect(cb.shouldSkipSync('unknown.endpoint'), isFalse);
    });

    test('after recordSuccess, endpoint is no longer skipped (reset)',
        () async {
      // Trip the breaker
      await cb.recordFailure('relay.example.com');
      await cb.recordFailure('relay.example.com');
      await cb.recordFailure('relay.example.com');
      expect(await cb.shouldSkip('relay.example.com'), isTrue);

      // Record success resets breaker
      await cb.recordSuccess('relay.example.com');
      expect(await cb.shouldSkip('relay.example.com'), isFalse);
      expect(cb.getFailures('relay.example.com'), 0);
    });

    test('reset() clears all endpoint states', () async {
      // Trip two different endpoints
      for (var i = 0; i < 3; i++) {
        await cb.recordFailure('endpoint-a');
        await cb.recordFailure('endpoint-b');
      }
      expect(await cb.shouldSkip('endpoint-a'), isTrue);
      expect(await cb.shouldSkip('endpoint-b'), isTrue);

      // Reset clears everything
      await cb.reset();
      expect(await cb.shouldSkip('endpoint-a'), isFalse);
      expect(await cb.shouldSkip('endpoint-b'), isFalse);
      expect(cb.getFailures('endpoint-a'), 0);
      expect(cb.getFailures('endpoint-b'), 0);
    });

    test('multiple endpoints are independent', () async {
      // Trip endpoint A only
      await cb.recordFailure('endpoint-a');
      await cb.recordFailure('endpoint-a');
      await cb.recordFailure('endpoint-a');

      // Record some failures on B but not enough to trip
      await cb.recordFailure('endpoint-b');

      expect(await cb.shouldSkip('endpoint-a'), isTrue);
      expect(await cb.shouldSkip('endpoint-b'), isFalse);
      expect(cb.getFailures('endpoint-a'), 3);
      expect(cb.getFailures('endpoint-b'), 1);
    });

    test('success on one endpoint does not affect another', () async {
      // Trip both endpoints
      for (var i = 0; i < 3; i++) {
        await cb.recordFailure('endpoint-a');
        await cb.recordFailure('endpoint-b');
      }
      expect(await cb.shouldSkip('endpoint-a'), isTrue);
      expect(await cb.shouldSkip('endpoint-b'), isTrue);

      // Reset only endpoint-a
      await cb.recordSuccess('endpoint-a');
      expect(await cb.shouldSkip('endpoint-a'), isFalse);
      expect(await cb.shouldSkip('endpoint-b'), isTrue);
    });

    test('failure count increments correctly beyond threshold', () async {
      for (var i = 0; i < 5; i++) {
        await cb.recordFailure('relay');
      }
      expect(cb.getFailures('relay'), 5);
      expect(await cb.shouldSkip('relay'), isTrue);
    });

    test('maxFailures constant is 3', () {
      expect(CircuitBreakerService.maxFailures, 3);
    });

    test('state persists to SharedPreferences', () async {
      // Record failures and verify they persist in prefs
      await cb.recordFailure('persisted.endpoint');
      await cb.recordFailure('persisted.endpoint');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('circuit_breaker_v1');
      expect(raw, isNotNull);
      expect(raw, contains('persisted.endpoint'));
    });

    test('reset removes SharedPreferences key', () async {
      await cb.recordFailure('endpoint');
      await cb.reset();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('circuit_breaker_v1');
      expect(raw, isNull);
    });
  });
}
