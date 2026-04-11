import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/services/custom_reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CustomReminderService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = CustomReminderService();
    await service.init(prefs);
  });

  tearDown(() {
    service.dispose();
  });

  group('CustomReminderService', () {
    group('reminders CRUD', () {
      test('starts with empty reminders', () {
        expect(service.reminders, isEmpty);
      });

      test('addReminder adds to list', () async {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink water',
          intervalMinutes: 30,
        );
        await service.addReminder(reminder);
        expect(service.reminders.length, 1);
        expect(service.reminders.first.name, 'Water');
      });

      test('addReminder persists to SharedPreferences', () async {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink water',
          intervalMinutes: 30,
        );
        await service.addReminder(reminder);
        final raw = prefs.getStringList('custom_reminders');
        expect(raw, isNotNull);
        expect(raw!.length, 1);
        final data = jsonDecode(raw.first) as Map<String, dynamic>;
        expect(data['name'], 'Water');
      });

      test('updateReminder modifies existing', () async {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink water',
          intervalMinutes: 30,
        );
        await service.addReminder(reminder);
        await service.updateReminder(reminder.copyWith(name: 'Tea'));
        expect(service.reminders.first.name, 'Tea');
      });

      test('removeReminder deletes from list', () async {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink water',
          intervalMinutes: 30,
        );
        await service.addReminder(reminder);
        await service.removeReminder('r-1');
        expect(service.reminders, isEmpty);
      });

      test('removeReminder persists removal', () async {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink water',
          intervalMinutes: 30,
        );
        await service.addReminder(reminder);
        await service.removeReminder('r-1');
        final raw = prefs.getStringList('custom_reminders');
        expect(raw, isEmpty);
      });
    });

    group('scheduled breaks CRUD', () {
      test('starts with empty scheduled breaks', () {
        expect(service.scheduledBreaks, isEmpty);
      });

      test('addScheduledBreak adds to list', () async {
        const sb = ScheduledBreak(
          id: 'sb-1',
          name: 'Lunch',
          hour: 12,
          minute: 0,
        );
        await service.addScheduledBreak(sb);
        expect(service.scheduledBreaks.length, 1);
        expect(service.scheduledBreaks.first.name, 'Lunch');
      });

      test('addScheduledBreak persists', () async {
        const sb = ScheduledBreak(
          id: 'sb-1',
          name: 'Lunch',
          hour: 12,
          minute: 0,
        );
        await service.addScheduledBreak(sb);
        final raw = prefs.getStringList('scheduled_breaks');
        expect(raw, isNotNull);
        expect(raw!.length, 1);
      });

      test('removeScheduledBreak deletes', () async {
        const sb = ScheduledBreak(
          id: 'sb-1',
          name: 'Lunch',
          hour: 12,
          minute: 0,
        );
        await service.addScheduledBreak(sb);
        await service.removeScheduledBreak('sb-1');
        expect(service.scheduledBreaks, isEmpty);
      });
    });

    group('persistence loading', () {
      test('loads reminders from prefs on init', () async {
        final reminderJson = const CustomReminder(
          id: 'r-1',
          name: 'Saved',
          message: 'From prefs',
          intervalMinutes: 15,
        ).toJson();
        await prefs.setStringList('custom_reminders', [jsonEncode(reminderJson)]);

        final newService = CustomReminderService();
        await newService.init(prefs);
        expect(newService.reminders.length, 1);
        expect(newService.reminders.first.name, 'Saved');
        newService.dispose();
      });

      test('loads scheduled breaks from prefs on init', () async {
        final sbJson = const ScheduledBreak(
          id: 'sb-1',
          name: 'Saved Break',
          hour: 10,
          minute: 30,
        ).toJson();
        await prefs.setStringList('scheduled_breaks', [jsonEncode(sbJson)]);

        final newService = CustomReminderService();
        await newService.init(prefs);
        expect(newService.scheduledBreaks.length, 1);
        expect(newService.scheduledBreaks.first.name, 'Saved Break');
        newService.dispose();
      });
    });

    group('wind-down', () {
      test('defaults to disabled', () {
        expect(service.windDownEnabled, false);
      });

      test('wind-down defaults to 18:00', () {
        expect(service.windDownHour, 18);
        expect(service.windDownMinute, 0);
      });
    });

    group('start/stop', () {
      test('start and stop do not throw', () {
        service.start();
        service.stop();
      });
    });

    group('unmodifiable lists', () {
      test('reminders list is unmodifiable', () {
        expect(
          () => service.reminders.add(const CustomReminder(
            id: 'x',
            name: 'x',
            message: 'x',
            intervalMinutes: 1,
          )),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('scheduledBreaks list is unmodifiable', () {
        expect(
          () => service.scheduledBreaks.add(const ScheduledBreak(
            id: 'x',
            name: 'x',
            hour: 0,
            minute: 0,
          )),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}
