import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/http_request_record.dart';
import '../services/http_records_service.dart';

class RequestExecutionForm extends StatefulWidget {
  final HttpRequestRecord record;

  const RequestExecutionForm({super.key, required this.record});

  @override
  State<RequestExecutionForm> createState() => _RequestExecutionFormState();
}

class _RequestExecutionFormState extends State<RequestExecutionForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _bodyController = TextEditingController();
  final Map<String, TextEditingController> _headerControllers = {};
  final Map<String, TextEditingController> _queryControllers = {};
  
  String _selectedMethod = 'GET';
  bool _isRawJsonMode = false;
  bool _isExecuting = false;
  HttpResponseRecord? _executionResult;

  final List<String> _httpMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _urlController.text = widget.record.url;
    _selectedMethod = widget.record.method;
    
    // Initialize header controllers
    for (final entry in widget.record.headers.entries) {
      _headerControllers[entry.key] = TextEditingController(text: entry.value.toString());
    }
    
    // Parse URL for query parameters
    final uri = Uri.tryParse(widget.record.url);
    if (uri != null) {
      for (final entry in uri.queryParameters.entries) {
        _queryControllers[entry.key] = TextEditingController(text: entry.value);
      }
    }
    
    // Initialize body
    if (widget.record.body != null) {
      if (widget.record.body is String) {
        _bodyController.text = widget.record.body;
      } else {
        _bodyController.text = const JsonEncoder.withIndent('  ').convert(widget.record.body);
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bodyController.dispose();
    for (final controller in _headerControllers.values) {
      controller.dispose();
    }
    for (final controller in _queryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Execute Request'),
        actions: [
          IconButton(
            icon: Icon(_isRawJsonMode ? Icons.view_list : Icons.code),
            onPressed: () {
              setState(() {
                _isRawJsonMode = !_isRawJsonMode;
              });
            },
            tooltip: _isRawJsonMode ? 'Switch to Form View' : 'Switch to Raw JSON',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMethodAndUrlSection(),
                    const SizedBox(height: 16),
                    _buildQueryParametersSection(),
                    const SizedBox(height: 16),
                    _buildHeadersSection(),
                    const SizedBox(height: 16),
                    if (_shouldShowBody()) _buildBodySection(),
                    if (_executionResult != null) ...[
                      const SizedBox(height: 24),
                      _buildExecutionResult(),
                    ],
                  ],
                ),
              ),
            ),
            _buildExecuteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodAndUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'HTTP Method',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _httpMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'URL is required';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasScheme) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQueryParametersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Query Parameters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addQueryParameter,
              tooltip: 'Add Query Parameter',
            ),
          ],
        ),
        if (_queryControllers.isEmpty)
          const Text(
            'No query parameters',
            style: TextStyle(color: Colors.grey),
          )
        else
          ..._queryControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: entry.key,
                      decoration: const InputDecoration(
                        labelText: 'Key',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (newKey) {
                        if (newKey != entry.key) {
                          final controller = _queryControllers.remove(entry.key);
                          if (controller != null && newKey.isNotEmpty) {
                            _queryControllers[newKey] = controller;
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: entry.value,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _queryControllers.remove(entry.key);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHeadersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Headers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addHeader,
              tooltip: 'Add Header',
            ),
          ],
        ),
        if (_headerControllers.isEmpty)
          const Text(
            'No headers',
            style: TextStyle(color: Colors.grey),
          )
        else
          ..._headerControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: entry.key,
                      decoration: const InputDecoration(
                        labelText: 'Header Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (newKey) {
                        if (newKey != entry.key) {
                          final controller = _headerControllers.remove(entry.key);
                          if (controller != null && newKey.isNotEmpty) {
                            _headerControllers[newKey] = controller;
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: entry.value,
                      decoration: const InputDecoration(
                        labelText: 'Header Value',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _headerControllers.remove(entry.key);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request Body',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bodyController,
          decoration: InputDecoration(
            labelText: _isRawJsonMode ? 'Raw JSON' : 'Request Body',
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          validator: _isRawJsonMode ? _validateJson : null,
        ),
      ],
    );
  }

  Widget _buildExecutionResult() {
    final result = _executionResult!;
    final statusColor = _getStatusColor(result.statusCode);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Execution Result',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.statusCode.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.statusMessage,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${result.duration}ms',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (result.body != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Response Body:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    _formatResponseBody(result.body),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExecuteButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isExecuting ? null : _executeRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isExecuting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Executing...'),
                ],
              )
            : const Text(
                'Execute Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  bool _shouldShowBody() {
    return ['POST', 'PUT', 'PATCH'].contains(_selectedMethod);
  }

  void _addQueryParameter() {
    setState(() {
      final key = 'param${_queryControllers.length + 1}';
      _queryControllers[key] = TextEditingController();
    });
  }

  void _addHeader() {
    setState(() {
      final key = 'Header${_headerControllers.length + 1}';
      _headerControllers[key] = TextEditingController();
    });
  }

  String? _validateJson(String? value) {
    if (value == null || value.isEmpty) return null;
    
    try {
      jsonDecode(value);
      return null;
    } catch (e) {
      return 'Invalid JSON format';
    }
  }

  Future<void> _executeRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isExecuting = true;
      _executionResult = null;
    });

    try {
      final dio = Dio();
      final stopwatch = Stopwatch()..start();
      
      // Build URL with query parameters
      final baseUrl = _urlController.text;
      final queryParams = <String, String>{};
      for (final entry in _queryControllers.entries) {
        if (entry.key.isNotEmpty && entry.value.text.isNotEmpty) {
          queryParams[entry.key] = entry.value.text;
        }
      }
      
      // Build headers
      final headers = <String, String>{};
      for (final entry in _headerControllers.entries) {
        if (entry.key.isNotEmpty && entry.value.text.isNotEmpty) {
          headers[entry.key] = entry.value.text;
        }
      }
      
      // Build request body
      dynamic requestBody;
      if (_shouldShowBody() && _bodyController.text.isNotEmpty) {
        try {
          requestBody = jsonDecode(_bodyController.text);
        } catch (e) {
          requestBody = _bodyController.text;
        }
      }
      
      // Execute request
      final response = await dio.request(
        baseUrl,
        options: Options(
          method: _selectedMethod,
          headers: headers,
        ),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        data: requestBody,
      );
      
      stopwatch.stop();
      
      // Create response record
      final responseRecord = HttpResponseRecord(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        headers: Map<String, dynamic>.from(response.headers.map),
        body: response.data,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsedMilliseconds,
      );
      
      // Save to history
      final requestRecord = HttpRequestRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: _selectedMethod,
        url: baseUrl,
        headers: Map<String, dynamic>.from(headers),
        body: requestBody,
        timestamp: DateTime.now(),
        response: responseRecord,
      );
      
      HttpRecordsService.instance.addRequest(requestRecord);
      
      setState(() {
        _executionResult = responseRecord;
      });
      
    } catch (e) {
      DioException dioError = e as DioException;
      final responseRecord = HttpResponseRecord(
        statusCode: dioError.response?.statusCode ?? 0,
        statusMessage: dioError.message ?? 'Error',
        headers: dioError.response?.headers.map ?? {},
        body: dioError.response?.data ?? {'error': dioError.message},
        timestamp: DateTime.now(),
        duration: 0,
      );
      
      setState(() {
        _executionResult = responseRecord;
      });
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.red;
    } else if (statusCode >= 500) {
      return Colors.deepOrange;
    }
    return Colors.grey;
  }

  String _formatResponseBody(dynamic body) {
    if (body == null) return 'No response body';
    
    if (body is String) {
      try {
        final parsed = jsonDecode(body);
        return const JsonEncoder.withIndent('  ').convert(parsed);
      } catch (e) {
        return body;
      }
    } else if (body is Map || body is List) {
      return const JsonEncoder.withIndent('  ').convert(body);
    }
    
    return body.toString();
  }
}