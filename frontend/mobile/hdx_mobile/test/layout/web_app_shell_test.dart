import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/l10n/app_localizations.dart';
import 'package:hdx_mobile/layout/web_app_shell.dart';
import 'package:hdx_mobile/providers/auth_provider.dart';
import 'package:hdx_mobile/services/auth_service.dart';
import 'package:hdx_mobile/core/api_service.dart';
import 'package:provider/provider.dart';

/// Renders the real shell at a given width. Without a stored login the role is
/// the patient area, which is the label the test checks.
Future<void> _pumpShell(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  final auth = AuthProvider(AuthService(ApiService(baseUrl: 'http://127.0.0.1:4000')));
  final router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => WebAppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text('Inhalt')),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp.router(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('wide layout keeps the sidebar and shows the area as text', (tester) async {
    await _pumpShell(tester, const Size(1200, 900));
    expect(find.text('Patientenbereich'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Inhalt'), findsOneWidget);
  });

  testWidgets('narrow layout moves the sidebar into a drawer and shows the area in the app bar', (tester) async {
    await _pumpShell(tester, const Size(390, 844));
    expect(find.text('Inhalt'), findsOneWidget);
    expect(find.textContaining('Patientenbereich'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The sidebar is not on screen until the menu opens it.
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Patientenbereich'), findsOneWidget);
  });
}
