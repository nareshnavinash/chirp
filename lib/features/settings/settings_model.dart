import 'package:blink/core/app_constants.dart';

class SettingsModel {
  final int workMinutes;
  final int breakSeconds;
  final int longBreakMinutes;
  final int longBreakInterval;
  final bool breaksEnabled;
  final bool blinkRemindersEnabled;
  final bool postureRemindersEnabled;
  final bool autoStart;
  final bool startMinimized;

  const SettingsModel({
    this.workMinutes = AppConstants.defaultWorkMinutes,
    this.breakSeconds = AppConstants.defaultBreakSeconds,
    this.longBreakMinutes = AppConstants.defaultLongBreakMinutes,
    this.longBreakInterval = AppConstants.defaultLongBreakInterval,
    this.breaksEnabled = true,
    this.blinkRemindersEnabled = true,
    this.postureRemindersEnabled = true,
    this.autoStart = false,
    this.startMinimized = false,
  });

  SettingsModel copyWith({
    int? workMinutes,
    int? breakSeconds,
    int? longBreakMinutes,
    int? longBreakInterval,
    bool? breaksEnabled,
    bool? blinkRemindersEnabled,
    bool? postureRemindersEnabled,
    bool? autoStart,
    bool? startMinimized,
  }) {
    return SettingsModel(
      workMinutes: workMinutes ?? this.workMinutes,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      breaksEnabled: breaksEnabled ?? this.breaksEnabled,
      blinkRemindersEnabled:
          blinkRemindersEnabled ?? this.blinkRemindersEnabled,
      postureRemindersEnabled:
          postureRemindersEnabled ?? this.postureRemindersEnabled,
      autoStart: autoStart ?? this.autoStart,
      startMinimized: startMinimized ?? this.startMinimized,
    );
  }
}
