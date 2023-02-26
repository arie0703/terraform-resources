# CodeDeploy + CodeCommit + EC2

CodeCommitへのpushをトリガーにEC2にApacheアプリをデプロイするパイプライン構築

## CodeCommit用のディレクトリ作成 

`mkdir app`

`cp -r app_example app`

`cd app`

`git init`

`git remote add origin ${codecommit_repo_uri}`

CodeCommitに接続し、pushできるようになればOK

## IAMロールの作成

- EC2
  - アーティファクトバケット(S3)へのアクセス権限を付与
- CodeDeploy
  - 今回作成するEC2インスタンスへのアクセス権限を付与

## コマンド

デプロイ失敗時はエージェントのログを見る

`tail -F /var/log/aws/codedeploy-agent/codedeploy-agent.log`

エージェントのステータス確認

`systemctl status codedeploy-agent`

apacheのステータス確認

`sudo systemctl status httpd`





