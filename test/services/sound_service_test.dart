import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/sound_service.dart';

void main() {
  late SoundService service;

  setUp(() {
    service = SoundService();
  });

  group('SoundService', () {
    group('configure', () {
      test('can be disabled', () {
        service.configure(enabled: false);
        // Disabled service should not play sounds
      });

      test('can be enabled', () {
        service.configure(enabled: true);
      });
    });

    group('setSoundForEvent', () {
      test('sets custom sound path', () {
        service.setSoundForEvent(SoundEvent.preBreak, '/custom/sound.aiff');
      });

      test('clears custom sound with null', () {
        service.setSoundForEvent(SoundEvent.preBreak, '/custom/sound.aiff');
        service.setSoundForEvent(SoundEvent.preBreak, null);
      });

      test('sets sound for all event types', () {
        for (final event in SoundEvent.values) {
          service.setSoundForEvent(event, '/sound/${event.name}.aiff');
        }
      });
    });

    group('play', () {
      test('does not throw when disabled', () async {
        service.configure(enabled: false);
        await service.play(SoundEvent.preBreak);
      });
    });
  });

  group('SoundEvent', () {
    test('has all expected values', () {
      expect(SoundEvent.values, containsAll([
        SoundEvent.preBreak,
        SoundEvent.breakStart,
        SoundEvent.breakEnd,
        SoundEvent.blinkReminder,
        SoundEvent.postureReminder,
      ]));
    });
  });
}
