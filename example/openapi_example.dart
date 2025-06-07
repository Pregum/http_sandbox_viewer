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
                        label: const Text('YAML読み込み'),
                        onPressed: _loadFromYamlString,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.description),
                        label: const Text('高度なYAML'),
                        onPressed: _loadAdvancedYamlExample,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('リセット'),
                        onPressed: _resetToSamples,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.library_books),
                        label: const Text('事前定義YAML'),
                        onPressed: _loadPrebuiltYamlSamples,
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

  // YAML文字列からOpenAPIを読み込む例
  void _loadFromYamlString() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // YAML形式のOpenAPI定義
    const weatherApiYaml = '''
openapi: 3.0.0
info:
  title: Weather API
  description: 天気情報取得API（YAML形式）
  version: 1.0.0
servers:
  - url: https://api.openweathermap.org/data/2.5
paths:
  /weather:
    get:
      tags:
        - weather
      summary: 現在の天気を取得
      description: 指定した都市の現在の天気情報を取得します
      parameters:
        - name: q
          in: query
          description: 都市名
          required: true
          schema:
            type: string
        - name: appid
          in: query
          description: APIキー
          required: true
          schema:
            type: string
        - name: units
          in: query
          description: 単位（metric, imperial）
          required: false
          schema:
            type: string
            enum:
              - metric
              - imperial
            default: metric
        - name: lang
          in: query
          description: 言語設定
          required: false
          schema:
            type: string
            enum:
              - ja
              - en
              - fr
              - de
            default: en
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  weather:
                    type: array
                  main:
                    type: object
                  name:
                    type: string
  /forecast:
    get:
      tags:
        - weather
      summary: 天気予報を取得
      description: 指定した都市の5日間天気予報を取得します
      parameters:
        - name: q
          in: query
          description: 都市名
          required: true
          schema:
            type: string
        - name: appid
          in: query
          description: APIキー
          required: true
          schema:
            type: string
        - name: units
          in: query
          description: 単位
          required: false
          schema:
            type: string
            enum:
              - metric
              - imperial
        - name: cnt
          in: query
          description: 予報データ数（最大40）
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 40
            default: 5
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  list:
                    type: array
                  city:
                    type: object
  /onecall:
    get:
      tags:
        - weather
      summary: 詳細天気情報を取得
      description: 緯度経度指定で詳細な天気情報を取得
      parameters:
        - name: lat
          in: query
          description: 緯度
          required: true
          schema:
            type: number
            format: float
        - name: lon
          in: query
          description: 経度
          required: true
          schema:
            type: number
            format: float
        - name: appid
          in: query
          description: APIキー
          required: true
          schema:
            type: string
        - name: exclude
          in: query
          description: 除外するデータ
          required: false
          schema:
            type: string
            enum:
              - current
              - minutely
              - hourly
              - daily
              - alerts
      responses:
        '200':
          description: 成功
''';

    try {
      final apiDefinition = OpenApiLoader.fromYamlString(
        weatherApiYaml,
        baseUrl: 'https://api.openweathermap.org/data/2.5',
      );
      
      if (apiDefinition != null) {
        setState(() {
          apiDefinitions = [apiDefinition, ...apiDefinitions];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'YAML形式OpenAPIの解析に失敗しました';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'YAML解析エラー: $e';
        isLoading = false;
      });
    }
  }

  // 高度なYAMLサンプル（E-commerce API）
  void _loadAdvancedYamlExample() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // 複雑なYAML形式のOpenAPI定義（E-commerce API）
    const advancedYaml = '''
openapi: 3.0.0
info:
  title: E-commerce API
  description: |
    包括的なEコマースAPI
    
    **主要機能:**
    - 商品管理
    - ショッピングカート
    - 注文処理
    - ユーザー認証
    
    **利用方法:**
    1. ユーザー登録/ログイン
    2. 商品を検索・閲覧
    3. カートに追加
    4. 注文処理
  version: 2.1.0
  contact:
    name: API Support
    email: support@example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT
servers:
  - url: https://api.shop.example.com/v2
    description: Production server
  - url: https://staging-api.shop.example.com/v2
    description: Staging server
paths:
  /products:
    get:
      tags:
        - products
      summary: 商品一覧を取得
      description: |
        商品一覧を取得します。
        様々なフィルタリングオプションが利用可能です。
      operationId: getProducts
      parameters:
        - name: category
          in: query
          description: カテゴリでフィルタ
          required: false
          schema:
            type: string
            enum:
              - electronics
              - clothing
              - books
              - home
              - sports
        - name: brand
          in: query
          description: ブランドでフィルタ
          required: false
          schema:
            type: string
        - name: price_min
          in: query
          description: 最低価格
          required: false
          schema:
            type: number
            format: float
            minimum: 0
        - name: price_max
          in: query
          description: 最高価格
          required: false
          schema:
            type: number
            format: float
            minimum: 0
        - name: sort
          in: query
          description: ソート順
          required: false
          schema:
            type: string
            enum:
              - price_asc
              - price_desc
              - name_asc
              - name_desc
              - created_at
              - rating
            default: created_at
        - name: page
          in: query
          description: ページ番号
          required: false
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          description: 1ページあたりの件数
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        - name: in_stock
          in: query
          description: 在庫ありのみ
          required: false
          schema:
            type: boolean
            default: false
      responses:
        '200':
          description: 商品一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  products:
                    type: array
                    items:
                      \$ref: '#/components/schemas/Product'
                  pagination:
                    \$ref: '#/components/schemas/Pagination'
        '400':
          description: 無効なパラメータ
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Error'
    post:
      tags:
        - products
      summary: 新しい商品を作成
      description: 新しい商品を作成します（管理者権限が必要）
      operationId: createProduct
      security:
        - BearerAuth: []
        - AdminAuth: []
      requestBody:
        description: 作成する商品データ
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/ProductCreate'
          multipart/form-data:
            schema:
              type: object
              properties:
                product:
                  \$ref: '#/components/schemas/ProductCreate'
                images:
                  type: array
                  items:
                    type: string
                    format: binary
      responses:
        '201':
          description: 商品作成成功
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Product'
        '400':
          description: 無効なデータ
        '401':
          description: 認証が必要
        '403':
          description: 管理者権限が必要
  /products/{productId}:
    get:
      tags:
        - products
      summary: 商品詳細を取得
      description: 指定した商品の詳細情報を取得します
      operationId: getProduct
      parameters:
        - name: productId
          in: path
          description: 商品ID
          required: true
          schema:
            type: string
            pattern: '^[0-9a-f]{24}\$'
        - name: include_reviews
          in: query
          description: レビューを含むかどうか
          required: false
          schema:
            type: boolean
            default: false
      responses:
        '200':
          description: 商品詳細
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/ProductDetail'
        '404':
          description: 商品が見つからない
  /cart:
    get:
      tags:
        - cart
      summary: カート内容を取得
      description: 現在のユーザーのカート内容を取得します
      operationId: getCart
      security:
        - BearerAuth: []
      responses:
        '200':
          description: カート内容
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Cart'
        '401':
          description: 認証が必要
    post:
      tags:
        - cart
      summary: カートに商品を追加
      description: 指定した商品をカートに追加します
      operationId: addToCart
      security:
        - BearerAuth: []
      requestBody:
        description: カートに追加する商品
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - productId
                - quantity
              properties:
                productId:
                  type: string
                  description: 商品ID
                quantity:
                  type: integer
                  minimum: 1
                  maximum: 99
                  description: 数量
                options:
                  type: object
                  description: 商品オプション（サイズ、色など）
      responses:
        '200':
          description: カート更新成功
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Cart'
        '400':
          description: 無効なデータ
        '401':
          description: 認証が必要
        '404':
          description: 商品が見つからない
  /orders:
    get:
      tags:
        - orders
      summary: 注文履歴を取得
      description: ユーザーの注文履歴を取得します
      operationId: getOrders
      security:
        - BearerAuth: []
      parameters:
        - name: status
          in: query
          description: 注文ステータスでフィルタ
          required: false
          schema:
            type: string
            enum:
              - pending
              - processing
              - shipped
              - delivered
              - cancelled
        - name: date_from
          in: query
          description: 開始日
          required: false
          schema:
            type: string
            format: date
        - name: date_to
          in: query
          description: 終了日
          required: false
          schema:
            type: string
            format: date
      responses:
        '200':
          description: 注文履歴
          content:
            application/json:
              schema:
                type: array
                items:
                  \$ref: '#/components/schemas/Order'
        '401':
          description: 認証が必要
    post:
      tags:
        - orders
      summary: 注文を作成
      description: カート内容から新しい注文を作成します
      operationId: createOrder
      security:
        - BearerAuth: []
      requestBody:
        description: 注文情報
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - shippingAddress
                - paymentMethod
              properties:
                shippingAddress:
                  \$ref: '#/components/schemas/Address'
                billingAddress:
                  \$ref: '#/components/schemas/Address'
                paymentMethod:
                  type: string
                  enum:
                    - credit_card
                    - debit_card
                    - paypal
                    - bank_transfer
                notes:
                  type: string
                  maxLength: 500
      responses:
        '201':
          description: 注文作成成功
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Order'
        '400':
          description: 無効なデータ
        '401':
          description: 認証が必要
  /auth/login:
    post:
      tags:
        - auth
      summary: ユーザーログイン
      description: ユーザー認証を行います
      operationId: login
      requestBody:
        description: ログイン情報
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - email
                - password
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  minLength: 8
      responses:
        '200':
          description: ログイン成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  token:
                    type: string
                  user:
                    \$ref: '#/components/schemas/User'
        '401':
          description: 認証失敗
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    AdminAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  schemas:
    Product:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        description:
          type: string
        price:
          type: number
          format: float
        category:
          type: string
        brand:
          type: string
        stock:
          type: integer
        images:
          type: array
          items:
            type: string
            format: uri
        rating:
          type: number
          format: float
          minimum: 0
          maximum: 5
        created_at:
          type: string
          format: date-time
    ProductCreate:
      type: object
      required:
        - name
        - description
        - price
        - category
        - stock
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 255
        description:
          type: string
          minLength: 1
        price:
          type: number
          format: float
          minimum: 0
        category:
          type: string
        brand:
          type: string
        stock:
          type: integer
          minimum: 0
    ProductDetail:
      allOf:
        - \$ref: '#/components/schemas/Product'
        - type: object
          properties:
            reviews:
              type: array
              items:
                \$ref: '#/components/schemas/Review'
            specifications:
              type: object
            related_products:
              type: array
              items:
                \$ref: '#/components/schemas/Product'
    Cart:
      type: object
      properties:
        items:
          type: array
          items:
            \$ref: '#/components/schemas/CartItem'
        total:
          type: number
          format: float
        item_count:
          type: integer
    CartItem:
      type: object
      properties:
        product:
          \$ref: '#/components/schemas/Product'
        quantity:
          type: integer
        options:
          type: object
        subtotal:
          type: number
          format: float
    Order:
      type: object
      properties:
        id:
          type: string
        status:
          type: string
          enum:
            - pending
            - processing
            - shipped
            - delivered
            - cancelled
        items:
          type: array
          items:
            \$ref: '#/components/schemas/CartItem'
        total:
          type: number
          format: float
        shipping_address:
          \$ref: '#/components/schemas/Address'
        created_at:
          type: string
          format: date-time
    Address:
      type: object
      required:
        - street
        - city
        - country
        - postal_code
      properties:
        street:
          type: string
        city:
          type: string
        state:
          type: string
        country:
          type: string
        postal_code:
          type: string
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
          format: email
        name:
          type: string
        avatar:
          type: string
          format: uri
    Review:
      type: object
      properties:
        id:
          type: string
        user:
          \$ref: '#/components/schemas/User'
        rating:
          type: integer
          minimum: 1
          maximum: 5
        comment:
          type: string
        created_at:
          type: string
          format: date-time
    Pagination:
      type: object
      properties:
        page:
          type: integer
        limit:
          type: integer
        total:
          type: integer
        has_next:
          type: boolean
        has_prev:
          type: boolean
    Error:
      type: object
      properties:
        error:
          type: string
        message:
          type: string
        details:
          type: object
''';

    try {
      final apiDefinition = OpenApiLoader.fromYamlString(
        advancedYaml,
        baseUrl: 'https://api.shop.example.com/v2',
      );
      
      if (apiDefinition != null) {
        setState(() {
          apiDefinitions = [apiDefinition, ...apiDefinitions];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '高度なYAML形式OpenAPIの解析に失敗しました';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '高度なYAML解析エラー: $e';
        isLoading = false;
      });
    }
  }

  // 事前定義されたYAMLサンプルを読み込み
  void _loadPrebuiltYamlSamples() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // SampleApiDefinitionsから事前定義されたYAMLサンプルを取得
      final yamlSamples = [
        SampleApiDefinitions.openApiYamlExample(), // Books API (YAML)
        SampleApiDefinitions.openApiPetStore(),    // PetStore API
      ];
      
      setState(() {
        // 既存のAPIに事前定義のYAMLサンプルを追加
        apiDefinitions = [...yamlSamples, ...apiDefinitions];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '事前定義YAMLサンプルの読み込みエラー: $e';
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