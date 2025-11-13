import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import '../providers/bluetooth_provider.dart';
import '../services/bluetooth_service.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BluetoothProvider>(context, listen: false);
      provider.checkBluetoothStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for Devices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/bluetooth'),
          tooltip: 'Back',
        ),
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, provider, _) {
              if (provider.isScanning) {
                return IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => provider.stopScan(),
                  tooltip: 'Stop Scanning',
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.startScan(),
                  tooltip: 'Start Scanning',
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, provider, _) {
          // Check Bluetooth status
          if (!provider.isBluetoothEnabled) {
            return _buildBluetoothDisabledView(provider);
          }

          // Show error if any
          if (provider.errorMessage != null) {
            return _buildErrorView(provider);
          }

          // Show scanning status
          if (provider.isScanning && provider.discoveredDevices.isEmpty) {
            return _buildScanningView();
          }

          // Show discovered devices
          if (provider.discoveredDevices.isEmpty) {
            return _buildEmptyView(provider);
          }

          return _buildDeviceList(provider);
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
            const Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bluetooth is Disabled',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enable Bluetooth to scan for devices',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.turnOnBluetooth(),
              icon: const Icon(Icons.bluetooth),
              label: const Text('Enable Bluetooth'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BluetoothProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.checkBluetoothStatus();
              },
              child: const Text('Retry'),
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
            'Scanning for devices...',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your device is discoverable',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BluetoothProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bluetooth_searching,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Devices Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap the refresh button to start scanning',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.startScan(),
              icon: const Icon(Icons.refresh),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(BluetoothProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.stopScan();
        await provider.startScan();
      },
      child: ListView.builder(
        itemCount: provider.discoveredDevices.length,
        itemBuilder: (context, index) {
          final deviceInfo = provider.discoveredDevices[index];
          return _buildDeviceTile(deviceInfo, provider);
        },
      ),
    );
  }

  Widget _buildDeviceTile(
    BluetoothDeviceInfo deviceInfo,
    BluetoothProvider provider,
  ) {
    final isConnected = provider.isConnected &&
        provider.connectedDevice?.remoteId == deviceInfo.device.remoteId;

    return ListTile(
      leading: Icon(
        isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
        color: isConnected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        deviceInfo.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${deviceInfo.id}'),
          if (deviceInfo.rssi != null)
            Text('Signal: ${deviceInfo.rssi} dBm'),
        ],
      ),
      trailing: isConnected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              onPressed: () => _connectToDevice(deviceInfo.device, provider),
              child: const Text('Connect'),
            ),
      onTap: isConnected
          ? null
          : () => _connectToDevice(deviceInfo.device, provider),
    );
  }

  Future<void> _connectToDevice(
    BluetoothDevice device,
    BluetoothProvider provider,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await provider.connect(device);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.platformName}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate back or to connection screen
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate connection
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

