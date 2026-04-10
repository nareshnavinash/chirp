import 'dart:async';
import 'dart:convert';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomReminder {
  final String id;
  final String name;
  final String message;
  final int intervalMinutes;
  final bool enabled;

  const CustomReminder({
    required this.id,
    required this.name,
    required this.message,
    required this.intervalMinutes,
    this.enabled = true,
  });

  CustomReminder copyWith({
    String? name,
    String? message,
    int? intervalMinutes,
    bool? enabled,
  }) {
    return CustomReminder(
      id: id,
      name: name ?? this.name,
      message: message ?? this.message,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'message': message,
    'intervalMinutes': intervalMinutes,
    'enabled': enabled,
  };

  factory CustomReminder.fromJson(Map<String, dynamic> json) => CustomReminder(
    id: json['id'] as String,
    name: json['name'] as String,
    message: json['message'] as String,
    intervalMinutes: json['intervalMinutes'] as int,
    enabled: json['enabled'] as bool? ?? true,
  );
}

class ScheduledBreak {
  final String id;
  final String name;
  final int hour;
  final int minute;
  final int durationMinutes;
  final List<int> activeDays; // 1=Mon through 7=Sun
  final bool enabled;

  const ScheduledBreak({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    this.durationMinutes = 15,
    this.activeDays = const [1, 2, 3, 4, 5],
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hour': hour,
    'minute': minute,
    'durationMinutes': durationMinutes,
    'activeDays': activeDays,
    'enabled': enabled,
  };

  factory ScheduledBreak.fromJson(Map<String, dynamic> json) => ScheduledBreak(
    id: json['id'] as String,
    name: json['name'] as String,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    durationMinutes: json['durationMinutes'] as int? ?? 15,
    activeDays: (json['activeDays'] as List<dynamic>?)
        ?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5],
    enabled: json['enabled'] as bool? ?? true,
  );
}

class CustomReminderService {
  final Map<String, Timer> _timers = {};
  late final SharedPreferences _prefs;

  List<CustomReminder> _reminders = [];
  List<ScheduledBreak> _scheduledBreaks = [];
  Timer? _scheduleCheckTimer;

  // Wind-down
  bool windDownEnabled = false;
  int windDownHour = 18;
  int windDownMinute = 0;

  void Function()? onWindDown;
  void Function(ScheduledBreak)? onScheduledBreak;

  List<CustomReminder> get reminders => List.unmodifiable(_reminders);
  List<ScheduledBreak> get scheduledBreaks => List.unmodifiable(_scheduledBreaks);

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _loadReminders();
    _loadScheduledBreaks();
  }

  void _loadReminders() {
    final raw = _prefs.getStringList('custom_reminders') ?? [];
    _reminders = raw
        .map((s) => CustomReminder.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  void _loadScheduledBreaks() {
    final raw = _prefs.getStringList('scheduled_breaks') ?? [];
    _scheduledBreaks = raw
        .map((s) => ScheduledBreak.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveReminders() async {
    await _prefs.setStringList(
      'custom_reminders',
      _reminders.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  Future<void> _saveScheduledBreaks() async {
    await _prefs.setStringList(
      'scheduled_breaks',
      _scheduledBreaks.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> addReminder(CustomReminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    if (reminder.enabled) {
      _startReminderTimer(reminder);
    }
  }

  Future<void> updateReminder(CustomReminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index >= 0) {
      _reminders[index] = reminder;
      await _saveReminders();
      _stopReminderTimer(reminder.id);
      if (reminder.enabled) {
        _startReminderTimer(reminder);
      }
    }
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    _stopReminderTimer(id);
    await _saveReminders();
  }

  Future<void> addScheduledBreak(ScheduledBreak sb) async {
    _scheduledBreaks.add(sb);
    await _saveScheduledBreaks();
  }

  Future<void> removeScheduledBreak(String id) async {
    _scheduledBreaks.removeWhere((s) => s.id == id);
    await _saveScheduledBreaks();
  }

  void start() {
    for (final r in _reminders) {
      if (r.enabled) {
        _startReminderTimer(r);
      }
    }
    _scheduleCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkScheduledBreaks(),
    );
  }

  void stop() {
    for (final id in _timers.keys.toList()) {
      _stopReminderTimer(id);
    }
    _scheduleCheckTimer?.cancel();
  }

  void _startReminderTimer(CustomReminder reminder) {
    _timers[reminder.id] = Timer.periodic(
      Duration(minutes: reminder.intervalMinutes),
      (_) {
        final notification = LocalNotification(
          title: reminder.name,
          body: reminder.message,
        );
        notification.show();
      },
    );
  }

  void _stopReminderTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  void _checkScheduledBreaks() {
    final now = DateTime.now();
    for (final sb in _scheduledBreaks) {
      if (!sb.enabled) continue;
      if (!sb.activeDays.contains(now.weekday)) continue;
      if (now.hour == sb.hour && now.minute == sb.minute) {
        onScheduledBreak?.call(sb);
      }
    }

    // Wind-down check
    if (windDownEnabled &&
        now.hour == windDownHour &&
        now.minute == windDownMinute) {
      onWindDown?.call();
    }
  }

  void dispose() {
    stop();
  }
}
