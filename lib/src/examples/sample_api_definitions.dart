import '../models/api_definition.dart';
import '../builders/simple_api_builder.dart';
import '../loaders/openapi_loader.dart';

/// Pre-built API definitions for common testing scenarios.
/// 
/// This class provides several ready-to-use API definitions that can be
/// used for testing and demonstration purposes.
class SampleApiDefinitions {
  /// Creates a sample JSONPlaceholder API definition using the simple builder.
  static ApiDefinition jsonPlaceholder() {
    return SimpleApiBuilder(
      title: 'JSONPlaceholder API',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      description: 'Fake online REST API for testing and prototyping',
    )
        .get('/posts', 
            name: 'Get All Posts',
            description: 'Retrieve all posts',
            queryParams: ['userId', '_limit', '_start'],
            tags: ['posts', 'read'],
            responseType: 'List<Post>')
        .get('/posts/{id}',
            name: 'Get Post by ID', 
            description: 'Retrieve a specific post',
            tags: ['posts', 'read'],
            responseType: 'Post')
        .post('/posts',
            name: 'Create Post',
            description: 'Create a new post',
            tags: ['posts', 'write'],
            responseType: 'Post')
        .put('/posts/{id}',
            name: 'Update Post',
            description: 'Update an existing post',
            tags: ['posts', 'write'],
            responseType: 'Post')
        .delete('/posts/{id}',
            name: 'Delete Post',
            description: 'Delete a post',
            tags: ['posts', 'write'],
            responseType: 'void')
        .get('/users',
            name: 'Get All Users',
            description: 'Retrieve all users',
            tags: ['users', 'read'],
            responseType: 'List<User>')
        .get('/users/{id}',
            name: 'Get User by ID',
            description: 'Retrieve a specific user',
            tags: ['users', 'read'],
            responseType: 'User')
        .get('/comments',
            name: 'Get Comments',
            description: 'Retrieve comments',
            queryParams: ['postId', '_limit'],
            tags: ['comments', 'read'],
            responseType: 'List<Comment>')
        .build();
  }
  
  /// Creates a CRUD API for posts using the convenience method.
  static ApiDefinition postsCrud() {
    return SimpleApiBuilder.crud(
      title: 'Posts CRUD API',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      resource: 'posts',
      description: 'Complete CRUD operations for blog posts',
      listQueryParams: ['userId', '_limit', '_start'],
      includeSearch: true,
    ).build();
  }
  
  /// Creates a CRUD API for users.
  static ApiDefinition usersCrud() {
    return SimpleApiBuilder.crud(
      title: 'Users CRUD API',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      resource: 'users',
      description: 'User management API',
      listQueryParams: ['_limit', '_start'],
      includeSearch: false,
    ).build();
  }
  
  /// Creates a comprehensive e-commerce API definition.
  static ApiDefinition ecommerce() {
    return SimpleApiBuilder(
      title: 'E-commerce API',
      baseUrl: 'https://fakestoreapi.com',
      description: 'Comprehensive e-commerce API with products, carts, and user management',
    )
        // Products
        .get('/products',
            name: 'Get Products',
            queryParams: ['limit', 'sort'],
            tags: ['products', 'read'],
            responseType: 'List<Product>')
        .get('/products/{id}',
            name: 'Get Product Details',
            tags: ['products', 'read'],
            responseType: 'Product')
        .post('/products',
            name: 'Create Product',
            tags: ['products', 'write'],
            responseType: 'Product')
        .put('/products/{id}',
            name: 'Update Product',
            tags: ['products', 'write'],
            responseType: 'Product')
        .delete('/products/{id}',
            name: 'Delete Product',
            tags: ['products', 'write'],
            responseType: 'Product')
        
        // Categories
        .get('/products/categories',
            name: 'Get Categories',
            tags: ['categories', 'read'],
            responseType: 'List<String>')
        .get('/products/category/{category}',
            name: 'Get Products by Category',
            queryParams: ['limit', 'sort'],
            tags: ['categories', 'products', 'read'],
            responseType: 'List<Product>')
        
        // Carts
        .get('/carts',
            name: 'Get All Carts',
            queryParams: ['limit', 'sort', 'startdate', 'enddate'],
            tags: ['carts', 'read'],
            responseType: 'List<Cart>')
        .get('/carts/{id}',
            name: 'Get Cart Details',
            tags: ['carts', 'read'],
            responseType: 'Cart')
        .get('/carts/user/{userId}',
            name: 'Get User Carts',
            tags: ['carts', 'users', 'read'],
            responseType: 'List<Cart>')
        .post('/carts',
            name: 'Create Cart',
            tags: ['carts', 'write'],
            responseType: 'Cart')
        .put('/carts/{id}',
            name: 'Update Cart',
            tags: ['carts', 'write'],
            responseType: 'Cart')
        .delete('/carts/{id}',
            name: 'Delete Cart',
            tags: ['carts', 'write'],
            responseType: 'Cart')
        
        // Users
        .get('/users',
            name: 'Get All Users',
            queryParams: ['limit', 'sort'],
            tags: ['users', 'read'],
            responseType: 'List<User>')
        .get('/users/{id}',
            name: 'Get User Details',
            tags: ['users', 'read'],
            responseType: 'User')
        .post('/users',
            name: 'Create User',
            tags: ['users', 'write'],
            responseType: 'User')
        .put('/users/{id}',
            name: 'Update User',
            tags: ['users', 'write'],
            responseType: 'User')
        .delete('/users/{id}',
            name: 'Delete User',
            tags: ['users', 'write'],
            responseType: 'User')
        
        // Auth
        .post('/auth/login',
            name: 'User Login',
            tags: ['auth'],
            responseType: 'LoginResponse')
        
        .build();
  }
  
  /// Creates a social media API definition.
  static ApiDefinition socialMedia() {
    return SimpleApiBuilder(
      title: 'Social Media API',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      description: 'Social media platform API for posts, comments, and users',
    )
        // Posts
        .get('/posts',
            name: 'Get All Posts',
            queryParams: ['userId', '_limit', '_start', '_sort', '_order'],
            tags: ['posts', 'read'],
            responseType: 'List<Post>')
        .get('/posts/{id}',
            name: 'Get Post',
            tags: ['posts', 'read'],
            responseType: 'Post')
        .post('/posts',
            name: 'Create Post',
            tags: ['posts', 'write'],
            responseType: 'Post')
        .put('/posts/{id}',
            name: 'Update Post',
            tags: ['posts', 'write'],
            responseType: 'Post')
        .patch('/posts/{id}',
            name: 'Partial Update Post',
            tags: ['posts', 'write'],
            responseType: 'Post')
        .delete('/posts/{id}',
            name: 'Delete Post',
            tags: ['posts', 'write'],
            responseType: 'void')
        
        // Comments
        .get('/comments',
            name: 'Get All Comments',
            queryParams: ['postId', 'email', '_limit', '_start'],
            tags: ['comments', 'read'],
            responseType: 'List<Comment>')
        .get('/comments/{id}',
            name: 'Get Comment',
            tags: ['comments', 'read'],
            responseType: 'Comment')
        .get('/posts/{id}/comments',
            name: 'Get Post Comments',
            queryParams: ['_limit', '_start'],
            tags: ['posts', 'comments', 'read'],
            responseType: 'List<Comment>')
        .post('/comments',
            name: 'Add Comment',
            tags: ['comments', 'write'],
            responseType: 'Comment')
        .put('/comments/{id}',
            name: 'Update Comment',
            tags: ['comments', 'write'],
            responseType: 'Comment')
        .delete('/comments/{id}',
            name: 'Delete Comment',
            tags: ['comments', 'write'],
            responseType: 'void')
        
        // Users
        .get('/users',
            name: 'Get All Users',
            queryParams: ['_limit', '_start', '_sort', '_order'],
            tags: ['users', 'read'],
            responseType: 'List<User>')
        .get('/users/{id}',
            name: 'Get User Profile',
            tags: ['users', 'read'],
            responseType: 'User')
        .get('/users/{id}/posts',
            name: 'Get User Posts',
            queryParams: ['_limit', '_start'],
            tags: ['users', 'posts', 'read'],
            responseType: 'List<Post>')
        .get('/users/{id}/albums',
            name: 'Get User Albums',
            queryParams: ['_limit', '_start'],
            tags: ['users', 'albums', 'read'],
            responseType: 'List<Album>')
        .get('/users/{id}/todos',
            name: 'Get User Todos',
            queryParams: ['_limit', '_start', 'completed'],
            tags: ['users', 'todos', 'read'],
            responseType: 'List<Todo>')
        
        // Albums & Photos
        .get('/albums',
            name: 'Get All Albums',
            queryParams: ['userId', '_limit', '_start'],
            tags: ['albums', 'read'],
            responseType: 'List<Album>')
        .get('/albums/{id}',
            name: 'Get Album',
            tags: ['albums', 'read'],
            responseType: 'Album')
        .get('/albums/{id}/photos',
            name: 'Get Album Photos',
            queryParams: ['_limit', '_start'],
            tags: ['albums', 'photos', 'read'],
            responseType: 'List<Photo>')
        .get('/photos',
            name: 'Get All Photos',
            queryParams: ['albumId', '_limit', '_start'],
            tags: ['photos', 'read'],
            responseType: 'List<Photo>')
        
        // Todos
        .get('/todos',
            name: 'Get All Todos',
            queryParams: ['userId', 'completed', '_limit', '_start'],
            tags: ['todos', 'read'],
            responseType: 'List<Todo>')
        .get('/todos/{id}',
            name: 'Get Todo',
            tags: ['todos', 'read'],
            responseType: 'Todo')
        
        .build();
  }
  
  /// Returns all sample API definitions.
  static List<ApiDefinition> all() {
    return [
      jsonPlaceholder(),
      postsCrud(),
      usersCrud(),
      ecommerce(),
      socialMedia(),
      openApiPetStore(),
      openApiYamlExample(),
    ];
  }
  
  /// Returns a subset of sample APIs suitable for quick testing.
  static List<ApiDefinition> quickStart() {
    return [
      jsonPlaceholder(),
      postsCrud(),
    ];
  }

  /// Creates an API definition from OpenAPI specification.
  static ApiDefinition openApiPetStore() {
    // Sample OpenAPI spec for Petstore API
    final openApiSpec = {
      "openapi": "3.0.0",
      "info": {
        "title": "Petstore API",
        "description": "Sample API for a pet store (using v3 API)",
        "version": "3.0.0"
      },
      "servers": [
        {
          "url": "https://petstore3.swagger.io/api/v3"
        }
      ],
      "paths": {
        "/pet": {
          "post": {
            "tags": ["pet"],
            "summary": "Add a new pet",
            "description": "Add a new pet to the store",
            "operationId": "addPet",
            "requestBody": {
              "description": "Pet object to be added",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "required": ["name", "photoUrls"],
                    "properties": {
                      "id": {"type": "integer", "format": "int64"},
                      "name": {"type": "string", "example": "doggie"},
                      "category": {
                        "type": "object",
                        "properties": {
                          "id": {"type": "integer", "format": "int64"},
                          "name": {"type": "string"}
                        }
                      },
                      "photoUrls": {
                        "type": "array",
                        "items": {"type": "string"},
                        "example": ["https://example.com/photo1.jpg"]
                      },
                      "tags": {
                        "type": "array",
                        "items": {
                          "type": "object",
                          "properties": {
                            "id": {"type": "integer", "format": "int64"},
                            "name": {"type": "string"}
                          }
                        }
                      },
                      "status": {
                        "type": "string",
                        "description": "pet status in the store",
                        "enum": ["available", "pending", "sold"]
                      }
                    }
                  }
                }
              }
            },
            "responses": {
              "200": {
                "description": "Successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Pet"
                    }
                  }
                }
              },
              "405": {
                "description": "Invalid input"
              }
            }
          },
          "put": {
            "tags": ["pet"],
            "summary": "Update an existing pet",
            "description": "Update an existing pet by Id",
            "operationId": "updatePet",
            "requestBody": {
              "description": "Pet object to be updated",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "\$ref": "#/components/schemas/Pet"
                  }
                }
              }
            },
            "responses": {
              "200": {
                "description": "Successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Pet"
                    }
                  }
                }
              },
              "400": {
                "description": "Invalid ID supplied"
              },
              "404": {
                "description": "Pet not found"
              },
              "405": {
                "description": "Validation exception"
              }
            }
          }
        },
        "/pet/{petId}": {
          "get": {
            "tags": ["pet"],
            "summary": "Find pet by ID",
            "description": "Returns a single pet",
            "operationId": "getPetById",
            "parameters": [
              {
                "name": "petId",
                "in": "path",
                "description": "ID of pet to return",
                "required": true,
                "schema": {
                  "type": "integer",
                  "format": "int64"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Pet"
                    }
                  }
                }
              },
              "400": {
                "description": "Invalid ID supplied"
              },
              "404": {
                "description": "Pet not found"
              }
            }
          },
          "delete": {
            "tags": ["pet"],
            "summary": "Deletes a pet",
            "description": "Deletes a pet by ID",
            "operationId": "deletePet",
            "parameters": [
              {
                "name": "api_key",
                "in": "header",
                "description": "API key for authentication",
                "required": false,
                "schema": {
                  "type": "string"
                }
              },
              {
                "name": "petId",
                "in": "path",
                "description": "Pet id to delete",
                "required": true,
                "schema": {
                  "type": "integer",
                  "format": "int64"
                }
              }
            ],
            "responses": {
              "400": {
                "description": "Invalid pet value"
              }
            }
          }
        },
        "/pet/findByStatus": {
          "get": {
            "tags": ["pet"],
            "summary": "Finds Pets by status",
            "description": "Multiple status values can be provided with comma separated strings",
            "operationId": "findPetsByStatus",
            "parameters": [
              {
                "name": "status",
                "in": "query",
                "description": "Status values that need to be considered for filter",
                "required": false,
                "explode": true,
                "schema": {
                  "type": "string",
                  "default": "available",
                  "enum": ["available", "pending", "sold"]
                }
              }
            ],
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "\$ref": "#/components/schemas/Pet"
                      }
                    }
                  }
                }
              },
              "400": {
                "description": "Invalid status value"
              }
            }
          }
        },
        "/pet/findByTags": {
          "get": {
            "tags": ["pet"],
            "summary": "Finds Pets by tags",
            "description": "Multiple tags can be provided with comma separated strings",
            "operationId": "findPetsByTags",
            "parameters": [
              {
                "name": "tags",
                "in": "query",
                "description": "Tags to filter by",
                "required": false,
                "explode": true,
                "schema": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                }
              }
            ],
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "\$ref": "#/components/schemas/Pet"
                      }
                    }
                  }
                }
              },
              "400": {
                "description": "Invalid tag value"
              }
            }
          }
        },
        "/store/order": {
          "post": {
            "tags": ["store"],
            "summary": "Place an order",
            "description": "Place a new order in the store",
            "operationId": "placeOrder",
            "requestBody": {
              "description": "Order object",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "id": {"type": "integer", "format": "int64"},
                      "petId": {"type": "integer", "format": "int64"},
                      "quantity": {"type": "integer", "format": "int32"},
                      "shipDate": {"type": "string", "format": "date-time"},
                      "status": {
                        "type": "string",
                        "description": "Order Status",
                        "enum": ["placed", "approved", "delivered"]
                      },
                      "complete": {"type": "boolean"}
                    }
                  }
                }
              }
            },
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Order"
                    }
                  }
                }
              },
              "405": {
                "description": "Invalid input"
              }
            }
          }
        },
        "/store/order/{orderId}": {
          "get": {
            "tags": ["store"],
            "summary": "Find order by ID",
            "description": "Find purchase order by ID",
            "operationId": "getOrderById",
            "parameters": [
              {
                "name": "orderId",
                "in": "path",
                "description": "ID of order to return",
                "required": true,
                "schema": {
                  "type": "integer",
                  "format": "int64"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Order"
                    }
                  }
                }
              },
              "400": {
                "description": "Invalid ID supplied"
              },
              "404": {
                "description": "Order not found"
              }
            }
          },
          "delete": {
            "tags": ["store"],
            "summary": "Delete order by ID",
            "description": "Delete purchase order by ID",
            "operationId": "deleteOrder",
            "parameters": [
              {
                "name": "orderId",
                "in": "path",
                "description": "ID of the order to delete",
                "required": true,
                "schema": {
                  "type": "integer",
                  "format": "int64"
                }
              }
            ],
            "responses": {
              "400": {
                "description": "Invalid ID supplied"
              },
              "404": {
                "description": "Order not found"
              }
            }
          }
        },
        "/store/inventory": {
          "get": {
            "tags": ["store"],
            "summary": "Returns pet inventories by status",
            "description": "Returns a map of status codes to quantities",
            "operationId": "getInventory",
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "object",
                      "additionalProperties": {
                        "type": "integer",
                        "format": "int32"
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "/user": {
          "post": {
            "tags": ["user"],
            "summary": "Create user",
            "description": "This can only be done by the logged in user",
            "operationId": "createUser",
            "requestBody": {
              "description": "Created user object",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "id": {"type": "integer", "format": "int64"},
                      "username": {"type": "string"},
                      "firstName": {"type": "string"},
                      "lastName": {"type": "string"},
                      "email": {"type": "string"},
                      "password": {"type": "string"},
                      "phone": {"type": "string"},
                      "userStatus": {"type": "integer", "format": "int32"}
                    }
                  }
                }
              }
            },
            "responses": {
              "default": {
                "description": "successful operation"
              }
            }
          }
        },
        "/user/{username}": {
          "get": {
            "tags": ["user"],
            "summary": "Get user by username",
            "description": "Get user by username",
            "operationId": "getUserByName",
            "parameters": [
              {
                "name": "username",
                "in": "path",
                "description": "The name that needs to be fetched",
                "required": true,
                "schema": {
                  "type": "string"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "successful operation",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/User"
                    }
                  }
                }
              },
              "400": {
                "description": "Invalid username supplied"
              },
              "404": {
                "description": "User not found"
              }
            }
          }
        }
      }
    };

    // Convert using OpenApiLoader
    return OpenApiLoader.fromMap(openApiSpec) ?? _fallbackPetStoreApi();
  }

  /// Fallback PetStore API definition in case OpenAPI parsing fails.
  static ApiDefinition _fallbackPetStoreApi() {
    return SimpleApiBuilder(
      title: 'Petstore API (Fallback)',
      baseUrl: 'https://petstore3.swagger.io/api/v3',
      description: 'Sample API for a pet store',
    )
        .get('/pet/findByStatus', 
            name: 'Find Pets by Status',
            queryParams: ['status'],
            tags: ['pet'],
            responseType: 'List<Pet>')
        .get('/pet/findByTags', 
            name: 'Find Pets by Tags',
            queryParams: ['tags'],
            tags: ['pet'],
            responseType: 'List<Pet>')
        .get('/pet/{petId}', 
            name: 'Get Pet by ID',
            tags: ['pet'],
            responseType: 'Pet')
        .post('/pet', 
            name: 'Add Pet',
            tags: ['pet'],
            responseType: 'Pet')
        .put('/pet', 
            name: 'Update Pet',
            tags: ['pet'],
            responseType: 'Pet')
        .delete('/pet/{petId}', 
            name: 'Delete Pet',
            headerParams: ['api_key'],
            tags: ['pet'])
        .get('/store/inventory',
            name: 'Get Store Inventory',
            tags: ['store'],
            responseType: 'Map<String, int>')
        .get('/store/order/{orderId}', 
            name: 'Get Order by ID',
            tags: ['store'],
            responseType: 'Order')
        .post('/store/order', 
            name: 'Place Order',
            tags: ['store'],
            responseType: 'Order')
        .delete('/store/order/{orderId}',
            name: 'Delete Order',
            tags: ['store'])
        .post('/user', 
            name: 'Create User',
            tags: ['user'])
        .get('/user/{username}', 
            name: 'Get User by Username',
            tags: ['user'],
            responseType: 'User')
        .build();
  }

  /// Creates an API definition from YAML format OpenAPI specification.
  static ApiDefinition openApiYamlExample() {
    // Sample OpenAPI spec in YAML format (as string)
    const openApiYaml = '''
openapi: 3.0.0
info:
  title: Books API
  description: A simple books management API (YAML format example)
  version: 1.0.0
servers:
  - url: https://openlibrary.org/api
paths:
  /books:
    get:
      tags:
        - books
      summary: Search for books
      description: Search for books using Open Library API
      parameters:
        - name: q
          in: query
          description: Search query (title, author, ISBN)
          required: true
          schema:
            type: string
        - name: title
          in: query
          description: Filter by title
          required: false
          schema:
            type: string
        - name: author
          in: query
          description: Filter by author name
          required: false
          schema:
            type: string
        - name: subject
          in: query
          description: Filter by subject/genre
          required: false
          schema:
            type: string
        - name: limit
          in: query
          description: Maximum number of books to return
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        - name: offset
          in: query
          description: Number of results to skip
          required: false
          schema:
            type: integer
            minimum: 0
            default: 0
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  numFound:
                    type: integer
                  start:
                    type: integer
                  docs:
                    type: array
                    items:
                      type: object
                      properties:
                        key:
                          type: string
                        title:
                          type: string
                        author_name:
                          type: array
                          items:
                            type: string
                        first_publish_year:
                          type: integer
                        isbn:
                          type: array
                          items:
                            type: string
  /works/{id}.json:
    get:
      tags:
        - books
      summary: Get book details
      description: Get detailed information about a specific work
      parameters:
        - name: id
          in: path
          description: Work ID (e.g., OL45804W)
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  title:
                    type: string
                  description:
                    type: string
                  subjects:
                    type: array
                    items:
                      type: string
                  authors:
                    type: array
                    items:
                      type: object
                      properties:
                        author:
                          type: object
                          properties:
                            key:
                              type: string
                        type:
                          type: object
                          properties:
                            key:
                              type: string
        '404':
          description: Work not found
  /authors/{id}.json:
    get:
      tags:
        - authors
      summary: Get author details
      description: Get information about a specific author
      parameters:
        - name: id
          in: path
          description: Author ID (e.g., OL23919A)
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  name:
                    type: string
                  bio:
                    type: string
                  birth_date:
                    type: string
                  death_date:
                    type: string
                  alternate_names:
                    type: array
                    items:
                      type: string
        '404':
          description: Author not found
  /isbn/{isbn}.json:
    get:
      tags:
        - books
      summary: Get book by ISBN
      description: Get book information by ISBN
      parameters:
        - name: isbn
          in: path
          description: ISBN-10 or ISBN-13
          required: true
          schema:
            type: string
            pattern: '^(97(8|9))?\\\\d{9}(\\\\d|X)\$'
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
        '404':
          description: ISBN not found
  /subjects/{subject}.json:
    get:
      tags:
        - subjects
      summary: Get books by subject
      description: Get a list of works for a given subject
      parameters:
        - name: subject
          in: path
          description: Subject name (e.g., science_fiction, love)
          required: true
          schema:
            type: string
        - name: limit
          in: query
          description: Number of results to return
          required: false
          schema:
            type: integer
            default: 20
        - name: offset
          in: query
          description: Number of results to skip
          required: false
          schema:
            type: integer
            default: 0
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  subject_type:
                    type: string
                  name:
                    type: string
                  work_count:
                    type: integer
                  works:
                    type: array
                    items:
                      type: object
''';

    // Convert YAML to ApiDefinition
    return OpenApiLoader.fromYamlString(openApiYaml, baseUrl: 'https://openlibrary.org/api') ?? _fallbackBooksApi();
  }

  /// Fallback Books API definition in case YAML parsing fails.
  static ApiDefinition _fallbackBooksApi() {
    return SimpleApiBuilder(
      title: 'Open Library API (Fallback)',
      baseUrl: 'https://openlibrary.org/api',
      description: 'Open Library book search and information API',
    )
        .get('/books', 
            name: 'Search Books',
            queryParams: ['q', 'title', 'author', 'subject', 'limit', 'offset'],
            tags: ['books'],
            responseType: 'BookSearchResponse')
        .get('/works/{id}.json', 
            name: 'Get Book Details',
            tags: ['books'],
            responseType: 'Work')
        .get('/authors/{id}.json', 
            name: 'Get Author Details',
            tags: ['authors'],
            responseType: 'Author')
        .get('/isbn/{isbn}.json', 
            name: 'Get Book by ISBN',
            tags: ['books'],
            responseType: 'Book')
        .get('/subjects/{subject}.json', 
            name: 'Get Books by Subject',
            queryParams: ['limit', 'offset'],
            tags: ['subjects'],
            responseType: 'SubjectResponse')
        .build();
  }
}