import 'package:dio/dio.dart';
import '../models/http_request_record.dart';
import '../services/http_records_service.dart';

/// A Dio interceptor that captures and logs HTTP requests and responses.
/// 
/// This interceptor automatically records all HTTP traffic passing through
/// the Dio instance it's attached to, making it available for debugging
/// and inspection in the HTTP Sandbox Dashboard.
/// 
/// ## Usage
/// 
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(HttpSandboxInterceptor());
/// ```
/// 
/// The interceptor will:
/// - Capture request details (method, URL, headers, body)
/// - Record response data (status code, headers, body)
/// - Track request timing and duration
/// - Handle both successful responses and errors
/// 
/// All captured data is stored in [HttpRecordsService] and can be viewed
/// using the [HttpSandboxDashboard] widget.
class HttpSandboxInterceptor extends Interceptor {
  final HttpRecordsService _recordsService = HttpRecordsService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Generate unique ID for this request
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final record = HttpRequestRecord(
      id: requestId,
      method: options.method,
      url: options.uri.toString(),
      headers: Map<String, dynamic>.from(options.headers),
      body: options.data,
      timestamp: DateTime.now(),
    );

    // Store the request ID in options.extra so we can retrieve it in response/error handlers
    options.extra['sandboxRequestId'] = requestId;
    
    _recordsService.addRequest(record);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Retrieve the request ID from the original request
    final requestId = response.requestOptions.extra['sandboxRequestId'] as String?;
    
    if (requestId != null) {
      // Calculate request duration
      final requestTimestamp = _recordsService.records
          .firstWhere((r) => r.id == requestId, orElse: () => HttpRequestRecord(
            id: '',
            method: '',
            url: '',
            headers: {},
            timestamp: DateTime.now(),
          ))
          .timestamp;
      
      final duration = DateTime.now().difference(requestTimestamp).inMilliseconds;
      
      final responseRecord = HttpResponseRecord(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        headers: Map<String, dynamic>.from(response.headers.map),
        body: response.data,
        timestamp: DateTime.now(),
        duration: duration,
      );

      _recordsService.updateRequestWithResponse(requestId, responseRecord);
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Retrieve the request ID from the original request
    final requestId = err.requestOptions.extra['sandboxRequestId'] as String?;
    
    if (requestId != null) {
      // Calculate request duration
      final requestTimestamp = _recordsService.records
          .firstWhere((r) => r.id == requestId, orElse: () => HttpRequestRecord(
            id: '',
            method: '',
            url: '',
            headers: {},
            timestamp: DateTime.now(),
          ))
          .timestamp;
      
      final duration = DateTime.now().difference(requestTimestamp).inMilliseconds;
      
      final responseRecord = HttpResponseRecord(
        statusCode: err.response?.statusCode ?? 0,
        statusMessage: err.message ?? 'Error',
        headers: err.response?.headers.map ?? {},
        body: err.response?.data ?? {'error': err.message},
        timestamp: DateTime.now(),
        duration: duration,
      );

      _recordsService.updateRequestWithResponse(requestId, responseRecord);
    }
    
    handler.next(err);
  }
}