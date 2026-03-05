import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../providers/bluetooth_provider.dart';
import 'bluetooth_scan_screen.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  State<BluetoothConnectionScreen> createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth-Verbindung'),
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, provider, _) {
          if (provider.isConnected && provider.connectedDevice != null) {
            return _buildConnectedView(provider);
          } else {
            return _buildDisconnectedView(provider);
          }
        },
      ),
    );
  }

  Widget _buildConnectedView(BluetoothProvider provider) {
    final device = provider.connectedDevice!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection Status Card
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.bluetooth_connected,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verbunden',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.platformName.isNotEmpty
                        ? device.platformName
                        : 'Unbekanntes Gerät',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${device.remoteId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Services Section
          if (provider.services.isNotEmpty) ...[
            const Text(
              'Dienste',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.services.map((service) => Card(
                  child: ExpansionTile(
                    title: Text('Service: ${service.uuid}'),
                    subtitle: Text('${service.characteristics.length} characteristics'),
                    children: [
                      ...service.characteristics.map((characteristic) => ListTile(
                            title: Text('Characteristic: ${characteristic.uuid}'),
                            subtitle: Text(
                              'Properties: ${characteristic.properties.toString()}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (characteristic.properties.read)
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () => _readCharacteristic(
                                      characteristic,
                                      provider,
                                    ),
                                    tooltip: 'Lesen',
                                  ),
                                if (characteristic.properties.write ||
                                    characteristic.properties.writeWithoutResponse)
                                  IconButton(
                                    icon: const Icon(Icons.upload),
                                    onPressed: () => _writeCharacteristic(
                                      characteristic,
                                      provider,
                                    ),
                                    tooltip: 'Schreiben',
                                  ),
                                if (characteristic.properties.notify ||
                                    characteristic.properties.indicate)
                                  IconButton(
                                    icon: const Icon(Icons.notifications),
                                    onPressed: () => _subscribeToCharacteristic(
                                      characteristic,
                                      provider,
                                    ),
                                    tooltip: 'Abonnieren',
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],

          // Disconnect Button
          ElevatedButton.icon(
            onPressed: () => _disconnect(provider),
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Trennen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedView(BluetoothProvider provider) {
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
              'Kein Gerät verbunden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suchen Sie nach einem Bluetooth-Gerät und verbinden Sie sich, um zu beginnen',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToScan(provider),
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Nach Geräten suchen'),
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

  Future<void> _navigateToScan(BluetoothProvider provider) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const BluetoothScanScreen(),
      ),
    );

    if (result == true && mounted) {
      // Device connected, refresh the view
      setState(() {});
    }
  }

  Future<void> _disconnect(BluetoothProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät trennen'),
        content: const Text('Möchten Sie die Verbindung wirklich trennen?'),
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
      await provider.disconnect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Getrennt'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _readCharacteristic(
    BluetoothCharacteristic characteristic,
    BluetoothProvider provider,
  ) async {
    try {
      final data = await provider.readCharacteristic(characteristic);
      if (mounted) {
        _showDataDialog('Gelesene Daten', data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lesen fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _writeCharacteristic(
    BluetoothCharacteristic characteristic,
    BluetoothProvider provider,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daten schreiben'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Daten eingeben (Hex-Format)',
            hintText: 'z.B. 01 02 03',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Schreiben'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      try {
        // Parse hex string to bytes
        final bytes = controller.text
            .split(' ')
            .map((s) => int.parse(s, radix: 16))
            .toList();
        await provider.writeCharacteristic(characteristic, bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daten erfolgreich geschrieben'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Schreiben fehlgeschlagen: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _subscribeToCharacteristic(
    BluetoothCharacteristic characteristic,
    BluetoothProvider provider,
  ) {
    try {
      final stream = provider.subscribeToCharacteristic(characteristic);
      stream.listen((data) {
        if (mounted) {
          _showDataDialog('Benachrichtigungsdaten', data);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Benachrichtigungen abonniert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abonnieren fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDataDialog(String title, List<int> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hex: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}'),
              const SizedBox(height: 8),
              Text('Decimal: ${data.join(', ')}'),
              const SizedBox(height: 8),
              Text('ASCII: ${String.fromCharCodes(data.where((b) => b >= 32 && b <= 126))}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}

