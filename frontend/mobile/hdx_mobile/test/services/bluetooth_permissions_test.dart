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

    for (final s in [PermissionStatus.denied, PermissionStatus.permanentlyDenied]) {
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
    });
  });
}
