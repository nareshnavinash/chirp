import 'package:shared_preferences/shared_preferences.dart';
import 'package:blink/core/app_constants.dart';
import 'package:blink/features/settings/settings_model.dart';

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SettingsModel loadSettings() {
    return SettingsModel(
      workMinutes:
          _prefs.getInt(AppConstants.keyWorkMinutes) ??
          AppConstants.defaultWorkMinutes,
      breakSeconds:
          _prefs.getInt(AppConstants.keyBreakSeconds) ??
          AppConstants.defaultBreakSeconds,
      longBreakMinutes:
          _prefs.getInt(AppConstants.keyLongBreakMinutes) ??
          AppConstants.defaultLongBreakMinutes,
      longBreakInterval:
          _prefs.getInt(AppConstants.keyLongBreakInterval) ??
          AppConstants.defaultLongBreakInterval,
      breaksEnabled: _prefs.getBool(AppConstants.keyBreaksEnabled) ?? true,
      maxPostponesPerDay: _prefs.getInt('max_postpones_per_day') ?? 5,
      blinkRemindersEnabled:
          _prefs.getBool(AppConstants.keyBlinkRemindersEnabled) ?? true,
      blinkIntervalMinutes: _prefs.getInt('blink_interval_minutes') ??
          AppConstants.defaultBlinkReminderMinutes,
      postureRemindersEnabled:
          _prefs.getBool(AppConstants.keyPostureRemindersEnabled) ?? true,
      postureIntervalMinutes: _prefs.getInt('posture_interval_minutes') ??
          AppConstants.defaultPostureReminderMinutes,
      autoStart: _prefs.getBool(AppConstants.keyAutoStart) ?? false,
      startMinimized: _prefs.getBool(AppConstants.keyStartMinimized) ?? false,
      idleThresholdMinutes: _prefs.getInt('idle_threshold_minutes') ?? 3,
      scheduleEnabled: _prefs.getBool('schedule_enabled') ?? false,
      activeDays: _prefs.getStringList('active_days')?.map(int.parse).toList() ??
          [1, 2, 3, 4, 5],
      scheduleStartHour: _prefs.getInt('schedule_start_hour') ?? 9,
      scheduleStartMinute: _prefs.getInt('schedule_start_minute') ?? 0,
      scheduleEndHour: _prefs.getInt('schedule_end_hour') ?? 17,
      scheduleEndMinute: _prefs.getInt('schedule_end_minute') ?? 0,
    );
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await Future.wait([
      _prefs.setInt(AppConstants.keyWorkMinutes, settings.workMinutes),
      _prefs.setInt(AppConstants.keyBreakSeconds, settings.breakSeconds),
      _prefs.setInt(AppConstants.keyLongBreakMinutes, settings.longBreakMinutes),
      _prefs.setInt(AppConstants.keyLongBreakInterval, settings.longBreakInterval),
      _prefs.setBool(AppConstants.keyBreaksEnabled, settings.breaksEnabled),
      _prefs.setInt('max_postpones_per_day', settings.maxPostponesPerDay),
      _prefs.setBool(AppConstants.keyBlinkRemindersEnabled, settings.blinkRemindersEnabled),
      _prefs.setInt('blink_interval_minutes', settings.blinkIntervalMinutes),
      _prefs.setBool(AppConstants.keyPostureRemindersEnabled, settings.postureRemindersEnabled),
      _prefs.setInt('posture_interval_minutes', settings.postureIntervalMinutes),
      _prefs.setBool(AppConstants.keyAutoStart, settings.autoStart),
      _prefs.setBool(AppConstants.keyStartMinimized, settings.startMinimized),
      _prefs.setInt('idle_threshold_minutes', settings.idleThresholdMinutes),
      _prefs.setBool('schedule_enabled', settings.scheduleEnabled),
      _prefs.setStringList('active_days', settings.activeDays.map((d) => d.toString()).toList()),
      _prefs.setInt('schedule_start_hour', settings.scheduleStartHour),
      _prefs.setInt('schedule_start_minute', settings.scheduleStartMinute),
      _prefs.setInt('schedule_end_hour', settings.scheduleEndHour),
      _prefs.setInt('schedule_end_minute', settings.scheduleEndMinute),
    ]);
  }
}
