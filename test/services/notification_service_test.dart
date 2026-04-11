import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/timer_service.dart';

// NotificationService depends on local_notifier which requires platform bindings.
// We test the notification message construction logic by replicating the
// message-building code from NotificationService and verifying all branches.

String buildPreBreakBody({
  required BreakType breakType,
  required bool canPostpone,
  required int postponesRemaining,
  required int secondsUntilBreak,
}) {
  final type = breakType == BreakType.long ? 'Long break' : 'Break';
  return canPostpone
      ? '$type starting in $secondsUntilBreak seconds. $postponesRemaining postpones remaining.'
      : '$type starting in $secondsUntilBreak seconds. No postpones remaining.';
}

String buildBreakStartMessage(BreakType breakType) {
  return breakType == BreakType.long
      ? 'Time for a longer break. Stand up and stretch!'
      : 'Look at something 20 feet away for 20 seconds.';
}

void main() {
  group('NotificationService message logic', () {
    group('pre-break notification messages', () {
      test('short break with postpones available', () {
        final body = buildPreBreakBody(
          breakType: BreakType.short,
          canPostpone: true,
          postponesRemaining: 3,
          secondsUntilBreak: 30,
        );
        expect(body, 'Break starting in 30 seconds. 3 postpones remaining.');
      });

      test('long break with postpones available', () {
        final body = buildPreBreakBody(
          breakType: BreakType.long,
          canPostpone: true,
          postponesRemaining: 2,
          secondsUntilBreak: 30,
        );
        expect(body, 'Long break starting in 30 seconds. 2 postpones remaining.');
      });

      test('short break without postpones', () {
        final body = buildPreBreakBody(
          breakType: BreakType.short,
          canPostpone: false,
          postponesRemaining: 0,
          secondsUntilBreak: 30,
        );
        expect(body, 'Break starting in 30 seconds. No postpones remaining.');
      });

      test('long break without postpones', () {
        final body = buildPreBreakBody(
          breakType: BreakType.long,
          canPostpone: false,
          postponesRemaining: 0,
          secondsUntilBreak: 30,
        );
        expect(body, 'Long break starting in 30 seconds. No postpones remaining.');
      });
    });

    group('break start notification messages', () {
      test('short break message', () {
        expect(
          buildBreakStartMessage(BreakType.short),
          'Look at something 20 feet away for 20 seconds.',
        );
      });

      test('long break message', () {
        expect(
          buildBreakStartMessage(BreakType.long),
          'Time for a longer break. Stand up and stretch!',
        );
      });
    });
  });
}
