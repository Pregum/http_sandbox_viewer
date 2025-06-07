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
      baseUrl: 'https://api.example.com',
      resource: 'posts',
      description: 'Complete CRUD operations for blog posts',
      listQueryParams: ['author', 'category', 'published'],
      includeSearch: true,
    ).build();
  }
  
  /// Creates a CRUD API for users.
  static ApiDefinition usersCrud() {
    return SimpleApiBuilder.crud(
      title: 'Users CRUD API',
      baseUrl: 'https://api.example.com',
      resource: 'users',
      description: 'User management API',
      listQueryParams: ['role', 'status', 'department'],
      includeSearch: true,
    ).build();
  }
  
  /// Creates a comprehensive e-commerce API definition.
  static ApiDefinition ecommerce() {
    return SimpleApiBuilder(
      title: 'E-commerce API',
      baseUrl: 'https://shop.example.com/api',
      description: 'Comprehensive e-commerce API with products, orders, and user management',
    )
        // Products
        .get('/products',
            name: 'Get Products',
            queryParams: ['category', 'price_min', 'price_max', 'search', '_limit', '_offset'],
            tags: ['products', 'read'],
            responseType: 'List<Product>')
        .get('/products/{id}',
            name: 'Get Product Details',
            tags: ['products', 'read'],
            responseType: 'Product')
        .get('/products/{id}/reviews',
            name: 'Get Product Reviews',
            queryParams: ['rating', '_limit'],
            tags: ['products', 'reviews', 'read'],
            responseType: 'List<Review>')
        
        // Categories
        .get('/categories',
            name: 'Get Categories',
            tags: ['categories', 'read'],
            responseType: 'List<Category>')
        .get('/categories/{id}/products',
            name: 'Get Products by Category',
            queryParams: ['sort', '_limit'],
            tags: ['categories', 'products', 'read'],
            responseType: 'List<Product>')
        
        // Orders
        .get('/orders',
            name: 'Get Orders',
            queryParams: ['status', 'user_id', 'date_from', 'date_to'],
            headerParams: ['Authorization'],
            tags: ['orders', 'read'],
            responseType: 'List<Order>')
        .get('/orders/{id}',
            name: 'Get Order Details',
            headerParams: ['Authorization'],
            tags: ['orders', 'read'],
            responseType: 'Order')
        .post('/orders',
            name: 'Create Order',
            headerParams: ['Authorization'],
            tags: ['orders', 'write'],
            responseType: 'Order')
        .put('/orders/{id}',
            name: 'Update Order',
            headerParams: ['Authorization'],
            tags: ['orders', 'write'],
            responseType: 'Order')
        
        // Cart
        .get('/cart',
            name: 'Get Cart',
            headerParams: ['Authorization'],
            tags: ['cart', 'read'],
            responseType: 'Cart')
        .post('/cart/items',
            name: 'Add to Cart',
            headerParams: ['Authorization'],
            tags: ['cart', 'write'],
            responseType: 'CartItem')
        .put('/cart/items/{id}',
            name: 'Update Cart Item',
            headerParams: ['Authorization'],
            tags: ['cart', 'write'],
            responseType: 'CartItem')
        .delete('/cart/items/{id}',
            name: 'Remove from Cart',
            headerParams: ['Authorization'],
            tags: ['cart', 'write'],
            responseType: 'void')
        
        // User Profile
        .get('/profile',
            name: 'Get User Profile',
            headerParams: ['Authorization'],
            tags: ['user', 'read'],
            responseType: 'User')
        .put('/profile',
            name: 'Update Profile',
            headerParams: ['Authorization'],
            tags: ['user', 'write'],
            responseType: 'User')
        .get('/profile/addresses',
            name: 'Get User Addresses',
            headerParams: ['Authorization'],
            tags: ['user', 'addresses', 'read'],
            responseType: 'List<Address>')
        .post('/profile/addresses',
            name: 'Add Address',
            headerParams: ['Authorization'],
            tags: ['user', 'addresses', 'write'],
            responseType: 'Address')
        
        .build();
  }
  
  /// Creates a social media API definition.
  static ApiDefinition socialMedia() {
    return SimpleApiBuilder(
      title: 'Social Media API',
      baseUrl: 'https://social.example.com/api',
      description: 'Social media platform API for posts, likes, and follows',
    )
        // Timeline
        .get('/timeline',
            name: 'Get Timeline',
            queryParams: ['_limit', '_offset'],
            headerParams: ['Authorization'],
            tags: ['timeline', 'read'],
            responseType: 'List<Post>')
        .get('/timeline/trending',
            name: 'Get Trending Posts',
            queryParams: ['period', '_limit'],
            tags: ['timeline', 'trending', 'read'],
            responseType: 'List<Post>')
        
        // Posts
        .get('/posts/{id}',
            name: 'Get Post',
            tags: ['posts', 'read'],
            responseType: 'Post')
        .post('/posts',
            name: 'Create Post',
            headerParams: ['Authorization'],
            tags: ['posts', 'write'],
            responseType: 'Post')
        .put('/posts/{id}',
            name: 'Update Post',
            headerParams: ['Authorization'],
            tags: ['posts', 'write'],
            responseType: 'Post')
        .delete('/posts/{id}',
            name: 'Delete Post',
            headerParams: ['Authorization'],
            tags: ['posts', 'write'],
            responseType: 'void')
        
        // Interactions
        .post('/posts/{id}/like',
            name: 'Like Post',
            headerParams: ['Authorization'],
            hasBody: false,
            tags: ['posts', 'interactions', 'write'],
            responseType: 'void')
        .delete('/posts/{id}/like',
            name: 'Unlike Post',
            headerParams: ['Authorization'],
            tags: ['posts', 'interactions', 'write'],
            responseType: 'void')
        .get('/posts/{id}/comments',
            name: 'Get Comments',
            queryParams: ['_limit', '_offset'],
            tags: ['posts', 'comments', 'read'],
            responseType: 'List<Comment>')
        .post('/posts/{id}/comments',
            name: 'Add Comment',
            headerParams: ['Authorization'],
            tags: ['posts', 'comments', 'write'],
            responseType: 'Comment')
        
        // Users and Follows
        .get('/users/{id}',
            name: 'Get User Profile',
            tags: ['users', 'read'],
            responseType: 'User')
        .get('/users/{id}/posts',
            name: 'Get User Posts',
            queryParams: ['_limit', '_offset'],
            tags: ['users', 'posts', 'read'],
            responseType: 'List<Post>')
        .post('/users/{id}/follow',
            name: 'Follow User',
            headerParams: ['Authorization'],
            hasBody: false,
            tags: ['users', 'follows', 'write'],
            responseType: 'void')
        .delete('/users/{id}/follow',
            name: 'Unfollow User',
            headerParams: ['Authorization'],
            tags: ['users', 'follows', 'write'],
            responseType: 'void')
        .get('/users/{id}/followers',
            name: 'Get Followers',
            queryParams: ['_limit', '_offset'],
            tags: ['users', 'followers', 'read'],
            responseType: 'List<User>')
        .get('/users/{id}/following',
            name: 'Get Following',
            queryParams: ['_limit', '_offset'],
            tags: ['users', 'following', 'read'],
            responseType: 'List<User>')
        
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
        "description": "Sample API for a pet store",
        "version": "1.0.0"
      },
      "servers": [
        {
          "url": "https://petstore.swagger.io/v2"
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
              "required": true
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
              "required": true
            },
            "responses": {
              "200": {
                "description": "Successful operation"
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
            "description": "Multiple status values can be provided",
            "operationId": "findPetsByStatus",
            "parameters": [
              {
                "name": "status",
                "in": "query",
                "description": "Status values to filter by",
                "required": false,
                "schema": {
                  "type": "string",
                  "enum": ["available", "pending", "sold"],
                  "default": "available"
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
              "required": true
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
              }
            }
          }
        },
        "/user": {
          "post": {
            "tags": ["user"],
            "summary": "Create user",
            "description": "Create a new user account",
            "operationId": "createUser",
            "requestBody": {
              "description": "User object to be created",
              "required": true
            },
            "responses": {
              "default": {
                "description": "successful operation"
              }
            }
          }
        },
        "/user/login": {
          "get": {
            "tags": ["user"],
            "summary": "Logs user into the system",
            "description": "User authentication endpoint",
            "operationId": "loginUser",
            "parameters": [
              {
                "name": "username",
                "in": "query",
                "description": "The username for login",
                "required": false,
                "schema": {
                  "type": "string"
                }
              },
              {
                "name": "password",
                "in": "query",
                "description": "The password for login",
                "required": false,
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
                      "type": "string"
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
      baseUrl: 'https://petstore.swagger.io/v2',
      description: 'Sample API for a pet store',
    )
        .get('/pet/findByStatus', 
            name: 'Find Pets by Status',
            queryParams: ['status'],
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
        .get('/store/order/{orderId}', 
            name: 'Get Order by ID',
            tags: ['store'],
            responseType: 'Order')
        .post('/store/order', 
            name: 'Place Order',
            tags: ['store'],
            responseType: 'Order')
        .post('/user', 
            name: 'Create User',
            tags: ['user'])
        .get('/user/login', 
            name: 'User Login',
            queryParams: ['username', 'password'],
            tags: ['user'],
            responseType: 'String')
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
  - url: https://api.bookstore.com/v1
paths:
  /books:
    get:
      tags:
        - books
      summary: Get all books
      description: Retrieve a list of all books
      parameters:
        - name: author
          in: query
          description: Filter by author name
          required: false
          schema:
            type: string
        - name: genre
          in: query
          description: Filter by genre
          required: false
          schema:
            type: string
            enum:
              - fiction
              - non-fiction
              - mystery
              - romance
              - sci-fi
        - name: limit
          in: query
          description: Maximum number of books to return
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  \$ref: '#/components/schemas/Book'
    post:
      tags:
        - books
      summary: Create a new book
      description: Add a new book to the collection
      requestBody:
        description: Book object to be created
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/Book'
      responses:
        '201':
          description: Book created successfully
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Book'
  /books/{id}:
    get:
      tags:
        - books
      summary: Get book by ID
      description: Retrieve a specific book by its ID
      parameters:
        - name: id
          in: path
          description: Book ID
          required: true
          schema:
            type: integer
            format: int64
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Book'
        '404':
          description: Book not found
    put:
      tags:
        - books
      summary: Update book
      description: Update an existing book
      parameters:
        - name: id
          in: path
          description: Book ID
          required: true
          schema:
            type: integer
            format: int64
      requestBody:
        description: Updated book object
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/Book'
      responses:
        '200':
          description: Book updated successfully
        '404':
          description: Book not found
    delete:
      tags:
        - books
      summary: Delete book
      description: Delete a book from the collection
      parameters:
        - name: id
          in: path
          description: Book ID
          required: true
          schema:
            type: integer
            format: int64
      responses:
        '204':
          description: Book deleted successfully
        '404':
          description: Book not found
  /authors:
    get:
      tags:
        - authors
      summary: Get all authors
      description: Retrieve a list of all authors
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  \$ref: '#/components/schemas/Author'
  /authors/{id}:
    get:
      tags:
        - authors
      summary: Get author by ID
      description: Retrieve a specific author by their ID
      parameters:
        - name: id
          in: path
          description: Author ID
          required: true
          schema:
            type: integer
            format: int64
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Author'
        '404':
          description: Author not found
components:
  schemas:
    Book:
      type: object
      properties:
        id:
          type: integer
          format: int64
        title:
          type: string
        author:
          type: string
        isbn:
          type: string
        genre:
          type: string
        publishedDate:
          type: string
          format: date
        price:
          type: number
          format: double
    Author:
      type: object
      properties:
        id:
          type: integer
          format: int64
        name:
          type: string
        biography:
          type: string
        birthDate:
          type: string
          format: date
''';

    // Convert YAML to ApiDefinition
    return OpenApiLoader.fromYamlString(openApiYaml) ?? _fallbackBooksApi();
  }

  /// Fallback Books API definition in case YAML parsing fails.
  static ApiDefinition _fallbackBooksApi() {
    return SimpleApiBuilder(
      title: 'Books API (Fallback)',
      baseUrl: 'https://api.bookstore.com/v1',
      description: 'A simple books management API',
    )
        .get('/books', 
            name: 'Get All Books',
            queryParams: ['author', 'genre', 'limit'],
            tags: ['books'],
            responseType: 'List<Book>')
        .get('/books/{id}', 
            name: 'Get Book by ID',
            tags: ['books'],
            responseType: 'Book')
        .post('/books', 
            name: 'Create Book',
            tags: ['books'],
            responseType: 'Book')
        .put('/books/{id}', 
            name: 'Update Book',
            tags: ['books'],
            responseType: 'Book')
        .delete('/books/{id}', 
            name: 'Delete Book',
            tags: ['books'])
        .get('/authors', 
            name: 'Get All Authors',
            tags: ['authors'],
            responseType: 'List<Author>')
        .get('/authors/{id}', 
            name: 'Get Author by ID',
            tags: ['authors'],
            responseType: 'Author')
        .build();
  }
}