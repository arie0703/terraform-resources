# terraform-resources
TerraformによるAWSリソースの管理をするリポジトリ。

ECSやIAMロールなど、各サービスで利用する共通設定はmoduleを活用する。

tfstateはS3で管理する。