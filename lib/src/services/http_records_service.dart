import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_request_record.dart';

class HttpRecordsService extends ChangeNotifier {
  static final HttpRecordsService _instance = HttpRecordsService._internal();
  static HttpRecordsService get instance => _instance;
  HttpRecordsService._internal();

  static const String _storageKey = 'http_sandbox_records';
  final List<HttpRequestRecord> _records = [];

  List<HttpRequestRecord> get records => List.unmodifiable(_records);

  void addRequest(HttpRequestRecord record) {
    _records.insert(0, record);
    _saveToStorage();
    notifyListeners(); // Notify UI to update
  }

  void updateRequestWithResponse(String requestId, HttpResponseRecord response) {
    final index = _records.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _records[index] = _records[index].copyWith(response: response);
      _saveToStorage();
      notifyListeners(); // Notify UI to update
    }
  }

  void clearRecords() {
    _records.clear();
    _saveToStorage();
    notifyListeners(); // Notify UI to update
  }

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_storageKey);
      if (recordsJson != null) {
        final recordsList = jsonDecode(recordsJson) as List;
        _records.clear();
        for (final recordMap in recordsList) {
          _records.add(_recordFromMap(recordMap));
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = jsonEncode(_records.map((r) => _recordToMap(r)).toList());
      await prefs.setString(_storageKey, recordsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Map<String, dynamic> _recordToMap(HttpRequestRecord record) {
    return {
      'id': record.id,
      'method': record.method,
      'url': record.url,
      'headers': record.headers,
      'body': record.body,
      'timestamp': record.timestamp.millisecondsSinceEpoch,
      'response': record.response != null ? {
        'statusCode': record.response!.statusCode,
        'statusMessage': record.response!.statusMessage,
        'headers': record.response!.headers,
        'body': record.response!.body,
        'timestamp': record.response!.timestamp.millisecondsSinceEpoch,
        'duration': record.response!.duration,
      } : null,
    };
  }

  HttpRequestRecord _recordFromMap(Map<String, dynamic> map) {
    return HttpRequestRecord(
      id: map['id'],
      method: map['method'],
      url: map['url'],
      headers: Map<String, dynamic>.from(map['headers']),
      body: map['body'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      response: map['response'] != null ? HttpResponseRecord(
        statusCode: map['response']['statusCode'],
        statusMessage: map['response']['statusMessage'],
        headers: Map<String, dynamic>.from(map['response']['headers']),
        body: map['response']['body'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['response']['timestamp']),
        duration: map['response']['duration'],
      ) : null,
    );
  }
}