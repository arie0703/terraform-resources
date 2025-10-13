package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sns"
)

type Response struct {
	Result bool `json:"result"`
}

type Request struct {
	// 必要に応じてリクエストパラメータを追加
}

type SNSMessage struct {
	Version string `json:"version"`
	Source  string `json:"source"`
	Content struct {
		Description string `json:"description"`
	} `json:"content"`
}

func handler(ctx context.Context, request Request) (Response, error) {
	// 環境変数から設定を取得
	websiteURL := os.Getenv("WEBSITE_URL")
	targetString := os.Getenv("TARGET_STRING")
	snsTopicARN := os.Getenv("SNS_TOPIC_ARN")

	if websiteURL == "" || targetString == "" {
		return Response{}, fmt.Errorf("required environment variables not set: WEBSITE_URL=%s, TARGET_STRING=%s", websiteURL, targetString)
	}

	// HTTPクライアントを作成（タイムアウト設定）
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	// リクエストを作成
	req, err := http.NewRequestWithContext(ctx, "GET", websiteURL, nil)
	if err != nil {
		return Response{}, fmt.Errorf("failed to create request: %w", err)
	}

	// User-Agentを設定（Webサイトによっては必要）
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

	// リクエストを実行
	resp, err := client.Do(req)
	if err != nil {
		return Response{}, fmt.Errorf("failed to fetch website: %w", err)
	}
	defer resp.Body.Close()

	// レスポンスステータスをチェック
	if resp.StatusCode != http.StatusOK {
		return Response{}, fmt.Errorf("website returned non-200 status: %d", resp.StatusCode)
	}

	// レスポンスボディを読み取り
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return Response{}, fmt.Errorf("failed to read response body: %w", err)
	}

	// 文字列の存在をチェック（大文字小文字を区別しない）
	bodyStr := strings.ToLower(string(body))
	targetStr := strings.ToLower(targetString)
	result := strings.Contains(bodyStr, targetStr)

	fmt.Printf("Website: %s, Target: %s, Found: %t\n", websiteURL, targetString, result)

	// 特定の文字列が見つからない場合、SNSに通知を送信
	if !result && snsTopicARN != "" {
		if err := sendSNSNotification(ctx, snsTopicARN, targetString); err != nil {
			fmt.Printf("Failed to send SNS notification: %v\n", err)
		} else {
			fmt.Printf("SNS notification sent successfully\n")
		}
	}

	return Response{
		Result: result,
	}, nil
}

func sendSNSNotification(ctx context.Context, topicARN, targetString string) error {
	// AWS設定を読み込み
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return fmt.Errorf("failed to load AWS config: %w", err)
	}

	// SNSクライアントを作成
	snsClient := sns.NewFromConfig(cfg)

	// メッセージを作成（見つからない場合のメッセージ）
	message := fmt.Sprintf("特定の文字列 '%s' は監視中のWebサイトから見つかりませんでした", targetString)

	// SNSメッセージ構造体を作成
	snsMessage := SNSMessage{
		Version: "1.0",
		Source:  "custom",
	}
	snsMessage.Content.Description = message

	// JSONにシリアライズ
	messageJSON, err := json.Marshal(snsMessage)
	if err != nil {
		return fmt.Errorf("failed to marshal SNS message: %w", err)
	}

	// SNSにメッセージを送信
	_, err = snsClient.Publish(ctx, &sns.PublishInput{
		TopicArn: &topicARN,
		Message:  aws.String(string(messageJSON)),
		Subject:  aws.String("Website Monitor Alert - String Not Found"),
	})

	return err
}

func main() {
	lambda.Start(handler)
}
