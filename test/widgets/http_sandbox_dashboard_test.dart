import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/models/http_request_record.dart';
import 'package:http_sandbox_viewer/src/services/http_records_service.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/widgets/http_sandbox_dashboard.dart';

void main() {
  group('HttpSandboxDashboard', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      HttpRecordsService.instance.clearRecords();
      ApiDefinitionsService.instance.clearDefinitions();
    });

    tearDown(() {
      HttpRecordsService.instance.clearRecords();
      ApiDefinitionsService.instance.clearDefinitions();
    });

    testWidgets('displays tab navigation correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Check that both tabs are present
      expect(find.text('History'), findsOneWidget);
      expect(find.text('API Definitions'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.api), findsOneWidget);
    });

    testWidgets('starts on History tab by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty history message
      expect(find.text('No HTTP requests recorded yet.'), findsOneWidget);
    });

    testWidgets('switches between tabs correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on History tab
      expect(find.text('No HTTP requests recorded yet.'), findsOneWidget);

      // Switch to API Definitions tab
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      // Should show API definitions content
      expect(find.text('No HTTP requests recorded yet.'), findsNothing);
      expect(find.text('No API definitions available.'), findsOneWidget);

      // Switch back to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should show history content again
      expect(find.text('No HTTP requests recorded yet.'), findsOneWidget);
    });

    testWidgets('displays HTTP requests in History tab', (tester) async {
      // Add a test request to the service
      final testRecord = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/test',
        headers: {'Content-Type': 'application/json'},
        timestamp: DateTime.now(),
        response: HttpResponseRecord(
          statusCode: 200,
          statusMessage: 'OK',
          headers: {},
          timestamp: DateTime.now(),
          duration: 1500,
        ),
      );
      
      HttpRecordsService.instance.addRequest(testRecord);

      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Should display the request
      expect(find.text('https://jsonplaceholder.typicode.com/test'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('displays API definitions when provided', (tester) async {
      final testDefinition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://jsonplaceholder.typicode.com',
            endpoints: [
              ApiEndpoint(
                name: 'Get Test',
                path: '/test',
                method: HttpMethod.get,
                description: 'A test endpoint',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(
            apiDefinitions: [testDefinition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to API Definitions tab
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      // Should show the test endpoint
      expect(find.text('Get Test'), findsOneWidget);
      expect(find.text('/test'), findsOneWidget);
      expect(find.text('A test endpoint'), findsOneWidget);
    });

    testWidgets('clear all button works in History tab', (tester) async {
      // Add a test request
      final testRecord = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/test',
        headers: {},
        timestamp: DateTime.now(),
      );
      
      HttpRecordsService.instance.addRequest(testRecord);

      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the request
      expect(find.text('https://jsonplaceholder.typicode.com/test'), findsOneWidget);

      // Tap clear all button
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No HTTP requests recorded yet.'), findsOneWidget);
      expect(find.text('https://jsonplaceholder.typicode.com/test'), findsNothing);
    });

    testWidgets('request cards are tappable and navigate to detail view', (tester) async {
      final testRecord = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/test',
        headers: {},
        timestamp: DateTime.now(),
      );
      
      HttpRecordsService.instance.addRequest(testRecord);

      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the request card
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Should navigate to detail view
      expect(find.text('GET Request'), findsOneWidget); // App bar title
      expect(find.text('URL'), findsOneWidget);
    });

    testWidgets('method colors are applied correctly', (tester) async {
      final requests = [
        HttpRequestRecord(
          id: '1',
          method: 'GET',
          url: 'https://jsonplaceholder.typicode.com/get',
          headers: {},
          timestamp: DateTime.now(),
        ),
        HttpRequestRecord(
          id: '2',
          method: 'POST',
          url: 'https://jsonplaceholder.typicode.com/post',
          headers: {},
          timestamp: DateTime.now(),
        ),
        HttpRequestRecord(
          id: '3',
          method: 'DELETE',
          url: 'https://jsonplaceholder.typicode.com/delete',
          headers: {},
          timestamp: DateTime.now(),
        ),
      ];

      for (final request in requests) {
        HttpRecordsService.instance.addRequest(request);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // All method badges should be visible
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('POST'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('status code colors are applied correctly', (tester) async {
      final requests = [
        HttpRequestRecord(
          id: '1',
          method: 'GET',
          url: 'https://jsonplaceholder.typicode.com/success',
          headers: {},
          timestamp: DateTime.now(),
          response: HttpResponseRecord(
            statusCode: 200,
            statusMessage: 'OK',
            headers: {},
            timestamp: DateTime.now(),
            duration: 1000,
          ),
        ),
        HttpRequestRecord(
          id: '2',
          method: 'GET',
          url: 'https://jsonplaceholder.typicode.com/error',
          headers: {},
          timestamp: DateTime.now(),
          response: HttpResponseRecord(
            statusCode: 404,
            statusMessage: 'Not Found',
            headers: {},
            timestamp: DateTime.now(),
            duration: 500,
          ),
        ),
        HttpRequestRecord(
          id: '3',
          method: 'GET',
          url: 'https://jsonplaceholder.typicode.com/server-error',
          headers: {},
          timestamp: DateTime.now(),
          response: HttpResponseRecord(
            statusCode: 500,
            statusMessage: 'Internal Server Error',
            headers: {},
            timestamp: DateTime.now(),
            duration: 2000,
          ),
        ),
      ];

      for (final request in requests) {
        HttpRecordsService.instance.addRequest(request);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // All status codes should be visible
      expect(find.text('200'), findsOneWidget);
      expect(find.text('404'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      
      // Status messages should be visible
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Not Found'), findsOneWidget);
      expect(find.text('Internal Server Error'), findsOneWidget);
    });

    testWidgets('timestamp formatting works correctly', (tester) async {
      final now = DateTime.now();
      final testRecord = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/test',
        headers: {},
        timestamp: now,
      );
      
      HttpRecordsService.instance.addRequest(testRecord);

      await tester.pumpWidget(
        const MaterialApp(
          home: HttpSandboxDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show "Just now" for recent timestamps
      expect(find.text('Just now'), findsOneWidget);
    });
  });
}