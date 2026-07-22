import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';

/// Log tag filter: `flutter logs` / DevTools, or Android:
/// `adb logcat | grep HDX_CUBE`
///
/// Verbose timing + poll traces: set `CUBE_VERBOSE=true` in `.env` (default on).
/// Disable with `CUBE_VERBOSE=false` for quieter logs.
const String _kCubeLogScope = 'HDX_CUBE';

void _cubeTrace(String phase, String message) {
  if (kReleaseMode && !AppConstants.cubeVerboseLogging) return;
  developer.log('[$phase] $message', name: _kCubeLogScope);
}

void _cubeTracePoll(String message) {
  if (!AppConstants.cubeVerboseLogging) return;
  developer.log('[POLL] $message', name: _kCubeLogScope);
}

bool _cubeSdkMessageIsError(String msgType) {
  return msgType == 'MT_ERROR' || msgType == '1';
}

// ── CubeDLL `MT_ERROR` / device errors (Programmer's Guide §10.4, §10.6) ──

/// `MessageCode` when `MessageType` is `MT_ERROR` (decimal as emitted by native).
const int _emCommandNotSupported = 0x00;
const int _emDeviceError = 0x01;
const int _emCommunicationError = 0x02;
const int _emDateTimeInvalid = 0x03;
const int _emTimeOut = 0x04;
const int _emLicenseMismatch = 0x05;
const int _emTestConfigError = 0x06;

/// German UI text for `MT_ERROR` + messageCode + msgData (device / comm / config lists).
String _cubeMtErrorUserMessage(int messageCode, int data) {
  switch (messageCode) {
    case _emCommandNotSupported:
      return 'Der Befehl wird von diesem Cube nicht unterstützt.';
    case _emDeviceError:
      return _cubeDeviceErrorUserMessage(data);
    case _emCommunicationError:
      return _cubeCommunicationErrorUserMessage(data);
    case _emDateTimeInvalid:
      return 'Ungültiges Datum oder Uhrzeit vom Gerät.';
    case _emTimeOut:
      return data == 1
          ? 'Zeitüberschreitung: das Gerät wurde getrennt.'
          : 'Zeitüberschreitung bei der Kommunikation mit dem Cube.';
    case _emLicenseMismatch:
      return 'Die Cube-Lizenz passt nicht zu diesem Gerät (cube_license.dat).';
    case _emTestConfigError:
      return _cubeTestConfigErrorUserMessage(data);
    default:
      return 'Cube-Messung abgebrochen (SDK-Fehlercode $messageCode, Zusatz $data).';
  }
}

String _cubeDeviceErrorUserMessage(int data) {
  // Values are hex ordinals from the DLL (msgData equals 0xNN as decimal, e.g. 0x91 → 145).
  switch (data) {
    case 0x10:
      return 'Die Testkonfiguration ist abgelaufen (Ablaufdatum überschritten).';
    case 0x11:
      return 'Batterie im Cube zu schwach für diese Messung.';
    case 0x12:
    case 0x13:
    case 0x14:
    case 0x15:
      return 'Fehler bei der Bildaufnahme (Schwarz-/Hellwert). Bitte Kassette und Optik prüfen.';
    case 0x16:
      return 'Auswertung: Testlinie außerhalb des gültigen Bereichs.';
    case 0x17:
      return 'Auswertung: Suchbereich der Testlinie zu klein.';
    case 0x1A:
      return 'Die geladene Testkonfiguration ist ungültig.';
    case 0x1C:
      return 'Testkonfiguration: nicht unterstützte Version.';
    case 0x1D:
      return 'Messung wurde abgebrochen.';
    case 0x1E:
      return 'Vor der nächsten Messung ist ein QC-Test am Gerät erforderlich.';
    case 0x30:
      return 'Zeitüberschreitung beim Auslesen der RFID-Daten von der Kassette.';
    case 0x31:
      return 'RFID-Statusfehler auf der Kassette.';
    case 0x32:
      return 'RFID: empfangener Datensatz zu groß.';
    case 0x33:
      return 'RFID: mehrere Kassetten im Lesefeld (Kollision).';
    case 0x91:
      return 'Die Testkonfiguration (z. B. CRP-.bin) ist für dieses Cube-Modell '
          'nicht freigegeben — sie passt nicht zu Ihrem „Cube plus“. '
          'Bitte die vom Hersteller passende Konfiguration verwenden oder ohne '
          'externe Datei mit Kassetten-Kalibrierung (RFID) messen.';
    case 0x9E:
      return 'Kein gespeichertes Ergebnis mit dieser ID auf dem Gerät.';
    default:
      return 'Gerätefehler beim Cube (Technisch: Data=$data, 0x${data.toRadixString(16)}). '
          'Siehe CubeDLL Programmer’s Guide, Abschnitt „Device errors“.';
  }
}

String _cubeCommunicationErrorUserMessage(int data) {
  switch (data) {
    case 0x00:
      return 'Kommunikation: kein Fehler (unerwartet).';
    default:
      return 'Kommunikationsfehler mit dem Cube (Code $data / 0x${data.toRadixString(16)}).';
  }
}

String _cubeTestConfigErrorUserMessage(int data) {
  switch (data) {
    default:
      return 'Fehler in der Testkonfiguration (SDK 0x06, Detail $data).';
  }
}

/// `MessageData.EInfoMessage.getCode()` from cubelib (`MessageData.kt` / AAR).
/// Older code wrongly assumed hex 0x00–0x04; the SDK uses these ordinals.
const int _imConnectionEstablished = 1;
const int _imDeviceDisconnected = 2;
const int _imPlaceWhite = 3;
const int _imPlaceTest = 4;
const int _imTimerRunning = 5;
const int _imEvaluationRunning = 6;
const int _imEvaluationReadData = 7;
const int _imMeasurementDone = 8;
const int _imMeasureCount = 9;
const int _imDbFormatted = 10;

/// Lifecycle payloads we react to in [CubeService.runTestAndSubmit].
const Set<int> _cubeLifecycleInfoCodes = {
  _imConnectionEstablished,
  _imDeviceDisconnected,
  _imPlaceWhite,
  _imPlaceTest,
  _imTimerRunning,
  _imEvaluationRunning,
  _imEvaluationReadData,
  _imMeasurementDone,
  _imMeasureCount,
  _imDbFormatted,
};

/// StandardMethodCodec may deliver ints as [int], [double], or occasionally
/// [String]. A bad `as num?` cast throws and **kills the EventChannel stream**.
int _cubeEventInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Cubelib `MessageData.EInfoMessage` names (see `infoMessage` from Android bridge).
int? _cubeEInfoMessageNameToCode(String name) {
  switch (name) {
    case 'IM_CONNECTION_ESTABLISHED':
      return _imConnectionEstablished;
    case 'IM_DEVICE_DISCONNECTED':
      return _imDeviceDisconnected;
    case 'IM_PLACE_WHITE':
      return _imPlaceWhite;
    case 'IM_PLACE_TEST':
      return _imPlaceTest;
    case 'IM_TIMER_RUNNING':
      return _imTimerRunning;
    case 'IM_EVALUATION_RUNNING':
      return _imEvaluationRunning;
    case 'IM_EVALUATION_READ_DATA':
      return _imEvaluationReadData;
    case 'IM_MEASUREMENT_DONE':
      return _imMeasurementDone;
    case 'IM_MEASURE_COUNT':
      return _imMeasureCount;
    case 'IM_DB_FORMATTED':
      return _imDbFormatted;
    default:
      return null;
  }
}

/// True when [msgCode] is a cubelib [MessageData.EInfoMessage] code (non-error types only).
bool _cubeSdkMessageIsInfo(String msgType, int msgCode) {
  if (_cubeSdkMessageIsError(msgType)) return false;
  return _cubeLifecycleInfoCodes.contains(msgCode);
}

/// Result from Cube data processing
class CubeTestResult {
  final bool success;
  final String? testId;
  final String? result;
  final String? error;
  final List<CubeResultData>? resultData;

  final String? certificateId;

  CubeTestResult({
    required this.success,
    this.testId,
    this.result,
    this.error,
    this.resultData,
    this.certificateId,
  });

  factory CubeTestResult.fromJson(Map<String, dynamic> json) {
    return CubeTestResult(
      success: json['success'] ?? false,
      testId: json['testId'],
      result: json['result'],
      error: json['error'],
      certificateId: json['certificateId'] as String?,
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

  /// Cube SDK `CL_GetResultValidity` codes (Programmer's Guide §7.3).
  bool get isMeasurementValid => validity == 0;

  /// User-facing label for the measurement quality flag from the Cube device.
  String get validityLabel {
    switch (validity) {
      case 0:
        return 'Gültig';
      case 1:
        return 'Kein Wert';
      case 2:
        return 'Unendlich';
      case 3:
        return 'Ungültig';
      case 4:
        return 'Gerät abgelaufen';
      default:
        return 'Unbekannt';
    }
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

  /// Logs every platform call and surfaces [PlatformException] (missing channel handler,
  /// invalid args, native `result.error`, etc.).
  Future<T?> _invokeCube<T>(String method, [Object? arguments]) async {
    final argBrief = arguments == null ? '' : arguments.toString();
    _cubeTrace('NATIVE→', '$method($argBrief)');
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      _cubeTrace('NATIVE←', '$method → ${result ?? '(null)'}');
      return result;
    } on PlatformException catch (e, st) {
      developer.log(
        'PlatformException on $method: code=${e.code} message=${e.message} details=${e.details}',
        name: _kCubeLogScope,
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } catch (e, st) {
      developer.log(
        'invoke $method failed: $e',
        name: _kCubeLogScope,
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    }
  }

  void Function(String state)? onStateChanged;
  void Function(List<CubeDeviceInfo> devices)? onDevicesUpdated;
  void Function(String msgType, int msgCode, int msgData)? onMessage;
  void Function(List<CubeResultData> results)? onResultsReady;

  CubeService(this._apiService);

  void startListening() {
    if (_eventSubscription != null) {
      _cubeTrace('CHANNEL', 'startListening: already subscribed, no-op');
      return;
    }
    _cubeTrace('CHANNEL', 'startListening: subscribing to EventChannel');
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _handleEvent,
      onError: (Object e, StackTrace st) {
        developer.log(
          'EventChannel stream error: $e',
          name: _kCubeLogScope,
          error: e,
          stackTrace: st,
          level: 1000,
        );
        debugPrint('CubeService EventChannel error: $e\n$st');
      },
      cancelOnError: false,
    );
  }

  void stopListening() {
    if (_eventSubscription == null) {
      _cubeTrace('CHANNEL', 'stopListening: no subscription, no-op');
      return;
    }
    _cubeTrace('CHANNEL', 'stopListening: cancelling EventChannel subscription');
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  void _handleEvent(dynamic event) {
    try {
      if (event is! Map) {
        _cubeTrace('EVENT', 'ignored non-Map event: ${event.runtimeType} $event');
        return;
      }
      final map = Map<String, dynamic>.from(event);
      final type = map['type'] as String?;
      _cubeTrace('EVENT', 'type=$type keys=${map.keys.join(",")}');

      switch (type) {
        case 'state':
          final st = map['state']?.toString() ?? 'ST_DISCONNECTED';
          _cubeTrace('EVENT', 'state=$st');
          onStateChanged?.call(st);
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
          _cubeTrace('EVENT', 'devices count=${devices.length} ${devices.map((d) => '#${d.index}:${d.name}[${d.commType}]').join(' | ')}');
          onDevicesUpdated?.call(devices);
          break;
        case 'message':
          var msgType = map['msgType']?.toString() ?? '';
          var msgCode = _cubeEventInt(map['msgCode']);
          final infoName = map['infoMessage']?.toString();
          if (infoName != null &&
              infoName.isNotEmpty &&
              infoName != 'IM_NO_INFO_MESSAGE') {
            final mapped = _cubeEInfoMessageNameToCode(infoName);
            if (mapped != null) {
              msgCode = mapped;
            }
          }
          final msgData = _cubeEventInt(map['msgData']);
          _cubeTrace(
            'EVENT',
            'message msgType=$msgType msgCode=$msgCode (rawCode=${_cubeEventInt(map['msgCode'])}) infoName=${infoName ?? '-'} msgData=$msgData',
          );
          onMessage?.call(msgType, msgCode, msgData);
          break;
        case 'measurements':
          _cubeTrace(
            'EVENT',
            'measurements update count=${map['count'] ?? '?'} (native DB list sync)',
          );
          break;
        case 'results':
          final raw = (map['results'] as List?) ?? [];
          _cubeTrace('EVENT', 'results batch count=${raw.length}');
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
          for (var i = 0; i < results.length && i < 8; i++) {
            final r = results[i];
            _cubeTrace('EVENT', '  result[$i] ${r.name}=${r.value} ${r.unit} class=${r.resultClass} val=${r.validity}');
          }
          if (results.length > 8) {
            _cubeTrace('EVENT', '  … ${results.length - 8} more result rows');
          }
          onResultsReady?.call(results);
          break;
        default:
          _cubeTrace('EVENT', 'unhandled type=$type full=$map');
      }
    } catch (e, st) {
      developer.log('CubeService._handleEvent: $e', name: _kCubeLogScope, error: e, stackTrace: st);
      debugPrint('CubeService._handleEvent: $e\n$st');
    }
  }

  // ── SDK info ──

  Future<String> getVersion() async {
    final version = await _invokeCube<String>('getVersion');
    return version ?? '';
  }

  Future<bool> licenseValid() async {
    final valid = await _invokeCube<bool>('licenseValid');
    return valid ?? false;
  }

  Future<String> getState() async {
    final state = await _invokeCube<String>('getState');
    return state ?? 'ST_DISCONNECTED';
  }

  // ── Scanning ──

  Future<bool> startScan({int timeoutMs = 5000}) async {
    final ok =
        await _invokeCube<bool>('startScan', {'timeoutMs': timeoutMs});
    return ok ?? false;
  }

  Future<void> stopScan() async {
    await _invokeCube<void>('stopScan');
  }

  // ── Connection ──

  Future<bool> connectDevice(int index, {bool disableButton = false}) async {
    final ok = await _invokeCube<bool>(
      'connectDevice',
      {'index': index, 'disableButton': disableButton},
    );
    return ok ?? false;
  }

  Future<void> disconnectDevice({bool shutDown = false}) async {
    await _invokeCube<void>('disconnectDevice', {'shutDown': shutDown});
  }

  Future<bool> isConnected() async {
    final connected = await _invokeCube<bool>('isConnected');
    return connected ?? false;
  }

  // ── Measurement ──

  /// [configAssetName] — optional APK asset under `android/app/src/main/assets/` (vendor `.bin`).
  ///
  /// [configAbsolutePath] — local filesystem path after a pick (e.g. [FilePicker]); passed
  /// through to Android as a readable file. Use this for `.config`/`.bin` blobs on device.
  ///
  /// [configUri] — Android `content://…` or `file://…`; use when the SAF picker only
  /// grants access via a Uri (see [FilePicker] / `getFullPath()` patterns).
  ///
  /// Source priority on Android: [configUri], then [configAbsolutePath], then
  /// [configAssetName]/[requireBundledConfig], otherwise RFID (cassette-stored config).
  Future<bool> startEvaluation({
    bool useTimer = false,
    String? configAssetName,
    bool requireBundledConfig = false,
    String? configAbsolutePath,
    String? configUri,
  }) async {
    final args = <String, dynamic>{
      'useTimer': useTimer,
      'requireBundledConfig': requireBundledConfig,
    };
    if (configAssetName != null && configAssetName.isNotEmpty) {
      args['configAssetName'] = configAssetName;
    }
    if (configAbsolutePath != null && configAbsolutePath.isNotEmpty) {
      args['configAbsolutePath'] = configAbsolutePath;
    }
    if (configUri != null && configUri.isNotEmpty) {
      args['configUri'] = configUri;
    }
    final ok = await _invokeCube<bool>('startEvaluation', args);
    return ok ?? false;
  }

  Future<bool> readDeviceDatabase() async {
    final ok = await _invokeCube<bool>('readDeviceDatabase');
    return ok ?? false;
  }

  Future<List<CubeMeasurementInfo>> getMeasurements() async {
    final raw = await _invokeCube<List<dynamic>>('getMeasurements');
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
    final ok = await _invokeCube<bool>('selectMeasurement', {'index': index});
    return ok ?? false;
  }

  Future<List<CubeResultData>> getResults() async {
    final raw = await _invokeCube<List<dynamic>>('getResults');
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
    await _invokeCube<void>('clearLocalDatabase');
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
    String? rapidTestId,
    void Function(String status)? onStatus,
    void Function(CubeStepUpdate step)? onStep,
    Duration timeout = const Duration(minutes: 20),
    bool useTimer = true,
    String? configAssetName,
    bool requireBundledConfig = false,
    String? configAbsolutePath,
    String? configUri,
  }) async {
    // Measurement must receive EventChannel payloads; route pushes can otherwise
    // race a never-subscribed engine (see logcat: startEvaluation without any
    // CubeBridge `state` / `message` lines).
    startListening();
    final flowWatch = Stopwatch()..start();
    void ft(String m) {
      if (AppConstants.cubeVerboseLogging) {
        _cubeTrace(
          'FLOW',
          '+${flowWatch.elapsedMilliseconds}ms test=$testTypeId | $m',
        );
      } else {
        _cubeTrace('FLOW', m);
      }
    }

    ft(
      'runTestAndSubmit begin useTimer=$useTimer '
      'asset=${configAssetName ?? '-'} path=${configAbsolutePath ?? '-'} uri=${configUri ?? '-'} '
      'requireBundledConfig=$requireBundledConfig timeout=${timeout.inSeconds}s',
    );

    void emitStep(CubeMeasureStep step, String label, {int? secondsLeft}) {
      ft('step=${step.name} label=$label secs=${secondsLeft ?? '-'}');
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

      if (_cubeSdkMessageIsInfo(msgType, msgCode)) {
        switch (msgCode) {
          case _imConnectionEstablished:
            ft('msg INFO IM_CONNECTION_ESTABLISHED (handshake)');
            // Handshake noise; keep waiting for cassette instructions.
            break;
          case _imDeviceDisconnected:
            ft('msg INFO IM_DEVICE_DISCONNECTED → fail');
            lastSdkError = 'Cube-Gerät getrennt';
            if (!stateCompleter.isCompleted) {
              stateCompleter.complete(false);
            }
            break;
          case _imPlaceWhite:
            ft('msg INFO IM_PLACE_WHITE');
            emitStep(CubeMeasureStep.placeWhite, 'Bitte legen Sie die weiße Kassette in das Gerät ein.');
            break;
          case _imPlaceTest:
            ft('msg INFO IM_PLACE_TEST');
            emitStep(CubeMeasureStep.placeTest, 'Bitte legen Sie die Testkassette in das Gerät ein.');
            break;
          case _imTimerRunning:
            ft('msg INFO IM_TIMER_RUNNING data=$msgData');
            final secs = msgData;
            final mins = secs ~/ 60;
            final remSecs = secs % 60;
            final timeStr = mins > 0
                ? '$mins:${remSecs.toString().padLeft(2, '0')} Min'
                : '$secs Sek';
            emitStep(CubeMeasureStep.timerRunning, 'Inkubationszeit: $timeStr verbleibend', secondsLeft: secs);
            break;
          case _imEvaluationRunning:
          case _imEvaluationReadData:
            ft('msg INFO code=$msgCode (eval/read)');
            emitStep(CubeMeasureStep.evaluating, 'Messung wird ausgewertet...');
            break;
          case _imMeasurementDone:
            measurementDoneIndex = msgData;
            ft('msg INFO IM_MEASUREMENT_DONE index=$measurementDoneIndex → complete(wait)');
            if (!stateCompleter.isCompleted) {
              stateCompleter.complete(true);
            }
            emitStep(CubeMeasureStep.readingResults, 'Messung abgeschlossen. Ergebnisse werden geladen...');
            break;
          case _imMeasureCount:
            ft('msg INFO IM_MEASURE_COUNT → dbReadCompleter ok');
            final c = dbReadCompleter;
            if (c != null && !c.isCompleted) {
              c.complete(true);
            }
            break;
          case _imDbFormatted:
            ft('msg INFO IM_DB_FORMATTED');
            break;
        }
      } else if (_cubeSdkMessageIsError(msgType)) {
        ft('msg ERROR msgType=$msgType code=$msgCode data=$msgData');
        lastSdkError = _cubeMtErrorUserMessage(msgCode, msgData);
        if (!stateCompleter.isCompleted) {
          stateCompleter.complete(false);
        }
        final c = dbReadCompleter;
        if (c != null && !c.isCompleted) {
          c.complete(false);
        }
      } else {
        ft('msg unhandled msgType=$msgType msgCode=$msgCode msgData=$msgData isInfo=${_cubeSdkMessageIsInfo(msgType, msgCode)}');
      }
    };

    // Install state listener before startEvaluation to avoid missing quick transitions.
    onStateChanged = (state) {
      ft('state callback → $state sawEvaluating=$sawEvaluating completer.done=${stateCompleter.isCompleted}');
      previousStateHandler?.call(state);

      if (state == 'ST_EVALUATE' || state == 'ST_READ') {
        sawEvaluating = true;
      }

      if (sawEvaluating && state == 'ST_IDLE') {
        if (!stateCompleter.isCompleted) {
          ft('state ST_IDLE after eval → complete(wait) true');
          stateCompleter.complete(true);
        }
      }

      if (state == 'ST_DISCONNECTED' || state == 'ST_ERROR') {
        if (!stateCompleter.isCompleted) {
          ft('state $state → complete(wait) false');
          stateCompleter.complete(false);
        }
      }
    };

    try {
      // 2. Start evaluation on the Cube device
      ft('PHASE-2 startEvaluation…');
      final evalOk = await startEvaluation(
        useTimer: useTimer,
        configAssetName: configAssetName,
        requireBundledConfig: requireBundledConfig,
        configAbsolutePath: configAbsolutePath,
        configUri: configUri,
      );
      if (!evalOk) {
        ft('PHASE-2 FAILED startEvaluation returned false');
        return CubeTestResult(
          success: false,
          error: 'Messung konnte nicht gestartet werden',
        );
      }
      ft('PHASE-2 OK startEvaluation invoked on native');

      // Don't claim we're already evaluating — wait for the SDK to send
      // its first IM_PLACE_WHITE / IM_PLACE_TEST / IM_TIMER_RUNNING /
      // IM_EVALUATION_RUNNING message. Showing "Messung wird ausgewertet"
      // before the SDK has driven the device confuses users when the SDK
      // is actually still in init/handshake and not progressing.
      emitStep(
        CubeMeasureStep.starting,
        'Warte auf Cube-Gerät … Bei Aufforderung: zuerst weiße Kassette, dann Testkassette.',
      );

      // 3. Wait for SDK completion signal/state.
      ft('PHASE-3 await measurement completion (stateCompleter) timeout=$timeout');
      final ok = await stateCompleter.future.timeout(timeout, onTimeout: () {
        ft(
          'PHASE-3 TIMEOUT after ${timeout.inSeconds}s lastSdkError=$lastSdkError '
          'measurementDoneIndex=$measurementDoneIndex sawEvaluating=$sawEvaluating',
        );
        return false;
      });

      if (!ok) {
        ft('PHASE-3 failed ok=false lastSdkError=$lastSdkError');
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Messung fehlgeschlagen oder Zeitüberschreitung',
        );
      }
      ft('PHASE-3 OK proceeding to read device DB');

      // 4. Read measurements from device database
      emitStep(CubeMeasureStep.readingResults, 'Messdaten werden geladen...');
      dbReadCompleter = Completer<bool>();
      ft('PHASE-4 readDeviceDatabase…');
      await readDeviceDatabase();
      final dbReadOk = await dbReadCompleter.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          ft('PHASE-4 TIMEOUT waiting IM_MEASURE_COUNT / dbReadCompleter');
          return false;
        },
      );
      if (!dbReadOk) {
        ft('PHASE-4 failed dbReadOk=false lastSdkError=$lastSdkError');
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Auslesen der Messdaten hat zu lange gedauert',
        );
      }
      ft('PHASE-4 OK polling getMeasurements expectedIndex=$measurementDoneIndex');
      final measurements = await _waitForMeasurements(
        expectedIndex: measurementDoneIndex,
        flowWatch: flowWatch,
      );
      ft(
        'PHASE-4 measurements count=${measurements.length} '
        '${measurements.map((m) => '[#${m.index} ${m.cfgName} ser=${m.deviceSerial}]').join(' ')}',
      );
      if (measurements.isEmpty) {
        ft('PHASE-4 ABORT empty measurements list');
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
      ft(
        'PHASE-5 selectMeasurement index=${selected.index} uid=${selected.uid} serial=${selected.deviceSerial}',
      );

      emitStep(CubeMeasureStep.readingResults, 'Ergebnisse werden geladen...');
      final selectedOk = await selectMeasurement(selected.index);
      if (!selectedOk) {
        ft('PHASE-5 FAILED selectMeasurement');
        return CubeTestResult(
          success: false,
          error: 'Messung konnte nicht ausgewählt werden',
        );
      }

      // 6. Get results
      ft('PHASE-6 _waitForResults');
      final results = await _waitForResults(flowWatch: flowWatch);
      ft('PHASE-6 results count=${results.length} summary=${results.map((r) => '${r.name}=${r.value}').join(', ')}');
      if (results.isEmpty) {
        ft('PHASE-6 ABORT no Cube result rows');
        return CubeTestResult(
          success: false,
          error: lastSdkError ?? 'Keine Ergebnisse für diese Messung verfügbar',
        );
      }

      // 7. Submit to backend
      emitStep(CubeMeasureStep.submitting, 'Ergebnisse werden übermittelt...');
      final deviceSerial = selected.deviceSerial;
      final resultString = _determineResultString(results);
      ft(
        'PHASE-7 submitCubeData resultString=$resultString deviceSerial=$deviceSerial rows=${results.length}',
      );
      final response = await _apiService.submitCubeData(
        testTypeId: testTypeId,
        rapidTestId: rapidTestId,
        deviceSerial: deviceSerial,
        measurementTimestamp: DateTime.now().millisecondsSinceEpoch,
        result: resultString,
        resultData: results.map((r) => r.toApiJson()).toList(),
      );
      ft('PHASE-7 API response=$response');

      emitStep(CubeMeasureStep.done, 'Fertig');
      ft('runTestAndSubmit SUCCESS');
      return CubeTestResult.fromJson(response);
    } catch (e, st) {
      try {
        ft('EXCEPTION in runTestAndSubmit: $e');
      } catch (_) {}
      developer.log(
        'runTestAndSubmit exception: $e',
        name: _kCubeLogScope,
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return CubeTestResult(
        success: false,
        error: 'Fehler während der Messung: $e',
      );
    } finally {
      ft('runTestAndSubmit finally: restore handlers');
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

  /// Derive overall result from Cube-provided `class` fields only.
  ///
  /// Must stay aligned with backend `CubeService.normalizeCubeResult`:
  /// no numeric thresholding, and fail closed to `INCONCLUSIVE` when class
  /// is missing/unknown (never invent POSITIVE/NEGATIVE from `value`).
  String _determineResultString(List<CubeResultData> results) {
    for (final r in results) {
      final cls = r.resultClass.toUpperCase();
      if (cls == 'POSITIVE' || cls == 'POS') return 'POSITIVE';
      if (cls == 'NEGATIVE' || cls == 'NEG') return 'NEGATIVE';
      if (cls == 'INVALID') return 'INVALID';
      if (cls == 'INCONCLUSIVE') return 'INCONCLUSIVE';
    }
    return 'INCONCLUSIVE';
  }

  Future<List<CubeMeasurementInfo>> _waitForMeasurements({
    int? expectedIndex,
    Duration timeout = const Duration(seconds: 20),
    Duration pollInterval = const Duration(milliseconds: 300),
    Stopwatch? flowWatch,
  }) async {
    final deadline = DateTime.now().add(timeout);
    List<CubeMeasurementInfo> latest = [];
    var poll = 0;
    while (DateTime.now().isBefore(deadline)) {
      poll++;
      latest = await getMeasurements();
      if (AppConstants.cubeVerboseLogging &&
          (poll == 1 || poll % 6 == 0 || latest.isNotEmpty)) {
        final ms = flowWatch?.elapsedMilliseconds;
        _cubeTracePoll(
          '+${ms ?? '?'}ms getMeasurements poll#$poll n=${latest.length} '
          'expectedIdx=$expectedIndex '
          '${latest.map((m) => '[${m.index}:${m.cfgName}]').take(4).join(' ')}',
        );
      }
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
    Stopwatch? flowWatch,
  }) async {
    final deadline = DateTime.now().add(timeout);
    List<CubeResultData> latest = [];
    var poll = 0;
    while (DateTime.now().isBefore(deadline)) {
      poll++;
      latest = await getResults();
      if (AppConstants.cubeVerboseLogging &&
          (poll == 1 || poll % 5 == 0 || latest.isNotEmpty)) {
        final ms = flowWatch?.elapsedMilliseconds;
        _cubeTracePoll(
          '+${ms ?? '?'}ms getResults poll#$poll n=${latest.length}',
        );
      }
      if (latest.isNotEmpty) return latest;
      await Future.delayed(pollInterval);
    }
    return latest;
  }
}
