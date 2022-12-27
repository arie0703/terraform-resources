# simple_pipeline_s3

S3 bucketの入力アーティファクトをトリガーにコンテナをデプロイするCodePipeline
imagedefinitions.jsonに以下を記述

```json
[
    {
        "name":"httpd-container",
        "imageUri":"${REPOSITORY_URI}:latest"
    }
]
```

## 参考
https://qiita.com/arie0703/items/f9daef1aee67ce05794b
