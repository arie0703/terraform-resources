resource "aws_codepipeline" "pipeline" {
    name     = "sandbox-cicd-pipeline"
    role_arn = data.aws_iam_role.pipeline_role.arn
    artifact_store {
        location = var.artifact_input
        type     = "S3"
    }

    stage {
        name = "Source"
        action {
            category         = "Source"
            configuration    = {
                "RepositoryName" = var.ecr_repository_name
            }
            input_artifacts  = []
            name             = "Source"
            namespace        = "SourceVariables"
            output_artifacts = [
                "SourceArtifact",
            ]
            owner            = "AWS"
            provider         = "ECR"
            region           = "ap-northeast-1"
            run_order        = 1
            version          = "1"
        }
        action {
            category         = "Source"
            configuration    = {
                "PollForSourceChanges" = "false"
                "S3Bucket"             = var.artifact_output
                "S3ObjectKey"          = "imagedefinitions.json.zip"
            }
            input_artifacts  = []
            name             = "S3input"
            output_artifacts = [
                "OutArtifact",
            ]
            owner            = "AWS"
            provider         = "S3"
            region           = "ap-northeast-1"
            run_order        = 1
            version          = "1"
        }
    }
    stage {
        name = "Deploy"

        action {
            category         = "Deploy"
            configuration    = {
                "ClusterName" = var.ecs_cluster_name
                "FileName"    = "imagedefinitions.json"
                "ServiceName" = var.ecs_service_name
            }
            input_artifacts  = [
                "OutArtifact",
            ]
            name             = "Deploy"
            namespace        = "DeployVariables"
            output_artifacts = []
            owner            = "AWS"
            provider         = "ECS"
            region           = "ap-northeast-1"
            run_order        = 1
            version          = "1"
        }
    }
}

# data管理の資産はあらかじめ作成しておく
data "aws_iam_role" "pipeline_role" {
    name = "AWSCodePipelineServiceRole-ap-northeast-1-test"
}
