import 'package:dio/dio.dart';
import '../models/http_request_record.dart';
import '../services/http_records_service.dart';

class HttpSandboxInterceptor extends Interceptor {
  final HttpRecordsService _recordsService = HttpRecordsService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final record = HttpRequestRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: options.method,
      url: options.uri.toString(),
      headers: Map<String, dynamic>.from(options.headers),
      body: options.data,
      timestamp: DateTime.now(),
    );

    _recordsService.addRequest(record);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final responseRecord = HttpResponseRecord(
      statusCode: response.statusCode ?? 0,
      statusMessage: response.statusMessage ?? '',
      headers: Map<String, dynamic>.from(response.headers.map),
      body: response.data,
      timestamp: DateTime.now(),
      duration: 0,
    );

    _recordsService.updateRequestWithResponse(requestId, responseRecord);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final responseRecord = HttpResponseRecord(
      statusCode: err.response?.statusCode ?? 0,
      statusMessage: err.message ?? 'Error',
      headers: err.response?.headers.map ?? {},
      body: err.response?.data,
      timestamp: DateTime.now(),
      duration: 0,
    );

    _recordsService.updateRequestWithResponse(requestId, responseRecord);
    handler.next(err);
  }
}