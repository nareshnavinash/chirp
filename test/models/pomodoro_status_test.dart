import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/pomodoro_service.dart';

void main() {
  group('PomodoroStatus', () {
    group('progress', () {
      test('returns 0.0 at start', () {
        const status = PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 1500,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.progress, 0.0);
      });

      test('returns 0.5 at midpoint', () {
        const status = PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 750,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.progress, 0.5);
      });

      test('returns 1.0 when done', () {
        const status = PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 0,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.progress, 1.0);
      });

      test('returns 0.0 when totalSeconds is 0', () {
        const status = PomodoroStatus(
          state: PomodoroState.idle,
          remainingSeconds: 0,
          totalSeconds: 0,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.progress, 0.0);
      });
    });

    group('remainingFormatted', () {
      test('formats 25 minutes as 25:00', () {
        const status = PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 1500,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.remainingFormatted, '25:00');
      });

      test('formats 5 minutes as 05:00', () {
        const status = PomodoroStatus(
          state: PomodoroState.shortBreak,
          remainingSeconds: 300,
          totalSeconds: 300,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.remainingFormatted, '05:00');
      });

      test('formats 7 seconds as 00:07', () {
        const status = PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 7,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.remainingFormatted, '00:07');
      });
    });

    group('stateLabel', () {
      test('returns "Focus" for work state', () {
        const status = PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 1500,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.stateLabel, 'Focus');
      });

      test('returns "Short Break" for shortBreak state', () {
        const status = PomodoroStatus(
          state: PomodoroState.shortBreak,
          remainingSeconds: 300,
          totalSeconds: 300,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.stateLabel, 'Short Break');
      });

      test('returns "Long Break" for longBreak state', () {
        const status = PomodoroStatus(
          state: PomodoroState.longBreak,
          remainingSeconds: 900,
          totalSeconds: 900,
          currentPomodoro: 4,
          totalPomodoros: 4,
          pomodorosCompletedToday: 4,
        );
        expect(status.stateLabel, 'Long Break');
      });

      test('returns "Paused" for paused state', () {
        const status = PomodoroStatus(
          state: PomodoroState.paused,
          remainingSeconds: 1000,
          totalSeconds: 1500,
          currentPomodoro: 2,
          totalPomodoros: 4,
          pomodorosCompletedToday: 1,
        );
        expect(status.stateLabel, 'Paused');
      });

      test('returns "Ready" for idle state', () {
        const status = PomodoroStatus(
          state: PomodoroState.idle,
          remainingSeconds: 0,
          totalSeconds: 0,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        );
        expect(status.stateLabel, 'Ready');
      });
    });
  });
}
