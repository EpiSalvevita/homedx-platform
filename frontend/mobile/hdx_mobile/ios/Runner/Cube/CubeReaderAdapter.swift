#if canImport(CubeReader)
import Combine
import CubeReader
import Foundation
import os

/// `CubeSDK` backed by the proprietary CubeReader framework
/// (`CubeViewModel.shared`, iOS 17+).
///
/// Only compiled when CubeReader.xcframework is linked (see
/// ios/CubeSDK/README.md). CI builds without it, so this file is checked by
/// the compiler only on a developer Mac that has the SDK.
///
/// The Combine subscriptions live as long as the adapter. `@Published`
/// emits in `willSet`, so the property on the view model still holds the old
/// value inside a sink: the adapter therefore caches the value the sink
/// receives and updates the cache before notifying the observer. Outside the
/// `$measurements` sink, `measurements` is read live from the view model, so
/// results that SwiftData attaches after the list was published are seen.
@MainActor
final class CubeReaderAdapter: CubeSDK {
  /// The bridge logs only lifecycle information. No result values, serials,
  /// license or configuration contents.
  private let log = Logger(subsystem: "com.homedx.app", category: "HDX_CUBE")
  private let viewModel: CubeViewModel
  private var cancellables = Set<AnyCancellable>()

  private(set) var state: CubeSDKState
  private(set) var devices: [CubeDeviceValue]
  private var cachedMeasurements: [CubeMeasurementValue]
  private var deliveringMeasurements = false

  let isAvailable = true
  weak var observer: CubeSDKObserver?

  /// Matches the Android bridge (300 s). The CubeReader setting is in
  /// minutes (`CubeSettingsKey.autoDisconnectTimeout` documentation).
  private static let autoDisconnectTimeoutMinutes = 5
  private static let licenseResourceName = "cube_license"
  private static let licenseResourceExtension = "dat"
  private static let licenseAttemptKey = "hdx.cube.bundledLicenseAttempt"

  init() {
    let model = CubeViewModel.shared.settings([
      .autoDisconnect: true,
      .autoDisconnectTimeout: CubeReaderAdapter.autoDisconnectTimeoutMinutes,
    ])
    self.viewModel = model
    self.state = CubeReaderAdapter.map(model.state)
    self.devices = model.devices.map { CubeReaderAdapter.map($0) }
    self.cachedMeasurements = model.measurements.map { CubeReaderAdapter.map($0) }
    installBundledLicenseIfNeeded()
    subscribe()
    log.info("CubeReader adapter ready")
  }

  // MARK: - Subscriptions

  private func subscribe() {
    // dropFirst: the initial values were read in init. lastMessage in
    // particular must not replay an old message (e.g. a stale
    // measurementEnd) as if it were new.
    viewModel.$state
      .dropFirst()
      .sink { [weak self] newState in
        guard let self = self else { return }
        let mapped = CubeReaderAdapter.map(newState)
        self.state = mapped
        self.observer?.cubeSDKDidChangeState(mapped)
      }
      .store(in: &cancellables)

    viewModel.$devices
      .dropFirst()
      .sink { [weak self] newDevices in
        guard let self = self else { return }
        let mapped = newDevices.map { CubeReaderAdapter.map($0) }
        self.devices = mapped
        self.observer?.cubeSDKDidUpdateDevices(mapped)
      }
      .store(in: &cancellables)

    viewModel.$measurements
      .dropFirst()
      .sink { [weak self] newMeasurements in
        guard let self = self else { return }
        let mapped = newMeasurements.map { CubeReaderAdapter.map($0) }
        self.cachedMeasurements = mapped
        // Inside willSet the view model still returns the old list.
        self.deliveringMeasurements = true
        defer { self.deliveringMeasurements = false }
        self.observer?.cubeSDKDidUpdateMeasurements(mapped)
      }
      .store(in: &cancellables)

    viewModel.$lastMessage
      .dropFirst()
      .sink { [weak self] message in
        guard let self = self, let message = message else { return }
        guard let mapped = CubeReaderAdapter.map(message) else { return }
        self.observer?.cubeSDKDidReceive(mapped)
      }
      .store(in: &cancellables)
  }

  // MARK: - License

  /// Adds the bundled `cube_license.dat` (copied into the app bundle by the
  /// CubeReader pod) unless a valid license is already stored. The same
  /// file is offered to the SDK only once, so a rejected or expired file is
  /// not inserted again on every launch.
  private func installBundledLicenseIfNeeded() {
    if hasValidLicense() {
      log.info("license: valid license already stored")
      return
    }
    guard let url = Bundle.main.url(
      forResource: CubeReaderAdapter.licenseResourceName,
      withExtension: CubeReaderAdapter.licenseResourceExtension
    ), let data = try? Data(contentsOf: url), !data.isEmpty else {
      log.error("license: bundled cube_license.dat not found")
      return
    }
    let fingerprint = CubeMeasurementUID.sha256Hex(data)
    let defaults = UserDefaults.standard
    if defaults.string(forKey: CubeReaderAdapter.licenseAttemptKey) == fingerprint {
      log.error("license: bundled file was already offered and is not valid")
      return
    }
    defaults.set(fingerprint, forKey: CubeReaderAdapter.licenseAttemptKey)
    let accepted = viewModel.addLicense(data)
    log.info("license: bundled file accepted=\(accepted, privacy: .public)")
  }

  private func hasValidLicense() -> Bool {
    let model = viewModel
    return model.licenses.contains { model.isLicenseValid($0) }
  }

  // MARK: - CubeSDK

  var version: String { viewModel.getVersion() }

  var measurements: [CubeMeasurementValue] {
    if deliveringMeasurements {
      return cachedMeasurements
    }
    return viewModel.measurements.map { CubeReaderAdapter.map($0) }
  }
  var licenseValid: Bool { hasValidLicense() }
  var isConnected: Bool { viewModel.isConnected }
  var connectedDeviceSerial: String? { viewModel.connectedDevice?.deviceSerial }
  var connectedDeviceDate: Date? { viewModel.connectedDevice?.lastDeviceDate }

  func startScan(timeoutMs: Int) -> Bool {
    // CubeReader's timeout is in milliseconds, like the Dart argument.
    viewModel.startScan(timeout: Double(timeoutMs))
  }

  func stopScan() {
    viewModel.stopScan()
  }

  func connect(deviceId: String, disableButton: Bool) -> Bool {
    guard let device = viewModel.devices.first(where: { $0.id.uuidString == deviceId }) else {
      log.error("connect: device no longer in scan list")
      return false
    }
    viewModel.setSetting(forKey: .disableButtonOnConnect, value: disableButton)
    return viewModel.connectDevice(device)
  }

  func disconnect(shutDown: Bool) {
    viewModel.setSetting(forKey: .shutdownOnDisconnect, value: shutDown)
    guard let device = viewModel.connectedDevice else {
      log.info("disconnect: no connected device")
      return
    }
    viewModel.disconnectDevice(device)
  }

  func startEvaluation(useTimer: Bool, configuration: Data?) -> Bool {
    viewModel.startEvaluation(withTimer: useTimer, testConfiguration: configuration)
  }

  func readDeviceDatabase() -> Bool {
    viewModel.readDeviceDatabase()
  }

  func clearLocalDatabase() {
    viewModel.clearLocalDatabase()
  }

  // MARK: - Mapping

  private static func map(_ state: CubeState) -> CubeSDKState {
    switch state {
    case .disconnected: return .disconnected
    case .scanning: return .scanning
    case .connecting: return .connecting
    case .unlocking: return .unlocking
    case .idle: return .idle
    case .writingTestconfig: return .writingTestconfig
    case .evaluating: return .evaluating
    case .readingResults: return .readingResults
    case .locking: return .locking
    case .disconnecting: return .disconnecting
    case .readingDB: return .readingDB
    case .clearingDB: return .clearingDB
    @unknown default: return .unknown
    }
  }

  private static func map(_ device: Device) -> CubeDeviceValue {
    let commType: String
    switch device.commType {
    case .bluetooth: commType = "BLUETOOTH_LE"
    case .ftdi: commType = "FTDI"
    @unknown default: commType = ""
    }
    return CubeDeviceValue(id: device.id.uuidString, name: device.name, commType: commType)
  }

  private static func map(_ measurement: CubeReader.Measurement) -> CubeMeasurementValue {
    let results = measurement.results.map { (r: CubeReader.Measurement.Result) -> CubeResultValue in
      CubeResultValue(
        index: r.index,
        name: r.name,
        formatted: r.formatted,
        unit: r.unit,
        resultClass: r.resultClass,
        isValid: r.isValid
      )
    }
    return CubeMeasurementValue(
      uid: CubeMeasurementUID.make(
        deviceSerial: measurement.deviceSerial,
        deviceDate: measurement.deviceDate,
        configurationName: measurement.configurationName,
        configurationLotNumber: measurement.configurationLotNumber,
        configurationVendor: measurement.configurationVendor
      ),
      deviceSerial: measurement.deviceSerial,
      deviceDate: measurement.deviceDate,
      temperature: Double(measurement.deviceTemperature),
      cfgName: measurement.configurationName,
      cfgLotNr: measurement.configurationLotNumber,
      results: results
    )
  }

  private static func map(_ message: CubeReader.Message) -> CubeSDKMessage? {
    if let info = message as? InfoMessage {
      let kind: CubeInfoKind
      switch info.infoType {
      case .generic: kind = .generic
      case .measurementStart: kind = .measurementStart
      case .measurementConfigWrite: kind = .measurementConfigWrite
      case .measurementProgress: kind = .measurementProgress
      case .measurementRead: kind = .measurementRead
      case .measurementEnd: kind = .measurementEnd
      case .databaseFormatted: kind = .databaseFormatted
      @unknown default: kind = .generic
      }
      return .info(kind, numericData: CubeSDKValue.intValue(info.data))
    }
    if let success = message as? SuccessMessage {
      let kind: CubeSuccessKind
      switch success.successType {
      case .generic: kind = .generic
      case .connected: kind = .connected
      case .disconnected: kind = .disconnected
      case .DBRead: kind = .dbRead
      case .DBCleared: kind = .dbCleared
      @unknown default: kind = .generic
      }
      return .success(kind)
    }
    if let failure = message as? ErrorMessage {
      return .error(errorKind(failure.error))
    }
    // WarningMessage, ProgressMessage and plain messages are not part of
    // the Flutter contract.
    return nil
  }

  private static func errorKind(_ error: Error) -> CubeErrorKind {
    if let deviceError = error as? DeviceError {
      return .device(code: deviceError.rawValue)
    }
    if error is CommunicationError {
      return .communication
    }
    if let requestError = error as? RequestError {
      return requestError == .timeoutReached ? .timeout : .other
    }
    if error is LicenseError {
      return .license
    }
    if error is TestConfigError {
      return .testConfig
    }
    return .other
  }
}
#endif
