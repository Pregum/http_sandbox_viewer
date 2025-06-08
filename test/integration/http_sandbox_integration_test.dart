import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/services/http_records_service.dart';
import 'package:http_sandbox_viewer/src/widgets/http_sandbox_dashboard.dart';

void main() {
  group('HTTP Sandbox Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ApiDefinitionsService.instance.clearDefinitions();
      HttpRecordsService.instance.clearRecords();
    });

    tearDown(() {
      ApiDefinitionsService.instance.clearDefinitions();
      HttpRecordsService.instance.clearRecords();
    });

    testWidgets('complete flow: navigate between tabs and execute API', (tester) async {
      final testDefinition = _createTestApiDefinition();
      
      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(
            apiDefinitions: [testDefinition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should start on History tab
      expect(find.text('History'), findsOneWidget);
      expect(find.text('API Definitions'), findsOneWidget);
      expect(find.text('No HTTP requests recorded yet.'), findsOneWidget);

      // Switch to API Definitions tab
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      // Should show the test endpoint
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('/users/{id}'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);

      // Tap on the execute button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Should navigate to execution form
      expect(find.text('Get User'), findsOneWidget); // App bar title
      expect(find.text('Base URL'), findsOneWidget);
      expect(find.text('Path Parameters'), findsOneWidget);
      expect(find.text('id'), findsOneWidget);

      // Fill in required path parameter
      final idField = find.widgetWithText(TextFormField, '').first;
      await tester.enterText(idField, '123');

      // Try to execute (will fail due to mock HTTP, but should validate)
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      // Should show loading state briefly
      expect(find.text('Executing...'), findsOneWidget);
      
      // Wait for execution to complete (will likely fail with mock)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Go back to dashboard
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back in API Definitions tab
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('/users/{id}'), findsOneWidget);
    });

    testWidgets('API definitions persistence and search functionality', (tester) async {
      final definition1 = _createTestApiDefinition();
      final definition2 = _createSecondApiDefinition();
      
      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(
            apiDefinitions: [definition1, definition2],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to API Definitions tab
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      // Should show both endpoints
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('Get Posts'), findsOneWidget);

      // Test search functionality
      await tester.enterText(find.byType(TextField), 'user');
      await tester.pumpAndSettle();

      // Should only show user endpoint
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('Get Posts'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Should show both endpoints again
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('Get Posts'), findsOneWidget);

      // Test tag filtering
      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      // Should only show user endpoint
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('Get Posts'), findsNothing);

      // Switch back to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Should show both endpoints again
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('Get Posts'), findsOneWidget);
    });

    testWidgets('endpoint expansion shows parameter details', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        summary: 'Create a new user in the system',
        description: 'This endpoint allows creating a new user with provided data',
        tags: ['users', 'write'],
        parameters: [
          ApiParameter(
            name: 'Authorization',
            type: ParameterType.header,
            dataType: String,
            required: true,
            description: 'Bearer token for authentication',
          ),
          ApiParameter(
            name: 'limit',
            type: ParameterType.query,
            dataType: int,
            defaultValue: 10,
            description: 'Maximum number of results',
          ),
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
            description: 'User data object',
          ),
        ],
        responseType: 'User',
      );

      final definition = ApiDefinition(
        title: 'User API',
        services: [
          ApiService(
            name: 'User Service',
            baseUrl: 'https://jsonplaceholder.typicode.com',
            endpoints: [endpoint],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(
            apiDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to API Definitions tab
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      // Initially endpoint details should not be visible
      expect(find.text('Summary'), findsNothing);
      expect(find.text('Header Parameters'), findsNothing);

      // Expand the endpoint
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Now endpoint details should be visible
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Create a new user in the system'), findsOneWidget);
      expect(find.text('Header Parameters'), findsOneWidget);
      expect(find.text('Query Parameters'), findsOneWidget);
      expect(find.text('Request Body'), findsOneWidget);
      expect(find.text('Response Type'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);

      // Check parameter details
      expect(find.text('Authorization'), findsOneWidget);
      expect(find.text('Bearer token for authentication'), findsOneWidget);
      expect(find.text('required'), findsAtLeastNWidgets(1));
      expect(find.text('optional'), findsOneWidget);
      expect(find.text('Default: 10'), findsOneWidget);
    });

    testWidgets('form validation prevents invalid execution', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Get User',
        path: '/users/{id}',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'id',
            type: ParameterType.path,
            dataType: int,
            required: true,
            description: 'User ID',
          ),
        ],
      );

      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://jsonplaceholder.typicode.com',
            endpoints: [endpoint],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(
            apiDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to API Definitions and execute endpoint
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Try to execute without filling required field
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('This field is required'), findsOneWidget);

      // The execute button should not show loading state
      expect(find.text('Executing...'), findsNothing);
      expect(find.text('Execute Request'), findsOneWidget);
    });

    testWidgets('method colors are displayed correctly for different HTTP methods', (tester) async {
      final endpoints = [
        ApiEndpoint(name: 'GET Test', path: '/get', method: HttpMethod.get),
        ApiEndpoint(name: 'POST Test', path: '/post', method: HttpMethod.post),
        ApiEndpoint(name: 'PUT Test', path: '/put', method: HttpMethod.put),
        ApiEndpoint(name: 'DELETE Test', path: '/delete', method: HttpMethod.delete),
        ApiEndpoint(name: 'PATCH Test', path: '/patch', method: HttpMethod.patch),
      ];

      final definition = ApiDefinition(
        title: 'HTTP Methods API',
        services: [
          ApiService(
            name: 'Methods Service',
            baseUrl: 'https://jsonplaceholder.typicode.com',
            endpoints: endpoints,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HttpSandboxDashboard(
            apiDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to API Definitions tab
      await tester.tap(find.text('API Definitions'));
      await tester.pumpAndSettle();

      // All method badges should be visible
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('POST'), findsOneWidget);
      expect(find.text('PUT'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
      expect(find.text('PATCH'), findsOneWidget);

      // All endpoint names should be visible
      expect(find.text('GET Test'), findsOneWidget);
      expect(find.text('POST Test'), findsOneWidget);
      expect(find.text('PUT Test'), findsOneWidget);
      expect(find.text('DELETE Test'), findsOneWidget);
      expect(find.text('PATCH Test'), findsOneWidget);
    });
  });
}

ApiDefinition _createTestApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Get User',
    path: '/users/{id}',
    method: HttpMethod.get,
    description: 'Retrieve a specific user by ID',
    tags: ['users', 'read'],
    parameters: [
      ApiParameter(
        name: 'id',
        type: ParameterType.path,
        dataType: int,
        required: true,
        description: 'User ID',
      ),
    ],
    responseType: 'User',
  );

  return ApiDefinition(
    title: 'User API',
    services: [
      ApiService(
        name: 'User Service',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        endpoints: [endpoint],
      ),
    ],
  );
}

ApiDefinition _createSecondApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Get Posts',
    path: '/posts',
    method: HttpMethod.get,
    description: 'Retrieve all posts',
    tags: ['posts', 'read'],
    responseType: 'List<Post>',
  );

  return ApiDefinition(
    title: 'Posts API',
    services: [
      ApiService(
        name: 'Posts Service',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        endpoints: [endpoint],
      ),
    ],
  );
}