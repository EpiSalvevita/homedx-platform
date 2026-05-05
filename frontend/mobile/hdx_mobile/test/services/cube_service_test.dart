import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/services/api_service.dart';
import 'package:hdx_mobile/services/cube_service.dart';

import 'cube_test_harness.dart';

/// In-memory ApiService double. We inherit from the real class instead of
/// using a mock library so the type still satisfies CubeService's
/// constructor parameter without any runtime stubbing.
class _FakeApiService extends ApiService {
  _FakeApiService() : super(baseUrl: 'http://test', authToken: 'tok');

  Map<String, dynamic>? lastBody;
  Map<String, dynamic> nextResponse = {
    'success': true,
    'testId': 'test-123',
    'result': 'POSITIVE',
  };
  int callCount = 0;

  @override
  Future<Map<String, dynamic>> submitCubeData({
    required String testTypeId,
    List<int>? rawData,
    String? deviceSerial,
    int? measurementTimestamp,
    String? result,
    List<Map<String, dynamic>>? resultData,
  }) async {
    callCount++;
    lastBody = {
      'testTypeId': testTypeId,
      'rawData': rawData,
      'deviceSerial': deviceSerial,
      'measurementTimestamp': measurementTimestamp,
      'result': result,
      'resultData': resultData,
    };
    return nextResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CubeChannelHarness harness;
  late _FakeApiService api;
  late CubeService cube;

  setUp(() {
    harness = CubeChannelHarness();
    api = _FakeApiService();
    cube = CubeService(api);
  });

  tearDown(() {
    cube.stopListening();
    harness.dispose();
  });

  // ─────────────────────────────────────────────────────────────────────
  // EventChannel → callback dispatch
  // ─────────────────────────────────────────────────────────────────────

  group('EventChannel dispatch', () {
    test('"state" events fire onStateChanged', () async {
      String? seen;
      cube.onStateChanged = (s) => seen = s;
      cube.startListening();

      await harness.pushEvent({'type': 'state', 'state': 'ST_IDLE'});

      expect(seen, 'ST_IDLE');
    });

    test('missing state defaults to ST_DISCONNECTED', () async {
      String? seen;
      cube.onStateChanged = (s) => seen = s;
      cube.startListening();

      await harness.pushEvent({'type': 'state'});

      expect(seen, 'ST_DISCONNECTED');
    });

    test('"devices" events parse name + commType + index', () async {
      List<CubeDeviceInfo>? seen;
      cube.onDevicesUpdated = (d) => seen = d;
      cube.startListening();

      await harness.pushEvent({
        'type': 'devices',
        'devices': [
          {'name': 'Cube-001', 'commType': 'BLUETOOTH_LE', 'index': 0},
          {'name': 'Cube-002', 'commType': 'BLUETOOTH', 'index': 1},
        ],
      });

      expect(seen, isNotNull);
      expect(seen!.length, 2);
      expect(seen![0].name, 'Cube-001');
      expect(seen![0].commType, 'BLUETOOTH_LE');
      expect(seen![0].index, 0);
      expect(seen![1].name, 'Cube-002');
      expect(seen![1].index, 1);
    });

    test('"message" events parse msgType/msgCode/msgData', () async {
      String? type;
      int? code;
      int? data;
      cube.onMessage = (t, c, d) {
        type = t;
        code = c;
        data = d;
      };
      cube.startListening();

      await harness.pushEvent({
        'type': 'message',
        'msgType': 'MT_INFO',
        'msgCode': 0x02, // IM_TIMER_RUNNING
        'msgData': 75,
      });

      expect(type, 'MT_INFO');
      expect(code, 0x02);
      expect(data, 75);
    });

    test('"results" events deserialize CubeResultData fields', () async {
      List<CubeResultData>? seen;
      cube.onResultsReady = (r) => seen = r;
      cube.startListening();

      await harness.pushEvent({
        'type': 'results',
        'results': [
          {
            'name': 'Rheuma',
            'value': '1.23',
            'unit': 'mg/L',
            'class': 'POSITIVE',
            'validity': 1,
          },
        ],
      });

      expect(seen, isNotNull);
      expect(seen!.length, 1);
      expect(seen![0].name, 'Rheuma');
      expect(seen![0].value, '1.23');
      expect(seen![0].unit, 'mg/L');
      expect(seen![0].resultClass, 'POSITIVE');
      expect(seen![0].validity, 1);
    });

    test('unknown event types are silently ignored', () async {
      var stateCalls = 0;
      cube.onStateChanged = (_) => stateCalls++;
      cube.startListening();

      await harness.pushEvent({'type': 'something_new', 'foo': 'bar'});

      expect(stateCalls, 0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // MethodChannel-backed getters
  // ─────────────────────────────────────────────────────────────────────

  group('MethodChannel calls', () {
    test('getVersion returns SDK string', () async {
      harness.answerMethod('getVersion', '1.2.3');
      expect(await cube.getVersion(), '1.2.3');
    });

    test('getVersion handles null gracefully', () async {
      harness.answerMethod('getVersion', null);
      expect(await cube.getVersion(), '');
    });

    test('licenseValid returns false when null', () async {
      harness.answerMethod('licenseValid', null);
      expect(await cube.licenseValid(), false);
    });

    test('startScan forwards timeout argument', () async {
      harness.answerMethod('startScan', true);

      final ok = await cube.startScan(timeoutMs: 9000);

      expect(ok, true);
      final call = harness.calls.singleWhere((c) => c.method == 'startScan');
      expect(call.arguments, {'timeoutMs': 9000});
    });

    test('connectDevice forwards index and disableButton', () async {
      harness.answerMethod('connectDevice', true);

      final ok = await cube.connectDevice(2, disableButton: true);

      expect(ok, true);
      final call = harness.calls.singleWhere((c) => c.method == 'connectDevice');
      expect(call.arguments, {'index': 2, 'disableButton': true});
    });

    test('startEvaluation forwards useTimer + configAssetName', () async {
      harness.answerMethod('startEvaluation', true);

      await cube.startEvaluation(
        useTimer: true,
        configAssetName: 'cube_test_config.bin',
        requireBundledConfig: true,
      );

      final call =
          harness.calls.singleWhere((c) => c.method == 'startEvaluation');
      expect(call.arguments, {
        'useTimer': true,
        'requireBundledConfig': true,
        'configAssetName': 'cube_test_config.bin',
      });
    });

    test('startEvaluation omits configAssetName when not provided', () async {
      harness.answerMethod('startEvaluation', true);

      await cube.startEvaluation(useTimer: false);

      final call =
          harness.calls.singleWhere((c) => c.method == 'startEvaluation');
      expect(call.arguments, {
        'useTimer': false,
        'requireBundledConfig': false,
      });
    });

    test('getMeasurements parses list and coerces numeric fields', () async {
      harness.answerMethod('getMeasurements', [
        {
          'index': 5,
          'uid': 'UID-1',
          'deviceSerial': 'SN-123',
          'dateTime': '2026-05-05T12:00:00Z',
          'temperature': 22.5,
          'cfgName': 'Rheuma',
        },
      ]);

      final list = await cube.getMeasurements();

      expect(list, hasLength(1));
      expect(list.first.index, 5);
      expect(list.first.deviceSerial, 'SN-123');
      expect(list.first.temperature, 22.5);
    });

    test('getResults parses class field as resultClass', () async {
      harness.answerMethod('getResults', [
        {
          'name': 'COVID',
          'value': '0.1',
          'unit': '',
          'class': 'NEGATIVE',
          'validity': 1,
        },
      ]);

      final results = await cube.getResults();

      expect(results, hasLength(1));
      expect(results.first.resultClass, 'NEGATIVE');
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // submitResults — covers _determineResultString indirectly
  // ─────────────────────────────────────────────────────────────────────

  group('submitResults / _determineResultString', () {
    test('classifies POSITIVE on explicit class', () async {
      harness.answerMethod('getResults', [
        {'class': 'POSITIVE', 'name': 'X', 'value': '0', 'unit': '', 'validity': 1},
      ]);

      final out = await cube.submitResults(
        testTypeId: 'rheumacheck',
        deviceSerial: 'SN-1',
      );

      expect(out.success, true);
      expect(api.lastBody!['result'], 'POSITIVE');
      expect(api.lastBody!['testTypeId'], 'rheumacheck');
      expect(api.lastBody!['deviceSerial'], 'SN-1');
    });

    test('accepts short-form POS / NEG class strings', () async {
      harness.answerMethod('getResults', [
        {'class': 'POS', 'name': 'X', 'value': '0', 'unit': '', 'validity': 1},
      ]);

      await cube.submitResults(testTypeId: 't');
      expect(api.lastBody!['result'], 'POSITIVE');

      harness.answerMethod('getResults', [
        {'class': 'NEG', 'name': 'X', 'value': '0', 'unit': '', 'validity': 1},
      ]);
      await cube.submitResults(testTypeId: 't');
      expect(api.lastBody!['result'], 'NEGATIVE');
    });

    test('falls back to numeric value > 0.5 when class missing', () async {
      harness.answerMethod('getResults', [
        {'class': '', 'name': 'X', 'value': '0.9', 'unit': '', 'validity': 1},
      ]);

      await cube.submitResults(testTypeId: 't');
      expect(api.lastBody!['result'], 'POSITIVE');
    });

    test('defaults to NEGATIVE when nothing classifies', () async {
      harness.answerMethod('getResults', [
        {'class': '', 'name': 'X', 'value': '0.1', 'unit': '', 'validity': 1},
      ]);

      await cube.submitResults(testTypeId: 't');
      expect(api.lastBody!['result'], 'NEGATIVE');
    });

    test('returns failure CubeTestResult when no results available', () async {
      harness.answerMethod('getResults', []);

      final out = await cube.submitResults(testTypeId: 't');

      expect(out.success, false);
      expect(out.error, contains('No Cube results'));
      expect(api.callCount, 0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // runTestAndSubmit — full orchestration
  // ─────────────────────────────────────────────────────────────────────

  group('runTestAndSubmit', () {
    test('drives placeWhite → placeTest → timer → evaluate → done → submit', () async {
      // Wire happy-path MethodChannel responses.
      harness.answerMethod('startEvaluation', true);
      harness.answerMethod('readDeviceDatabase', true);
      harness.answerMethod('selectMeasurement', true);
      harness.answerMethod('getMeasurements', [
        {
          'index': 7,
          'uid': 'UID-7',
          'deviceSerial': 'SN-007',
          'dateTime': '2026-05-05T12:00:00Z',
          'temperature': 22.0,
          'cfgName': 'Rheuma',
        },
      ]);
      harness.answerMethod('getResults', [
        {
          'class': 'POSITIVE',
          'name': 'Rheuma',
          'value': '1.0',
          'unit': 'mg/L',
          'validity': 1,
        },
      ]);

      final steps = <CubeMeasureStep>[];
      cube.startListening();

      // Run the orchestration concurrently with our event injection.
      final future = cube.runTestAndSubmit(
        testTypeId: 'rheumacheck',
        onStep: (s) => steps.add(s.step),
      );

      // Give CubeService a moment to install its message/state listeners
      // and start the evaluation MethodChannel call.
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Simulate the SDK message stream the Cube device would send.
      Future<void> push(int code, {int data = 0}) => harness.pushEvent({
            'type': 'message',
            'msgType': 'MT_INFO',
            'msgCode': code,
            'msgData': data,
          });

      await push(0x00); // IM_PLACE_WHITE
      await push(0x01); // IM_PLACE_TEST
      await push(0x02, data: 30); // IM_TIMER_RUNNING (30s remaining)
      await push(0x03); // IM_EVALUATION_RUNNING
      await push(0x04, data: 7); // IM_MEASUREMENT_DONE on slot 7
      // Allow stateCompleter to resolve and CubeService to call readDeviceDatabase.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await push(0x09); // IM_MEASURE_COUNT (database read complete)

      final result = await future;

      // Result derived from the fake ApiService response.
      expect(result.success, true);
      expect(result.result, 'POSITIVE');

      // Backend received the right payload.
      expect(api.lastBody!['testTypeId'], 'rheumacheck');
      expect(api.lastBody!['deviceSerial'], 'SN-007');
      expect(api.lastBody!['result'], 'POSITIVE');
      expect((api.lastBody!['resultData'] as List).first['name'], 'Rheuma');

      // Step machine progressed through every phase.
      expect(steps, contains(CubeMeasureStep.starting));
      expect(steps, contains(CubeMeasureStep.placeWhite));
      expect(steps, contains(CubeMeasureStep.placeTest));
      expect(steps, contains(CubeMeasureStep.timerRunning));
      expect(steps, contains(CubeMeasureStep.evaluating));
      expect(steps, contains(CubeMeasureStep.readingResults));
      expect(steps, contains(CubeMeasureStep.submitting));
      expect(steps, contains(CubeMeasureStep.done));

      // useTimer defaults to true.
      final evalCall =
          harness.calls.singleWhere((c) => c.method == 'startEvaluation');
      expect((evalCall.arguments as Map)['useTimer'], true);
    });

    test('returns error when startEvaluation fails', () async {
      harness.answerMethod('startEvaluation', false);
      cube.startListening();

      final result = await cube.runTestAndSubmit(testTypeId: 'rheumacheck');

      expect(result.success, false);
      expect(result.error, contains('Messung konnte nicht gestartet'));
      expect(api.callCount, 0);
    });

    test('reports SDK error message when MT_ERROR arrives', () async {
      harness.answerMethod('startEvaluation', true);
      cube.startListening();

      final future = cube.runTestAndSubmit(testTypeId: 'rheumacheck');
      await Future<void>.delayed(const Duration(milliseconds: 30));

      await harness.pushEvent({
        'type': 'message',
        'msgType': 'MT_ERROR',
        'msgCode': 42,
        'msgData': 1,
      });

      final result = await future;

      expect(result.success, false);
      expect(result.error, contains('Code 42'));
      expect(api.callCount, 0);
    });

    test('forwards useTimer=false when caller opts out', () async {
      harness.answerMethod('startEvaluation', true);
      // We don't progress past startEvaluation — just inspect the args and
      // then end the run via an SDK error so the test exits quickly.
      cube.startListening();

      final future = cube.runTestAndSubmit(
        testTypeId: 't',
        useTimer: false,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await harness.pushEvent({
        'type': 'message',
        'msgType': 'MT_ERROR',
        'msgCode': 1,
        'msgData': 0,
      });
      await future;

      final evalCall =
          harness.calls.singleWhere((c) => c.method == 'startEvaluation');
      expect((evalCall.arguments as Map)['useTimer'], false);
    });
  });
}
