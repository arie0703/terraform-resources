resource "aws_ecr_repository" "repository" {
    name                 = "cicd-sandbox-ecr"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}
