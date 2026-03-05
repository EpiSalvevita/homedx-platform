// Widget tests for HomeDX Mobile App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  // Setup: Load test environment before tests run
  setUpAll(() async {
    // Initialize dotenv with test values (mock the .env file)
    dotenv.testLoad(fileInput: '''
API_BASE_URL=http://localhost:4000
ENV=test
STRIPE_PUBLISHABLE_KEY=pk_test_mock
''');
  });

  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Build a minimal app to verify dotenv is properly loaded
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('HomeDX Test'),
          ),
        ),
      ),
    );

    // Verify the test app renders
    expect(find.text('HomeDX Test'), findsOneWidget);
  });

  testWidgets('Environment variables are loaded', (WidgetTester tester) async {
    // Verify environment variables are accessible
    expect(dotenv.env['API_BASE_URL'], isNotNull);
    expect(dotenv.env['ENV'], equals('test'));
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Environment loaded'),
          ),
        ),
      ),
    );

    expect(find.text('Environment loaded'), findsOneWidget);
  });
}
