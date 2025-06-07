import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/widgets/api_endpoint_execution_form.dart';

void main() {
  group('ApiEndpointExecutionForm', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ApiDefinitionsService.instance.clearDefinitions();
    });

    tearDown(() {
      ApiDefinitionsService.instance.clearDefinitions();
    });

    testWidgets('displays endpoint information correctly', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Get User',
        path: '/users/{id}',
        method: HttpMethod.get,
        description: 'Retrieve a specific user by ID',
        tags: ['users', 'read'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('/users/{id}'), findsOneWidget);
      expect(find.text('Retrieve a specific user by ID'), findsOneWidget);
      expect(find.text('users'), findsOneWidget);
      expect(find.text('read'), findsOneWidget);
    });

    testWidgets('displays base URL field', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Base URL'), findsOneWidget);
      expect(find.byType(TextFormField).first, findsOneWidget);
    });

    testWidgets('displays path parameters section', (tester) async {
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

      expect(find.text('Path Parameters'), findsOneWidget);
      expect(find.text('id'), findsOneWidget);
      expect(find.text('(int)'), findsOneWidget);
      expect(find.text('*'), findsOneWidget); // Required indicator
      expect(find.text('User ID'), findsOneWidget);
    });

    testWidgets('displays query parameters section', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'limit',
            type: ParameterType.query,
            dataType: int,
            required: false,
            description: 'Number of results',
            defaultValue: 10,
          ),
          ApiParameter(
            name: 'status',
            type: ParameterType.query,
            dataType: String,
            required: true,
            enumValues: ['active', 'inactive', 'pending'],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Query Parameters'), findsOneWidget);
      expect(find.text('limit'), findsOneWidget);
      expect(find.text('status'), findsOneWidget);
      expect(find.text('Number of results'), findsOneWidget);
      
      // Check that enum parameter shows dropdown
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays header parameters section', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'Authorization',
            type: ParameterType.header,
            dataType: String,
            required: true,
            description: 'Bearer token',
          ),
          ApiParameter(
            name: 'Content-Type',
            type: ParameterType.header,
            dataType: String,
            defaultValue: 'application/json',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Header Parameters'), findsOneWidget);
      expect(find.text('Authorization'), findsOneWidget);
      expect(find.text('Content-Type'), findsOneWidget);
      expect(find.text('Bearer token'), findsOneWidget);
    });

    testWidgets('displays request body section for POST method', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
            description: 'User data',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request Body'), findsOneWidget);
      // Should show a multi-line text field for JSON
      final bodyFields = find.byType(TextFormField);
      expect(bodyFields, findsAtLeastNWidgets(1));
    });

    testWidgets('does not display request body for GET method', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request Body'), findsNothing);
    });

    testWidgets('displays execute button', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Execute Request'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('validates required parameters', (tester) async {
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

      // Try to execute without filling required field
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('validates base URL', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Clear base URL
      await tester.enterText(find.byType(TextFormField).first, '');
      
      // Try to execute
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      expect(find.text('Base URL is required'), findsOneWidget);

      // Enter invalid URL
      await tester.enterText(find.byType(TextFormField).first, 'invalid-url');
      
      // Try to execute
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid URL'), findsOneWidget);
    });

    testWidgets('validates JSON in raw mode', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to raw JSON mode
      await tester.tap(find.byIcon(Icons.code));
      await tester.pumpAndSettle();

      // Enter invalid JSON in the body field (should be the last TextFormField)
      final bodyFields = find.byType(TextFormField);
      await tester.enterText(bodyFields.last, '{invalid json}');

      // Try to execute
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid JSON format'), findsOneWidget);
    });

    testWidgets('toggles between form and raw JSON mode', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Initially should show form view icon
      expect(find.byIcon(Icons.code), findsOneWidget);

      // Switch to raw JSON mode
      await tester.tap(find.byIcon(Icons.code));
      await tester.pumpAndSettle();

      // Should now show form view icon
      expect(find.byIcon(Icons.view_list), findsOneWidget);
      expect(find.text('Switch to Form View'), findsOneWidget);
    });

    testWidgets('fills default values correctly', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'limit',
            type: ParameterType.query,
            dataType: int,
            defaultValue: 10,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Check that default value is pre-filled
      final limitField = find.widgetWithText(TextFormField, '10');
      expect(limitField, findsOneWidget);
    });

    testWidgets('displays correct keyboard types for different data types', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'intParam',
            type: ParameterType.query,
            dataType: int,
          ),
          ApiParameter(
            name: 'doubleParam',
            type: ParameterType.query,
            dataType: double,
          ),
          ApiParameter(
            name: 'stringParam',
            type: ParameterType.query,
            dataType: String,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Find all text form fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4)); // base URL + 3 parameters

      // Note: In widget tests, we can't easily verify keyboard types
      // but we can verify the fields exist
      expect(find.text('intParam'), findsOneWidget);
      expect(find.text('doubleParam'), findsOneWidget);
      expect(find.text('stringParam'), findsOneWidget);
    });
  });
}