import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/pairing_service.dart';

void main() {
  group('PairingMessage', () {
    group('constructor', () {
      test('sets timestamp to now when not provided', () {
        final before = DateTime.now();
        final message = PairingMessage(event: PairingSyncEvent.ping);
        final after = DateTime.now();
        expect(
          message.timestamp.isAfter(before) ||
              message.timestamp.isAtSameMomentAs(before),
          true,
        );
        expect(
          message.timestamp.isBefore(after) ||
              message.timestamp.isAtSameMomentAs(after),
          true,
        );
      });

      test('accepts explicit timestamp', () {
        final ts = DateTime(2024, 6, 15, 12, 0);
        final message = PairingMessage(
          event: PairingSyncEvent.breakStart,
          timestamp: ts,
        );
        expect(message.timestamp, ts);
      });

      test('accepts data map', () {
        final message = PairingMessage(
          event: PairingSyncEvent.breakEnd,
          data: {'duration': 20},
        );
        expect(message.data?['duration'], 20);
      });
    });

    group('toJson', () {
      test('serializes event name', () {
        final message = PairingMessage(
          event: PairingSyncEvent.pause,
          timestamp: DateTime(2024, 1, 15),
        );
        final json = message.toJson();
        expect(json['event'], 'pause');
      });

      test('serializes timestamp as ISO 8601', () {
        final message = PairingMessage(
          event: PairingSyncEvent.resume,
          timestamp: DateTime(2024, 1, 15, 10, 30),
        );
        final json = message.toJson();
        expect(json['timestamp'], '2024-01-15T10:30:00.000');
      });

      test('includes data when present', () {
        final message = PairingMessage(
          event: PairingSyncEvent.breakStart,
          data: {'type': 'long'},
          timestamp: DateTime(2024, 1, 15),
        );
        final json = message.toJson();
        expect(json['data'], {'type': 'long'});
      });

      test('includes null data when absent', () {
        final message = PairingMessage(
          event: PairingSyncEvent.ping,
          timestamp: DateTime(2024, 1, 15),
        );
        final json = message.toJson();
        expect(json['data'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all event types', () {
        for (final event in PairingSyncEvent.values) {
          final message = PairingMessage.fromJson({
            'event': event.name,
            'timestamp': '2024-01-15T10:00:00.000',
          });
          expect(message.event, event);
        }
      });

      test('deserializes timestamp', () {
        final message = PairingMessage.fromJson({
          'event': 'ping',
          'timestamp': '2024-06-15T14:30:00.000',
        });
        expect(message.timestamp, DateTime(2024, 6, 15, 14, 30));
      });

      test('deserializes data map', () {
        final message = PairingMessage.fromJson({
          'event': 'breakStart',
          'timestamp': '2024-01-15T10:00:00.000',
          'data': {'breakType': 'short'},
        });
        expect(message.data?['breakType'], 'short');
      });
    });

    group('JSON round-trip', () {
      test('all event types survive round-trip', () {
        for (final event in PairingSyncEvent.values) {
          final original = PairingMessage(
            event: event,
            data: {'test': true},
            timestamp: DateTime(2024, 3, 10, 8, 0),
          );
          final restored = PairingMessage.fromJson(original.toJson());
          expect(restored.event, original.event);
          expect(restored.data, original.data);
          expect(restored.timestamp, original.timestamp);
        }
      });
    });
  });
}
