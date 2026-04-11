class AppConstants {
  static const String appName = 'Chirp';
  static const String appVersion = '0.1.0';

  // Default break settings
  static const int defaultWorkMinutes = 20;
  static const int defaultBreakSeconds = 20;
  static const int defaultLongBreakMinutes = 5;
  static const int defaultLongBreakInterval = 4; // Every 4th break is long

  // Default reminder settings
  static const int defaultBlinkReminderMinutes = 10;
  static const int defaultPostureReminderMinutes = 30;

  // Storage keys
  static const String keyWorkMinutes = 'work_minutes';
  static const String keyBreakSeconds = 'break_seconds';
  static const String keyLongBreakMinutes = 'long_break_minutes';
  static const String keyLongBreakInterval = 'long_break_interval';
  static const String keyBreaksEnabled = 'breaks_enabled';
  static const String keyBlinkRemindersEnabled = 'blink_reminders_enabled';
  static const String keyPostureRemindersEnabled = 'posture_reminders_enabled';
  static const String keyAutoStart = 'auto_start';
  static const String keyStartMinimized = 'start_minimized';
}
