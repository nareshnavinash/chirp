import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/services/stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StatsService service;
  late SharedPreferences prefs;

  String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = StatsService();
    await service.init(prefs);
  });

  group('StatsService', () {
    group('getToday', () {
      test('returns empty stats for new day', () {
        final stats = service.getToday();
        expect(stats.date, todayKey());
        expect(stats.breaksTaken, 0);
        expect(stats.breaksSkipped, 0);
        expect(stats.breaksPostponed, 0);
      });

      test('returns persisted stats', () async {
        final statsJson = DailyStats(
          date: todayKey(),
          breaksTaken: 5,
          breaksSkipped: 1,
        ).toJson();
        await prefs.setString('stats_${todayKey()}', jsonEncode(statsJson));

        final stats = service.getToday();
        expect(stats.breaksTaken, 5);
        expect(stats.breaksSkipped, 1);
      });
    });

    group('recordBreakTaken', () {
      test('increments breaksTaken', () async {
        await service.recordBreakTaken();
        final stats = service.getToday();
        expect(stats.breaksTaken, 1);
      });

      test('accumulates multiple breaks', () async {
        await service.recordBreakTaken();
        await service.recordBreakTaken();
        await service.recordBreakTaken();
        final stats = service.getToday();
        expect(stats.breaksTaken, 3);
      });

      test('persists to SharedPreferences', () async {
        await service.recordBreakTaken();
        final raw = prefs.getString('stats_${todayKey()}');
        expect(raw, isNotNull);
        final data = jsonDecode(raw!) as Map<String, dynamic>;
        expect(data['breaksTaken'], 1);
      });
    });

    group('recordBreakSkipped', () {
      test('increments breaksSkipped', () async {
        await service.recordBreakSkipped();
        final stats = service.getToday();
        expect(stats.breaksSkipped, 1);
      });

      test('persists to SharedPreferences', () async {
        await service.recordBreakSkipped();
        await service.recordBreakSkipped();
        final stats = service.getToday();
        expect(stats.breaksSkipped, 2);
      });
    });

    group('recordPostpone', () {
      test('increments breaksPostponed', () async {
        await service.recordPostpone();
        final stats = service.getToday();
        expect(stats.breaksPostponed, 1);
      });
    });

    group('getWeek', () {
      test('returns 7 days of stats', () {
        final week = service.getWeek();
        expect(week.length, 7);
      });

      test('last entry is today', () {
        final week = service.getWeek();
        expect(week.last.date, todayKey());
      });

      test('returns empty stats for days with no data', () {
        final week = service.getWeek();
        for (final day in week) {
          expect(day.breaksTaken, 0);
        }
      });

      test('includes persisted data for today', () async {
        await service.recordBreakTaken();
        await service.recordBreakTaken();
        final week = service.getWeek();
        expect(week.last.breaksTaken, 2);
      });
    });
  });
}
