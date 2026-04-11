import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/automation_service.dart';

void main() {
  group('Automation', () {
    group('constructor', () {
      test('defaults enabled to true', () {
        const automation = Automation(
          id: 'a-1',
          name: 'Notify Slack',
          event: AutomationEvent.breakStart,
          type: AutomationType.webhook,
          command: 'https://hooks.slack.com/test',
        );
        expect(automation.enabled, true);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const automation = Automation(
          id: 'a-1',
          name: 'Log Break',
          event: AutomationEvent.breakEnd,
          type: AutomationType.shellCommand,
          command: 'echo "break done"',
          enabled: false,
        );
        final json = automation.toJson();
        expect(json['id'], 'a-1');
        expect(json['name'], 'Log Break');
        expect(json['event'], 'breakEnd');
        expect(json['type'], 'shellCommand');
        expect(json['command'], 'echo "break done"');
        expect(json['enabled'], false);
      });

      test('serializes all event types', () {
        for (final event in AutomationEvent.values) {
          final automation = Automation(
            id: 'a-${event.name}',
            name: event.name,
            event: event,
            type: AutomationType.shellCommand,
            command: 'echo',
          );
          expect(automation.toJson()['event'], event.name);
        }
      });

      test('serializes all automation types', () {
        for (final type in AutomationType.values) {
          final automation = Automation(
            id: 'a-${type.name}',
            name: type.name,
            event: AutomationEvent.breakStart,
            type: type,
            command: 'test',
          );
          expect(automation.toJson()['type'], type.name);
        }
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final automation = Automation.fromJson({
          'id': 'a-2',
          'name': 'Send Webhook',
          'event': 'pause',
          'type': 'webhook',
          'command': 'https://example.com/hook',
          'enabled': true,
        });
        expect(automation.id, 'a-2');
        expect(automation.name, 'Send Webhook');
        expect(automation.event, AutomationEvent.pause);
        expect(automation.type, AutomationType.webhook);
        expect(automation.command, 'https://example.com/hook');
        expect(automation.enabled, true);
      });

      test('defaults enabled to true', () {
        final automation = Automation.fromJson({
          'id': 'a-3',
          'name': 'Test',
          'event': 'resume',
          'type': 'shellCommand',
          'command': 'test',
        });
        expect(automation.enabled, true);
      });

      test('parses all event types', () {
        for (final event in AutomationEvent.values) {
          final automation = Automation.fromJson({
            'id': 'test',
            'name': 'test',
            'event': event.name,
            'type': 'shellCommand',
            'command': 'test',
          });
          expect(automation.event, event);
        }
      });
    });

    group('JSON round-trip', () {
      test('data survives round-trip', () {
        const original = Automation(
          id: 'a-rt',
          name: 'Round Trip',
          event: AutomationEvent.postureReminder,
          type: AutomationType.webhook,
          command: 'https://example.com',
          enabled: false,
        );
        final restored = Automation.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.event, original.event);
        expect(restored.type, original.type);
        expect(restored.command, original.command);
        expect(restored.enabled, original.enabled);
      });
    });
  });
}
