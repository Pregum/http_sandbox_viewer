import 'package:flutter/material.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

/// シンプルなOpenAPI読み込みの使用例
void main() {
  runApp(const SimpleOpenApiApp());
}

class SimpleOpenApiApp extends StatelessWidget {
  const SimpleOpenApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple OpenAPI Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SimpleOpenApiPage(),
    );
  }
}

class SimpleOpenApiPage extends StatefulWidget {
  const SimpleOpenApiPage({super.key});

  @override
  State<SimpleOpenApiPage> createState() => _SimpleOpenApiPageState();
}

class _SimpleOpenApiPageState extends State<SimpleOpenApiPage> {
  ApiDefinition? _currentApi;

  @override
  void initState() {
    super.initState();
    _loadJsonPlaceholderApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple OpenAPI Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJsonPlaceholderApi,
            tooltip: 'APIを再読み込み',
          ),
        ],
      ),
      body: _currentApi == null
          ? const Center(child: CircularProgressIndicator())
          : ApiDefinitionsDashboard(initialDefinitions: [_currentApi!]),
    );
  }

  /// JSONPlaceholder APIをOpenAPI形式で定義して読み込む
  void _loadJsonPlaceholderApi() {
    // JSONPlaceholder APIのOpenAPI定義
    final jsonPlaceholderSpec = {
      "openapi": "3.0.0",
      "info": {
        "title": "JSONPlaceholder API",
        "description": "テスト用のJSONPlaceholder API（OpenAPIから生成）",
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
            "tags": ["posts"],
            "summary": "全ての投稿を取得",
            "description": "すべてのブログ投稿を取得します",
            "parameters": [
              {
                "name": "userId",
                "in": "query",
                "description": "特定のユーザーの投稿をフィルタ",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              },
              {
                "name": "_limit",
                "in": "query",
                "description": "取得件数の制限",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "成功",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "\$ref": "#/components/schemas/Post"
                      }
                    }
                  }
                }
              }
            }
          },
          "post": {
            "tags": ["posts"],
            "summary": "新しい投稿を作成",
            "description": "新しいブログ投稿を作成します",
            "requestBody": {
              "description": "作成する投稿データ",
              "required": true,
              "content": {
                "application/json": {
                  "schema": {
                    "\$ref": "#/components/schemas/Post"
                  }
                }
              }
            },
            "responses": {
              "201": {
                "description": "作成成功",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Post"
                    }
                  }
                }
              }
            }
          }
        },
        "/posts/{id}": {
          "get": {
            "tags": ["posts"],
            "summary": "特定の投稿を取得",
            "description": "IDで指定した投稿を取得します",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "投稿のID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "成功",
                "content": {
                  "application/json": {
                    "schema": {
                      "\$ref": "#/components/schemas/Post"
                    }
                  }
                }
              }
            }
          },
          "put": {
            "tags": ["posts"],
            "summary": "投稿を更新",
            "description": "既存の投稿を更新します",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "投稿のID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "requestBody": {
              "description": "更新する投稿データ",
              "required": true
            },
            "responses": {
              "200": {
                "description": "更新成功"
              }
            }
          },
          "delete": {
            "tags": ["posts"],
            "summary": "投稿を削除",
            "description": "指定した投稿を削除します",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "投稿のID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "削除成功"
              }
            }
          }
        },
        "/users": {
          "get": {
            "tags": ["users"],
            "summary": "全てのユーザーを取得",
            "description": "すべてのユーザー情報を取得します",
            "responses": {
              "200": {
                "description": "成功",
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
            "tags": ["users"],
            "summary": "特定のユーザーを取得",
            "description": "IDで指定したユーザー情報を取得します",
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "description": "ユーザーのID",
                "required": true,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "成功",
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
        },
        "/comments": {
          "get": {
            "tags": ["comments"],
            "summary": "コメントを取得",
            "description": "投稿のコメントを取得します",
            "parameters": [
              {
                "name": "postId",
                "in": "query",
                "description": "投稿IDでコメントをフィルタ",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              },
              {
                "name": "_limit",
                "in": "query",
                "description": "取得件数の制限",
                "required": false,
                "schema": {
                  "type": "integer"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "成功",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "array",
                      "items": {
                        "\$ref": "#/components/schemas/Comment"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "components": {
        "schemas": {
          "Post": {
            "type": "object",
            "properties": {
              "id": {"type": "integer"},
              "title": {"type": "string"},
              "body": {"type": "string"},
              "userId": {"type": "integer"}
            }
          },
          "User": {
            "type": "object",
            "properties": {
              "id": {"type": "integer"},
              "name": {"type": "string"},
              "username": {"type": "string"},
              "email": {"type": "string"}
            }
          },
          "Comment": {
            "type": "object",
            "properties": {
              "id": {"type": "integer"},
              "postId": {"type": "integer"},
              "name": {"type": "string"},
              "email": {"type": "string"},
              "body": {"type": "string"}
            }
          }
        }
      }
    };

    // OpenAPI仕様をAPIDefinitionに変換
    final apiDefinition = OpenApiLoader.fromMap(jsonPlaceholderSpec);
    
    setState(() {
      _currentApi = apiDefinition;
    });

    if (apiDefinition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OpenAPI仕様の読み込みに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${apiDefinition.title}を読み込みました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}