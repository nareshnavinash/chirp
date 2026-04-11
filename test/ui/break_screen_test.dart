import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chirp/core/providers.dart';
import 'package:chirp/services/timer_service.dart';
import 'package:chirp/ui/break_screen.dart';
import 'package:chirp/ui/theme/app_theme.dart';
import 'package:chirp/ui/widgets/breathing_progress_ring.dart';

void main() {
  Widget createBreakScreen({required TimerStatus status}) {
    return ProviderScope(
      overrides: [
        timerStatusProvider.overrideWith((ref) {
          return Stream.value(status);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const BreakScreen(),
      ),
    );
  }

  group('BreakScreen', () {
    testWidgets('shows short break title for short break', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 15,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pump();

      expect(find.text('Eye Break'), findsOneWidget);
    });

    testWidgets('shows long break title for long break', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 200,
          totalSeconds: 300,
          nextBreakType: BreakType.long,
          breaksTakenInCycle: 3,
        ),
      ));
      await tester.pump();

      expect(find.text('Long Break'), findsOneWidget);
    });

    testWidgets('shows countdown timer', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 15,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pump();

      expect(find.text('00:15'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 10,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pump();

      expect(find.text('Skip break (Esc)'), findsOneWidget);
    });

    testWidgets('shows short break message', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 10,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pump();

      expect(
        find.text('Look at something 20 feet away\nfor 20 seconds.'),
        findsOneWidget,
      );
    });

    testWidgets('shows long break message', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 200,
          totalSeconds: 300,
          nextBreakType: BreakType.long,
          breaksTakenInCycle: 3,
        ),
      ));
      await tester.pump();

      expect(
        find.text('Stand up and stretch.\nGrab some water.'),
        findsOneWidget,
      );
    });

    testWidgets('has gradient background', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 10,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pump();

      // Verify gradient Container exists within the Scaffold
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.gradient, isA<LinearGradient>());
    });

    testWidgets('shows breathing progress ring', (tester) async {
      await tester.pumpWidget(createBreakScreen(
        status: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 10,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pump();

      expect(find.byType(BreathingProgressRing), findsOneWidget);
    });
  });
}
