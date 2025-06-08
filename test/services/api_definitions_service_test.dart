import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/services/api_definitions_service.dart';

void main() {
  group('ApiDefinitionsService', () {
    late ApiDefinitionsService service;

    setUp(() {
      service = ApiDefinitionsService.instance;
      service.clearDefinitions();
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      service.clearDefinitions();
    });

    test('is singleton', () {
      final service1 = ApiDefinitionsService.instance;
      final service2 = ApiDefinitionsService.instance;
      expect(service1, same(service2));
    });

    test('starts with empty definitions', () {
      expect(service.definitions, isEmpty);
    });

    test('adds definition correctly', () {
      final definition = _createTestApiDefinition();
      
      service.addDefinition(definition);
      
      expect(service.definitions.length, 1);
      expect(service.definitions.first, definition);
    });

    test('removes definition correctly', () {
      final definition = _createTestApiDefinition();
      service.addDefinition(definition);
      
      service.removeDefinition(definition);
      
      expect(service.definitions, isEmpty);
    });

    test('clears all definitions', () {
      final definition1 = _createTestApiDefinition();
      final definition2 = ApiDefinition(
        title: 'Another API',
        services: [
          ApiService(
            name: 'Another Service',
            baseUrl: 'https://another.example.com',
            endpoints: [],
          ),
        ],
      );
      
      service.addDefinition(definition1);
      service.addDefinition(definition2);
      expect(service.definitions.length, 2);
      
      service.clearDefinitions();
      expect(service.definitions, isEmpty);
    });

    test('gets all endpoints from all definitions', () {
      final endpoint1 = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
      );
      final endpoint2 = ApiEndpoint(
        name: 'Get Posts',
        path: '/posts',
        method: HttpMethod.get,
      );
      final endpoint3 = ApiEndpoint(
        name: 'Get Comments',
        path: '/comments',
        method: HttpMethod.get,
      );

      final definition1 = ApiDefinition(
        title: 'API 1',
        services: [
          ApiService(
            name: 'Service 1',
            baseUrl: 'https://api1.example.com',
            endpoints: [endpoint1, endpoint2],
          ),
        ],
      );
      final definition2 = ApiDefinition(
        title: 'API 2',
        services: [
          ApiService(
            name: 'Service 2',
            baseUrl: 'https://api2.example.com',
            endpoints: [endpoint3],
          ),
        ],
      );

      service.addDefinition(definition1);
      service.addDefinition(definition2);

      final allEndpoints = service.getAllEndpoints();
      expect(allEndpoints.length, 3);
      expect(allEndpoints, containsAll([endpoint1, endpoint2, endpoint3]));
    });

    test('gets endpoints by tag', () {
      final endpoint1 = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
        tags: ['users', 'public'],
      );
      final endpoint2 = ApiEndpoint(
        name: 'Get Posts',
        path: '/posts',
        method: HttpMethod.get,
        tags: ['posts', 'public'],
      );
      final endpoint3 = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        tags: ['users', 'admin'],
      );

      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://jsonplaceholder.typicode.com',
            endpoints: [endpoint1, endpoint2, endpoint3],
          ),
        ],
      );

      service.addDefinition(definition);

      final publicEndpoints = service.getEndpointsByTag('public');
      expect(publicEndpoints.length, 2);
      expect(publicEndpoints, containsAll([endpoint1, endpoint2]));

      final userEndpoints = service.getEndpointsByTag('users');
      expect(userEndpoints.length, 2);
      expect(userEndpoints, containsAll([endpoint1, endpoint3]));

      final adminEndpoints = service.getEndpointsByTag('admin');
      expect(adminEndpoints.length, 1);
      expect(adminEndpoints, contains(endpoint3));

      final nonExistentEndpoints = service.getEndpointsByTag('nonexistent');
      expect(nonExistentEndpoints, isEmpty);
    });

    test('searches endpoints by name, path, and description', () {
      final endpoint1 = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
        description: 'Retrieve all users from the system',
      );
      final endpoint2 = ApiEndpoint(
        name: 'Get Posts',
        path: '/posts',
        method: HttpMethod.get,
        description: 'Fetch blog posts',
      );
      final endpoint3 = ApiEndpoint(
        name: 'Search Users',
        path: '/users/search',
        method: HttpMethod.get,
        description: 'Find specific users',
      );

      final definition = ApiDefinition(
        title: 'Test API',
        services: [
          ApiService(
            name: 'Test Service',
            baseUrl: 'https://jsonplaceholder.typicode.com',
            endpoints: [endpoint1, endpoint2, endpoint3],
          ),
        ],
      );

      service.addDefinition(definition);

      // Search by name
      final userEndpoints = service.searchEndpoints('user');
      expect(userEndpoints.length, 2);
      expect(userEndpoints, containsAll([endpoint1, endpoint3]));

      // Search by path
      final searchEndpoints = service.searchEndpoints('search');
      expect(searchEndpoints.length, 1);
      expect(searchEndpoints, contains(endpoint3));

      // Search by description
      final blogEndpoints = service.searchEndpoints('blog');
      expect(blogEndpoints.length, 1);
      expect(blogEndpoints, contains(endpoint2));

      // Case insensitive search
      final upperCaseEndpoints = service.searchEndpoints('USERS');
      expect(upperCaseEndpoints.length, 2);
      expect(upperCaseEndpoints, containsAll([endpoint1, endpoint3]));

      // No results
      final noResults = service.searchEndpoints('nonexistent');
      expect(noResults, isEmpty);
    });

    test('loads sample definitions when requested', () {
      expect(service.definitions, isEmpty);
      
      service.loadSampleDefinitions();
      
      expect(service.definitions, isNotEmpty);
      expect(service.definitions.first.title, 'User API');
      expect(service.definitions.first.services.first.baseUrl, 
             'https://jsonplaceholder.typicode.com');
      
      final endpoints = service.getAllEndpoints();
      expect(endpoints, isNotEmpty);
      expect(endpoints.any((e) => e.name == 'Get Users'), true);
      expect(endpoints.any((e) => e.name == 'Create User'), true);
      expect(endpoints.any((e) => e.name == 'Delete User'), true);
    });

    test('does not load sample definitions if definitions already exist', () {
      final customDefinition = _createTestApiDefinition();
      service.addDefinition(customDefinition);
      expect(service.definitions.length, 1);
      
      service.loadSampleDefinitions();
      
      // Should still have only the custom definition
      expect(service.definitions.length, 1);
      expect(service.definitions.first, customDefinition);
    });

    test('saves and loads from storage', () async {
      final definition = _createTestApiDefinition();
      service.addDefinition(definition);
      
      // Clear in-memory definitions
      service.clearDefinitions();
      expect(service.definitions, isEmpty);
      
      // Load from storage
      await service.loadFromStorage();
      
      expect(service.definitions.length, 1);
      expect(service.definitions.first.title, definition.title);
      expect(service.definitions.first.services.first.name, 
             definition.services.first.name);
      expect(service.definitions.first.services.first.baseUrl, 
             definition.services.first.baseUrl);
      expect(service.definitions.first.services.first.endpoints.length, 
             definition.services.first.endpoints.length);
    });

    test('handles storage errors gracefully', () async {
      // This should not throw an exception
      await service.loadFromStorage();
      expect(service.definitions, isEmpty);
    });
  });
}

ApiDefinition _createTestApiDefinition() {
  final endpoint = ApiEndpoint(
    name: 'Get Test Data',
    path: '/test',
    method: HttpMethod.get,
    parameters: [
      ApiParameter(
        name: 'id',
        type: ParameterType.path,
        dataType: int,
        required: true,
        description: 'Test ID',
      ),
      ApiParameter(
        name: 'limit',
        type: ParameterType.query,
        dataType: int,
        defaultValue: 10,
      ),
    ],
    description: 'Test endpoint for testing',
    tags: ['test'],
  );

  final service = ApiService(
    name: 'Test Service',
    baseUrl: 'https://test.example.com',
    endpoints: [endpoint],
    description: 'A test service',
    tags: ['test'],
  );

  return ApiDefinition(
    title: 'Test API',
    version: '1.0.0',
    description: 'A test API definition',
    services: [service],
  );
}