import CryptoKit
import Foundation

// SDK-independent helpers used by `CubeReaderAdapter`. They live outside
// `#if canImport(CubeReader)` so CI compiles and tests them. The mapping of
// CubeReader's own types (states, message classes, error enums) has to stay
// in the adapter because it needs those types.

enum CubeMeasurementUID {
  /// Stable measurement id.
  ///
  /// SwiftData's `PersistentIdentifier` can change from a temporary to a
  /// permanent id when the context saves, which would make an old
  /// measurement look new to the wrong-measurement guard. The id is
  /// therefore derived from what identifies a Cube measurement: device
  /// serial, device timestamp (ms), configuration name, lot and vendor. If
  /// two rows ever share the id, the bridge treats it as ambiguous and fails
  /// closed. The id is hashed so that it does not expose the serial.
  static func make(
    deviceSerial: String,
    deviceDate: Date,
    configurationName: String,
    configurationLotNumber: String,
    configurationVendor: String
  ) -> String {
    let millis = Int64((deviceDate.timeIntervalSince1970 * 1000).rounded())
    let key = [
      deviceSerial,
      String(millis),
      configurationName,
      configurationLotNumber,
      configurationVendor,
    ].joined(separator: "\u{1F}")
    return "m-" + String(sha256Hex(Data(key.utf8)).prefix(24))
  }

  static func sha256Hex(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }
}

enum CubeSDKValue {
  /// Converts the untyped `InfoMessage.data` to an Int without trapping.
  /// Bool, non-integral or out-of-range numbers and other types give nil.
  static func intValue(_ value: Any?) -> Int? {
    guard let value = value else { return nil }
    if value is Bool { return nil }
    if let v = value as? Int { return v }
    if let v = value as? Int32 { return Int(v) }
    if let v = value as? Int64 { return Int(exactly: v) }
    if let v = value as? UInt { return Int(exactly: v) }
    if let v = value as? UInt16 { return Int(v) }
    if let v = value as? UInt32 { return Int(exactly: v) }
    if let v = value as? Double { return Int(exactly: v) }
    if let v = value as? Float { return Int(exactly: v) }
    return nil
  }
}

/// Creates the real SDK on first use instead of at app launch, so the
/// CubeReader view model (and its Bluetooth permission prompt) only starts
/// when Dart first uses a Cube channel.
@MainActor
final class LazyCubeSDK: CubeSDK {
  private let factory: @MainActor () -> CubeSDK
  private var instance: CubeSDK?

  weak var observer: CubeSDKObserver? {
    didSet { instance?.observer = observer }
  }

  init(factory: @escaping @MainActor () -> CubeSDK) {
    self.factory = factory
  }

  var isCreated: Bool { instance != nil }

  private var sdk: CubeSDK {
    if let existing = instance {
      return existing
    }
    let created = factory()
    created.observer = observer
    instance = created
    return created
  }

  var isAvailable: Bool { sdk.isAvailable }
  var version: String { sdk.version }
  var licenseValid: Bool { sdk.licenseValid }
  var state: CubeSDKState { sdk.state }
  var devices: [CubeDeviceValue] { sdk.devices }
  var measurements: [CubeMeasurementValue] { sdk.measurements }
  var isConnected: Bool { sdk.isConnected }
  var connectedDeviceSerial: String? { sdk.connectedDeviceSerial }
  var connectedDeviceDate: Date? { sdk.connectedDeviceDate }

  func startScan(timeoutMs: Int) -> Bool { sdk.startScan(timeoutMs: timeoutMs) }
  func stopScan() { sdk.stopScan() }
  func connect(deviceId: String, disableButton: Bool) -> Bool {
    sdk.connect(deviceId: deviceId, disableButton: disableButton)
  }
  func disconnect(shutDown: Bool) { sdk.disconnect(shutDown: shutDown) }
  func startEvaluation(useTimer: Bool, configuration: Data?) -> Bool {
    sdk.startEvaluation(useTimer: useTimer, configuration: configuration)
  }
  func readDeviceDatabase() -> Bool { sdk.readDeviceDatabase() }
  func clearLocalDatabase() { sdk.clearLocalDatabase() }
}
