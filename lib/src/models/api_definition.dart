enum HttpMethod { get, post, put, delete, patch, head, options }

enum ParameterType { path, query, body, header, field }

class ApiParameter {
  final String name;
  final ParameterType type;
  final Type dataType;
  final bool required;
  final String? description;
  final dynamic defaultValue;
  final List<String>? enumValues;

  const ApiParameter({
    required this.name,
    required this.type,
    required this.dataType,
    this.required = false,
    this.description,
    this.defaultValue,
    this.enumValues,
  });

  String get typeString {
    if (dataType == String) {
      return 'String';
    } else if (dataType == int) {
      return 'int';
    } else if (dataType == double) {
      return 'double';
    } else if (dataType == bool) {
      return 'bool';
    } else if (dataType == List) {
      return 'List';
    } else if (dataType == Map) {
      return 'Map';
    } else {
      return dataType.toString();
    }
  }
}

class ApiEndpoint {
  final String name;
  final String path;
  final HttpMethod method;
  final List<ApiParameter> parameters;
  final String? description;
  final String? summary;
  final List<String> tags;
  final Map<String, String>? headers;
  final String? responseType;

  const ApiEndpoint({
    required this.name,
    required this.path,
    required this.method,
    this.parameters = const [],
    this.description,
    this.summary,
    this.tags = const [],
    this.headers,
    this.responseType,
  });

  String get methodString => method.name.toUpperCase();

  List<ApiParameter> get pathParameters =>
      parameters.where((p) => p.type == ParameterType.path).toList();

  List<ApiParameter> get queryParameters =>
      parameters.where((p) => p.type == ParameterType.query).toList();

  List<ApiParameter> get headerParameters =>
      parameters.where((p) => p.type == ParameterType.header).toList();

  ApiParameter? get bodyParameter =>
      parameters.cast<ApiParameter?>().firstWhere(
        (p) => p?.type == ParameterType.body,
        orElse: () => null,
      );

  List<ApiParameter> get fieldParameters =>
      parameters.where((p) => p.type == ParameterType.field).toList();
}

class ApiService {
  final String name;
  final String baseUrl;
  final List<ApiEndpoint> endpoints;
  final String? description;
  final List<String> tags;
  final Map<String, String>? defaultHeaders;

  const ApiService({
    required this.name,
    required this.baseUrl,
    required this.endpoints,
    this.description,
    this.tags = const [],
    this.defaultHeaders,
  });
}

class ApiDefinition {
  final String title;
  final String? version;
  final String? description;
  final List<ApiService> services;
  final Map<String, String>? globalHeaders;

  const ApiDefinition({
    required this.title,
    this.version,
    this.description,
    required this.services,
    this.globalHeaders,
  });

  List<ApiEndpoint> get allEndpoints {
    return services.expand((service) => service.endpoints).toList();
  }

  List<String> get allTags {
    final tags = <String>{};
    for (final service in services) {
      tags.addAll(service.tags);
      for (final endpoint in service.endpoints) {
        tags.addAll(endpoint.tags);
      }
    }
    return tags.toList()..sort();
  }
}

class ApiDefinitionBuilder {
  static ApiDefinition fromRetrofitService({
    required String serviceName,
    required String baseUrl,
    required List<ApiEndpoint> endpoints,
    String? description,
    Map<String, String>? defaultHeaders,
  }) {
    final service = ApiService(
      name: serviceName,
      baseUrl: baseUrl,
      endpoints: endpoints,
      description: description,
      defaultHeaders: defaultHeaders,
    );

    return ApiDefinition(
      title: serviceName,
      services: [service],
      description: description,
    );
  }

  static ApiEndpoint endpoint({
    required String name,
    required String path,
    required HttpMethod method,
    List<ApiParameter> parameters = const [],
    String? description,
    String? summary,
    List<String> tags = const [],
    Map<String, String>? headers,
    String? responseType,
  }) {
    return ApiEndpoint(
      name: name,
      path: path,
      method: method,
      parameters: parameters,
      description: description,
      summary: summary,
      tags: tags,
      headers: headers,
      responseType: responseType,
    );
  }

  static ApiParameter pathParam(
    String name, {
    Type dataType = String,
    bool required = true,
    String? description,
  }) {
    return ApiParameter(
      name: name,
      type: ParameterType.path,
      dataType: dataType,
      required: required,
      description: description,
    );
  }

  static ApiParameter queryParam(
    String name, {
    Type dataType = String,
    bool required = false,
    String? description,
    dynamic defaultValue,
    List<String>? enumValues,
  }) {
    return ApiParameter(
      name: name,
      type: ParameterType.query,
      dataType: dataType,
      required: required,
      description: description,
      defaultValue: defaultValue,
      enumValues: enumValues,
    );
  }

  static ApiParameter headerParam(
    String name, {
    Type dataType = String,
    bool required = false,
    String? description,
    dynamic defaultValue,
  }) {
    return ApiParameter(
      name: name,
      type: ParameterType.header,
      dataType: dataType,
      required: required,
      description: description,
      defaultValue: defaultValue,
    );
  }

  static ApiParameter bodyParam({
    Type dataType = Map,
    bool required = true,
    String? description,
  }) {
    return ApiParameter(
      name: 'body',
      type: ParameterType.body,
      dataType: dataType,
      required: required,
      description: description,
    );
  }

  static ApiParameter fieldParam(
    String name, {
    Type dataType = String,
    bool required = false,
    String? description,
    dynamic defaultValue,
  }) {
    return ApiParameter(
      name: name,
      type: ParameterType.field,
      dataType: dataType,
      required: required,
      description: description,
      defaultValue: defaultValue,
    );
  }
}