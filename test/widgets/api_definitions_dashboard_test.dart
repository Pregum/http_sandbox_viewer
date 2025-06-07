import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';
import 'package:http_sandbox_viewer/src/widgets/api_definitions_dashboard.dart';

void main() {
  group('ApiDefinitionsDashboard', () {
    late ApiDefinitionsService service;

    setUp(() {
      service = ApiDefinitionsService.instance;
      service.clearDefinitions();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      service.clearDefinitions();
    });

    testWidgets('displays empty state when no definitions exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ApiDefinitionsDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.api), findsOneWidget);
      expect(find.text('No API definitions available.\nAdd some definitions to get started.'), findsOneWidget);
      expect(find.text('Load Sample APIs'), findsOneWidget);
    });

    testWidgets('loads and displays sample APIs when requested', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ApiDefinitionsDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap load sample APIs button
      await tester.tap(find.text('Load Sample APIs'));
      await tester.pumpAndSettle();

      // Should now show endpoints
      expect(find.text('Get Users'), findsOneWidget);
      expect(find.text('Create User'), findsOneWidget);
      expect(find.text('Delete User'), findsOneWidget);
    });

    testWidgets('displays provided initial definitions', (tester) async {
      final testDefinition = _createTestApiDefinition();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [testDefinition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Endpoint'), findsOneWidget);
      expect(find.text('/test/{id}'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
    });

    testWidgets('search functionality works correctly', (tester) async {
      final testDefinition = _createTestApiDefinition();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [testDefinition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially shows the endpoint
      expect(find.text('Test Endpoint'), findsOneWidget);

      // Search for something that doesn't match
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      // Should show no results message
      expect(find.text('No endpoints found matching your criteria'), findsOneWidget);
      expect(find.text('Test Endpoint'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Should show endpoint again
      expect(find.text('Test Endpoint'), findsOneWidget);
    });

    testWidgets('tag filtering works correctly', (tester) async {
      final endpoint1 = ApiEndpoint(
        name: 'User Endpoint',
        path: '/users',
        method: HttpMethod.get,
        tags: ['users'],
      );
      final endpoint2 = ApiEndpoint(
        name: 'Post Endpoint',
        path: '/posts',
        method: HttpMethod.get,
        tags: ['posts'],
      );
      
      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://api.example.com',
            endpoints: [endpoint1, endpoint2],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially shows both endpoints
      expect(find.text('User Endpoint'), findsOneWidget);
      expect(find.text('Post Endpoint'), findsOneWidget);

      // Filter by users tag
      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      // Should only show user endpoint
      expect(find.text('User Endpoint'), findsOneWidget);
      expect(find.text('Post Endpoint'), findsNothing);

      // Switch to All filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Should show both endpoints again
      expect(find.text('User Endpoint'), findsOneWidget);
      expect(find.text('Post Endpoint'), findsOneWidget);
    });

    testWidgets('endpoint cards display correct information', (tester) async {
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
          ApiParameter(
            name: 'include',
            type: ParameterType.query,
            dataType: String,
            description: 'Related data to include',
          ),
        ],
      );

      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://api.example.com',
            endpoints: [endpoint],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check endpoint card content
      expect(find.text('Get User'), findsOneWidget);
      expect(find.text('/users/{id}'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('Retrieve a specific user by ID'), findsOneWidget);
      expect(find.text('users'), findsOneWidget);
      expect(find.text('read'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('expansion tile shows parameter details', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        summary: 'Create a new user account',
        parameters: [
          ApiParameter(
            name: 'id',
            type: ParameterType.path,
            dataType: int,
            required: true,
            description: 'User ID',
          ),
          ApiParameter(
            name: 'limit',
            type: ParameterType.query,
            dataType: int,
            required: false,
            description: 'Limit results',
            defaultValue: 10,
          ),
          ApiParameter(
            name: 'authorization',
            type: ParameterType.header,
            dataType: String,
            required: true,
            description: 'Bearer token',
          ),
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
            description: 'User data',
          ),
        ],
        responseType: 'User',
      );

      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://api.example.com',
            endpoints: [endpoint],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the endpoint card
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Check that parameter details are shown
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Create a new user account'), findsOneWidget);
      expect(find.text('Path Parameters'), findsOneWidget);
      expect(find.text('Query Parameters'), findsOneWidget);
      expect(find.text('Header Parameters'), findsOneWidget);
      expect(find.text('Request Body'), findsOneWidget);
      expect(find.text('Response Type'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      
      // Check parameter details
      expect(find.text('required'), findsNWidgets(3)); // path, header, body
      expect(find.text('optional'), findsOneWidget);   // query
      expect(find.text('(int)'), findsNWidgets(2));    // path and query params
      expect(find.text('(String)'), findsOneWidget);   // header param
      expect(find.text('(Map)'), findsOneWidget);      // body param
      expect(find.text('Default: 10'), findsOneWidget);
    });

    testWidgets('method colors are correct', (tester) async {
      final endpoints = [
        ApiEndpoint(name: 'GET Test', path: '/get', method: HttpMethod.get),
        ApiEndpoint(name: 'POST Test', path: '/post', method: HttpMethod.post),
        ApiEndpoint(name: 'PUT Test', path: '/put', method: HttpMethod.put),
        ApiEndpoint(name: 'DELETE Test', path: '/delete', method: HttpMethod.delete),
        ApiEndpoint(name: 'PATCH Test', path: '/patch', method: HttpMethod.patch),
      ];

      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://api.example.com',
            endpoints: endpoints,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [definition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all method badges are present
      expect(find.text('GET'), findsOneWidget);
      expect(find.text('POST'), findsOneWidget);
      expect(find.text('PUT'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
      expect(find.text('PATCH'), findsOneWidget);
    });

    testWidgets('execute button navigates to execution form', (tester) async {
      final testDefinition = _createTestApiDefinition();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ApiDefinitionsDashboard(
            initialDefinitions: [testDefinition],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap execute button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Should navigate to execution form
      expect(find.text('Test Endpoint'), findsOneWidget); // Title in app bar
      expect(find.text('Base URL'), findsOneWidget);
    });
  });
}

ApiDefinition _createTestApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Test Endpoint',
    path: '/test/{id}',
    method: HttpMethod.get,
    description: 'A test endpoint for testing',
    tags: ['test'],
    parameters: [
      ApiParameter(
        name: 'id',
        type: ParameterType.path,
        dataType: int,
        required: true,
        description: 'Test ID',
      ),
    ],
  );

  return ApiDefinition(
    title: 'Test API',
    services: [
      ApiService(
        name: 'Test Service',
        baseUrl: 'https://test.example.com',
        endpoints: [endpoint],
      ),
    ],
  );
}