import Foundation

/// Fallback used when the app is built without `CubeReader.xcframework`
/// (CI, public checkouts). It fails closed: the license is reported as
/// invalid, so the scan screen stops before scanning, and `CubeBridgeCore`
/// answers every device or measurement call with the `sdk_unavailable` error.
@MainActor
final class UnavailableCubeSDK: CubeSDK {
  let isAvailable = false
  weak var observer: CubeSDKObserver?

  var version: String { "" }
  var licenseValid: Bool { false }
  var state: CubeSDKState { .disconnected }
  var devices: [CubeDeviceValue] { [] }
  var measurements: [CubeMeasurementValue] { [] }
  var isConnected: Bool { false }
  var connectedDeviceSerial: String? { nil }
  var connectedDeviceDate: Date? { nil }

  func startScan(timeoutMs: Int) -> Bool { false }
  func stopScan() {}
  func connect(deviceId: String, disableButton: Bool) -> Bool { false }
  func disconnect(shutDown: Bool) {}
  func startEvaluation(useTimer: Bool, configuration: Data?) -> Bool { false }
  func readDeviceDatabase() -> Bool { false }
  func clearLocalDatabase() {}
}
