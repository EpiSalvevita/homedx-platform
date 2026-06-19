import 'dart:async';

class BluetoothDeviceInfo {
  final String id;
  final String name;
  final int? rssi;
  final bool isConnected;

  BluetoothDeviceInfo({
    required this.id,
    required this.name,
    this.rssi,
    this.isConnected = false,
  });
}

class AppBluetoothService {
  static final AppBluetoothService _instance = AppBluetoothService._internal();
  factory AppBluetoothService() => _instance;
  AppBluetoothService._internal();

  bool get isScanning => false;
  bool get isConnected => false;
  Object? get connectedDevice => null;
  List<BluetoothDeviceInfo> get discoveredDevices => const [];

  final _connectionStateController = StreamController<bool>.broadcast();
  final _devicesController =
      StreamController<List<BluetoothDeviceInfo>>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<List<BluetoothDeviceInfo>> get devicesStream =>
      _devicesController.stream;
  Stream<List<int>> get dataStream => _dataController.stream;

  Future<void> initialize() async {}

  Future<bool> requestPermissions() async {
    throw UnsupportedError(
      'Bluetooth ist im Web derzeit nicht verfügbar. Bitte nutzen Sie die mobile App.',
    );
  }

  Future<bool> isBluetoothEnabled() async => false;

  Future<void> turnOnBluetooth() async {
    throw UnsupportedError(
      'Bluetooth ist im Web derzeit nicht verfügbar. Bitte nutzen Sie die mobile App.',
    );
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    throw UnsupportedError(
      'Bluetooth ist im Web derzeit nicht verfügbar. Bitte nutzen Sie die mobile App.',
    );
  }

  Future<void> stopScan() async {}

  Future<void> connect(Object device) async {
    throw UnsupportedError(
      'Bluetooth ist im Web derzeit nicht verfügbar. Bitte nutzen Sie die mobile App.',
    );
  }

  Future<void> disconnect() async {}

  Future<List<int>> readCharacteristic(Object characteristic) async {
    throw UnsupportedError('Bluetooth nicht verfügbar im Web.');
  }

  Future<void> writeCharacteristic(
    Object characteristic,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    throw UnsupportedError('Bluetooth nicht verfügbar im Web.');
  }

  Stream<List<int>> subscribeToCharacteristic(Object characteristic) {
    throw UnsupportedError('Bluetooth nicht verfügbar im Web.');
  }

  Future<List<Object>> getServices() async => [];

  List<Object> getCharacteristics(Object service) => [];

  void dispose() {
    _connectionStateController.close();
    _devicesController.close();
    _dataController.close();
  }
}
