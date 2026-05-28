import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/screens/test_progress_screen.dart';
import 'package:hdx_mobile/services/api_service.dart';
import 'package:hdx_mobile/services/cube_service.dart';

class _FakeApiService extends ApiService {
  _FakeApiService() : super(baseUrl: 'http://test', authToken: 'tok');
}

/// Subclassed CubeService that captures the onStep callback and exposes a
/// completer for the test to resolve runTestAndSubmit on demand.
class _FakeCubeService extends CubeService {
  _FakeCubeService(super.api);

  Completer<CubeTestResult> nextResult = Completer<CubeTestResult>();
  void Function(CubeStepUpdate step)? capturedOnStep;
  int runCount = 0;
  bool? lastUseTimer;
  String? lastConfigAssetName;

  @override
  Future<CubeTestResult> runTestAndSubmit({
    required String testTypeId,
    void Function(String status)? onStatus,
    void Function(CubeStepUpdate step)? onStep,
    Duration timeout = const Duration(minutes: 20),
    bool useTimer = true,
    String? configAssetName,
    bool requireBundledConfig = false,
    String? configAbsolutePath,
    String? configUri,
  }) {
    runCount++;
    lastUseTimer = useTimer;
    lastConfigAssetName = configAssetName;
    capturedOnStep = onStep;
    return nextResult.future;
  }
}

void main() {
  late _FakeCubeService fake;

  setUp(() {
    fake = _FakeCubeService(_FakeApiService());
  });

  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the starting label on initial frame', (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    )));

    // initState fires _startMeasurement which awaits the fake completer; the
    // first frame still shows the placeholder set in state init.
    expect(find.text('Messung wird vorbereitet...'), findsOneWidget);
    expect(find.text('RheumaCheck'), findsOneWidget); // AppBar title
  });

  testWidgets('forwards useTimer flag to CubeService', (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 't',
      testTypeName: 'X',
      useTimer: false,
    )));

    expect(fake.runCount, 1);
    expect(fake.lastUseTimer, false);
  });

  testWidgets('crp test forwards bundled CRP asset to CubeService',
      (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'crp',
      testTypeName: 'CRP',
    )));
    await tester.pump();

    expect(fake.runCount, 1);
    expect(fake.lastConfigAssetName, 'CRP_250702_216.bin');
  });

  testWidgets('picked config path overrides bundled asset for crp',
      (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'crp',
      testTypeName: 'CRP',
      cubeConfigAbsolutePath: '/storage/foo.bin',
    )));
    await tester.pump();

    expect(fake.lastConfigAssetName, isNull);
  });

  testWidgets('placeWhite step swaps active label and icon', (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    )));

    // Wait for initState's microtask to install capturedOnStep.
    await tester.pump();
    expect(fake.capturedOnStep, isNotNull);

    fake.capturedOnStep!(const CubeStepUpdate(
      step: CubeMeasureStep.placeWhite,
      label: 'Bitte legen Sie die weiße Kassette in das Gerät ein.',
    ));
    await tester.pump();

    expect(
      find.text('Bitte legen Sie die weiße Kassette in das Gerät ein.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
  });

  testWidgets('timerRunning step formats and displays MM:SS', (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    )));
    await tester.pump();

    fake.capturedOnStep!(const CubeStepUpdate(
      step: CubeMeasureStep.timerRunning,
      label: 'Inkubationszeit: 1:30 Min verbleibend',
      secondsLeft: 90,
    ));
    await tester.pump();

    expect(find.text('01:30'), findsOneWidget);
    expect(find.text('verbleibend'), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);
  });

  testWidgets('failure result switches to error UI with retry button',
      (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    )));
    await tester.pump();

    fake.nextResult.complete(CubeTestResult(
      success: false,
      error: 'Cube SDK Fehler: Code 42',
    ));
    // The pulse animation keeps scheduling frames, so pumpAndSettle would
    // deadlock. Use runAsync to actually let the awaited future resume,
    // then pump one frame to render the resulting setState.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('Messung fehlgeschlagen'), findsOneWidget);
    expect(find.text('Cube SDK Fehler: Code 42'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('tapping "Erneut versuchen" re-runs the measurement',
      (tester) async {
    await tester.pumpWidget(wrap(TestProgressScreen(
      cubeService: fake,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    )));
    await tester.pump();
    expect(fake.runCount, 1);

    fake.nextResult.complete(CubeTestResult(success: false, error: 'boom'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    // Replace the completer so the second run can be tracked independently.
    fake.nextResult = Completer<CubeTestResult>();

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();

    expect(fake.runCount, 2);
    // After the retry, the screen should be back in the in-progress UI.
    expect(find.text('Messung fehlgeschlagen'), findsNothing);
    expect(find.text('Messung wird vorbereitet...'), findsOneWidget);
  });
}
