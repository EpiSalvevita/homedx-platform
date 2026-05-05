import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal harness to drive the `CubeService` MethodChannel and EventChannel
/// from unit tests.
///
/// MethodChannel: register lambdas with [whenMethod]; the harness forwards
/// the invocation arguments and any thrown errors back to the channel
/// caller.
///
/// EventChannel: call [pushEvent] to deliver a value to whoever is currently
/// listening to `com.homedx.cube/events`. The handler for `listen` /
/// `cancel` is wired automatically on construction.
class CubeChannelHarness {
  CubeChannelHarness() {
    _wireEventChannel();
  }

  static const String methodChannelName = 'com.homedx.cube/analysis';
  static const String eventChannelName = 'com.homedx.cube/events';

  static const StandardMethodCodec _codec = StandardMethodCodec();

  /// Method-name → handler. Latest registration wins so individual tests
  /// can override defaults set in [setUp].
  final Map<String, Future<Object?> Function(MethodCall call)> _handlers = {};

  /// Every call seen on the method channel, in order. Useful to assert that
  /// e.g. `startEvaluation` was invoked exactly once with the right args.
  final List<MethodCall> calls = <MethodCall>[];

  TestDefaultBinaryMessenger get _messenger =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Register (or replace) a handler for a single method.
  void whenMethod(
    String method,
    Future<Object?> Function(MethodCall call) handler,
  ) {
    _handlers[method] = handler;
    _messenger.setMockMethodCallHandler(
      const MethodChannel(methodChannelName),
      _dispatchMethodCall,
    );
  }

  /// Convenience: the method always returns the same value.
  void answerMethod(String method, Object? value) {
    whenMethod(method, (_) async => value);
  }

  Future<Object?> _dispatchMethodCall(MethodCall call) async {
    calls.add(call);
    final handler = _handlers[call.method];
    if (handler == null) {
      throw MissingPluginException(
        'CubeChannelHarness: no handler registered for "${call.method}". '
        'Use whenMethod/answerMethod to set one up.',
      );
    }
    return handler(call);
  }

  /// Push a Cube event to subscribers of the EventChannel.
  ///
  /// Mirrors the wire format the Kotlin bridge produces (see
  /// `CubeAnalysisMethodChannel.kt`):
  /// ```dart
  /// pushEvent({'type': 'state', 'state': 'ST_IDLE'});
  /// pushEvent({'type': 'message', 'msgType': 'MT_INFO', 'msgCode': 0x04, 'msgData': 7});
  /// ```
  Future<void> pushEvent(Map<String, Object?> event) async {
    final data = _codec.encodeSuccessEnvelope(event);
    await _messenger.handlePlatformMessage(
      eventChannelName,
      data,
      (_) {},
    );
  }

  /// Push an SDK error onto the EventChannel.
  Future<void> pushError({
    required String code,
    String? message,
    Object? details,
  }) async {
    final data =
        _codec.encodeErrorEnvelope(code: code, message: message, details: details);
    await _messenger.handlePlatformMessage(
      eventChannelName,
      data,
      (_) {},
    );
  }

  /// Tear everything down; call from `tearDown` in each test.
  void dispose() {
    _messenger.setMockMethodCallHandler(
      const MethodChannel(methodChannelName),
      null,
    );
    _messenger.setMockMethodCallHandler(
      const MethodChannel(eventChannelName),
      null,
    );
  }

  void _wireEventChannel() {
    // EventChannel.listen sends MethodCall('listen', ...) over its own
    // MethodChannel; we just ack it so the broadcast stream goes live.
    _messenger.setMockMethodCallHandler(
      const MethodChannel(eventChannelName),
      (call) async => null,
    );
  }
}
