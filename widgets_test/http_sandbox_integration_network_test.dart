import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/services/http_records_service.dart';
import 'package:http_sandbox_viewer/src/widgets/http_sandbox_dashboard.dart';

void main() {
  group('HTTP Sandbox Network Integration Tests', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      ApiDefinitionsService.instance.clearDefinitions();
      HttpRecordsService.instance.clearRecords();
    });

    tearDown(() {
      ApiDefinitionsService.instance.clearDefinitions();
      HttpRecordsService.instance.clearRecords();
    });

    testWidgets('complete flow: execute API and see it in history', (tester) async {
      final testDefinition = _createJsonPlaceholderApiDefinition();
      
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
      expect(find.text('Get Post'), findsOneWidget);
      expect(find.text('/posts/{id}'), findsOneWidget);

      // Tap on the execute button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Should navigate to execution form
      expect(find.text('Get Post'), findsOneWidget); // App bar title
      expect(find.text('Base URL'), findsOneWidget);
      expect(find.text('Path Parameters'), findsOneWidget);

      // Fill in required path parameter
      final idField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(idField, '1');

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Executing...'), findsOneWidget);

      // Wait for execution to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show successful response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Go back to dashboard
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Switch to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should see the executed request in history
      expect(find.text('https://jsonplaceholder.typicode.com/posts/1'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('execute multiple requests and verify history ordering', (tester) async {
      final testDefinition = _createMultipleEndpointsApiDefinition();
      
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

      // Execute first endpoint (Get Posts)
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Execute Request'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go back to API Definitions
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Execute second endpoint (Get Users)
      await tester.tap(find.byIcon(Icons.play_arrow).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Execute Request'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go back to dashboard and check history
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should see both requests in history (most recent first)
      final requestTiles = find.byType(ListTile);
      expect(requestTiles, findsNWidgets(2));

      // Verify the URLs are present
      expect(find.text('https://jsonplaceholder.typicode.com/posts'), findsOneWidget);
      expect(find.text('https://jsonplaceholder.typicode.com/users'), findsOneWidget);
    });

    testWidgets('execute POST request with body and verify in history', (tester) async {
      final testDefinition = _createPostApiDefinition();
      
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

      // Execute POST endpoint
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Fill in request body
      final bodyField = find.byType(TextFormField).last;
      await tester.enterText(bodyField, '{"title": "Test Post", "body": "Test content", "userId": 1}');

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show successful response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('201'), findsOneWidget);

      // Go back and check history
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should see the POST request in history
      expect(find.text('https://jsonplaceholder.typicode.com/posts'), findsOneWidget);
      expect(find.text('POST'), findsOneWidget);
      expect(find.text('201'), findsOneWidget);

      // Tap on the request to see details
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Should show request details including body
      expect(find.text('POST Request'), findsOneWidget);
      expect(find.text('Request Body'), findsOneWidget);
      expect(find.textContaining('Test Post'), findsOneWidget);
    });

    testWidgets('error handling and history persistence', (tester) async {
      final testDefinition = _createErrorTestApiDefinition();
      
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

      // Execute endpoint that will return 404
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Fill in non-existent ID
      final idField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(idField, '999999');

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show 404 response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('404'), findsOneWidget);

      // Go back and check history
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should see the failed request in history
      expect(find.text('https://jsonplaceholder.typicode.com/posts/999999'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('404'), findsOneWidget);
    });

    testWidgets('search and filter in API definitions with network execution', (tester) async {
      final definition1 = _createJsonPlaceholderApiDefinition();
      final definition2 = _createMultipleEndpointsApiDefinition();
      
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

      // Should show multiple endpoints
      expect(find.text('Get Post'), findsOneWidget);
      expect(find.text('Get Posts'), findsOneWidget);
      expect(find.text('Get Users'), findsOneWidget);

      // Filter by 'post' to show only post-related endpoints
      await tester.enterText(find.byType(TextField), 'post');
      await tester.pumpAndSettle();

      // Should only show post endpoints
      expect(find.text('Get Post'), findsOneWidget);
      expect(find.text('Get Posts'), findsOneWidget);
      expect(find.text('Get Users'), findsNothing);

      // Execute one of the filtered endpoints
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pumpAndSettle();

      // Fill required parameter if any
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length > 1) {
        await tester.enterText(textFields.last, '1');
      }

      await tester.tap(find.text('Execute Request'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show successful execution
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
    });
  });
}

ApiDefinition _createJsonPlaceholderApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Get Post',
    path: '/posts/{id}',
    method: HttpMethod.get,
    description: 'Retrieve a specific post by ID',
    tags: ['posts', 'read'],
    parameters: [
      ApiParameter(
        name: 'id',
        type: ParameterType.path,
        dataType: int,
        required: true,
        description: 'Post ID',
      ),
    ],
    responseType: 'Post',
  );

  return ApiDefinition(
    title: 'JSONPlaceholder API',
    services: [
      ApiService(
        name: 'Posts Service',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        endpoints: [endpoint],
      ),
    ],
  );
}

ApiDefinition _createMultipleEndpointsApiDefinition() {
  final endpoints = [
    ApiEndpoint(
      name: 'Get Posts',
      path: '/posts',
      method: HttpMethod.get,
      description: 'Retrieve all posts',
      tags: ['posts', 'read'],
      responseType: 'List<Post>',
    ),
    ApiEndpoint(
      name: 'Get Users',
      path: '/users',
      method: HttpMethod.get,
      description: 'Retrieve all users',
      tags: ['users', 'read'],
      responseType: 'List<User>',
    ),
  ];

  return ApiDefinition(
    title: 'JSONPlaceholder Multiple',
    services: [
      ApiService(
        name: 'Multiple Service',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        endpoints: endpoints,
      ),
    ],
  );
}

ApiDefinition _createPostApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Create Post',
    path: '/posts',
    method: HttpMethod.post,
    description: 'Create a new post',
    tags: ['posts', 'write'],
    parameters: [
      ApiParameter(
        name: 'body',
        type: ParameterType.body,
        dataType: Map,
        required: true,
        description: 'Post data',
      ),
    ],
    responseType: 'Post',
  );

  return ApiDefinition(
    title: 'POST API',
    services: [
      ApiService(
        name: 'Post Service',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        endpoints: [endpoint],
      ),
    ],
  );
}

ApiDefinition _createErrorTestApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Get Non-existent Post',
    path: '/posts/{id}',
    method: HttpMethod.get,
    description: 'Test 404 error handling',
    tags: ['error', 'test'],
    parameters: [
      ApiParameter(
        name: 'id',
        type: ParameterType.path,
        dataType: int,
        required: true,
        description: 'Post ID (use 999999 for 404)',
      ),
    ],
  );

  return ApiDefinition(
    title: 'Error Test API',
    services: [
      ApiService(
        name: 'Error Service',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        endpoints: [endpoint],
      ),
    ],
  );
}