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

  CubeDeviceInfo({required this.index, required this.name});
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

/// Service that bridges Flutter to the native Cube Android SDK via MethodChannel/EventChannel.
///
/// The Cube SDK manages its own BLE/USB connections, scanning, measurements, and result reading.
/// Flutter drives the workflow through this service.
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

  /// Start listening to native Cube SDK events.
  void startListening() {
    _eventSubscription ??=
        _eventChannel.receiveBroadcastStream().listen(_handleEvent);
  }

  /// Stop listening to events.
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

  Future<bool> startEvaluation({bool useTimer = false}) async {
    final ok = await _channel
        .invokeMethod<bool>('startEvaluation', {'useTimer': useTimer});
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

  /// Run a complete measurement: start evaluation, wait for results, submit to backend.
  ///
  /// [onStatus] is called with progress messages for UI updates.
  Future<CubeTestResult> runTestAndSubmit({
    required String testTypeId,
    void Function(String status)? onStatus,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    onStatus?.call('Starte Messung...');

    // 1. Start evaluation on the Cube device
    final evalOk = await startEvaluation();
    if (!evalOk) {
      return CubeTestResult(
        success: false,
        error: 'Messung konnte nicht gestartet werden',
      );
    }

    onStatus?.call('Messung läuft...');

    // 2. Wait for the SDK to finish evaluation (state goes back to ST_IDLE)
    final stateCompleter = Completer<bool>();
    final previousStateHandler = onStateChanged;
    bool sawEvaluating = false;

    onStateChanged = (state) {
      previousStateHandler?.call(state);

      if (state == 'ST_EVALUATE' || state == 'ST_READ') {
        sawEvaluating = true;
        if (state == 'ST_EVALUATE') {
          onStatus?.call('Messung läuft...');
        } else {
          onStatus?.call('Daten werden gelesen...');
        }
      }

      if (sawEvaluating && state == 'ST_IDLE') {
        if (!stateCompleter.isCompleted) stateCompleter.complete(true);
      }

      if (state == 'ST_DISCONNECTED' || state == 'ST_ERROR') {
        if (!stateCompleter.isCompleted) stateCompleter.complete(false);
      }
    };

    try {
      final ok = await stateCompleter.future.timeout(timeout, onTimeout: () => false);
      onStateChanged = previousStateHandler;

      if (!ok) {
        return CubeTestResult(
          success: false,
          error: 'Messung fehlgeschlagen oder Zeitüberschreitung',
        );
      }

      // 3. Read measurements from device database
      onStatus?.call('Messdaten werden geladen...');
      await Future.delayed(const Duration(milliseconds: 500));
      await readDeviceDatabase();
      await Future.delayed(const Duration(seconds: 2));

      final measurements = await getMeasurements();
      if (measurements.isEmpty) {
        return CubeTestResult(
          success: false,
          error: 'Keine Messdaten auf dem Gerät gefunden',
        );
      }

      // 4. Select the most recent measurement
      onStatus?.call('Ergebnisse werden geladen...');
      await selectMeasurement(measurements.last.index);
      await Future.delayed(const Duration(seconds: 2));

      // 5. Get results
      final results = await getResults();
      if (results.isEmpty) {
        return CubeTestResult(
          success: false,
          error: 'Keine Ergebnisse für diese Messung verfügbar',
        );
      }

      // 6. Submit to backend
      onStatus?.call('Ergebnisse werden übermittelt...');
      final deviceSerial = measurements.last.deviceSerial;
      final resultString = _determineResultString(results);
      final response = await _apiService.submitCubeData(
        testTypeId: testTypeId,
        deviceSerial: deviceSerial,
        measurementTimestamp: DateTime.now().millisecondsSinceEpoch,
        result: resultString,
        resultData: results.map((r) => r.toApiJson()).toList(),
      );

      return CubeTestResult.fromJson(response);
    } catch (e) {
      onStateChanged = previousStateHandler;
      return CubeTestResult(
        success: false,
        error: 'Fehler während der Messung: $e',
      );
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
}
