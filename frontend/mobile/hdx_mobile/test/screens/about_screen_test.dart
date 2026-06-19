import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/config/auth_routes.dart';
import 'package:hdx_mobile/providers/locale_provider.dart';
import 'package:hdx_mobile/screens/about_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _aboutTestApp({
  required LocaleProvider localeProvider,
  Widget? home,
  GoRouter? router,
}) {
  return ChangeNotifierProvider<LocaleProvider>.value(
    value: localeProvider,
    child: Consumer<LocaleProvider>(
      builder: (context, lp, _) {
        if (router != null) {
          return MaterialApp.router(
            locale: lp.locale,
            routerConfig: router,
          );
        }
        return MaterialApp(
          locale: lp.locale,
          home: home,
        );
      },
    ),
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

  testWidgets('AboutScreen shows hero and story in German', (tester) async {
    final localeProvider = LocaleProvider();

    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _aboutTestApp(
        localeProvider: localeProvider,
        home: const AboutScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Gesundheit beginnt'), findsOneWidget);
    expect(find.text('Unsere Geschichte'), findsOneWidget);
    expect(find.text('Das Produkt'), findsOneWidget);
  });

  testWidgets('AboutScreen locale toggle switches hero to English', (tester) async {
    final localeProvider = LocaleProvider();

    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _aboutTestApp(
        localeProvider: localeProvider,
        home: const AboutScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Gesundheit beginnt'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Health starts'), findsOneWidget);
    expect(find.text('Our story'), findsOneWidget);
  });

  testWidgets('AboutScreen signup CTA navigates', (tester) async {
    final localeProvider = LocaleProvider();
    final router = GoRouter(
      initialLocation: '/about',
      routes: [
        GoRoute(
          path: '/about',
          builder: (_, __) => const AboutScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, __) => const Scaffold(body: Text('Signup page')),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _aboutTestApp(
        localeProvider: localeProvider,
        router: router,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.scrollUntilVisible(
      find.text('Jetzt starten'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Jetzt starten'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Signup page'), findsOneWidget);
  });
}
