import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/core/providers.dart';
import 'package:chirp/services/timer_service.dart';
import 'package:chirp/services/pomodoro_service.dart';
import 'package:chirp/services/reminder_service.dart';
import 'package:chirp/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Service providers', () {
    test('timerServiceProvider creates TimerService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(timerServiceProvider);
      expect(service, isA<TimerService>());
    });

    test('pomodoroServiceProvider creates PomodoroService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(pomodoroServiceProvider);
      expect(service, isA<PomodoroService>());
    });

    test('reminderServiceProvider creates ReminderService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(reminderServiceProvider);
      expect(service, isA<ReminderService>());
    });

    test('storageServiceProvider creates StorageService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final service = container.read(storageServiceProvider);
      expect(service, isA<StorageService>());
    });
  });

  group('AppStatusNotifier', () {
    test('initial state is running', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(appStatusProvider), AppStatus.running);
    });

    test('toggle switches to paused', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStatusProvider.notifier).toggle();
      expect(container.read(appStatusProvider), AppStatus.paused);
    });

    test('toggle twice returns to running', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStatusProvider.notifier).toggle();
      container.read(appStatusProvider.notifier).toggle();
      expect(container.read(appStatusProvider), AppStatus.running);
    });

    test('set to paused', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStatusProvider.notifier).set(AppStatus.paused);
      expect(container.read(appStatusProvider), AppStatus.paused);
    });

    test('set to running', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStatusProvider.notifier).set(AppStatus.paused);
      container.read(appStatusProvider.notifier).set(AppStatus.running);
      expect(container.read(appStatusProvider), AppStatus.running);
    });
  });

  group('timerStatusProvider', () {
    test('is a StreamProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final value = container.read(timerStatusProvider);
      // Initially loading (no events emitted yet)
      expect(value, isA<AsyncValue<TimerStatus>>());
    });
  });

  group('pomodoroStatusProvider', () {
    test('is a StreamProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final value = container.read(pomodoroStatusProvider);
      expect(value, isA<AsyncValue<PomodoroStatus>>());
    });
  });
}
