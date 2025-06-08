import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/api_definition.dart';
import '../models/http_request_record.dart';
import '../services/http_records_service.dart';
import '../services/api_definitions_service.dart';

class ApiEndpointExecutionForm extends StatefulWidget {
  final ApiEndpoint endpoint;

  const ApiEndpointExecutionForm({super.key, required this.endpoint});

  @override
  State<ApiEndpointExecutionForm> createState() => _ApiEndpointExecutionFormState();
}

class _ApiEndpointExecutionFormState extends State<ApiEndpointExecutionForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _parameterControllers = {};
  final _bodyController = TextEditingController();
  
  bool _isRawJsonMode = false;
  bool _isExecuting = false;
  HttpResponseRecord? _executionResult;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize parameter controllers
    for (final param in widget.endpoint.parameters) {
      if (param.type != ParameterType.body) {
        _parameterControllers[param.name] = TextEditingController(
          text: param.defaultValue?.toString() ?? '',
        );
      }
    }

    // Initialize body for POST/PUT/PATCH methods
    if (widget.endpoint.bodyParameter != null) {
      _bodyController.text = _getDefaultBodyContent();
    }

    // Try to get base URL from API definitions service
    final definitions = ApiDefinitionsService.instance.definitions;
    for (final definition in definitions) {
      for (final service in definition.services) {
        if (service.endpoints.contains(widget.endpoint)) {
          _baseUrl = service.baseUrl;
          break;
        }
      }
      if (_baseUrl != null) break;
    }
    _baseUrl ??= 'https://api.example.com'; // Fallback
  }

  String _getDefaultBodyContent() {
    if (widget.endpoint.bodyParameter?.dataType == Map) {
      return const JsonEncoder.withIndent('  ').convert({
        'example': 'value',
      });
    }
    return '';
  }

  @override
  void dispose() {
    for (final controller in _parameterControllers.values) {
      controller.dispose();
    }
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.endpoint.name),
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
                    _buildEndpointInfo(),
                    const SizedBox(height: 16),
                    _buildBaseUrlSection(),
                    const SizedBox(height: 16),
                    if (widget.endpoint.pathParameters.isNotEmpty) ...[
                      _buildParametersSection('Path Parameters', widget.endpoint.pathParameters),
                      const SizedBox(height: 16),
                    ],
                    if (widget.endpoint.queryParameters.isNotEmpty) ...[
                      _buildParametersSection('Query Parameters', widget.endpoint.queryParameters),
                      const SizedBox(height: 16),
                    ],
                    if (widget.endpoint.headerParameters.isNotEmpty) ...[
                      _buildParametersSection('Header Parameters', widget.endpoint.headerParameters),
                      const SizedBox(height: 16),
                    ],
                    if (widget.endpoint.bodyParameter != null) ...[
                      _buildBodySection(),
                      const SizedBox(height: 16),
                    ],
                    if (widget.endpoint.fieldParameters.isNotEmpty) ...[
                      _buildParametersSection('Form Fields', widget.endpoint.fieldParameters),
                      const SizedBox(height: 16),
                    ],
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

  Widget _buildEndpointInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMethodColor(widget.endpoint.method),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.endpoint.methodString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.endpoint.path,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.endpoint.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.endpoint.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (widget.endpoint.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: widget.endpoint.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBaseUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Base URL',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _baseUrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'https://api.example.com',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Base URL is required';
            }
            final uri = Uri.tryParse(value);
            if (uri == null || !uri.hasScheme) {
              return 'Please enter a valid URL';
            }
            return null;
          },
          onChanged: (value) {
            _baseUrl = value;
          },
        ),
      ],
    );
  }

  Widget _buildParametersSection(String title, List<ApiParameter> parameters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...parameters.map((param) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildParameterField(param),
        )),
      ],
    );
  }

  Widget _buildParameterField(ApiParameter param) {
    final controller = _parameterControllers[param.name]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              param.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '(${param.typeString})',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (param.required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        if (param.description != null) ...[
          const SizedBox(height: 4),
          Text(
            param.description!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (param.enumValues != null && param.enumValues!.isNotEmpty)
          DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty && param.enumValues!.contains(controller.text)
                ? controller.text
                : null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: param.enumValues!.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              controller.text = value ?? '';
            },
            validator: param.required
                ? (value) => value == null || value.isEmpty ? 'This field is required' : null
                : null,
          )
        else
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: param.defaultValue?.toString(),
            ),
            keyboardType: _getKeyboardType(param.dataType),
            validator: param.required
                ? (value) => value == null || value.isEmpty ? 'This field is required' : null
                : null,
          ),
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

  TextInputType _getKeyboardType(Type dataType) {
    if (dataType == int) {
      return TextInputType.number;
    } else if (dataType == double) {
      return const TextInputType.numberWithOptions(decimal: true);
    }
    return TextInputType.text;
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
      
      // Build URL
      String url = _buildUrl();
      
      // Build headers
      final headers = _buildHeaders();
      
      // Build query parameters
      final queryParams = _buildQueryParameters();
      
      // Build request body
      dynamic requestBody = _buildRequestBody();
      
      // Execute request
      final response = await dio.request(
        url,
        options: Options(
          method: widget.endpoint.methodString,
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
        method: widget.endpoint.methodString,
        url: url,
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
      
      // Save error requests to history as well
      final requestRecord = HttpRequestRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: widget.endpoint.methodString,
        url: _buildUrl(),
        headers: Map<String, dynamic>.from(_buildHeaders()),
        body: _buildRequestBody(),
        timestamp: DateTime.now(),
        response: responseRecord,
      );
      
      HttpRecordsService.instance.addRequest(requestRecord);
      
      setState(() {
        _executionResult = responseRecord;
      });
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  String _buildUrl() {
    String url = _baseUrl! + widget.endpoint.path;
    
    // Replace path parameters
    for (final param in widget.endpoint.pathParameters) {
      final value = _parameterControllers[param.name]?.text ?? '';
      url = url.replaceAll('{${param.name}}', value);
    }
    
    return url;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{};
    
    for (final param in widget.endpoint.headerParameters) {
      final value = _parameterControllers[param.name]?.text ?? '';
      if (value.isNotEmpty) {
        headers[param.name] = value;
      }
    }
    
    return headers;
  }

  Map<String, String> _buildQueryParameters() {
    final queryParams = <String, String>{};
    
    for (final param in widget.endpoint.queryParameters) {
      final value = _parameterControllers[param.name]?.text ?? '';
      if (value.isNotEmpty) {
        queryParams[param.name] = value;
      }
    }
    
    return queryParams;
  }

  dynamic _buildRequestBody() {
    if (widget.endpoint.bodyParameter == null || _bodyController.text.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(_bodyController.text);
    } catch (e) {
      return _bodyController.text;
    }
  }

  Color _getMethodColor(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return Colors.green;
      case HttpMethod.post:
        return Colors.blue;
      case HttpMethod.put:
        return Colors.orange;
      case HttpMethod.delete:
        return Colors.red;
      case HttpMethod.patch:
        return Colors.purple;
      case HttpMethod.head:
        return Colors.teal;
      case HttpMethod.options:
        return Colors.grey;
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