# Coding Rule

- terraform.tfにprovider, backendの情報を記載する
- backendはAmazon S3とし、bucket名は"arie-terraform-states", keyは"${作業ディレクトリ名}/terraform.tfstate"とする
- regionは基本的にap-northeast-1を指定する
- 変数はvariables.tfに記載する
- Lambdaのソースコードは作業ディレクトリ内にsrc/ディレクトリを作成し、その中にソースコードを格納する
- Lambdaのランタイムは指定がない場合はnode.jsを使用する
- リソースごとにファイルを分ける。例: dynamodbに関連するリソースはdynamodb.tfに定義する
