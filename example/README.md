# HTTP Sandbox Viewer Example

This example app demonstrates how to use the `http_sandbox_viewer` package for debugging HTTP requests and responses with pre-defined API definitions.

## Features Demonstrated

- **HTTP Request Interception**: Using `HttpSandboxInterceptor` with Dio
- **Dashboard Navigation**: Accessing the HTTP Sandbox Dashboard
- **API Definitions**: Examples using `SimpleApiBuilder` and pre-built samples
- **OpenAPI/YAML Support**: Dedicated screen for OpenAPI examples

## Running the Example

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

## Example Features

### Main Example (lib/main.dart)
- Basic HTTP request interception setup
- Dashboard with custom API definitions
- Centered UI layout with clear navigation

### OpenAPI Example (openapi_example.dart)  
- YAML format OpenAPI loading
- JSON format OpenAPI loading
- Asset-based OpenAPI loading
- Advanced e-commerce API examples
- Pre-built sample integrations

## API Samples Included

| Sample | Description | Endpoints |
|--------|-------------|-----------|
| **JSONPlaceholder** | Real working REST API | 8 endpoints |
| **E-commerce** | Shopping cart and orders | 15+ endpoints |
| **Social Media** | Posts, likes, follows | 18+ endpoints |
| **PetStore** | Classic OpenAPI example | 8 endpoints |
| **Weather API** | YAML format example | 3 endpoints |

## Code Examples

### Basic Setup
```dart
// Setup Dio with interceptor
final dio = Dio();
dio.interceptors.add(HttpSandboxInterceptor());

// Open dashboard
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => HttpSandboxDashboard(
      apiDefinitions: SampleApiDefinitions.quickStart(),
    ),
  ),
);
```

### OpenAPI Loading
```dart
// From YAML string
final api = OpenApiLoader.fromYamlString(yamlContent);

// From JSON string  
final api = OpenApiLoader.fromJsonString(jsonContent);

// From asset file
final api = await OpenApiLoader.fromAsset('assets/openapi.yaml');
```

## Package Documentation

For complete documentation, see the main package README at:
https://github.com/Pregum/http_sandbox_viewer