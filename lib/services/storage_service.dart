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
      blinkRemindersEnabled:
          _prefs.getBool(AppConstants.keyBlinkRemindersEnabled) ?? true,
      postureRemindersEnabled:
          _prefs.getBool(AppConstants.keyPostureRemindersEnabled) ?? true,
      autoStart: _prefs.getBool(AppConstants.keyAutoStart) ?? false,
      startMinimized: _prefs.getBool(AppConstants.keyStartMinimized) ?? false,
    );
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await Future.wait([
      _prefs.setInt(AppConstants.keyWorkMinutes, settings.workMinutes),
      _prefs.setInt(AppConstants.keyBreakSeconds, settings.breakSeconds),
      _prefs.setInt(AppConstants.keyLongBreakMinutes, settings.longBreakMinutes),
      _prefs.setInt(
        AppConstants.keyLongBreakInterval,
        settings.longBreakInterval,
      ),
      _prefs.setBool(AppConstants.keyBreaksEnabled, settings.breaksEnabled),
      _prefs.setBool(
        AppConstants.keyBlinkRemindersEnabled,
        settings.blinkRemindersEnabled,
      ),
      _prefs.setBool(
        AppConstants.keyPostureRemindersEnabled,
        settings.postureRemindersEnabled,
      ),
      _prefs.setBool(AppConstants.keyAutoStart, settings.autoStart),
      _prefs.setBool(AppConstants.keyStartMinimized, settings.startMinimized),
    ]);
  }
}
