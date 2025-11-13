import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue show BluetoothService;
import 'package:permission_handler/permission_handler.dart';

class BluetoothDeviceInfo {
  final String id;
  final String name;
  final BluetoothDevice device;
  final int? rssi;
  final bool isConnected;

  BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.device,
    this.rssi,
    this.isConnected = false,
  });
}

class AppBluetoothService {
  static final AppBluetoothService _instance = AppBluetoothService._internal();
  factory AppBluetoothService() => _instance;
  AppBluetoothService._internal();

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  BluetoothDevice? _connectedDevice;
  List<BluetoothDeviceInfo> _discoveredDevices = [];
  bool _isScanning = false;
  bool _isConnected = false;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDeviceInfo> get discoveredDevices => _discoveredDevices;

  // Stream controllers for state updates
  final _connectionStateController = StreamController<bool>.broadcast();
  final _devicesController = StreamController<List<BluetoothDeviceInfo>>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<List<BluetoothDeviceInfo>> get devicesStream => _devicesController.stream;
  Stream<List<int>> get dataStream => _dataController.stream;

  /// Initialize Bluetooth service
  Future<void> initialize() async {
    // Listen to adapter state changes
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        // Bluetooth is on
      } else if (state == BluetoothAdapterState.off) {
        // Bluetooth is off
        _isConnected = false;
        _connectedDevice = null;
        _connectionStateController.add(false);
      }
    });

    // Check current connected devices
    try {
      final devices = FlutterBluePlus.connectedDevices;
      _isConnected = devices.isNotEmpty;
      if (devices.isNotEmpty) {
        _connectedDevice = devices.first;
      } else {
        _connectedDevice = null;
      }
      _connectionStateController.add(_isConnected);
    } catch (e) {
      // Ignore errors during initialization
    }
  }

  /// Check and request Bluetooth permissions
  Future<bool> requestPermissions() async {
    // Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth is not supported on this device');
    }

    // Request location permission (required for Bluetooth scanning on Android)
    final locationStatus = await Permission.location.request();
    if (!locationStatus.isGranted) {
      throw Exception('Location permission is required for Bluetooth scanning');
    }

    // Request Bluetooth permissions (Android 12+)
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return true;
    }

    // For older Android versions, check if Bluetooth is enabled
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw Exception('Bluetooth is not enabled. Please enable Bluetooth in settings.');
    }

    return true;
  }

  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    return adapterState == BluetoothAdapterState.on;
  }

  /// Turn on Bluetooth (Android only)
  Future<void> turnOnBluetooth() async {
    await FlutterBluePlus.turnOn();
  }

  /// Start scanning for Bluetooth devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) {
      return;
    }

    await requestPermissions();

    if (!await isBluetoothEnabled()) {
      throw Exception('Bluetooth is not enabled');
    }

    _isScanning = true;
    _discoveredDevices.clear();
    _devicesController.add(_discoveredDevices);

    // Start scanning
    await FlutterBluePlus.startScan(timeout: timeout);

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _discoveredDevices.clear();
      
      for (var result in results) {
        final device = result.device;
        final deviceInfo = BluetoothDeviceInfo(
          id: device.remoteId.str,
          name: device.platformName.isNotEmpty 
              ? device.platformName 
              : 'Unknown Device',
          device: device,
          rssi: result.rssi,
          isConnected: device.isConnected,
        );

        // Avoid duplicates
        if (!_discoveredDevices.any((d) => d.id == deviceInfo.id)) {
          _discoveredDevices.add(deviceInfo);
        }
      }

      _devicesController.add(List.from(_discoveredDevices));
    });
  }

  /// Stop scanning for Bluetooth devices
  Future<void> stopScan() async {
    if (!_isScanning) {
      return;
    }

    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
  }

  /// Connect to a Bluetooth device
  Future<void> connect(BluetoothDevice device) async {
    try {
      // Disconnect from current device if connected
      if (_connectedDevice != null && _connectedDevice != device) {
        await disconnect();
      }

      // Connect to the new device
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;
      _isConnected = true;
      _connectionStateController.add(true);

      // Discover services after connection
      await device.discoverServices();
    } catch (e) {
      _isConnected = false;
      _connectedDevice = null;
      _connectionStateController.add(false);
      rethrow;
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        // Ignore errors during disconnect
      }
    }

    _connectedDevice = null;
    _isConnected = false;
    _connectionStateController.add(false);
  }

  /// Read data from a characteristic
  Future<List<int>> readCharacteristic(
    BluetoothCharacteristic characteristic,
  ) async {
    try {
      final value = await characteristic.read();
      _dataController.add(value);
      return value;
    } catch (e) {
      throw Exception('Failed to read characteristic: $e');
    }
  }

  /// Write data to a characteristic
  Future<void> writeCharacteristic(
    BluetoothCharacteristic characteristic,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    try {
      await characteristic.write(
        value,
        withoutResponse: withoutResponse,
      );
    } catch (e) {
      throw Exception('Failed to write characteristic: $e');
    }
  }

  /// Subscribe to notifications from a characteristic
  Stream<List<int>> subscribeToCharacteristic(
    BluetoothCharacteristic characteristic,
  ) {
    try {
      characteristic.setNotifyValue(true);
      return characteristic.onValueReceived;
    } catch (e) {
      throw Exception('Failed to subscribe to characteristic: $e');
    }
  }

  /// Get services from connected device
  Future<List<blue.BluetoothService>> getServices() async {
    if (_connectedDevice == null || !_isConnected) {
      throw Exception('No device connected');
    }

    try {
      final services = await _connectedDevice!.discoverServices();
      return services;
    } catch (e) {
      throw Exception('Failed to discover services: $e');
    }
  }

  /// Get characteristics from a service
  List<BluetoothCharacteristic> getCharacteristics(blue.BluetoothService service) {
    return service.characteristics;
  }

  /// Cleanup resources
  void dispose() {
    stopScan();
    disconnect();
    _adapterStateSubscription?.cancel();
    _connectionStateController.close();
    _devicesController.close();
    _dataController.close();
  }
}

