import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/screens/doctor_selection_screen.dart';
import 'package:hdx_mobile/services/doctor_service.dart';

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

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  // Allow the simulated 500ms API delay in DoctorService to complete.
  await tester.pumpAndSettle(const Duration(milliseconds: 600));
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

    // Specialist visible.
    expect(find.text('Dr. Klaus Becker'), findsOneWidget);
    expect(find.text('Rheumatologie'), findsOneWidget);

    // Off-specialty doctors filtered out.
    expect(find.text('Dr. Thomas Fischer'), findsNothing); // Dermatologie
    expect(find.text('Dr. Anna Weber'), findsNothing); // Kardiologie
  });

  testWidgets('without testTypeId, no banner is shown and the first doctors render',
      (tester) async {
    await _pumpScreen(tester);

    expect(find.byKey(const Key('doctor-selection-test-banner')), findsNothing);

    // The first few mock doctors should be present in the (lazy) ListView.
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
}
