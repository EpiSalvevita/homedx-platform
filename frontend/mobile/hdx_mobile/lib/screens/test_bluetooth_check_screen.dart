import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/bluetooth_provider.dart';
import '../services/api_service.dart';
import '../services/cube_service.dart';
import 'bluetooth_scan_screen.dart';

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

  final ValueNotifier<String> _statusNotifier =
      ValueNotifier('Starte Messung...');

  Future<void> _proceedWithTest() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: ValueListenableBuilder<String>(
              valueListenable: _statusNotifier,
              builder: (context, status, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(status),
                  const SizedBox(height: 8),
                  Text(
                    'Bitte warten Sie, bis die Messung abgeschlossen ist.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final result = await _cubeService.runTestAndSubmit(
        testTypeId: widget.testTypeId,
        onStatus: (status) => _statusNotifier.value = status,
      );

      if (mounted) Navigator.of(context).pop();

      if (result.success) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Testergebnis'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.testTypeName} Test abgeschlossen',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        result.result == 'POSITIVE'
                            ? Icons.warning
                            : result.result == 'NEGATIVE'
                                ? Icons.check_circle
                                : Icons.help,
                        color: result.result == 'POSITIVE'
                            ? Colors.red
                            : result.result == 'NEGATIVE'
                                ? Colors.green
                                : Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        result.result ?? 'Unbekannt',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: result.result == 'POSITIVE'
                              ? Colors.red
                              : result.result == 'NEGATIVE'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  if (result.resultData != null &&
                      result.resultData!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      'Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...result.resultData!.map((data) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child:
                              Text('${data.name}: ${data.value} ${data.unit}'),
                        )),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result.error ?? 'Fehler beim Verarbeiten des Tests'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
            const Icon(Icons.bluetooth_disabled, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Bluetooth ist deaktiviert',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bluetooth muss aktiviert sein, um eine Verbindung zum Cube-Gerät herzustellen',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.turnOnBluetooth(),
              icon: const Icon(Icons.bluetooth),
              label: const Text('Bluetooth aktivieren'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Cube-Gerät verbunden',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: $_cubeState',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bereit zum Teststart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ihr Cube-Gerät ist verbunden und bereit. Sie können nun mit dem ${widget.testTypeName} Test fortfahren.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _proceedWithTest,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
                _isProcessing ? 'Test wird gestartet...' : 'Test starten'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : _disconnectCube,
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Gerät trennen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
            const Icon(Icons.bluetooth_searching, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Kein Cube-Gerät verbunden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Bitte verbinden Sie Ihr Cube-Gerät, um mit dem ${widget.testTypeName} Test fortzufahren',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToScan,
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Nach Cube-Geräten suchen'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }
}
