import 'package:flutter/material.dart';
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

void main() {
  runApp(const OpenApiExampleApp());
}

class OpenApiExampleApp extends StatelessWidget {
  const OpenApiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAPI Loader Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OpenApiExamplePage(),
    );
  }
}

class OpenApiExamplePage extends StatefulWidget {
  const OpenApiExamplePage({super.key});

  @override
  State<OpenApiExamplePage> createState() => _OpenApiExamplePageState();
}

class _OpenApiExamplePageState extends State<OpenApiExamplePage> {
  List<ApiDefinition> apiDefinitions = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSampleApis();
  }

  void _loadSampleApis() {
    setState(() {
      // 事前定義されたサンプルAPIを読み込み（OpenAPIのPetStoreを含む）
      apiDefinitions = [
        ...SampleApiDefinitions.quickStart(),
        SampleApiDefinitions.openApiPetStore(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAPI Loader Examples'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ボタン群
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('JSONから読み込み'),
                        onPressed: _loadFromJsonString,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.folder_open),
                        label: const Text('アセットから読み込み'),
                        onPressed: _loadFromAsset,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.code),
                        label: const Text('カスタムOpenAPI'),
                        onPressed: _loadCustomOpenApi,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('リセット'),
                        onPressed: _resetToSamples,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // エラーメッセージ
          if (errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => errorMessage = null),
                  ),
                ],
              ),
            ),

          // ローディング表示
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // API定義のダッシュボード
          Expanded(
            child: apiDefinitions.isEmpty
                ? const Center(
                    child: Text(
                      'API定義がありません\n上のボタンでOpenAPIを読み込んでください',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ApiDefinitionsDashboard(
                    initialDefinitions: apiDefinitions,
                  ),
          ),
        ],
      ),
    );
  }

  // JSON文字列からOpenAPIを読み込む例
  void _loadFromJsonString() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // サンプルOpenAPI JSON（簡易版）
    const openApiJson = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Todo API",
    "description": "シンプルなTodo管理API",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "https://jsonplaceholder.typicode.com"
    }
  ],
  "paths": {
    "/todos": {
      "get": {
        "tags": ["todos"],
        "summary": "全てのTodoを取得",
        "description": "全てのTodoアイテムを取得します",
        "parameters": [
          {
            "name": "userId",
            "in": "query",
            "description": "ユーザーIDでフィルタ",
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
                    "\$ref": "#/components/schemas/Todo"
                  }
                }
              }
            }
          }
        }
      },
      "post": {
        "tags": ["todos"],
        "summary": "新しいTodoを作成",
        "description": "新しいTodoアイテムを作成します",
        "requestBody": {
          "description": "作成するTodoデータ",
          "required": true
        },
        "responses": {
          "201": {
            "description": "作成成功",
            "content": {
              "application/json": {
                "schema": {
                  "\$ref": "#/components/schemas/Todo"
                }
              }
            }
          }
        }
      }
    },
    "/todos/{id}": {
      "get": {
        "tags": ["todos"],
        "summary": "指定したTodoを取得",
        "description": "IDで指定したTodoアイテムを取得します",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "TodoのID",
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
                  "\$ref": "#/components/schemas/Todo"
                }
              }
            }
          }
        }
      },
      "put": {
        "tags": ["todos"],
        "summary": "Todoを更新",
        "description": "既存のTodoアイテムを更新します",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "TodoのID",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "requestBody": {
          "description": "更新するTodoデータ",
          "required": true
        },
        "responses": {
          "200": {
            "description": "更新成功"
          }
        }
      },
      "delete": {
        "tags": ["todos"],
        "summary": "Todoを削除",
        "description": "指定したTodoアイテムを削除します",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "TodoのID",
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
    }
  }
}
''';

    try {
      final apiDefinition = OpenApiLoader.fromJsonString(openApiJson);
      if (apiDefinition != null) {
        setState(() {
          apiDefinitions = [apiDefinition, ...apiDefinitions];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'OpenAPI JSONの解析に失敗しました';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'エラー: $e';
        isLoading = false;
      });
    }
  }

  // アセットファイルからOpenAPIを読み込む例
  void _loadFromAsset() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 注意: 実際にアセットファイルを使用する場合は、
      // pubspec.yamlのassetsセクションにファイルを追加する必要があります
      // 例: assets/openapi/petstore.json
      
      final apiDefinition = await OpenApiLoader.fromAsset(
        'assets/openapi/petstore.json',
        baseUrl: 'https://petstore.swagger.io/v2',
      );
      
      if (apiDefinition != null) {
        setState(() {
          apiDefinitions = [apiDefinition, ...apiDefinitions];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'アセットファイルからの読み込みに失敗しました';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'アセットファイルが見つかりません: $e';
        isLoading = false;
      });
    }
  }

  // カスタムOpenAPI Mapから読み込む例
  void _loadCustomOpenApi() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // カスタムOpenAPI定義（Map形式）
    final customOpenApiSpec = {
      "openapi": "3.0.0",
      "info": {
        "title": "Weather API",
        "description": "天気情報取得API",
        "version": "1.0.0"
      },
      "servers": [
        {
          "url": "https://api.openweathermap.org/data/2.5"
        }
      ],
      "paths": {
        "/weather": {
          "get": {
            "tags": ["weather"],
            "summary": "現在の天気を取得",
            "description": "指定した都市の現在の天気情報を取得します",
            "parameters": [
              {
                "name": "q",
                "in": "query",
                "description": "都市名",
                "required": true,
                "schema": {
                  "type": "string"
                }
              },
              {
                "name": "appid",
                "in": "query",
                "description": "APIキー",
                "required": true,
                "schema": {
                  "type": "string"
                }
              },
              {
                "name": "units",
                "in": "query",
                "description": "単位（metric, imperial）",
                "required": false,
                "schema": {
                  "type": "string",
                  "enum": ["metric", "imperial"],
                  "default": "metric"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "成功",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "object"
                    }
                  }
                }
              }
            }
          }
        },
        "/forecast": {
          "get": {
            "tags": ["weather"],
            "summary": "天気予報を取得",
            "description": "指定した都市の5日間天気予報を取得します",
            "parameters": [
              {
                "name": "q",
                "in": "query",
                "description": "都市名",
                "required": true,
                "schema": {
                  "type": "string"
                }
              },
              {
                "name": "appid",
                "in": "query",
                "description": "APIキー",
                "required": true,
                "schema": {
                  "type": "string"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "成功"
              }
            }
          }
        }
      }
    };

    try {
      final apiDefinition = OpenApiLoader.fromMap(
        customOpenApiSpec,
        baseUrl: 'https://api.openweathermap.org/data/2.5',
      );
      
      if (apiDefinition != null) {
        setState(() {
          apiDefinitions = [apiDefinition, ...apiDefinitions];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'カスタムOpenAPI Mapの解析に失敗しました';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'エラー: $e';
        isLoading = false;
      });
    }
  }

  // サンプルAPIにリセット
  void _resetToSamples() {
    setState(() {
      errorMessage = null;
    });
    _loadSampleApis();
  }
}