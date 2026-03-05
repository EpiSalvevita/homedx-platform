import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/bluetooth_service.dart' show AppBluetoothService, BluetoothDeviceInfo;

class BluetoothProvider with ChangeNotifier {
  final AppBluetoothService _bluetoothService = AppBluetoothService();

  bool _isScanning = false;
  bool _isConnected = false;
  bool _isBluetoothEnabled = false;
  BluetoothDevice? _connectedDevice;
  List<BluetoothDeviceInfo> _discoveredDevices = [];
  String? _errorMessage;
  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _characteristics = [];

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDeviceInfo> get discoveredDevices => _discoveredDevices;
  String? get errorMessage => _errorMessage;
  List<BluetoothService> get services => _services;
  List<BluetoothCharacteristic> get characteristics => _characteristics;

  BluetoothProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _bluetoothService.initialize();
      
      // Listen to connection state
      _bluetoothService.connectionStateStream.listen((connected) {
        _isConnected = connected;
        _connectedDevice = _bluetoothService.connectedDevice;
        notifyListeners();
      });

      // Listen to discovered devices
      _bluetoothService.devicesStream.listen((devices) {
        _discoveredDevices = devices;
        notifyListeners();
      });

      // Check initial Bluetooth state
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

      // Stop scanning after timeout
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

  Future<void> connect(BluetoothDevice device) async {
    try {
      _errorMessage = null;
      notifyListeners();

      await _bluetoothService.connect(device);
      _connectedDevice = device;
      _isConnected = true;

      // Discover services
      _services = await _bluetoothService.getServices();
      if (_services.isNotEmpty) {
        _characteristics = _bluetoothService.getCharacteristics(_services.first);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to connect: $e';
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      _errorMessage = null;
      await _bluetoothService.disconnect();
      _connectedDevice = null;
      _isConnected = false;
      _services = [];
      _characteristics = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to disconnect: $e';
      notifyListeners();
    }
  }

  Future<List<int>> readCharacteristic(BluetoothCharacteristic characteristic) async {
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
    BluetoothCharacteristic characteristic,
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

  Stream<List<int>> subscribeToCharacteristic(BluetoothCharacteristic characteristic) {
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

