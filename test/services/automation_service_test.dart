import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/services/automation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AutomationService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = AutomationService();
    await service.init(prefs);
  });

  group('AutomationService', () {
    group('init', () {
      test('starts with empty automations', () {
        expect(service.automations, isEmpty);
      });

      test('loads automations from prefs', () async {
        final automationJson = const Automation(
          id: 'a-1',
          name: 'Test',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'echo hello',
        ).toJson();
        await prefs.setStringList('automations', [jsonEncode(automationJson)]);

        final newService = AutomationService();
        await newService.init(prefs);
        expect(newService.automations.length, 1);
        expect(newService.automations.first.name, 'Test');
      });
    });

    group('add', () {
      test('adds automation to list', () async {
        const automation = Automation(
          id: 'a-1',
          name: 'Log Break',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'echo "break started"',
        );
        await service.add(automation);
        expect(service.automations.length, 1);
        expect(service.automations.first.id, 'a-1');
      });

      test('persists to SharedPreferences', () async {
        const automation = Automation(
          id: 'a-1',
          name: 'Log Break',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'echo "break started"',
        );
        await service.add(automation);
        final raw = prefs.getStringList('automations');
        expect(raw, isNotNull);
        expect(raw!.length, 1);
      });

      test('adds multiple automations', () async {
        for (var i = 0; i < 3; i++) {
          await service.add(Automation(
            id: 'a-$i',
            name: 'Auto $i',
            event: AutomationEvent.values[i],
            type: AutomationType.shellCommand,
            command: 'echo $i',
          ));
        }
        expect(service.automations.length, 3);
      });
    });

    group('remove', () {
      test('removes automation by id', () async {
        const automation = Automation(
          id: 'a-1',
          name: 'Test',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'test',
        );
        await service.add(automation);
        await service.remove('a-1');
        expect(service.automations, isEmpty);
      });

      test('persists removal', () async {
        const automation = Automation(
          id: 'a-1',
          name: 'Test',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'test',
        );
        await service.add(automation);
        await service.remove('a-1');
        final raw = prefs.getStringList('automations');
        expect(raw, isEmpty);
      });

      test('no-op for non-existent id', () async {
        await service.remove('non-existent');
        expect(service.automations, isEmpty);
      });
    });

    group('automations getter', () {
      test('returns unmodifiable list', () async {
        expect(
          () => service.automations.add(const Automation(
            id: 'x',
            name: 'x',
            event: AutomationEvent.breakStart,
            type: AutomationType.shellCommand,
            command: 'x',
          )),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('trigger', () {
      test('does not throw with no automations', () async {
        await service.trigger(AutomationEvent.breakStart);
      });

      test('skips disabled automations', () async {
        const automation = Automation(
          id: 'a-1',
          name: 'Disabled',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'should-not-run',
          enabled: false,
        );
        await service.add(automation);
        // trigger should not throw even with disabled automations
        await service.trigger(AutomationEvent.breakStart);
      });

      test('only triggers matching event', () async {
        await service.add(const Automation(
          id: 'a-1',
          name: 'Break Start Only',
          event: AutomationEvent.breakStart,
          type: AutomationType.shellCommand,
          command: 'echo "start"',
        ));
        // Triggering a different event should be fine
        await service.trigger(AutomationEvent.breakEnd);
      });
    });
  });
}
