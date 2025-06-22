# ビルドステージ
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
RUN GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o bootstrap main.go

# 実行ステージ
FROM public.ecr.aws/lambda/provided:al2023

# バイナリを/var/runtime/bootstrapに配置
COPY --from=builder /app/bootstrap /var/runtime/bootstrap

# 実行権限を付与
RUN chmod +x /var/runtime/bootstrap

# 非rootユーザーを作成して指定
USER 1000

# Lambda関数のエントリーポイントを設定
CMD [ "/var/runtime/bootstrap" ] 
