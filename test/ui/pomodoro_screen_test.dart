import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chirp/core/providers.dart';
import 'package:chirp/services/pomodoro_service.dart';
import 'package:chirp/ui/pomodoro_screen.dart';
import 'package:chirp/ui/theme/app_theme.dart';

void main() {
  Widget createPomodoroScreen({PomodoroStatus? status}) {
    if (status != null) {
      return ProviderScope(
        overrides: [
          pomodoroStatusProvider.overrideWith((ref) {
            return Stream.value(status);
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const PomodoroScreen(),
        ),
      );
    }
    // No override — uses default idle state
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const PomodoroScreen(),
      ),
    );
  }

  group('PomodoroScreen', () {
    testWidgets('shows app bar with "Pomodoro" title', (tester) async {
      await tester.pumpWidget(createPomodoroScreen());
      expect(find.text('Pomodoro'), findsOneWidget);
    });

    testWidgets('shows idle state initially', (tester) async {
      await tester.pumpWidget(createPomodoroScreen());
      await tester.pumpAndSettle();
      expect(find.text('Ready to focus?'), findsOneWidget);
      expect(find.text('Start Pomodoro'), findsOneWidget);
    });

    testWidgets('shows work state UI', (tester) async {
      await tester.pumpWidget(createPomodoroScreen(
        status: const PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 1200,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Focus'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('Pomodoro 1 of 4'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('shows short break state', (tester) async {
      await tester.pumpWidget(createPomodoroScreen(
        status: const PomodoroStatus(
          state: PomodoroState.shortBreak,
          remainingSeconds: 180,
          totalSeconds: 300,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Short Break'), findsOneWidget);
      expect(find.text('Skip Break'), findsOneWidget);
    });

    testWidgets('shows paused state', (tester) async {
      await tester.pumpWidget(createPomodoroScreen(
        status: const PomodoroStatus(
          state: PomodoroState.paused,
          remainingSeconds: 900,
          totalSeconds: 1500,
          currentPomodoro: 2,
          totalPomodoros: 4,
          pomodorosCompletedToday: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('shows completed count', (tester) async {
      await tester.pumpWidget(createPomodoroScreen(
        status: const PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 1500,
          totalSeconds: 1500,
          currentPomodoro: 3,
          totalPomodoros: 4,
          pomodorosCompletedToday: 5,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('5 Pomodoros completed today'), findsOneWidget);
    });

    testWidgets('shows circular progress indicator', (tester) async {
      await tester.pumpWidget(createPomodoroScreen(
        status: const PomodoroStatus(
          state: PomodoroState.work,
          remainingSeconds: 750,
          totalSeconds: 1500,
          currentPomodoro: 1,
          totalPomodoros: 4,
          pomodorosCompletedToday: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
