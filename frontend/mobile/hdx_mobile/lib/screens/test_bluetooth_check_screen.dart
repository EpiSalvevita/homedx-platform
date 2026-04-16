import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/bluetooth_provider.dart';
import '../services/api_service.dart';
import '../services/cube_service.dart';
import '../widgets/neumorphic.dart';
import 'bluetooth_scan_screen.dart';
import 'test_progress_screen.dart';

class TestBluetoothCheckScreen extends StatefulWidget {
  final String testTypeId;
  final String testTypeName;

  const TestBluetoothCheckScreen({
    super.key,
    required this.testTypeId,
    required this.testTypeName,
  });

  @override
  State<TestBluetoothCheckScreen> createState() =>
      _TestBluetoothCheckScreenState();
}

class _TestBluetoothCheckScreenState extends State<TestBluetoothCheckScreen> {
  late CubeService _cubeService;
  bool _isProcessing = false;
  bool _cubeConnected = false;
  String _cubeState = 'ST_DISCONNECTED';

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _cubeService = CubeService(apiService);
    _cubeService.onStateChanged = _onCubeStateChanged;
    _cubeService.startListening();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCubeConnection();
    });
  }

  @override
  void dispose() {
    _cubeService.stopListening();
    super.dispose();
  }

  void _onCubeStateChanged(String state) {
    if (!mounted) return;
    setState(() {
      _cubeState = state;
      _cubeConnected = state == 'ST_IDLE' ||
          state == 'ST_READ' ||
          state == 'ST_EVALUATE' ||
          state == 'ST_DEVICE_BUSY';
    });
  }

  Future<void> _checkCubeConnection() async {
    final connected = await _cubeService.isConnected();
    if (mounted) {
      setState(() => _cubeConnected = connected);
    }
  }

  void _proceedWithTest() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestProgressScreen(
          cubeService: _cubeService,
          testTypeId: widget.testTypeId,
          testTypeName: widget.testTypeName,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  Future<void> _navigateToScan() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const BluetoothScanScreen(),
      ),
    );

    if (result == true && mounted) {
      await _checkCubeConnection();
    }
  }

  Future<void> _disconnectCube() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät trennen'),
        content: const Text(
            'Möchten Sie die Verbindung wirklich trennen? Sie müssen sich erneut verbinden, um den Test zu starten.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Trennen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubeService.disconnectDevice();
      if (mounted) {
        setState(() => _cubeConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cube-Gerät getrennt'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.testTypeName} - Bluetooth-Prüfung'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Zurück',
        ),
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, btProvider, _) {
          if (!btProvider.isBluetoothEnabled) {
            return _buildBluetoothDisabledView(btProvider);
          }
          if (_cubeConnected) {
            return _buildConnectedView();
          }
          return _buildDisconnectedView();
        },
      ),
    );
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
              'Bluetooth muss aktiviert sein, um eine Verbindung zum Cube-Gerät herzustellen',
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

  Widget _buildConnectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeumorphicContainer(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 64, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Cube-Gerät verbunden',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: $_cubeState',
                  style: TextStyle(fontSize: 14, color: AppTheme.textColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          NeumorphicContainer(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bereit zum Teststart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ihr Cube-Gerät ist verbunden und bereit. Sie können nun mit dem ${widget.testTypeName} Test fortfahren.',
                  style: TextStyle(fontSize: 16, color: AppTheme.textColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          IgnorePointer(
            ignoring: _isProcessing,
            child: NeumorphicButton(
              isPrimary: true,
              onPressed: _proceedWithTest,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(Icons.play_arrow, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _isProcessing ? 'Test wird gestartet...' : 'Test starten',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          IgnorePointer(
            ignoring: _isProcessing,
            child: NeumorphicButton(
              onPressed: _disconnectCube,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_disabled, color: AppTheme.textColor),
                  const SizedBox(width: 8),
                  Text('Gerät trennen', style: TextStyle(color: AppTheme.textColor, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_searching, size: 96, color: AppTheme.primaryColor),
            const SizedBox(height: 28),
            Text(
              'Kein Cube-Gerät verbunden',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Bitte verbinden Sie Ihr Cube-Gerät, um mit dem ${widget.testTypeName} Test fortzufahren',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppTheme.textColor),
            ),
            const SizedBox(height: 36),
            NeumorphicButton(
              isPrimary: true,
              onPressed: _navigateToScan,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth_searching, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Nach Cube-Geräten suchen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(48, 48),
              ),
              child: Text('Abbrechen', style: TextStyle(fontSize: 18, color: AppTheme.textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
