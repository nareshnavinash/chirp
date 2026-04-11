import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chirp/services/team_service.dart';
import 'package:chirp/features/settings/settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TeamService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = TeamService();
    await service.init(prefs);
  });

  group('TeamService', () {
    group('init', () {
      test('starts not in team', () {
        expect(service.isInTeam, false);
      });

      test('starts not admin', () {
        expect(service.isAdmin, false);
      });

      test('starts with null teamId', () {
        expect(service.teamId, isNull);
      });

      test('loads team state from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'team_server_url': 'https://team.example.com',
          'team_auth_token': 'team-token',
          'team_id': 'team-123',
          'team_is_admin': true,
        });
        prefs = await SharedPreferences.getInstance();
        final svc = TeamService();
        await svc.init(prefs);
        expect(svc.isInTeam, true);
        expect(svc.isAdmin, true);
        expect(svc.teamId, 'team-123');
      });
    });

    group('configure', () {
      test('persists server config', () async {
        await service.configure(
          serverUrl: 'https://team.example.com',
          authToken: 'my-token',
        );
        expect(prefs.getString('team_server_url'), 'https://team.example.com');
        expect(prefs.getString('team_auth_token'), 'my-token');
      });
    });

    group('joinTeam', () {
      test('returns false without server config', () async {
        final result = await service.joinTeam('TEAM-CODE');
        expect(result, false);
      });
    });

    group('leaveTeam', () {
      test('no-op when not in team', () async {
        await service.leaveTeam();
        expect(service.isInTeam, false);
      });
    });

    group('getLicense', () {
      test('returns null when not in team', () async {
        final license = await service.getLicense();
        expect(license, isNull);
      });
    });

    group('getMembers', () {
      test('returns empty when not in team', () async {
        final members = await service.getMembers();
        expect(members, isEmpty);
      });
    });

    group('getTeamStats', () {
      test('returns null when not in team', () async {
        final stats = await service.getTeamStats();
        expect(stats, isNull);
      });
    });

    group('pushTeamSettings', () {
      test('returns false when not admin', () async {
        final result = await service.pushTeamSettings(const SettingsModel());
        expect(result, false);
      });
    });

    group('reportStatus', () {
      test('no-op when not in team', () async {
        await service.reportStatus(healthScore: 85, breaksTakenToday: 5);
        // Should not throw
      });
    });
  });
}
