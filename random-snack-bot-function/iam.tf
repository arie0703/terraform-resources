# Lambda
resource "aws_iam_role" "lambda" {
  name               = "${local.app_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${local.app_name}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_inline_policy.json
}

data "aws_iam_policy_document" "lambda_inline_policy" {
  statement {
    sid = "IAM"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "DynamoDB"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
    ]
    resources = [
      "*"
    ]
  }
}


# CodePipelineロール
resource "aws_iam_role" "codepipeline" {
  name               = "${local.app_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${local.app_name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_inline_policy.json
}

data "aws_iam_policy_document" "codepipeline_inline_policy" {
  statement {
    sid = "IAM"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "S3"
    actions = [
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketVersioning",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    sid = "ECS"
    actions = [
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeServices",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CodeBuild"
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CodeDeploy"
    actions = [
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetDeployment",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetApplication",
      "codedeploy:CreateDeployment",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CodeStar"
    actions = [
      "codestar-connections:UseConnection",
    ]
    resources = [
      "*"
    ]
  }
}

# CodeBuildロール
resource "aws_iam_role" "codebuild" {
  name               = "${local.app_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name   = "${local.app_name}-codebuild-policy"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_inline_policy.json
}

data "aws_iam_policy_document" "codebuild_inline_policy" {
  statement {
    sid = "S3"
    actions = [
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CloudWatch"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    sid = "ECR"
    actions = [
      "ecr:UploadLayerPart",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "Lambda"
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CodeStar"
    actions = [
      "codestar-connections:UseConnection",
    ]
    resources = [
      "*"
    ]
  }
}
