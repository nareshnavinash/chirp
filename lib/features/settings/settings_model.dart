import 'package:blink/core/app_constants.dart';

class SettingsModel {
  // Break settings
  final int workMinutes;
  final int breakSeconds;
  final int longBreakMinutes;
  final int longBreakInterval;
  final bool breaksEnabled;
  final int maxPostponesPerDay;

  // Reminder settings
  final bool blinkRemindersEnabled;
  final int blinkIntervalMinutes;
  final bool postureRemindersEnabled;
  final int postureIntervalMinutes;

  // General settings
  final bool autoStart;
  final bool startMinimized;

  // Idle settings
  final int idleThresholdMinutes;

  // Schedule settings
  final bool scheduleEnabled;
  final List<int> activeDays; // 1=Mon through 7=Sun
  final int scheduleStartHour;
  final int scheduleStartMinute;
  final int scheduleEndHour;
  final int scheduleEndMinute;

  const SettingsModel({
    this.workMinutes = AppConstants.defaultWorkMinutes,
    this.breakSeconds = AppConstants.defaultBreakSeconds,
    this.longBreakMinutes = AppConstants.defaultLongBreakMinutes,
    this.longBreakInterval = AppConstants.defaultLongBreakInterval,
    this.breaksEnabled = true,
    this.maxPostponesPerDay = 5,
    this.blinkRemindersEnabled = true,
    this.blinkIntervalMinutes = AppConstants.defaultBlinkReminderMinutes,
    this.postureRemindersEnabled = true,
    this.postureIntervalMinutes = AppConstants.defaultPostureReminderMinutes,
    this.autoStart = false,
    this.startMinimized = false,
    this.idleThresholdMinutes = 3,
    this.scheduleEnabled = false,
    this.activeDays = const [1, 2, 3, 4, 5],
    this.scheduleStartHour = 9,
    this.scheduleStartMinute = 0,
    this.scheduleEndHour = 17,
    this.scheduleEndMinute = 0,
  });

  SettingsModel copyWith({
    int? workMinutes,
    int? breakSeconds,
    int? longBreakMinutes,
    int? longBreakInterval,
    bool? breaksEnabled,
    int? maxPostponesPerDay,
    bool? blinkRemindersEnabled,
    int? blinkIntervalMinutes,
    bool? postureRemindersEnabled,
    int? postureIntervalMinutes,
    bool? autoStart,
    bool? startMinimized,
    int? idleThresholdMinutes,
    bool? scheduleEnabled,
    List<int>? activeDays,
    int? scheduleStartHour,
    int? scheduleStartMinute,
    int? scheduleEndHour,
    int? scheduleEndMinute,
  }) {
    return SettingsModel(
      workMinutes: workMinutes ?? this.workMinutes,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      breaksEnabled: breaksEnabled ?? this.breaksEnabled,
      maxPostponesPerDay: maxPostponesPerDay ?? this.maxPostponesPerDay,
      blinkRemindersEnabled:
          blinkRemindersEnabled ?? this.blinkRemindersEnabled,
      blinkIntervalMinutes: blinkIntervalMinutes ?? this.blinkIntervalMinutes,
      postureRemindersEnabled:
          postureRemindersEnabled ?? this.postureRemindersEnabled,
      postureIntervalMinutes:
          postureIntervalMinutes ?? this.postureIntervalMinutes,
      autoStart: autoStart ?? this.autoStart,
      startMinimized: startMinimized ?? this.startMinimized,
      idleThresholdMinutes: idleThresholdMinutes ?? this.idleThresholdMinutes,
      scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
      activeDays: activeDays ?? this.activeDays,
      scheduleStartHour: scheduleStartHour ?? this.scheduleStartHour,
      scheduleStartMinute: scheduleStartMinute ?? this.scheduleStartMinute,
      scheduleEndHour: scheduleEndHour ?? this.scheduleEndHour,
      scheduleEndMinute: scheduleEndMinute ?? this.scheduleEndMinute,
    );
  }
}
