import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/sync_service.dart';
import 'package:chirp/features/settings/settings_model.dart';
import 'package:chirp/services/stats_service.dart';

void main() {
  group('SyncConfig', () {
    test('isConfigured returns false when serverUrl is null', () {
      const config = SyncConfig(authToken: 'token');
      expect(config.isConfigured, false);
    });

    test('isConfigured returns false when authToken is null', () {
      const config = SyncConfig(serverUrl: 'https://example.com');
      expect(config.isConfigured, false);
    });

    test('isConfigured returns true when both set', () {
      const config = SyncConfig(
        serverUrl: 'https://example.com',
        authToken: 'token',
      );
      expect(config.isConfigured, true);
    });

    test('defaults to disabled', () {
      const config = SyncConfig();
      expect(config.enabled, false);
      expect(config.autoSync, false);
    });
  });

  group('SyncBundle', () {
    late SyncBundle bundle;

    setUp(() {
      bundle = SyncBundle(
        settings: const SettingsModel(workMinutes: 25),
        stats: [
          DailyStats(date: '2024-01-15', breaksTaken: 5),
          DailyStats(date: '2024-01-16', breaksTaken: 8),
        ],
        deviceId: 'test-device-123',
        platform: 'macos',
        syncedAt: DateTime(2024, 1, 16, 10, 30),
      );
    });

    group('toJson', () {
      test('includes version field', () {
        final json = bundle.toJson();
        expect(json['version'], 1);
      });

      test('includes device metadata', () {
        final json = bundle.toJson();
        expect(json['deviceId'], 'test-device-123');
        expect(json['platform'], 'macos');
      });

      test('includes settings', () {
        final json = bundle.toJson();
        expect(json['settings'], isA<Map<String, dynamic>>());
        expect(json['settings']['workMinutes'], 25);
      });

      test('includes stats as list', () {
        final json = bundle.toJson();
        expect(json['stats'], isA<List>());
        expect((json['stats'] as List).length, 2);
      });

      test('includes syncedAt as ISO 8601', () {
        final json = bundle.toJson();
        expect(json['syncedAt'], '2024-01-16T10:30:00.000');
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = bundle.toJson();
        final restored = SyncBundle.fromJson(json);
        expect(restored.deviceId, 'test-device-123');
        expect(restored.platform, 'macos');
        expect(restored.settings.workMinutes, 25);
        expect(restored.stats.length, 2);
        expect(restored.stats[0].breaksTaken, 5);
      });

      test('uses defaults for missing fields', () {
        final restored = SyncBundle.fromJson({});
        expect(restored.deviceId, 'unknown');
        expect(restored.platform, 'unknown');
        expect(restored.stats, isEmpty);
      });
    });

    group('toJsonString', () {
      test('produces valid JSON string', () {
        final jsonStr = bundle.toJsonString();
        expect(() => jsonDecode(jsonStr), returnsNormally);
      });

      test('is pretty-printed', () {
        final jsonStr = bundle.toJsonString();
        expect(jsonStr.contains('\n'), true);
      });
    });

    group('JSON round-trip', () {
      test('data survives round-trip via string', () {
        final jsonStr = bundle.toJsonString();
        final restored = SyncBundle.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );
        expect(restored.deviceId, bundle.deviceId);
        expect(restored.platform, bundle.platform);
        expect(restored.settings.workMinutes, bundle.settings.workMinutes);
        expect(restored.stats.length, bundle.stats.length);
      });
    });
  });
}
