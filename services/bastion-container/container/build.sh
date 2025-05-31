#!/bin/bash

# 環境変数
AWS_ACCOUNT_ID=$1
AWS_REGION=ap-northeast-1
ECR_REPOSITORY_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bastion-container

# 1. ECRログイン
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS \
  --password-stdin ${ECR_REPOSITORY_URL}

# 2. ビルド
docker build --platform linux/amd64 -t bastion .

# 3. タグ付け
docker tag bastion:latest ${ECR_REPOSITORY_URL}:latest

# 4. プッシュ
docker push ${ECR_REPOSITORY_URL}:latest
