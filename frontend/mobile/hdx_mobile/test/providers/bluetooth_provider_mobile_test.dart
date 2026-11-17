import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothAdapterState;
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/providers/bluetooth_provider_mobile.dart';

void main() {
  test('adapter state -> enabled flag; unknown leaves the flag unchanged', () {
    expect(BluetoothProvider.enabledFromAdapterState(BluetoothAdapterState.on), isTrue);
    expect(BluetoothProvider.enabledFromAdapterState(BluetoothAdapterState.off), isFalse);
    expect(BluetoothProvider.enabledFromAdapterState(BluetoothAdapterState.turningOn), isFalse);
    expect(BluetoothProvider.enabledFromAdapterState(BluetoothAdapterState.unauthorized), isFalse);
    // iOS cold launch reports `unknown` first: must not show "disabled".
    expect(BluetoothProvider.enabledFromAdapterState(BluetoothAdapterState.unknown), isNull);
  });
}
