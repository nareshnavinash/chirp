import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/pomodoro_service.dart';

void main() {
  late PomodoroService service;

  setUp(() {
    service = PomodoroService();
    service.configure(
      workMinutes: 1,       // 60s
      shortBreakMinutes: 1, // 60s (keep equal for simpler arithmetic)
      longBreakMinutes: 2,  // 120s
      pomodorosPerCycle: 4,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('PomodoroService', () {
    group('initial state', () {
      test('starts in idle state', () {
        expect(service.currentStatus.state, PomodoroState.idle);
      });

      test('starts at pomodoro 1', () {
        expect(service.currentStatus.currentPomodoro, 1);
      });

      test('starts with 0 completed today', () {
        expect(service.currentStatus.pomodorosCompletedToday, 0);
      });
    });

    group('configure', () {
      test('sets work duration', () {
        service.configure(workMinutes: 30);
        service.startWork();
        expect(service.currentStatus.totalSeconds, 30 * 60);
      });
    });

    group('startWork', () {
      test('transitions to work state', () {
        service.startWork();
        expect(service.currentStatus.state, PomodoroState.work);
      });

      test('sets timer to work duration', () {
        service.startWork();
        expect(service.currentStatus.remainingSeconds, 60);
      });
    });

    group('work countdown', () {
      test('decrements each second', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 5));
          expect(service.currentStatus.remainingSeconds, 55);
        });
      });

      test('transitions to short break after work completes (pomodoro 1-3)', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 60));
          expect(service.currentStatus.state, PomodoroState.shortBreak);
        });
      });
    });

    group('break cycling', () {
      test('gives short break for pomodoro 1', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 60));
          expect(service.currentStatus.state, PomodoroState.shortBreak);
        });
      });

      test('gives long break after 4th pomodoro', () {
        fakeAsync((async) {
          service.startWork();
          // Pomodoro 1: work(60) -> shortBreak(60) -> auto-startWork
          // Pomodoro 2: work(60) -> shortBreak(60) -> auto-startWork
          // Pomodoro 3: work(60) -> shortBreak(60) -> auto-startWork
          // Pomodoro 4: work(60) -> longBreak
          async.elapse(const Duration(seconds: 60 * 7)); // 7 * 60 = 420
          expect(service.currentStatus.state, PomodoroState.longBreak);
        });
      });
    });

    group('callbacks', () {
      test('fires onPomodoroComplete when work finishes', () {
        fakeAsync((async) {
          var called = false;
          service.onPomodoroComplete = () => called = true;
          service.startWork();
          async.elapse(const Duration(seconds: 60));
          expect(called, true);
        });
      });

      test('fires onBreakStart when break begins', () {
        fakeAsync((async) {
          var called = false;
          service.onBreakStart = () => called = true;
          service.startWork();
          async.elapse(const Duration(seconds: 60));
          expect(called, true);
        });
      });

      test('fires onBreakEnd when break finishes', () {
        fakeAsync((async) {
          var called = false;
          service.onBreakEnd = () => called = true;
          service.startWork();
          // Work + short break
          async.elapse(const Duration(seconds: 120));
          expect(called, true);
        });
      });
    });

    group('pomodorosCompletedToday', () {
      test('increments after each work session', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 60));
          expect(service.currentStatus.pomodorosCompletedToday, 1);

          async.elapse(const Duration(seconds: 60)); // short break done
          async.elapse(const Duration(seconds: 60)); // second work done
          expect(service.currentStatus.pomodorosCompletedToday, 2);
        });
      });
    });

    group('pause/resume', () {
      test('pauses stops countdown', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 10));
          service.pause();
          expect(service.currentStatus.state, PomodoroState.paused);
          final remaining = service.currentStatus.remainingSeconds;
          async.elapse(const Duration(seconds: 10));
          expect(service.currentStatus.remainingSeconds, remaining);
        });
      });

      test('resume restores previous state', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 10));
          service.pause();
          service.resume();
          expect(service.currentStatus.state, PomodoroState.work);
        });
      });

      test('pause from idle is no-op', () {
        service.pause();
        expect(service.currentStatus.state, PomodoroState.idle);
      });

      test('pause when already paused is no-op', () {
        service.startWork();
        service.pause();
        service.pause();
        expect(service.currentStatus.state, PomodoroState.paused);
      });

      test('resume when not paused is no-op', () {
        service.startWork();
        service.resume(); // not paused
        expect(service.currentStatus.state, PomodoroState.work);
      });
    });

    group('skipBreak', () {
      test('skips short break and starts next work', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 60)); // to short break
          expect(service.currentStatus.state, PomodoroState.shortBreak);
          service.skipBreak();
          expect(service.currentStatus.state, PomodoroState.work);
        });
      });

      test('no-op during work state', () {
        service.startWork();
        service.skipBreak();
        expect(service.currentStatus.state, PomodoroState.work);
      });
    });

    group('reset', () {
      test('resets to idle at pomodoro 1', () {
        fakeAsync((async) {
          service.startWork();
          async.elapse(const Duration(seconds: 30));
          service.reset();
          expect(service.currentStatus.state, PomodoroState.idle);
          expect(service.currentStatus.currentPomodoro, 1);
          expect(service.currentStatus.remainingSeconds, 0);
        });
      });
    });

    group('statusStream', () {
      test('emits updates', () {
        fakeAsync((async) {
          final states = <PomodoroState>[];
          service.statusStream.listen((s) => states.add(s.state));
          service.startWork();
          async.elapse(const Duration(seconds: 60));
          expect(states, contains(PomodoroState.work));
          expect(states, contains(PomodoroState.shortBreak));
        });
      });

      test('is broadcast', () {
        service.statusStream.listen((_) {});
        service.statusStream.listen((_) {});
      });
    });
  });
}
