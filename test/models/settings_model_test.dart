import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/features/settings/settings_model.dart';
import 'package:chirp/core/app_constants.dart';

void main() {
  group('SettingsModel', () {
    group('constructor defaults', () {
      test('uses AppConstants defaults for work/break durations', () {
        const settings = SettingsModel();
        expect(settings.workMinutes, AppConstants.defaultWorkMinutes);
        expect(settings.breakSeconds, AppConstants.defaultBreakSeconds);
        expect(settings.longBreakMinutes, AppConstants.defaultLongBreakMinutes);
        expect(settings.longBreakInterval, AppConstants.defaultLongBreakInterval);
      });

      test('uses AppConstants defaults for reminder intervals', () {
        const settings = SettingsModel();
        expect(settings.blinkIntervalMinutes, AppConstants.defaultBlinkReminderMinutes);
        expect(settings.postureIntervalMinutes, AppConstants.defaultPostureReminderMinutes);
      });

      test('enables breaks and reminders by default', () {
        const settings = SettingsModel();
        expect(settings.breaksEnabled, true);
        expect(settings.blinkRemindersEnabled, true);
        expect(settings.postureRemindersEnabled, true);
      });

      test('disables autoStart and startMinimized by default', () {
        const settings = SettingsModel();
        expect(settings.autoStart, false);
        expect(settings.startMinimized, false);
      });

      test('defaults to weekday schedule 9-17', () {
        const settings = SettingsModel();
        expect(settings.scheduleEnabled, false);
        expect(settings.activeDays, [1, 2, 3, 4, 5]);
        expect(settings.scheduleStartHour, 9);
        expect(settings.scheduleStartMinute, 0);
        expect(settings.scheduleEndHour, 17);
        expect(settings.scheduleEndMinute, 0);
      });

      test('defaults idle threshold to 3 minutes', () {
        const settings = SettingsModel();
        expect(settings.idleThresholdMinutes, 3);
      });

      test('defaults max postpones to 5', () {
        const settings = SettingsModel();
        expect(settings.maxPostponesPerDay, 5);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const settings = SettingsModel(
          workMinutes: 25,
          breakSeconds: 30,
          longBreakMinutes: 10,
          longBreakInterval: 3,
          breaksEnabled: false,
          maxPostponesPerDay: 3,
          blinkRemindersEnabled: false,
          blinkIntervalMinutes: 15,
          postureRemindersEnabled: false,
          postureIntervalMinutes: 45,
          autoStart: true,
          startMinimized: true,
          idleThresholdMinutes: 5,
          scheduleEnabled: true,
          activeDays: [1, 3, 5],
          scheduleStartHour: 8,
          scheduleStartMinute: 30,
          scheduleEndHour: 18,
          scheduleEndMinute: 45,
        );

        final json = settings.toJson();
        expect(json['workMinutes'], 25);
        expect(json['breakSeconds'], 30);
        expect(json['longBreakMinutes'], 10);
        expect(json['longBreakInterval'], 3);
        expect(json['breaksEnabled'], false);
        expect(json['maxPostponesPerDay'], 3);
        expect(json['blinkRemindersEnabled'], false);
        expect(json['blinkIntervalMinutes'], 15);
        expect(json['postureRemindersEnabled'], false);
        expect(json['postureIntervalMinutes'], 45);
        expect(json['autoStart'], true);
        expect(json['startMinimized'], true);
        expect(json['idleThresholdMinutes'], 5);
        expect(json['scheduleEnabled'], true);
        expect(json['activeDays'], [1, 3, 5]);
        expect(json['scheduleStartHour'], 8);
        expect(json['scheduleStartMinute'], 30);
        expect(json['scheduleEndHour'], 18);
        expect(json['scheduleEndMinute'], 45);
      });

      test('serializes default settings with all 19 fields', () {
        final json = const SettingsModel().toJson();
        expect(json.keys.length, 19);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'workMinutes': 30,
          'breakSeconds': 45,
          'longBreakMinutes': 15,
          'longBreakInterval': 6,
          'breaksEnabled': false,
          'maxPostponesPerDay': 2,
          'blinkRemindersEnabled': false,
          'blinkIntervalMinutes': 20,
          'postureRemindersEnabled': false,
          'postureIntervalMinutes': 60,
          'autoStart': true,
          'startMinimized': true,
          'idleThresholdMinutes': 10,
          'scheduleEnabled': true,
          'activeDays': [1, 2, 3],
          'scheduleStartHour': 7,
          'scheduleStartMinute': 15,
          'scheduleEndHour': 19,
          'scheduleEndMinute': 30,
        };

        final settings = SettingsModel.fromJson(json);
        expect(settings.workMinutes, 30);
        expect(settings.breakSeconds, 45);
        expect(settings.longBreakMinutes, 15);
        expect(settings.longBreakInterval, 6);
        expect(settings.breaksEnabled, false);
        expect(settings.maxPostponesPerDay, 2);
        expect(settings.blinkRemindersEnabled, false);
        expect(settings.blinkIntervalMinutes, 20);
        expect(settings.postureRemindersEnabled, false);
        expect(settings.postureIntervalMinutes, 60);
        expect(settings.autoStart, true);
        expect(settings.startMinimized, true);
        expect(settings.idleThresholdMinutes, 10);
        expect(settings.scheduleEnabled, true);
        expect(settings.activeDays, [1, 2, 3]);
        expect(settings.scheduleStartHour, 7);
        expect(settings.scheduleStartMinute, 15);
        expect(settings.scheduleEndHour, 19);
        expect(settings.scheduleEndMinute, 30);
      });

      test('uses defaults for missing fields', () {
        final settings = SettingsModel.fromJson({});
        expect(settings.workMinutes, AppConstants.defaultWorkMinutes);
        expect(settings.breakSeconds, AppConstants.defaultBreakSeconds);
        expect(settings.breaksEnabled, true);
        expect(settings.activeDays, [1, 2, 3, 4, 5]);
      });

      test('handles null values gracefully', () {
        final json = {
          'workMinutes': null,
          'breakSeconds': null,
          'breaksEnabled': null,
        };
        final settings = SettingsModel.fromJson(json);
        expect(settings.workMinutes, AppConstants.defaultWorkMinutes);
        expect(settings.breakSeconds, AppConstants.defaultBreakSeconds);
        expect(settings.breaksEnabled, true);
      });
    });

    group('JSON round-trip', () {
      test('default settings survive round-trip', () {
        const original = SettingsModel();
        final restored = SettingsModel.fromJson(original.toJson());
        expect(restored.workMinutes, original.workMinutes);
        expect(restored.breakSeconds, original.breakSeconds);
        expect(restored.longBreakMinutes, original.longBreakMinutes);
        expect(restored.longBreakInterval, original.longBreakInterval);
        expect(restored.breaksEnabled, original.breaksEnabled);
        expect(restored.maxPostponesPerDay, original.maxPostponesPerDay);
        expect(restored.blinkRemindersEnabled, original.blinkRemindersEnabled);
        expect(restored.blinkIntervalMinutes, original.blinkIntervalMinutes);
        expect(restored.postureRemindersEnabled, original.postureRemindersEnabled);
        expect(restored.postureIntervalMinutes, original.postureIntervalMinutes);
        expect(restored.autoStart, original.autoStart);
        expect(restored.startMinimized, original.startMinimized);
        expect(restored.idleThresholdMinutes, original.idleThresholdMinutes);
        expect(restored.scheduleEnabled, original.scheduleEnabled);
        expect(restored.activeDays, original.activeDays);
        expect(restored.scheduleStartHour, original.scheduleStartHour);
        expect(restored.scheduleStartMinute, original.scheduleStartMinute);
        expect(restored.scheduleEndHour, original.scheduleEndHour);
        expect(restored.scheduleEndMinute, original.scheduleEndMinute);
      });

      test('custom settings survive round-trip', () {
        const original = SettingsModel(
          workMinutes: 50,
          breakSeconds: 60,
          activeDays: [6, 7],
          scheduleEnabled: true,
        );
        final restored = SettingsModel.fromJson(original.toJson());
        expect(restored.workMinutes, 50);
        expect(restored.breakSeconds, 60);
        expect(restored.activeDays, [6, 7]);
        expect(restored.scheduleEnabled, true);
      });
    });

    group('copyWith', () {
      test('copies single field', () {
        const original = SettingsModel();
        final modified = original.copyWith(workMinutes: 30);
        expect(modified.workMinutes, 30);
        expect(modified.breakSeconds, original.breakSeconds);
        expect(modified.breaksEnabled, original.breaksEnabled);
      });

      test('copies multiple fields', () {
        const original = SettingsModel();
        final modified = original.copyWith(
          workMinutes: 30,
          breaksEnabled: false,
          activeDays: [1, 2],
        );
        expect(modified.workMinutes, 30);
        expect(modified.breaksEnabled, false);
        expect(modified.activeDays, [1, 2]);
        expect(modified.breakSeconds, original.breakSeconds);
      });

      test('returns new instance (does not mutate original)', () {
        const original = SettingsModel();
        final modified = original.copyWith(workMinutes: 99);
        expect(original.workMinutes, AppConstants.defaultWorkMinutes);
        expect(modified.workMinutes, 99);
      });

      test('copies all fields when all specified', () {
        final modified = const SettingsModel().copyWith(
          workMinutes: 1,
          breakSeconds: 2,
          longBreakMinutes: 3,
          longBreakInterval: 4,
          breaksEnabled: false,
          maxPostponesPerDay: 5,
          blinkRemindersEnabled: false,
          blinkIntervalMinutes: 6,
          postureRemindersEnabled: false,
          postureIntervalMinutes: 7,
          autoStart: true,
          startMinimized: true,
          idleThresholdMinutes: 8,
          scheduleEnabled: true,
          activeDays: [7],
          scheduleStartHour: 10,
          scheduleStartMinute: 11,
          scheduleEndHour: 12,
          scheduleEndMinute: 13,
        );
        expect(modified.workMinutes, 1);
        expect(modified.breakSeconds, 2);
        expect(modified.longBreakMinutes, 3);
        expect(modified.longBreakInterval, 4);
        expect(modified.breaksEnabled, false);
        expect(modified.maxPostponesPerDay, 5);
        expect(modified.blinkRemindersEnabled, false);
        expect(modified.blinkIntervalMinutes, 6);
        expect(modified.postureRemindersEnabled, false);
        expect(modified.postureIntervalMinutes, 7);
        expect(modified.autoStart, true);
        expect(modified.startMinimized, true);
        expect(modified.idleThresholdMinutes, 8);
        expect(modified.scheduleEnabled, true);
        expect(modified.activeDays, [7]);
        expect(modified.scheduleStartHour, 10);
        expect(modified.scheduleStartMinute, 11);
        expect(modified.scheduleEndHour, 12);
        expect(modified.scheduleEndMinute, 13);
      });
    });
  });
}
