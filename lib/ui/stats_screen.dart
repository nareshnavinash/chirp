import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chirp/core/providers.dart';
import 'package:chirp/services/stats_service.dart';
import 'package:chirp/ui/theme/app_theme_extension.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsService = ref.watch(statsServiceProvider);
    final today = statsService.getToday();
    final week = statsService.getWeek();
    final currentStreak = statsService.getCurrentStreak();
    final longestStreak = statsService.getLongestStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Health Score
          _HealthScoreCard(score: today.healthScore),
          const SizedBox(height: 16),
          _StreakCard(currentStreak: currentStreak, longestStreak: longestStreak),
          const SizedBox(height: 16),

          // Today's stats
          _SectionHeader('Today'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.check_circle_outline,
                label: 'Breaks Taken',
                value: '${today.breaksTaken}',
                color: ChirpColors.of(context).success,
              )),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(
                icon: Icons.cancel_outlined,
                label: 'Skipped',
                value: '${today.breaksSkipped}',
                color: ChirpColors.of(context).error,
              )),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(
                icon: Icons.snooze,
                label: 'Postponed',
                value: '${today.breaksPostponed}',
                color: ChirpColors.of(context).warning,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.timer,
                label: 'Screen Time',
                value: _formatMinutes(today.totalScreenMinutes),
                color: ChirpColors.of(context).brand,
              )),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(
                icon: Icons.trending_up,
                label: 'Longest Session',
                value: _formatMinutes(today.longestSessionMinutes),
                color: ChirpColors.of(context).statsPurple,
              )),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(
                icon: Icons.analytics_outlined,
                label: 'Median Session',
                value: _formatMinutes(today.medianSessionMinutes),
                color: ChirpColors.of(context).statsTeal,
              )),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly chart
          _SectionHeader('This Week'),
          const SizedBox(height: 12),
          _WeeklyChart(week: week),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }
}

class _HealthScoreCard extends StatelessWidget {
  final int score;

  const _HealthScoreCard({required this.score});

  Color _scoreColor(BuildContext context) {
    final colors = ChirpColors.of(context);
    if (score >= 80) return colors.success;
    if (score >= 60) return colors.warning;
    return colors.error;
  }

  String get _scoreLabel {
    if (score >= 80) return 'Great';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Needs work';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 6,
                      backgroundColor: ChirpColors.of(context).surfaceSubtle,
                      color: _scoreColor(context),
                    ),
                  ),
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _scoreLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _scoreColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const _StreakCard({required this.currentStreak, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.local_fire_department,
                      color: currentStreak > 0 ? ChirpColors.of(context).warning : ChirpColors.of(context).textTertiary,
                      size: 28),
                  const SizedBox(height: 8),
                  Text(
                    '$currentStreak',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentStreak == 1 ? 'Day' : 'Days'} Streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ChirpColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: ChirpColors.of(context).border,
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.emoji_events,
                      color: longestStreak > 0 ? ChirpColors.of(context).statsAmber : ChirpColors.of(context).textTertiary,
                      size: 28),
                  const SizedBox(height: 8),
                  Text(
                    '$longestStreak',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Best Streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ChirpColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ChirpColors.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<DailyStats> week;

  const _WeeklyChart({required this.week});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxBreaks = week.fold(0, (max, s) =>
        s.breaksTaken > max ? s.breaksTaken : max);
    final barMax = maxBreaks > 0 ? maxBreaks.toDouble() : 1.0;

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(week.length, (i) {
          final stats = week[i];
          final dayOfWeek = DateTime.now()
              .subtract(Duration(days: 6 - i))
              .weekday;
          final isToday = i == 6;
          final rawHeight = barMax > 0
              ? (stats.breaksTaken / barMax) * 100
              : 0.0;
          final barHeight = stats.breaksTaken > 0 ? rawHeight.clamp(4.0, 100.0) : 0.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${stats.breaksTaken}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? ChirpColors.of(context).brand
                        : ChirpColors.of(context).brand.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dayLabels[dayOfWeek - 1],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
