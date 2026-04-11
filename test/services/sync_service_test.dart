import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/services/sync_service.dart';
import 'package:chirp/services/stats_service.dart';
import 'package:chirp/features/settings/settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SyncService service;
  late SharedPreferences prefs;
  late StatsService statsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SyncService();
    await service.init(prefs);
    statsService = StatsService();
    await statsService.init(prefs);
  });

  group('SyncService', () {
    group('init', () {
      test('starts with idle status', () {
        expect(service.status, SyncStatus.idle);
      });

      test('starts with no last sync', () {
        expect(service.lastSyncAt, isNull);
      });

      test('starts with no error', () {
        expect(service.lastError, isNull);
      });

      test('loads config from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'sync_server_url': 'https://sync.example.com',
          'sync_auth_token': 'my-token',
          'sync_enabled': true,
          'sync_auto': true,
        });
        prefs = await SharedPreferences.getInstance();
        final svc = SyncService();
        await svc.init(prefs);
        expect(svc.config.serverUrl, 'https://sync.example.com');
        expect(svc.config.authToken, 'my-token');
        expect(svc.config.enabled, true);
        expect(svc.config.autoSync, true);
      });

      test('loads last sync timestamp from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'sync_last_at': '2024-01-15T10:00:00.000',
        });
        prefs = await SharedPreferences.getInstance();
        final svc = SyncService();
        await svc.init(prefs);
        expect(svc.lastSyncAt, DateTime(2024, 1, 15, 10, 0));
      });
    });

    group('configure', () {
      test('updates config', () async {
        const config = SyncConfig(
          serverUrl: 'https://new.example.com',
          authToken: 'new-token',
          enabled: true,
          autoSync: true,
        );
        await service.configure(config);
        expect(service.config.serverUrl, 'https://new.example.com');
        expect(service.config.authToken, 'new-token');
      });

      test('persists config to prefs', () async {
        const config = SyncConfig(
          serverUrl: 'https://new.example.com',
          authToken: 'new-token',
          enabled: true,
          autoSync: false,
        );
        await service.configure(config);
        expect(prefs.getString('sync_server_url'), 'https://new.example.com');
        expect(prefs.getString('sync_auth_token'), 'new-token');
        expect(prefs.getBool('sync_enabled'), true);
        expect(prefs.getBool('sync_auto'), false);
      });
    });

    group('createExportBundle', () {
      test('creates bundle with settings and stats', () {
        final bundle = service.createExportBundle(
          settings: const SettingsModel(workMinutes: 25),
          statsService: statsService,
        );
        expect(bundle.settings.workMinutes, 25);
        expect(bundle.stats, isNotNull);
        expect(bundle.platform, isNotEmpty);
        expect(bundle.deviceId, isNotEmpty);
      });

      test('generates device ID and persists it', () {
        final bundle1 = service.createExportBundle(
          settings: const SettingsModel(),
          statsService: statsService,
        );
        final bundle2 = service.createExportBundle(
          settings: const SettingsModel(),
          statsService: statsService,
        );
        // Same device ID across calls
        expect(bundle1.deviceId, bundle2.deviceId);
      });
    });

    group('exportToJson / importFromJson', () {
      test('exportToJson returns valid JSON string', () {
        final json = service.exportToJson(
          settings: const SettingsModel(workMinutes: 30),
          statsService: statsService,
        );
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('importFromJson parses valid JSON', () {
        final json = service.exportToJson(
          settings: const SettingsModel(workMinutes: 30),
          statsService: statsService,
        );
        final bundle = service.importFromJson(json);
        expect(bundle, isNotNull);
        expect(bundle!.settings.workMinutes, 30);
      });

      test('importFromJson returns null for invalid JSON', () {
        final bundle = service.importFromJson('not valid json');
        expect(bundle, isNull);
      });

      test('importFromJson returns null for empty string', () {
        final bundle = service.importFromJson('');
        expect(bundle, isNull);
      });

      test('round-trip preserves settings', () {
        const original = SettingsModel(
          workMinutes: 45,
          breakSeconds: 30,
          breaksEnabled: false,
          activeDays: [1, 3, 5],
        );
        final json = service.exportToJson(
          settings: original,
          statsService: statsService,
        );
        final bundle = service.importFromJson(json)!;
        expect(bundle.settings.workMinutes, 45);
        expect(bundle.settings.breakSeconds, 30);
        expect(bundle.settings.breaksEnabled, false);
        expect(bundle.settings.activeDays, [1, 3, 5]);
      });
    });

    group('pushToCloud', () {
      test('returns false when not configured', () async {
        final result = await service.pushToCloud(
          settings: const SettingsModel(),
          statsService: statsService,
        );
        expect(result, false);
      });
    });

    group('pullFromCloud', () {
      test('returns null when not configured', () async {
        final result = await service.pullFromCloud();
        expect(result, isNull);
      });
    });
  });
}
