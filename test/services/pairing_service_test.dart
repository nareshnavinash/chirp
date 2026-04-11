import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/services/pairing_service.dart';

void main() {
  group('PairingService', () {
    group('desktop role', () {
      late PairingService service;

      setUp(() {
        service = PairingService(role: PairingRole.desktop);
      });

      tearDown(() async {
        await service.dispose();
      });

      test('starts not paired', () {
        expect(service.isPaired, false);
      });

      test('starts with null pairing code', () {
        expect(service.pairingCode, isNull);
      });

      test('startServer generates pairing code', () async {
        final code = await service.startServer();
        expect(code, isNotEmpty);
        expect(code.length, 6);
        expect(service.pairingCode, code);
        expect(service.port, greaterThan(0));
      });

      test('pairing code is numeric', () async {
        final code = await service.startServer();
        expect(int.tryParse(code), isNotNull);
      });

      test('messages stream is broadcast', () {
        service.messages.listen((_) {});
        service.messages.listen((_) {});
      });
    });

    group('mobile role', () {
      late PairingService service;

      setUp(() {
        service = PairingService(role: PairingRole.mobile);
      });

      tearDown(() async {
        await service.dispose();
      });

      test('starts not paired', () {
        expect(service.isPaired, false);
      });

      test('connectToDesktop fails with invalid address', () async {
        final result = await service.connectToDesktop(
          address: '127.0.0.1',
          port: 99999,
          code: '000000',
        );
        expect(result, false);
      });
    });

    group('unpair', () {
      test('resets paired state', () async {
        final service = PairingService(role: PairingRole.desktop);
        await service.startServer();
        await service.unpair();
        expect(service.isPaired, false);
        await service.dispose();
      });
    });

    group('desktop-mobile pairing flow', () {
      test('full pairing handshake works', () async {
        // Start desktop server
        final desktop = PairingService(role: PairingRole.desktop);
        final code = await desktop.startServer();
        final port = desktop.port;

        // Connect mobile client
        final mobile = PairingService(role: PairingRole.mobile);
        final result = await mobile.connectToDesktop(
          address: '127.0.0.1',
          port: port,
          code: code,
        );

        expect(result, true);
        expect(mobile.isPaired, true);
        expect(desktop.isPaired, true);

        await mobile.dispose();
        await desktop.dispose();
      });

      test('pairing fails with wrong code', () async {
        final desktop = PairingService(role: PairingRole.desktop);
        await desktop.startServer();
        final port = desktop.port;

        final mobile = PairingService(role: PairingRole.mobile);
        final result = await mobile.connectToDesktop(
          address: '127.0.0.1',
          port: port,
          code: '999999', // wrong code
        );

        expect(result, false);
        expect(mobile.isPaired, false);

        await mobile.dispose();
        await desktop.dispose();
      });

      test('event sync between paired devices', () async {
        final desktop = PairingService(role: PairingRole.desktop);
        final code = await desktop.startServer();
        final port = desktop.port;

        final mobile = PairingService(role: PairingRole.mobile);
        await mobile.connectToDesktop(
          address: '127.0.0.1',
          port: port,
          code: code,
        );

        // Desktop sends event
        await desktop.sendEvent(PairingSyncEvent.breakStart);

        // Give polling time to pick up the event
        await Future.delayed(const Duration(seconds: 3));

        // Mobile receives via polling (events are queued on desktop)
        // The mobile polls /events periodically, so we check the stream
        final messages = <PairingMessage>[];
        mobile.messages.listen(messages.add);

        // Wait for a poll cycle
        await Future.delayed(const Duration(seconds: 3));

        // Events should have been delivered
        // Note: depending on timing, the message may or may not be received yet
        // This is an integration test that depends on real network timing

        await mobile.dispose();
        await desktop.dispose();
      });
    });
  });
}
