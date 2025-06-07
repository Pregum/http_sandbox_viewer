import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/api_definition.dart';

/// Loader for OpenAPI/Swagger specifications.
/// 
/// This class can load OpenAPI definitions from various sources and convert
/// them to our internal API definition format.
class OpenApiLoader {
  /// Loads an OpenAPI definition from a JSON string.
  /// 
  /// [jsonString] - The OpenAPI specification as a JSON string
  /// [baseUrl] - Optional base URL override (if not specified in the spec)
  /// 
  /// Returns an [ApiDefinition] or null if parsing fails.
  static ApiDefinition? fromJsonString(String jsonString, {String? baseUrl}) {
    try {
      final Map<String, dynamic> spec = jsonDecode(jsonString);
      return _parseOpenApiSpec(spec, baseUrl: baseUrl);
    } catch (e) {
      debugPrint('Error parsing OpenAPI JSON: $e');
      return null;
    }
  }

  /// Loads an OpenAPI definition from a Map.
  /// 
  /// [spec] - The OpenAPI specification as a Map
  /// [baseUrl] - Optional base URL override
  /// 
  /// Returns an [ApiDefinition] or null if parsing fails.
  static ApiDefinition? fromMap(Map<String, dynamic> spec, {String? baseUrl}) {
    try {
      return _parseOpenApiSpec(spec, baseUrl: baseUrl);
    } catch (e) {
      debugPrint('Error parsing OpenAPI spec: $e');
      return null;
    }
  }

  /// Loads an OpenAPI definition from an asset file.
  /// 
  /// [assetPath] - Path to the asset file (e.g., 'assets/api/openapi.json')
  /// [baseUrl] - Optional base URL override
  /// 
  /// Returns an [ApiDefinition] or null if loading/parsing fails.
  static Future<ApiDefinition?> fromAsset(String assetPath, {String? baseUrl}) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return fromJsonString(jsonString, baseUrl: baseUrl);
    } catch (e) {
      debugPrint('Error loading OpenAPI from asset: $e');
      return null;
    }
  }

  /// Parses an OpenAPI specification and converts it to our API definition format.
  static ApiDefinition _parseOpenApiSpec(Map<String, dynamic> spec, {String? baseUrl}) {
    final info = spec['info'] as Map<String, dynamic>? ?? {};
    final paths = spec['paths'] as Map<String, dynamic>? ?? {};
    final servers = spec['servers'] as List<dynamic>? ?? [];
    
    // Determine base URL
    String resolvedBaseUrl = baseUrl ?? '';
    if (resolvedBaseUrl.isEmpty && servers.isNotEmpty) {
      final server = servers.first as Map<String, dynamic>;
      resolvedBaseUrl = server['url'] as String? ?? '';
    }
    if (resolvedBaseUrl.isEmpty) {
      resolvedBaseUrl = 'https://api.example.com'; // Fallback
    }

    // Parse API info
    final title = info['title'] as String? ?? 'API';
    final description = info['description'] as String?;
    final version = info['version'] as String? ?? '1.0.0';

    // Parse endpoints
    final endpoints = <ApiEndpoint>[];
    
    paths.forEach((path, pathItem) {
      if (pathItem is Map<String, dynamic>) {
        pathItem.forEach((method, operation) {
          if (operation is Map<String, dynamic> && _isHttpMethod(method)) {
            final endpoint = _parseOperation(path, method, operation);
            if (endpoint != null) {
              endpoints.add(endpoint);
            }
          }
        });
      }
    });

    // Create API service
    final service = ApiService(
      name: title,
      baseUrl: resolvedBaseUrl,
      description: description,
      endpoints: endpoints,
    );

    return ApiDefinition(
      title: title,
      description: description,
      version: version,
      services: [service],
    );
  }

  /// Parses a single OpenAPI operation into an ApiEndpoint.
  static ApiEndpoint? _parseOperation(String path, String method, Map<String, dynamic> operation) {
    try {
      final operationId = operation['operationId'] as String?;
      final summary = operation['summary'] as String?;
      final description = operation['description'] as String?;
      final tags = (operation['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      final parameters = operation['parameters'] as List<dynamic>? ?? [];
      final requestBody = operation['requestBody'] as Map<String, dynamic>?;
      final responses = operation['responses'] as Map<String, dynamic>? ?? {};

      // Parse parameters
      final apiParameters = <ApiParameter>[];
      
      for (final param in parameters) {
        if (param is Map<String, dynamic>) {
          final apiParam = _parseParameter(param);
          if (apiParam != null) {
            apiParameters.add(apiParam);
          }
        }
      }

      // Parse request body
      if (requestBody != null && _methodHasBody(method)) {
        final bodyParam = ApiParameter(
          name: 'body',
          type: ParameterType.body,
          dataType: Map,
          required: requestBody['required'] as bool? ?? false,
          description: requestBody['description'] as String? ?? 'Request body',
        );
        apiParameters.add(bodyParam);
      }

      // Determine response type
      String? responseType;
      final successResponse = responses['200'] ?? responses['201'] ?? responses['default'];
      if (successResponse is Map<String, dynamic>) {
        responseType = _extractResponseType(successResponse);
      }

      return ApiEndpoint(
        name: summary ?? operationId ?? '${method.toUpperCase()} $path',
        path: path,
        method: _parseHttpMethod(method),
        summary: summary,
        description: description,
        tags: tags,
        parameters: apiParameters,
        responseType: responseType,
      );
    } catch (e) {
      debugPrint('Error parsing operation $method $path: $e');
      return null;
    }
  }

  /// Parses an OpenAPI parameter into an ApiParameter.
  static ApiParameter? _parseParameter(Map<String, dynamic> param) {
    try {
      final name = param['name'] as String?;
      final inLocation = param['in'] as String?;
      final required = param['required'] as bool? ?? false;
      final description = param['description'] as String?;
      final schema = param['schema'] as Map<String, dynamic>? ?? {};
      final example = param['example'];

      if (name == null || inLocation == null) return null;

      final parameterType = _parseParameterType(inLocation);
      if (parameterType == null) return null;

      final dataType = _parseSchemaType(schema);
      final enumValues = _parseEnumValues(schema);

      return ApiParameter(
        name: name,
        type: parameterType,
        dataType: dataType,
        required: required,
        description: description,
        defaultValue: example,
        enumValues: enumValues,
      );
    } catch (e) {
      debugPrint('Error parsing parameter: $e');
      return null;
    }
  }

  /// Maps OpenAPI parameter locations to our ParameterType enum.
  static ParameterType? _parseParameterType(String inLocation) {
    switch (inLocation.toLowerCase()) {
      case 'path':
        return ParameterType.path;
      case 'query':
        return ParameterType.query;
      case 'header':
        return ParameterType.header;
      case 'formdata':
        return ParameterType.field;
      default:
        return null;
    }
  }

  /// Maps OpenAPI HTTP methods to our HttpMethod enum.
  static HttpMethod _parseHttpMethod(String method) {
    switch (method.toLowerCase()) {
      case 'get':
        return HttpMethod.get;
      case 'post':
        return HttpMethod.post;
      case 'put':
        return HttpMethod.put;
      case 'delete':
        return HttpMethod.delete;
      case 'patch':
        return HttpMethod.patch;
      case 'head':
        return HttpMethod.head;
      case 'options':
        return HttpMethod.options;
      default:
        return HttpMethod.get;
    }
  }

  /// Checks if a string represents a valid HTTP method.
  static bool _isHttpMethod(String method) {
    const methods = ['get', 'post', 'put', 'delete', 'patch', 'head', 'options'];
    return methods.contains(method.toLowerCase());
  }

  /// Checks if an HTTP method typically has a request body.
  static bool _methodHasBody(String method) {
    const methodsWithBody = ['post', 'put', 'patch'];
    return methodsWithBody.contains(method.toLowerCase());
  }

  /// Parses a JSON schema type to a Dart type.
  static Type _parseSchemaType(Map<String, dynamic> schema) {
    final type = schema['type'] as String?;
    final format = schema['format'] as String?;

    switch (type) {
      case 'integer':
        return int;
      case 'number':
        return format == 'float' ? double : double;
      case 'string':
        return String;
      case 'boolean':
        return bool;
      case 'array':
        return List;
      case 'object':
        return Map;
      default:
        return String;
    }
  }

  /// Extracts enum values from a JSON schema.
  static List<String>? _parseEnumValues(Map<String, dynamic> schema) {
    final enumList = schema['enum'] as List<dynamic>?;
    return enumList?.cast<String>();
  }

  /// Extracts response type from an OpenAPI response definition.
  static String? _extractResponseType(Map<String, dynamic> response) {
    final content = response['content'] as Map<String, dynamic>?;
    if (content == null) return null;

    // Look for JSON content type
    final jsonContent = content['application/json'] as Map<String, dynamic>?;
    if (jsonContent == null) return null;

    final schema = jsonContent['schema'] as Map<String, dynamic>?;
    if (schema == null) return null;

    // Extract type information
    final type = schema['type'] as String?;
    if (type == 'array') {
      final items = schema['items'] as Map<String, dynamic>?;
      final itemsRef = items?['\$ref'] as String?;
      if (itemsRef != null) {
        final typeName = itemsRef.split('/').last;
        return 'List<$typeName>';
      }
      return 'List';
    } else if (type == 'object') {
      final ref = schema['\$ref'] as String?;
      if (ref != null) {
        return ref.split('/').last;
      }
      return 'Object';
    }

    return type;
  }
}