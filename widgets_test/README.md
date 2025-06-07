# Network-Dependent Widget Tests

This directory contains widget tests that are separated from the standard `test/` directory which runs in offline mode.

## Purpose

As noted by the user, the standard `test/` directory runs in offline mode where all HTTP requests are blocked. This `widgets_test/` directory is intended for tests that may need network access or have different execution requirements.

## Test Files

### `simple_network_test.dart`
Basic widget tests for network-related UI components:
- Form display and parameter validation
- Field input and form state management  
- Loading states and button behavior
- Enum parameter dropdown functionality
- Request body form/raw mode toggle

### `api_endpoint_execution_form_network_test.dart` (Experimental)
Tests for actual network request execution:
- Loading state verification during request execution
- Form validation with network endpoints
- Error handling for invalid URLs

### `http_sandbox_integration_network_test.dart` (Experimental)
Integration tests for complete workflows:
- Navigate between tabs and execute requests
- History tracking after execution
- Search and filter functionality

## Status

Currently, the network tests face some challenges:
- Widget finder ambiguity with multiple similar elements
- Timer-related test cleanup issues  
- Network request timeouts in test environment

The `simple_network_test.dart` file focuses on UI behavior without actual network calls and provides the most reliable test coverage.

## Running Tests

```bash
# Run the working UI tests
mise exec -- flutter test widgets_test/simple_network_test.dart

# Run all tests (some may fail)
mise exec -- flutter test widgets_test/

# Run with verbose output for debugging
mise exec -- flutter test widgets_test/ --verbose
```

## Recommendations

For reliable testing:
1. Use the standard `test/` directory for unit tests and UI tests without network
2. Use this `widgets_test/` directory for UI tests that need network-like behavior
3. Consider mocking network requests for more predictable test results
4. Use integration tests or manual testing for actual network validation

## Test Coverage Summary

The test suite provides coverage for:
- ✅ API definition models and validation
- ✅ Service layer functionality  
- ✅ Dashboard UI and tab navigation
- ✅ Request history display
- ✅ Form validation and parameter handling
- ✅ Execution form UI components
- ⚠️ Actual network request execution (experimental)
- ⚠️ Complete end-to-end workflows (experimental)