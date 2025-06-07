import 'package:flutter_test/flutter_test.dart';
import 'package:http_sandbox_viewer/src/examples/sample_api_definitions.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';

void main() {
  group('SampleApiDefinitions', () {
    group('jsonPlaceholder', () {
      test('should create JSONPlaceholder API definition', () {
        final apiDefinition = SampleApiDefinitions.jsonPlaceholder();

        expect(apiDefinition.title, equals('JSONPlaceholder API'));
        expect(apiDefinition.description, equals('Fake online REST API for testing and prototyping'));
        expect(apiDefinition.services.length, equals(1));

        final service = apiDefinition.services.first;
        expect(service.baseUrl, equals('https://jsonplaceholder.typicode.com'));
        expect(service.endpoints.length, greaterThan(5));

        // Check for key endpoints
        expect(service.endpoints.any((e) => 
            e.path == '/posts' && e.method == HttpMethod.get), isTrue);
        expect(service.endpoints.any((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.get), isTrue);
        expect(service.endpoints.any((e) => 
            e.path == '/posts' && e.method == HttpMethod.post), isTrue);
        expect(service.endpoints.any((e) => 
            e.path == '/users' && e.method == HttpMethod.get), isTrue);
        expect(service.endpoints.any((e) => 
            e.path == '/comments' && e.method == HttpMethod.get), isTrue);

        // Check query parameters
        final postsEndpoint = service.endpoints.firstWhere((e) => 
            e.path == '/posts' && e.method == HttpMethod.get);
        expect(postsEndpoint.parameters.any((p) => p.name == 'userId'), isTrue);
        expect(postsEndpoint.parameters.any((p) => p.name == '_limit'), isTrue);

        // Check tags
        expect(postsEndpoint.tags, contains('posts'));
        expect(postsEndpoint.tags, contains('read'));
      });
    });

    group('postsCrud', () {
      test('should create Posts CRUD API definition', () {
        final apiDefinition = SampleApiDefinitions.postsCrud();

        expect(apiDefinition.title, equals('Posts CRUD API'));
        expect(apiDefinition.description, equals('Complete CRUD operations for blog posts'));
        expect(apiDefinition.services.first.baseUrl, equals('https://jsonplaceholder.typicode.com'));

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, greaterThanOrEqualTo(5)); // At least 5 CRUD endpoints

        // Verify CRUD operations exist
        expect(endpoints.any((e) => 
            e.path == '/posts' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/posts' && e.method == HttpMethod.post), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.put), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.delete), isTrue);
        expect(endpoints.any((e) => e.path == '/posts/search'), isTrue);

        // Check query parameters for list endpoint
        final listEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts' && e.method == HttpMethod.get);
        expect(listEndpoint.parameters.any((p) => p.name == 'author'), isTrue);
        expect(listEndpoint.parameters.any((p) => p.name == 'category'), isTrue);
        expect(listEndpoint.parameters.any((p) => p.name == 'published'), isTrue);
      });
    });

    group('usersCrud', () {
      test('should create Users CRUD API definition', () {
        final apiDefinition = SampleApiDefinitions.usersCrud();

        expect(apiDefinition.title, equals('Users CRUD API'));
        expect(apiDefinition.description, equals('User management API'));
        expect(apiDefinition.services.first.baseUrl, equals('https://jsonplaceholder.typicode.com'));

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, greaterThanOrEqualTo(5)); // At least 5 CRUD endpoints

        // Check specific query parameters for users
        final listEndpoint = endpoints.firstWhere((e) => 
            e.path == '/users' && e.method == HttpMethod.get);
        expect(listEndpoint.parameters.any((p) => p.name == 'role'), isTrue);
        expect(listEndpoint.parameters.any((p) => p.name == 'status'), isTrue);
        expect(listEndpoint.parameters.any((p) => p.name == 'department'), isTrue);
      });
    });

    group('ecommerce', () {
      test('should create comprehensive e-commerce API definition', () {
        final apiDefinition = SampleApiDefinitions.ecommerce();

        expect(apiDefinition.title, equals('E-commerce API'));
        expect(apiDefinition.description, 
            equals('Comprehensive e-commerce API with products, orders, and user management'));
        expect(apiDefinition.services.first.baseUrl, equals('https://shop.example.com/api'));

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, greaterThan(10));

        // Check for product endpoints
        expect(endpoints.any((e) => e.path == '/products'), isTrue);
        expect(endpoints.any((e) => e.path == '/products/{id}'), isTrue);
        expect(endpoints.any((e) => e.path == '/products/{id}/reviews'), isTrue);

        // Check for order endpoints
        expect(endpoints.any((e) => e.path == '/orders'), isTrue);
        expect(endpoints.any((e) => e.path == '/orders/{id}'), isTrue);

        // Check for cart endpoints
        expect(endpoints.any((e) => e.path == '/cart'), isTrue);
        expect(endpoints.any((e) => e.path == '/cart/items'), isTrue);

        // Check for user profile endpoints
        expect(endpoints.any((e) => e.path == '/profile'), isTrue);
        expect(endpoints.any((e) => e.path == '/profile/addresses'), isTrue);

        // Check authentication headers
        final ordersEndpoint = endpoints.firstWhere((e) => e.path == '/orders');
        expect(ordersEndpoint.parameters.any((p) => 
            p.name == 'Authorization' && p.type == ParameterType.header), isTrue);

        // Check product query parameters
        final productsEndpoint = endpoints.firstWhere((e) => e.path == '/products');
        expect(productsEndpoint.parameters.any((p) => p.name == 'category'), isTrue);
        expect(productsEndpoint.parameters.any((p) => p.name == 'price_min'), isTrue);
        expect(productsEndpoint.parameters.any((p) => p.name == 'price_max'), isTrue);
      });
    });

    group('socialMedia', () {
      test('should create social media API definition', () {
        final apiDefinition = SampleApiDefinitions.socialMedia();

        expect(apiDefinition.title, equals('Social Media API'));
        expect(apiDefinition.description, 
            equals('Social media platform API for posts, likes, and follows'));
        expect(apiDefinition.services.first.baseUrl, equals('https://social.example.com/api'));

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, greaterThan(15));

        // Check timeline endpoints
        expect(endpoints.any((e) => e.path == '/timeline'), isTrue);
        expect(endpoints.any((e) => e.path == '/timeline/trending'), isTrue);

        // Check post endpoints
        expect(endpoints.any((e) => 
            e.path == '/posts/{id}' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/posts' && e.method == HttpMethod.post), isTrue);

        // Check interaction endpoints
        expect(endpoints.any((e) => e.path == '/posts/{id}/like'), isTrue);
        expect(endpoints.any((e) => e.path == '/posts/{id}/comments'), isTrue);

        // Check user/follow endpoints
        expect(endpoints.any((e) => e.path == '/users/{id}/follow'), isTrue);
        expect(endpoints.any((e) => e.path == '/users/{id}/followers'), isTrue);
        expect(endpoints.any((e) => e.path == '/users/{id}/following'), isTrue);

        // Check authorization requirements
        final createPostEndpoint = endpoints.firstWhere((e) => 
            e.path == '/posts' && e.method == HttpMethod.post);
        expect(createPostEndpoint.parameters.any((p) => 
            p.name == 'Authorization' && p.type == ParameterType.header), isTrue);

        // Check endpoints without body
        final likeEndpoint = endpoints.firstWhere((e) => e.path == '/posts/{id}/like');
        expect(likeEndpoint.parameters.any((p) => p.type == ParameterType.body), isFalse);
      });
    });

    group('openApiPetStore', () {
      test('should create PetStore API from OpenAPI spec', () {
        final apiDefinition = SampleApiDefinitions.openApiPetStore();

        expect(apiDefinition.title, equals('Petstore API'));
        expect(apiDefinition.description, equals('Sample API for a pet store'));
        expect(apiDefinition.services.first.baseUrl, equals('https://petstore.swagger.io/v2'));

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, greaterThan(5));

        // Check key PetStore endpoints
        expect(endpoints.any((e) => 
            e.path == '/pet' && e.method == HttpMethod.post), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/pet/{petId}' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/pet/findByStatus' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/store/order' && e.method == HttpMethod.post), isTrue);
        expect(endpoints.any((e) => e.path == '/user/login'), isTrue);

        // Check path parameters
        final getPetEndpoint = endpoints.firstWhere((e) => 
            e.path == '/pet/{petId}' && e.method == HttpMethod.get);
        expect(getPetEndpoint.parameters.any((p) => 
            p.name == 'petId' && p.type == ParameterType.path), isTrue);

        // Check query parameters with enum
        final findByStatusEndpoint = endpoints.firstWhere((e) => 
            e.path == '/pet/findByStatus');
        final statusParam = findByStatusEndpoint.parameters.firstWhere((p) => p.name == 'status');
        expect(statusParam.enumValues, isNotNull);
        expect(statusParam.enumValues!, contains('available'));
        expect(statusParam.enumValues!, contains('pending'));
        expect(statusParam.enumValues!, contains('sold'));

        // Check header parameters
        final deletePetEndpoint = endpoints.firstWhere((e) => 
            e.path == '/pet/{petId}' && e.method == HttpMethod.delete);
        expect(deletePetEndpoint.parameters.any((p) => 
            p.name == 'api_key' && p.type == ParameterType.header), isTrue);
      });
    });

    group('openApiYamlExample', () {
      test('should create Books API from YAML OpenAPI spec', () {
        final apiDefinition = SampleApiDefinitions.openApiYamlExample();

        expect(apiDefinition.title, equals('Books API'));
        expect(apiDefinition.description, equals('A simple books management API (YAML format example)'));
        expect(apiDefinition.services.first.baseUrl, equals('https://api.bookstore.com/v1'));

        final endpoints = apiDefinition.services.first.endpoints;
        expect(endpoints.length, greaterThan(5));

        // Check books endpoints
        expect(endpoints.any((e) => 
            e.path == '/books' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/books/{id}' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/books' && e.method == HttpMethod.post), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/books/{id}' && e.method == HttpMethod.put), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/books/{id}' && e.method == HttpMethod.delete), isTrue);

        // Check authors endpoints
        expect(endpoints.any((e) => 
            e.path == '/authors' && e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => 
            e.path == '/authors/{id}' && e.method == HttpMethod.get), isTrue);

        // Check query parameters
        final getBooksEndpoint = endpoints.firstWhere((e) => 
            e.path == '/books' && e.method == HttpMethod.get);
        expect(getBooksEndpoint.parameters.any((p) => p.name == 'author'), isTrue);
        expect(getBooksEndpoint.parameters.any((p) => p.name == 'genre'), isTrue);
        expect(getBooksEndpoint.parameters.any((p) => p.name == 'limit'), isTrue);

        // Check enum values for genre parameter
        final genreParam = getBooksEndpoint.parameters.firstWhere((p) => p.name == 'genre');
        expect(genreParam.enumValues, isNotNull);
        expect(genreParam.enumValues!, contains('fiction'));
        expect(genreParam.enumValues!, contains('non-fiction'));
        expect(genreParam.enumValues!, contains('mystery'));
        expect(genreParam.enumValues!, contains('romance'));
        expect(genreParam.enumValues!, contains('sci-fi'));

        // Check integer parameter with constraints
        final limitParam = getBooksEndpoint.parameters.firstWhere((p) => p.name == 'limit');
        expect(limitParam.dataType, equals(int));
      });
    });

    group('Collection methods', () {
      test('all() should return all sample API definitions', () {
        final allApis = SampleApiDefinitions.all();

        expect(allApis.length, greaterThanOrEqualTo(7));
        expect(allApis.any((api) => api.title == 'JSONPlaceholder API'), isTrue);
        expect(allApis.any((api) => api.title == 'Posts CRUD API'), isTrue);
        expect(allApis.any((api) => api.title == 'Users CRUD API'), isTrue);
        expect(allApis.any((api) => api.title == 'E-commerce API'), isTrue);
        expect(allApis.any((api) => api.title == 'Social Media API'), isTrue);
        expect(allApis.any((api) => api.title == 'Petstore API'), isTrue);
        expect(allApis.any((api) => api.title == 'Books API'), isTrue);
      });

      test('quickStart() should return subset of APIs', () {
        final quickStartApis = SampleApiDefinitions.quickStart();

        expect(quickStartApis.length, equals(2));
        expect(quickStartApis.any((api) => api.title == 'JSONPlaceholder API'), isTrue);
        expect(quickStartApis.any((api) => api.title == 'Posts CRUD API'), isTrue);
      });
    });

    group('API consistency', () {
      test('all sample APIs should have valid structure', () {
        final allApis = SampleApiDefinitions.all();

        for (final api in allApis) {
          // Every API should have basic properties
          expect(api.title, isNotEmpty);
          expect(api.services, isNotEmpty);
          
          for (final service in api.services) {
            expect(service.name, isNotEmpty);
            expect(service.baseUrl, isNotEmpty);
            expect(service.baseUrl, startsWith('http'));
            
            for (final endpoint in service.endpoints) {
              expect(endpoint.name, isNotEmpty);
              expect(endpoint.path, isNotEmpty);
              expect(endpoint.path, startsWith('/'));
              expect(endpoint.method, isIn(HttpMethod.values));
              
              for (final parameter in endpoint.parameters) {
                expect(parameter.name, isNotEmpty);
                expect(parameter.type, isIn(ParameterType.values));
                expect(parameter.dataType, isNotNull);
              }
            }
          }
        }
      });

      test('all sample APIs should have unique titles', () {
        final allApis = SampleApiDefinitions.all();
        final titles = allApis.map((api) => api.title).toList();
        final uniqueTitles = titles.toSet();

        expect(uniqueTitles.length, equals(titles.length),
            reason: 'All API titles should be unique');
      });

      test('all sample APIs should have reasonable endpoint counts', () {
        final allApis = SampleApiDefinitions.all();

        for (final api in allApis) {
          final totalEndpoints = api.services
              .map((s) => s.endpoints.length)
              .reduce((a, b) => a + b);
          
          expect(totalEndpoints, greaterThan(0),
              reason: '${api.title} should have at least one endpoint');
          expect(totalEndpoints, lessThan(50),
              reason: '${api.title} should not have excessive endpoints');
        }
      });
    });
  });
}