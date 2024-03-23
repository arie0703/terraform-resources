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
      output_artifacts = ["source_artifacts"]
      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "arie0703/sandbox-nest"
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
      input_artifacts  = ["source_artifacts"]
      output_artifacts = ["build_artifacts"]
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      run_order       = 1
      input_artifacts = ["build_artifacts", "source_artifacts"]
      configuration = {
        ApplicationName                = aws_codedeploy_app.this.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.this.deployment_group_name
        TaskDefinitionTemplateArtifact = "build_artifacts"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "source_artifacts"
        AppSpecTemplatePath            = "appspec.yml"
        Image1ArtifactName             = "build_artifacts"
        Image1ContainerName            = "IMAGE_NAME"
      }
    }
  }

}

# Source Artifact
resource "aws_s3_bucket" "artifact" {
  bucket = "${local.app_name}-pipeline-artifacts"
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

# codeconnection
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.app_name}-github"
  provider_type = "GitHub"
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
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ENV"
      value = "PRODUCTION"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "AWS_LOCALSTACK_REGION"
      value = "ap-northeast-1"
    }

    environment_variable {
      name  = "AWS_LOCALSTACK_ENDPOINT"
      value = "None"
    }

    environment_variable {
      name  = "SQS_QUEUE_URL"
      value = aws_sqs_queue.this.url
    }

    environment_variable {
      name  = "NOTION_SECRET"
      value = aws_secretsmanager_secret.notion.arn
    }

    environment_variable {
      name  = "NOTION_DATABASE_ID"
      value = var.notion_database_id
    }

    environment_variable {
      name  = "SLACK_WORKFLOW_URL"
      value = "dummy"
    }

    environment_variable {
      name  = "NEW_RELIC_APP_NAME"
      value = local.app_name
    }

    environment_variable {
      name  = "NEW_RELIC_LICENSE_KEY"
      value = aws_secretsmanager_secret.newrelic_license_key.arn
    }

    environment_variable {
      name  = "NEW_RELIC_ACCOUNT_ID"
      value = local.newrelic_accound_id
    }

    environment_variable {
      name  = "NEW_RELIC_TRUSTED_ACCOUNT_KEY"
      value = local.newrelic_accound_id
    }

    environment_variable {
      name  = "TASK_FAMILY"
      value = aws_ecs_task_definition.this.family
    }

    environment_variable {
      name  = "TASK_EXECUTION_ROLE_ARN"
      value = aws_iam_role.task_execution.arn
    }
    environment_variable {
      name  = "TASK_ROLE_ARN"
      value = aws_iam_role.task.arn
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.app_name}"
    }
  }
}


#######################
#      CodeDeploy     #
#######################

resource "aws_codedeploy_app" "this" {
  name             = local.app_name
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "this" {
  deployment_group_name  = "${local.app_name}-deploy"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  app_name               = aws_codedeploy_app.this.name
  service_role_arn       = aws_iam_role.codedeploy.arn

  # ECSのデプロイではBlue/Greenである必要がある。
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE"
    ]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 60
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.this.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
          aws_lb_listener.blue_prod.arn
        ]
      }
      test_traffic_route {
        listener_arns = [
          aws_lb_listener.blue_test.arn
        ]
      }
      target_group {
        name = aws_lb_target_group.blue.name
      }
      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}
