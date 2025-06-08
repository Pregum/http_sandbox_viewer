class HttpRequestRecord {
  final String id;
  final String method;
  final String url;
  final Map<String, dynamic> headers;
  final dynamic body;
  final DateTime timestamp;
  final HttpResponseRecord? response;

  const HttpRequestRecord({
    required this.id,
    required this.method,
    required this.url,
    required this.headers,
    this.body,
    required this.timestamp,
    this.response,
  });

  HttpRequestRecord copyWith({
    String? id,
    String? method,
    String? url,
    Map<String, dynamic>? headers,
    dynamic body,
    DateTime? timestamp,
    HttpResponseRecord? response,
  }) {
    return HttpRequestRecord(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      response: response ?? this.response,
    );
  }
}

class HttpResponseRecord {
  final int statusCode;
  final String statusMessage;
  final Map<String, dynamic> headers;
  final dynamic body;
  final DateTime timestamp;
  final int duration;

  const HttpResponseRecord({
    required this.statusCode,
    required this.statusMessage,
    required this.headers,
    this.body,
    required this.timestamp,
    required this.duration,
  });
}