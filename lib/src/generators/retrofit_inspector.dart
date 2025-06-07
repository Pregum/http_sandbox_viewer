import 'package:flutter/foundation.dart';
import '../models/api_definition.dart';

/// Inspector that analyzes Retrofit service classes to extract API definitions.
/// 
/// This class uses static analysis of generated Retrofit code to automatically
/// create API definitions without requiring additional annotations or code generation.
/// It inspects the source files and generated code to extract endpoint information.
class RetrofitInspector {
  /// Extracts API definitions from a Retrofit service instance.
  /// 
  /// This method analyzes the runtime type and attempts to extract
  /// API definition information from the service class.
  /// 
  /// [service] - An instance of a Retrofit service
  /// [baseUrl] - The base URL for the API (required since we can't always extract it)
  /// [title] - Optional title for the API service
  /// 
  /// Example:
  /// ```dart
  /// final apiService = ApiService(dio);
  /// final definition = await RetrofitInspector.fromService(
  ///   apiService,
  ///   baseUrl: 'https://api.example.com',
  ///   title: 'My API',
  /// );
  /// ```
  static Future<ApiDefinition?> fromService(
    dynamic service, {
    required String baseUrl,
    String? title,
    String? description,
  }) async {
    try {
      final serviceType = service.runtimeType;
      final serviceName = serviceType.toString();
      
      // For now, return a basic definition with the service info
      // In a real implementation, we would analyze the service class
      return ApiDefinition(
        title: title ?? serviceName,
        description: description ?? 'Auto-generated from $serviceName',
        version: '1.0.0',
        services: [
          ApiService(
            name: serviceName,
            baseUrl: baseUrl,
            description: description,
            endpoints: [], // Will be populated by analysis
          ),
        ],
      );
    } catch (e) {
      // Error inspecting service: $e
      debugPrint('Error inspecting service: $e');
      return null;
    }
  }
  
  /// Extracts API definitions from multiple Retrofit services.
  /// 
  /// [services] - A map of service instances with their base URLs
  /// 
  /// Example:
  /// ```dart
  /// final definitions = await RetrofitInspector.fromServices({
  ///   UserService(dio): 'https://api.example.com',
  ///   PostService(dio): 'https://blog.example.com',
  /// });
  /// ```
  static Future<List<ApiDefinition>> fromServices(
    Map<dynamic, String> services,
  ) async {
    final definitions = <ApiDefinition>[];
    
    for (final entry in services.entries) {
      final service = entry.key;
      final baseUrl = entry.value;
      
      final definition = await fromService(
        service,
        baseUrl: baseUrl,
      );
      
      if (definition != null) {
        definitions.add(definition);
      }
    }
    
    return definitions;
  }
}