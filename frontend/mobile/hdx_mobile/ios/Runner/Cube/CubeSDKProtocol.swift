import Foundation

// Abstraction over the proprietary CubeReader SDK.
//
// The Flutter bridge (`CubeBridgeCore`) depends only on the types in this
// file. Two implementations exist:
//   * `CubeReaderAdapter` wraps `CubeViewModel.shared` and is compiled only
//     when the vendor framework is present (`#if canImport(CubeReader)`).
//   * `UnavailableCubeSDK` is the fail-closed fallback used when the app is
//     built without the SDK (CI, public checkouts).
// Tests drive the bridge through a fake implementation.
//
// Regulatory note: these are transport types only. They carry the values
// computed by the Cube SDK unchanged (no thresholds, rounding or
// interpretation happen in the app).

/// Mirror of `CubeReader.CubeState`.
enum CubeSDKState: Equatable {
  case disconnected
  case scanning
  case connecting
  case unlocking
  case idle
  case writingTestconfig
  case evaluating
  case readingResults
  case locking
  case disconnecting
  case readingDB
  case clearingDB
  /// A state the SDK reported that this build does not know about.
  case unknown
}

/// A Cube found during a scan.
struct CubeDeviceValue: Equatable {
  /// Stable identifier from the SDK (`Device.id.uuidString`).
  let id: String
  let name: String
  /// Android-compatible name of the transport (`BLUETOOTH_LE`, `FTDI`, or "").
  let commType: String
}

/// One result row of a measurement (`Measurement.Result`).
struct CubeResultValue: Equatable {
  /// Position as defined by the test configuration (starts at 1).
  let index: Int
  let name: String
  /// Value already formatted by the SDK (`Result.formatted`).
  let formatted: String
  let unit: String
  /// Classification string from the SDK (`Result.resultClass`), verbatim.
  let resultClass: String
  let isValid: Bool
}

/// One stored measurement (`CubeReader.Measurement`).
struct CubeMeasurementValue: Equatable {
  /// Stable identifier, unchanged across SDK list updates (see adapter).
  let uid: String
  let deviceSerial: String
  let deviceDate: Date
  let temperature: Double
  let cfgName: String
  let cfgLotNr: String
  let results: [CubeResultValue]
}

/// Mirror of `CubeReader.InfoType`.
enum CubeInfoKind: Equatable {
  case generic
  case measurementStart
  case measurementConfigWrite
  case measurementProgress
  case measurementRead
  case measurementEnd
  case databaseFormatted
}

/// Mirror of `CubeReader.SuccessType`.
enum CubeSuccessKind: Equatable {
  case generic
  case connected
  case disconnected
  case dbRead
  case dbCleared
}

/// Error category of an SDK `ErrorMessage`.
enum CubeErrorKind: Equatable {
  /// `DeviceError` with its raw value.
  case device(code: Int)
  /// `CommunicationError` (any case).
  case communication
  /// `RequestError.timeoutReached`.
  case timeout
  /// `LicenseError` (any case).
  case license
  /// `TestConfigError` (any case).
  case testConfig
  /// Everything else (`CommandError`, `EEPROMError`, other `RequestError`s, unknown).
  case other
}

/// The subset of SDK messages the bridge forwards to Flutter.
enum CubeSDKMessage: Equatable {
  /// `InfoMessage`. `numericData` is `InfoMessage.data` if it is a number.
  case info(CubeInfoKind, numericData: Int?)
  case success(CubeSuccessKind)
  case error(CubeErrorKind)
}

/// Receives SDK updates. Every callback runs on the main actor, after the
/// SDK implementation has updated the values it returns from its getters.
@MainActor
protocol CubeSDKObserver: AnyObject {
  func cubeSDKDidChangeState(_ state: CubeSDKState)
  func cubeSDKDidUpdateDevices(_ devices: [CubeDeviceValue])
  func cubeSDKDidUpdateMeasurements(_ measurements: [CubeMeasurementValue])
  func cubeSDKDidReceive(_ message: CubeSDKMessage)
}

/// Operations the bridge needs from the Cube SDK.
@MainActor
protocol CubeSDK: AnyObject {
  /// False for the fallback build without the vendor framework.
  var isAvailable: Bool { get }
  /// Implementations must hold this weakly.
  var observer: CubeSDKObserver? { get set }

  var version: String { get }
  var licenseValid: Bool { get }
  var state: CubeSDKState { get }
  var devices: [CubeDeviceValue] { get }
  /// Unordered; the bridge defines the order exposed to Flutter.
  var measurements: [CubeMeasurementValue] { get }
  var isConnected: Bool { get }

  func startScan(timeoutMs: Int) -> Bool
  func stopScan()
  /// Connects the device with `CubeDeviceValue.id == deviceId`.
  func connect(deviceId: String, disableButton: Bool) -> Bool
  func disconnect(shutDown: Bool)
  /// `configuration == nil` means the SDK reads the test configuration from RFID.
  func startEvaluation(useTimer: Bool, configuration: Data?) -> Bool
  func readDeviceDatabase() -> Bool
  func clearLocalDatabase()
}
