import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReminderService service;

  setUp(() {
    service = ReminderService();
    service.configure(
      blinkIntervalMinutes: 1,    // 1 min for fast tests
      postureIntervalMinutes: 2,  // 2 min for fast tests
      blinkEnabled: true,
      postureEnabled: true,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('ReminderService', () {
    group('configure', () {
      test('sets interval and enabled state', () {
        service.configure(
          blinkIntervalMinutes: 15,
          postureIntervalMinutes: 45,
          blinkEnabled: false,
          postureEnabled: false,
        );
        // No public getters for these, but start should respect config
        // If disabled, no events should fire
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 20));
          expect(events, isEmpty);
        });
      });
    });

    group('events stream', () {
      test('emits blink reminder at configured interval', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 1));
          expect(events.where((e) => e.type == ReminderType.blink).length, 1);
        });
      });

      test('emits posture reminder at configured interval', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 2));
          expect(events.where((e) => e.type == ReminderType.posture).length, 1);
        });
      });

      test('emits multiple blink reminders over time', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 3));
          expect(events.where((e) => e.type == ReminderType.blink).length, 3);
        });
      });

      test('includes timestamp in event', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 1));
          expect(events.first.timestamp, isNotNull);
        });
      });
    });

    group('start/stop', () {
      test('stop halts all reminders', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 1));
          service.stop();
          final countAtStop = events.length;
          async.elapse(const Duration(minutes: 5));
          expect(events.length, countAtStop);
        });
      });

      test('start after stop resumes reminders', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          async.elapse(const Duration(minutes: 1));
          service.stop();
          service.start();
          async.elapse(const Duration(minutes: 1));
          // Should have 2 blink events total (one from each start)
          final blinkCount = events.where((e) => e.type == ReminderType.blink).length;
          expect(blinkCount, 2);
        });
      });
    });

    group('updateBlinkEnabled', () {
      test('disabling stops blink reminders', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          service.updateBlinkEnabled(false);
          async.elapse(const Duration(minutes: 5));
          expect(events.where((e) => e.type == ReminderType.blink), isEmpty);
        });
      });

      test('re-enabling restarts blink reminders', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          service.updateBlinkEnabled(false);
          service.updateBlinkEnabled(true);
          async.elapse(const Duration(minutes: 1));
          expect(events.where((e) => e.type == ReminderType.blink).length, 1);
        });
      });
    });

    group('updatePostureEnabled', () {
      test('disabling stops posture reminders', () {
        fakeAsync((async) {
          final events = <ReminderEvent>[];
          service.events.listen(events.add);
          service.start();
          service.updatePostureEnabled(false);
          async.elapse(const Duration(minutes: 5));
          expect(events.where((e) => e.type == ReminderType.posture), isEmpty);
        });
      });
    });

    group('events stream', () {
      test('is broadcast', () {
        service.events.listen((_) {});
        service.events.listen((_) {});
      });
    });
  });

  group('ReminderEvent', () {
    test('stores type and timestamp', () {
      final event = ReminderEvent(
        type: ReminderType.blink,
        timestamp: DateTime(2024, 1, 15),
      );
      expect(event.type, ReminderType.blink);
      expect(event.timestamp, DateTime(2024, 1, 15));
    });
  });
}
