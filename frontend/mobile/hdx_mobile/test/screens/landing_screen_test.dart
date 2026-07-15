import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/providers/locale_provider.dart';
import 'package:hdx_mobile/screens/landing_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('LandingScreen shows hero and auth CTAs', (tester) async {
    final localeProvider = LocaleProvider();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, state) => LandingScreen(
            initialSection: state.uri.queryParameters['section'],
          ),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, __) => const Scaffold(body: Text('Signup')),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(body: Text('Login')),
        ),
        GoRoute(
          path: '/about',
          redirect: (_, __) => '/?section=about',
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<LocaleProvider>.value(
        value: localeProvider,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gesundheitstests\nund Online-Versorgung'), findsOneWidget);
    expect(find.text('Jetzt starten'), findsOneWidget);
    expect(find.text('Für Patienten'), findsOneWidget);
    expect(find.text('Testergebnisse & Videoberatung'), findsOneWidget);
    expect(find.text('Cube Schnelltests'), findsNothing);
    expect(find.text('Anmelden'), findsOneWidget);

    await tester.tap(find.text('Anmelden'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrieren'));
    await tester.pumpAndSettle();
    expect(find.text('Signup'), findsOneWidget);
  });
}
