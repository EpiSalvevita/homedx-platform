import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../services/api_service.dart';
import '../services/cube_service.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  late CubeService _cubeService;
  List<CubeDeviceInfo> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _cubeService = CubeService(apiService);
    _cubeService.onDevicesUpdated = _onDevicesUpdated;
    _cubeService.onStateChanged = _onStateChanged;
    _cubeService.onMessage = _onMessage;
    _cubeService.startListening();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScan();
    });
  }

  @override
  void dispose() {
    _cubeService.stopListening();
    super.dispose();
  }

  void _onDevicesUpdated(List<CubeDeviceInfo> devices) {
    if (mounted) setState(() => _devices = devices);
  }

  void _onStateChanged(String state) {
    if (!mounted) return;

    if (state == 'ST_IDLE') {
      // Connected and idle — go back with success
      if (_isConnecting) {
        _isConnecting = false;
        if (mounted) {
          Navigator.of(context).pop(); // close loading dialog if any
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cube-Gerät verbunden'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } else if (state == 'ST_SCAN') {
      setState(() => _isScanning = true);
    } else if (state == 'ST_DISCONNECTED') {
      setState(() => _isScanning = false);
    }
  }

  void _onMessage(String msgType, int msgCode, int msgData) {
    if (msgType == 'MT_ERROR' && mounted) {
      setState(() {
        _error = 'Cube-Fehler (Code: $msgCode)';
        _isConnecting = false;
      });
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _error = null;
      _isScanning = true;
      _devices = [];
    });
    try {
      final ok = await _cubeService.startScan(timeoutMs: 10000);
      if (!ok && mounted) {
        setState(() {
          _isScanning = false;
          _error = 'Scan konnte nicht gestartet werden. Ist die Lizenz gültig?';
        });
      }
      // Scanning stops automatically after timeout; state event will update _isScanning
      await Future.delayed(const Duration(seconds: 11));
      if (mounted) setState(() => _isScanning = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _error = 'Scan-Fehler: $e';
        });
      }
    }
  }

  Future<void> _connectDevice(CubeDeviceInfo device) async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ok = await _cubeService.connectDevice(device.index);
      if (!ok && mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isConnecting = false;
          _error = 'Verbindung fehlgeschlagen';
        });
      }
      // If connection succeeds, _onStateChanged will handle navigation
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isConnecting = false;
          _error = 'Verbindungsfehler: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cube-Gerät suchen'),
        actions: [
          if (_isScanning)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => _cubeService.stopScan(),
              tooltip: 'Suche stoppen',
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
              tooltip: 'Suche starten',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final btProvider = Provider.of<BluetoothProvider>(context);
    if (!btProvider.isBluetoothEnabled) {
      return _buildBluetoothDisabledView(btProvider);
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_isScanning && _devices.isEmpty) {
      return _buildScanningView();
    }

    if (_devices.isEmpty) {
      return _buildEmptyView();
    }

    return _buildDeviceList();
  }

  Widget _buildBluetoothDisabledView(BluetoothProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Bluetooth ist deaktiviert',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bitte aktivieren Sie Bluetooth, um nach Cube-Geräten zu suchen',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.turnOnBluetooth(),
              icon: const Icon(Icons.bluetooth),
              label: const Text('Bluetooth aktivieren'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Fehler',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startScan,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Suche nach Cube-Geräten...',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Stellen Sie sicher, dass Ihr Cube eingeschaltet ist',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_searching, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Kein Cube-Gerät gefunden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Stellen Sie sicher, dass Ihr Cube eingeschaltet und in Reichweite ist',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut suchen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return Column(
      children: [
        if (_isScanning)
          const LinearProgressIndicator(),
        Expanded(
          child: ListView.builder(
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              final device = _devices[index];
              return ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.teal),
                title: Text(
                  device.name.isNotEmpty ? device.name : 'Cube-Gerät',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: ElevatedButton(
                  onPressed: _isConnecting ? null : () => _connectDevice(device),
                  child: const Text('Verbinden'),
                ),
                onTap: _isConnecting ? null : () => _connectDevice(device),
              );
            },
          ),
        ),
      ],
    );
  }
}
