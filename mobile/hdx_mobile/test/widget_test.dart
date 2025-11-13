// Widget tests for HomeDX Mobile App

import 'package:flutter_test/flutter_test.dart';

import 'package:hdx_mobile/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('HomeDX'), findsOneWidget);

    // Verify that welcome text is displayed
    expect(find.text('Welcome to HomeDX'), findsOneWidget);

    // Verify that quick action cards are displayed
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
  });

  testWidgets('Home screen displays all sections', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify Quick Actions section
    expect(find.text('Quick Actions'), findsOneWidget);

    // Verify Recent Activity section
    expect(find.text('Recent Activity'), findsOneWidget);
  });
}
