/// Annotation to mark a class as an API service for the HTTP Sandbox Viewer.
/// 
/// This annotation should be used on abstract classes that define API endpoints
/// similar to Retrofit services. The annotated class will be used to generate
/// API definitions for the sandbox viewer.
/// 
/// Example:
/// ```dart
/// @ApiService(
///   baseUrl: 'https://api.example.com',
///   title: 'User API',
///   description: 'API for managing users',
/// )
/// abstract class UserApi {
///   @GET('/users')
///   Future<List<User>> getUsers();
/// }
/// ```
class ApiService {
  /// The base URL for this API service
  final String baseUrl;
  
  /// The title/name of the API service
  final String title;
  
  /// Optional description of the API service
  final String? description;
  
  /// Optional version of the API
  final String? version;
  
  /// Optional tags to categorize this service
  final List<String>? tags;

  const ApiService({
    required this.baseUrl,
    required this.title,
    this.description,
    this.version,
    this.tags,
  });
}

/// Annotation to provide additional metadata for API endpoints.
/// 
/// This can be used alongside Retrofit annotations to provide more
/// detailed information for the sandbox viewer.
/// 
/// Example:
/// ```dart
/// @GET('/users/{id}')
/// @Summary('Get user by ID')
/// @Tags(['users', 'read'])
/// @ResponseType('User')
/// Future<User> getUser(@Path('id') int id);
/// ```
class Summary {
  final String value;
  const Summary(this.value);
}

/// Annotation to specify tags for categorizing endpoints
class Tags {
  final List<String> values;
  const Tags(this.values);
}

/// Annotation to specify the response type for documentation
class ResponseType {
  final String type;
  const ResponseType(this.type);
}

/// Annotation to provide parameter descriptions
class ParamDescription {
  final String description;
  const ParamDescription(this.description);
}

/// Annotation to specify default values for parameters
class DefaultValue {
  final dynamic value;
  const DefaultValue(this.value);
}

/// Annotation to specify enum values for parameters
class EnumValues {
  final List<String> values;
  const EnumValues(this.values);
}