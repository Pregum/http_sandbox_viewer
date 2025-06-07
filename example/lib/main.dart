import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Sandbox Viewer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Dio dio;

  @override
  void initState() {
    super.initState();
    
    // Initialize Dio with the HTTP Sandbox Interceptor
    dio = Dio();
    dio.interceptors.add(HttpSandboxInterceptor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Sandbox Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Make HTTP requests to see them in the sandbox:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeGetRequest,
              child: const Text('Make GET Request'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _makePostRequest,
              child: const Text('Make POST Request'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _makeErrorRequest,
              child: const Text('Make Error Request'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _openSandbox,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open HTTP Sandbox'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeGetRequest() async {
    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      _showSnackBar('GET request completed');
    } catch (e) {
      _showSnackBar('GET request failed: $e');
    }
  }

  Future<void> _makePostRequest() async {
    try {
      await dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          'title': 'Sample Post',
          'body': 'This is a sample post body',
          'userId': 1,
        },
      );
      _showSnackBar('POST request completed');
    } catch (e) {
      _showSnackBar('POST request failed: $e');
    }
  }

  Future<void> _makeErrorRequest() async {
    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/999999');
      _showSnackBar('Error request completed');
    } catch (e) {
      _showSnackBar('Error request failed: $e');
    }
  }

  void _openSandbox() {
    // Create sample API definitions for demonstration
    final sampleApiDefinitions = [
      ApiDefinitionBuilder.fromRetrofitService(
        serviceName: 'JSONPlaceholder API',
        baseUrl: 'https://jsonplaceholder.typicode.com',
        description: 'Sample API for testing and learning',
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
          ApiDefinitionBuilder.endpoint(
            name: 'Get Post by ID',
            path: '/posts/{id}',
            method: HttpMethod.get,
            description: 'Get a specific post by its ID',
            summary: 'Retrieve detailed information about a single post',
            tags: ['posts', 'read'],
            parameters: [
              ApiDefinitionBuilder.pathParam(
                'id',
                dataType: int,
                description: 'The ID of the post to retrieve',
              ),
            ],
            responseType: 'Post',
          ),
          ApiDefinitionBuilder.endpoint(
            name: 'Create New Post',
            path: '/posts',
            method: HttpMethod.post,
            description: 'Create a new post',
            summary: 'Add a new post to the system',
            tags: ['posts', 'write'],
            parameters: [
              ApiDefinitionBuilder.bodyParam(
                description: 'Post data including title, body, and userId',
              ),
            ],
            responseType: 'Post',
          ),
          ApiDefinitionBuilder.endpoint(
            name: 'Update Post',
            path: '/posts/{id}',
            method: HttpMethod.put,
            description: 'Update an existing post',
            summary: 'Modify the content of an existing post',
            tags: ['posts', 'write'],
            parameters: [
              ApiDefinitionBuilder.pathParam(
                'id',
                dataType: int,
                description: 'The ID of the post to update',
              ),
              ApiDefinitionBuilder.bodyParam(
                description: 'Updated post data',
              ),
            ],
            responseType: 'Post',
          ),
          ApiDefinitionBuilder.endpoint(
            name: 'Delete Post',
            path: '/posts/{id}',
            method: HttpMethod.delete,
            description: 'Delete a post',
            summary: 'Remove a post from the system',
            tags: ['posts', 'write'],
            parameters: [
              ApiDefinitionBuilder.pathParam(
                'id',
                dataType: int,
                description: 'The ID of the post to delete',
              ),
            ],
            responseType: 'void',
          ),
          ApiDefinitionBuilder.endpoint(
            name: 'Get All Users',
            path: '/users',
            method: HttpMethod.get,
            description: 'Retrieve all users',
            summary: 'Get a list of all registered users',
            tags: ['users', 'read'],
            responseType: 'List<User>',
          ),
          ApiDefinitionBuilder.endpoint(
            name: 'Get User by ID',
            path: '/users/{id}',
            method: HttpMethod.get,
            description: 'Get a specific user by ID',
            summary: 'Retrieve detailed user information',
            tags: ['users', 'read'],
            parameters: [
              ApiDefinitionBuilder.pathParam(
                'id',
                dataType: int,
                description: 'The ID of the user to retrieve',
              ),
            ],
            responseType: 'User',
          ),
        ],
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HttpSandboxDashboard(
          apiDefinitions: sampleApiDefinitions,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}