import '../models/api_definition.dart';

/// Simplified builder for creating API definitions with minimal code.
/// 
/// This builder provides a more concise syntax for creating API definitions
/// compared to the verbose manual approach, while still being explicit about
/// the API structure.
class SimpleApiBuilder {
  final String title;
  final String baseUrl;
  final String? description;
  final List<EndpointSpec> _endpoints = [];
  
  SimpleApiBuilder({
    required this.title,
    required this.baseUrl,
    this.description,
  });
  
  /// Adds a GET endpoint with the specified path and optional parameters.
  SimpleApiBuilder get(
    String path, {
    String? name,
    String? description,
    List<String>? queryParams,
    List<String>? pathParams,
    List<String>? headerParams,
    List<String>? tags,
    String? responseType,
  }) {
    _endpoints.add(EndpointSpec(
      name: name ?? _generateName('GET', path),
      path: path,
      method: HttpMethod.get,
      description: description,
      queryParams: queryParams ?? [],
      pathParams: pathParams ?? _extractPathParams(path),
      headerParams: headerParams ?? [],
      tags: tags ?? [],
      responseType: responseType,
    ));
    return this;
  }
  
  /// Adds a POST endpoint with the specified path and optional parameters.
  SimpleApiBuilder post(
    String path, {
    String? name,
    String? description,
    List<String>? queryParams,
    List<String>? pathParams,
    List<String>? headerParams,
    bool hasBody = true,
    List<String>? tags,
    String? responseType,
  }) {
    _endpoints.add(EndpointSpec(
      name: name ?? _generateName('POST', path),
      path: path,
      method: HttpMethod.post,
      description: description,
      queryParams: queryParams ?? [],
      pathParams: pathParams ?? _extractPathParams(path),
      headerParams: headerParams ?? [],
      hasBody: hasBody,
      tags: tags ?? [],
      responseType: responseType,
    ));
    return this;
  }
  
  /// Adds a PUT endpoint with the specified path and optional parameters.
  SimpleApiBuilder put(
    String path, {
    String? name,
    String? description,
    List<String>? queryParams,
    List<String>? pathParams,
    List<String>? headerParams,
    bool hasBody = true,
    List<String>? tags,
    String? responseType,
  }) {
    _endpoints.add(EndpointSpec(
      name: name ?? _generateName('PUT', path),
      path: path,
      method: HttpMethod.put,
      description: description,
      queryParams: queryParams ?? [],
      pathParams: pathParams ?? _extractPathParams(path),
      headerParams: headerParams ?? [],
      hasBody: hasBody,
      tags: tags ?? [],
      responseType: responseType,
    ));
    return this;
  }
  
  /// Adds a DELETE endpoint with the specified path and optional parameters.
  SimpleApiBuilder delete(
    String path, {
    String? name,
    String? description,
    List<String>? queryParams,
    List<String>? pathParams,
    List<String>? headerParams,
    List<String>? tags,
    String? responseType,
  }) {
    _endpoints.add(EndpointSpec(
      name: name ?? _generateName('DELETE', path),
      path: path,
      method: HttpMethod.delete,
      description: description,
      queryParams: queryParams ?? [],
      pathParams: pathParams ?? _extractPathParams(path),
      headerParams: headerParams ?? [],
      tags: tags ?? [],
      responseType: responseType,
    ));
    return this;
  }
  
  /// Adds a PATCH endpoint with the specified path and optional parameters.
  SimpleApiBuilder patch(
    String path, {
    String? name,
    String? description,
    List<String>? queryParams,
    List<String>? pathParams,
    List<String>? headerParams,
    bool hasBody = true,
    List<String>? tags,
    String? responseType,
  }) {
    _endpoints.add(EndpointSpec(
      name: name ?? _generateName('PATCH', path),
      path: path,
      method: HttpMethod.patch,
      description: description,
      queryParams: queryParams ?? [],
      pathParams: pathParams ?? _extractPathParams(path),
      headerParams: headerParams ?? [],
      hasBody: hasBody,
      tags: tags ?? [],
      responseType: responseType,
    ));
    return this;
  }
  
  /// Builds the final API definition.
  ApiDefinition build() {
    final endpoints = _endpoints.map((spec) => _buildEndpoint(spec)).toList();
    
    return ApiDefinition(
      title: title,
      description: description,
      version: '1.0.0',
      services: [
        ApiService(
          name: title,
          baseUrl: baseUrl,
          description: description,
          endpoints: endpoints,
        ),
      ],
    );
  }
  
  /// Creates a standard CRUD API for a resource.
  /// 
  /// This is a convenience method that adds common CRUD endpoints:
  /// - GET /resource (list all)
  /// - GET /resource/{id} (get by ID)
  /// - POST /resource (create)
  /// - PUT /resource/{id} (update)
  /// - DELETE /resource/{id} (delete)
  static SimpleApiBuilder crud({
    required String title,
    required String baseUrl,
    required String resource,
    String? description,
    List<String>? listQueryParams,
    bool includeSearch = false,
  }) {
    final builder = SimpleApiBuilder(
      title: title,
      baseUrl: baseUrl,
      description: description,
    );
    
    // List all
    builder.get(
      '/$resource',
      name: 'Get All $resource',
      description: 'Retrieve all $resource items',
      queryParams: [
        ...?listQueryParams,
        if (includeSearch) 'search',
        '_limit',
        '_offset',
      ],
      tags: [resource, 'read'],
      responseType: 'List<${_capitalize(resource)}>',
    );
    
    // Get by ID
    builder.get(
      '/$resource/{id}',
      name: 'Get $resource by ID',
      description: 'Retrieve a specific $resource item',
      tags: [resource, 'read'],
      responseType: _capitalize(resource),
    );
    
    // Create
    builder.post(
      '/$resource',
      name: 'Create $resource',
      description: 'Create a new $resource item',
      tags: [resource, 'write'],
      responseType: _capitalize(resource),
    );
    
    // Update
    builder.put(
      '/$resource/{id}',
      name: 'Update $resource',
      description: 'Update an existing $resource item',
      tags: [resource, 'write'],
      responseType: _capitalize(resource),
    );
    
    // Delete
    builder.delete(
      '/$resource/{id}',
      name: 'Delete $resource',
      description: 'Delete a $resource item',
      tags: [resource, 'write'],
      responseType: 'void',
    );
    
    return builder;
  }
  
  /// Generates a readable name for an endpoint.
  String _generateName(String method, String path) {
    // Remove leading slash and replace slashes with spaces
    final pathPart = path.substring(1).replaceAll('/', ' ');
    
    // Remove path parameters (things in curly braces)
    final cleanPath = pathPart.replaceAll(RegExp(r'\{[^}]+\}'), 'by ID');
    
    return '$method $cleanPath'.trim();
  }
  
  /// Extracts path parameters from a path string.
  List<String> _extractPathParams(String path) {
    final regex = RegExp(r'\{([^}]+)\}');
    return regex
        .allMatches(path)
        .map((match) => match.group(1)!)
        .toList();
  }
  
  /// Builds an ApiEndpoint from an EndpointSpec.
  ApiEndpoint _buildEndpoint(EndpointSpec spec) {
    final parameters = <ApiParameter>[];
    
    // Add path parameters
    for (final param in spec.pathParams) {
      parameters.add(ApiParameter(
        name: param,
        type: ParameterType.path,
        dataType: param == 'id' ? int : String,
        required: true,
        description: 'The $param parameter',
      ));
    }
    
    // Add query parameters
    for (final param in spec.queryParams) {
      parameters.add(ApiParameter(
        name: param,
        type: ParameterType.query,
        dataType: _guessDataType(param),
        required: false,
        description: 'Query parameter: $param',
        defaultValue: _getDefaultValue(param),
      ));
    }
    
    // Add header parameters
    for (final param in spec.headerParams) {
      parameters.add(ApiParameter(
        name: param,
        type: ParameterType.header,
        dataType: String,
        required: true,
        description: 'Header parameter: $param',
      ));
    }
    
    // Add body parameter if needed
    if (spec.hasBody) {
      parameters.add(ApiParameter(
        name: 'body',
        type: ParameterType.body,
        dataType: Map,
        required: true,
        description: 'Request body data',
      ));
    }
    
    return ApiEndpoint(
      name: spec.name,
      path: spec.path,
      method: spec.method,
      description: spec.description,
      tags: spec.tags,
      parameters: parameters,
      responseType: spec.responseType,
    );
  }
  
  /// Guesses the data type based on parameter name.
  Type _guessDataType(String paramName) {
    final lowerName = paramName.toLowerCase();
    if (lowerName.contains('id') || 
        lowerName.contains('count') || 
        lowerName.contains('limit') || 
        lowerName.contains('offset') ||
        lowerName.contains('page')) {
      return int;
    }
    return String;
  }
  
  /// Gets a reasonable default value for common parameters.
  dynamic _getDefaultValue(String paramName) {
    switch (paramName.toLowerCase()) {
      case '_limit':
      case 'limit':
        return 10;
      case '_offset':
      case 'offset':
        return 0;
      case 'page':
        return 1;
      default:
        return null;
    }
  }
  
  /// Capitalizes the first letter of a string.
  static String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }
}

/// Internal class to hold endpoint specification during building.
class EndpointSpec {
  final String name;
  final String path;
  final HttpMethod method;
  final String? description;
  final List<String> queryParams;
  final List<String> pathParams;
  final List<String> headerParams;
  final bool hasBody;
  final List<String> tags;
  final String? responseType;
  
  EndpointSpec({
    required this.name,
    required this.path,
    required this.method,
    this.description,
    this.queryParams = const [],
    this.pathParams = const [],
    this.headerParams = const [],
    this.hasBody = false,
    this.tags = const [],
    this.responseType,
  });
}