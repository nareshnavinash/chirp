import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/stats_service.dart';

void main() {
  group('DailyStats', () {
    group('constructor', () {
      test('defaults all counters to zero', () {
        final stats = DailyStats(date: '2024-01-15');
        expect(stats.breaksTaken, 0);
        expect(stats.breaksSkipped, 0);
        expect(stats.breaksPostponed, 0);
        expect(stats.totalScreenMinutes, 0);
        expect(stats.longestSessionMinutes, 0);
        expect(stats.sessionLengths, isEmpty);
      });

      test('accepts custom values', () {
        final stats = DailyStats(
          date: '2024-01-15',
          breaksTaken: 5,
          breaksSkipped: 2,
          breaksPostponed: 1,
          totalScreenMinutes: 480,
          longestSessionMinutes: 60,
          sessionLengths: [20, 30, 60],
        );
        expect(stats.breaksTaken, 5);
        expect(stats.breaksSkipped, 2);
        expect(stats.totalScreenMinutes, 480);
        expect(stats.sessionLengths, [20, 30, 60]);
      });
    });

    group('healthScore', () {
      test('returns 100 for perfect day', () {
        final stats = DailyStats(date: '2024-01-15');
        expect(stats.healthScore, 100);
      });

      test('penalizes skipped breaks by 5 points each', () {
        final stats = DailyStats(
          date: '2024-01-15',
          breaksSkipped: 3,
        );
        expect(stats.healthScore, 85);
      });

      test('penalizes postponed breaks by 1 point each', () {
        final stats = DailyStats(
          date: '2024-01-15',
          breaksPostponed: 4,
        );
        expect(stats.healthScore, 96);
      });

      test('penalizes long sessions (>40 min) by 3 points each', () {
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: [45, 50, 60],
        );
        expect(stats.healthScore, 91);
      });

      test('does not penalize sessions <= 40 min', () {
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: [20, 30, 40],
        );
        expect(stats.healthScore, 100);
      });

      test('combines all penalties', () {
        final stats = DailyStats(
          date: '2024-01-15',
          breaksSkipped: 2,    // -10
          breaksPostponed: 3,  // -3
          sessionLengths: [45, 50], // -6
        );
        expect(stats.healthScore, 81);
      });

      test('clamps to minimum 0', () {
        final stats = DailyStats(
          date: '2024-01-15',
          breaksSkipped: 25,
        );
        expect(stats.healthScore, 0);
      });

      test('clamps to maximum 100', () {
        final stats = DailyStats(date: '2024-01-15');
        expect(stats.healthScore, 100);
      });
    });

    group('medianSessionMinutes', () {
      test('returns 0 for empty sessions', () {
        final stats = DailyStats(date: '2024-01-15');
        expect(stats.medianSessionMinutes, 0);
      });

      test('returns the single session length', () {
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: [20],
        );
        expect(stats.medianSessionMinutes, 20);
      });

      test('returns middle element for odd count', () {
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: [10, 20, 30],
        );
        expect(stats.medianSessionMinutes, 20);
      });

      test('returns average of middle two for even count', () {
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: [10, 20, 30, 40],
        );
        expect(stats.medianSessionMinutes, 25);
      });

      test('sorts before finding median', () {
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: [50, 10, 30],
        );
        expect(stats.medianSessionMinutes, 30);
      });

      test('does not mutate original list', () {
        final sessions = [50, 10, 30];
        final stats = DailyStats(
          date: '2024-01-15',
          sessionLengths: sessions,
        );
        stats.medianSessionMinutes;
        expect(sessions, [50, 10, 30]);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final stats = DailyStats(
          date: '2024-01-15',
          breaksTaken: 5,
          breaksSkipped: 2,
          breaksPostponed: 1,
          totalScreenMinutes: 480,
          longestSessionMinutes: 60,
          sessionLengths: [20, 30, 60],
        );
        final json = stats.toJson();
        expect(json['date'], '2024-01-15');
        expect(json['breaksTaken'], 5);
        expect(json['breaksSkipped'], 2);
        expect(json['breaksPostponed'], 1);
        expect(json['totalScreenMinutes'], 480);
        expect(json['longestSessionMinutes'], 60);
        expect(json['sessionLengths'], [20, 30, 60]);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'date': '2024-01-15',
          'breaksTaken': 3,
          'breaksSkipped': 1,
          'breaksPostponed': 2,
          'totalScreenMinutes': 360,
          'longestSessionMinutes': 45,
          'sessionLengths': [15, 25, 45],
        };
        final stats = DailyStats.fromJson(json);
        expect(stats.date, '2024-01-15');
        expect(stats.breaksTaken, 3);
        expect(stats.breaksSkipped, 1);
        expect(stats.breaksPostponed, 2);
        expect(stats.totalScreenMinutes, 360);
        expect(stats.longestSessionMinutes, 45);
        expect(stats.sessionLengths, [15, 25, 45]);
      });

      test('uses defaults for missing fields', () {
        final stats = DailyStats.fromJson({'date': '2024-01-15'});
        expect(stats.breaksTaken, 0);
        expect(stats.breaksSkipped, 0);
        expect(stats.sessionLengths, isEmpty);
      });
    });

    group('JSON round-trip', () {
      test('data survives round-trip', () {
        final original = DailyStats(
          date: '2024-01-15',
          breaksTaken: 8,
          breaksSkipped: 1,
          breaksPostponed: 3,
          totalScreenMinutes: 450,
          longestSessionMinutes: 55,
          sessionLengths: [20, 25, 55, 30],
        );
        final restored = DailyStats.fromJson(original.toJson());
        expect(restored.date, original.date);
        expect(restored.breaksTaken, original.breaksTaken);
        expect(restored.breaksSkipped, original.breaksSkipped);
        expect(restored.breaksPostponed, original.breaksPostponed);
        expect(restored.totalScreenMinutes, original.totalScreenMinutes);
        expect(restored.longestSessionMinutes, original.longestSessionMinutes);
        expect(restored.sessionLengths, original.sessionLengths);
      });
    });
  });
}
