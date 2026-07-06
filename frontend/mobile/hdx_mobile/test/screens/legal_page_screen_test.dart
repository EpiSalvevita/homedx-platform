import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/screens/legal_page_screen.dart';
import 'package:hdx_mobile/services/api_service.dart';
import 'package:provider/provider.dart';

class _LegalMockApi extends ApiService {
  _LegalMockApi() : super(baseUrl: 'http://mock');

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    if (endpoint == 'get-legal-page' && body?['type'] == 'TERMS_CONDITIONS') {
      return {
        'success': true,
        'legalPage': {
          'type': 'TERMS_CONDITIONS',
          'title': 'Testbedingungen',
          'content': 'Beispieltext der Testbedingungen.',
          'language': 'de',
        },
      };
    }
    return {'success': false, 'error': 'not found'};
  }
}

void main() {
  testWidgets('renders fetched legal page title and content', (tester) async {
    final api = _LegalMockApi();
    final router = GoRouter(
      initialLocation: '/legal/TERMS_CONDITIONS',
      routes: [
        GoRoute(
          path: '/legal/:type',
          builder: (context, state) =>
              LegalPageScreen(type: state.pathParameters['type'] ?? ''),
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

    expect(find.text('Testbedingungen'), findsWidgets);
    expect(find.text('Beispieltext der Testbedingungen.'), findsOneWidget);
  });

  testWidgets('shows an error message when the page cannot be loaded', (tester) async {
    final api = _LegalMockApi();
    final router = GoRouter(
      initialLocation: '/legal/PRIVACY_POLICY',
      routes: [
        GoRoute(
          path: '/legal/:type',
          builder: (context, state) =>
              LegalPageScreen(type: state.pathParameters['type'] ?? ''),
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

    expect(find.text('not found'), findsOneWidget);
  });
}
