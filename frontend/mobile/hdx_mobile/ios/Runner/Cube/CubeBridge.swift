import Flutter
import Foundation

/// Connects `CubeBridgeCore` to the Flutter channels used by
/// lib/features/cube/cube_service.dart:
///   * method channel `com.homedx.cube/analysis`
///   * event channel `com.homedx.cube/events`
///
/// Flutter calls method handlers and stream-handler callbacks on the main
/// thread, and the core (like `CubeViewModel`) is `@MainActor`, so each
/// entry point asserts main-actor isolation with `MainActor.assumeIsolated`.
/// Events are sent from SDK callbacks, which also run on the main actor.
final class CubeBridge: NSObject, FlutterStreamHandler {
  static let methodChannelName = "com.homedx.cube/analysis"
  static let eventChannelName = "com.homedx.cube/events"

  private let core: CubeBridgeCore
  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel

  @MainActor
  init(messenger: FlutterBinaryMessenger, core: CubeBridgeCore) {
    self.core = core
    self.methodChannel = FlutterMethodChannel(name: CubeBridge.methodChannelName, binaryMessenger: messenger)
    self.eventChannel = FlutterEventChannel(name: CubeBridge.eventChannelName, binaryMessenger: messenger)
    super.init()
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
    eventChannel.setStreamHandler(self)
  }

  /// Picks the SDK implementation at compile time: the real CubeReader
  /// adapter when the vendor framework is linked, otherwise the fail-closed
  /// fallback.
  @MainActor
  static func makeSDK() -> CubeSDK {
    #if canImport(CubeReader)
    return CubeReaderAdapter()
    #else
    return UnavailableCubeSDK()
    #endif
  }

  @MainActor
  static func makeCore() -> CubeBridgeCore {
    // Lazy: CubeViewModel (and its Bluetooth prompt) starts on the first
    // Cube channel call, not at app launch.
    CubeBridgeCore(
      sdk: LazyCubeSDK(factory: { makeSDK() }),
      loadBundledResource: { name in cubeBundledResourceData(named: name) },
      readFile: { path in cubeFileData(atPath: path) }
    )
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    MainActor.assumeIsolated {
      let outcome = self.core.handle(method: call.method, arguments: call.arguments)
      switch outcome {
      case let .success(value):
        result(value)
      case let .error(code, message):
        result(FlutterError(code: code, message: message, details: nil))
      case .notImplemented:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // MARK: - FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    MainActor.assumeIsolated {
      self.core.startListening { payload in
        events(payload)
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    MainActor.assumeIsolated {
      self.core.stopListening()
    }
    return nil
  }
}
