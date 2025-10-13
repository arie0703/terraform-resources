# Serverless Order System

DynamoDB、Lambda、SQSを使用したサーバーレス注文システムです。

## アーキテクチャ

- **DynamoDB**: ユーザー、商品、注文データの保存
- **SQS**: 注文処理のキューイング（重複注文防止）
- **Lambda**: 注文処理とAPI処理

## 機能

1. **重複注文防止**: SQSのメッセージ重複排除機能とDynamoDBのトランザクションIDチェック
2. **残高管理**: ユーザーの残高を管理し、購入時に残高を減算
3. **購入回数カウント**: ユーザーの購入回数を自動でカウント
4. **非同期処理**: SQSキューを使用した非同期注文処理

## データ構造

### ユーザーテーブル (users)

```json
{
  "user_id": "string",
  "username": "string",
  "balance": "number",
  "purchase_count": "number"
}
```

### 商品テーブル (products)

```json
{
  "product_id": "string",
  "name": "string",
  "price": "number"
}
```

### 注文テーブル (orders)

```json
{
  "order_id": "string",
  "transaction_id": "string",
  "user_id": "string",
  "product_id": "string",
  "amount": "number",
  "status": "string",
  "created_at": "string",
  "updated_at": "string"
}
```

## デプロイ方法

- Terraformの初期化

```bash
terraform init
```

- プランの確認

```bash
terraform plan
```

- デプロイ

```bash
terraform apply
```

## API使用方法

### 注文作成

```bash
POST /orders
Content-Type: application/json

{
  "userId": "user123",
  "productId": "product456"
}
```

### レスポンス

```json
{
  "message": "Order submitted successfully",
  "transactionId": "uuid"
}
```

## Lambdaテスト用サンプルリクエスト

### 注文API (order-api) テスト用イベント

#### 注文作成テスト

```json
{
  "httpMethod": "POST",
  "path": "/orders",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"userId\":\"user123\",\"productId\":\"product456\"}"
}
```

#### 商品一覧取得テスト

```json
{
  "httpMethod": "GET",
  "path": "/products",
  "headers": {}
}
```

#### ユーザー情報取得テスト

```json
{
  "httpMethod": "GET",
  "path": "/users/user123",
  "headers": {}
}
```

### 注文処理 (order-processor) テスト用イベント

#### SQSメッセージ処理テスト

```json
{
  "Records": [
    {
      "messageId": "test-message-id",
      "receiptHandle": "test-receipt-handle",
      "body": "{\"userId\":\"user123\",\"productId\":\"product456\",\"transactionId\":\"test-transaction-123\",\"timestamp\":\"2024-01-01T00:00:00.000Z\"}",
      "attributes": {
        "ApproximateReceiveCount": "1",
        "SentTimestamp": "1640995200000",
        "SenderId": "test-sender-id",
        "ApproximateFirstReceiveTimestamp": "1640995200000"
      },
      "messageAttributes": {},
      "md5OfBody": "test-md5",
      "eventSource": "aws:sqs",
      "eventSourceARN": "arn:aws:sqs:ap-northeast-1:123456789012:test-queue",
      "awsRegion": "ap-northeast-1"
    }
  ]
}
```

## 処理フロー

1. ユーザーが注文APIを呼び出し
2. 注文データがSQSキューに送信される
3. Lambda関数がSQSメッセージを処理
4. 重複チェック（transaction_id）
5. ユーザー残高チェック
6. 注文レコード作成
7. ユーザー残高減算・購入回数増加
8. 注文ステータス更新

## 注意事項

- 商品の在庫管理は実装されていません
- ユーザー認証は実装されていません
- エラーハンドリングとログ出力は基本的な実装のみです
