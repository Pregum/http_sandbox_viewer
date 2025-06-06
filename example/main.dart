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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HttpSandboxDashboard(),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}