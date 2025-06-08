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
      baseUrl: 'https://jsonplaceholder.typicode.com',
      description: 'E-commerce API using JSONPlaceholder endpoints for testing',
    )
        // Posts as "Products"
        .get('/posts',
            name: 'Get Products',
            queryParams: ['userId', '_limit', '_start'],
            tags: ['products', 'read'],
            responseType: 'List<Product>')
        .get('/posts/{id}',
            name: 'Get Product Details',
            tags: ['products', 'read'],
            responseType: 'Product')
        .post('/posts',
            name: 'Create Product',
            tags: ['products', 'write'],
            responseType: 'Product')
        .put('/posts/{id}',
            name: 'Update Product',
            tags: ['products', 'write'],
            responseType: 'Product')
        .delete('/posts/{id}',
            name: 'Delete Product',
            tags: ['products', 'write'],
            responseType: 'Product')
        
        // Albums as "Categories"
        .get('/albums',
            name: 'Get Categories',
            queryParams: ['userId', '_limit'],
            tags: ['categories', 'read'],
            responseType: 'List<Category>')
        .get('/albums/{id}',
            name: 'Get Category Details',
            tags: ['categories', 'read'],
            responseType: 'Category')
        .get('/albums/{id}/photos',
            name: 'Get Category Items',
            queryParams: ['_limit', '_start'],
            tags: ['categories', 'photos', 'read'],
            responseType: 'List<Photo>')
        
        // Todos as "Orders/Carts"
        .get('/todos',
            name: 'Get All Orders',
            queryParams: ['userId', 'completed', '_limit', '_start'],
            tags: ['orders', 'read'],
            responseType: 'List<Order>')
        .get('/todos/{id}',
            name: 'Get Order Details',
            tags: ['orders', 'read'],
            responseType: 'Order')
        .post('/todos',
            name: 'Create Order',
            tags: ['orders', 'write'],
            responseType: 'Order')
        .put('/todos/{id}',
            name: 'Update Order',
            tags: ['orders', 'write'],
            responseType: 'Order')
        .delete('/todos/{id}',
            name: 'Delete Order',
            tags: ['orders', 'write'],
            responseType: 'Order')
        
        // Users
        .get('/users',
            name: 'Get All Users',
            queryParams: ['_limit', '_start'],
            tags: ['users', 'read'],
            responseType: 'List<User>')
        .get('/users/{id}',
            name: 'Get User Details',
            tags: ['users', 'read'],
            responseType: 'User')
        .get('/users/{id}/posts',
            name: 'Get User Products',
            queryParams: ['_limit', '_start'],
            tags: ['users', 'products', 'read'],
            responseType: 'List<Product>')
        .get('/users/{id}/albums',
            name: 'Get User Categories',
            queryParams: ['_limit', '_start'],
            tags: ['users', 'categories', 'read'],
            responseType: 'List<Category>')
        .get('/users/{id}/todos',
            name: 'Get User Orders',
            queryParams: ['_limit', '_start', 'completed'],
            tags: ['users', 'orders', 'read'],
            responseType: 'List<Order>')
        
        // Comments as "Reviews"
        .get('/comments',
            name: 'Get Product Reviews',
            queryParams: ['postId', '_limit'],
            tags: ['reviews', 'read'],
            responseType: 'List<Review>')
        .get('/comments/{id}',
            name: 'Get Review Details',
            tags: ['reviews', 'read'],
            responseType: 'Review')
        .get('/posts/{id}/comments',
            name: 'Get Reviews for Product',
            queryParams: ['_limit', '_start'],
            tags: ['products', 'reviews', 'read'],
            responseType: 'List<Review>')
        
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
    // Sample OpenAPI spec for JSONPlaceholder API
    final openApiSpec = {
      "openapi": "3.0.0",
      "info": {
        "title": "JSONPlaceholder API",
        "description": "A simple REST API for testing and prototyping (JSON format example)",
        "version": "1.0.0"
      },
      "servers": [
        {
          "url": "https://jsonplaceholder.typicode.com"
        }
      ],
      "paths": {
        "/posts": {
          "get": {
            "tags": ["posts", "read"],
            "summary": "Get All Posts",
            "description": "Retrieve all posts",
            "operationId": "getAllPosts",
            "parameters": [
              {
                "name": "userId",
                "in": "query",
                "description": "Filter by user ID",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              },
              {
                "name": "_limit",
                "in": "query",
                "description": "Maximum number of posts to return",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              },
              {
                "name": "_start",
                "in": "query",
                "description": "Number of results to skip",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Successful response",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "userId": {"type": "integer"},
                          "id": {"type": "integer"},
                          "title": {"type": "string"},
                          "body": {"type": "string"}
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "post": {
            "tags": ["posts", "write"],
            "summary": "Create Post",
            "description": "Create a new post",
            "operationId": "createPost",
            "requestBody": {
              "description": "Post object to be created",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "title": {"type": "string"},
                      "body": {"type": "string"},
                      "userId": {"type": "integer"}
                    }
                  }
                }
              }
            },
            "responses": {
              "201": {
                "description": "Post created successfully",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "object",
                      "properties": {
                        "id": {"type": "integer"},
                        "title": {"type": "string"},
                        "body": {"type": "string"},
                        "userId": {"type": "integer"}
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "/posts/{id}": {
          "get": {
            "tags": ["posts", "read"],
            "summary": "Get Post by ID",
            "description": "Retrieve a specific post",
            "operationId": "getPostById",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "Post ID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Successful response",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "object",
                      "properties": {
                        "userId": {"type": "integer"},
                        "id": {"type": "integer"},
                        "title": {"type": "string"},
                        "body": {"type": "string"}
                      }
                    }
                  }
                }
              },
              "404": {
                "description": "Post not found"
              }
            }
          },
          "put": {
            "tags": ["posts", "write"],
            "summary": "Update Post",
            "description": "Update an existing post",
            "operationId": "updatePost",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "Post ID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "requestBody": {
              "description": "Post object to be updated",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "title": {"type": "string"},
                      "body": {"type": "string"},
                      "userId": {"type": "integer"}
                    }
                  }
                }
              }
            },
            "responses": {
              "200": {
                "description": "Post updated successfully",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "object",
                      "properties": {
                        "userId": {"type": "integer"},
                        "id": {"type": "integer"},
                        "title": {"type": "string"},
                        "body": {"type": "string"}
                      }
                    }
                  }
                }
              }
            }
          },
          "delete": {
            "tags": ["posts", "write"],
            "summary": "Delete Post",
            "description": "Delete a post",
            "operationId": "deletePost",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "Post ID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Post deleted successfully"
              }
            }
          }
        },
        "/users": {
          "get": {
            "tags": ["users", "read"],
            "summary": "Get All Users",
            "description": "Retrieve all users",
            "operationId": "getAllUsers",
            "responses": {
              "200": {
                "description": "Successful response",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "id": {"type": "integer"},
                          "name": {"type": "string"},
                          "username": {"type": "string"},
                          "email": {"type": "string"},
                          "address": {"type": "object"},
                          "phone": {"type": "string"},
                          "website": {"type": "string"},
                          "company": {"type": "object"}
                        }
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
            "tags": ["users", "read"],
            "summary": "Get User by ID",
            "description": "Retrieve a specific user",
            "operationId": "getUserById",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "User ID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Successful response",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "object",
                      "properties": {
                        "id": {"type": "integer"},
                        "name": {"type": "string"},
                        "username": {"type": "string"},
                        "email": {"type": "string"},
                        "address": {"type": "object"},
                        "phone": {"type": "string"},
                        "website": {"type": "string"},
                        "company": {"type": "object"}
                      }
                    }
                  }
                }
              },
              "404": {
                "description": "User not found"
              }
            }
          }
        },
        "/comments": {
          "get": {
            "tags": ["comments", "read"],
            "summary": "Get Comments",
            "description": "Retrieve comments",
            "operationId": "getComments",
            "parameters": [
              {
                "name": "postId",
                "in": "query",
                "description": "Filter by post ID",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              },
              {
                "name": "_limit",
                "in": "query",
                "description": "Number of comments to return",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Successful response",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "postId": {"type": "integer"},
                          "id": {"type": "integer"},
                          "name": {"type": "string"},
                          "email": {"type": "string"},
                          "body": {"type": "string"}
                        }
                      }
                    }
                  }
                }
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
      baseUrl: 'https://jsonplaceholder.typicode.com',
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
  title: JSONPlaceholder API
  description: A simple REST API for testing and prototyping (YAML format example)
  version: 1.0.0
servers:
  - url: https://jsonplaceholder.typicode.com
paths:
  /posts:
    get:
      tags:
        - posts
        - read
      summary: Get All Posts
      description: Retrieve all posts
      parameters:
        - name: userId
          in: query
          description: Filter by user ID
          required: false
          schema:
            type: integer
        - name: _limit
          in: query
          description: Maximum number of posts to return
          required: false
          schema:
            type: integer
        - name: _start
          in: query
          description: Number of results to skip
          required: false
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    userId:
                      type: integer
                    id:
                      type: integer
                    title:
                      type: string
                    body:
                      type: string
    post:
      tags:
        - posts
        - write
      summary: Create Post
      description: Create a new post
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                title:
                  type: string
                body:
                  type: string
                userId:
                  type: integer
      responses:
        '201':
          description: Post created successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: integer
                  title:
                    type: string
                  body:
                    type: string
                  userId:
                    type: integer
  /posts/{id}:
    get:
      tags:
        - posts
        - read
      summary: Get Post by ID
      description: Retrieve a specific post
      parameters:
        - name: id
          in: path
          description: Post ID
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  userId:
                    type: integer
                  id:
                    type: integer
                  title:
                    type: string
                  body:
                    type: string
        '404':
          description: Post not found
    put:
      tags:
        - posts
        - write
      summary: Update Post
      description: Update an existing post
      parameters:
        - name: id
          in: path
          description: Post ID
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                title:
                  type: string
                body:
                  type: string
                userId:
                  type: integer
      responses:
        '200':
          description: Post updated successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  userId:
                    type: integer
                  id:
                    type: integer
                  title:
                    type: string
                  body:
                    type: string
    delete:
      tags:
        - posts
        - write
      summary: Delete Post
      description: Delete a post
      parameters:
        - name: id
          in: path
          description: Post ID
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Post deleted successfully
  /users:
    get:
      tags:
        - users
        - read
      summary: Get All Users
      description: Retrieve all users
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: integer
                    name:
                      type: string
                    username:
                      type: string
                    email:
                      type: string
                    address:
                      type: object
                    phone:
                      type: string
                    website:
                      type: string
                    company:
                      type: object
  /users/{id}:
    get:
      tags:
        - users
        - read
      summary: Get User by ID
      description: Retrieve a specific user
      parameters:
        - name: id
          in: path
          description: User ID
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: integer
                  name:
                    type: string
                  username:
                    type: string
                  email:
                    type: string
                  address:
                    type: object
                  phone:
                    type: string
                  website:
                    type: string
                  company:
                    type: object
        '404':
          description: User not found
  /comments:
    get:
      tags:
        - comments
        - read
      summary: Get Comments
      description: Retrieve comments
      parameters:
        - name: postId
          in: query
          description: Filter by post ID
          required: false
          schema:
            type: integer
        - name: _limit
          in: query
          description: Number of comments to return
          required: false
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    postId:
                      type: integer
                    id:
                      type: integer
                    name:
                      type: string
                    email:
                      type: string
                    body:
                      type: string
''';

    // Convert YAML to ApiDefinition
    return OpenApiLoader.fromYamlString(openApiYaml, baseUrl: 'https://jsonplaceholder.typicode.com') ?? _fallbackBooksApi();
  }

  /// Fallback JSONPlaceholder API definition in case YAML parsing fails.
  static ApiDefinition _fallbackBooksApi() {
    return SimpleApiBuilder(
      title: 'JSONPlaceholder API (Fallback)',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      description: 'Fake online REST API for testing and prototyping',
    )
        .get('/posts', 
            name: 'Get All Posts',
            queryParams: ['userId', '_limit', '_start'],
            tags: ['posts'],
            responseType: 'List<Post>')
        .get('/posts/{id}', 
            name: 'Get Post by ID',
            tags: ['posts'],
            responseType: 'Post')
        .post('/posts', 
            name: 'Create Post',
            tags: ['posts'],
            responseType: 'Post')
        .put('/posts/{id}', 
            name: 'Update Post',
            tags: ['posts'],
            responseType: 'Post')
        .delete('/posts/{id}', 
            name: 'Delete Post',
            tags: ['posts'])
        .get('/users', 
            name: 'Get All Users',
            queryParams: ['_limit'],
            tags: ['users'],
            responseType: 'List<User>')
        .get('/users/{id}', 
            name: 'Get User by ID',
            tags: ['users'],
            responseType: 'User')
        .get('/comments', 
            name: 'Get Comments',
            queryParams: ['postId', '_limit'],
            tags: ['comments'],
            responseType: 'List<Comment>')
        .build();
  }
}