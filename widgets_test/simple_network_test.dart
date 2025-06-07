import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/widgets/api_endpoint_execution_form.dart';

void main() {
  group('Simple Network Tests', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      ApiDefinitionsService.instance.clearDefinitions();
    });

    tearDown(() {
      ApiDefinitionsService.instance.clearDefinitions();
    });

    testWidgets('form displays correctly with network parameters', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Network Test Endpoint',
        path: '/api/test/{id}',
        method: HttpMethod.get,
        description: 'Test endpoint for network operations',
        parameters: [
          ApiParameter(
            name: 'id',
            type: ParameterType.path,
            dataType: int,
            required: true,
            description: 'Resource ID',
          ),
          ApiParameter(
            name: 'limit',
            type: ParameterType.query,
            dataType: int,
            required: false,
            defaultValue: 10,
            description: 'Limit results',
          ),
          ApiParameter(
            name: 'Authorization',
            type: ParameterType.header,
            dataType: String,
            required: true,
            description: 'Bearer token',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Verify endpoint information
      expect(find.text('Network Test Endpoint'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('/api/test/{id}'), findsOneWidget);
      expect(find.text('Test endpoint for network operations'), findsOneWidget);

      // Verify parameter sections
      expect(find.text('Base URL'), findsOneWidget);
      expect(find.text('Path Parameters'), findsOneWidget);
      expect(find.text('Query Parameters'), findsOneWidget);
      expect(find.text('Header Parameters'), findsOneWidget);

      // Verify specific parameters
      expect(find.text('id'), findsOneWidget);
      expect(find.text('limit'), findsOneWidget);
      expect(find.text('Authorization'), findsOneWidget);

      // Verify default values
      expect(find.widgetWithText(TextFormField, '10'), findsOneWidget);

      // Verify execute button
      expect(find.text('Execute Request'), findsOneWidget);
    });

    testWidgets('can fill form fields for network request', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'API Test',
        path: '/users/{userId}',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'userId',
            type: ParameterType.path,
            dataType: int,
            required: true,
          ),
          ApiParameter(
            name: 'include',
            type: ParameterType.query,
            dataType: String,
            required: false,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://api.example.com'
      );

      // Fill path parameter
      final userIdField = find.widgetWithText(TextFormField, '').first;
      await tester.enterText(userIdField, '123');

      // Fill query parameter
      final includeField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(includeField, 'profile,settings');

      await tester.pumpAndSettle();

      // Verify values were entered
      expect(find.widgetWithText(TextFormField, 'https://api.example.com'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '123'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'profile,settings'), findsOneWidget);
    });

    testWidgets('validation works for network request parameters', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Validation Test',
        path: '/test/{id}',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'id',
            type: ParameterType.path,
            dataType: int,
            required: true,
          ),
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

      // Try to execute without filling required fields
      await tester.tap(find.text('Execute Request'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Base URL is required'), findsOneWidget);
      expect(find.text('This field is required'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows execution loading state', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Loading Test',
        path: '/test',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org'
      );

      // Execute request
      await tester.tap(find.text('Execute Request'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Executing...'), findsOneWidget);
      expect(find.text('Execute Request'), findsNothing);
    });

    testWidgets('POST request form shows request body section', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'POST Test',
        path: '/api/create',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
            description: 'Request payload',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Should show request body section
      expect(find.text('Request Body'), findsAtLeastNWidgets(1));
      expect(find.text('Request payload'), findsOneWidget);

      // Should have form/raw toggle
      expect(find.byIcon(Icons.code), findsOneWidget);

      // Fill request body
      final bodyField = find.byType(TextFormField).last;
      await tester.enterText(bodyField, '{"name": "test", "value": 123}');

      // Toggle to raw mode
      await tester.tap(find.byIcon(Icons.code));
      await tester.pumpAndSettle();

      // Should show raw mode icon
      expect(find.byIcon(Icons.view_list), findsOneWidget);
    });

    testWidgets('enum parameters show dropdown', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Enum Test',
        path: '/test',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'status',
            type: ParameterType.query,
            dataType: String,
            required: true,
            enumValues: ['active', 'inactive', 'pending'],
            description: 'Status filter',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Should show dropdown for enum parameter
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('status'), findsOneWidget);
      expect(find.text('Status filter'), findsOneWidget);

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show enum values
      expect(find.text('active'), findsOneWidget);
      expect(find.text('inactive'), findsOneWidget);
      expect(find.text('pending'), findsOneWidget);
    });
  });
}