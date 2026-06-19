import 'package:flutter/material.dart';
import '../utils/app_assets.dart';

/// Phosphor duotone Bluetooth icons from [AppAssets].
class BluetoothAssetIcon extends StatelessWidget {
  final bool enabled;
  final double size;

  const BluetoothAssetIcon({
    super.key,
    this.enabled = true,
    this.size = 96,
  });

  const BluetoothAssetIcon.disabled({super.key, this.size = 96}) : enabled = false;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      enabled ? AppAssets.iconBluetooth : AppAssets.iconBluetoothSlash,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
