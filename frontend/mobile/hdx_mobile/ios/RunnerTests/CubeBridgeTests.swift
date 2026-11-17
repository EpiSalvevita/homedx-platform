import Foundation
import XCTest
@testable import Runner

// Tests for the iOS Cube bridge core (Runner/Cube/CubeBridgeCore.swift).
// They use a fake SDK, so they run in CI without CubeReader.xcframework.
// All data is synthetic.

// MARK: - Fake SDK

@MainActor
final class FakeCubeSDK: CubeSDK {
  var isAvailable = true
  weak var observer: CubeSDKObserver?

  var version = "0.0.0-test"
  var licenseValid = true
  var state: CubeSDKState = .disconnected
  var devices: [CubeDeviceValue] = []
  var measurements: [CubeMeasurementValue] = []
  var isConnected = false

  var startScanResult = true
  var connectResult = true
  var startEvaluationResult = true
  var readDatabaseResult = true

  private(set) var startScanTimeouts: [Int] = []
  private(set) var stopScanCount = 0
  private(set) var connectCalls: [(deviceId: String, disableButton: Bool)] = []
  private(set) var disconnectCalls: [Bool] = []
  private(set) var startEvaluationCalls: [(useTimer: Bool, configuration: Data?)] = []
  private(set) var readDatabaseCount = 0
  private(set) var clearLocalDatabaseCount = 0

  func startScan(timeoutMs: Int) -> Bool {
    startScanTimeouts.append(timeoutMs)
    return startScanResult
  }

  func stopScan() {
    stopScanCount += 1
  }

  func connect(deviceId: String, disableButton: Bool) -> Bool {
    connectCalls.append((deviceId: deviceId, disableButton: disableButton))
    return connectResult
  }

  func disconnect(shutDown: Bool) {
    disconnectCalls.append(shutDown)
  }

  func startEvaluation(useTimer: Bool, configuration: Data?) -> Bool {
    startEvaluationCalls.append((useTimer: useTimer, configuration: configuration))
    return startEvaluationResult
  }

  func readDeviceDatabase() -> Bool {
    readDatabaseCount += 1
    return readDatabaseResult
  }

  func clearLocalDatabase() {
    clearLocalDatabaseCount += 1
    measurements = []
  }

  // Simulated SDK publications (values are updated before the callback,
  // as the real adapter guarantees).

  func publishState(_ newState: CubeSDKState) {
    state = newState
    observer?.cubeSDKDidChangeState(newState)
  }

  func publishDevices(_ newDevices: [CubeDeviceValue]) {
    devices = newDevices
    observer?.cubeSDKDidUpdateDevices(newDevices)
  }

  func publishMeasurements(_ newMeasurements: [CubeMeasurementValue]) {
    measurements = newMeasurements
    observer?.cubeSDKDidUpdateMeasurements(newMeasurements)
  }

  func send(_ message: CubeSDKMessage) {
    observer?.cubeSDKDidReceive(message)
  }
}

/// Holds injected bundle resources and files.
final class FakeStorage {
  var assets: [String: Data] = [:]
  var files: [String: Data] = [:]
  private(set) var requestedAssets: [String] = []

  func asset(_ name: String) -> Data? {
    requestedAssets.append(name)
    return assets[name]
  }
}

@MainActor
final class BridgeHarness {
  let sdk: FakeCubeSDK
  let storage: FakeStorage
  let core: CubeBridgeCore
  var events: [[String: Any]] = []

  init() {
    let sdk = FakeCubeSDK()
    self.sdk = sdk
    let storage = FakeStorage()
    self.storage = storage
    self.core = CubeBridgeCore(
      sdk: sdk,
      loadBundledResource: { name in storage.asset(name) },
      readFile: { path in storage.files[path] }
    )
  }

  func listen() {
    core.startListening { [weak self] payload in
      self?.events.append(payload)
    }
  }

  func call(_ method: String, _ args: [String: Any]? = nil) -> CubeMethodOutcome {
    core.handle(method: method, arguments: args)
  }

  var messages: [[String: Any]] {
    events.filter { $0["type"] as? String == "message" }
  }

  func events(ofType type: String) -> [[String: Any]] {
    events.filter { $0["type"] as? String == type }
  }

  func clearEvents() {
    events.removeAll()
  }
}

// MARK: - Helpers

private let syntheticSerial = "SYN-TEST-0001"

private func measurement(
  _ uid: String,
  at seconds: TimeInterval,
  results: [CubeResultValue] = []
) -> CubeMeasurementValue {
  CubeMeasurementValue(
    uid: uid,
    deviceSerial: syntheticSerial,
    deviceDate: Date(timeIntervalSince1970: seconds),
    temperature: 21.5,
    cfgName: "SYNTH-CFG",
    cfgLotNr: "LOT-TEST",
    results: results
  )
}

private func result(
  index: Int,
  name: String,
  formatted: String = "1.0",
  unit: String = "u",
  resultClass: String,
  isValid: Bool
) -> CubeResultValue {
  CubeResultValue(
    index: index,
    name: name,
    formatted: formatted,
    unit: unit,
    resultClass: resultClass,
    isValid: isValid
  )
}

private func successValue(
  _ outcome: CubeMethodOutcome,
  file: StaticString = #filePath,
  line: UInt = #line
) -> Any? {
  guard case let .success(value) = outcome else {
    XCTFail("expected success, got \(outcome)", file: file, line: line)
    return nil
  }
  return value
}

private func assertErrorCode(
  _ outcome: CubeMethodOutcome,
  _ expected: String,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  guard case let .error(code, _) = outcome else {
    XCTFail("expected error \(expected), got \(outcome)", file: file, line: line)
    return
  }
  XCTAssertEqual(code, expected, file: file, line: line)
}

/// Asserts the dynamic type is exactly Int (never Bool or Double).
private func assertInt(
  _ value: Any?,
  _ expected: Int,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  guard let value = value else {
    XCTFail("expected Int \(expected), got nil", file: file, line: line)
    return
  }
  XCTAssertTrue(type(of: value) == Int.self, "expected Int, got \(type(of: value))", file: file, line: line)
  XCTAssertEqual(value as? Int, expected, file: file, line: line)
}

private func assertInfo(
  _ event: [String: Any]?,
  code: Int,
  name: String,
  data: Int? = nil,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  guard let event = event else {
    XCTFail("missing MT_INFO \(name)", file: file, line: line)
    return
  }
  XCTAssertEqual(event["type"] as? String, "message", file: file, line: line)
  XCTAssertEqual(event["msgType"] as? String, "MT_INFO", file: file, line: line)
  assertInt(event["msgCode"], code, file: file, line: line)
  XCTAssertEqual(event["infoMessage"] as? String, name, file: file, line: line)
  if let data = data {
    assertInt(event["msgData"], data, file: file, line: line)
  } else if let raw = event["msgData"] {
    XCTAssertTrue(type(of: raw) == Int.self, "msgData must be Int", file: file, line: line)
  } else {
    XCTFail("msgData missing", file: file, line: line)
  }
}

private func assertError(
  _ event: [String: Any]?,
  code: Int,
  data: Int,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  guard let event = event else {
    XCTFail("missing MT_ERROR \(code)", file: file, line: line)
    return
  }
  XCTAssertEqual(event["type"] as? String, "message", file: file, line: line)
  XCTAssertEqual(event["msgType"] as? String, "MT_ERROR", file: file, line: line)
  assertInt(event["msgCode"], code, file: file, line: line)
  assertInt(event["msgData"], data, file: file, line: line)
  XCTAssertNil(event["infoMessage"], file: file, line: line)
}

private func infoCodes(_ events: [[String: Any]]) -> [Int] {
  events.compactMap { event in
    event["msgType"] as? String == "MT_INFO" ? event["msgCode"] as? Int : nil
  }
}

// MARK: - Tests

final class CubeBridgeTests: XCTestCase {

  // MARK: State

  @MainActor
  func testStateMappingTable() {
    let table: [(CubeSDKState, String)] = [
      (.disconnected, "ST_DISCONNECTED"),
      (.scanning, "ST_SCAN"),
      (.connecting, "ST_CONNECTING"),
      (.unlocking, "ST_CONNECTING"),
      (.idle, "ST_IDLE"),
      (.writingTestconfig, "ST_EVALUATE"),
      (.evaluating, "ST_EVALUATE"),
      (.readingResults, "ST_READ"),
      (.readingDB, "ST_READ"),
      (.locking, "ST_DEVICE_BUSY"),
      (.clearingDB, "ST_DEVICE_BUSY"),
      (.disconnecting, "ST_DEVICE_BUSY"),
      (.unknown, "ST_DEVICE_BUSY"),
    ]
    for (state, name) in table {
      XCTAssertEqual(CubeBridgeCore.stateName(state), name, "\(state)")
    }
  }

  @MainActor
  func testStateEventsAndGetState() {
    let h = BridgeHarness()
    h.listen()
    h.clearEvents()

    h.sdk.publishState(.evaluating)

    XCTAssertEqual(h.events.count, 1)
    XCTAssertEqual(h.events.first?["type"] as? String, "state")
    XCTAssertEqual(h.events.first?["state"] as? String, "ST_EVALUATE")
    XCTAssertEqual(successValue(h.call("getState")) as? String, "ST_EVALUATE")
  }

  // MARK: Devices

  @MainActor
  func testDevicesEventShapeAndConnectUsesSameSnapshot() {
    let h = BridgeHarness()
    h.listen()
    h.clearEvents()

    h.sdk.publishDevices([
      CubeDeviceValue(id: "dev-a", name: "Cube-A", commType: "BLUETOOTH_LE"),
      CubeDeviceValue(id: "dev-b", name: "Cube-B", commType: "BLUETOOTH_LE"),
    ])

    let event = h.events(ofType: "devices").last
    let rows = event?["devices"] as? [[String: Any]]
    XCTAssertEqual(rows?.count, 2)
    XCTAssertEqual(rows?[1]["name"] as? String, "Cube-B")
    XCTAssertEqual(rows?[1]["commType"] as? String, "BLUETOOTH_LE")
    assertInt(rows?[0]["index"], 0)
    assertInt(rows?[1]["index"], 1)

    XCTAssertEqual(successValue(h.call("connectDevice", ["index": 1, "disableButton": true])) as? Bool, true)
    XCTAssertEqual(h.sdk.connectCalls.count, 1)
    XCTAssertEqual(h.sdk.connectCalls.first?.deviceId, "dev-b")
    XCTAssertEqual(h.sdk.connectCalls.first?.disableButton, true)

    _ = h.call("connectDevice", ["index": 0])
    XCTAssertEqual(h.sdk.connectCalls.last?.deviceId, "dev-a")
    XCTAssertEqual(h.sdk.connectCalls.last?.disableButton, false)
  }

  @MainActor
  func testConnectDeviceInvalidArgs() {
    let h = BridgeHarness()
    h.sdk.publishDevices([CubeDeviceValue(id: "dev-a", name: "Cube-A", commType: "BLUETOOTH_LE")])

    assertErrorCode(h.call("connectDevice", [:]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("connectDevice", nil), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("connectDevice", ["index": 1]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("connectDevice", ["index": -1]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("connectDevice", ["index": "0"]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("connectDevice", ["index": true]), CubeBridgeErrorCode.invalidArgs)
    XCTAssertTrue(h.sdk.connectCalls.isEmpty)
  }

  // MARK: Simple pass-through methods

  @MainActor
  func testScanConnectionAndVersionMethods() {
    let h = BridgeHarness()
    h.sdk.isConnected = true

    XCTAssertEqual(successValue(h.call("getVersion")) as? String, "0.0.0-test")
    XCTAssertEqual(successValue(h.call("licenseValid")) as? Bool, true)
    XCTAssertEqual(successValue(h.call("startScan", ["timeoutMs": 30000])) as? Bool, true)
    XCTAssertEqual(successValue(h.call("startScan")) as? Bool, true)
    XCTAssertEqual(h.sdk.startScanTimeouts, [30000, CubeBridgeCore.defaultScanTimeoutMs])
    XCTAssertNil(successValue(h.call("stopScan")))
    XCTAssertEqual(h.sdk.stopScanCount, 1)
    XCTAssertEqual(successValue(h.call("isConnected")) as? Bool, true)
    XCTAssertNil(successValue(h.call("disconnectDevice", ["shutDown": true])))
    XCTAssertNil(successValue(h.call("disconnectDevice")))
    XCTAssertEqual(h.sdk.disconnectCalls, [true, false])
    XCTAssertEqual(successValue(h.call("readDeviceDatabase")) as? Bool, true)
    XCTAssertEqual(h.sdk.readDatabaseCount, 1)
  }

  @MainActor
  func testUnknownMethodIsNotImplemented() {
    let h = BridgeHarness()
    guard case .notImplemented = h.call("doesNotExist") else {
      return XCTFail("expected notImplemented")
    }
  }

  @MainActor
  func testUnavailableSDKFailsClosed() {
    let core = CubeBridgeCore(
      sdk: UnavailableCubeSDK(),
      loadBundledResource: { _ in nil },
      readFile: { _ in nil }
    )
    XCTAssertEqual(successValue(core.handle(method: "getVersion", arguments: nil)) as? String, "")
    XCTAssertEqual(successValue(core.handle(method: "licenseValid", arguments: nil)) as? Bool, false)
    for method in [
      "getState", "startScan", "stopScan", "connectDevice", "disconnectDevice",
      "isConnected", "startEvaluation", "readDeviceDatabase", "selectMeasurement",
      "getMeasurements", "getResults", "clearLocalDatabase",
    ] {
      assertErrorCode(core.handle(method: method, arguments: ["index": 0]), CubeBridgeErrorCode.sdkUnavailable)
    }
    guard case .notImplemented = core.handle(method: "doesNotExist", arguments: nil) else {
      return XCTFail("expected notImplemented")
    }
  }

  // MARK: Message mapping

  @MainActor
  func testInfoAndSuccessMessageMapping() {
    let h = BridgeHarness()
    h.listen()
    h.clearEvents()

    h.sdk.send(.success(.connected))
    assertInfo(h.messages.last, code: 1, name: "IM_CONNECTION_ESTABLISHED")
    h.sdk.send(.success(.disconnected))
    assertInfo(h.messages.last, code: 2, name: "IM_DEVICE_DISCONNECTED")
    h.sdk.send(.info(.measurementStart, numericData: nil))
    assertInfo(h.messages.last, code: 6, name: "IM_EVALUATION_RUNNING")
    h.sdk.send(.info(.measurementConfigWrite, numericData: nil))
    assertInfo(h.messages.last, code: 6, name: "IM_EVALUATION_RUNNING")
    h.sdk.send(.info(.measurementProgress, numericData: 75))
    assertInfo(h.messages.last, code: 6, name: "IM_EVALUATION_RUNNING", data: 0)
    h.sdk.send(.info(.measurementRead, numericData: nil))
    assertInfo(h.messages.last, code: 7, name: "IM_EVALUATION_READ_DATA")
    h.sdk.send(.info(.databaseFormatted, numericData: nil))
    assertInfo(h.messages.last, code: 10, name: "IM_DB_FORMATTED")
    h.sdk.send(.success(.dbCleared))
    assertInfo(h.messages.last, code: 10, name: "IM_DB_FORMATTED")
    h.sdk.send(.success(.dbRead))
    assertInfo(h.messages.last, code: 9, name: "IM_MEASURE_COUNT")

    let countBefore = h.messages.count
    h.sdk.send(.info(.generic, numericData: 3))
    h.sdk.send(.success(.generic))
    XCTAssertEqual(h.messages.count, countBefore, "generic messages are not forwarded")
  }

  @MainActor
  func testTimerProgressMapsToTimerRunningOnlyForTimedEvaluation() {
    let h = BridgeHarness()
    h.listen()
    _ = h.call("startEvaluation", ["useTimer": true])
    h.clearEvents()

    h.sdk.send(.info(.measurementProgress, numericData: 75))
    assertInfo(h.messages.last, code: 5, name: "IM_TIMER_RUNNING", data: 75)
    h.sdk.send(.info(.measurementProgress, numericData: nil))
    assertInfo(h.messages.last, code: 6, name: "IM_EVALUATION_RUNNING", data: 0)
    h.sdk.send(.info(.measurementProgress, numericData: -1))
    assertInfo(h.messages.last, code: 6, name: "IM_EVALUATION_RUNNING", data: 0)

    _ = h.call("startEvaluation", ["useTimer": false])
    h.sdk.send(.info(.measurementProgress, numericData: 75))
    assertInfo(h.messages.last, code: 6, name: "IM_EVALUATION_RUNNING", data: 0)
  }

  @MainActor
  func testErrorCategoryMapping() {
    let h = BridgeHarness()
    h.listen()
    h.clearEvents()

    h.sdk.send(.error(.device(code: 0x91)))
    assertError(h.messages.last, code: 1, data: 0x91)
    h.sdk.send(.error(.communication))
    assertError(h.messages.last, code: 2, data: 0)
    h.sdk.send(.error(.timeout))
    assertError(h.messages.last, code: 4, data: 0)
    h.sdk.send(.error(.license))
    assertError(h.messages.last, code: 5, data: 0)
    h.sdk.send(.error(.testConfig))
    assertError(h.messages.last, code: 6, data: 0)
    h.sdk.send(.error(.other))
    assertError(h.messages.last, code: 1, data: 0)
  }

  // MARK: Measurements and results

  @MainActor
  func testGetMeasurementsOrderingAndShape() {
    let h = BridgeHarness()
    h.sdk.measurements = [
      measurement("m-c", at: 3000),
      measurement("m-b", at: 1000),
      measurement("m-a", at: 1000),
      measurement("m-d", at: 2000),
    ]

    let rows = successValue(h.call("getMeasurements")) as? [[String: Any]]
    XCTAssertEqual(rows?.map { $0["uid"] as? String }, ["m-a", "m-b", "m-d", "m-c"])
    for (i, row) in (rows ?? []).enumerated() {
      assertInt(row["index"], i)
    }
    let first = rows?.first
    XCTAssertEqual(first?["deviceSerial"] as? String, syntheticSerial)
    XCTAssertEqual(first?["cfgName"] as? String, "SYNTH-CFG")
    XCTAssertEqual(first?["cfgLotNr"] as? String, "LOT-TEST")
    XCTAssertEqual(first?["temperature"] as? Double, 21.5)
    XCTAssertEqual(first?["dateTime"] as? String, "1970-01-01T00:16:40.000Z")
  }

  @MainActor
  func testGetResultsIsEmptyBeforeSelection() {
    let h = BridgeHarness()
    h.sdk.measurements = [
      measurement("m-a", at: 1000, results: [result(index: 1, name: "X", resultClass: "POSITIVE", isValid: true)]),
    ]
    let rows = successValue(h.call("getResults")) as? [[String: Any]]
    XCTAssertEqual(rows?.count, 0)
  }

  @MainActor
  func testSelectMeasurementInvalidArgs() {
    let h = BridgeHarness()
    h.sdk.measurements = [measurement("m-a", at: 1000)]
    assertErrorCode(h.call("selectMeasurement", [:]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("selectMeasurement", ["index": -1]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("selectMeasurement", ["index": 1]), CubeBridgeErrorCode.invalidArgs)
    assertErrorCode(h.call("selectMeasurement", ["index": false]), CubeBridgeErrorCode.invalidArgs)
  }

  /// Full happy path: one new measurement, results with validity as Int
  /// and class passed through verbatim (including empty and unusual values).
  @MainActor
  func testEvaluationFlowReportsNewMeasurementAndVerbatimResults() {
    let h = BridgeHarness()
    let old = measurement("m-old", at: 1000, results: [
      result(index: 1, name: "OLD", resultClass: "NEGATIVE", isValid: true),
    ])
    h.sdk.measurements = [old]
    h.listen()

    XCTAssertEqual(successValue(h.call("startEvaluation", ["useTimer": true])) as? Bool, true)
    XCTAssertEqual(h.sdk.startEvaluationCalls.count, 1)
    XCTAssertNil(h.sdk.startEvaluationCalls.first?.configuration ?? nil)
    h.clearEvents()

    let fresh = measurement("m-new", at: 5000, results: [
      result(index: 3, name: "C", formatted: "n/a", unit: "", resultClass: "", isValid: false),
      result(index: 1, name: "A", formatted: "12.3", unit: "mg/L", resultClass: "Positive ", isValid: true),
      result(index: 2, name: "B", formatted: "<0.5", unit: "mg/L", resultClass: "NEG", isValid: true),
    ])
    h.sdk.publishMeasurements([old, fresh])
    h.sdk.send(.info(.measurementEnd, numericData: nil))
    assertInfo(h.messages.last, code: 8, name: "IM_MEASUREMENT_DONE", data: 1)

    h.sdk.send(.success(.dbRead))
    XCTAssertEqual(infoCodes(Array(h.messages.suffix(2))), [8, 9])
    assertInfo(h.messages[h.messages.count - 2], code: 8, name: "IM_MEASUREMENT_DONE", data: 1)

    XCTAssertEqual(successValue(h.call("selectMeasurement", ["index": 1])) as? Bool, true)

    let rows = successValue(h.call("getResults")) as? [[String: Any]] ?? []
    XCTAssertEqual(rows.map { $0["name"] as? String }, ["A", "B", "C"])
    XCTAssertEqual(rows.map { $0["class"] as? String }, ["Positive ", "NEG", ""])
    XCTAssertEqual(rows.map { $0["value"] as? String }, ["12.3", "<0.5", "n/a"])
    XCTAssertEqual(rows.map { $0["unit"] as? String }, ["mg/L", "mg/L", ""])
    assertInt(rows[0]["validity"], 0)
    assertInt(rows[1]["validity"], 0)
    assertInt(rows[2]["validity"], 3)

    let resultsEvent = h.events(ofType: "results").last
    let eventRows = resultsEvent?["results"] as? [[String: Any]] ?? []
    XCTAssertEqual(eventRows.count, 3)
    assertInt(eventRows[2]["validity"], 3)
    XCTAssertEqual(eventRows[2]["class"] as? String, "")
  }

  // MARK: Wrong-measurement guard

  @MainActor
  func testGuardWithZeroNewMeasurementsEmitsErrorAndBlocksSelection() {
    let h = BridgeHarness()
    h.sdk.measurements = [measurement("m-old", at: 1000)]
    h.listen()
    _ = h.call("startEvaluation", [:])
    h.clearEvents()

    h.sdk.send(.info(.measurementEnd, numericData: nil))
    XCTAssertTrue(h.messages.isEmpty, "measurementEnd with no new measurement is deferred, not guessed")

    h.sdk.send(.success(.dbRead))
    XCTAssertEqual(h.messages.count, 1)
    assertError(h.messages.last, code: CubeBridgeCore.measurementGuardErrorCode, data: 0)
    XCTAssertFalse(infoCodes(h.messages).contains(9), "IM_MEASURE_COUNT must not complete the Dart wait")

    assertErrorCode(h.call("selectMeasurement", ["index": 0]), CubeBridgeErrorCode.measurementMismatch)
    XCTAssertEqual((successValue(h.call("getResults")) as? [[String: Any]])?.count, 0)
  }

  @MainActor
  func testGuardWithOneNewMeasurementReportsItsIndex() {
    let h = BridgeHarness()
    let a = measurement("m-a", at: 1000)
    let c = measurement("m-c", at: 3000)
    h.sdk.measurements = [a, c]
    h.listen()
    _ = h.call("startEvaluation", [:])
    h.clearEvents()

    // The new measurement sorts between the old ones (e.g. Cube clock drift).
    let b = measurement("m-b", at: 2000)
    h.sdk.publishMeasurements([c, b, a])
    h.sdk.send(.info(.measurementEnd, numericData: nil))
    assertInfo(h.messages.last, code: 8, name: "IM_MEASUREMENT_DONE", data: 1)

    let rows = successValue(h.call("getMeasurements")) as? [[String: Any]]
    XCTAssertEqual(rows?[1]["uid"] as? String, "m-b")

    assertErrorCode(h.call("selectMeasurement", ["index": 2]), CubeBridgeErrorCode.measurementMismatch)
    XCTAssertEqual(successValue(h.call("selectMeasurement", ["index": 1])) as? Bool, true)
  }

  @MainActor
  func testGuardWithTwoNewMeasurementsEmitsErrorAndBlocksSelection() {
    let h = BridgeHarness()
    let old = measurement("m-old", at: 1000)
    h.sdk.measurements = [old]
    h.listen()
    _ = h.call("startEvaluation", [:])
    h.clearEvents()

    h.sdk.publishMeasurements([old, measurement("m-x", at: 2000), measurement("m-y", at: 3000)])
    h.sdk.send(.info(.measurementEnd, numericData: nil))

    XCTAssertFalse(infoCodes(h.messages).contains(8))
    assertError(h.messages.last, code: CubeBridgeCore.measurementGuardErrorCode, data: 2)

    h.sdk.send(.success(.dbRead))
    XCTAssertFalse(infoCodes(h.messages).contains(8))
    XCTAssertFalse(infoCodes(h.messages).contains(9))

    // Dart's "last item" fallback must not be able to pick a result.
    assertErrorCode(h.call("selectMeasurement", ["index": 2]), CubeBridgeErrorCode.measurementMismatch)
    assertErrorCode(h.call("selectMeasurement", ["index": 1]), CubeBridgeErrorCode.measurementMismatch)
  }

  @MainActor
  func testGuardDeferredUntilMeasurementIsPublished() {
    let h = BridgeHarness()
    let old = measurement("m-old", at: 1000)
    h.sdk.measurements = [old]
    h.listen()
    _ = h.call("startEvaluation", [:])
    h.clearEvents()

    h.sdk.send(.info(.measurementEnd, numericData: nil))
    XCTAssertTrue(h.messages.isEmpty)

    h.sdk.publishMeasurements([old, measurement("m-new", at: 2000)])
    assertInfo(h.messages.last, code: 8, name: "IM_MEASUREMENT_DONE", data: 1)
    XCTAssertEqual(successValue(h.call("selectMeasurement", ["index": 1])) as? Bool, true)
  }

  /// A DB read can import older measurements stored on the Cube. The pinned
  /// measurement's index then shifts and is reported again before
  /// IM_MEASURE_COUNT, so Dart selects the right row.
  @MainActor
  func testGuardReportsShiftedIndexAfterDatabaseImport() {
    let h = BridgeHarness()
    let old = measurement("m-old", at: 1000)
    h.sdk.measurements = [old]
    h.listen()
    _ = h.call("startEvaluation", [:])
    h.clearEvents()

    let fresh = measurement("m-new", at: 9000)
    h.sdk.publishMeasurements([old, fresh])
    h.sdk.send(.info(.measurementEnd, numericData: nil))
    assertInfo(h.messages.last, code: 8, name: "IM_MEASUREMENT_DONE", data: 1)

    h.sdk.publishMeasurements([old, fresh, measurement("m-imp1", at: 200), measurement("m-imp2", at: 300)])
    assertInfo(h.messages.last, code: 8, name: "IM_MEASUREMENT_DONE", data: 3)

    h.clearEvents()
    h.sdk.send(.success(.dbRead))
    XCTAssertEqual(infoCodes(h.messages), [8, 9])
    assertInfo(h.messages.first, code: 8, name: "IM_MEASUREMENT_DONE", data: 3)

    assertErrorCode(h.call("selectMeasurement", ["index": 1]), CubeBridgeErrorCode.measurementMismatch)
    XCTAssertEqual(successValue(h.call("selectMeasurement", ["index": 3])) as? Bool, true)
    let rows = successValue(h.call("getMeasurements")) as? [[String: Any]]
    XCTAssertEqual(rows?[3]["uid"] as? String, "m-new")
  }

  @MainActor
  func testMeasurementEndWithoutEvaluationIsAnError() {
    let h = BridgeHarness()
    h.listen()
    h.clearEvents()
    h.sdk.send(.info(.measurementEnd, numericData: nil))
    assertError(h.messages.last, code: CubeBridgeCore.measurementGuardErrorCode, data: 0)
  }

  @MainActor
  func testSDKErrorDuringEvaluationBlocksSelection() {
    let h = BridgeHarness()
    let old = measurement("m-old", at: 1000)
    h.sdk.measurements = [old]
    h.listen()
    _ = h.call("startEvaluation", [:])
    h.sdk.send(.error(.device(code: 0x1D)))
    h.sdk.publishMeasurements([old, measurement("m-new", at: 2000)])
    h.sdk.send(.info(.measurementEnd, numericData: nil))

    XCTAssertFalse(infoCodes(h.messages).contains(8))
    assertErrorCode(h.call("selectMeasurement", ["index": 1]), CubeBridgeErrorCode.measurementMismatch)
  }

  @MainActor
  func testNewEvaluationClearsPreviousSelection() {
    let h = BridgeHarness()
    let old = measurement("m-old", at: 1000, results: [
      result(index: 1, name: "OLD", resultClass: "POSITIVE", isValid: true),
    ])
    h.sdk.measurements = [old]
    XCTAssertEqual(successValue(h.call("selectMeasurement", ["index": 0])) as? Bool, true)
    XCTAssertEqual((successValue(h.call("getResults")) as? [[String: Any]])?.count, 1)

    _ = h.call("startEvaluation", [:])
    XCTAssertEqual((successValue(h.call("getResults")) as? [[String: Any]])?.count, 0)
  }

  @MainActor
  func testClearLocalDatabaseResetsSelection() {
    let h = BridgeHarness()
    h.sdk.measurements = [measurement("m-a", at: 1000, results: [
      result(index: 1, name: "X", resultClass: "NEGATIVE", isValid: true),
    ])]
    _ = h.call("selectMeasurement", ["index": 0])
    XCTAssertNil(successValue(h.call("clearLocalDatabase")))
    XCTAssertEqual(h.sdk.clearLocalDatabaseCount, 1)
    XCTAssertEqual((successValue(h.call("getResults")) as? [[String: Any]])?.count, 0)
  }

  // MARK: startEvaluation configuration

  @MainActor
  func testStartEvaluationConfigResolution() {
    let assetData = Data([0x01, 0x02])
    let defaultAssetData = Data([0x03])
    let fileData = Data([0x04, 0x05, 0x06])

    // Missing named asset.
    var h = BridgeHarness()
    assertErrorCode(h.call("startEvaluation", ["configAssetName": "missing.bin"]), CubeBridgeErrorCode.missingAsset)
    XCTAssertTrue(h.sdk.startEvaluationCalls.isEmpty)

    // requireBundledConfig without the default asset.
    h = BridgeHarness()
    assertErrorCode(h.call("startEvaluation", ["requireBundledConfig": true]), CubeBridgeErrorCode.missingAsset)
    XCTAssertEqual(h.storage.requestedAssets, [CubeBridgeCore.defaultConfigAsset])
    XCTAssertTrue(h.sdk.startEvaluationCalls.isEmpty)

    // Named asset present.
    h = BridgeHarness()
    h.storage.assets["crp.bin"] = assetData
    XCTAssertEqual(successValue(h.call("startEvaluation", ["configAssetName": " crp.bin "])) as? Bool, true)
    XCTAssertEqual(h.sdk.startEvaluationCalls.last?.configuration, assetData)

    // Default asset present.
    h = BridgeHarness()
    h.storage.assets[CubeBridgeCore.defaultConfigAsset] = defaultAssetData
    _ = h.call("startEvaluation", ["requireBundledConfig": true, "useTimer": true])
    XCTAssertEqual(h.sdk.startEvaluationCalls.last?.configuration, defaultAssetData)
    XCTAssertEqual(h.sdk.startEvaluationCalls.last?.useTimer, true)

    // Unreadable path.
    h = BridgeHarness()
    h.storage.assets["crp.bin"] = assetData
    assertErrorCode(
      h.call("startEvaluation", ["configAbsolutePath": "/nope/cfg.bin", "configAssetName": "crp.bin"]),
      CubeBridgeErrorCode.openFailed
    )
    XCTAssertTrue(h.sdk.startEvaluationCalls.isEmpty)

    // Readable path wins over the asset.
    h = BridgeHarness()
    h.storage.assets["crp.bin"] = assetData
    h.storage.files["/tmp/cfg.bin"] = fileData
    _ = h.call("startEvaluation", ["configAbsolutePath": "/tmp/cfg.bin", "configAssetName": "crp.bin"])
    XCTAssertEqual(h.sdk.startEvaluationCalls.last?.configuration, fileData)

    // configUri is not supported on iOS and never falls back.
    h = BridgeHarness()
    h.storage.files["/tmp/cfg.bin"] = fileData
    assertErrorCode(
      h.call("startEvaluation", ["configUri": "content://x/y", "configAbsolutePath": "/tmp/cfg.bin"]),
      CubeBridgeErrorCode.openFailed
    )
    XCTAssertTrue(h.sdk.startEvaluationCalls.isEmpty)

    // Nothing given (or only blanks): RFID, nil configuration.
    h = BridgeHarness()
    _ = h.call("startEvaluation", ["useTimer": false, "requireBundledConfig": false, "configAssetName": "  "])
    XCTAssertEqual(h.sdk.startEvaluationCalls.count, 1)
    XCTAssertNil(h.sdk.startEvaluationCalls.first?.configuration ?? nil)
    XCTAssertEqual(h.sdk.startEvaluationCalls.first?.useTimer, false)
    XCTAssertTrue(h.storage.requestedAssets.isEmpty)
  }

  @MainActor
  func testStartEvaluationReturnsSDKResult() {
    let h = BridgeHarness()
    h.sdk.startEvaluationResult = false
    XCTAssertEqual(successValue(h.call("startEvaluation", [:])) as? Bool, false)
  }

  func testFileHelpersFailClosed() throws {
    XCTAssertNil(cubeFileData(atPath: "/definitely/not/here.bin"))
    XCTAssertNil(cubeBundledResourceData(named: "hdx-does-not-exist.bin"))
    XCTAssertNil(cubeBundledResourceData(named: ""))

    let dir = FileManager.default.temporaryDirectory
    let full = dir.appendingPathComponent("hdx-cube-test-\(UUID().uuidString).bin")
    let empty = dir.appendingPathComponent("hdx-cube-empty-\(UUID().uuidString).bin")
    try Data([0x0A, 0x0B]).write(to: full)
    try Data().write(to: empty)
    defer {
      try? FileManager.default.removeItem(at: full)
      try? FileManager.default.removeItem(at: empty)
    }
    XCTAssertEqual(cubeFileData(atPath: full.path), Data([0x0A, 0x0B]))
    XCTAssertNil(cubeFileData(atPath: empty.path))
    XCTAssertNil(cubeFileData(atPath: dir.path))
  }

  // MARK: Event channel lifecycle

  @MainActor
  func testListenReEmitsCurrentSnapshot() {
    let h = BridgeHarness()
    h.sdk.state = .idle
    h.sdk.devices = [CubeDeviceValue(id: "dev-a", name: "Cube-A", commType: "BLUETOOTH_LE")]
    h.sdk.measurements = [measurement("m-a", at: 1000, results: [
      result(index: 1, name: "X", resultClass: "NEGATIVE", isValid: true),
    ])]
    _ = h.call("selectMeasurement", ["index": 0])

    h.listen()

    XCTAssertEqual(h.events.map { $0["type"] as? String }, ["state", "devices", "measurements", "results"])
    XCTAssertEqual(h.events[0]["state"] as? String, "ST_IDLE")
    XCTAssertEqual((h.events[1]["devices"] as? [[String: Any]])?.count, 1)
    assertInt(h.events[2]["count"], 1)
    XCTAssertEqual((h.events[3]["results"] as? [[String: Any]])?.count, 1)
  }

  @MainActor
  func testListenCancelListenDeliversNoDuplicates() {
    let h = BridgeHarness()
    h.listen()
    h.core.stopListening()
    XCTAssertFalse(h.core.isListening)

    h.clearEvents()
    h.sdk.publishState(.scanning)
    XCTAssertTrue(h.events.isEmpty, "no events while cancelled")

    h.listen()
    XCTAssertEqual(h.events(ofType: "state").count, 1, "snapshot sent once")
    h.clearEvents()

    h.sdk.publishState(.idle)
    XCTAssertEqual(h.events.count, 1)

    // A second onListen without onCancel replaces the sink.
    var secondSink: [[String: Any]] = []
    h.core.startListening { payload in secondSink.append(payload) }
    h.clearEvents()
    secondSink.removeAll()
    h.sdk.publishState(.evaluating)
    XCTAssertTrue(h.events.isEmpty)
    XCTAssertEqual(secondSink.count, 1)
  }
}
