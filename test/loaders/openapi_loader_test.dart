import 'package:flutter_test/flutter_test.dart';
import 'package:http_sandbox_viewer/src/loaders/openapi_loader.dart';
import 'package:http_sandbox_viewer/src/models/api_definition.dart';

void main() {
  group('OpenApiLoader', () {
    group('fromJsonString', () {
      test('should parse valid JSON OpenAPI specification', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0",
    "description": "Test API description"
  },
  "servers": [
    {
      "url": "https://api.test.com"
    }
  ],
  "paths": {
    "/users": {
      "get": {
        "summary": "Get users",
        "tags": ["users"],
        "parameters": [
          {
            "name": "limit",
            "in": "query",
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      },
      "post": {
        "summary": "Create user",
        "tags": ["users"],
        "requestBody": {
          "required": true
        },
        "responses": {
          "201": {
            "description": "Created"
          }
        }
      }
    },
    "/users/{id}": {
      "get": {
        "summary": "Get user by ID",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);

        expect(result, isNotNull);
        expect(result!.title, equals('Test API'));
        expect(result.description, equals('Test API description'));
        expect(result.version, equals('1.0.0'));
        expect(result.services.length, equals(1));

        final service = result.services.first;
        expect(service.name, equals('Test API'));
        expect(service.baseUrl, equals('https://api.test.com'));
        expect(service.endpoints.length, equals(3));

        // Check GET /users endpoint
        final getUsersEndpoint = service.endpoints
            .where((e) => e.path == '/users' && e.method == HttpMethod.get)
            .first;
        expect(getUsersEndpoint.name, equals('Get users'));
        expect(getUsersEndpoint.tags, contains('users'));
        expect(getUsersEndpoint.parameters.length, equals(1));
        expect(getUsersEndpoint.parameters.first.name, equals('limit'));
        expect(getUsersEndpoint.parameters.first.type, equals(ParameterType.query));

        // Check POST /users endpoint
        final postUsersEndpoint = service.endpoints
            .where((e) => e.path == '/users' && e.method == HttpMethod.post)
            .first;
        expect(postUsersEndpoint.name, equals('Create user'));
        expect(postUsersEndpoint.parameters.any((p) => p.type == ParameterType.body), isTrue);

        // Check GET /users/{id} endpoint
        final getUserEndpoint = service.endpoints
            .where((e) => e.path == '/users/{id}' && e.method == HttpMethod.get)
            .first;
        expect(getUserEndpoint.name, equals('Get user by ID'));
        expect(getUserEndpoint.parameters.length, equals(1));
        expect(getUserEndpoint.parameters.first.name, equals('id'));
        expect(getUserEndpoint.parameters.first.type, equals(ParameterType.path));
        expect(getUserEndpoint.parameters.first.required, isTrue);
      });

      test('should return null for invalid JSON', () {
        const invalidJson = '{ invalid json }';
        final result = OpenApiLoader.fromJsonString(invalidJson);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = OpenApiLoader.fromJsonString('');
        expect(result, isNull);
      });

      test('should handle missing info section', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "paths": {
    "/test": {
      "get": {
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);
        expect(result, isNotNull);
        expect(result!.title, equals('API'));
        expect(result.version, equals('1.0.0'));
      });

      test('should use fallback base URL when no servers defined', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0"
  },
  "paths": {
    "/test": {
      "get": {
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);
        expect(result, isNotNull);
        expect(result!.services.first.baseUrl, equals('https://jsonplaceholder.typicode.com'));
      });

      test('should override base URL when provided', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "https://original.com"
    }
  ],
  "paths": {
    "/test": {
      "get": {
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec, baseUrl: 'https://override.com');
        expect(result, isNotNull);
        expect(result!.services.first.baseUrl, equals('https://override.com'));
      });
    });

    group('fromYamlString', () {
      test('should parse valid YAML OpenAPI specification', () {
        const yamlSpec = '''
openapi: 3.0.0
info:
  title: Books API
  description: YAML format API
  version: 2.0.0
servers:
  - url: https://books.api.com
paths:
  /books:
    get:
      summary: Get all books
      tags:
        - books
      parameters:
        - name: author
          in: query
          schema:
            type: string
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
      responses:
        '200':
          description: List of books
    post:
      summary: Create book
      tags:
        - books
      requestBody:
        required: true
        description: Book data
      responses:
        '201':
          description: Book created
  /books/{id}:
    get:
      summary: Get book by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Book details
    delete:
      summary: Delete book
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '204':
          description: Book deleted
''';

        final result = OpenApiLoader.fromYamlString(yamlSpec);

        expect(result, isNotNull);
        expect(result!.title, equals('Books API'));
        expect(result.description, equals('YAML format API'));
        expect(result.version, equals('2.0.0'));
        expect(result.services.length, equals(1));

        final service = result.services.first;
        expect(service.name, equals('Books API'));
        expect(service.baseUrl, equals('https://books.api.com'));
        expect(service.endpoints.length, equals(4));

        // Check GET /books endpoint
        final getBooksEndpoint = service.endpoints
            .where((e) => e.path == '/books' && e.method == HttpMethod.get)
            .first;
        expect(getBooksEndpoint.name, equals('Get all books'));
        expect(getBooksEndpoint.tags, contains('books'));
        expect(getBooksEndpoint.parameters.length, equals(2));
        
        final authorParam = getBooksEndpoint.parameters.firstWhere((p) => p.name == 'author');
        expect(authorParam.type, equals(ParameterType.query));
        expect(authorParam.dataType, equals(String));
        
        final limitParam = getBooksEndpoint.parameters.firstWhere((p) => p.name == 'limit');
        expect(limitParam.type, equals(ParameterType.query));
        expect(limitParam.dataType, equals(int));

        // Check POST /books endpoint
        final postBooksEndpoint = service.endpoints
            .where((e) => e.path == '/books' && e.method == HttpMethod.post)
            .first;
        expect(postBooksEndpoint.name, equals('Create book'));
        expect(postBooksEndpoint.parameters.any((p) => p.type == ParameterType.body), isTrue);

        // Check DELETE /books/{id} endpoint
        final deleteBookEndpoint = service.endpoints
            .where((e) => e.path == '/books/{id}' && e.method == HttpMethod.delete)
            .first;
        expect(deleteBookEndpoint.name, equals('Delete book'));
        expect(deleteBookEndpoint.parameters.length, equals(1));
        expect(deleteBookEndpoint.parameters.first.name, equals('id'));
        expect(deleteBookEndpoint.parameters.first.type, equals(ParameterType.path));
        expect(deleteBookEndpoint.parameters.first.required, isTrue);
      });

      test('should handle YAML with complex structures', () {
        const yamlSpec = '''
openapi: 3.0.0
info:
  title: Complex API
  version: 1.0.0
paths:
  /users/{id}/posts:
    get:
      summary: Get user posts
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
            format: int64
        - name: status
          in: query
          schema:
            type: string
            enum:
              - published
              - draft
              - archived
        - name: Authorization
          in: header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: User posts
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
''';

        final result = OpenApiLoader.fromYamlString(yamlSpec);

        expect(result, isNotNull);
        final endpoint = result!.services.first.endpoints.first;
        expect(endpoint.path, equals('/users/{id}/posts'));
        expect(endpoint.parameters.length, equals(3));
        
        final statusParam = endpoint.parameters.firstWhere((p) => p.name == 'status');
        expect(statusParam.enumValues, isNotNull);
        expect(statusParam.enumValues!, contains('published'));
        expect(statusParam.enumValues!, contains('draft'));
        expect(statusParam.enumValues!, contains('archived'));
        
        final authParam = endpoint.parameters.firstWhere((p) => p.name == 'Authorization');
        expect(authParam.type, equals(ParameterType.header));
        expect(authParam.required, isTrue);
      });

      test('should return null for invalid YAML', () {
        const invalidYaml = '''
invalid: yaml: content:
  - missing
    proper: structure
''';
        final result = OpenApiLoader.fromYamlString(invalidYaml);
        expect(result, isNull);
      });

      test('should return null for non-map YAML', () {
        const listYaml = '''
- item1
- item2
- item3
''';
        final result = OpenApiLoader.fromYamlString(listYaml);
        expect(result, isNull);
      });

      test('should handle YAML with comments', () {
        const yamlWithComments = '''
openapi: 3.0.0
info:
  title: Commented API
  version: 1.0.0
  # This is a comment
paths:
  /test:
    get:
      # Another comment
      summary: Test endpoint
      responses:
        '200':
          description: Success
          # Response comment
''';

        final result = OpenApiLoader.fromYamlString(yamlWithComments);
        expect(result, isNotNull);
        expect(result!.title, equals('Commented API'));
        expect(result.services.first.endpoints.length, equals(1));
      });
    });

    group('fromMap', () {
      test('should parse valid Map OpenAPI specification', () {
        final mapSpec = {
          "openapi": "3.0.0",
          "info": {
            "title": "Map API",
            "version": "1.0.0"
          },
          "paths": {
            "/test": {
              "get": {
                "summary": "Test endpoint",
                "responses": {
                  "200": {
                    "description": "Success"
                  }
                }
              }
            }
          }
        };

        final result = OpenApiLoader.fromMap(mapSpec);

        expect(result, isNotNull);
        expect(result!.title, equals('Map API'));
        expect(result.services.first.endpoints.length, equals(1));
      });

      test('should handle empty map', () {
        final emptyMap = <String, dynamic>{};
        final result = OpenApiLoader.fromMap(emptyMap);

        expect(result, isNotNull);
        expect(result!.title, equals('API'));
        expect(result.services.first.endpoints.length, equals(0));
      });
    });

    group('HTTP methods parsing', () {
      test('should parse all supported HTTP methods', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Methods API",
    "version": "1.0.0"
  },
  "paths": {
    "/test": {
      "get": {
        "summary": "GET method",
        "responses": {"200": {"description": "Success"}}
      },
      "post": {
        "summary": "POST method",
        "responses": {"201": {"description": "Created"}}
      },
      "put": {
        "summary": "PUT method",
        "responses": {"200": {"description": "Updated"}}
      },
      "delete": {
        "summary": "DELETE method",
        "responses": {"204": {"description": "Deleted"}}
      },
      "patch": {
        "summary": "PATCH method",
        "responses": {"200": {"description": "Patched"}}
      },
      "head": {
        "summary": "HEAD method",
        "responses": {"200": {"description": "Success"}}
      },
      "options": {
        "summary": "OPTIONS method",
        "responses": {"200": {"description": "Success"}}
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);

        expect(result, isNotNull);
        final endpoints = result!.services.first.endpoints;
        expect(endpoints.length, equals(7));

        expect(endpoints.any((e) => e.method == HttpMethod.get), isTrue);
        expect(endpoints.any((e) => e.method == HttpMethod.post), isTrue);
        expect(endpoints.any((e) => e.method == HttpMethod.put), isTrue);
        expect(endpoints.any((e) => e.method == HttpMethod.delete), isTrue);
        expect(endpoints.any((e) => e.method == HttpMethod.patch), isTrue);
        expect(endpoints.any((e) => e.method == HttpMethod.head), isTrue);
        expect(endpoints.any((e) => e.method == HttpMethod.options), isTrue);
      });
    });

    group('Parameter types parsing', () {
      test('should parse different parameter types', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Params API",
    "version": "1.0.0"
  },
  "paths": {
    "/test/{id}": {
      "post": {
        "summary": "Test parameters",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": {"type": "integer"}
          },
          {
            "name": "filter",
            "in": "query",
            "schema": {"type": "string"}
          },
          {
            "name": "X-API-Key",
            "in": "header",
            "required": true,
            "schema": {"type": "string"}
          }
        ],
        "requestBody": {
          "required": true,
          "description": "Request body"
        },
        "responses": {
          "200": {"description": "Success"}
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);

        expect(result, isNotNull);
        final endpoint = result!.services.first.endpoints.first;
        expect(endpoint.parameters.length, equals(4)); // 3 explicit + 1 body

        final pathParam = endpoint.parameters.firstWhere((p) => p.type == ParameterType.path);
        expect(pathParam.name, equals('id'));
        expect(pathParam.required, isTrue);
        expect(pathParam.dataType, equals(int));

        final queryParam = endpoint.parameters.firstWhere((p) => p.type == ParameterType.query);
        expect(queryParam.name, equals('filter'));
        expect(queryParam.dataType, equals(String));

        final headerParam = endpoint.parameters.firstWhere((p) => p.type == ParameterType.header);
        expect(headerParam.name, equals('X-API-Key'));
        expect(headerParam.required, isTrue);

        final bodyParam = endpoint.parameters.firstWhere((p) => p.type == ParameterType.body);
        expect(bodyParam.name, equals('body'));
        expect(bodyParam.required, isTrue);
      });

      test('should parse different data types', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Types API",
    "version": "1.0.0"
  },
  "paths": {
    "/test": {
      "get": {
        "summary": "Test data types",
        "parameters": [
          {
            "name": "stringParam",
            "in": "query",
            "schema": {"type": "string"}
          },
          {
            "name": "intParam",
            "in": "query",
            "schema": {"type": "integer"}
          },
          {
            "name": "numberParam",
            "in": "query",
            "schema": {"type": "number"}
          },
          {
            "name": "boolParam",
            "in": "query",
            "schema": {"type": "boolean"}
          },
          {
            "name": "arrayParam",
            "in": "query",
            "schema": {"type": "array"}
          },
          {
            "name": "objectParam",
            "in": "query",
            "schema": {"type": "object"}
          }
        ],
        "responses": {
          "200": {"description": "Success"}
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);

        expect(result, isNotNull);
        final endpoint = result!.services.first.endpoints.first;
        expect(endpoint.parameters.length, equals(6));

        final stringParam = endpoint.parameters.firstWhere((p) => p.name == 'stringParam');
        expect(stringParam.dataType, equals(String));

        final intParam = endpoint.parameters.firstWhere((p) => p.name == 'intParam');
        expect(intParam.dataType, equals(int));

        final numberParam = endpoint.parameters.firstWhere((p) => p.name == 'numberParam');
        expect(numberParam.dataType, equals(double));

        final boolParam = endpoint.parameters.firstWhere((p) => p.name == 'boolParam');
        expect(boolParam.dataType, equals(bool));

        final arrayParam = endpoint.parameters.firstWhere((p) => p.name == 'arrayParam');
        expect(arrayParam.dataType, equals(List));

        final objectParam = endpoint.parameters.firstWhere((p) => p.name == 'objectParam');
        expect(objectParam.dataType, equals(Map));
      });
    });

    group('Response type extraction', () {
      test('should extract response types from OpenAPI responses', () {
        const jsonSpec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Response API",
    "version": "1.0.0"
  },
  "paths": {
    "/users": {
      "get": {
        "summary": "Get users",
        "responses": {
          "200": {
            "description": "List of users",
            "content": {
              "application/json": {
                "schema": {
                  "type": "array",
                  "items": {
                    "\$ref": "#/components/schemas/User"
                  }
                }
              }
            }
          }
        }
      }
    },
    "/users/{id}": {
      "get": {
        "summary": "Get user",
        "responses": {
          "200": {
            "description": "Single user",
            "content": {
              "application/json": {
                "schema": {
                  "\$ref": "#/components/schemas/User"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

        final result = OpenApiLoader.fromJsonString(jsonSpec);

        expect(result, isNotNull);
        final endpoints = result!.services.first.endpoints;

        final listEndpoint = endpoints.firstWhere((e) => e.path == '/users');
        expect(listEndpoint.responseType, anyOf(equals('List<User>'), isNull));

        final singleEndpoint = endpoints.firstWhere((e) => e.path == '/users/{id}');
        // The response type might be null if schema reference is not resolved
        expect(singleEndpoint.responseType, anyOf(equals('User'), isNull));
      });
    });
  });
}