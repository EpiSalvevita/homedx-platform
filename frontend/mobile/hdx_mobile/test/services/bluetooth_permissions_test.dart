import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothAdapterState;
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/services/bluetooth_service_mobile.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  final service = AppBluetoothService();

  Future<void> run({
    required bool ios,
    required Map<Permission, PermissionStatus> answers,
    required List<Permission> asked,
  }) {
    return service.ensurePlatformPermissions(
      isAndroid: !ios,
      isIOS: ios,
      request: (p) async {
        asked.add(p);
        return answers[p] ?? PermissionStatus.denied;
      },
    );
  }

  group('iOS', () {
    test('bluetooth granted -> ok, location never requested', () async {
      final asked = <Permission>[];
      await run(ios: true, answers: {Permission.bluetooth: PermissionStatus.granted}, asked: asked);
      expect(asked, [Permission.bluetooth]);
    });

    for (final s in [
      PermissionStatus.denied,
      PermissionStatus.permanentlyDenied,
      PermissionStatus.restricted,
      PermissionStatus.limited,
      PermissionStatus.provisional,
    ]) {
      test('bluetooth $s -> throws, location never requested', () async {
        final asked = <Permission>[];
        await expectLater(
          run(ios: true, answers: {Permission.bluetooth: s}, asked: asked),
          throwsA(isA<Exception>()),
        );
        expect(asked, [Permission.bluetooth]);
      });
    }
  });

  group('Android (unchanged)', () {
    final granted = {
      Permission.bluetoothScan: PermissionStatus.granted,
      Permission.bluetoothConnect: PermissionStatus.granted,
      Permission.locationWhenInUse: PermissionStatus.granted,
    };

    test('requests scan, connect, then location; never Permission.bluetooth', () async {
      final asked = <Permission>[];
      await run(ios: false, answers: granted, asked: asked);
      expect(asked, [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.locationWhenInUse]);
    });

    test('scan denied -> throws before location', () async {
      final asked = <Permission>[];
      await expectLater(
        run(ios: false, answers: {...granted, Permission.bluetoothScan: PermissionStatus.denied}, asked: asked),
        throwsA(isA<Exception>()),
      );
      expect(asked, [Permission.bluetoothScan, Permission.bluetoothConnect]);
    });

    test('location denied -> throws', () async {
      final asked = <Permission>[];
      await expectLater(
        run(ios: false, answers: {...granted, Permission.locationWhenInUse: PermissionStatus.denied}, asked: asked),
        throwsA(isA<Exception>()),
      );
      expect(asked, [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.locationWhenInUse]);
    });
  });

  group('adapter state', () {
    test('iOS: unknown then on -> ok', () async {
      await service.ensureAdapterOn(
        isIOS: true,
        states: Stream.fromIterable([BluetoothAdapterState.unknown, BluetoothAdapterState.on]),
      );
    });

    test('iOS: only unknown -> throws after timeout', () async {
      await expectLater(
        service.ensureAdapterOn(
          isIOS: true,
          states: Stream<BluetoothAdapterState>.periodic(
            const Duration(milliseconds: 5),
            (_) => BluetoothAdapterState.unknown,
          ),
          iosTimeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('iOS: off -> throws', () async {
      await expectLater(
        service.ensureAdapterOn(isIOS: true, states: Stream.value(BluetoothAdapterState.off)),
        throwsA(isA<Exception>()),
      );
    });

    test('Android: first state used (on ok, unknown throws)', () async {
      await service.ensureAdapterOn(isIOS: false, states: Stream.value(BluetoothAdapterState.on));
      await expectLater(
        service.ensureAdapterOn(isIOS: false, states: Stream.value(BluetoothAdapterState.unknown)),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('isBluetoothEnabled (provider initial state)', () {
    test('iOS: cold-launch unknown then on -> true (no "disabled" flash)', () async {
      expect(
        await service.isBluetoothEnabled(
          isIOS: true,
          states: Stream.fromIterable([BluetoothAdapterState.unknown, BluetoothAdapterState.on]),
        ),
        isTrue,
      );
    });

    test('iOS: unknown then off -> false', () async {
      expect(
        await service.isBluetoothEnabled(
          isIOS: true,
          states: Stream.fromIterable([BluetoothAdapterState.unknown, BluetoothAdapterState.off]),
        ),
        isFalse,
      );
    });

    test('iOS: only unknown -> false after timeout', () async {
      expect(
        await service.isBluetoothEnabled(
          isIOS: true,
          states: Stream<BluetoothAdapterState>.periodic(
            const Duration(milliseconds: 5),
            (_) => BluetoothAdapterState.unknown,
          ),
          iosTimeout: const Duration(milliseconds: 50),
        ),
        isFalse,
      );
    });

    test('Android (unchanged): first state used', () async {
      expect(
        await service.isBluetoothEnabled(isIOS: false, states: Stream.value(BluetoothAdapterState.on)),
        isTrue,
      );
      expect(
        await service.isBluetoothEnabled(
          isIOS: false,
          states: Stream.fromIterable([BluetoothAdapterState.unknown, BluetoothAdapterState.on]),
        ),
        isFalse,
      );
    });
  });
}
