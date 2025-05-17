resource "aws_iam_role" "gha" {
  name               = "gha-amplify-next-role"
  assume_role_policy = data.aws_iam_policy_document.gha.json
}

resource "aws_iam_role_policy_attachment" "gha_secrets" {
  role       = aws_iam_role.gha.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "gha_amplify" {
  role       = aws_iam_role.gha.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

resource "aws_iam_role_policy_attachment" "gha_logs" {
  role       = aws_iam_role.gha.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

data "aws_iam_policy_document" "gha" {
  statement {
    sid     = "OidcAllowAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.gha.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_repo]
    }
  }
}

# モジュール外で作成されている想定
data "aws_iam_openid_connect_provider" "gha" {
  url = "https://token.actions.githubusercontent.com"
}
