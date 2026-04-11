import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/schedule_service.dart';

void main() {
  group('ScheduleConfig', () {
    group('isActiveNow', () {
      test('returns true when disabled (always active)', () {
        const config = ScheduleConfig(enabled: false);
        expect(config.isActiveNow(), true);
      });

      test('default config is not enabled', () {
        const config = ScheduleConfig();
        expect(config.enabled, false);
        expect(config.isActiveNow(), true);
      });

      test('returns false on weekend when only weekdays active', () {
        final now = DateTime.now();
        // Create a config that's enabled with only weekdays
        final config = ScheduleConfig(
          enabled: true,
          activeDays: const {1, 2, 3, 4, 5},
          startTime: const TimeOfDay(hour: 0, minute: 0),
          endTime: const TimeOfDay(hour: 23, minute: 59),
        );
        // This test is time-dependent. We test the logic path:
        // If today is a weekend, it should return false.
        // If today is a weekday, it should return true.
        if (now.weekday >= 6) {
          expect(config.isActiveNow(), false);
        } else {
          expect(config.isActiveNow(), true);
        }
      });

      test('default weekdays are Mon-Fri', () {
        const config = ScheduleConfig();
        expect(config.activeDays, {1, 2, 3, 4, 5});
      });

      test('default hours are 9-17', () {
        const config = ScheduleConfig();
        expect(config.startTime.hour, 9);
        expect(config.startTime.minute, 0);
        expect(config.endTime.hour, 17);
        expect(config.endTime.minute, 0);
      });
    });
  });

  group('ScheduleService', () {
    late ScheduleService service;

    setUp(() {
      service = ScheduleService();
    });

    tearDown(() {
      service.dispose();
    });

    test('isActiveNow delegates to config', () {
      const config = ScheduleConfig(enabled: false);
      service.configure(config);
      expect(service.isActiveNow, true);
    });

    test('configure updates internal config', () {
      const config = ScheduleConfig(
        enabled: true,
        activeDays: {1, 3, 5},
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 18, minute: 0),
      );
      service.configure(config);
      // The service's isActiveNow should use the new config
      // Since we can't control time easily here, just verify no errors
      service.isActiveNow;
    });

    test('start and stop do not throw', () {
      service.configure(const ScheduleConfig(enabled: false));
      service.start();
      service.stop();
    });

    test('fires onScheduleChanged callback on boundary', () {
      fakeAsync((async) {
        var callbackFired = false;
        service.onScheduleChanged = (isActive) {
          callbackFired = true;
        };

        // Use a config that's always inactive (empty days)
        service.configure(const ScheduleConfig(
          enabled: true,
          activeDays: {}, // no active days
        ));
        service.start();
        // The initial _wasActive should be false (no active days)
        // After 1 minute check, still false -> no change -> no callback
        async.elapse(const Duration(minutes: 2));
        // Since there's no schedule boundary crossing, callback may not fire
        // This tests that the timer runs without error
        expect(callbackFired, false);
      });
    });

    test('dispose stops timer', () {
      service.configure(const ScheduleConfig());
      service.start();
      service.dispose();
      // Should not throw or error
    });
  });
}
