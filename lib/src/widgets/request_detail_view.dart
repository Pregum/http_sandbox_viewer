import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/http_request_record.dart';
import 'request_execution_form.dart';

class RequestDetailView extends StatefulWidget {
  final HttpRequestRecord record;

  const RequestDetailView({super.key, required this.record});

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.record.method} Request'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _openExecutionForm,
            tooltip: 'Execute Request',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyRequestAsCurl,
            tooltip: 'Copy as cURL',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Request'),
            Tab(text: 'Response'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestTab(),
          _buildResponseTab(),
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('URL', widget.record.url),
          const SizedBox(height: 16),
          _buildSection('Method', widget.record.method),
          const SizedBox(height: 16),
          _buildSection('Timestamp', widget.record.timestamp.toString()),
          const SizedBox(height: 16),
          _buildHeadersSection('Headers', widget.record.headers),
          if (widget.record.body != null) ...[
            const SizedBox(height: 16),
            _buildBodySection('Request Body', widget.record.body),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseTab() {
    if (widget.record.response == null) {
      return const Center(
        child: Text(
          'No response recorded',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final response = widget.record.response!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Status Code', '${response.statusCode} ${response.statusMessage}'),
          const SizedBox(height: 16),
          _buildSection('Timestamp', response.timestamp.toString()),
          const SizedBox(height: 16),
          _buildSection('Duration', '${response.duration}ms'),
          const SizedBox(height: 16),
          _buildHeadersSection('Headers', response.headers),
          if (response.body != null) ...[
            const SizedBox(height: 16),
            _buildBodySection('Response Body', response.body),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadersSection(String title, Map<String, dynamic> headers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: headers.isEmpty
              ? const Text(
                  'No headers',
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: headers.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SelectableText(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildBodySection(String title, dynamic body) {
    String bodyText;
    
    if (body is String) {
      bodyText = body;
    } else if (body is Map || body is List) {
      try {
        bodyText = const JsonEncoder.withIndent('  ').convert(body);
      } catch (e) {
        bodyText = body.toString();
      }
    } else {
      bodyText = body?.toString() ?? '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            bodyText.isEmpty ? 'No body' : bodyText,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: bodyText.isEmpty ? Colors.grey : null,
            ),
          ),
        ),
      ],
    );
  }

  void _openExecutionForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestExecutionForm(record: widget.record),
      ),
    );
  }

  void _copyRequestAsCurl() {
    final buffer = StringBuffer();
    buffer.write("curl -X ${widget.record.method} '${widget.record.url}'");
    
    for (final entry in widget.record.headers.entries) {
      buffer.write(" \\\n  -H '${entry.key}: ${entry.value}'");
    }
    
    if (widget.record.body != null) {
      String bodyStr;
      if (widget.record.body is String) {
        bodyStr = widget.record.body;
      } else {
        bodyStr = jsonEncode(widget.record.body);
      }
      buffer.write(" \\\n  -d '$bodyStr'");
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('cURL command copied to clipboard')),
    );
  }
}