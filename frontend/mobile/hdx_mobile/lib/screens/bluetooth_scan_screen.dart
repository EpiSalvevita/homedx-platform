import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/bluetooth_provider.dart';
import '../services/api_service.dart';
import '../services/cube_service.dart';
import '../widgets/neumorphic.dart';

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
  bool _connectDialogOpen = false;
  String? _error;
  Timer? _connectTimeoutTimer;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _cubeService = CubeService(apiService);
    _cubeService.onDevicesUpdated = _onDevicesUpdated;
    _cubeService.onStateChanged = _onStateChanged;
    _cubeService.onMessage = _onMessage;
    _cubeService.startListening();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final licensed = await _cubeService.licenseValid();
      if (!mounted) return;
      if (!licensed) {
        setState(() {
          _error =
              'Cube-Lizenz ungültig oder abgelaufen. Ersetzen Sie android/app/src/main/assets/cube_license.dat durch die gültige Datei vom Anbieter und bauen Sie die App neu.';
        });
        return;
      }
      _startScan();
    });
  }

  @override
  void dispose() {
    _connectTimeoutTimer?.cancel();
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
        _connectTimeoutTimer?.cancel();
        _connectTimeoutTimer = null;
        _isConnecting = false;
        if (mounted) {
          _closeConnectDialogIfOpen();
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
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = null;
      _closeConnectDialogIfOpen();
      setState(() {
        final detail = msgData != 0 ? ' (Zusatz: $msgData)' : '';
        // SDK MT_ERROR codes (see Cube programmer guide): 5 = license/device mismatch; 6 = test config.
        // Code 7 often maps to Android BLE GATT_INVALID_OFFSET (link layer), not the license file.
        _error = 'Cube-Fehler (Code: $msgCode)$detail';
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
      // Cube / blessed stack may need time for advertising + bonding; 30s is safer than 10s.
      const scanMs = 30000;
      final ok = await _cubeService.startScan(timeoutMs: scanMs);
      if (!ok && mounted) {
        setState(() {
          _isScanning = false;
          _error =
              'Scan konnte nicht gestartet werden (SDK lehnt Start ab — z. B. noch verbunden oder bereits am Scannen). Tippen Sie auf Aktualisieren oder starten Sie die App neu.';
        });
      }
      // Scanning stops automatically after timeout; state event will update _isScanning
      await Future.delayed(const Duration(milliseconds: scanMs + 1500));
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

    _connectTimeoutTimer?.cancel();
    // BLE connect + bond + Cube handshake can exceed 20s on some phones; cancel on ST_IDLE / MT_ERROR.
    _connectTimeoutTimer = Timer(const Duration(seconds: 60), () {
      if (!mounted || !_isConnecting) return;
      _closeConnectDialogIfOpen();
      setState(() {
        _isConnecting = false;
        _error =
            'Verbindung zum Cube dauerte zu lange (60 s). Cube nah ans Telefon halten, Suche mit „Stopp“ beenden und erneut „Verbinden“ tippen. In Android-Bluetooth ggf. Gerät trennen (nicht nur paaren).';
      });
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    _connectDialogOpen = true;

    try {
      // Active BLE scan can block or slow GATT connect on several stacks.
      await _cubeService.stopScan();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      // disableButton: matches vendor flow for reader hardware during connect.
      final ok = await _cubeService.connectDevice(device.index, disableButton: true);
      if (!ok && mounted) {
        _connectTimeoutTimer?.cancel();
        _connectTimeoutTimer = null;
        _closeConnectDialogIfOpen();
        setState(() {
          _isConnecting = false;
          _error = 'Verbindung fehlgeschlagen';
        });
      }
      // If connection succeeds, _onStateChanged will handle navigation
    } catch (e) {
      if (mounted) {
        _connectTimeoutTimer?.cancel();
        _connectTimeoutTimer = null;
        _closeConnectDialogIfOpen();
        setState(() {
          _isConnecting = false;
          _error = 'Verbindungsfehler: $e';
        });
      }
    }
  }

  void _closeConnectDialogIfOpen() {
    if (!_connectDialogOpen || !mounted) return;
    _connectDialogOpen = false;
    Navigator.of(context, rootNavigator: true).pop();
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
            Icon(Icons.bluetooth_disabled, size: 96, color: AppTheme.textColor),
            const SizedBox(height: 28),
            Text(
              'Bluetooth ist deaktiviert',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Bitte aktivieren Sie Bluetooth, um nach Cube-Geräten zu suchen',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppTheme.textColor),
            ),
            const SizedBox(height: 36),
            NeumorphicButton(
              isPrimary: true,
              onPressed: () => provider.turnOnBluetooth(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bluetooth, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Bluetooth aktivieren', style: TextStyle(color: Colors.white)),
                ],
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
            Icon(Icons.error_outline, size: 96, color: AppTheme.errorColor),
            const SizedBox(height: 28),
            Text(
              'Fehler',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppTheme.textColor),
            ),
            const SizedBox(height: 36),
            NeumorphicButton(
              isPrimary: true,
              onPressed: _startScan,
              child: Text('Erneut versuchen', style: TextStyle(color: Colors.white)),
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
          Text(
            'Suche nach Cube-Geräten...',
            style: TextStyle(fontSize: 20, color: AppTheme.textColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Stellen Sie sicher, dass Ihr Cube eingeschaltet ist',
            style: TextStyle(fontSize: 16, color: AppTheme.textColorSecondary),
            textAlign: TextAlign.center,
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
            Icon(Icons.bluetooth_searching, size: 96, color: AppTheme.textColor),
            const SizedBox(height: 28),
            Text(
              'Kein Cube-Gerät gefunden',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Stellen Sie sicher, dass Ihr Cube eingeschaltet und in Reichweite ist',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppTheme.textColor),
            ),
            const SizedBox(height: 36),
            NeumorphicButton(
              isPrimary: true,
              onPressed: _startScan,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Erneut suchen', style: TextStyle(color: Colors.white)),
                ],
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: _isConnecting ? null : () => _connectDevice(device),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                  children: [
                    Icon(Icons.medical_services, color: AppTheme.primaryColor, size: 36),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        device.name.isNotEmpty ? device.name : 'Cube-Gerät',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor, fontSize: 18),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: _isConnecting,
                      child: NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => _connectDevice(device),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Text('Verbinden', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
