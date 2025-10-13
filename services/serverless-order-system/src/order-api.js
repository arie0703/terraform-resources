const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');
const { v4: uuidv4 } = require('uuid');

// SQSクライアントの初期化
const sqsClient = new SQSClient({});

// 環境変数からキューURLを取得
const ORDER_QUEUE_URL = process.env.ORDER_QUEUE_URL;

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  try {
    // HTTPメソッドとパスを取得
    const httpMethod = event.httpMethod;
    const path = event.path;

    if (httpMethod === 'POST' && path === '/orders') {
      return await createOrder(event);
    } else if (httpMethod === 'GET' && path === '/products') {
      return await getProducts(event);
    } else if (httpMethod === 'GET' && path.startsWith('/users/')) {
      return await getUser(event);
    } else {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
        },
        body: JSON.stringify({
          error: 'Not Found'
        })
      };
    }
  } catch (error) {
    console.error('Error processing request:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        error: 'Internal Server Error',
        message: error.message
      })
    };
  }
};

async function createOrder(event) {
  try {
    const body = JSON.parse(event.body);
    const { userId, productId } = body;

    // バリデーション
    if (!userId || !productId) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
          error: 'Bad Request',
          message: 'userId and productId are required'
        })
      };
    }

    // 重複防止のためのトランザクションIDを生成
    const transactionId = uuidv4();

    // SQSにメッセージを送信
    const message = {
      userId,
      productId,
      transactionId,
      timestamp: new Date().toISOString()
    };

    const command = new SendMessageCommand({
      QueueUrl: ORDER_QUEUE_URL,
      MessageBody: JSON.stringify(message),
    });

    await sqsClient.send(command);

    return {
      statusCode: 202,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        message: 'Order submitted successfully',
        transactionId: transactionId
      })
    };

  } catch (error) {
    console.error('Error creating order:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        error: 'Failed to create order',
        message: error.message
      })
    };
  }
}

async function getProducts(event) {
  // この関数はDynamoDBから商品一覧を取得する実装が必要
  // 簡易的なレスポンスを返す
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      message: 'Products endpoint - implementation needed'
    })
  };
}

async function getUser(event) {
  // この関数はDynamoDBからユーザー情報を取得する実装が必要
  // 簡易的なレスポンスを返す
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      message: 'User endpoint - implementation needed'
    })
  };
}
