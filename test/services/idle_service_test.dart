import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/idle_service.dart';

void main() {
  late IdleService service;

  setUp(() {
    service = IdleService();
  });

  tearDown(() {
    service.dispose();
  });

  group('IdleService', () {
    group('initial state', () {
      test('starts as not idle', () {
        expect(service.isIdle, false);
      });
    });

    group('configure', () {
      test('sets idle threshold', () {
        service.configure(idleThresholdSeconds: 300);
        // No public getter for threshold, but it should not throw
      });
    });

    group('start/stop', () {
      test('start and stop do not throw', () async {
        await service.start();
        await service.stop();
      });

      test('stop resets idle state', () async {
        await service.start();
        await service.stop();
        expect(service.isIdle, false);
      });

      test('double stop is safe', () async {
        await service.start();
        await service.stop();
        await service.stop();
      });
    });

    group('callback', () {
      test('onIdleChanged can be set', () {
        service.onIdleChanged = (isIdle) {};
        // Should not throw
      });
    });

    group('dispose', () {
      test('dispose is safe after start', () async {
        await service.start();
        service.dispose();
      });

      test('dispose is safe without start', () {
        service.dispose();
      });
    });
  });
}
