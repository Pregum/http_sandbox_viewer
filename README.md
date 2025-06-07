# HTTP Sandbox Viewer

A Flutter package for debugging HTTP requests and responses with Swagger-like API definitions for Retrofit + Dio. Inspect, analyze, and re-execute HTTP requests with a beautiful dashboard interface.

> Inspired by [drift_db_viewer](https://pub.dev/packages/drift_db_viewer)

## ✨ Features

- 🔍 **Request/Response Inspection**: View detailed information about HTTP requests and responses
- 📊 **Visual Dashboard**: Clean, intuitive UI for browsing HTTP history with tab navigation
- 🚀 **Swagger-like API Definitions**: Pre-define API endpoints for testing and exploration
- 🔄 **Request Re-execution**: Re-send recorded requests and execute pre-defined APIs
- 📝 **Parameter Forms**: Dynamic forms for path, query, header, and body parameters
- 📋 **Export to cURL**: Copy requests as cURL commands for CLI usage
- 💾 **Persistent Storage**: HTTP history is saved across app sessions
- 🎨 **Status Code Highlighting**: Color-coded status indicators and method badges
- ⏱️ **Timestamp Tracking**: See when requests were made with relative time
- 🏗️ **Simple API Builder**: Create API definitions with 70% less code
- 📚 **Pre-built Samples**: Ready-to-use API definitions for popular services
- 📄 **OpenAPI/Swagger Support**: Import from YAML/JSON OpenAPI specifications
- 🔗 **YAML Format Support**: Load APIs from YAML files with automatic detection

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  http_sandbox_viewer: ^0.1.0
```

## 🚀 Quick Start

### 1. Setup the Interceptor

Add the `HttpSandboxInterceptor` to your Dio instance:

```dart
import 'package:dio/dio.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

final dio = Dio();
dio.interceptors.add(HttpSandboxInterceptor());
```

### 2. Add the Dashboard

Navigate to the HTTP Sandbox Dashboard:

```dart
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

// Basic usage - view request history only
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const HttpSandboxDashboard(),
  ),
);

// With API definitions for testing
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => HttpSandboxDashboard(
      apiDefinitions: SampleApiDefinitions.quickStart(),
    ),
  ),
);
```

## 🎯 API Definitions

Define APIs for testing and exploration using the simple builder:

### Simple API Builder (Recommended)

```dart
final apiDefinitions = [
  SimpleApiBuilder(
    title: 'JSONPlaceholder API',
    baseUrl: 'https://jsonplaceholder.typicode.com',
    description: 'Sample API for testing',
  )
      .get('/posts', 
          name: 'Get All Posts',
          queryParams: ['userId', '_limit'],
          tags: ['posts', 'read'])
      .get('/posts/{id}', 
          name: 'Get Post by ID',
          tags: ['posts', 'read'])
      .post('/posts', 
          name: 'Create Post',
          tags: ['posts', 'write'])
      .build(),
];
```

### CRUD Builder (Even Simpler!)

```dart
final apiDefinitions = [
  // Creates GET, POST, PUT, DELETE endpoints automatically
  SimpleApiBuilder.crud(
    title: 'Posts API',
    baseUrl: 'https://jsonplaceholder.typicode.com',
    resource: 'posts',
    listQueryParams: ['userId', 'published'],
    includeSearch: true,
  ).build(),
];
```

### OpenAPI/Swagger Import

```dart
// From YAML string
const openApiYaml = '''
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
paths:
  /users:
    get:
      summary: Get users
      responses:
        '200':
          description: Success
''';

final apiFromYaml = OpenApiLoader.fromYamlString(openApiYaml);

// From JSON string
final apiFromJson = OpenApiLoader.fromJsonString(jsonString);

// From asset file (auto-detects YAML/JSON)
final apiFromAsset = await OpenApiLoader.fromAsset('assets/openapi.yaml');
```

### Pre-built Samples

```dart
final apiDefinitions = [
  SampleApiDefinitions.jsonPlaceholder(),  // JSONPlaceholder API
  SampleApiDefinitions.ecommerce(),        // E-commerce API
  SampleApiDefinitions.socialMedia(),      // Social media API
  SampleApiDefinitions.openApiPetStore(),  // OpenAPI PetStore example
  SampleApiDefinitions.openApiYamlExample(), // YAML format example
];
```

## 📖 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Sandbox Example',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Dio dio;

  @override
  void initState() {
    super.initState();
    
    // Setup Dio with HTTP Sandbox Interceptor
    dio = Dio();
    dio.interceptors.add(HttpSandboxInterceptor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP Sandbox Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await dio.get('https://jsonplaceholder.typicode.com/posts/1');
              },
              child: const Text('Make GET Request'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openSandbox,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Open HTTP Sandbox'),
            ),
          ],
        ),
      ),
    );
  }

  void _openSandbox() {
    final apiDefinitions = [
      // Use simple builder
      SimpleApiBuilder(
        title: 'JSONPlaceholder API',
        baseUrl: 'https://jsonplaceholder.typicode.com',
      )
          .get('/posts', queryParams: ['userId', '_limit'])
          .get('/posts/{id}')
          .post('/posts')
          .build(),
      
      // Or use pre-built samples
      SampleApiDefinitions.jsonPlaceholder(),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HttpSandboxDashboard(
          apiDefinitions: apiDefinitions,
        ),
      ),
    );
  }
}
```

## 🎮 Sample Applications

The package includes example applications showing different usage patterns:

### Basic Example (example/lib/main.dart)
A simple app demonstrating basic HTTP sandbox functionality with custom API definitions built using `SimpleApiBuilder`.

**Features:**
- HTTP request interception with `HttpSandboxInterceptor`
- Custom API definitions using builder pattern
- Centered UI layout with clear navigation

**To run:**
```bash
cd example
flutter run
```

### OpenAPI/YAML Sample Screen
The example app includes a dedicated button for exploring OpenAPI and YAML format samples:

**Included Samples:**
- **PetStore API**: Classic OpenAPI specification example with full CRUD operations
- **Books API**: YAML format example demonstrating genre enums and constraints

**Usage in your app:**
```dart
void _openOpenApiSamples() {
  final openApiDefinitions = [
    SampleApiDefinitions.openApiPetStore(),    // Classic OpenAPI example
    SampleApiDefinitions.openApiYamlExample(), // YAML format example
  ];

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => HttpSandboxDashboard(
        apiDefinitions: openApiDefinitions,
      ),
    ),
  );
}
```

### Quick Start Samples
Use pre-built sample API definitions for immediate testing:

```dart
// Minimal setup with 2 APIs
final quickStartApis = SampleApiDefinitions.quickStart();

// All available samples (7+ APIs)
final allApis = SampleApiDefinitions.all();

// Specific samples
final customSamples = [
  SampleApiDefinitions.jsonPlaceholder(),  // Real working API
  SampleApiDefinitions.ecommerce(),        // Complete e-commerce example
  SampleApiDefinitions.socialMedia(),      // Social platform API
];
```

### Sample API Categories

| Sample | Type | Description | Endpoints |
|--------|------|-------------|-----------|
| **JSONPlaceholder** | Working API | Real REST API for testing | 8 endpoints |
| **Posts CRUD** | Template | Basic blog post operations | 6 endpoints |
| **Users CRUD** | Template | User management API | 6 endpoints |
| **E-commerce** | Complex | Shopping cart, orders, products | 15+ endpoints |
| **Social Media** | Complex | Posts, likes, follows, timeline | 18+ endpoints |
| **PetStore (OpenAPI)** | OpenAPI | Classic Swagger example | 8 endpoints |
| **Books (YAML)** | OpenAPI | YAML format demonstration | 7 endpoints |

## 🎨 Features Overview

### Dashboard View
- **History Tab**: All HTTP requests with method, URL, status, and timestamp
- **API Definitions Tab**: Pre-defined endpoints for testing and exploration
- Color-coded HTTP methods (GET=green, POST=blue, PUT=orange, DELETE=red)
- Status code indicators with appropriate colors
- Search and filter functionality

### Request Detail View
- **Request Info**: URL, method, headers, and request body
- **Response Info**: Status code, headers, response body, and duration
- **Re-execution**: Modify parameters and re-send requests
- **Form/Raw Toggle**: Switch between form inputs and raw JSON
- **Export**: Copy request as cURL command to clipboard
- **JSON Formatting**: Pretty-printed JSON bodies

### API Definitions Dashboard
- **Swagger-like Interface**: Browse and test API endpoints
- **Parameter Forms**: Dynamic forms for all parameter types
- **Tag Filtering**: Filter endpoints by tags
- **Expandable Details**: View endpoint descriptions and parameters
- **Real-time Execution**: Execute requests and see results immediately

## 📚 API Builder Options

| Method | Description | Code Reduction |
|--------|-------------|----------------|
| **SimpleApiBuilder** | Fluent API for defining endpoints | ~70% less code |
| **CRUD Builder** | Auto-generates CRUD operations | ~90% less code |
| **Sample APIs** | Pre-built API definitions | 100% ready-to-use |

### Smart Features
- **Auto-detection**: Path parameters extracted from `{param}` syntax
- **Type Inference**: Parameter types guessed from names (id → int, limit → int)
- **Default Values**: Common parameters get sensible defaults
- **Validation**: Form validation based on parameter types

## 🔮 Roadmap

- [x] **OpenAPI Support**: Import from Swagger/OpenAPI specifications ✅
- [x] **YAML Format Support**: Full YAML format support with auto-detection ✅
- [ ] **Retrofit Integration**: Auto-generate API definitions from Retrofit services
- [ ] **Export Features**: Save to Postman collections, HAR files
- [ ] **Advanced Filtering**: Complex search and filter options
- [ ] **Performance Metrics**: Network timing and performance analysis
- [ ] **Mock Responses**: Built-in response mocking for development

## 📝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [drift_db_viewer](https://pub.dev/packages/drift_db_viewer)
- Built for the Flutter and Retrofit community
- Designed to improve API development and debugging experience