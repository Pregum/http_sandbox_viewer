import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_sandbox_viewer/src/interceptors/http_sandbox_interceptor.dart';
import 'package:http_sandbox_viewer/src/services/http_records_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HttpSandboxInterceptor', () {
    late HttpSandboxInterceptor interceptor;
    late HttpRecordsService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = HttpRecordsService.instance;
      service.clearRecords();
      interceptor = HttpSandboxInterceptor();
    });

    test('should save request with unique ID', () {
      final options = RequestOptions(
        path: '/test',
        method: 'GET',
        baseUrl: 'https://api.example.com',
      );

      interceptor.onRequest(options, MockRequestHandler());

      expect(service.records.length, equals(1));
      expect(service.records.first.id, isNotEmpty);
      expect(service.records.first.method, equals('GET'));
      expect(service.records.first.url, equals('https://api.example.com/test'));
      expect(options.extra['sandboxRequestId'], isNotEmpty);
      expect(options.extra['sandboxRequestId'], equals(service.records.first.id));
    });

    test('should update request with response data', () async {
      // First, create a request
      final options = RequestOptions(
        path: '/test',
        method: 'GET',
        baseUrl: 'https://api.example.com',
      );

      interceptor.onRequest(options, MockRequestHandler());
      expect(options.extra['sandboxRequestId'], isNotNull);

      // Then, handle the response
      final response = Response(
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
        data: {'result': 'success'},
      );

      // Wait a bit to ensure different timestamp
      await Future.delayed(const Duration(milliseconds: 10));

      interceptor.onResponse(response, MockResponseHandler());

      expect(service.records.length, equals(1));
      expect(service.records.first.response, isNotNull);
      expect(service.records.first.response!.statusCode, equals(200));
      expect(service.records.first.response!.statusMessage, equals('OK'));
      expect(service.records.first.response!.body, equals({'result': 'success'}));
      expect(service.records.first.response!.duration, greaterThan(0));
    });

    test('should update request with error response', () async {
      // First, create a request
      final options = RequestOptions(
        path: '/test',
        method: 'POST',
        baseUrl: 'https://api.example.com',
      );

      interceptor.onRequest(options, MockRequestHandler());

      // Then, handle the error
      final errorResponse = Response(
        requestOptions: options,
        statusCode: 404,
        statusMessage: 'Not Found',
        data: {'error': 'Resource not found'},
      );

      final error = DioException(
        requestOptions: options,
        response: errorResponse,
        message: 'Not Found',
        type: DioExceptionType.badResponse,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      interceptor.onError(error, MockErrorHandler());

      expect(service.records.length, equals(1));
      expect(service.records.first.response, isNotNull);
      expect(service.records.first.response!.statusCode, equals(404));
      expect(service.records.first.response!.body, equals({'error': 'Resource not found'}));
    });

    test('should handle error without response', () async {
      // First, create a request
      final options = RequestOptions(
        path: '/test',
        method: 'GET',
        baseUrl: 'https://api.example.com',
      );

      interceptor.onRequest(options, MockRequestHandler());

      // Then, handle connection error
      final error = DioException(
        requestOptions: options,
        message: 'Connection timeout',
        type: DioExceptionType.connectionTimeout,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      interceptor.onError(error, MockErrorHandler());

      expect(service.records.length, equals(1));
      expect(service.records.first.response, isNotNull);
      expect(service.records.first.response!.statusCode, equals(0));
      expect(service.records.first.response!.body, equals({'error': 'Connection timeout'}));
    });

    test('should handle multiple concurrent requests', () async {
      // Create multiple requests
      final requests = List.generate(5, (i) => RequestOptions(
        path: '/test$i',
        method: 'GET',
        baseUrl: 'https://api.example.com',
      ));

      // Send all requests
      for (final options in requests) {
        interceptor.onRequest(options, MockRequestHandler());
      }

      expect(service.records.length, equals(5));

      // Handle responses
      for (int i = 0; i < requests.length; i++) {
        final response = Response(
          requestOptions: requests[i],
          statusCode: 200,
          data: {'index': i},
        );
        
        await Future.delayed(const Duration(milliseconds: 5));
        interceptor.onResponse(response, MockResponseHandler());
      }

      // All requests should have responses
      final recordsWithResponse = service.records.where((r) => r.response != null).toList();
      expect(recordsWithResponse.length, equals(5));
      
      // Check that we have all 5 different requests
      final urls = service.records.map((r) => r.url).toSet();
      expect(urls.length, equals(5));
      
      // Each URL should be unique
      for (int i = 0; i < 5; i++) {
        expect(urls.any((url) => url.endsWith('/test$i')), isTrue);
      }
    });
  });
}

// Mock handlers for testing
class MockRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions options) {
    // Do nothing in test
  }

  @override
  void reject(DioException error, [bool callFollowingErrorInterceptor = false]) {
    // Do nothing in test
  }

  @override
  void resolve(Response response, [bool callFollowingResponseInterceptor = false]) {
    // Do nothing in test
  }
}

class MockResponseHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {
    // Do nothing in test
  }

  @override
  void reject(DioException error, [bool callFollowingErrorInterceptor = false]) {
    // Do nothing in test
  }

  @override
  void resolve(Response response) {
    // Do nothing in test
  }
}

class MockErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {
    // Do nothing in test
  }

  @override
  void reject(DioException error) {
    // Do nothing in test
  }

  @override
  void resolve(Response response) {
    // Do nothing in test
  }
}