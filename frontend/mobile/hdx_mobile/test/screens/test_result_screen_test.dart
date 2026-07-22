import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/screens/test_result_screen.dart';
import 'package:hdx_mobile/features/cube/cube_service.dart';

/// Helper that pumps [child] inside a minimal GoRouter, capturing the
/// last pushed location so tests can assert on navigation.
Future<List<String>> _pumpWithRouter(
  WidgetTester tester,
  Widget child,
) async {
  final pushed = <String>[];
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
        path: '/doctors',
        builder: (context, state) {
          pushed.add(state.uri.toString());
          return const Scaffold(body: Text('doctors-stub'));
        },
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return pushed;
}

void main() {
  testWidgets(
      'shows "Termin mit Facharzt buchen" CTA when the result is positive',
      (tester) async {
    final pushed = await _pumpWithRouter(
      tester,
      TestResultScreen(
        testTypeName: 'RheumaCheck',
        testTypeId: 'rheumacheck',
        result: CubeTestResult(success: true, result: 'POSITIVE'),
      ),
    );

    expect(find.byKey(const Key('book-specialist-cta')), findsOneWidget);
    expect(find.text('Termin mit Facharzt buchen'), findsOneWidget);
    expect(find.text('Empfohlen: Rheumatologie'), findsOneWidget);
    expect(pushed, isEmpty);
  });

  testWidgets('hides the booking CTA on a negative result', (tester) async {
    await _pumpWithRouter(
      tester,
      TestResultScreen(
        testTypeName: 'RheumaCheck',
        testTypeId: 'rheumacheck',
        result: CubeTestResult(success: true, result: 'NEGATIVE'),
      ),
    );

    expect(find.byKey(const Key('book-specialist-cta')), findsNothing);
    expect(find.text('Termin mit Facharzt buchen'), findsNothing);
  });

  testWidgets(
      'tapping the CTA pushes /doctors with the testTypeId query param',
      (tester) async {
    final pushed = await _pumpWithRouter(
      tester,
      TestResultScreen(
        testTypeName: 'RheumaCheck',
        testTypeId: 'rheumacheck',
        result: CubeTestResult(success: true, result: 'POSITIVE'),
      ),
    );

    await tester.tap(find.byKey(const Key('book-specialist-cta')));
    await tester.pumpAndSettle();

    expect(pushed, hasLength(1));
    final uri = Uri.parse(pushed.single);
    expect(uri.path, '/doctors');
    expect(uri.queryParameters['testTypeId'], 'rheumacheck');
    expect(uri.queryParameters['testTypeName'], 'RheumaCheck');
  });

  testWidgets('falls back to a generalist label when testTypeId is unknown',
      (tester) async {
    await _pumpWithRouter(
      tester,
      TestResultScreen(
        testTypeName: 'Mystery Test',
        testTypeId: 'mystery-test',
        result: CubeTestResult(success: true, result: 'POSITIVE'),
      ),
    );

    expect(find.text('Empfohlen: Allgemeinmedizin'), findsOneWidget);
  });

  testWidgets('shows Cube SDK validity labels on detailed result rows',
      (tester) async {
    await _pumpWithRouter(
      tester,
      TestResultScreen(
        testTypeName: 'CRP',
        testTypeId: 'crp',
        result: CubeTestResult(
          success: true,
          result: 'NEGATIVE',
          resultData: [
            CubeResultData(
              name: 'CRP',
              value: '3.2',
              unit: 'mg/L',
              resultClass: 'NEG',
              validity: 0,
            ),
            CubeResultData(
              name: 'Control',
              value: '—',
              unit: '',
              resultClass: '',
              validity: 3,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Gültig'), findsOneWidget);
    expect(find.text('Ungültig'), findsOneWidget);
    expect(find.text('Unklar'), findsNothing);
  });
}
