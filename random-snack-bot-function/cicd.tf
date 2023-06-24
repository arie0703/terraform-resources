#######################
#    CICD Artifact    #
#######################

resource "aws_s3_bucket" "artifact" {
  bucket = "${local.app_name}-pipeline-artifacts"
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

# artifactのライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.bucket

  rule {
    id = "delete-artifact-in-a-year"

    expiration {
      days = 365
    }

    status = "Enabled"
  }
}

#######################
#  CodeStarConnection #
#######################

resource "aws_codestarconnections_connection" "github" {
  name          = "github"
  provider_type = "GitHub"
}

#######################
#     CodePipeline    #
#######################
resource "aws_codepipeline" "this" {
  name     = local.app_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = 1
      output_artifacts = ["source"]
      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = var.repository_id
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

}

#######################
#      CodeBuild      #
#######################
resource "aws_codebuild_project" "this" {
  name         = local.app_name
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.app_name}"
    }
  }
}
