import 'package:flutter/foundation.dart';

/// Platform-specific feature gates (Cube/Bluetooth require native mobile).
class PlatformCapabilities {
  static bool get canRunCubeTests => !kIsWeb;
}
