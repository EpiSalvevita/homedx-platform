import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/screens/test_submission_screen.dart';
import 'package:hdx_mobile/services/api_service.dart';
import 'package:provider/provider.dart';

class _SubmissionMockApi extends ApiService {
  _SubmissionMockApi() : super(baseUrl: 'http://mock');

  int finalizeCalls = 0;

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    if (endpoint == 'finalize-test-submission') {
      finalizeCalls++;
      return {'success': true};
    }
    return {'success': false};
  }
}

void main() {
  testWidgets('submission screen shows steps and requires agreement', (tester) async {
    final api = _SubmissionMockApi();
    final router = GoRouter(
      initialLocation: '/submission',
      routes: [
        GoRoute(
          path: '/submission',
          builder: (_, __) => const TestSubmissionScreen(
            testTypeId: 'rheumacheck',
            testTypeName: 'RheumaCheck',
            rapidTestId: 'rt-1',
            cubeResult: 'NEGATIVE',
          ),
        ),
        GoRoute(
          path: '/results',
          builder: (_, __) => const Scaffold(body: Text('Results')),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      Provider<ApiService>.value(
        value: api,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test abschließen'), findsOneWidget);
    expect(find.text('RheumaCheck'), findsOneWidget);
    expect(find.text('Cube-Ergebnis: NEGATIVE'), findsOneWidget);
    expect(find.text('Testfoto (optional)'), findsOneWidget);
    expect(find.text('Ausweis Vorderseite'), findsOneWidget);

    final submit = find.text('Test absenden');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Bitte stimmen Sie den Bedingungen zu.'), findsOneWidget);
    expect(api.finalizeCalls, 0);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(api.finalizeCalls, 1);
    expect(find.text('Results'), findsOneWidget);
  });
}
