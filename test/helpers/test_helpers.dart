import 'package:shared_preferences/shared_preferences.dart';

/// Initialize SharedPreferences with mock values for testing.
Future<SharedPreferences> setupMockPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}
