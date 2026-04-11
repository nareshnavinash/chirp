import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/timer_service.dart';

void main() {
  group('TimerStatus', () {
    group('canPostpone', () {
      test('returns true when postpones available', () {
        const status = TimerStatus(
          state: TimerState.preBreak,
          remainingSeconds: 30,
          totalSeconds: 30,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
          postponesUsedToday: 2,
          maxPostponesPerDay: 5,
        );
        expect(status.canPostpone, true);
      });

      test('returns false when all postpones used', () {
        const status = TimerStatus(
          state: TimerState.preBreak,
          remainingSeconds: 30,
          totalSeconds: 30,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
          postponesUsedToday: 5,
          maxPostponesPerDay: 5,
        );
        expect(status.canPostpone, false);
      });

      test('returns false when postpones exceed max', () {
        const status = TimerStatus(
          state: TimerState.preBreak,
          remainingSeconds: 30,
          totalSeconds: 30,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
          postponesUsedToday: 6,
          maxPostponesPerDay: 5,
        );
        expect(status.canPostpone, false);
      });
    });

    group('postponesRemaining', () {
      test('calculates remaining correctly', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 100,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
          postponesUsedToday: 2,
          maxPostponesPerDay: 5,
        );
        expect(status.postponesRemaining, 3);
      });

      test('returns zero when all used', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 100,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
          postponesUsedToday: 5,
          maxPostponesPerDay: 5,
        );
        expect(status.postponesRemaining, 0);
      });
    });

    group('progress', () {
      test('returns 0.0 at start of session', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 1200,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.progress, 0.0);
      });

      test('returns 0.5 at halfway', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 600,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.progress, 0.5);
      });

      test('returns 1.0 at end', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 0,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.progress, 1.0);
      });

      test('returns 0.0 when totalSeconds is 0', () {
        const status = TimerStatus(
          state: TimerState.idle,
          remainingSeconds: 0,
          totalSeconds: 0,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.progress, 0.0);
      });
    });

    group('remainingFormatted', () {
      test('formats zero as 00:00', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 0,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.remainingFormatted, '00:00');
      });

      test('formats 90 seconds as 01:30', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 90,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.remainingFormatted, '01:30');
      });

      test('formats 20 minutes as 20:00', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 1200,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.remainingFormatted, '20:00');
      });

      test('pads single digits', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 65,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.remainingFormatted, '01:05');
      });
    });

    group('stateLabel', () {
      test('returns "Next break in" for working state', () {
        const status = TimerStatus(
          state: TimerState.working,
          remainingSeconds: 1200,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.stateLabel, 'Next break in');
      });

      test('returns "Break starting in" for preBreak state', () {
        const status = TimerStatus(
          state: TimerState.preBreak,
          remainingSeconds: 30,
          totalSeconds: 30,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.stateLabel, 'Break starting in');
      });

      test('returns "Short break" for short break', () {
        const status = TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 20,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.stateLabel, 'Short break');
      });

      test('returns "Long break" for long break', () {
        const status = TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 300,
          totalSeconds: 300,
          nextBreakType: BreakType.long,
          breaksTakenInCycle: 3,
        );
        expect(status.stateLabel, 'Long break');
      });

      test('returns "Paused" for paused state', () {
        const status = TimerStatus(
          state: TimerState.paused,
          remainingSeconds: 500,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.stateLabel, 'Paused');
      });

      test('returns "Idle" for idle state', () {
        const status = TimerStatus(
          state: TimerState.idle,
          remainingSeconds: 0,
          totalSeconds: 0,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        );
        expect(status.stateLabel, 'Idle');
      });
    });
  });
}
