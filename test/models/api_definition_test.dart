import 'package:flutter_test/flutter_test.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';

void main() {
  group('ApiParameter', () {
    test('creates valid ApiParameter with all properties', () {
      final parameter = ApiParameter(
        name: 'userId',
        type: ParameterType.query,
        dataType: int,
        required: true,
        description: 'User identifier',
        defaultValue: 1,
        enumValues: ['1', '2', '3'],
      );

      expect(parameter.name, 'userId');
      expect(parameter.type, ParameterType.query);
      expect(parameter.dataType, int);
      expect(parameter.required, true);
      expect(parameter.description, 'User identifier');
      expect(parameter.defaultValue, 1);
      expect(parameter.enumValues, ['1', '2', '3']);
    });

    test('returns correct type string for different data types', () {
      expect(
        ApiParameter(
          name: 'test',
          type: ParameterType.query,
          dataType: String,
        ).typeString,
        'String',
      );
      
      expect(
        ApiParameter(
          name: 'test',
          type: ParameterType.query,
          dataType: int,
        ).typeString,
        'int',
      );
      
      expect(
        ApiParameter(
          name: 'test',
          type: ParameterType.query,
          dataType: double,
        ).typeString,
        'double',
      );
      
      expect(
        ApiParameter(
          name: 'test',
          type: ParameterType.query,
          dataType: bool,
        ).typeString,
        'bool',
      );
      
      expect(
        ApiParameter(
          name: 'test',
          type: ParameterType.query,
          dataType: List,
        ).typeString,
        'List',
      );
      
      expect(
        ApiParameter(
          name: 'test',
          type: ParameterType.query,
          dataType: Map,
        ).typeString,
        'Map',
      );
    });

    test('creates parameter with minimal required fields', () {
      final parameter = ApiParameter(
        name: 'simple',
        type: ParameterType.path,
        dataType: String,
      );

      expect(parameter.name, 'simple');
      expect(parameter.type, ParameterType.path);
      expect(parameter.dataType, String);
      expect(parameter.required, false);
      expect(parameter.description, null);
      expect(parameter.defaultValue, null);
      expect(parameter.enumValues, null);
    });
  });

  group('ApiEndpoint', () {
    test('creates valid ApiEndpoint with all properties', () {
      final parameters = [
        ApiParameter(
          name: 'id',
          type: ParameterType.path,
          dataType: int,
          required: true,
        ),
        ApiParameter(
          name: 'limit',
          type: ParameterType.query,
          dataType: int,
        ),
      ];

      final endpoint = ApiEndpoint(
        name: 'Get User',
        path: '/users/{id}',
        method: HttpMethod.get,
        parameters: parameters,
        description: 'Get user by ID',
        summary: 'Retrieve user details',
        tags: ['users', 'read'],
        headers: {'Authorization': 'Bearer token'},
        responseType: 'User',
      );

      expect(endpoint.name, 'Get User');
      expect(endpoint.path, '/users/{id}');
      expect(endpoint.method, HttpMethod.get);
      expect(endpoint.parameters, parameters);
      expect(endpoint.description, 'Get user by ID');
      expect(endpoint.summary, 'Retrieve user details');
      expect(endpoint.tags, ['users', 'read']);
      expect(endpoint.headers, {'Authorization': 'Bearer token'});
      expect(endpoint.responseType, 'User');
    });

    test('returns correct method string', () {
      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.post,
      );

      expect(endpoint.methodString, 'POST');
    });

    test('filters parameters by type correctly', () {
      final pathParam = ApiParameter(
        name: 'id',
        type: ParameterType.path,
        dataType: int,
      );
      final queryParam = ApiParameter(
        name: 'limit',
        type: ParameterType.query,
        dataType: int,
      );
      final headerParam = ApiParameter(
        name: 'authorization',
        type: ParameterType.header,
        dataType: String,
      );
      final bodyParam = ApiParameter(
        name: 'body',
        type: ParameterType.body,
        dataType: Map,
      );
      final fieldParam = ApiParameter(
        name: 'field',
        type: ParameterType.field,
        dataType: String,
      );

      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.post,
        parameters: [pathParam, queryParam, headerParam, bodyParam, fieldParam],
      );

      expect(endpoint.pathParameters, [pathParam]);
      expect(endpoint.queryParameters, [queryParam]);
      expect(endpoint.headerParameters, [headerParam]);
      expect(endpoint.bodyParameter, bodyParam);
      expect(endpoint.fieldParameters, [fieldParam]);
    });

    test('returns null for bodyParameter when none exists', () {
      final endpoint = ApiEndpoint(
        name: 'Test',
        path: '/test',
        method: HttpMethod.get,
        parameters: [
          ApiParameter(
            name: 'query',
            type: ParameterType.query,
            dataType: String,
          ),
        ],
      );

      expect(endpoint.bodyParameter, null);
    });
  });

  group('ApiService', () {
    test('creates valid ApiService', () {
      final endpoint = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
      );

      final service = ApiService(
        name: 'User Service',
        baseUrl: 'https://api.example.com',
        endpoints: [endpoint],
        description: 'User management API',
        tags: ['users'],
        defaultHeaders: {'Content-Type': 'application/json'},
      );

      expect(service.name, 'User Service');
      expect(service.baseUrl, 'https://api.example.com');
      expect(service.endpoints, [endpoint]);
      expect(service.description, 'User management API');
      expect(service.tags, ['users']);
      expect(service.defaultHeaders, {'Content-Type': 'application/json'});
    });
  });

  group('ApiDefinition', () {
    test('creates valid ApiDefinition', () {
      final endpoint = ApiEndpoint(
        name: 'Get Users',
        path: '/users',
        method: HttpMethod.get,
        tags: ['users', 'public'],
      );

      final service = ApiService(
        name: 'User Service',
        baseUrl: 'https://api.example.com',
        endpoints: [endpoint],
        tags: ['service'],
      );

      final definition = ApiDefinition(
        title: 'My API',
        version: '1.0.0',
        description: 'A sample API',
        services: [service],
        globalHeaders: {'X-API-Key': 'secret'},
      );

      expect(definition.title, 'My API');
      expect(definition.version, '1.0.0');
      expect(definition.description, 'A sample API');
      expect(definition.services, [service]);
      expect(definition.globalHeaders, {'X-API-Key': 'secret'});
    });

    test('returns all endpoints from all services', () {
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

      final service1 = ApiService(
        name: 'User Service',
        baseUrl: 'https://api.example.com',
        endpoints: [endpoint1],
      );
      final service2 = ApiService(
        name: 'Post Service',
        baseUrl: 'https://api.example.com',
        endpoints: [endpoint2],
      );

      final definition = ApiDefinition(
        title: 'My API',
        services: [service1, service2],
      );

      expect(definition.allEndpoints, [endpoint1, endpoint2]);
    });

    test('returns all unique tags sorted', () {
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

      final service = ApiService(
        name: 'Service',
        baseUrl: 'https://api.example.com',
        endpoints: [endpoint1, endpoint2],
        tags: ['api'],
      );

      final definition = ApiDefinition(
        title: 'My API',
        services: [service],
      );

      expect(definition.allTags, ['api', 'posts', 'public', 'users']);
    });
  });

  group('ApiDefinitionBuilder', () {
    test('creates ApiDefinition from Retrofit service', () {
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
          ),
        ],
      );

      final definition = ApiDefinitionBuilder.fromRetrofitService(
        serviceName: 'UserApi',
        baseUrl: 'https://api.example.com',
        endpoints: [endpoint],
        description: 'User API service',
        defaultHeaders: {'Authorization': 'Bearer token'},
      );

      expect(definition.title, 'UserApi');
      expect(definition.services.length, 1);
      expect(definition.services.first.name, 'UserApi');
      expect(definition.services.first.baseUrl, 'https://api.example.com');
      expect(definition.services.first.endpoints, [endpoint]);
      expect(definition.services.first.description, 'User API service');
      expect(definition.services.first.defaultHeaders, {'Authorization': 'Bearer token'});
    });

    test('creates endpoint with builder method', () {
      final endpoint = ApiDefinitionBuilder.endpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        parameters: [
          ApiDefinitionBuilder.pathParam('id', dataType: int),
          ApiDefinitionBuilder.queryParam('limit', dataType: int, defaultValue: 10),
          ApiDefinitionBuilder.headerParam('authorization', dataType: String),
          ApiDefinitionBuilder.bodyParam(dataType: Map),
          ApiDefinitionBuilder.fieldParam('name', dataType: String),
        ],
        description: 'Create a new user',
        summary: 'User creation endpoint',
        tags: ['users', 'write'],
        headers: {'Content-Type': 'application/json'},
        responseType: 'User',
      );

      expect(endpoint.name, 'Create User');
      expect(endpoint.path, '/users');
      expect(endpoint.method, HttpMethod.post);
      expect(endpoint.parameters.length, 5);
      expect(endpoint.description, 'Create a new user');
      expect(endpoint.summary, 'User creation endpoint');
      expect(endpoint.tags, ['users', 'write']);
      expect(endpoint.headers, {'Content-Type': 'application/json'});
      expect(endpoint.responseType, 'User');
    });

    test('creates different parameter types correctly', () {
      final pathParam = ApiDefinitionBuilder.pathParam(
        'id',
        dataType: int,
        description: 'User ID',
      );
      expect(pathParam.name, 'id');
      expect(pathParam.type, ParameterType.path);
      expect(pathParam.dataType, int);
      expect(pathParam.required, true);
      expect(pathParam.description, 'User ID');

      final queryParam = ApiDefinitionBuilder.queryParam(
        'limit',
        dataType: int,
        defaultValue: 10,
        enumValues: ['10', '20', '50'],
      );
      expect(queryParam.name, 'limit');
      expect(queryParam.type, ParameterType.query);
      expect(queryParam.dataType, int);
      expect(queryParam.required, false);
      expect(queryParam.defaultValue, 10);
      expect(queryParam.enumValues, ['10', '20', '50']);

      final headerParam = ApiDefinitionBuilder.headerParam(
        'authorization',
        dataType: String,
        required: true,
      );
      expect(headerParam.name, 'authorization');
      expect(headerParam.type, ParameterType.header);
      expect(headerParam.dataType, String);
      expect(headerParam.required, true);

      final bodyParam = ApiDefinitionBuilder.bodyParam(
        dataType: Map,
        description: 'Request body',
      );
      expect(bodyParam.name, 'body');
      expect(bodyParam.type, ParameterType.body);
      expect(bodyParam.dataType, Map);
      expect(bodyParam.required, true);
      expect(bodyParam.description, 'Request body');

      final fieldParam = ApiDefinitionBuilder.fieldParam(
        'name',
        dataType: String,
        defaultValue: 'John',
      );
      expect(fieldParam.name, 'name');
      expect(fieldParam.type, ParameterType.field);
      expect(fieldParam.dataType, String);
      expect(fieldParam.required, false);
      expect(fieldParam.defaultValue, 'John');
    });
  });
}