import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyStats {
  final String date; // yyyy-MM-dd
  int breaksTaken;
  int breaksSkipped;
  int breaksPostponed;
  int totalScreenMinutes;
  int longestSessionMinutes;
  List<int> sessionLengths; // in minutes

  DailyStats({
    required this.date,
    this.breaksTaken = 0,
    this.breaksSkipped = 0,
    this.breaksPostponed = 0,
    this.totalScreenMinutes = 0,
    this.longestSessionMinutes = 0,
    List<int>? sessionLengths,
  }) : sessionLengths = sessionLengths ?? [];

  int get healthScore {
    var score = 100;
    score -= breaksSkipped * 5;
    score -= breaksPostponed * 1;

    // Penalize long sessions without break
    for (final length in sessionLengths) {
      if (length > 40) score -= 3;
    }

    return score.clamp(0, 100);
  }

  int get medianSessionMinutes {
    if (sessionLengths.isEmpty) return 0;
    final sorted = List<int>.from(sessionLengths)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 0) {
      return (sorted[mid - 1] + sorted[mid]) ~/ 2;
    }
    return sorted[mid];
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'breaksTaken': breaksTaken,
    'breaksSkipped': breaksSkipped,
    'breaksPostponed': breaksPostponed,
    'totalScreenMinutes': totalScreenMinutes,
    'longestSessionMinutes': longestSessionMinutes,
    'sessionLengths': sessionLengths,
  };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    date: json['date'] as String,
    breaksTaken: json['breaksTaken'] as int? ?? 0,
    breaksSkipped: json['breaksSkipped'] as int? ?? 0,
    breaksPostponed: json['breaksPostponed'] as int? ?? 0,
    totalScreenMinutes: json['totalScreenMinutes'] as int? ?? 0,
    longestSessionMinutes: json['longestSessionMinutes'] as int? ?? 0,
    sessionLengths: (json['sessionLengths'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList() ?? [],
  );
}

class StatsService {
  late final SharedPreferences _prefs;
  DateTime? _sessionStart;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _sessionStart = DateTime.now();
  }

  String get _todayKey => _dateKey(DateTime.now());
  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DailyStats getToday() {
    return _load(_todayKey);
  }

  DailyStats _load(String dateKey) {
    final raw = _prefs.getString('stats_$dateKey');
    if (raw == null) return DailyStats(date: dateKey);
    return DailyStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _save(DailyStats stats) async {
    await _prefs.setString('stats_${stats.date}', jsonEncode(stats.toJson()));
  }

  Future<void> recordBreakTaken() async {
    final stats = getToday();
    stats.breaksTaken++;
    _recordSession(stats);
    await _save(stats);
  }

  Future<void> recordBreakSkipped() async {
    final stats = getToday();
    stats.breaksSkipped++;
    await _save(stats);
  }

  Future<void> recordPostpone() async {
    final stats = getToday();
    stats.breaksPostponed++;
    await _save(stats);
  }

  void _recordSession(DailyStats stats) {
    if (_sessionStart != null) {
      final minutes = DateTime.now().difference(_sessionStart!).inMinutes;
      if (minutes > 0) {
        stats.sessionLengths.add(minutes);
        stats.totalScreenMinutes += minutes;
        if (minutes > stats.longestSessionMinutes) {
          stats.longestSessionMinutes = minutes;
        }
      }
    }
    _sessionStart = DateTime.now();
  }

  List<DailyStats> getWeek() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return _load(_dateKey(date));
    });
  }
}
