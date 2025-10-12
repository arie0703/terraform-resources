const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, QueryCommand } = require('@aws-sdk/lib-dynamodb');
const { v4: uuidv4 } = require('uuid');

// DynamoDBクライアントの初期化
const client = new DynamoDBClient({});
const dynamodb = DynamoDBDocumentClient.from(client);

// 環境変数からテーブル名とキューURLを取得
const USERS_TABLE = process.env.USERS_TABLE;
const PRODUCTS_TABLE = process.env.PRODUCTS_TABLE;
const ORDERS_TABLE = process.env.ORDERS_TABLE;
const ORDER_QUEUE_URL = process.env.ORDER_QUEUE_URL;

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  try {
    // SQSメッセージを処理
    for (const record of event.Records) {
      const messageBody = JSON.parse(record.body);
      console.log('Processing message:', messageBody);

      await processOrder(messageBody);
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Orders processed successfully'
      })
    };
  } catch (error) {
    console.error('Error processing orders:', error);
    throw error;
  }
};

async function processOrder(orderData) {
  const { userId, productId, transactionId } = orderData;

  try {
    // 1. 重複チェック - 同じtransaction_idの注文が既に存在するかチェック
    const existingOrder = await checkDuplicateOrder(transactionId);
    if (existingOrder) {
      console.log(`Duplicate order detected for transaction_id: ${transactionId}`);
      return {
        success: false,
        reason: 'Duplicate transaction'
      };
    }

    // 2. ユーザー情報を取得
    const user = await getUser(userId);
    if (!user) {
      throw new Error(`User not found: ${userId}`);
    }

    // 3. 商品情報を取得
    const product = await getProduct(productId);
    if (!product) {
      throw new Error(`Product not found: ${productId}`);
    }

    // 4. 残高チェック
    if (user.balance < product.price) {
      console.log(`Insufficient balance for user ${userId}. Required: ${product.price}, Available: ${user.balance}`);
      return {
        success: false,
        reason: 'Insufficient balance'
      };
    }

    // 5. 注文レコードを作成
    const orderId = uuidv4();
    const order = {
      order_id: orderId,
      transaction_id: transactionId,
      user_id: userId,
      product_id: productId,
      amount: product.price,
      status: 'processing',
      created_at: new Date().toISOString()
    };

    await createOrder(order);

    // 6. ユーザーの残高を減らし、購入回数を増やす
    await updateUserBalance(userId, user.balance - product.price, user.purchase_count + 1);

    // 7. 注文ステータスを完了に更新
    await updateOrderStatus(orderId, 'completed');

    console.log(`Order ${orderId} processed successfully for user ${userId}`);

    return {
      success: true,
      orderId: orderId,
      amount: product.price
    };

  } catch (error) {
    console.error(`Error processing order for transaction ${transactionId}:`, error);
    throw error;
  }
}

async function checkDuplicateOrder(transactionId) {
  const command = new QueryCommand({
    TableName: ORDERS_TABLE,
    IndexName: 'transaction-id-index',
    KeyConditionExpression: 'transaction_id = :transaction_id',
    ExpressionAttributeValues: {
      ':transaction_id': transactionId
    }
  });

  const result = await dynamodb.send(command);
  return result.Items.length > 0 ? result.Items[0] : null;
}

async function getUser(userId) {
  const command = new GetCommand({
    TableName: USERS_TABLE,
    Key: {
      user_id: userId
    }
  });

  const result = await dynamodb.send(command);
  return result.Item;
}

async function getProduct(productId) {
  const command = new GetCommand({
    TableName: PRODUCTS_TABLE,
    Key: {
      product_id: productId
    }
  });

  const result = await dynamodb.send(command);
  return result.Item;
}

async function createOrder(order) {
  const command = new PutCommand({
    TableName: ORDERS_TABLE,
    Item: order
  });

  await dynamodb.send(command);
}

async function updateUserBalance(userId, newBalance, newPurchaseCount) {
  const command = new UpdateCommand({
    TableName: USERS_TABLE,
    Key: {
      user_id: userId
    },
    UpdateExpression: 'SET balance = :balance, purchase_count = :purchase_count',
    ExpressionAttributeValues: {
      ':balance': newBalance,
      ':purchase_count': newPurchaseCount
    }
  });

  await dynamodb.send(command);
}

async function updateOrderStatus(orderId, status) {
  const command = new UpdateCommand({
    TableName: ORDERS_TABLE,
    Key: {
      order_id: orderId
    },
    UpdateExpression: 'SET #status = :status, updated_at = :updated_at',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':status': status,
      ':updated_at': new Date().toISOString()
    }
  });

  await dynamodb.send(command);
}
