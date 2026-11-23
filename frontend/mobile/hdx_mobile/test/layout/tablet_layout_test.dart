import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hdx_mobile/features/cube/cube_service.dart';
import 'package:hdx_mobile/screens/test_result_screen.dart';
import 'package:hdx_mobile/widgets/figma_ui.dart';
import 'package:hdx_mobile/widgets/responsive_layout.dart';

const _phonePortrait = Size(400, 860);
const _tabletPortrait = Size(800, 1280);
const _tabletLandscape = Size(1280, 800);
const _largeTabletPortrait = Size(1024, 1366);

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

const _bodyKey = Key('body-probe');

void main() {
  group('NativeContentWidth', () {
    Future<double> pumpProbe(WidgetTester tester, Size size, {bool? isWeb}) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeContentWidth(
              isWebOverride: isWeb,
              child: const SizedBox(key: _bodyKey, width: double.infinity, height: 50),
            ),
          ),
        ),
      );
      return tester.getSize(find.byKey(_bodyKey)).width;
    }

    testWidgets('phone width is unchanged', (tester) async {
      expect(await pumpProbe(tester, _phonePortrait), _phonePortrait.width);
    });

    testWidgets('tablet portrait caps at 800', (tester) async {
      expect(await pumpProbe(tester, _tabletPortrait), AppBreakpoints.contentMaxWidth);
    });

    testWidgets('tablet landscape caps at 800 and centers', (tester) async {
      expect(await pumpProbe(tester, _tabletLandscape), AppBreakpoints.contentMaxWidth);
      final left = tester.getTopLeft(find.byKey(_bodyKey)).dx;
      expect(left, (_tabletLandscape.width - AppBreakpoints.contentMaxWidth) / 2);
    });

    testWidgets('web is left to the web shell', (tester) async {
      expect(await pumpProbe(tester, _tabletLandscape, isWeb: true), _tabletLandscape.width);
    });
  });

  testWidgets('FigmaScreen keeps header full width and caps body on tablets', (tester) async {
    await _setSurface(tester, _tabletLandscape);
    const headerKey = Key('header-probe');
    await tester.pumpWidget(
      const MaterialApp(
        home: FigmaScreen(
          header: SizedBox(key: headerKey, height: 40),
          body: SizedBox(key: _bodyKey, width: double.infinity, height: 50),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(headerKey)).width, _tabletLandscape.width);
    expect(tester.getSize(find.byKey(_bodyKey)).width, AppBreakpoints.contentMaxWidth);
  });

  for (final size in [_tabletLandscape, _largeTabletPortrait]) {
    testWidgets('bottom action bar stays compact and body visible at $size', (tester) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(
        MaterialApp(
          home: FigmaScreen(
            body: const SizedBox.expand(key: _bodyKey),
            bottomBar: FigmaBottomActionBar(buttonLabel: 'OK', onPressed: () {}),
          ),
        ),
      );
      expect(tester.getSize(find.byType(FigmaBottomActionBar)).height, lessThan(200));
      final body = tester.getSize(find.byKey(_bodyKey));
      expect(body.height, greaterThan(size.height / 2));
      expect(body.width, AppBreakpoints.contentMaxWidth);
      expect(
        tester.getSize(find.byType(NeumorphicPillButton)).width,
        lessThanOrEqualTo(AppBreakpoints.contentMaxWidth),
      );
    });
  }

  // Tablet sizes only: the phone path is unchanged by NativeContentWidth, and
  // the test font (square glyphs) makes long German CTA labels overflow a
  // 400px surface even though the real font fits.
  for (final size in [_tabletPortrait, _tabletLandscape, _largeTabletPortrait]) {
    testWidgets('TestResultScreen renders without overflow at $size', (tester) async {
      await _setSurface(tester, size);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => TestResultScreen(
              testTypeName: 'RheumaCheck',
              testTypeId: 'rheumacheck',
              result: CubeTestResult(success: true, result: 'POSITIVE'),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('book-specialist-cta')), findsOneWidget);
      final cardWidth = tester.getSize(find.byType(NeumorphicRaisedCard).first).width;
      expect(cardWidth, lessThanOrEqualTo(AppBreakpoints.contentMaxWidth));
    });
  }
}
