import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/team_service.dart';

void main() {
  group('TeamMember', () {
    group('fromJson', () {
      test('deserializes required fields', () {
        final member = TeamMember.fromJson({
          'id': 'user-1',
          'name': 'Alice',
          'email': 'alice@example.com',
        });
        expect(member.id, 'user-1');
        expect(member.name, 'Alice');
        expect(member.email, 'alice@example.com');
        expect(member.role, 'member');
      });

      test('deserializes all optional fields', () {
        final member = TeamMember.fromJson({
          'id': 'user-1',
          'name': 'Alice',
          'email': 'alice@example.com',
          'role': 'admin',
          'devicePlatform': 'macos',
          'lastSeen': '2024-01-15T10:00:00.000',
          'healthScore': 85,
          'breaksTakenToday': 6,
        });
        expect(member.role, 'admin');
        expect(member.devicePlatform, 'macos');
        expect(member.lastSeen, DateTime(2024, 1, 15, 10, 0));
        expect(member.healthScore, 85);
        expect(member.breaksTakenToday, 6);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const member = TeamMember(
          id: 'user-1',
          name: 'Bob',
          email: 'bob@example.com',
          role: 'admin',
          devicePlatform: 'windows',
          healthScore: 92,
          breaksTakenToday: 10,
        );
        final json = member.toJson();
        expect(json['id'], 'user-1');
        expect(json['name'], 'Bob');
        expect(json['email'], 'bob@example.com');
        expect(json['role'], 'admin');
        expect(json['devicePlatform'], 'windows');
        expect(json['healthScore'], 92);
        expect(json['breaksTakenToday'], 10);
      });
    });

    group('JSON round-trip', () {
      test('member survives round-trip', () {
        const original = TeamMember(
          id: 'u-1',
          name: 'Test',
          email: 'test@test.com',
          role: 'admin',
          healthScore: 77,
        );
        final restored = TeamMember.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.role, original.role);
        expect(restored.healthScore, original.healthScore);
      });
    });
  });

  group('TeamStats', () {
    group('fromJson', () {
      test('deserializes all fields', () {
        final stats = TeamStats.fromJson({
          'totalMembers': 10,
          'activeToday': 8,
          'avgHealthScore': 85.5,
          'totalBreaksToday': 42,
          'avgBreakCompliance': 0.78,
        });
        expect(stats.totalMembers, 10);
        expect(stats.activeToday, 8);
        expect(stats.avgHealthScore, 85.5);
        expect(stats.totalBreaksToday, 42);
        expect(stats.avgBreakCompliance, 0.78);
      });

      test('uses defaults for missing fields', () {
        final stats = TeamStats.fromJson({});
        expect(stats.totalMembers, 0);
        expect(stats.activeToday, 0);
        expect(stats.avgHealthScore, 0);
        expect(stats.totalBreaksToday, 0);
        expect(stats.avgBreakCompliance, 0);
      });

      test('handles int as avgHealthScore', () {
        final stats = TeamStats.fromJson({'avgHealthScore': 90});
        expect(stats.avgHealthScore, 90.0);
      });
    });
  });

  group('TeamLicense', () {
    group('fromJson', () {
      test('deserializes all fields', () {
        final license = TeamLicense.fromJson({
          'teamId': 'team-1',
          'teamName': 'Engineering',
          'totalSeats': 20,
          'usedSeats': 15,
          'expiresAt': '2025-12-31T00:00:00.000',
        });
        expect(license.teamId, 'team-1');
        expect(license.teamName, 'Engineering');
        expect(license.totalSeats, 20);
        expect(license.usedSeats, 15);
        expect(license.expiresAt, DateTime(2025, 12, 31));
      });
    });

    group('isValid', () {
      test('returns true when no expiry', () {
        const license = TeamLicense(
          teamId: 't1',
          teamName: 'Test',
        );
        expect(license.isValid, true);
      });

      test('returns true when expiry is in the future', () {
        final license = TeamLicense(
          teamId: 't1',
          teamName: 'Test',
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );
        expect(license.isValid, true);
      });

      test('returns false when expired', () {
        final license = TeamLicense(
          teamId: 't1',
          teamName: 'Test',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(license.isValid, false);
      });
    });

    group('availableSeats', () {
      test('calculates available seats', () {
        const license = TeamLicense(
          teamId: 't1',
          teamName: 'Test',
          totalSeats: 10,
          usedSeats: 7,
        );
        expect(license.availableSeats, 3);
      });

      test('returns zero when full', () {
        const license = TeamLicense(
          teamId: 't1',
          teamName: 'Test',
          totalSeats: 5,
          usedSeats: 5,
        );
        expect(license.availableSeats, 0);
      });
    });
  });
}
