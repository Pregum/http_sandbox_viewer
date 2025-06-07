import 'package:flutter/material.dart';
import '../models/api_definition.dart';
import '../services/api_definitions_service.dart';
import 'api_endpoint_execution_form.dart';

class ApiDefinitionsDashboard extends StatefulWidget {
  final List<ApiDefinition>? initialDefinitions;

  const ApiDefinitionsDashboard({
    super.key,
    this.initialDefinitions,
  });

  @override
  State<ApiDefinitionsDashboard> createState() => _ApiDefinitionsDashboardState();
}

class _ApiDefinitionsDashboardState extends State<ApiDefinitionsDashboard> {
  final ApiDefinitionsService _service = ApiDefinitionsService.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadDefinitions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDefinitions() async {
    await _service.loadFromStorage();
    
    // Add initial definitions if provided
    if (widget.initialDefinitions != null) {
      for (final definition in widget.initialDefinitions!) {
        _service.addDefinition(definition);
      }
    }
    
    // Load sample definitions if none exist
    if (_service.definitions.isEmpty) {
      _service.loadSampleDefinitions();
    }
    
    setState(() {});
  }

  List<ApiEndpoint> get _filteredEndpoints {
    List<ApiEndpoint> endpoints = _service.getAllEndpoints();

    if (_searchQuery.isNotEmpty) {
      endpoints = _service.searchEndpoints(_searchQuery);
    }

    if (_selectedTag != null) {
      endpoints = endpoints
          .where((endpoint) => endpoint.tags.contains(_selectedTag))
          .toList();
    }

    return endpoints;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: _buildEndpointsList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    final allTags = _service.definitions
        .expand((def) => def.allTags)
        .toSet()
        .toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search endpoints...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          if (allTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allTags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedTag == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTag = null;
                          });
                        },
                      ),
                    );
                  }

                  final tag = allTags[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: _selectedTag == tag,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = selected ? tag : null;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEndpointsList() {
    final endpoints = _filteredEndpoints;

    if (endpoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.api,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedTag != null
                  ? 'No endpoints found matching your criteria'
                  : 'No API definitions available.\nAdd some definitions to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isEmpty && _selectedTag == null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _service.loadSampleDefinitions();
                  setState(() {});
                },
                child: const Text('Load Sample APIs'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: endpoints.length,
      itemBuilder: (context, index) {
        final endpoint = endpoints[index];
        return _buildEndpointCard(endpoint);
      },
    );
  }

  Widget _buildEndpointCard(ApiEndpoint endpoint) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMethodColor(endpoint.method),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            endpoint.methodString,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          endpoint.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              endpoint.path,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            if (endpoint.description != null) ...[
              const SizedBox(height: 4),
              Text(
                endpoint.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (endpoint.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: endpoint.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green),
          onPressed: () => _executeEndpoint(endpoint),
          tooltip: 'Execute API',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (endpoint.summary != null) ...[
                  _buildDetailSection('Summary', endpoint.summary!),
                  const SizedBox(height: 12),
                ],
                if (endpoint.pathParameters.isNotEmpty) ...[
                  _buildParametersSection('Path Parameters', endpoint.pathParameters),
                  const SizedBox(height: 12),
                ],
                if (endpoint.queryParameters.isNotEmpty) ...[
                  _buildParametersSection('Query Parameters', endpoint.queryParameters),
                  const SizedBox(height: 12),
                ],
                if (endpoint.headerParameters.isNotEmpty) ...[
                  _buildParametersSection('Header Parameters', endpoint.headerParameters),
                  const SizedBox(height: 12),
                ],
                if (endpoint.bodyParameter != null) ...[
                  _buildParametersSection('Request Body', [endpoint.bodyParameter!]),
                  const SizedBox(height: 12),
                ],
                if (endpoint.fieldParameters.isNotEmpty) ...[
                  _buildParametersSection('Form Fields', endpoint.fieldParameters),
                  const SizedBox(height: 12),
                ],
                if (endpoint.responseType != null) ...[
                  _buildDetailSection('Response Type', endpoint.responseType!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...parameters.map((param) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: param.required ? Colors.red[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  param.required ? 'required' : 'optional',
                  style: TextStyle(
                    fontSize: 10,
                    color: param.required ? Colors.red[800] : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          param.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${param.typeString})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    if (param.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        param.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (param.defaultValue != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Default: ${param.defaultValue}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (param.enumValues != null && param.enumValues!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Options: ${param.enumValues!.join(', ')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
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

  void _executeEndpoint(ApiEndpoint endpoint) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApiEndpointExecutionForm(endpoint: endpoint),
      ),
    );
  }
}