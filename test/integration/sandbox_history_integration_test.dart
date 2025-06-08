import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';
import 'package:http_sandbox_viewer/src/models/http_request_record.dart';
import 'package:http_sandbox_viewer/src/services/http_records_service.dart';
import 'package:http_sandbox_viewer/src/widgets/api_endpoint_execution_form.dart';
import 'package:http_sandbox_viewer/src/widgets/request_execution_form.dart';

void main() {
  group('Sandbox History Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      HttpRecordsService.instance.clearRecords();
    });

    tearDown(() {
      HttpRecordsService.instance.clearRecords();
    });

    testWidgets('API endpoint execution adds request to history', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test Endpoint',
        path: '/test',
        method: HttpMethod.get,
        description: 'Test endpoint for history verification',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial history is empty
      expect(HttpRecordsService.instance.records, isEmpty);

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org'
      );

      // Execute request - this should add to history
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      // Wait a bit for the request to be processed
      await tester.pump(const Duration(milliseconds: 100));

      // Verify request was added to history
      expect(HttpRecordsService.instance.records, isNotEmpty,
          reason: 'Request should be added to history after execution');
      
      final addedRequest = HttpRecordsService.instance.records.first;
      expect(addedRequest.method, 'GET');
      expect(addedRequest.url, 'https://httpbin.org/test');
    });

    testWidgets('API endpoint execution with path parameters adds to history', (tester) async {
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
            description: 'User ID',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial history is empty
      expect(HttpRecordsService.instance.records, isEmpty);

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org'
      );

      // Fill in path parameter
      final idFields = find.byType(TextFormField);
      await tester.enterText(idFields.last, '123');

      // Execute request
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify request was added to history with correct URL
      expect(HttpRecordsService.instance.records, isNotEmpty);
      final addedRequest = HttpRecordsService.instance.records.first;
      expect(addedRequest.url, 'https://httpbin.org/users/123');
    });

    testWidgets('POST request with body adds to history', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Create User',
        path: '/users',
        method: HttpMethod.post,
        parameters: [
          ApiParameter(
            name: 'body',
            type: ParameterType.body,
            dataType: Map,
            required: true,
            description: 'User data',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in base URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org'
      );

      // Fill in request body
      final bodyField = find.byType(TextFormField).last;
      await tester.enterText(bodyField, '{"name": "John", "email": "john@example.com"}');

      // Execute request
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify request was added to history
      expect(HttpRecordsService.instance.records, isNotEmpty);
      final addedRequest = HttpRecordsService.instance.records.first;
      expect(addedRequest.method, 'POST');
      expect(addedRequest.url, 'https://httpbin.org/users');
      expect(addedRequest.body, isNotNull);
    });

    testWidgets('Request execution form adds to history', (tester) async {
      final testRecord = HttpRequestRecord(
        id: 'test-id',
        method: 'GET',
        url: 'https://httpbin.org/get',
        headers: {},
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RequestExecutionForm(record: testRecord),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial history is empty
      expect(HttpRecordsService.instance.records, isEmpty);

      // Fill in URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org/get'
      );

      // Execute request
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify request was added to history
      expect(HttpRecordsService.instance.records, isNotEmpty);
      final addedRequest = HttpRecordsService.instance.records.first;
      expect(addedRequest.method, 'GET');
      expect(addedRequest.url, 'https://httpbin.org/get');
    });

    testWidgets('Multiple requests accumulate in history', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Test Endpoint',
        path: '/test',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Execute first request
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://httpbin.org'
      );
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(HttpRecordsService.instance.records.length, 1);

      // Execute second request with different URL
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://jsonplaceholder.typicode.com'
      );
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have 2 requests in history
      expect(HttpRecordsService.instance.records.length, 2);
      
      // Verify both URLs are recorded
      final urls = HttpRecordsService.instance.records.map((r) => r.url).toList();
      expect(urls, contains('https://httpbin.org/test'));
      expect(urls, contains('https://jsonplaceholder.typicode.com/test'));
    });

    testWidgets('Error requests are also added to history', (tester) async {
      final endpoint = ApiEndpoint(
        name: 'Invalid Endpoint',
        path: '/invalid',
        method: HttpMethod.get,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ApiEndpointExecutionForm(endpoint: endpoint),
        ),
      );
      await tester.pumpAndSettle();

      // Use an invalid URL that will cause an error
      await tester.enterText(
        find.byType(TextFormField).first,
        'https://invalid-domain-that-does-not-exist-12345.com'
      );

      // Execute request (should fail)
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();
      
      // Wait longer for network timeout/error
      await tester.pump(const Duration(seconds: 5));

      // Even failed requests should be added to history
      expect(HttpRecordsService.instance.records, isNotEmpty,
          reason: 'Failed requests should also be recorded in history');
      
      final addedRequest = HttpRecordsService.instance.records.first;
      expect(addedRequest.url, contains('invalid-domain'));
      expect(addedRequest.response, isNotNull);
    });

    test('HttpRecordsService correctly stores and retrieves requests', () {
      final service = HttpRecordsService.instance;
      service.clearRecords();

      // Create a test request
      final testRequest = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://test.com/api',
        headers: {'Content-Type': 'application/json'},
        timestamp: DateTime.now(),
      );

      // Add request to service
      service.addRequest(testRequest);

      // Verify it was stored
      expect(service.records.length, 1);
      expect(service.records.first.id, '123');
      expect(service.records.first.url, 'https://test.com/api');
    });
  });
}