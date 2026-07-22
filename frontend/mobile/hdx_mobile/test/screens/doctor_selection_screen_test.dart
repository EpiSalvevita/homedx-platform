import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/screens/doctor_selection_screen.dart';
import 'package:hdx_mobile/core/api_service.dart';
import 'package:hdx_mobile/services/doctor_service.dart';
import 'package:provider/provider.dart';
import '../helpers/mock_api_service.dart';

Future<List<String>> _pumpScreen(
  WidgetTester tester, {
  String? testTypeId,
  String? testTypeName,
}) async {
  final pushed = <String>[];
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => DoctorSelectionScreen(
          testTypeId: testTypeId,
          testTypeName: testTypeName,
        ),
      ),
      GoRoute(
        path: '/doctors/:doctorId/appointment',
        builder: (context, state) {
          pushed.add(state.uri.toString());
          return const Scaffold(body: Text('booking-stub'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    Provider<ApiService>.value(
      value: MockApiService(),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return pushed;
}

void main() {
  testWidgets(
      'rheumacheck context shows only the Rheumatologie specialist',
      (tester) async {
    await _pumpScreen(
      tester,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    );

    expect(find.byKey(const Key('doctor-selection-test-banner')), findsOneWidget);
    expect(find.textContaining('Empfohlene Fachärzte: Rheumatologie'),
        findsOneWidget);

    expect(find.text('Dr. Klaus Becker'), findsOneWidget);
    expect(find.text('Rheumatologie'), findsOneWidget);
    expect(find.text('Dr. Sarah Müller'), findsNothing);
  });

  testWidgets('without testTypeId, no banner is shown and the first doctors render',
      (tester) async {
    await _pumpScreen(tester);

    expect(find.byKey(const Key('doctor-selection-test-banner')), findsNothing);

    final mock = DoctorService.mockDoctors();
    expect(find.text(mock[0].name), findsOneWidget);
    expect(find.text(mock[1].name), findsOneWidget);
  });

  testWidgets(
      'tapping a doctor card forwards testTypeId to the booking screen',
      (tester) async {
    final pushed = await _pumpScreen(
      tester,
      testTypeId: 'rheumacheck',
      testTypeName: 'RheumaCheck',
    );

    await tester.tap(find.text('Dr. Klaus Becker'));
    await tester.pumpAndSettle();

    expect(pushed, hasLength(1));
    final uri = Uri.parse(pushed.single);
    expect(uri.path, '/doctors/doc6/appointment');
    expect(uri.queryParameters['testTypeId'], 'rheumacheck');
    expect(uri.queryParameters['testTypeName'], 'RheumaCheck');
    expect(uri.queryParameters['specialization'], 'Rheumatologie');
  });

  testWidgets('language filter shows only doctors speaking selected language',
      (tester) async {
    await _pumpScreen(tester);

    expect(find.text('Sprache'), findsOneWidget);
    expect(find.byKey(const ValueKey('doctor-lang-filter-Deutsch')), findsOneWidget);
    expect(find.byKey(const ValueKey('doctor-lang-filter-Englisch')), findsOneWidget);

    expect(find.byKey(const ValueKey('doctor-lang-filter-Türkisch')), findsOneWidget);
    expect(find.byKey(const ValueKey('doctor-lang-filter-Arabisch')), findsOneWidget);
    expect(find.byKey(const ValueKey('doctor-lang-filter-Russisch')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('doctor-lang-filter-Türkisch')));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Sarah Müller'), findsOneWidget);
    expect(find.text('Dr. Klaus Becker'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('doctor-lang-filter-Englisch')));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Sarah Müller'), findsOneWidget);
    expect(find.text('Dr. Klaus Becker'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('doctor-lang-filter-all')));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Klaus Becker'), findsOneWidget);
  });
}
