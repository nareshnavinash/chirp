import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/services/storage_service.dart';
import 'package:chirp/features/settings/settings_model.dart';
import 'package:chirp/core/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = StorageService();
    await service.init();
  });

  group('StorageService', () {
    group('loadSettings', () {
      test('returns defaults when no stored values', () {
        final settings = service.loadSettings();
        expect(settings.workMinutes, AppConstants.defaultWorkMinutes);
        expect(settings.breakSeconds, AppConstants.defaultBreakSeconds);
        expect(settings.longBreakMinutes, AppConstants.defaultLongBreakMinutes);
        expect(settings.longBreakInterval, AppConstants.defaultLongBreakInterval);
        expect(settings.breaksEnabled, true);
        expect(settings.maxPostponesPerDay, 5);
        expect(settings.blinkRemindersEnabled, true);
        expect(settings.postureRemindersEnabled, true);
        expect(settings.autoStart, false);
        expect(settings.startMinimized, false);
        expect(settings.idleThresholdMinutes, 3);
        expect(settings.scheduleEnabled, false);
        expect(settings.activeDays, [1, 2, 3, 4, 5]);
        expect(settings.scheduleStartHour, 9);
        expect(settings.scheduleEndHour, 17);
      });

      test('returns stored values', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(AppConstants.keyWorkMinutes, 30);
        await prefs.setInt(AppConstants.keyBreakSeconds, 45);
        await prefs.setBool(AppConstants.keyBreaksEnabled, false);

        final settings = service.loadSettings();
        expect(settings.workMinutes, 30);
        expect(settings.breakSeconds, 45);
        expect(settings.breaksEnabled, false);
      });
    });

    group('saveSettings', () {
      test('persists all settings', () async {
        const settings = SettingsModel(
          workMinutes: 30,
          breakSeconds: 45,
          longBreakMinutes: 10,
          longBreakInterval: 3,
          breaksEnabled: false,
          maxPostponesPerDay: 2,
          blinkRemindersEnabled: false,
          blinkIntervalMinutes: 15,
          postureRemindersEnabled: false,
          postureIntervalMinutes: 45,
          autoStart: true,
          startMinimized: true,
          idleThresholdMinutes: 10,
          scheduleEnabled: true,
          activeDays: [1, 3, 5],
          scheduleStartHour: 8,
          scheduleStartMinute: 30,
          scheduleEndHour: 18,
          scheduleEndMinute: 45,
        );
        await service.saveSettings(settings);

        final loaded = service.loadSettings();
        expect(loaded.workMinutes, 30);
        expect(loaded.breakSeconds, 45);
        expect(loaded.longBreakMinutes, 10);
        expect(loaded.longBreakInterval, 3);
        expect(loaded.breaksEnabled, false);
        expect(loaded.maxPostponesPerDay, 2);
        expect(loaded.blinkRemindersEnabled, false);
        expect(loaded.blinkIntervalMinutes, 15);
        expect(loaded.postureRemindersEnabled, false);
        expect(loaded.postureIntervalMinutes, 45);
        expect(loaded.autoStart, true);
        expect(loaded.startMinimized, true);
        expect(loaded.idleThresholdMinutes, 10);
        expect(loaded.scheduleEnabled, true);
        expect(loaded.activeDays, [1, 3, 5]);
        expect(loaded.scheduleStartHour, 8);
        expect(loaded.scheduleStartMinute, 30);
        expect(loaded.scheduleEndHour, 18);
        expect(loaded.scheduleEndMinute, 45);
      });
    });

    group('round-trip', () {
      test('save then load preserves all settings', () async {
        const original = SettingsModel(
          workMinutes: 50,
          breakSeconds: 60,
          activeDays: [6, 7],
          scheduleEnabled: true,
        );
        await service.saveSettings(original);
        final loaded = service.loadSettings();
        expect(loaded.workMinutes, original.workMinutes);
        expect(loaded.breakSeconds, original.breakSeconds);
        expect(loaded.activeDays, original.activeDays);
        expect(loaded.scheduleEnabled, original.scheduleEnabled);
      });

      test('overwriting settings works', () async {
        await service.saveSettings(const SettingsModel(workMinutes: 10));
        await service.saveSettings(const SettingsModel(workMinutes: 50));
        final loaded = service.loadSettings();
        expect(loaded.workMinutes, 50);
      });
    });
  });
}
