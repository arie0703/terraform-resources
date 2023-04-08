#######################
#       IAM Role      #
#######################

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
  name   = "${local.app_name}-codepipeline"
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
  name   = "${local.app_name}-codebuild"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_inline_policy.json
}

data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy_attachment" "ecr_power_user" {
  name       = "ecr"
  roles      = ["${aws_iam_role.codebuild.name}"]
  policy_arn = data.aws_iam_policy.ecr_power_user.arn
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
    sid = "EC2"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "ECS"
    actions = [
      "ecs:DescribeTaskDefinition",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "ECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "SecretsManager"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CodeBuild"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
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

# CodeDeployロール
resource "aws_iam_role" "codedeploy" {
  name               = "${local.app_name}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
}

data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codedeploy" {
  name   = "${local.app_name}-codedeploy"
  role   = aws_iam_role.codedeploy.id
  policy = data.aws_iam_policy_document.codedeploy_inline_policy.json
}

data "aws_iam_policy_document" "codedeploy_inline_policy" {

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
    sid = "ECS"
    actions = [
      "ecs:CreateTaskSet",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeServices",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DeleteTaskSet",
    ]
    resources = [
      "*"
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
    sid = "ELB"
    actions = [
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "SecretsManager"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "*"
    ]
  }
}



# タスク実行ロール
resource "aws_iam_role" "task_execution" {
  name               = "${local.app_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json
}

data "aws_iam_policy_document" "task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "task_execution" {
  name   = "${local.app_name}-task-execution"
  role   = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution_inline_policy.json
}

data "aws_iam_policy_document" "task_execution_inline_policy" {

  statement {
    sid = "ECS"
    actions = [
      "ecs:DescribeTaskDefinition",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "ECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "SecretsManager"
    actions = [
      "secretsmanager:GetSecretValue",
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
}

