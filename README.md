# HTTP Sandbox Viewer

A Flutter package for debugging HTTP requests and responses in development. This package provides a visual dashboard to inspect, analyze, and re-execute HTTP requests made through Dio + Retrofit.

> Inspired by [drift_db_viewer](https://pub.dev/packages/drift_db_viewer)

## Features

- 🔍 **Request/Response Inspection**: View detailed information about HTTP requests and responses
- 📊 **Visual Dashboard**: Clean, intuitive UI for browsing HTTP history
- 🔄 **Request Re-execution**: Re-send recorded requests for testing
- 📋 **Export to cURL**: Copy requests as cURL commands
- 💾 **Persistent Storage**: HTTP history is saved across app sessions
- 🎨 **Status Code Highlighting**: Color-coded status indicators
- ⏱️ **Timestamp Tracking**: See when requests were made with relative time

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  http_sandbox_viewer: ^0.0.1
```

## Usage

### 1. Setup the Interceptor

Add the `HttpSandboxInterceptor` to your Dio instance:

```dart
import 'package:dio/dio.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

final dio = Dio();
dio.interceptors.add(HttpSandboxInterceptor());
```

### 2. Add the Dashboard to Your App

Add a way to navigate to the HTTP Sandbox Dashboard:

```dart
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

// Navigate to the dashboard
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const HttpSandboxDashboard(),
  ),
);
```

### 3. Complete Example

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await dio.get('https://jsonplaceholder.typicode.com/posts/1');
            },
            child: const Text('Make GET Request'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HttpSandboxDashboard(),
                ),
              );
            },
            child: const Text('Open HTTP Sandbox'),
          ),
        ],
      ),
    );
  }
}
```

## Features Overview

### Dashboard View
- List all HTTP requests with method, URL, status code, and timestamp
- Color-coded HTTP methods (GET=green, POST=blue, PUT=orange, DELETE=red)
- Status code indicators with appropriate colors
- Relative timestamps (e.g., "2m ago", "1h ago")

### Request Detail View
- **Request Tab**: URL, method, headers, and request body
- **Response Tab**: Status code, headers, response body, and duration
- **Export**: Copy request as cURL command to clipboard
- **JSON Formatting**: Pretty-printed JSON bodies for better readability

### Data Persistence
- Requests are automatically saved to device storage
- History persists across app restarts
- Clear all records with a single tap

## Limitations

- Currently supports Dio interceptors only
- Designed for development/debugging use only
- Storage is local to the device

## Future Plans

- Support for `http` package and `chopper`
- Request filtering and search
- Export to various formats (HAR, Postman collections)
- Timeline view with status-based filtering
- Network performance metrics

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.