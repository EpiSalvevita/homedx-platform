import 'dart:async';
import 'package:flutter/services.dart';
import 'api_service.dart';

/// Result from Cube data processing
class CubeTestResult {
  final bool success;
  final String? testId;
  final String? result;
  final String? error;
  final List<CubeResultData>? resultData;

  CubeTestResult({
    required this.success,
    this.testId,
    this.result,
    this.error,
    this.resultData,
  });

  factory CubeTestResult.fromJson(Map<String, dynamic> json) {
    return CubeTestResult(
      success: json['success'] ?? false,
      testId: json['testId'],
      result: json['result'],
      error: json['error'],
      resultData: json['resultData'] != null
          ? (json['resultData'] as List)
              .map((r) => CubeResultData.fromJson(r))
              .toList()
          : null,
    );
  }
}

class CubeResultData {
  final String name;
  final String value;
  final String unit;
  final String resultClass;
  final int validity;

  CubeResultData({
    required this.name,
    required this.value,
    required this.unit,
    required this.resultClass,
    required this.validity,
  });

  factory CubeResultData.fromJson(Map<String, dynamic> json) {
    return CubeResultData(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      resultClass: json['class'] ?? '',
      validity: _toInt(json['validity']),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'class': resultClass,
      'validity': validity,
    };
  }

  static int _toInt(dynamic v) {
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v.toInt();
    return 0;
  }
}

/// Cube device info returned from native scan.
class CubeDeviceInfo {
  final int index;
  final String name;

  /// Communication channel reported by the SDK
  /// (e.g. `BLUETOOTH_LE`, `BLUETOOTH`, `FTDI`). Empty when unknown.
  final String commType;

  CubeDeviceInfo({
    required this.index,
    required this.name,
    this.commType = '',
  });
}

/// Measurement summary returned from native SDK.
class CubeMeasurementInfo {
  final int index;
  final String uid;
  final String deviceSerial;
  final String dateTime;
  final double temperature;
  final String cfgName;

  CubeMeasurementInfo({
    required this.index,
    required this.uid,
    required this.deviceSerial,
    required this.dateTime,
    required this.temperature,
    required this.cfgName,
  });
}

/// Identifies a step in the Cube measurement lifecycle.
enum CubeMeasureStep {
  starting,
  placeWhite,
  placeTest,
  timerRunning,
  evaluating,
  readingResults,
  submitting,
  done,
  error,
}

/// Payload for a measurement step update.
class CubeStepUpdate {
  final CubeMeasureStep step;
  final String label;
  final int? secondsLeft;

  const CubeStepUpdate({required this.step, required this.label, this.secondsLeft});
}

/// Service that bridges Flutter to the native Cube Android SDK via MethodChannel/EventChannel.
class CubeService {
  static const MethodChannel _channel =
      MethodChannel('com.homedx.cube/analysis');
  static const EventChannel _eventChannel =
      EventChannel('com.homedx.cube/events');

  final ApiService _apiService;
  StreamSubscription<dynamic>? _eventSubscription;

  void Function(String state)? onStateChanged;
  void Function(List<CubeDeviceInfo> devices)? onDevicesUpdated;
  void Function(String msgType, int msgCode, int msgData)? onMessage;
  void Function(List<CubeResultData> results)? onResultsReady;

  CubeService(this._apiService);

  void startListening() {
    _eventSubscription ??=
        _eventChannel.receiveBroadcastStream().listen(_handleEvent);
  }

  void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  void _handleEvent(dynamic event) {
    if (event is! Map) return;
    final map = Map<String, dynamic>.from(event);
    final type = map['type'] as String?;

    switch (type) {
      case 'state':
        onStateChanged?.call(map['state']?.toString() ?? 'ST_DISCONNECTED');
        break;
      case 'devices':
        final raw = (map['devices'] as List?) ?? [];
        final devices = raw.map((d) {
          final dm = Map<String, dynamic>.from(d as Map);
          return CubeDeviceInfo(
            index: (dm['index'] as num?)?.toInt() ?? 0,
            name: dm['name']?.toString() ?? '',
            commType: dm['commType']?.toString() ?? '',
          );
        }).toList();
        onDevicesUpdated?.call(devices);
        break;
      case 'message':
        onMessage?.call(
          map['msgType']?.toString() ?? '',
          (map['msgCode'] as num?)?.toInt() ?? 0,
          (map['msgData'] as num?)?.toInt() ?? 0,
        );
        break;
      case 'results':
        final raw = (map['results'] as List?) ?? [];
        final results = raw.map((r) {
          final rm = Map<String, dynamic>.from(r as Map);
          return CubeResultData(
            name: rm['name']?.toString() ?? '',
            value: rm['value']?.toString() ?? '',
            unit: rm['unit']?.toString() ?? '',
            resultClass: rm['class']?.toString() ?? '',
            validity: CubeResultData._toInt(rm['validity']),
          );
        }).toList();
        onResultsReady?.call(results);
        break;
    }
  }

  // ── SDK info ──

  Future<String> getVersion() async {
    final version = await _channel.invokeMethod<String>('getVersion');
    return version ?? '';
  }

  Future<bool> licenseValid() async {
    final valid = await _channel.invokeMethod<bool>('licenseValid');
    return valid ?? false;
  }

  Future<String> getState() async {
    final state = await _channel.invokeMethod<String>('getState');
    return state ?? 'ST_DISCONNECTED';
  }

  // ── Scanning ──

  Future<bool> startScan({int timeoutMs = 5000}) async {
    final ok =
        await _channel.invokeMethod<bool>('startScan', {'timeoutMs': timeoutMs});
    return ok ?? false;
  }

  Future<void> stopScan() async {
    await _channel.invokeMethod<void>('stopScan');
  }

  // ── Connection ──

  Future<bool> connectDevice(int index, {bool disableButton = false}) async {
    final ok = await _channel.invokeMethod<bool>(
      'connectDevice',
      {'index': index, 'disableButton': disableButton},
    );
    return ok ?? false;
  }

  Future<void> disconnectDevice({bool shutDown = false}) async {
    await _channel
        .invokeMethod<void>('disconnectDevice', {'shutDown': shutDown});
  }

  Future<bool> isConnected() async {
    final connected = await _channel.invokeMethod<bool>('isConnected');
    return connected ?? false;
  }

  // ── Measurement ──

  /// [configAssetName] — optional file under `android/app/src/main/assets/` (default: `cube_test_config.bin`).
  /// If the asset is missing and [requireBundledConfig] is false, evaluation falls back to RFID config (SDK default).
  Future<bool> startEvaluation({
    bool useTimer = false,
    String? configAssetName,
    bool requireBundledConfig = false,
  }) async {
    final args = <String, dynamic>{
      'useTimer': useTimer,
      'requireBundledConfig': requireBundledConfig,
    };
    if (configAssetName != null && configAssetName.isNotEmpty) {
      args['configAssetName'] = configAssetName;
    }
    final ok = await _channel.invokeMethod<bool>('startEvaluation', args);
    return ok ?? false;
  }

  Future<bool> readDeviceDatabase() async {
    final ok = await _channel.invokeMethod<bool>('readDeviceDatabase');
    return ok ?? false;
  }

  Future<List<CubeMeasurementInfo>> getMeasurements() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('getMeasurements');
    if (raw == null) return [];
    return raw.map((item) {
      final m = Map<String, dynamic>.from(item as Map);
      return CubeMeasurementInfo(
        index: (m['index'] as num?)?.toInt() ?? 0,
        uid: m['uid']?.toString() ?? '',
        deviceSerial: m['deviceSerial']?.toString() ?? '',
        dateTime: m['dateTime']?.toString() ?? '',
        temperature: (m['temperature'] as num?)?.toDouble() ?? 0.0,
        cfgName: m['cfgName']?.toString() ?? '',
      );
    }).toList();
  }

  Future<bool> selectMeasurement(int index) async {
    final ok = await _channel
        .invokeMethod<bool>('selectMeasurement', {'index': index});
    return ok ?? false;
  }

  Future<List<CubeResultData>> getResults() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('getResults');
    if (raw == null) return [];
    return raw.map((item) {
      final m = Map<String, dynamic>.from(item as Map);
      return CubeResultData(
        name: m['name']?.toString() ?? '',
        value: m['value']?.toString() ?? '',
        unit: m['unit']?.toString() ?? '',
        resultClass: m['class']?.toString() ?? '',
        validity: CubeResultData._toInt(m['validity']),
      );
    }).toList();
  }

  Future<void> clearLocalDatabase() async {
    await _channel.invokeMethod<void>('clearLocalDatabase');
  }

  // ── Full measurement flow ──

  /// Run a complete measurement with rich step-by-step callbacks.
  ///
  /// [onStep] is called with [CubeStepUpdate] for each lifecycle phase,
  /// enabling the UI to show detailed progress (cassette instructions,
  /// timer countdown, etc.).
  ///
  /// [useTimer] controls whether the SDK runs the standardized incubation
  /// timer defined in the cassette test configuration. Per the Cube
  /// programmer's guide, when this is false the measurement is executed
  /// immediately without waiting — which would skip the assay's required
  /// incubation period and produce clinically meaningless results — so it
  /// defaults to true. Pass false only for reading already-incubated
  /// cassettes.
  Future<CubeTestResult> runTestAndSubmit({
    required String testTypeId,
    void Function(String status)? onStatus,
    void Function(CubeStepUpdate step)? onStep,
    Duration timeout = const Duration(minutes: 5),
    bool useTimer = true,
  }) async {
    void emitStep(CubeMeasureStep step, String label, {int? secondsLeft}) {
      onStep?.call(CubeStepUpdate(step: step, label: label, secondsLeft: secondsLeft));
      onStatus?.call(label);
    }

    emitStep(CubeMeasureStep.starting, 'Starte Messung...');

    // 1. Hook into onMessage to detect Cube DLL info messages
    final previousMessageHandler = onMessage;
    final previousStateHandler = onStateChanged;
    final stateCompleter = Completer<bool>();
    Completer<bool>? dbReadCompleter;
    bool sawEvaluating = false;
    int? measurementDoneIndex;
    String? lastSdkError;

    onMessage = (msgType, msgCode, msgData) {
      previousMessageHandler?.call(msgType, msgCode, msgData);

      if (msgType == 'MT_INFO' || msgType == '0') {
        switch (msgCode) {
          case 0x00: // IM_PLACE_WHITE
            emitStep(CubeMeasureStep.placeWhite, 'Bitte legen Sie die weiße Kassette in das Gerät ein.');
            break;
          case 0x01: // IM_PLACE_TEST
            emitStep(CubeMeasureStep.placeTest, 'Bitte legen Sie die Testkassette in das Gerät ein.');
            break;
          case 0x02: // IM_TIMER_RUNNING
            final secs = msgData;
            final mins = secs ~/ 60;
            final remSecs = secs % 60;
            final timeStr = mins > 0
                ? '$mins:${remSecs.toString().padLeft(2, '0')} Min'
                : '$secs Sek';
            emitStep(CubeMeasureStep.timerRunning, 'Inkubationszeit: $timeStr verbleibend', secondsLeft: secs);
            break;
          case 0x03: // IM_EVALUATION_RUNNING
            emitStep(CubeMeasureStep.evaluating, 'Messung wird ausgewertet...');
            break;
          case 0x04: // IM_MEASUREMENT_DONE
            measurementDoneIndex = msgData;
            if (!stateCompleter.isCompleted) {
              stateCompleter.complete(true);
            }
            emitStep(CubeMeasureStep.readingResults, 'Messung abgeschlossen. Ergebnisse werden geladen...');
            break;
          case 0x09: // IM_MEASURE_COUNT (readDeviceDatabase completed)
            final c = dbReadCompleter;
            if (c != null && !c.isCompleted) {
              c.complete(true);
            }
            break;
        }
      } else if (msgType == 'MT_ERROR' || msgType == '1') {
        lastSdkError = 'Cube SDK Fehler: Code $msgCode, Data $msgData';
        if (!stateCompleter.isCompleted) {
          stateCompleter.complete(false);
        }
        final c = dbReadCompleter;
        if (c != null && !c.isCompleted) {
          c.complete(false);
        }
      }
    };

    // Install state listener before startEvaluation to avoid missing quick transitions.
    onStateChanged = (state) {
      previousStateHandler?.call(state);

      if (state == 'ST_EVALUATE' || state == 'ST_READ') {
        sawEvaluating = true;
      }

      if (sawEvaluating && state == 'ST_IDLE') {
        if (!stateCompleter.isCompleted) stateCompleter.complete(true);
      }

      if (state == 'ST_DISCONNECTED' || state == 'ST_ERROR') {
        if (!stateCompleter.isCompleted) stateCompleter.complete(false);
      }
    };

    try {
      // 2. Start evaluation on the Cube device
      final evalOk = await startEvaluation(useTimer: useTimer);
      if (!evalOk) {
        return CubeTestResult(
          success: false,
          error: 'Messung konnte nicht gestartet werden',
        );
      }

      emitStep(CubeMeasureStep.evaluating, 'Messung läuft...');

      // 3. Wait for SDK completion signal/state.
      final ok = await stateCompleter.future.timeout(timeout, onTimeout: () => false);

      if (!ok) {
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Messung fehlgeschlagen oder Zeitüberschreitung',
        );
      }

      // 4. Read measurements from device database
      emitStep(CubeMeasureStep.readingResults, 'Messdaten werden geladen...');
      dbReadCompleter = Completer<bool>();
      await readDeviceDatabase();
      final dbReadOk = await dbReadCompleter.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => false,
      );
      if (!dbReadOk) {
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Auslesen der Messdaten hat zu lange gedauert',
        );
      }
      final measurements = await _waitForMeasurements(
        expectedIndex: measurementDoneIndex,
      );
      if (measurements.isEmpty) {
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Keine Messdaten auf dem Gerät gefunden',
        );
      }

      // 5. Select the measurement announced by SDK, fallback to most recent.
      CubeMeasurementInfo selected = measurements.last;
      if (measurementDoneIndex != null) {
        for (final m in measurements) {
          if (m.index == measurementDoneIndex) {
            selected = m;
            break;
          }
        }
      }

      emitStep(CubeMeasureStep.readingResults, 'Ergebnisse werden geladen...');
      final selectedOk = await selectMeasurement(selected.index);
      if (!selectedOk) {
        return CubeTestResult(
          success: false,
          error: 'Messung konnte nicht ausgewählt werden',
        );
      }

      // 6. Get results
      final results = await _waitForResults();
      if (results.isEmpty) {
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Keine Ergebnisse für diese Messung verfügbar',
        );
      }

      // 7. Submit to backend
      emitStep(CubeMeasureStep.submitting, 'Ergebnisse werden übermittelt...');
      final deviceSerial = selected.deviceSerial;
      final resultString = _determineResultString(results);
      final response = await _apiService.submitCubeData(
        testTypeId: testTypeId,
        deviceSerial: deviceSerial,
        measurementTimestamp: DateTime.now().millisecondsSinceEpoch,
        result: resultString,
        resultData: results.map((r) => r.toApiJson()).toList(),
      );

      emitStep(CubeMeasureStep.done, 'Fertig');
      return CubeTestResult.fromJson(response);
    } catch (e) {
      return CubeTestResult(
        success: false,
        error: 'Fehler während der Messung: $e',
      );
    } finally {
      onStateChanged = previousStateHandler;
      onMessage = previousMessageHandler;
    }
  }

  // ── Backend submission (results already available) ──

  Future<CubeTestResult> submitResults({
    required String testTypeId,
    String? deviceSerial,
  }) async {
    final results = await getResults();
    if (results.isEmpty) {
      return CubeTestResult(
        success: false,
        error: 'No Cube results available to submit',
      );
    }

    final resultString = _determineResultString(results);
    final response = await _apiService.submitCubeData(
      testTypeId: testTypeId,
      deviceSerial: deviceSerial,
      measurementTimestamp: DateTime.now().millisecondsSinceEpoch,
      result: resultString,
      resultData: results.map((r) => r.toApiJson()).toList(),
    );

    return CubeTestResult.fromJson(response);
  }

  String _determineResultString(List<CubeResultData> results) {
    for (final r in results) {
      final cls = r.resultClass.toUpperCase();
      if (cls == 'POSITIVE' || cls == 'POS') return 'POSITIVE';
      if (cls == 'NEGATIVE' || cls == 'NEG') return 'NEGATIVE';
    }
    for (final r in results) {
      final v = double.tryParse(r.value);
      if (v != null && v > 0.5) return 'POSITIVE';
    }
    return 'NEGATIVE';
  }

  Future<List<CubeMeasurementInfo>> _waitForMeasurements({
    int? expectedIndex,
    Duration timeout = const Duration(seconds: 20),
    Duration pollInterval = const Duration(milliseconds: 300),
  }) async {
    final deadline = DateTime.now().add(timeout);
    List<CubeMeasurementInfo> latest = [];
    while (DateTime.now().isBefore(deadline)) {
      latest = await getMeasurements();
      if (latest.isNotEmpty) {
        if (expectedIndex == null) return latest;
        for (final m in latest) {
          if (m.index == expectedIndex) return latest;
        }
      }
      await Future.delayed(pollInterval);
    }
    return latest;
  }

  Future<List<CubeResultData>> _waitForResults({
    Duration timeout = const Duration(seconds: 12),
    Duration pollInterval = const Duration(milliseconds: 250),
  }) async {
    final deadline = DateTime.now().add(timeout);
    List<CubeResultData> latest = [];
    while (DateTime.now().isBefore(deadline)) {
      latest = await getResults();
      if (latest.isNotEmpty) return latest;
      await Future.delayed(pollInterval);
    }
    return latest;
  }
}
