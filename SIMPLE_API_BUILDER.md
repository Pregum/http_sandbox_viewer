# Simple API Builder

The `SimpleApiBuilder` provides a much more concise way to define API definitions compared to the verbose manual approach.

## Basic Usage

### Traditional Verbose Approach (Before)
```dart
final apiDefinitions = [
  ApiDefinitionBuilder.fromRetrofitService(
    serviceName: 'Posts API',
    baseUrl: 'https://jsonplaceholder.typicode.com',
    description: 'Posts management API',
    endpoints: [
      ApiDefinitionBuilder.endpoint(
        name: 'Get All Posts',
        path: '/posts',
        method: HttpMethod.get,
        description: 'Retrieve all posts from the API',
        summary: 'Fetch a list of all available posts',
        tags: ['posts', 'read'],
        parameters: [
          ApiDefinitionBuilder.queryParam(
            'userId',
            dataType: int,
            description: 'Filter posts by user ID',
          ),
          ApiDefinitionBuilder.queryParam(
            '_limit',
            dataType: int,
            description: 'Limit the number of results',
            defaultValue: 10,
          ),
        ],
        responseType: 'List<Post>',
      ),
      // ... many more verbose endpoint definitions
    ],
  ),
];
```

### New Simple Approach (After)
```dart
final apiDefinitions = [
  SimpleApiBuilder(
    title: 'Posts API',
    baseUrl: 'https://jsonplaceholder.typicode.com',
    description: 'Posts management API',
  )
      .get('/posts', 
          name: 'Get All Posts',
          queryParams: ['userId', '_limit'],
          tags: ['posts', 'read'],
          responseType: 'List<Post>')
      .get('/posts/{id}', 
          name: 'Get Post by ID',
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
      .delete('/posts/{id}', 
          name: 'Delete Post',
          tags: ['posts', 'write'])
      .build(),
];
```

## CRUD Builder - Even Simpler!

For standard CRUD operations, use the convenience method:

```dart
final apiDefinitions = [
  // This creates 5 endpoints: GET all, GET by ID, POST, PUT, DELETE
  SimpleApiBuilder.crud(
    title: 'Posts API',
    baseUrl: 'https://jsonplaceholder.typicode.com',
    resource: 'posts',
    listQueryParams: ['userId', 'published'],
    includeSearch: true,
  ).build(),
];
```

This automatically generates:
- `GET /posts` - Get all posts (with userId, published, search, _limit, _offset params)
- `GET /posts/{id}` - Get post by ID
- `POST /posts` - Create post (with body)
- `PUT /posts/{id}` - Update post (with body)
- `DELETE /posts/{id}` - Delete post

## Pre-built Sample APIs

For quick testing, use the pre-built samples:

```dart
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

// Option 1: Use pre-built samples
final apiDefinitions = SampleApiDefinitions.quickStart(); // JSONPlaceholder + Posts CRUD

// Option 2: Use all samples
final apiDefinitions = SampleApiDefinitions.all(); // JSONPlaceholder, CRUD, E-commerce, Social Media

// Option 3: Use specific samples
final apiDefinitions = [
  SampleApiDefinitions.jsonPlaceholder(),
  SampleApiDefinitions.ecommerce(),
  SampleApiDefinitions.socialMedia(),
];
```

## Available Sample APIs

### 1. JSONPlaceholder API
Ready-to-use JSONPlaceholder endpoints for testing.

### 2. CRUD APIs  
Generic CRUD operations for posts and users.

### 3. E-commerce API
Comprehensive e-commerce API with:
- Products (with categories, reviews)
- Orders and cart management
- User profile and addresses

### 4. Social Media API
Social platform API with:
- Timeline and trending posts
- Post interactions (likes, comments)
- User follows and relationships

## Advanced Usage

### Custom Endpoint Configuration
```dart
SimpleApiBuilder(
  title: 'Advanced API',
  baseUrl: 'https://api.example.com',
)
    .get('/users', 
        queryParams: ['role', 'department', 'status'],
        headerParams: ['Authorization', 'X-API-Key'],
        tags: ['users', 'admin'])
    .post('/users/{id}/activate',
        pathParams: ['id'],
        headerParams: ['Authorization'],
        hasBody: false,  // No request body needed
        tags: ['users', 'admin'])
    .build()
```

### Parameter Type Detection
The builder automatically detects parameter types:
- Path parameters: extracted from `{param}` in path
- Query parameters: specified in `queryParams`
- Header parameters: specified in `headerParams`
- Body parameters: automatically added for POST/PUT/PATCH with `hasBody: true` (default)

### Smart Defaults
- Parameters named `id`, `limit`, `offset`, `count` are treated as `int`
- Common parameters get default values (`_limit: 10`, `_offset: 0`, `page: 1`)
- Endpoint names are auto-generated from HTTP method and path if not specified

## Integration Example

```dart
void _openSandbox() {
  // Mix different approaches
  final apiDefinitions = [
    // Use pre-built sample
    SampleApiDefinitions.jsonPlaceholder(),
    
    // Create custom API
    SimpleApiBuilder(
      title: 'My Custom API',
      baseUrl: 'https://myapi.example.com',
    )
        .get('/health', name: 'Health Check')
        .get('/metrics', name: 'Get Metrics', 
            headerParams: ['Authorization'])
        .build(),
    
    // Use CRUD builder
    SimpleApiBuilder.crud(
      title: 'Products API',
      baseUrl: 'https://shop.example.com',
      resource: 'products',
      includeSearch: true,
    ).build(),
  ];

  Navigator.push(context, MaterialPageRoute(
    builder: (context) => HttpSandboxDashboard(
      apiDefinitions: apiDefinitions,
    ),
  ));
}
```

## Migration from Verbose Builder

Replace this:
```dart
ApiDefinitionBuilder.endpoint(
  name: 'Get Users',
  path: '/users',
  method: HttpMethod.get,
  parameters: [
    ApiDefinitionBuilder.queryParam('role', dataType: String),
    ApiDefinitionBuilder.queryParam('_limit', dataType: int, defaultValue: 10),
  ],
  tags: ['users', 'read'],
)
```

With this:
```dart
.get('/users',
    name: 'Get Users',
    queryParams: ['role', '_limit'],
    tags: ['users', 'read'])
```

**Result: ~70% less code while maintaining the same functionality!**