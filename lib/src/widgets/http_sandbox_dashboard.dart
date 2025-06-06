import 'package:flutter/material.dart';
import '../models/http_request_record.dart';
import '../services/http_records_service.dart';
import 'request_detail_view.dart';

class HttpSandboxDashboard extends StatefulWidget {
  const HttpSandboxDashboard({super.key});

  @override
  State<HttpSandboxDashboard> createState() => _HttpSandboxDashboardState();
}

class _HttpSandboxDashboardState extends State<HttpSandboxDashboard> {
  final HttpRecordsService _recordsService = HttpRecordsService.instance;

  @override
  void initState() {
    super.initState();
    _recordsService.loadFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Sandbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _recordsService.clearRecords();
              });
            },
            tooltip: 'Clear all records',
          ),
        ],
      ),
      body: _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    final records = _recordsService.records;
    
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No HTTP requests recorded yet.\nMake some API calls to see them here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRequestCard(record);
      },
    );
  }

  Widget _buildRequestCard(HttpRequestRecord record) {
    final statusColor = _getStatusColor(record.response?.statusCode);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMethodColor(record.method),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            record.method,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          record.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTimestamp(record.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            if (record.response != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      record.response!.statusCode.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.response!.statusMessage,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RequestDetailView(record: record),
            ),
          );
        },
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(int? statusCode) {
    if (statusCode == null) return Colors.grey;
    
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}