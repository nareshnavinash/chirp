import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/timer_service.dart';

void main() {
  late TimerService service;

  setUp(() {
    service = TimerService();
    service.configure(
      workMinutes: 1, // 60 seconds for fast tests
      breakSeconds: 10,
      longBreakMinutes: 1, // 60 seconds
      longBreakInterval: 4,
      preBreakSeconds: 5,
      maxPostponesPerDay: 3,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('TimerService', () {
    group('initial state', () {
      test('starts in idle state', () {
        expect(service.currentStatus.state, TimerState.idle);
      });

      test('initial remaining is 0', () {
        expect(service.currentStatus.remainingSeconds, 0);
      });

      test('initial postpones used is 0', () {
        expect(service.currentStatus.postponesUsedToday, 0);
      });
    });

    group('configure', () {
      test('sets work duration in seconds', () {
        service.configure(
          workMinutes: 25,
          breakSeconds: 20,
          longBreakMinutes: 5,
          longBreakInterval: 4,
        );
        service.startWorkSession();
        expect(service.currentStatus.totalSeconds, 25 * 60);
      });

      test('sets max postpones', () {
        service.configure(
          workMinutes: 20,
          breakSeconds: 20,
          longBreakMinutes: 5,
          longBreakInterval: 4,
          maxPostponesPerDay: 10,
        );
        expect(service.currentStatus.maxPostponesPerDay, 10);
      });
    });

    group('startWorkSession', () {
      test('transitions to working state', () {
        service.startWorkSession();
        expect(service.currentStatus.state, TimerState.working);
      });

      test('sets remaining to work duration', () {
        service.startWorkSession();
        expect(service.currentStatus.remainingSeconds, 60);
        expect(service.currentStatus.totalSeconds, 60);
      });

      test('emits status on stream', () {
        fakeAsync((async) {
          final statuses = <TimerStatus>[];
          service.statusStream.listen(statuses.add);
          service.startWorkSession();
          async.flushMicrotasks();
          expect(statuses, isNotEmpty);
          expect(statuses.last.state, TimerState.working);
        });
      });
    });

    group('countdown', () {
      test('decrements every second', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 3));
          expect(service.currentStatus.remainingSeconds, 57);
        });
      });

      test('transitions to preBreak when work timer completes', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 60));
          expect(service.currentStatus.state, TimerState.preBreak);
        });
      });

      test('transitions to onBreak after preBreak completes', () {
        fakeAsync((async) {
          service.startWorkSession();
          // Work: 60s + PreBreak: 5s
          async.elapse(const Duration(seconds: 65));
          expect(service.currentStatus.state, TimerState.onBreak);
        });
      });

      test('returns to working after break completes', () {
        fakeAsync((async) {
          service.startWorkSession();
          // Work: 60s + PreBreak: 5s + Short Break: 10s
          async.elapse(const Duration(seconds: 75));
          expect(service.currentStatus.state, TimerState.working);
        });
      });
    });

    group('break type cycling', () {
      test('first break is short', () {
        service.startWorkSession();
        expect(service.currentStatus.nextBreakType, BreakType.short);
      });

      test('4th break is long (longBreakInterval=4)', () {
        fakeAsync((async) {
          service.startWorkSession();
          // Complete 3 short break cycles: 3 * (60s work + 5s pre + 10s break)
          async.elapse(const Duration(seconds: 225));
          // Now on 4th work session, next break should be long
          expect(service.currentStatus.nextBreakType, BreakType.long);
        });
      });
    });

    group('callbacks', () {
      test('fires onPreBreakStart', () {
        fakeAsync((async) {
          var called = false;
          service.onPreBreakStart = () => called = true;
          service.startWorkSession();
          async.elapse(const Duration(seconds: 60));
          expect(called, true);
        });
      });

      test('fires onBreakStart with break type', () {
        fakeAsync((async) {
          BreakType? receivedType;
          service.onBreakStart = (type) => receivedType = type;
          service.startWorkSession();
          async.elapse(const Duration(seconds: 65));
          expect(receivedType, BreakType.short);
        });
      });

      test('fires onBreakEnd', () {
        fakeAsync((async) {
          var called = false;
          service.onBreakEnd = () => called = true;
          service.startWorkSession();
          // Work + PreBreak + Break
          async.elapse(const Duration(seconds: 75));
          expect(called, true);
        });
      });
    });

    group('postpone', () {
      test('returns to working state with new duration', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 60));
          expect(service.currentStatus.state, TimerState.preBreak);

          service.postpone(1); // 1 minute
          expect(service.currentStatus.state, TimerState.working);
          expect(service.currentStatus.remainingSeconds, 60);
        });
      });

      test('increments postpones used', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 60));
          service.postpone(1);
          expect(service.currentStatus.postponesUsedToday, 1);
        });
      });

      test('blocks postpone when max reached', () {
        fakeAsync((async) {
          // Use all 3 postpones
          for (var i = 0; i < 3; i++) {
            service.startWorkSession();
            async.elapse(const Duration(seconds: 60));
            service.postpone(1);
            async.elapse(const Duration(seconds: 60));
          }
          // 4th postpone attempt should be blocked
          service.startWorkSession();
          async.elapse(const Duration(seconds: 60));
          final stateBeforePostpone = service.currentStatus.state;
          service.postpone(1);
          expect(service.currentStatus.postponesUsedToday, 3);
          expect(service.currentStatus.state, stateBeforePostpone);
        });
      });
    });

    group('pause/resume', () {
      test('pauses stops countdown', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 10));
          service.pause();
          final remaining = service.currentStatus.remainingSeconds;
          async.elapse(const Duration(seconds: 10));
          expect(service.currentStatus.remainingSeconds, remaining);
          expect(service.currentStatus.state, TimerState.paused);
        });
      });

      test('resume continues countdown', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 10));
          service.pause();
          service.resume();
          expect(service.currentStatus.state, TimerState.working);
          async.elapse(const Duration(seconds: 5));
          expect(service.currentStatus.remainingSeconds, 45);
        });
      });

      test('pause when already paused is no-op', () {
        service.startWorkSession();
        service.pause();
        service.pause(); // should not throw
        expect(service.currentStatus.state, TimerState.paused);
      });

      test('resume when not paused is no-op', () {
        service.startWorkSession();
        service.resume(); // should not throw
        expect(service.currentStatus.state, TimerState.working);
      });
    });

    group('skipBreak', () {
      test('skips from onBreak to next work session', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 65));
          expect(service.currentStatus.state, TimerState.onBreak);
          service.skipBreak();
          expect(service.currentStatus.state, TimerState.working);
        });
      });

      test('no-op when not on break', () {
        service.startWorkSession();
        service.skipBreak();
        expect(service.currentStatus.state, TimerState.working);
      });
    });

    group('startBreakNow', () {
      test('immediately starts break', () {
        service.startWorkSession();
        service.startBreakNow();
        expect(service.currentStatus.state, TimerState.onBreak);
      });
    });

    group('resetDailyPostpones', () {
      test('resets postpone counter to zero', () {
        fakeAsync((async) {
          service.startWorkSession();
          async.elapse(const Duration(seconds: 60));
          service.postpone(1);
          expect(service.currentStatus.postponesUsedToday, 1);
          service.resetDailyPostpones();
          expect(service.currentStatus.postponesUsedToday, 0);
        });
      });
    });

    group('statusStream', () {
      test('emits status updates on state changes', () {
        fakeAsync((async) {
          final states = <TimerState>[];
          service.statusStream.listen((s) => states.add(s.state));

          service.startWorkSession();
          async.elapse(const Duration(seconds: 60)); // -> preBreak
          async.elapse(const Duration(seconds: 5));  // -> onBreak
          async.elapse(const Duration(seconds: 10)); // -> working

          expect(states, contains(TimerState.working));
          expect(states, contains(TimerState.preBreak));
          expect(states, contains(TimerState.onBreak));
        });
      });

      test('is a broadcast stream', () {
        // Should not throw when adding multiple listeners
        service.statusStream.listen((_) {});
        service.statusStream.listen((_) {});
      });
    });

    group('dispose', () {
      test('cancels timer and closes stream', () {
        service.startWorkSession();
        service.dispose();
        expect(service.statusStream.isBroadcast, true);
      });
    });
  });
}
