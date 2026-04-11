import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/core/providers.dart';
import 'package:chirp/services/stats_service.dart';
import 'package:chirp/ui/stats_screen.dart';
import 'package:chirp/ui/theme/app_theme.dart';

void main() {
  late StatsService statsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    statsService = StatsService();
    await statsService.init(prefs);
  });

  Widget createStatsScreen() {
    return ProviderScope(
      overrides: [
        statsServiceProvider.overrideWithValue(statsService),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const StatsScreen(),
      ),
    );
  }

  group('StatsScreen', () {
    testWidgets('shows app bar with "Stats" title', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      expect(find.text('Stats'), findsOneWidget);
    });

    testWidgets('shows health score section', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      expect(find.text('Health Score'), findsOneWidget);
    });

    testWidgets('shows 100 health score for new day', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Great'), findsOneWidget);
    });

    testWidgets('shows today stat cards', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      expect(find.text('Breaks Taken'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Postponed'), findsOneWidget);
      expect(find.text('Screen Time'), findsOneWidget);
      expect(find.text('Longest Session'), findsOneWidget);
      expect(find.text('Median Session'), findsOneWidget);
    });

    testWidgets('shows today section header', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows this week section', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('This Week'), 100);
      expect(find.text('This Week'), findsOneWidget);
    });

    testWidgets('shows zeros for fresh stats', (tester) async {
      await tester.pumpWidget(createStatsScreen());
      // Stat cards should show "0" and "0m" (weekly chart also shows some)
      expect(find.text('0'), findsWidgets); // breaksTaken, skipped, postponed + chart
      expect(find.text('0m'), findsWidgets); // screen time, longest, median
    });

    testWidgets('shows updated stats after recording', (tester) async {
      await statsService.recordBreakTaken();
      await statsService.recordBreakTaken();
      await statsService.recordBreakSkipped();

      await tester.pumpWidget(createStatsScreen());

      expect(find.text('Breaks Taken'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
    });

    testWidgets('weekly chart does not overflow with data', (tester) async {
      // Regression: bar max height was 120px which caused 4px overflow
      // when combined with text labels and spacing in a 160px container.
      for (var i = 0; i < 10; i++) {
        await statsService.recordBreakTaken();
      }

      await tester.pumpWidget(createStatsScreen());
      await tester.pumpAndSettle();

      // If the chart overflows, this test fails with a RenderFlex error
      await tester.scrollUntilVisible(find.text('This Week'), 100);
      expect(find.text('This Week'), findsOneWidget);
    });
  });
}
