import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;

import '../config/app_theme.dart';
import '../providers/bluetooth_provider.dart';
import '../services/api_service.dart';
import '../services/cube_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/bluetooth_icon.dart';
import '../utils/constants.dart';
import '../widgets/neumorphic.dart';
import 'bluetooth_scan_screen.dart';
import 'test_progress_screen.dart';

class TestBluetoothCheckScreen extends StatefulWidget {
  final String testTypeId;
  final String testTypeName;
  final String? rapidTestId;

  const TestBluetoothCheckScreen({
    super.key,
    required this.testTypeId,
    required this.testTypeName,
    this.rapidTestId,
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

  /// Picked Cube test configuration (`.config`/`.bin` — vendor binary blob), or null for RFID.
  String? _cubeConfigAbsolutePath;

  static String _fileBasename(String p) {
    final n = p.replaceAll('\\', '/').split('/').last;
    return n.isEmpty ? p : n;
  }

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
    // While TestProgressScreen is open we set [_isProcessing]; a GoRouter / navigator
    // rebuild can dispose this State briefly and would otherwise call
    // [CubeService.stopListening] → native EventChannel onCancel → missed Cube SDK
    // messages (see log: onCancel right after ST_IDLE, before startEvaluation).
    if (!_isProcessing) {
      _cubeService.stopListening();
    }
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
    developer.log(
      'TestBluetoothCheck: _proceedWithTest testTypeId=${widget.testTypeId} '
      'connected=$_cubeConnected state=$_cubeState '
      'pickedConfig=${_cubeConfigAbsolutePath ?? '(bundled/RFID)'}',
      name: 'HDX_CUBE',
    );
    setState(() => _isProcessing = true);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestProgressScreen(
          cubeService: _cubeService,
          testTypeId: widget.testTypeId,
          testTypeName: widget.testTypeName,
          rapidTestId: widget.rapidTestId,
          useTimer: AppConstants.cubeUseTimer,
          cubeConfigAbsolutePath: _cubeConfigAbsolutePath,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        // If dispose() skipped stopListening while progress was open, ensure the
        // EventChannel is listening again for the Bluetooth-Prüfung screen.
        _cubeService.startListening();
      }
    });
  }

  Future<void> _pickCubeConfigFile() async {
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['config', 'bin', 'dat', 'CFG', 'cfg'],
      withData: false,
    );
    if (pick == null || pick.files.isEmpty || !mounted) return;
    final path = pick.files.single.path;
    if (path == null || path.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kein Dateipfad verfügbar. Bitte über „Dateien“ wählen oder die Datei in Downloads ablegen.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    setState(() => _cubeConfigAbsolutePath = path);
  }

  void _clearCubeConfigFile() => setState(() => _cubeConfigAbsolutePath = null);

  Future<void> _navigateToScan() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            BluetoothScanScreen(sharedCubeService: _cubeService),
      ),
    );

    if (mounted) {
      // Scan overwrote these handlers; restore parent wiring. A second
      // CubeService on the scan route used to replace the EventChannel
      // listener — bounce stop/start so [startListening] can attach again.
      _cubeService.onStateChanged = _onCubeStateChanged;
      _cubeService.onDevicesUpdated = null;
      _cubeService.onMessage = null;
      _cubeService.stopListening();
      _cubeService.startListening();
    }
    if (result == true && mounted) {
      await _checkCubeConnection();
    }
  }

  void _goHome() {
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _handleBack() async {
    if (_isProcessing) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test abbrechen?'),
          content: const Text(
            'Die laufende Messung wird beendet und Sie kehren zur Startseite zurück.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Weiter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      );
      if (leave != true || !mounted) return;
      await Navigator.of(context).maybePop();
      if (!mounted) return;
    }
    _goHome();
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
    return FigmaScreen(
      header: FigmaBackHeader(title: 'Bluetooth', onBack: _handleBack),
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
            const BluetoothAssetIcon.disabled(size: 96),
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
                  const BluetoothAssetIcon(size: 24),
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
          const SizedBox(height: 24),
          NeumorphicContainer(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messkonfiguration (Cube)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  _cubeConfigAbsolutePath != null
                      ? 'Konfigurationsdatei: ${_fileBasename(_cubeConfigAbsolutePath!)}'
                      : 'Standard: Kalibrierung per RFID von der eingelegten Kassette. '
                          'Mit „Datei wählen“ verwenden Sie stattdessen eine `.config`/`.bin` vom Anbieter '
                          '(wie in der Cube-Beispiel-App).',
                  style: TextStyle(fontSize: 15, color: AppTheme.textColor),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: _isProcessing ? null : _pickCubeConfigFile,
                      icon: Icon(Icons.folder_open, color: AppTheme.primaryColor),
                      label: Text('Konfigurationsdatei wählen', style: TextStyle(color: AppTheme.primaryColor)),
                    ),
                    if (_cubeConfigAbsolutePath != null)
                      TextButton(
                        onPressed: _isProcessing ? null : _clearCubeConfigFile,
                        child: Text('RFID-Modus (Datei löschen)', style: TextStyle(color: AppTheme.textColor)),
                      ),
                  ],
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
                  const BluetoothAssetIcon.disabled(size: 24),
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
            const BluetoothAssetIcon(size: 96),
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
                  const BluetoothAssetIcon(size: 24),
                  const SizedBox(width: 8),
                  Text('Nach Cube-Geräten suchen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _goHome,
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
