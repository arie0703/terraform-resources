#!/bin/bash
AWS_ACCOUNT_ID=$1

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com
docker build -t watch-website-batch --provenance=false -f ./lambda_function/Dockerfile ./lambda_function
docker tag watch-website-batch:latest $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/watch-website-batch:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/watch-website-batch:latest
