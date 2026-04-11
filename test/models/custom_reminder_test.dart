import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/custom_reminder_service.dart';

void main() {
  group('CustomReminder', () {
    group('constructor', () {
      test('sets enabled to true by default', () {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink water',
          intervalMinutes: 30,
        );
        expect(reminder.enabled, true);
      });
    });

    group('copyWith', () {
      test('preserves id (not copyable)', () {
        const original = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink',
          intervalMinutes: 30,
        );
        final modified = original.copyWith(name: 'Tea');
        expect(modified.id, 'r-1');
        expect(modified.name, 'Tea');
      });

      test('copies individual fields', () {
        const original = CustomReminder(
          id: 'r-1',
          name: 'Water',
          message: 'Drink',
          intervalMinutes: 30,
        );
        final modified = original.copyWith(
          message: 'Hydrate',
          intervalMinutes: 45,
          enabled: false,
        );
        expect(modified.message, 'Hydrate');
        expect(modified.intervalMinutes, 45);
        expect(modified.enabled, false);
        expect(modified.name, 'Water');
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const reminder = CustomReminder(
          id: 'r-1',
          name: 'Stretch',
          message: 'Stand and stretch',
          intervalMinutes: 60,
          enabled: false,
        );
        final json = reminder.toJson();
        expect(json['id'], 'r-1');
        expect(json['name'], 'Stretch');
        expect(json['message'], 'Stand and stretch');
        expect(json['intervalMinutes'], 60);
        expect(json['enabled'], false);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final reminder = CustomReminder.fromJson({
          'id': 'r-2',
          'name': 'Walk',
          'message': 'Take a walk',
          'intervalMinutes': 90,
          'enabled': false,
        });
        expect(reminder.id, 'r-2');
        expect(reminder.name, 'Walk');
        expect(reminder.message, 'Take a walk');
        expect(reminder.intervalMinutes, 90);
        expect(reminder.enabled, false);
      });

      test('defaults enabled to true when missing', () {
        final reminder = CustomReminder.fromJson({
          'id': 'r-3',
          'name': 'Test',
          'message': 'Test message',
          'intervalMinutes': 10,
        });
        expect(reminder.enabled, true);
      });
    });

    group('JSON round-trip', () {
      test('data survives round-trip', () {
        const original = CustomReminder(
          id: 'r-5',
          name: 'Eye Exercise',
          message: 'Do eye exercises',
          intervalMinutes: 45,
          enabled: false,
        );
        final restored = CustomReminder.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.message, original.message);
        expect(restored.intervalMinutes, original.intervalMinutes);
        expect(restored.enabled, original.enabled);
      });
    });
  });

  group('ScheduledBreak', () {
    group('constructor', () {
      test('defaults to 15 min on weekdays', () {
        const sb = ScheduledBreak(
          id: 'sb-1',
          name: 'Lunch',
          hour: 12,
          minute: 0,
        );
        expect(sb.durationMinutes, 15);
        expect(sb.activeDays, [1, 2, 3, 4, 5]);
        expect(sb.enabled, true);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const sb = ScheduledBreak(
          id: 'sb-1',
          name: 'Lunch',
          hour: 12,
          minute: 30,
          durationMinutes: 60,
          activeDays: [1, 3, 5],
          enabled: false,
        );
        final json = sb.toJson();
        expect(json['id'], 'sb-1');
        expect(json['name'], 'Lunch');
        expect(json['hour'], 12);
        expect(json['minute'], 30);
        expect(json['durationMinutes'], 60);
        expect(json['activeDays'], [1, 3, 5]);
        expect(json['enabled'], false);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final sb = ScheduledBreak.fromJson({
          'id': 'sb-2',
          'name': 'Tea',
          'hour': 15,
          'minute': 0,
          'durationMinutes': 10,
          'activeDays': [1, 2, 3, 4, 5, 6, 7],
          'enabled': true,
        });
        expect(sb.id, 'sb-2');
        expect(sb.name, 'Tea');
        expect(sb.hour, 15);
        expect(sb.minute, 0);
        expect(sb.durationMinutes, 10);
        expect(sb.activeDays, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('uses defaults for missing optional fields', () {
        final sb = ScheduledBreak.fromJson({
          'id': 'sb-3',
          'name': 'Test',
          'hour': 10,
          'minute': 0,
        });
        expect(sb.durationMinutes, 15);
        expect(sb.activeDays, [1, 2, 3, 4, 5]);
        expect(sb.enabled, true);
      });
    });

    group('JSON round-trip', () {
      test('data survives round-trip', () {
        const original = ScheduledBreak(
          id: 'sb-10',
          name: 'Afternoon',
          hour: 14,
          minute: 45,
          durationMinutes: 20,
          activeDays: [2, 4],
          enabled: false,
        );
        final restored = ScheduledBreak.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.hour, original.hour);
        expect(restored.minute, original.minute);
        expect(restored.durationMinutes, original.durationMinutes);
        expect(restored.activeDays, original.activeDays);
        expect(restored.enabled, original.enabled);
      });
    });
  });
}
