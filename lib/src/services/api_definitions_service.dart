import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_definition.dart';

class ApiDefinitionsService {
  static final ApiDefinitionsService _instance = ApiDefinitionsService._internal();
  static ApiDefinitionsService get instance => _instance;
  ApiDefinitionsService._internal();

  static const String _storageKey = 'api_definitions_sandbox';
  final List<ApiDefinition> _definitions = [];

  List<ApiDefinition> get definitions => List.unmodifiable(_definitions);

  void addDefinition(ApiDefinition definition) {
    _definitions.add(definition);
    _saveToStorage();
  }

  void removeDefinition(ApiDefinition definition) {
    _definitions.remove(definition);
    _saveToStorage();
  }

  void clearDefinitions() {
    _definitions.clear();
    _saveToStorage();
  }

  List<ApiEndpoint> getAllEndpoints() {
    return _definitions.expand((def) => def.allEndpoints).toList();
  }

  List<ApiEndpoint> getEndpointsByTag(String tag) {
    return getAllEndpoints()
        .where((endpoint) => endpoint.tags.contains(tag))
        .toList();
  }

  List<ApiEndpoint> searchEndpoints(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllEndpoints().where((endpoint) {
      return endpoint.name.toLowerCase().contains(lowercaseQuery) ||
          endpoint.path.toLowerCase().contains(lowercaseQuery) ||
          endpoint.description?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final definitionsJson = prefs.getString(_storageKey);
      if (definitionsJson != null) {
        final definitionsList = jsonDecode(definitionsJson) as List;
        _definitions.clear();
        for (final definitionMap in definitionsList) {
          _definitions.add(_definitionFromMap(definitionMap));
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final definitionsJson = jsonEncode(_definitions.map((d) => _definitionToMap(d)).toList());
      await prefs.setString(_storageKey, definitionsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Map<String, dynamic> _definitionToMap(ApiDefinition definition) {
    return {
      'title': definition.title,
      'version': definition.version,
      'description': definition.description,
      'services': definition.services.map((s) => _serviceToMap(s)).toList(),
      'globalHeaders': definition.globalHeaders,
    };
  }

  Map<String, dynamic> _serviceToMap(ApiService service) {
    return {
      'name': service.name,
      'baseUrl': service.baseUrl,
      'description': service.description,
      'tags': service.tags,
      'defaultHeaders': service.defaultHeaders,
      'endpoints': service.endpoints.map((e) => _endpointToMap(e)).toList(),
    };
  }

  Map<String, dynamic> _endpointToMap(ApiEndpoint endpoint) {
    return {
      'name': endpoint.name,
      'path': endpoint.path,
      'method': endpoint.method.name,
      'description': endpoint.description,
      'summary': endpoint.summary,
      'tags': endpoint.tags,
      'headers': endpoint.headers,
      'responseType': endpoint.responseType,
      'parameters': endpoint.parameters.map((p) => _parameterToMap(p)).toList(),
    };
  }

  Map<String, dynamic> _parameterToMap(ApiParameter parameter) {
    return {
      'name': parameter.name,
      'type': parameter.type.name,
      'dataType': parameter.dataType.toString(),
      'required': parameter.required,
      'description': parameter.description,
      'defaultValue': parameter.defaultValue,
      'enumValues': parameter.enumValues,
    };
  }

  ApiDefinition _definitionFromMap(Map<String, dynamic> map) {
    return ApiDefinition(
      title: map['title'],
      version: map['version'],
      description: map['description'],
      services: (map['services'] as List)
          .map((s) => _serviceFromMap(s))
          .toList(),
      globalHeaders: map['globalHeaders'] != null
          ? Map<String, String>.from(map['globalHeaders'])
          : null,
    );
  }

  ApiService _serviceFromMap(Map<String, dynamic> map) {
    return ApiService(
      name: map['name'],
      baseUrl: map['baseUrl'],
      description: map['description'],
      tags: List<String>.from(map['tags'] ?? []),
      defaultHeaders: map['defaultHeaders'] != null
          ? Map<String, String>.from(map['defaultHeaders'])
          : null,
      endpoints: (map['endpoints'] as List)
          .map((e) => _endpointFromMap(e))
          .toList(),
    );
  }

  ApiEndpoint _endpointFromMap(Map<String, dynamic> map) {
    return ApiEndpoint(
      name: map['name'],
      path: map['path'],
      method: HttpMethod.values.firstWhere((m) => m.name == map['method']),
      description: map['description'],
      summary: map['summary'],
      tags: List<String>.from(map['tags'] ?? []),
      headers: map['headers'] != null
          ? Map<String, String>.from(map['headers'])
          : null,
      responseType: map['responseType'],
      parameters: (map['parameters'] as List)
          .map((p) => _parameterFromMap(p))
          .toList(),
    );
  }

  ApiParameter _parameterFromMap(Map<String, dynamic> map) {
    return ApiParameter(
      name: map['name'],
      type: ParameterType.values.firstWhere((t) => t.name == map['type']),
      dataType: _stringToType(map['dataType']),
      required: map['required'] ?? false,
      description: map['description'],
      defaultValue: map['defaultValue'],
      enumValues: map['enumValues'] != null
          ? List<String>.from(map['enumValues'])
          : null,
    );
  }

  Type _stringToType(String typeString) {
    switch (typeString) {
      case 'String':
        return String;
      case 'int':
        return int;
      case 'double':
        return double;
      case 'bool':
        return bool;
      case 'List':
        return List;
      case 'Map':
        return Map;
      default:
        return String;
    }
  }

  // Sample API definitions for demo purposes
  void loadSampleDefinitions() {
    if (_definitions.isNotEmpty) return;

    final sampleDefinition = ApiDefinitionBuilder.fromRetrofitService(
      serviceName: 'User API',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      description: 'Sample API for user management',
      endpoints: [
        ApiDefinitionBuilder.endpoint(
          name: 'Get Users',
          path: '/users',
          method: HttpMethod.get,
          description: 'Retrieve all users',
          summary: 'Get all users from the system',
          tags: ['users'],
          parameters: [
            ApiDefinitionBuilder.queryParam(
              'page',
              dataType: int,
              description: 'Page number for pagination',
              defaultValue: 1,
            ),
            ApiDefinitionBuilder.queryParam(
              'limit',
              dataType: int,
              description: 'Number of users per page',
              defaultValue: 10,
            ),
          ],
          responseType: 'List<User>',
        ),
        ApiDefinitionBuilder.endpoint(
          name: 'Get User by ID',
          path: '/users/{id}',
          method: HttpMethod.get,
          description: 'Retrieve a specific user by ID',
          summary: 'Get user details',
          tags: ['users'],
          parameters: [
            ApiDefinitionBuilder.pathParam(
              'id',
              dataType: int,
              description: 'User ID',
            ),
          ],
          responseType: 'User',
        ),
        ApiDefinitionBuilder.endpoint(
          name: 'Create User',
          path: '/users',
          method: HttpMethod.post,
          description: 'Create a new user',
          summary: 'Add new user to the system',
          tags: ['users'],
          parameters: [
            ApiDefinitionBuilder.bodyParam(
              description: 'User data to create',
            ),
          ],
          responseType: 'User',
        ),
        ApiDefinitionBuilder.endpoint(
          name: 'Update User',
          path: '/users/{id}',
          method: HttpMethod.put,
          description: 'Update an existing user',
          summary: 'Update user information',
          tags: ['users'],
          parameters: [
            ApiDefinitionBuilder.pathParam(
              'id',
              dataType: int,
              description: 'User ID to update',
            ),
            ApiDefinitionBuilder.bodyParam(
              description: 'Updated user data',
            ),
          ],
          responseType: 'User',
        ),
        ApiDefinitionBuilder.endpoint(
          name: 'Delete User',
          path: '/users/{id}',
          method: HttpMethod.delete,
          description: 'Delete a user',
          summary: 'Remove user from the system',
          tags: ['users'],
          parameters: [
            ApiDefinitionBuilder.pathParam(
              'id',
              dataType: int,
              description: 'User ID to delete',
            ),
          ],
          responseType: 'void',
        ),
      ],
    );

    addDefinition(sampleDefinition);
  }
}