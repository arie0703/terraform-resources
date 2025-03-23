package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/costexplorer"
	"github.com/aws/aws-sdk-go-v2/service/costexplorer/types"

	"github.com/line/line-bot-sdk-go/v8/linebot/messaging_api"
)

// Response はLambdaのレスポンス用構造体
type Response struct {
	Month string `json:"month"`
	Cost  string `json:"cost"`
}

type LambdaResponse struct {
	StatusCode int    `json:"statusCode"`
	Body       string `json:"body"`
}

func getMonthlyCost() (*Response, error) {
	// AWS SDK の設定をロード
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("AWS設定のロードに失敗: %v", err)
	}

	ceClient := costexplorer.NewFromConfig(cfg)

	// 現在の日付を取得
	now := time.Now()
	start := now.Format("2006-01") + "-01"
	end := now.Format("2006-01-02")

	// コスト取得リクエスト
	input := &costexplorer.GetCostAndUsageInput{
		TimePeriod: &types.DateInterval{
			Start: aws.String(start),
			End:   aws.String(end),
		},
		Granularity: "MONTHLY",
		Metrics:     []string{"UnblendedCost"},
	}

	result, err := ceClient.GetCostAndUsage(context.TODO(), input)
	if err != nil {
		return nil, fmt.Errorf("コスト取得に失敗: %v", err)
	}

	// コストを抽出
	if len(result.ResultsByTime) == 0 || len(result.ResultsByTime[0].Total) == 0 {
		return nil, fmt.Errorf("コストデータが見つかりません")
	}

	cost := result.ResultsByTime[0].Total["UnblendedCost"].Amount

	// レスポンスを作成
	return &Response{
		Month: now.Format("2006-01"),
		Cost:  *cost,
	}, nil
}

// Lambda ハンドラ
func handler(ctx context.Context) (LambdaResponse, error) {
	resp, err := getMonthlyCost()

	// Line messaging API の設定
	bot, err := messaging_api.NewMessagingApiAPI(
		os.Getenv("LINE_CHANNEL_TOKEN"),
	)

	if err != nil {
		return LambdaResponse{
			StatusCode: 500,
			Body:       "コスト取得に失敗しました",
		}, err
	}

	// JSON に変換
	jsonResp, err := json.Marshal(resp)
	if err != nil {
		return LambdaResponse{
			StatusCode: 500,
			Body:       "コスト取得に失敗しました",
		}, fmt.Errorf("JSONエンコードに失敗: %v", err)
	}

	message := resp.Month + "のコストは" + string(resp.Cost) + "です!"

	bot.PushMessage(
		&messaging_api.PushMessageRequest{
			To: os.Getenv("LINE_USER_ID"),
			Messages: []messaging_api.MessageInterface{
				messaging_api.TextMessage{
					Text: message,
				},
			},
		},
		"", // x-line-retry-key
	)

	return LambdaResponse{
		StatusCode: 200,
		Body:       string(jsonResp),
	}, nil
}

func main() {
	lambda.Start(handler)
}
