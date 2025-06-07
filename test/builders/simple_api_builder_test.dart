import 'package:flutter_test/flutter_test.dart';
import 'package:http_sandbox_viewer/src/builders/simple_api_builder.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';

void main() {
  group('SimpleApiBuilder', () {
    test('should create basic API definition', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
        description: 'Test API Description',
      ).build();

      expect(apiDefinition.title, equals('Test API'));
      expect(apiDefinition.description, equals('Test API Description'));
      expect(apiDefinition.services.length, equals(1));
      expect(apiDefinition.services.first.baseUrl, equals('https://api.test.com'));
      expect(apiDefinition.services.first.endpoints.isEmpty, isTrue);
    });

    test('should create API definition with GET endpoint', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .get('/users',
              name: 'Get Users',
              description: 'Retrieve all users',
              queryParams: ['limit', 'offset'],
              tags: ['users', 'read'],
              responseType: 'List<User>')
          .build();

      expect(apiDefinition.services.first.endpoints.length, equals(1));

      final endpoint = apiDefinition.services.first.endpoints.first;
      expect(endpoint.name, equals('Get Users'));
      expect(endpoint.path, equals('/users'));
      expect(endpoint.method, equals(HttpMethod.get));
      expect(endpoint.description, equals('Retrieve all users'));
      expect(endpoint.tags, contains('users'));
      expect(endpoint.tags, contains('read'));
      expect(endpoint.responseType, equals('List<User>'));
      expect(endpoint.parameters.length, equals(2));

      final limitParam = endpoint.parameters.firstWhere((p) => p.name == 'limit');
      expect(limitParam.type, equals(ParameterType.query));
      expect(limitParam.dataType, equals(int));

      final offsetParam = endpoint.parameters.firstWhere((p) => p.name == 'offset');
      expect(offsetParam.type, equals(ParameterType.query));
      expect(offsetParam.dataType, equals(int));
    });

    test('should create API definition with POST endpoint', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .post('/users',
              name: 'Create User',
              description: 'Create a new user',
              tags: ['users', 'write'],
              responseType: 'User')
          .build();

      final endpoint = apiDefinition.services.first.endpoints.first;
      expect(endpoint.name, equals('Create User'));
      expect(endpoint.path, equals('/users'));
      expect(endpoint.method, equals(HttpMethod.post));
      expect(endpoint.parameters.length, equals(1));

      final bodyParam = endpoint.parameters.first;
      expect(bodyParam.name, equals('body'));
      expect(bodyParam.type, equals(ParameterType.body));
      expect(bodyParam.dataType, equals(Map));
      expect(bodyParam.required, isTrue);
    });

    test('should create API definition with path parameters', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .get('/users/{id}',
              name: 'Get User by ID',
              tags: ['users'],
              responseType: 'User')
          .delete('/users/{userId}/posts/{postId}',
              name: 'Delete User Post',
              tags: ['users', 'posts'])
          .build();

      expect(apiDefinition.services.first.endpoints.length, equals(2));

      // Check single path parameter
      final getUserEndpoint = apiDefinition.services.first.endpoints
          .firstWhere((e) => e.path == '/users/{id}');
      expect(getUserEndpoint.parameters.length, equals(1));
      final idParam = getUserEndpoint.parameters.first;
      expect(idParam.name, equals('id'));
      expect(idParam.type, equals(ParameterType.path));
      expect(idParam.dataType, equals(String)); // Default type is String
      expect(idParam.required, isTrue);

      // Check multiple path parameters
      final deleteEndpoint = apiDefinition.services.first.endpoints
          .firstWhere((e) => e.path == '/users/{userId}/posts/{postId}');
      expect(deleteEndpoint.parameters.length, equals(2));
      
      final userIdParam = deleteEndpoint.parameters.firstWhere((p) => p.name == 'userId');
      expect(userIdParam.type, equals(ParameterType.path));
      expect(userIdParam.dataType, equals(String)); // Default type is String
      expect(userIdParam.required, isTrue);

      final postIdParam = deleteEndpoint.parameters.firstWhere((p) => p.name == 'postId');
      expect(postIdParam.type, equals(ParameterType.path));
      expect(postIdParam.dataType, equals(String)); // Default type is String
      expect(postIdParam.required, isTrue);
    });

    test('should create API definition with header parameters', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .get('/users',
              name: 'Get Users',
              headerParams: ['Authorization', 'X-API-Key'],
              tags: ['users'])
          .build();

      final endpoint = apiDefinition.services.first.endpoints.first;
      expect(endpoint.parameters.length, equals(2));

      final authParam = endpoint.parameters.firstWhere((p) => p.name == 'Authorization');
      expect(authParam.type, equals(ParameterType.header));
      expect(authParam.dataType, equals(String));
      expect(authParam.required, isTrue);

      final apiKeyParam = endpoint.parameters.firstWhere((p) => p.name == 'X-API-Key');
      expect(apiKeyParam.type, equals(ParameterType.header));
      expect(apiKeyParam.dataType, equals(String));
      expect(apiKeyParam.required, isTrue);
    });

    test('should create API definition with multiple endpoints', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .get('/users', name: 'Get Users', tags: ['users'])
          .post('/users', name: 'Create User', tags: ['users'])
          .build();

      final endpoints = apiDefinition.services.first.endpoints;
      expect(endpoints.length, equals(2));

      final getUsersEndpoint = endpoints.firstWhere((e) => e.method == HttpMethod.get);
      expect(getUsersEndpoint.name, equals('Get Users'));
      expect(getUsersEndpoint.tags, contains('users'));

      final createUserEndpoint = endpoints.firstWhere((e) => e.method == HttpMethod.post);
      expect(createUserEndpoint.name, equals('Create User'));
      expect(createUserEndpoint.tags, contains('users'));
      expect(createUserEndpoint.parameters.any((p) => p.type == ParameterType.body), isTrue);
    });

    test('should create API definition with mixed parameters', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .put('/users/{id}',
              name: 'Update User',
              queryParams: ['validate'],
              headerParams: ['Authorization'],
              tags: ['users'])
          .build();

      final endpoint = apiDefinition.services.first.endpoints.first;
      expect(endpoint.parameters.length, equals(4)); // path + query + header + body

      final idParam = endpoint.parameters.firstWhere((p) => p.name == 'id');
      expect(idParam.type, equals(ParameterType.path));

      final validateParam = endpoint.parameters.firstWhere((p) => p.name == 'validate');
      expect(validateParam.type, equals(ParameterType.query));

      final authParam = endpoint.parameters.firstWhere((p) => p.name == 'Authorization');
      expect(authParam.type, equals(ParameterType.header));

      final bodyParam = endpoint.parameters.firstWhere((p) => p.name == 'body');
      expect(bodyParam.type, equals(ParameterType.body));
    });

    test('should handle hasBody parameter correctly', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .post('/users',
              name: 'Create User',
              hasBody: true)
          .post('/notifications',
              name: 'Send Notification',
              hasBody: false)
          .build();

      final createUserEndpoint = apiDefinition.services.first.endpoints
          .firstWhere((e) => e.path == '/users');
      expect(createUserEndpoint.parameters.any((p) => p.type == ParameterType.body), isTrue);

      final notificationEndpoint = apiDefinition.services.first.endpoints
          .firstWhere((e) => e.path == '/notifications');
      expect(notificationEndpoint.parameters.any((p) => p.type == ParameterType.body), isFalse);
    });

    test('should create supported HTTP methods', () {
      final apiDefinition = SimpleApiBuilder(
        title: 'Test API',
        baseUrl: 'https://api.test.com',
      )
          .get('/test', name: 'GET Test')
          .post('/test', name: 'POST Test')
          .put('/test', name: 'PUT Test')
          .delete('/test', name: 'DELETE Test')
          .patch('/test', name: 'PATCH Test')
          .build();

      final endpoints = apiDefinition.services.first.endpoints;
      expect(endpoints.length, equals(5));

      expect(endpoints.any((e) => e.method == HttpMethod.get), isTrue);
      expect(endpoints.any((e) => e.method == HttpMethod.post), isTrue);
      expect(endpoints.any((e) => e.method == HttpMethod.put), isTrue);
      expect(endpoints.any((e) => e.method == HttpMethod.delete), isTrue);
      expect(endpoints.any((e) => e.method == HttpMethod.patch), isTrue);
    });

    group('CRUD Builder', () {
      test('should create basic CRUD endpoints', () {
        final apiDefinition = SimpleApiBuilder.crud(
          title: 'Posts API',
          baseUrl: 'https://api.test.com',
          resource: 'posts',
        ).build();

        expect(apiDefinition.title, equals('Posts API'));
        expect(apiDefinition.services.first.endpoints.length, equals(5));

        final endpoints = apiDefinition.services.first.endpoints;

        // GET /posts
        final listEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts' && e.method == HttpMethod.get);
        expect(listEndpoint.name, equals('Get All Posts'));
        expect(listEndpoint.tags, contains('posts'));

        // GET /posts/{id}
        final getEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.get);
        expect(getEndpoint.name, equals('Get Post'));
        expect(getEndpoint.parameters.any((p) => p.name == 'id'), isTrue);

        // POST /posts
        final createEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts' && e.method == HttpMethod.post);
        expect(createEndpoint.name, equals('Create Post'));
        expect(createEndpoint.parameters.any((p) => p.type == ParameterType.body), isTrue);

        // PUT /posts/{id}
        final updateEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.put);
        expect(updateEndpoint.name, equals('Update Post'));

        // DELETE /posts/{id}
        final deleteEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.delete);
        expect(deleteEndpoint.name, equals('Delete Post'));
      });

      test('should create CRUD with custom options', () {
        final apiDefinition = SimpleApiBuilder.crud(
          title: 'Users API',
          baseUrl: 'https://api.test.com',
          resource: 'users',
          description: 'User management API',
          listQueryParams: ['role', 'status'],
          includeSearch: true,
        ).build();

        expect(apiDefinition.description, equals('User management API'));
        
        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, equals(6)); // 5 CRUD + 1 search

        // Check list endpoint has query params
        final listEndpoint = endpoints.firstWhere((e) => 
            e.path == '/users' && e.method == HttpMethod.get);
        expect(listEndpoint.parameters.length, equals(2));
        expect(listEndpoint.parameters.any((p) => p.name == 'role'), isTrue);
        expect(listEndpoint.parameters.any((p) => p.name == 'status'), isTrue);

        // Check search endpoint exists
        final searchEndpoint = endpoints.firstWhere((e) => 
            e.path == '/users/search');
        expect(searchEndpoint.name, equals('Search Users'));
        expect(searchEndpoint.parameters.any((p) => p.name == 'q'), isTrue);
      });

      test('should create CRUD without search when disabled', () {
        final apiDefinition = SimpleApiBuilder.crud(
          title: 'Posts API',
          baseUrl: 'https://api.test.com',
          resource: 'posts',
          includeSearch: false,
        ).build();

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, equals(5)); // Only CRUD endpoints
        expect(endpoints.any((e) => e.path.contains('search')), isFalse);
      });
    });

    group('Parameter handling', () {
      test('should default to String type for all parameters', () {
        final apiDefinition = SimpleApiBuilder(
          title: 'Test API',
          baseUrl: 'https://api.test.com',
        )
            .get('/users',
                queryParams: ['id', 'name', 'active', 'limit'])
            .build();

        final endpoint = apiDefinition.services.first.endpoints.first;
        
        // All parameters should default to String type
        for (final param in endpoint.parameters) {
          expect(param.dataType, equals(String), 
              reason: '${param.name} should be String type by default');
        }
      });
    });

    group('Fluent API chaining', () {
      test('should support method chaining', () {
        final builder = SimpleApiBuilder(
          title: 'Chained API',
          baseUrl: 'https://api.test.com',
        );

        final apiDefinition = builder
            .get('/users')
            .post('/users')
            .get('/users/{id}')
            .put('/users/{id}')
            .delete('/users/{id}')
            .build();

        expect(apiDefinition.services.first.endpoints.length, equals(5));
      });

      test('should maintain builder state across calls', () {
        final builder = SimpleApiBuilder(
          title: 'Stateful API',
          baseUrl: 'https://api.test.com',
        );

        builder.get('/endpoint1');
        builder.post('/endpoint2');
        final apiDefinition = builder.build();

        expect(apiDefinition.title, equals('Stateful API'));
        expect(apiDefinition.services.first.baseUrl, equals('https://api.test.com'));
        expect(apiDefinition.services.first.endpoints.length, equals(2));
      });
    });

    group('Constructor validation', () {
      test('should accept empty title and baseUrl', () {
        // SimpleApiBuilder doesn't validate inputs in constructor
        expect(() => SimpleApiBuilder(title: '', baseUrl: ''), returnsNormally);
        expect(() => SimpleApiBuilder(title: 'Test API', baseUrl: ''), returnsNormally);
      });

      test('should accept all path formats', () {
        final builder = SimpleApiBuilder(
          title: 'Test API',
          baseUrl: 'https://api.test.com',
        );

        // SimpleApiBuilder accepts any path format
        expect(() => builder.get(''), returnsNormally);
        expect(() => builder.get('/users'), returnsNormally);
        expect(() => builder.get('/users/{id}'), returnsNormally);
        expect(() => builder.get('/users/{id}/posts'), returnsNormally);
      });
    });
  });
}