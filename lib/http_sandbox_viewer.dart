/// A Flutter package for debugging HTTP requests and responses with Swagger-like API definitions for Retrofit + Dio.
/// 
/// This package provides a comprehensive HTTP debugging solution for Flutter applications,
/// including request/response logging, API documentation, and a visual dashboard interface.
/// 
/// ## Features
/// 
/// - **HTTP Request Logging**: Intercepts and logs all HTTP requests and responses
/// - **API Definitions**: Define and document your APIs with Swagger-like definitions
/// - **Visual Dashboard**: Built-in UI to view requests, responses, and API documentation
/// - **Retrofit Integration**: Seamlessly integrates with Dio and Retrofit
/// - **OpenAPI Support**: Load API definitions from OpenAPI/Swagger specifications
/// - **Request Execution**: Execute API requests directly from the dashboard
/// 
/// ## Getting Started
/// 
/// 1. Add the interceptor to your Dio instance:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(HttpSandboxInterceptor());
/// ```
/// 
/// 2. Show the dashboard in your app:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => HttpSandboxDashboard(
///       apiDefinitions: [/* your API definitions */],
///     ),
///   ),
/// );
/// ```
/// 
/// 3. Define your APIs using the builder pattern:
/// ```dart
/// final apiDef = SimpleApiBuilder(
///   title: 'My API',
///   baseUrl: 'https://api.example.com',
/// )
///   .get('/users', name: 'Get Users')
///   .post('/users', name: 'Create User')
///   .build();
/// ```
library http_sandbox_viewer;

export 'src/models/http_request_record.dart';
export 'src/models/api_definition.dart';
export 'src/interceptors/http_sandbox_interceptor.dart';
export 'src/services/http_records_service.dart';
export 'src/services/api_definitions_service.dart';
export 'src/widgets/http_sandbox_dashboard.dart';
export 'src/widgets/request_detail_view.dart';
export 'src/widgets/request_execution_form.dart';
export 'src/widgets/api_definitions_dashboard.dart';
export 'src/widgets/api_endpoint_execution_form.dart';
export 'src/annotations/api_service.dart' hide ApiService;
export 'src/generators/retrofit_inspector.dart';
export 'src/builders/simple_api_builder.dart';
export 'src/examples/sample_api_definitions.dart';
export 'src/loaders/openapi_loader.dart';
