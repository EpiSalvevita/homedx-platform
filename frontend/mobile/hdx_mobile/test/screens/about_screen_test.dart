import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/config/auth_routes.dart';
import 'package:hdx_mobile/providers/locale_provider.dart';
import 'package:hdx_mobile/screens/landing_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _landingTestApp({required LocaleProvider localeProvider, required GoRouter router}) {
  return ChangeNotifierProvider<LocaleProvider>.value(
    value: localeProvider,
    child: Consumer<LocaleProvider>(
      builder: (context, lp, _) => MaterialApp.router(
        locale: lp.locale,
        routerConfig: router,
      ),
    ),
  );
}

GoRouter _testRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, state) => LandingScreen(
          initialSection: state.uri.queryParameters['section'],
        ),
      ),
      GoRoute(
        path: '/about',
        redirect: (_, __) => '/?section=about',
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const Scaffold(body: Text('Signup page')),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('isPublicRoute', () {
    test('/about is a public route', () {
      expect(isPublicRoute('/about'), isTrue);
    });
  });

  testWidgets('Landing shows merged About story and how-it-works in German', (tester) async {
    final localeProvider = LocaleProvider();

    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _landingTestApp(localeProvider: localeProvider, router: _testRouter()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Unsere Geschichte'), findsOneWidget);
    expect(find.text('So funktioniert es'), findsOneWidget);
    expect(find.text('Test zu Hause'), findsOneWidget);
    expect(find.text('Das Produkt'), findsNothing);
  });

  testWidgets('/about redirect shows merged About on landing', (tester) async {
    final localeProvider = LocaleProvider();

    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _landingTestApp(
        localeProvider: localeProvider,
        router: _testRouter(initialLocation: '/about'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Unsere Geschichte'), findsOneWidget);
    expect(find.text('So funktioniert es'), findsOneWidget);
  });

}
