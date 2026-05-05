import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/screens/bluetooth_scan_screen.dart';
import 'package:hdx_mobile/services/api_service.dart';
import 'package:hdx_mobile/services/cube_service.dart';

import '../services/cube_test_harness.dart';

class _FakeApiService extends ApiService {
  _FakeApiService() : super(baseUrl: 'http://test', authToken: 'tok');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CubeChannelHarness harness;
  late CubeService cube;

  setUp(() {
    harness = CubeChannelHarness();
    cube = CubeService(_FakeApiService());

    // Sensible defaults so each test only stubs the methods it cares about.
    harness.answerMethod('licenseValid', true);
    harness.answerMethod('startScan', true);
    harness.answerMethod('stopScan', null);
    harness.answerMethod('connectDevice', true);
    harness.answerMethod('getState', 'ST_DISCONNECTED');
  });

  tearDown(() {
    cube.stopListening();
    harness.dispose();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  /// Pumps the screen, lets the post-frame `licenseValid` future + the
  /// permission flow resolve, and pumps one more frame so the resulting
  /// `setState` is visible in the widget tree.
  Future<void> settleInitState(WidgetTester tester) async {
    await tester.pump(); // installs post-frame callback
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  testWidgets('shows license error UI when licenseValid returns false',
      (tester) async {
    harness.answerMethod('licenseValid', false);

    final overrides = BluetoothScanScreenTestOverrides(
      cubeService: cube,
      requestPermissions: () async => true,
    );

    await tester.pumpWidget(
      wrap(BluetoothScanScreen(testOverrides: overrides)),
    );
    await settleInitState(tester);

    expect(find.text('Fehler'), findsOneWidget);
    expect(find.textContaining('Cube-Lizenz ungültig'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
  });

  testWidgets('shows "Bluetooth deaktiviert" view when adapter is off',
      (tester) async {
    var turnOnCalls = 0;
    final overrides = BluetoothScanScreenTestOverrides(
      cubeService: cube,
      requestPermissions: () async => true,
      isBluetoothEnabled: false,
      turnOnBluetooth: () async => turnOnCalls++,
    );

    await tester.pumpWidget(
      wrap(BluetoothScanScreen(testOverrides: overrides)),
    );
    await settleInitState(tester);

    expect(find.text('Bluetooth ist deaktiviert'), findsOneWidget);
    expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);

    await tester.tap(find.text('Bluetooth aktivieren'));
    await tester.pump();

    expect(turnOnCalls, 1);
  });

  testWidgets('renders Cube device list when the SDK pushes devices',
      (tester) async {
    final overrides = BluetoothScanScreenTestOverrides(
      cubeService: cube,
      requestPermissions: () async => true,
    );

    await tester.pumpWidget(
      wrap(BluetoothScanScreen(testOverrides: overrides)),
    );
    await settleInitState(tester);

    // The screen should now be in the scanning state — empty list, spinner.
    expect(find.text('Suche nach Cube-Geräten...'), findsOneWidget);

    // Native SDK reports two Cubes via the EventChannel.
    await harness.pushEvent({
      'type': 'devices',
      'devices': [
        {'name': 'Cube-Test-001', 'commType': 'BLUETOOTH_LE', 'index': 0},
        {'name': 'Cube-Test-002', 'commType': 'BLUETOOTH_LE', 'index': 1},
      ],
    });
    await tester.pump();

    expect(find.text('Cube-Test-001'), findsOneWidget);
    expect(find.text('Cube-Test-002'), findsOneWidget);
    expect(find.text('Verbinden'), findsNWidgets(2));
  });

  testWidgets('surfaces SDK MT_ERROR messages as user-facing errors',
      (tester) async {
    final overrides = BluetoothScanScreenTestOverrides(
      cubeService: cube,
      requestPermissions: () async => true,
    );

    await tester.pumpWidget(
      wrap(BluetoothScanScreen(testOverrides: overrides)),
    );
    await settleInitState(tester);

    // Push a Cube error code as the native SDK would.
    await harness.pushEvent({
      'type': 'message',
      'msgType': 'MT_ERROR',
      'msgCode': 5,
      'msgData': 0,
    });
    await tester.pump();

    expect(find.text('Fehler'), findsOneWidget);
    expect(find.textContaining('Cube-Fehler (Code: 5)'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
  });

  testWidgets('shows permission-denied UI when requestPermissions returns false',
      (tester) async {
    final overrides = BluetoothScanScreenTestOverrides(
      cubeService: cube,
      requestPermissions: () async => false,
    );

    await tester.pumpWidget(
      wrap(BluetoothScanScreen(testOverrides: overrides)),
    );
    await settleInitState(tester);

    expect(find.text('Fehler'), findsOneWidget);
    // German curly quotes vary across editors; assert on a substring that
    // doesn't depend on the exact unicode quote characters.
    expect(find.textContaining('Geräte in der Nähe'), findsOneWidget);
    expect(find.textContaining('App-Einstellungen'), findsOneWidget);
  });
}
