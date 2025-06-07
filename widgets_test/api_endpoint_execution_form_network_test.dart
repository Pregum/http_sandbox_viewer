import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/widgets/api_endpoint_execution_form.dart';

void main() {
  group('ApiEndpointExecutionForm Network Tests', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      ApiDefinitionsService.instance.clearDefinitions();
    });

    tearDown(() {
      ApiDefinitionsService.instance.clearDefinitions();
    });

    testWidgets('shows loading state when executing request', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test Endpoint',
        path: '/test',
        method: HttpMethod.get,
        description: 'Test endpoint for loading state',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org'
      );

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state immediately
      expect(find.text('Executing...'), findsOneWidget);
      expect(find.text('Execute Request'), findsNothing);
    });

    testWidgets('handles network errors gracefully', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Invalid Endpoint',
        path: '/nonexistent',
        method: HttpMethod.get,
        description: 'Test error handling',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in invalid base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://invalid-domain-that-does-not-exist-12345.com'
      );

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Executing...'), findsOneWidget);

      // Wait for request to fail
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show error
      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Failed to execute request'), findsOneWidget);
    });

    testWidgets('executes POST request with request body', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create Post',
        path: '/posts',
        method: HttpMethod.post,
        description: 'Create a new post',
        parameters: [
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
            description: 'Post data',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://jsonplaceholder.typicode.com'
      );

      // Fill in request body
      final bodyField = find.byType(TextFormField).last;
      await tester.enterText(bodyField, '{"title": "Test Post", "body": "This is a test", "userId": 1}');

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Executing...'), findsOneWidget);

      // Wait for request to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show success response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('201'), findsOneWidget);
      expect(find.text('Created'), findsOneWidget);

      // Should display response data with created post
      expect(find.text('Response Body'), findsOneWidget);
      expect(find.textContaining('"id"'), findsOneWidget);
      expect(find.textContaining('"title"'), findsOneWidget);
    });

    testWidgets('validates and executes request with path parameters', (tester) async {
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

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://jsonplaceholder.typicode.com'
      );

      // Fill in path parameter
      final idField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(idField, '1');

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Executing...'), findsOneWidget);

      // Wait for request to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show success response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Should display user data
      expect(find.text('Response Body'), findsOneWidget);
      expect(find.textContaining('"id"'), findsOneWidget);
      expect(find.textContaining('"name"'), findsOneWidget);
      expect(find.textContaining('"email"'), findsOneWidget);
    });

    testWidgets('executes request with query parameters', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Get Posts with Limit',
        path: '/posts',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: '_limit',
            type: ParameterType.query,
            dataType: int,
            required: false,
            description: 'Limit number of posts',
            defaultValue: 5,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://jsonplaceholder.typicode.com'
      );

      // The query parameter field should be pre-filled with default value
      expect(find.widgetWithText(TextFormField, '5'), findsOneWidget);

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Executing...'), findsOneWidget);

      // Wait for request to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show success response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Should display limited number of posts
      expect(find.text('Response Body'), findsOneWidget);
      expect(find.textContaining('['), findsOneWidget); // Array response
    });

    testWidgets('shows cURL command for executed request', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Simple GET',
        path: '/posts/1',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://jsonplaceholder.typicode.com'
      );

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Wait for request to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show cURL command
      expect(find.text('cURL Command'), findsOneWidget);
      expect(find.textContaining('curl -X GET'), findsOneWidget);
      expect(find.textContaining('https://jsonplaceholder.typicode.com/posts/1'), findsOneWidget);
    });

    testWidgets('handles 404 response correctly', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Non-existent Resource',
        path: '/posts/999999',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://jsonplaceholder.typicode.com'
      );

      // Execute the request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Wait for request to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show 404 response
      expect(find.text('Response'), findsOneWidget);
      expect(find.text('404'), findsOneWidget);
      expect(find.text('Not Found'), findsOneWidget);
    });
  });
}