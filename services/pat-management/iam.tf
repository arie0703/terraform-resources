data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_org}/${local.github_repo}:ref:refs/heads/main"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "gha-create-pat-role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
}


resource "aws_iam_role_policy" "github_actions_policy" {
  role = aws_iam_role.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:ap-northeast-1:${data.aws_caller_identity.current.account_id}:secret:common-secrets-*"
      }
    ]
  })
}
