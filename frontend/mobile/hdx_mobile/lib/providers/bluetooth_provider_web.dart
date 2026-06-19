import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class BluetoothProvider with ChangeNotifier {
  final AppBluetoothService _bluetoothService = AppBluetoothService();

  bool _isScanning = false;
  bool _isConnected = false;
  bool _isBluetoothEnabled = false;
  List<BluetoothDeviceInfo> _discoveredDevices = [];
  String? _errorMessage;

  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  Object? get connectedDevice => _bluetoothService.connectedDevice;
  List<BluetoothDeviceInfo> get discoveredDevices => _discoveredDevices;
  String? get errorMessage => _errorMessage;
  List<Object> get services => [];
  List<Object> get characteristics => [];

  BluetoothProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _bluetoothService.initialize();

      _bluetoothService.connectionStateStream.listen((connected) {
        _isConnected = connected;
        notifyListeners();
      });

      _bluetoothService.devicesStream.listen((devices) {
        _discoveredDevices = devices;
        notifyListeners();
      });

      _isBluetoothEnabled = await _bluetoothService.isBluetoothEnabled();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize Bluetooth: $e';
      notifyListeners();
    }
  }

  Future<void> checkBluetoothStatus() async {
    try {
      _errorMessage = null;
      _isBluetoothEnabled = await _bluetoothService.isBluetoothEnabled();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to check Bluetooth status: $e';
      notifyListeners();
    }
  }

  Future<void> turnOnBluetooth() async {
    try {
      _errorMessage = null;
      await _bluetoothService.turnOnBluetooth();
      _isBluetoothEnabled = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to turn on Bluetooth: $e';
      notifyListeners();
    }
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      _errorMessage = null;
      _isScanning = true;
      notifyListeners();

      await _bluetoothService.requestPermissions();
      await _bluetoothService.startScan(timeout: timeout);

      Future.delayed(timeout, () {
        stopScan();
      });
    } catch (e) {
      _errorMessage = 'Failed to start scan: $e';
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    try {
      _errorMessage = null;
      await _bluetoothService.stopScan();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to stop scan: $e';
      notifyListeners();
    }
  }

  Future<void> connect(Object device) async {
    try {
      _errorMessage = null;
      notifyListeners();

      await _bluetoothService.connect(device);
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to connect: $e';
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      _errorMessage = null;
      await _bluetoothService.disconnect();
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to disconnect: $e';
      notifyListeners();
    }
  }

  Future<List<int>> readCharacteristic(Object characteristic) async {
    try {
      _errorMessage = null;
      return await _bluetoothService.readCharacteristic(characteristic);
    } catch (e) {
      _errorMessage = 'Failed to read characteristic: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> writeCharacteristic(
    Object characteristic,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    try {
      _errorMessage = null;
      await _bluetoothService.writeCharacteristic(
        characteristic,
        value,
        withoutResponse: withoutResponse,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to write characteristic: $e';
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<int>> subscribeToCharacteristic(Object characteristic) {
    try {
      return _bluetoothService.subscribeToCharacteristic(characteristic);
    } catch (e) {
      _errorMessage = 'Failed to subscribe to characteristic: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }
}
