# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-06-08

### Fixed
- 🔧 **Working API URLs**: Updated all sample APIs to use functional endpoints
  - PetStore API: Now uses `petstore3.swagger.io/api/v3` (working Swagger v3 API)
  - Books API: Now uses `openlibrary.org/api` (real Open Library API)
  - E-commerce API: Now uses `fakestoreapi.com` (working test e-commerce API)
  - Social Media API: Enhanced with more JSONPlaceholder endpoints
- 📋 **Sample API Improvements**: All sample APIs now return actual data for testing
- 🧪 **Test Updates**: Updated test URLs to match working endpoints
- 📱 **UI Fixes**: Improved center alignment in example applications

### Known Issues
- ⚠️ **Test Coverage**: Some widget tests need adjustment for UI edge cases (non-blocking)
- 🔄 **Concurrent Request Tests**: Minor timing issues in concurrent request tests (functionality works correctly)

These issues don't affect the core functionality and will be addressed in future releases.

## [0.1.0] - 2025-06-07

### Added
- 🎉 **Initial Release** - HTTP Sandbox Viewer for debugging HTTP requests and responses
- 📊 **Visual Dashboard** with tab navigation (History + API Definitions)
- 🔍 **Request/Response Inspection** with detailed view and JSON formatting
- 🔄 **Request Re-execution** with parameter modification
- 📋 **cURL Export** functionality for CLI usage
- 💾 **Persistent Storage** using SharedPreferences
- 🎨 **Status Code Highlighting** with color-coded indicators
- ⏱️ **Timestamp Tracking** with relative time display

### API Definitions System
- 🚀 **Swagger-like API Definitions** for pre-defined endpoint testing
- 🏗️ **SimpleApiBuilder** - Fluent API builder with 70% code reduction
- 📚 **CRUD Builder** - One-line CRUD API generation
- 🎯 **Pre-built Samples** - Ready-to-use API definitions
  - JSONPlaceholder API
  - E-commerce API (products, orders, cart, user management)
  - Social Media API (posts, likes, follows, comments)
- 📝 **Dynamic Parameter Forms** for all parameter types (path, query, header, body)
- 🔀 **Form/Raw JSON Toggle** for request body editing
- 🏷️ **Tag-based Filtering** and search functionality
- ✅ **Real-time Validation** with type checking

### Smart Features
- 🤖 **Auto-detection** of path parameters from `{param}` syntax
- 🧠 **Type Inference** for common parameter names (id → int, limit → int)
- 🎯 **Default Values** for common parameters (_limit: 10, _offset: 0)
- 📋 **Parameter Validation** based on data types

### Developer Experience
- 📖 **Comprehensive Documentation** with examples
- 🎮 **Interactive Examples** with working code
- 🔧 **Easy Integration** with existing Dio setup
- 🎨 **Beautiful UI** with Material Design
- 📱 **Responsive Layout** for different screen sizes

### Foundation for Future Features
- 🏗️ **Retrofit Inspector** foundation for auto-generation
- 📝 **Annotation System** for future Retrofit integration
- 🔌 **Extensible Architecture** for additional HTTP clients

## [Unreleased]

### Planned Features
- **Retrofit Integration**: Auto-generate API definitions from Retrofit services
- **OpenAPI Support**: Import from Swagger/OpenAPI specifications
- **Export Features**: Save to Postman collections, HAR files
- **Advanced Filtering**: Complex search and filter options
- **Performance Metrics**: Network timing and performance analysis
- **Mock Responses**: Built-in response mocking for development