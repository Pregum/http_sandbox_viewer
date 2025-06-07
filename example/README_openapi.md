# OpenAPI読み込み機能の使用例

このドキュメントでは、`http_sandbox_viewer`パッケージのOpenAPI読み込み機能の使用方法を説明します。

## 基本的な使用方法

### 1. JSON文字列からの読み込み

```dart
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

// OpenAPI JSON文字列を準備
const openApiJson = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "My API",
    "version": "1.0.0"
  },
  "servers": [{"url": "https://api.example.com"}],
  "paths": {
    "/users": {
      "get": {
        "summary": "Get users",
        "responses": {"200": {"description": "Success"}}
      }
    }
  }
}
''';

// APIDefinitionに変換
final apiDefinition = OpenApiLoader.fromJsonString(openApiJson);
if (apiDefinition != null) {
  // ダッシュボードで使用
  ApiDefinitionsDashboard(initialDefinitions: [apiDefinition])
}
```

### 2. YAML文字列からの読み込み

```dart
import 'package:http_sandbox_viewer/http_sandbox_viewer.dart';

// YAML形式のOpenAPI仕様
const openApiYaml = '''
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
servers:
  - url: https://api.example.com
paths:
  /users:
    get:
      summary: Get users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Success
''';

// APIDefinitionに変換
final apiDefinition = OpenApiLoader.fromYamlString(openApiYaml);
if (apiDefinition != null) {
  // ダッシュボードで使用
  ApiDefinitionsDashboard(initialDefinitions: [apiDefinition])
}
```

### 3. Map形式からの読み込み

```dart
// Map形式のOpenAPI仕様
final openApiSpec = {
  "openapi": "3.0.0",
  "info": {
    "title": "Todo API",
    "version": "1.0.0"
  },
  "servers": [
    {"url": "https://jsonplaceholder.typicode.com"}
  ],
  "paths": {
    "/todos": {
      "get": {
        "summary": "Get all todos",
        "parameters": [
          {
            "name": "userId",
            "in": "query",
            "schema": {"type": "integer"}
          }
        ],
        "responses": {
          "200": {"description": "Success"}
        }
      }
    }
  }
};

// APIDefinitionに変換
final apiDefinition = OpenApiLoader.fromMap(openApiSpec);
```

### 4. アセットファイルからの読み込み

```dart
// pubspec.yamlにアセットを追加
// assets:
//   - assets/openapi/

// JSON形式のアセットファイルから読み込み
final jsonApiDefinition = await OpenApiLoader.fromAsset(
  'assets/openapi/petstore.json',
  baseUrl: 'https://petstore.swagger.io/v2', // ベースURLのオーバーライド（オプション）
);

// YAML形式のアセットファイルから読み込み（自動判定）
final yamlApiDefinition = await OpenApiLoader.fromAsset(
  'assets/openapi/openapi.yaml',
  baseUrl: 'https://api.example.com',
);
```

**ファイル拡張子による自動判定**:
- `.yaml`, `.yml` → YAML形式として処理
- `.json` または その他 → JSON形式として処理

## 実用的な例

### GitHub API の定義

```dart
final gitHubApiSpec = {
  "openapi": "3.0.0",
  "info": {
    "title": "GitHub API",
    "version": "v3"
  },
  "servers": [
    {"url": "https://api.github.com"}
  ],
  "paths": {
    "/user": {
      "get": {
        "summary": "Get authenticated user",
        "parameters": [
          {
            "name": "Authorization",
            "in": "header",
            "required": true,
            "schema": {"type": "string"},
            "description": "Bearer {token}"
          }
        ],
        "responses": {
          "200": {"description": "Success"}
        }
      }
    },
    "/user/repos": {
      "get": {
        "summary": "List user repositories",
        "parameters": [
          {
            "name": "Authorization",
            "in": "header",
            "required": true,
            "schema": {"type": "string"}
          },
          {
            "name": "type",
            "in": "query",
            "schema": {
              "type": "string",
              "enum": ["all", "owner", "member"]
            }
          },
          {
            "name": "sort",
            "in": "query",
            "schema": {
              "type": "string",
              "enum": ["created", "updated", "pushed", "full_name"]
            }
          }
        ],
        "responses": {
          "200": {"description": "Success"}
        }
      }
    }
  }
};

final githubApi = OpenApiLoader.fromMap(gitHubApiSpec);
```

### 認証が必要なAPIの例

```dart
final authApiSpec = {
  "openapi": "3.0.0",
  "info": {
    "title": "Authenticated API",
    "version": "1.0.0"
  },
  "servers": [
    {"url": "https://api.myservice.com"}
  ],
  "paths": {
    "/auth/login": {
      "post": {
        "tags": ["auth"],
        "summary": "User login",
        "requestBody": {
          "required": true,
          "description": "Login credentials"
        },
        "responses": {
          "200": {"description": "Login successful"}
        }
      }
    },
    "/profile": {
      "get": {
        "tags": ["user"],
        "summary": "Get user profile",
        "parameters": [
          {
            "name": "Authorization",
            "in": "header",
            "required": true,
            "schema": {"type": "string"},
            "description": "Bearer token"
          }
        ],
        "responses": {
          "200": {"description": "Success"}
        }
      }
    }
  }
};

final authApi = OpenApiLoader.fromMap(authApiSpec);
```

## エラーハンドリング

```dart
try {
  final apiDefinition = OpenApiLoader.fromJsonString(openApiJson);
  if (apiDefinition == null) {
    print('OpenAPI仕様の解析に失敗しました');
  } else {
    // 正常に読み込まれた場合の処理
    print('API定義が正常に読み込まれました: ${apiDefinition.title}');
  }
} catch (e) {
  print('エラーが発生しました: $e');
}
```

## 対応している機能

### 入力形式
- **JSON文字列**: `OpenApiLoader.fromJsonString()`
- **YAML文字列**: `OpenApiLoader.fromYamlString()`
- **Map形式**: `OpenApiLoader.fromMap()`
- **アセットファイル**: `OpenApiLoader.fromAsset()` (JSON/YAML自動判定)

### HTTPメソッド
- GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS

### パラメータタイプ
- Path parameters (`/users/{id}`)
- Query parameters (`?limit=10&offset=0`)
- Header parameters (`Authorization: Bearer token`)
- Request body (POST, PUT, PATCH)

### データタイプ
- string
- integer
- number (float/double)
- boolean
- array
- object
- enum (select options)

### YAML特有の機能
- 複数行文字列サポート
- コメント記述対応
- より読みやすい階層構造
- enum値の配列記法

### レスポンス情報
- ステータスコード
- レスポンスタイプの自動推定
- エラーレスポンスの処理

## 制限事項

1. **セキュリティ定義**: 現在、セキュリティスキーマの自動適用には対応していません
2. **複雑なスキーマ**: $refやallOf、oneOfなどの複雑なスキーマ参照は部分的なサポートです
3. **コンテンツタイプ**: application/json以外のコンテンツタイプは限定的なサポートです

## サンプルファイル

プロジェクトには以下のサンプルが含まれています：

- `example/openapi_example.dart` - 完全な使用例
- `lib/src/examples/sample_api_definitions.dart` - 事前定義されたサンプル（PetStore APIを含む）

## 実際のOpenAPI仕様ファイルを使用する場合

1. **Swagger Editor**などで仕様ファイルを検証
2. アセットとしてプロジェクトに追加
3. `OpenApiLoader.fromAsset()`で読み込み

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/openapi/
    - assets/openapi/petstore.json
    - assets/openapi/my-api-spec.yaml  # YAMLの場合は事前にJSONに変換が必要
```