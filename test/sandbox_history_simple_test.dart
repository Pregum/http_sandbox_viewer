import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_sandbox_viewer/src/models/http_request_record.dart';
import 'package:http_sandbox_viewer/src/services/http_records_service.dart';

void main() {
  group('HttpRecordsService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      HttpRecordsService.instance.clearRecords();
    });

    tearDown(() {
      HttpRecordsService.instance.clearRecords();
    });

    test('should add request to history', () {
      final service = HttpRecordsService.instance;
      
      // Verify initial state is empty
      expect(service.records, isEmpty);
      
      // Create and add a request
      final request = HttpRequestRecord(
        id: 'test-123',
        method: 'GET',
        url: 'https://api.example.com/test',
        headers: {'Content-Type': 'application/json'},
        timestamp: DateTime.now(),
      );
      
      service.addRequest(request);
      
      // Verify request was added
      expect(service.records.length, 1);
      expect(service.records.first.id, 'test-123');
      expect(service.records.first.method, 'GET');
      expect(service.records.first.url, 'https://api.example.com/test');
    });

    test('should add multiple requests to history', () {
      final service = HttpRecordsService.instance;
      
      // Add first request
      final request1 = HttpRequestRecord(
        id: 'test-1',
        method: 'GET',
        url: 'https://api.example.com/users',
        headers: {},
        timestamp: DateTime.now(),
      );
      service.addRequest(request1);
      
      // Add second request
      final request2 = HttpRequestRecord(
        id: 'test-2',
        method: 'POST',
        url: 'https://api.example.com/posts',
        headers: {},
        timestamp: DateTime.now(),
      );
      service.addRequest(request2);
      
      // Verify both requests were added
      expect(service.records.length, 2);
      
      final urls = service.records.map((r) => r.url).toList();
      expect(urls, contains('https://api.example.com/users'));
      expect(urls, contains('https://api.example.com/posts'));
    });

    test('should clear all records', () {
      final service = HttpRecordsService.instance;
      
      // Add some requests
      service.addRequest(HttpRequestRecord(
        id: '1',
        method: 'GET',
        url: 'https://test.com',
        headers: {},
        timestamp: DateTime.now(),
      ));
      
      expect(service.records.length, 1);
      
      // Clear records
      service.clearRecords();
      
      // Verify records were cleared
      expect(service.records, isEmpty);
    });

    test('should preserve request order (most recent first)', () {
      final service = HttpRecordsService.instance;
      
      final now = DateTime.now();
      
      // Add first request (older)
      service.addRequest(HttpRequestRecord(
        id: 'older',
        method: 'GET',
        url: 'https://first.com',
        headers: {},
        timestamp: now.subtract(const Duration(minutes: 5)),
      ));
      
      // Add second request (newer)
      service.addRequest(HttpRequestRecord(
        id: 'newer',
        method: 'GET',
        url: 'https://second.com',
        headers: {},
        timestamp: now,
      ));
      
      // Verify most recent is first
      expect(service.records.length, 2);
      expect(service.records.first.id, 'newer');
      expect(service.records.last.id, 'older');
    });
  });
}