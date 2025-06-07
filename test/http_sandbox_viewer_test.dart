import 'package:flutter_test/flutter_test.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

void main() {
  group('HttpRequestRecord', () {
    test('creates a valid HttpRequestRecord', () {
      final record = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://api.example.com/test',
        headers: {'Content-Type': 'application/json'},
        timestamp: DateTime.now(),
      );

      expect(record.id, '123');
      expect(record.method, 'GET');
      expect(record.url, 'https://api.example.com/test');
      expect(record.headers['Content-Type'], 'application/json');
      expect(record.response, isNull);
    });

    test('copyWith creates a new record with updated values', () {
      final originalRecord = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://api.example.com/test',
        headers: {},
        timestamp: DateTime.now(),
      );

      final updatedRecord = originalRecord.copyWith(method: 'POST');

      expect(updatedRecord.id, originalRecord.id);
      expect(updatedRecord.method, 'POST');
      expect(updatedRecord.url, originalRecord.url);
    });
  });

  group('HttpResponseRecord', () {
    test('creates a valid HttpResponseRecord', () {
      final response = HttpResponseRecord(
        statusCode: 200,
        statusMessage: 'OK',
        headers: {'Content-Type': 'application/json'},
        body: {'success': true},
        timestamp: DateTime.now(),
        duration: 1500,
      );

      expect(response.statusCode, 200);
      expect(response.statusMessage, 'OK');
      expect(response.duration, 1500);
      expect(response.body['success'], true);
    });
  });

  group('HttpRecordsService', () {
    test('singleton instance works correctly', () {
      final service1 = HttpRecordsService.instance;
      final service2 = HttpRecordsService.instance;

      expect(service1, same(service2));
    });

    test('adds and retrieves records correctly', () {
      final service = HttpRecordsService.instance;
      service.clearRecords();

      final record = HttpRequestRecord(
        id: '123',
        method: 'GET',
        url: 'https://api.example.com/test',
        headers: {},
        timestamp: DateTime.now(),
      );

      service.addRequest(record);
      
      expect(service.records.length, 1);
      expect(service.records.first.id, '123');
    });
  });
}
