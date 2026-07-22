import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/screens/certificates_list_screen.dart';
import 'package:hdx_mobile/core/api_service.dart';
import 'package:provider/provider.dart';

/// Previously untested (see docs/regulatory/gap-assessment.md §1) and
/// unreachable in the app (no router entry). This is a smoke test for the
/// list rendering, not a full regression suite for the certificate feature.
class _CertificatesMockApi extends ApiService {
  _CertificatesMockApi() : super(baseUrl: 'http://mock');

  bool overrideEmpty = false;

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    if (endpoint == 'list-certificates' && overrideEmpty) {
      return {'success': true, 'certificates': []};
    }
    if (endpoint == 'list-certificates') {
      return {
        'success': true,
        'certificates': [
          {
            'id': 'cert-1',
            'certificateNumber': 'HDX-1',
            'type': 'TEST_RESULT',
            'status': 'ISSUED',
            'rapidTestId': 'rt-1',
            'testTypeId': 'rheumacheck',
            'testResult': 'POSITIVE',
            'issuedAt': '2026-01-01T00:00:00.000Z',
            'validFrom': '2026-01-01T00:00:00.000Z',
            'validUntil': '2026-06-30T00:00:00.000Z',
          },
        ],
      };
    }
    return {'success': false};
  }
}

void main() {
  testWidgets('renders the list of certificates returned by the API', (tester) async {
    final api = _CertificatesMockApi();
    final router = GoRouter(
      initialLocation: '/certificates',
      routes: [
        GoRoute(
          path: '/certificates',
          builder: (context, state) => const CertificatesListScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      Provider<ApiService>.value(
        value: api,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HDX-1'), findsOneWidget);
    expect(find.text('rheumacheck · POSITIVE'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no certificates', (tester) async {
    final api = _CertificatesMockApi();
    final router = GoRouter(
      initialLocation: '/certificates',
      routes: [
        GoRoute(
          path: '/certificates',
          builder: (context, state) => const CertificatesListScreen(),
        ),
      ],
    );

    // Override list-certificates to return an empty list for this case.
    api.overrideEmpty = true;

    await tester.pumpWidget(
      Provider<ApiService>.value(
        value: api,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Zertifikate'), findsOneWidget);
  });
}
