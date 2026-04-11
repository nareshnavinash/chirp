import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/core/app_constants.dart';
import 'package:chirp/core/providers.dart';
import 'package:chirp/features/settings/settings_model.dart';
import 'package:chirp/services/timer_service.dart';
import 'package:chirp/ui/home_screen.dart';
import 'package:chirp/ui/theme/app_theme.dart';
import 'package:chirp/ui/widgets/circular_timer.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createHomeScreen({
    TimerStatus? timerStatus,
    SettingsModel? settings,
    AppStatus? appStatus,
  }) {
    final status = timerStatus ?? const TimerStatus(
      state: TimerState.working,
      remainingSeconds: 1200,
      totalSeconds: 1200,
      nextBreakType: BreakType.short,
      breaksTakenInCycle: 0,
    );

    return ProviderScope(
      overrides: [
        timerStatusProvider.overrideWith((ref) {
          return Stream.value(status);
        }),
        settingsProvider.overrideWith(() {
          return _TestSettingsNotifier(settings ?? const SettingsModel());
        }),
        appStatusProvider.overrideWith(() {
          return _TestAppStatusNotifier(appStatus ?? AppStatus.running);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const HomeScreen(),
      ),
    );
  }

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('HomeScreen', () {
    testWidgets('shows app name', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.appName), findsAtLeast(1));
    });

    testWidgets('shows Active chip when running', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(appStatus: AppStatus.running));
      await tester.pumpAndSettle();
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows Paused chip when paused', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(appStatus: AppStatus.paused));
      await tester.pumpAndSettle();
      expect(find.text('Paused'), findsAtLeast(1));
    });

    testWidgets('shows timer display with formatted time', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(
        timerStatus: const TimerStatus(
          state: TimerState.working,
          remainingSeconds: 1200,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('shows state label', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(
        timerStatus: const TimerStatus(
          state: TimerState.working,
          remainingSeconds: 600,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Next break in'), findsOneWidget);
    });

    testWidgets('shows Pause button when running', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(appStatus: AppStatus.running));
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('shows Resume button when paused', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(appStatus: AppStatus.paused));
      await tester.pumpAndSettle();
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('shows quick settings chips', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsNWidgets(3));
      expect(find.text('Breaks'), findsOneWidget);
      expect(find.text('Posture'), findsOneWidget);
    });

    testWidgets('shows navigation icons', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows circular timer', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      expect(find.byType(CircularTimer), findsOneWidget);
    });

    testWidgets('shows break info row', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(
        timerStatus: const TimerStatus(
          state: TimerState.working,
          remainingSeconds: 600,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 1,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Break 2 of cycle'), findsOneWidget);
      expect(find.textContaining('Short break'), findsOneWidget);
    });

    testWidgets('shows snooze bar during preBreak', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(
        timerStatus: const TimerStatus(
          state: TimerState.preBreak,
          remainingSeconds: 25,
          totalSeconds: 30,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
          postponesUsedToday: 1,
          maxPostponesPerDay: 5,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Postpone?'), findsOneWidget);
      expect(find.text('+1 min'), findsOneWidget);
      expect(find.text('+5 min'), findsOneWidget);
      expect(find.text('+15 min'), findsOneWidget);
    });

    testWidgets('shows "Start Break Now" during working', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(
        timerStatus: const TimerStatus(
          state: TimerState.working,
          remainingSeconds: 600,
          totalSeconds: 1200,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Start Break Now'), findsOneWidget);
    });

    testWidgets('shows "Skip Break" during onBreak', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(createHomeScreen(
        timerStatus: const TimerStatus(
          state: TimerState.onBreak,
          remainingSeconds: 10,
          totalSeconds: 20,
          nextBreakType: BreakType.short,
          breaksTakenInCycle: 0,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Skip Break'), findsOneWidget);
    });
  });
}

class _TestSettingsNotifier extends SettingsNotifier {
  final SettingsModel _initial;
  _TestSettingsNotifier(this._initial);

  @override
  SettingsModel build() => _initial;
}

class _TestAppStatusNotifier extends AppStatusNotifier {
  final AppStatus _initial;
  _TestAppStatusNotifier(this._initial);

  @override
  AppStatus build() => _initial;
}
