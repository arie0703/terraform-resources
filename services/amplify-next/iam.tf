module "iam_role" {
  source      = "../../modules/amplify-next/iam-gha-role"
  github_repo = "repo:arie0703/terraform-resources/*"
}
