import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blink/features/settings/settings_model.dart';
import 'package:blink/services/stats_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncConfig {
  final String? serverUrl;
  final String? authToken;
  final bool enabled;
  final bool autoSync;

  const SyncConfig({
    this.serverUrl,
    this.authToken,
    this.enabled = false,
    this.autoSync = false,
  });

  bool get isConfigured => serverUrl != null && authToken != null;
}

/// Full exportable data bundle — settings + stats + custom reminders
class SyncBundle {
  final SettingsModel settings;
  final List<DailyStats> stats;
  final String deviceId;
  final String platform;
  final DateTime syncedAt;

  SyncBundle({
    required this.settings,
    required this.stats,
    required this.deviceId,
    required this.platform,
    DateTime? syncedAt,
  }) : syncedAt = syncedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'version': 1,
    'deviceId': deviceId,
    'platform': platform,
    'syncedAt': syncedAt.toIso8601String(),
    'settings': settings.toJson(),
    'stats': stats.map((s) => s.toJson()).toList(),
  };

  factory SyncBundle.fromJson(Map<String, dynamic> json) {
    return SyncBundle(
      deviceId: json['deviceId'] as String? ?? 'unknown',
      platform: json['platform'] as String? ?? 'unknown',
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : DateTime.now(),
      settings: SettingsModel.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
      stats: (json['stats'] as List<dynamic>?)
          ?.map((s) => DailyStats.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

class SyncService {
  late final SharedPreferences _prefs;
  SyncConfig _config = const SyncConfig();
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncAt;
  String? _lastError;

  SyncStatus get status => _status;
  DateTime? get lastSyncAt => _lastSyncAt;
  String? get lastError => _lastError;
  SyncConfig get config => _config;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _config = SyncConfig(
      serverUrl: _prefs.getString('sync_server_url'),
      authToken: _prefs.getString('sync_auth_token'),
      enabled: _prefs.getBool('sync_enabled') ?? false,
      autoSync: _prefs.getBool('sync_auto') ?? false,
    );
    final lastSync = _prefs.getString('sync_last_at');
    if (lastSync != null) {
      _lastSyncAt = DateTime.tryParse(lastSync);
    }
  }

  Future<void> configure(SyncConfig config) async {
    _config = config;
    await _prefs.setString('sync_server_url', config.serverUrl ?? '');
    await _prefs.setString('sync_auth_token', config.authToken ?? '');
    await _prefs.setBool('sync_enabled', config.enabled);
    await _prefs.setBool('sync_auto', config.autoSync);
  }

  /// Create an export bundle from current local data
  SyncBundle createExportBundle({
    required SettingsModel settings,
    required StatsService statsService,
  }) {
    return SyncBundle(
      settings: settings,
      stats: statsService.getWeek(),
      deviceId: _getDeviceId(),
      platform: Platform.operatingSystem,
    );
  }

  /// Export settings + stats as a JSON string
  String exportToJson({
    required SettingsModel settings,
    required StatsService statsService,
  }) {
    final bundle = createExportBundle(
      settings: settings,
      statsService: statsService,
    );
    return bundle.toJsonString();
  }

  /// Import settings from a JSON string, returns the parsed bundle
  SyncBundle? importFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return SyncBundle.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Push local data to cloud (last-write-wins)
  Future<bool> pushToCloud({
    required SettingsModel settings,
    required StatsService statsService,
  }) async {
    if (!_config.isConfigured) return false;

    _status = SyncStatus.syncing;
    _lastError = null;

    try {
      final bundle = createExportBundle(
        settings: settings,
        statsService: statsService,
      );

      final client = HttpClient();
      final uri = Uri.parse('${_config.serverUrl}/api/sync');
      final request = await client.putUrl(uri);
      request.headers.set('Authorization', 'Bearer ${_config.authToken}');
      request.headers.contentType = ContentType.json;
      request.write(bundle.toJsonString());
      final response = await request.close();
      client.close();

      if (response.statusCode == 200) {
        _status = SyncStatus.success;
        _lastSyncAt = DateTime.now();
        await _prefs.setString('sync_last_at', _lastSyncAt!.toIso8601String());
        return true;
      } else {
        _status = SyncStatus.error;
        _lastError = 'Server returned ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      return false;
    }
  }

  /// Pull data from cloud
  Future<SyncBundle?> pullFromCloud() async {
    if (!_config.isConfigured) return null;

    _status = SyncStatus.syncing;
    _lastError = null;

    try {
      final client = HttpClient();
      final uri = Uri.parse('${_config.serverUrl}/api/sync');
      final request = await client.getUrl(uri);
      request.headers.set('Authorization', 'Bearer ${_config.authToken}');
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      client.close();

      if (response.statusCode == 200) {
        _status = SyncStatus.success;
        _lastSyncAt = DateTime.now();
        await _prefs.setString('sync_last_at', _lastSyncAt!.toIso8601String());
        return SyncBundle.fromJson(
          jsonDecode(body) as Map<String, dynamic>,
        );
      } else {
        _status = SyncStatus.error;
        _lastError = 'Server returned ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      return null;
    }
  }

  String _getDeviceId() {
    var id = _prefs.getString('device_id');
    if (id == null) {
      id = '${Platform.operatingSystem}-${DateTime.now().millisecondsSinceEpoch}';
      _prefs.setString('device_id', id);
    }
    return id;
  }

  void dispose() {}
}
