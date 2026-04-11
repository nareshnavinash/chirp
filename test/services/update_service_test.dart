import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/update_service.dart';

void main() {
  group('UpdateService', () {
    group('isNewer (semver comparison)', () {
      test('newer major version', () {
        expect(UpdateService.isNewer('2.0.0', '1.0.0'), true);
      });

      test('newer minor version', () {
        expect(UpdateService.isNewer('1.1.0', '1.0.0'), true);
      });

      test('newer patch version', () {
        expect(UpdateService.isNewer('1.0.1', '1.0.0'), true);
      });

      test('same version is not newer', () {
        expect(UpdateService.isNewer('1.0.0', '1.0.0'), false);
      });

      test('older major version', () {
        expect(UpdateService.isNewer('1.0.0', '2.0.0'), false);
      });

      test('older minor version', () {
        expect(UpdateService.isNewer('1.0.0', '1.1.0'), false);
      });

      test('older patch version', () {
        expect(UpdateService.isNewer('1.0.0', '1.0.1'), false);
      });

      test('major beats minor', () {
        expect(UpdateService.isNewer('2.0.0', '1.9.9'), true);
      });

      test('minor beats patch', () {
        expect(UpdateService.isNewer('1.2.0', '1.1.9'), true);
      });

      test('handles short version strings', () {
        expect(UpdateService.isNewer('2.0', '1.0'), true);
      });

      test('handles single-component versions', () {
        expect(UpdateService.isNewer('2', '1'), true);
      });

      test('zero versions', () {
        expect(UpdateService.isNewer('0.0.1', '0.0.0'), true);
        expect(UpdateService.isNewer('0.1.0', '0.0.9'), true);
      });

      test('real-world version: 0.2.0 > 0.1.0', () {
        expect(UpdateService.isNewer('0.2.0', '0.1.0'), true);
      });

      test('real-world version: 0.1.0 is not newer than 0.1.0', () {
        expect(UpdateService.isNewer('0.1.0', '0.1.0'), false);
      });
    });

    group('checkForUpdate', () {
      test('handles network failure gracefully', () async {
        final service = UpdateService();
        final update = await service.checkForUpdate();
        expect(update, isNull);
      });
    });
  });

  group('AppUpdate', () {
    test('constructor defaults isRequired to false', () {
      const update = AppUpdate(
        version: '1.0.0',
        downloadUrl: 'https://example.com/download',
      );
      expect(update.isRequired, false);
    });

    test('fromJson creates AppUpdate', () {
      final update = AppUpdate.fromJson({
        'version': '2.0.0',
        'downloadUrl': 'https://example.com/2.0.0',
        'changelog': 'Major update',
        'isRequired': true,
      });
      expect(update.version, '2.0.0');
      expect(update.downloadUrl, 'https://example.com/2.0.0');
      expect(update.changelog, 'Major update');
      expect(update.isRequired, true);
    });

    test('fromJson handles null changelog', () {
      final update = AppUpdate.fromJson({
        'version': '1.0.1',
        'downloadUrl': 'https://example.com',
      });
      expect(update.changelog, isNull);
    });

    test('fromJson defaults isRequired to false', () {
      final update = AppUpdate.fromJson({
        'version': '1.1.0',
        'downloadUrl': 'https://example.com',
      });
      expect(update.isRequired, false);
    });
  });
}
