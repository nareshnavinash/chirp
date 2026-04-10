import 'dart:async';
import 'package:flutter/material.dart';

class ScheduleConfig {
  final Set<int> activeDays; // 1=Monday through 7=Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool enabled;

  const ScheduleConfig({
    this.activeDays = const {1, 2, 3, 4, 5}, // Weekdays
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 17, minute: 0),
    this.enabled = false,
  });

  bool isActiveNow() {
    if (!enabled) return true; // If scheduling disabled, always active

    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1=Monday, 7=Sunday

    if (!activeDays.contains(dayOfWeek)) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }
}

class ScheduleService {
  Timer? _checkTimer;
  ScheduleConfig _config = const ScheduleConfig();
  bool _wasActive = true;

  void Function(bool isWithinSchedule)? onScheduleChanged;

  void configure(ScheduleConfig config) {
    _config = config;
  }

  void start() {
    stop();
    _wasActive = _config.isActiveNow();
    // Check schedule every minute
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final isActive = _config.isActiveNow();
      if (isActive != _wasActive) {
        _wasActive = isActive;
        onScheduleChanged?.call(isActive);
      }
    });
  }

  void stop() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  bool get isActiveNow => _config.isActiveNow();

  void dispose() {
    stop();
  }
}
