import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/update_service.dart';

void main() {
  group('AppUpdate', () {
    group('constructor', () {
      test('defaults isRequired to false', () {
        const update = AppUpdate(
          version: '1.0.0',
          downloadUrl: 'https://example.com/download',
        );
        expect(update.isRequired, false);
      });

      test('accepts all fields', () {
        const update = AppUpdate(
          version: '2.0.0',
          downloadUrl: 'https://example.com/v2',
          changelog: 'New features',
          isRequired: true,
        );
        expect(update.version, '2.0.0');
        expect(update.downloadUrl, 'https://example.com/v2');
        expect(update.changelog, 'New features');
        expect(update.isRequired, true);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final update = AppUpdate.fromJson({
          'version': '1.5.0',
          'downloadUrl': 'https://example.com/1.5',
          'changelog': 'Bug fixes',
          'isRequired': true,
        });
        expect(update.version, '1.5.0');
        expect(update.downloadUrl, 'https://example.com/1.5');
        expect(update.changelog, 'Bug fixes');
        expect(update.isRequired, true);
      });

      test('defaults isRequired to false', () {
        final update = AppUpdate.fromJson({
          'version': '1.1.0',
          'downloadUrl': 'https://example.com',
        });
        expect(update.isRequired, false);
      });

      test('handles null changelog', () {
        final update = AppUpdate.fromJson({
          'version': '1.0.1',
          'downloadUrl': 'https://example.com',
        });
        expect(update.changelog, isNull);
      });
    });
  });
}
