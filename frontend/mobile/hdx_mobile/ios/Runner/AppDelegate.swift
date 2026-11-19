import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Serves the Cube method/event channels (same contract as the Android
  /// CubeBridge). Kept alive for the lifetime of the app.
  private var cubeBridge: CubeBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "HomeDxCubeBridge") {
      // App launch runs on the main thread; the bridge and the SDK are @MainActor.
      MainActor.assumeIsolated {
        self.cubeBridge = CubeBridge(messenger: registrar.messenger(), core: CubeBridge.makeCore())
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
