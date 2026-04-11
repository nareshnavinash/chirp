import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/smart_pause_service.dart';

void main() {
  late SmartPauseService service;

  setUp(() {
    service = SmartPauseService();
  });

  tearDown(() {
    service.dispose();
  });

  group('SmartPauseService', () {
    group('initial state', () {
      test('starts not paused', () {
        expect(service.isPaused, false);
      });

      test('starts with no reason', () {
        expect(service.currentReason, isNull);
      });
    });

    group('configure', () {
      test('accepts config without error', () {
        service.configure(const SmartPauseConfig(
          detectMeetings: true,
          detectFullscreen: false,
          detectVideoPlayers: true,
          focusApps: ['Xcode', 'IntelliJ'],
          postActivityDelayMinutes: 5,
        ));
      });
    });

    group('start/stop', () {
      test('start and stop do not throw', () {
        service.start();
        service.stop();
      });

      test('double stop is safe', () {
        service.start();
        service.stop();
        service.stop();
      });
    });

    group('callback', () {
      test('onPauseChanged can be set', () {
        service.onPauseChanged = (shouldPause, reason) {};
      });
    });

    group('dispose', () {
      test('dispose after start is safe', () {
        service.start();
        service.dispose();
      });
    });
  });

  group('SmartPauseConfig', () {
    test('defaults', () {
      const config = SmartPauseConfig();
      expect(config.detectMeetings, true);
      expect(config.detectFullscreen, true);
      expect(config.detectVideoPlayers, true);
      expect(config.focusApps, isEmpty);
      expect(config.postActivityDelayMinutes, 2);
    });

    test('custom values', () {
      const config = SmartPauseConfig(
        detectMeetings: false,
        detectFullscreen: false,
        detectVideoPlayers: false,
        focusApps: ['Xcode'],
        postActivityDelayMinutes: 10,
      );
      expect(config.detectMeetings, false);
      expect(config.focusApps, ['Xcode']);
      expect(config.postActivityDelayMinutes, 10);
    });
  });
}
