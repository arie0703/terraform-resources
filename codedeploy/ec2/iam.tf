# SSMとS3へのアクセス許可ポリシーを含む
data "aws_iam_role" "ec2_role" {
    name = "SSM_EC2"
}

data "aws_iam_role" "pipeline_role" {
    name = "${var.project}-pipeline-service-role"
}

# EC2インスタンスへのアクセス許可ポリシーを含む
data "aws_iam_role" "deployment_role" {
    name = "${var.project}-service-role"
}
