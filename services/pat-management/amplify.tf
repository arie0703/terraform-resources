resource "aws_amplify_app" "this" {
  name       = local.app_name
  repository = "https://github.com/${local.github_org}/${local.github_repo}"

  oauth_token = data.aws_secretsmanager_secret_version.common.secret_string["PAT_${local.github_repo}"]

  build_spec = <<EOF
version: 1
applications:
  - backend:
      phases:
        build:
          commands:
            - echo "placeholder"
    frontend:
      phases:
        build:
          commands:
            - npm ci
            - npm run build
      artifacts:
        baseDirectory: out
        files:
          - '**/*'
EOF
}
