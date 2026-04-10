import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blink/features/settings/settings_model.dart';
import 'package:blink/services/storage_service.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Settings notifier using modern Riverpod API
class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.loadSettings();
  }

  Future<void> update(SettingsModel Function(SettingsModel) updater) async {
    state = updater(state);
    final storage = ref.read(storageServiceProvider);
    await storage.saveSettings(state);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsModel>(SettingsNotifier.new);

// App state
enum AppStatus { running, paused }

class AppStatusNotifier extends Notifier<AppStatus> {
  @override
  AppStatus build() => AppStatus.running;

  void toggle() {
    state = state == AppStatus.running ? AppStatus.paused : AppStatus.running;
  }

  void set(AppStatus status) {
    state = status;
  }
}

final appStatusProvider =
    NotifierProvider<AppStatusNotifier, AppStatus>(AppStatusNotifier.new);
