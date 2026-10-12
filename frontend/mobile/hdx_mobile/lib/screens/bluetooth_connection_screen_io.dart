import '../config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../providers/bluetooth_provider_mobile.dart';
import '../widgets/figma_ui.dart';
import '../widgets/bluetooth_icon.dart';
import 'bluetooth_scan_screen.dart';
import '../l10n/l10n_ext.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  State<BluetoothConnectionScreen> createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: const FigmaBackHeader(title: 'Bluetooth'),
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
                  const BluetoothAssetIcon(size: 48),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.btConnected,
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
                        : context.l10n.btUnknownDevice,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${device.remoteId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Services Section
          if (provider.services.isNotEmpty) ...[
            Text(
              context.l10n.btServices,
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
                                    tooltip: context.l10n.btRead,
                                  ),
                                if (characteristic.properties.write ||
                                    characteristic.properties.writeWithoutResponse)
                                  IconButton(
                                    icon: const Icon(Icons.upload),
                                    onPressed: () => _writeCharacteristic(
                                      characteristic,
                                      provider,
                                    ),
                                    tooltip: context.l10n.btWrite,
                                  ),
                                if (characteristic.properties.notify ||
                                    characteristic.properties.indicate)
                                  IconButton(
                                    icon: const Icon(Icons.notifications),
                                    onPressed: () => _subscribeToCharacteristic(
                                      characteristic,
                                      provider,
                                    ),
                                    tooltip: context.l10n.btSubscribe,
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
            icon: const BluetoothAssetIcon.disabled(size: 24),
            label: Text(context.l10n.btDisconnect),
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
            const BluetoothAssetIcon.disabled(size: 80),
            const SizedBox(height: 24),
            Text(
              context.l10n.btNoDeviceConnected,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.btSearchPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textColorSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToScan(provider),
              icon: const BluetoothAssetIcon(size: 24),
              label: Text(context.l10n.btSearchDevices),
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
        title: Text(context.l10n.btDisconnectTitle),
        content: Text(context.l10n.btDisconnectConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.btDisconnect),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.disconnect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.btDisconnected),
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
        _showDataDialog(context.l10n.btReadData, data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.btReadFailed(e.toString())),
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
        title: Text(context.l10n.btWriteDataTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: context.l10n.btHexInputLabel,
            hintText: context.l10n.btHexInputHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.btWrite),
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
            SnackBar(
              content: Text(context.l10n.btWriteSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.btWriteFailed(e.toString())),
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
          _showDataDialog(context.l10n.btNotificationData, data);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.btSubscribed),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.btSubscribeFailed(e.toString())),
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
            child: Text(context.l10n.btClose),
          ),
        ],
      ),
    );
  }
}

