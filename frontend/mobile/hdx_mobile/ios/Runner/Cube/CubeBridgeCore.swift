import Foundation
import os

// Channel-independent core of the iOS Cube bridge.
//
// It implements the contract of the Android bridge
// (android/app/src/main/kotlin/com/homedx/app/CubeAnalysisMethodChannel.kt)
// so that lib/features/cube/cube_service.dart runs unchanged on iOS.
// `CubeBridge` (CubeBridge.swift) only connects this class to the Flutter
// method and event channels, which keeps everything here testable without a
// FlutterEngine (see RunnerTests/CubeBridgeTests.swift).
//
// Regulatory note (IVDR/MDR scope): this code transports Cube results. It
// never interprets them. `class` is passed through verbatim, `value` is the
// SDK's formatted string, and anything missing or ambiguous fails closed
// (empty list, `false`, an error code or an MT_ERROR event). Logs contain
// method, state and message names, counts and indices only: no result
// values, classes, device serials, license or configuration contents.

/// What a method call returns to Flutter.
enum CubeMethodOutcome {
  case success(Any?)
  case error(code: String, message: String)
  case notImplemented
}

/// `PlatformException.code` values. The first three match the Kotlin bridge.
enum CubeBridgeErrorCode {
  static let invalidArgs = "invalid_args"
  static let missingAsset = "missing_asset"
  static let openFailed = "open_failed"
  /// iOS build without CubeReader.xcframework.
  static let sdkUnavailable = "sdk_unavailable"
  /// `selectMeasurement` asked for a measurement other than the one the
  /// current evaluation produced (wrong-measurement guard).
  static let measurementMismatch = "measurement_mismatch"
}

/// MT_INFO codes and names as cube_sdk_messages.dart decodes them
/// (cubelib `MessageData.EInfoMessage`). Dart maps `infoMessage` back to the
/// code, so code and name must always agree.
struct CubeInfoMessageCode: Equatable {
  let code: Int
  let name: String

  static let connectionEstablished = CubeInfoMessageCode(code: 1, name: "IM_CONNECTION_ESTABLISHED")
  static let deviceDisconnected = CubeInfoMessageCode(code: 2, name: "IM_DEVICE_DISCONNECTED")
  static let timerRunning = CubeInfoMessageCode(code: 5, name: "IM_TIMER_RUNNING")
  static let evaluationRunning = CubeInfoMessageCode(code: 6, name: "IM_EVALUATION_RUNNING")
  static let evaluationReadData = CubeInfoMessageCode(code: 7, name: "IM_EVALUATION_READ_DATA")
  static let measurementDone = CubeInfoMessageCode(code: 8, name: "IM_MEASUREMENT_DONE")
  static let measureCount = CubeInfoMessageCode(code: 9, name: "IM_MEASURE_COUNT")
  static let dbFormatted = CubeInfoMessageCode(code: 10, name: "IM_DB_FORMATTED")
}

/// Reads a resource from the app bundle (`ios/CubeSDK/assets/*` is copied
/// there by the CubeReader pod). Empty files count as missing.
func cubeBundledResourceData(named name: String) -> Data? {
  let path = name as NSString
  let directory = path.deletingLastPathComponent
  let file = path.lastPathComponent
  guard !file.isEmpty,
        let url = Bundle.main.url(
          forResource: file,
          withExtension: nil,
          subdirectory: directory.isEmpty ? nil : directory
        ),
        let data = try? Data(contentsOf: url),
        !data.isEmpty
  else { return nil }
  return data
}

/// Reads a file from the local file system. Unreadable or empty files count
/// as missing.
func cubeFileData(atPath path: String) -> Data? {
  guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)), !data.isEmpty else {
    return nil
  }
  return data
}

@MainActor
final class CubeBridgeCore: CubeSDKObserver {
  typealias EventSink = ([String: Any]) -> Void

  /// Same default asset name as the Kotlin bridge.
  static let defaultConfigAsset = "cube_test_config.bin"
  static let defaultScanTimeoutMs = 5000
  /// MT_ERROR code emitted by the wrong-measurement guard. It is outside the
  /// SDK's 0x00-0x06 range, so Dart shows its generic "Cube-Messung
  /// abgebrochen (SDK-Fehlercode 99, Zusatz n)" text, where n is the number
  /// of candidate measurements the guard found.
  static let measurementGuardErrorCode = 99

  private static let knownMethods: Set<String> = [
    "getVersion", "licenseValid", "getState", "startScan", "stopScan",
    "connectDevice", "disconnectDevice", "isConnected", "startEvaluation",
    "readDeviceDatabase", "selectMeasurement", "getMeasurements", "getResults",
    "clearLocalDatabase",
  ]

  private static let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  /// Bookkeeping for one `startEvaluation` call (wrong-measurement guard).
  private struct EvaluationSession {
    /// uids of all measurements that existed before the evaluation started.
    let snapshot: Set<String>
    let useTimer: Bool
    /// uid of the one measurement this evaluation produced, once identified.
    var pinnedUid: String?
    /// Last index reported to Dart with IM_MEASUREMENT_DONE.
    var reportedIndex: Int?
    /// measurementEnd arrived before the new measurement was in the list.
    var awaitingMeasurement = false
    /// The guard or the SDK reported an error. Nothing may be selected.
    var failed = false
  }

  private enum Identification {
    case found(index: Int)
    case none
    case ambiguous(count: Int)
  }

  private let sdk: CubeSDK
  private let loadBundledResource: (String) -> Data?
  private let readFile: (String) -> Data?
  private let log = Logger(subsystem: "com.homedx.app", category: "HDX_CUBE")

  private var sink: EventSink?
  /// The device list last sent to Flutter. `connectDevice{index}` resolves
  /// against exactly this list, so an index always means what Dart saw.
  private var deviceSnapshot: [CubeDeviceValue]
  private var selectedUid: String?
  private var session: EvaluationSession?

  init(
    sdk: CubeSDK,
    loadBundledResource: @escaping (String) -> Data?,
    readFile: @escaping (String) -> Data?
  ) {
    self.sdk = sdk
    self.loadBundledResource = loadBundledResource
    self.readFile = readFile
    self.deviceSnapshot = sdk.devices
    // The core observes the SDK for its whole lifetime, independent of
    // Flutter listeners: the wrong-measurement guard must see every
    // message even if Dart re-subscribes in the middle of a run.
    // Flutter listen/cancel only attach/detach the event sink.
    sdk.observer = self
  }

  // MARK: - Event channel

  var isListening: Bool { sink != nil }

  /// Called from `onListen`. A second call without `stopListening` replaces
  /// the sink instead of adding one, so events are never delivered twice.
  func startListening(_ newSink: @escaping EventSink) {
    log.info("event sink attached (replacing=\(self.sink != nil, privacy: .public))")
    sink = newSink
    emitSnapshot()
  }

  /// Called from `onCancel`.
  func stopListening() {
    log.info("event sink detached")
    sink = nil
  }

  /// Re-sends the current state, devices, measurement count and the
  /// selected measurement's results, like LiveData does for a new observer
  /// on Android.
  private func emitSnapshot() {
    emitState(sdk.state)
    deviceSnapshot = sdk.devices
    emitDevices(deviceSnapshot)
    emit(["type": "measurements", "count": sdk.measurements.count])
    if let results = selectedResults() {
      emitResults(results)
    }
  }

  // MARK: - Method channel

  func handle(method: String, arguments: Any?) -> CubeMethodOutcome {
    log.info("method \(method, privacy: .public)")
    let args = arguments as? [String: Any] ?? [:]

    switch method {
    case "getVersion":
      return .success(sdk.version)
    case "licenseValid":
      return .success(sdk.licenseValid)
    default:
      break
    }

    guard Self.knownMethods.contains(method) else {
      return .notImplemented
    }
    guard sdk.isAvailable else {
      return .error(
        code: CubeBridgeErrorCode.sdkUnavailable,
        message: "This iOS build does not include the Cube SDK"
      )
    }

    switch method {
    case "getState":
      return .success(Self.stateName(sdk.state))

    case "startScan":
      let timeoutMs = Self.intArg(args, "timeoutMs") ?? Self.defaultScanTimeoutMs
      return .success(sdk.startScan(timeoutMs: timeoutMs))

    case "stopScan":
      sdk.stopScan()
      return .success(nil)

    case "connectDevice":
      guard let index = Self.intArg(args, "index") else {
        return Self.invalidArgs("index is required")
      }
      let disableButton = Self.boolArg(args, "disableButton") ?? false
      guard index >= 0, index < deviceSnapshot.count else {
        log.error("connectDevice index out of range (\(index, privacy: .public)/\(self.deviceSnapshot.count, privacy: .public))")
        return Self.invalidArgs("Device index out of range")
      }
      return .success(sdk.connect(deviceId: deviceSnapshot[index].id, disableButton: disableButton))

    case "disconnectDevice":
      sdk.disconnect(shutDown: Self.boolArg(args, "shutDown") ?? false)
      return .success(nil)

    case "isConnected":
      return .success(sdk.isConnected)

    case "startEvaluation":
      return startEvaluation(args)

    case "readDeviceDatabase":
      return .success(sdk.readDeviceDatabase())

    case "selectMeasurement":
      return selectMeasurement(args)

    case "getMeasurements":
      let ordered = orderedMeasurements()
      let rows: [[String: Any]] = ordered.enumerated().map { (index: Int, m: CubeMeasurementValue) -> [String: Any] in
        return [
          "index": index,
          "uid": m.uid,
          "deviceSerial": m.deviceSerial,
          "dateTime": Self.dateFormatter.string(from: m.deviceDate),
          "temperature": m.temperature,
          "cfgName": m.cfgName,
          "cfgLotNr": m.cfgLotNr,
        ]
      }
      return .success(rows)

    case "getResults":
      return .success(Self.resultPayloads(selectedResults() ?? []))

    case "clearLocalDatabase":
      sdk.clearLocalDatabase()
      selectedUid = nil
      session = nil
      return .success(nil)

    default:
      return .notImplemented
    }
  }

  /// Config source priority matches Kotlin: configUri, then
  /// configAbsolutePath, then configAssetName / requireBundledConfig,
  /// otherwise RFID (nil configuration).
  private func startEvaluation(_ args: [String: Any]) -> CubeMethodOutcome {
    let useTimer = Self.boolArg(args, "useTimer") ?? false
    let configUri = Self.stringArg(args, "configUri")
    let configPath = Self.stringArg(args, "configAbsolutePath")
    let assetName = Self.stringArg(args, "configAssetName")
    let requireAsset = Self.boolArg(args, "requireBundledConfig") ?? false

    let configuration: Data?
    let source: String
    if configUri != nil {
      // Android content:// URIs have no iOS equivalent. Fail instead of
      // silently falling back to RFID.
      return .error(code: CubeBridgeErrorCode.openFailed, message: "configUri is not supported on iOS")
    } else if let configPath = configPath {
      guard let data = readFile(configPath) else {
        log.error("startEvaluation: config path unreadable")
        return .error(code: CubeBridgeErrorCode.openFailed, message: "Cube config path missing or unreadable")
      }
      configuration = data
      source = "path"
    } else if assetName != nil || requireAsset {
      let name = assetName ?? Self.defaultConfigAsset
      guard let data = loadBundledResource(name) else {
        log.error("startEvaluation: config asset missing")
        return .error(code: CubeBridgeErrorCode.missingAsset, message: "Cube config asset not found: \(name)")
      }
      configuration = data
      source = "asset"
    } else {
      configuration = nil
      source = "rfid"
    }

    // Wrong-measurement guard, step 1: remember which measurements already
    // exist. Results of an earlier selection must not leak into this run.
    selectedUid = nil
    session = EvaluationSession(
      snapshot: Set(sdk.measurements.map { $0.uid }),
      useTimer: useTimer
    )
    let ok = sdk.startEvaluation(useTimer: useTimer, configuration: configuration)
    log.info("startEvaluation source=\(source, privacy: .public) useTimer=\(useTimer, privacy: .public) ok=\(ok, privacy: .public)")
    return .success(ok)
  }

  private func selectMeasurement(_ args: [String: Any]) -> CubeMethodOutcome {
    guard let index = Self.intArg(args, "index") else {
      return Self.invalidArgs("index is required")
    }
    let ordered = orderedMeasurements()
    guard index >= 0, index < ordered.count else {
      log.error("selectMeasurement index out of range (\(index, privacy: .public)/\(ordered.count, privacy: .public))")
      return Self.invalidArgs("Measurement index out of range")
    }
    let measurement = ordered[index]
    // Wrong-measurement guard, step 3: after startEvaluation only the
    // measurement identified for that evaluation may be selected. This
    // also blocks Dart's "last item" fallback when no index was reported.
    if let current = session, current.failed || current.pinnedUid != measurement.uid {
      log.error("selectMeasurement rejected: not the measurement of the current evaluation")
      return .error(
        code: CubeBridgeErrorCode.measurementMismatch,
        message: "Selected measurement does not belong to the current evaluation"
      )
    }
    selectedUid = measurement.uid
    log.info("selectMeasurement index=\(index, privacy: .public) results=\(measurement.results.count, privacy: .public)")
    emitResults(measurement.results)
    return .success(true)
  }

  // MARK: - SDK observer

  func cubeSDKDidChangeState(_ state: CubeSDKState) {
    let name = Self.stateName(state)
    log.info("state \(name, privacy: .public)")
    emitState(state)
  }

  func cubeSDKDidUpdateDevices(_ devices: [CubeDeviceValue]) {
    log.info("devices count=\(devices.count, privacy: .public)")
    deviceSnapshot = devices
    emitDevices(devices)
  }

  func cubeSDKDidUpdateMeasurements(_ measurements: [CubeMeasurementValue]) {
    log.info("measurements count=\(measurements.count, privacy: .public)")
    emit(["type": "measurements", "count": measurements.count])
    handleMeasurementsUpdated()
  }

  func cubeSDKDidReceive(_ message: CubeSDKMessage) {
    switch message {
    case let .info(kind, numericData):
      switch kind {
      case .measurementStart, .measurementConfigWrite:
        emitInfo(.evaluationRunning, data: 0)
      case .measurementProgress:
        // A timed evaluation reports the countdown as IM_TIMER_RUNNING with
        // the remaining seconds, like the Android SDK. Without a timer, or
        // without a numeric payload, it is plain evaluation progress.
        if session?.useTimer == true, let seconds = numericData, seconds >= 0 {
          emitInfo(.timerRunning, data: seconds)
        } else {
          emitInfo(.evaluationRunning, data: 0)
        }
      case .measurementRead:
        emitInfo(.evaluationReadData, data: 0)
      case .measurementEnd:
        handleMeasurementEnd()
      case .databaseFormatted:
        emitInfo(.dbFormatted, data: 0)
      case .generic:
        break
      }

    case let .success(kind):
      switch kind {
      case .connected:
        emitInfo(.connectionEstablished, data: 0)
      case .disconnected:
        emitInfo(.deviceDisconnected, data: 0)
      case .dbRead:
        handleDatabaseRead()
      case .dbCleared:
        emitInfo(.dbFormatted, data: 0)
      case .generic:
        break
      }

    case let .error(kind):
      let mapped = Self.errorCode(for: kind)
      if session != nil {
        // Any SDK error ends the evaluation for selection purposes. Dart
        // fails the run on every MT_ERROR anyway.
        session?.failed = true
      }
      emitError(code: mapped.code, data: mapped.data)
    }
  }

  // MARK: - Wrong-measurement guard
  //
  // ISO 14971: the highest-severity failure of this bridge is attaching a
  // different measurement's result to the current run. The iOS SDK does not
  // say which stored measurement an evaluation produced, so the bridge
  // works it out:
  //   1. startEvaluation snapshots the uids of all stored measurements.
  //   2. On measurementEnd, on later list updates and on DBRead, the bridge
  //      looks for measurements that are not in the snapshot. Exactly one
  //      must exist. Its index, in getMeasurements order (deviceDate
  //      ascending, uid as tie-break), is sent as IM_MEASUREMENT_DONE
  //      msgData and the uid is pinned. Zero (by DBRead) or several
  //      candidates emit MT_ERROR code 99 instead. The bridge never guesses.
  //   3. selectMeasurement only accepts the pinned measurement (see above).
  // If measurementEnd arrives before the SDK has published the new
  // measurement, the decision is deferred to the next list update or, at
  // the latest, to DBRead, where zero candidates is an error. If a DB read
  // adds older measurements and the pinned index shifts, IM_MEASUREMENT_DONE
  // is sent again with the new index before IM_MEASURE_COUNT, so the index
  // Dart selects always points at the pinned measurement.

  private func handleMeasurementEnd() {
    guard session != nil else {
      // Not started through this bridge: nothing to attribute it to.
      log.error("measurementEnd without startEvaluation")
      emitGuardError(candidates: 0)
      return
    }
    switch identifyEvaluationMeasurement() {
    case let .found(index):
      emitInfo(.measurementDone, data: index)
    case .none:
      log.info("measurementEnd: new measurement not yet listed, deferring")
      session?.awaitingMeasurement = true
    case let .ambiguous(count):
      failEvaluation(candidates: count)
    }
  }

  private func handleMeasurementsUpdated() {
    guard let current = session, !current.failed else { return }
    if current.pinnedUid != nil {
      let previousIndex = current.reportedIndex
      if case let .found(index) = identifyEvaluationMeasurement(), index != previousIndex {
        log.info("pinned measurement moved to index \(index, privacy: .public)")
        emitInfo(.measurementDone, data: index)
      }
      return
    }
    guard current.awaitingMeasurement else { return }
    switch identifyEvaluationMeasurement() {
    case let .found(index):
      session?.awaitingMeasurement = false
      emitInfo(.measurementDone, data: index)
    case .none:
      break
    case let .ambiguous(count):
      failEvaluation(candidates: count)
    }
  }

  private func handleDatabaseRead() {
    guard session != nil else {
      emitInfo(.measureCount, data: sdk.measurements.count)
      return
    }
    switch identifyEvaluationMeasurement() {
    case let .found(index):
      emitInfo(.measurementDone, data: index)
      emitInfo(.measureCount, data: sdk.measurements.count)
    case .none:
      failEvaluation(candidates: 0)
    case let .ambiguous(count):
      failEvaluation(candidates: count)
    }
  }

  private func identifyEvaluationMeasurement() -> Identification {
    guard var current = session, !current.failed else { return .none }
    let ordered = orderedMeasurements()
    let candidates: [Int]
    if let pinned = current.pinnedUid {
      candidates = ordered.indices.filter { ordered[$0].uid == pinned }
    } else {
      candidates = ordered.indices.filter { !current.snapshot.contains(ordered[$0].uid) }
    }
    guard candidates.count == 1 else {
      log.info("guard candidates=\(candidates.count, privacy: .public)")
      return candidates.isEmpty ? .none : .ambiguous(count: candidates.count)
    }
    let index = candidates[0]
    current.pinnedUid = ordered[index].uid
    current.reportedIndex = index
    session = current
    log.info("guard identified measurement index=\(index, privacy: .public)")
    return .found(index: index)
  }

  private func failEvaluation(candidates: Int) {
    log.error("guard failed, candidates=\(candidates, privacy: .public)")
    session?.awaitingMeasurement = false
    session?.pinnedUid = nil
    session?.failed = true
    emitGuardError(candidates: candidates)
  }

  // MARK: - Mapping helpers

  /// getMeasurements order: deviceDate ascending, uid as a deterministic
  /// tie-break, so indices do not depend on the SDK's array order.
  private func orderedMeasurements() -> [CubeMeasurementValue] {
    sdk.measurements.sorted { a, b in
      if a.deviceDate != b.deviceDate {
        return a.deviceDate < b.deviceDate
      }
      return a.uid < b.uid
    }
  }

  /// Results of the selected measurement, or nil if nothing is selected or
  /// the selected measurement is gone or no longer unique.
  private func selectedResults() -> [CubeResultValue]? {
    guard let uid = selectedUid else { return nil }
    let matches = sdk.measurements.filter { $0.uid == uid }
    guard matches.count == 1 else { return nil }
    return matches[0].results
  }

  /// Result rows in the Kotlin shape, sorted by the configuration's index.
  /// `class` is verbatim. `validity` is an Int (0 valid, 3 invalid, the
  /// Cube `CL_GetResultValidity` codes), never a Bool: Dart maps Bool true
  /// to 1 ("Kein Wert").
  static func resultPayloads(_ results: [CubeResultValue]) -> [[String: Any]] {
    results.sorted { $0.index < $1.index }.map { (r: CubeResultValue) -> [String: Any] in
      let validity: Int = r.isValid ? 0 : 3
      return [
        "name": r.name,
        "value": r.formatted,
        "unit": r.unit,
        "class": r.resultClass,
        "validity": validity,
      ]
    }
  }

  static func stateName(_ state: CubeSDKState) -> String {
    switch state {
    case .disconnected:
      return "ST_DISCONNECTED"
    case .scanning:
      return "ST_SCAN"
    case .connecting, .unlocking:
      return "ST_CONNECTING"
    case .idle:
      return "ST_IDLE"
    case .writingTestconfig, .evaluating:
      return "ST_EVALUATE"
    case .readingResults, .readingDB:
      return "ST_READ"
    case .locking, .clearingDB, .disconnecting, .unknown:
      return "ST_DEVICE_BUSY"
    }
  }

  /// MT_ERROR `msgCode` / `msgData` as cube_sdk_messages.dart decodes them.
  static func errorCode(for kind: CubeErrorKind) -> (code: Int, data: Int) {
    switch kind {
    case let .device(code):
      return (1, code)
    case .communication:
      return (2, 0)
    case .timeout:
      return (4, 0)
    case .license:
      return (5, 0)
    case .testConfig:
      return (6, 0)
    case .other:
      return (1, 0)
    }
  }

  // MARK: - Emitters

  private func emit(_ payload: [String: Any]) {
    sink?(payload)
  }

  private func emitState(_ state: CubeSDKState) {
    emit(["type": "state", "state": Self.stateName(state)])
  }

  private func emitDevices(_ devices: [CubeDeviceValue]) {
    let rows: [[String: Any]] = devices.enumerated().map { (index: Int, d: CubeDeviceValue) -> [String: Any] in
      return ["name": d.name, "commType": d.commType, "index": index]
    }
    emit(["type": "devices", "devices": rows])
  }

  private func emitResults(_ results: [CubeResultValue]) {
    emit(["type": "results", "results": Self.resultPayloads(results)])
  }

  private func emitInfo(_ info: CubeInfoMessageCode, data: Int) {
    log.info("message MT_INFO \(info.name, privacy: .public)")
    emit([
      "type": "message",
      "msgType": "MT_INFO",
      "msgCode": info.code,
      "msgData": data,
      "infoMessage": info.name,
    ])
  }

  private func emitError(code: Int, data: Int) {
    log.error("message MT_ERROR code=\(code, privacy: .public) data=\(data, privacy: .public)")
    emit([
      "type": "message",
      "msgType": "MT_ERROR",
      "msgCode": code,
      "msgData": data,
    ])
  }

  private func emitGuardError(candidates: Int) {
    emitError(code: Self.measurementGuardErrorCode, data: candidates)
  }

  // MARK: - Argument parsing

  private static func invalidArgs(_ message: String) -> CubeMethodOutcome {
    .error(code: CubeBridgeErrorCode.invalidArgs, message: message)
  }

  /// Integer argument. Booleans and non-numbers are rejected.
  static func intArg(_ args: [String: Any], _ key: String) -> Int? {
    guard let number = args[key] as? NSNumber else { return nil }
    if CFGetTypeID(number) == CFBooleanGetTypeID() { return nil }
    return number.intValue
  }

  static func boolArg(_ args: [String: Any], _ key: String) -> Bool? {
    args[key] as? Bool
  }

  /// Trimmed, non-empty string argument.
  static func stringArg(_ args: [String: Any], _ key: String) -> String? {
    guard let value = args[key] as? String else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}
