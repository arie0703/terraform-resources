data "aws_s3_bucket" "artifact" {
    bucket = "codepipeline-ap-northeast-1-679957290007"
}

resource "aws_codepipeline" "pipeline" {
    name     = "${var.project}-pipeline"
    role_arn = data.aws_iam_role.pipeline_role.arn
    tags     = {}
    tags_all = {}

    artifact_store {
        location = data.aws_s3_bucket.artifact.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            category         = "Source"
            configuration    = {
                "BranchName"           = "main"
                "OutputArtifactFormat" = "CODE_ZIP"
                "PollForSourceChanges" = "false"
                "RepositoryName"       = aws_codecommit_repository.repo.repository_name
            }
            input_artifacts  = []
            name             = "Source"
            namespace        = "SourceVariables"
            output_artifacts = [
                "SourceArtifact",
            ]
            owner            = "AWS"
            provider         = "CodeCommit"
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
                "ApplicationName"     = aws_codedeploy_app.app.name
                "DeploymentGroupName" = aws_codedeploy_deployment_group.dg.deployment_group_name
            }
            input_artifacts  = [
                "SourceArtifact",
            ]
            name             = "Deploy"
            namespace        = "DeployVariables"
            output_artifacts = []
            owner            = "AWS"
            provider         = "CodeDeploy"
            region           = "ap-northeast-1"
            run_order        = 1
            version          = "1"
        }
    }
}

resource "aws_codedeploy_app" "app" {
    name             = "${var.project}-app"
}

resource "aws_codedeploy_deployment_group" "dg" {
    app_name               = aws_codedeploy_app.app.name
    autoscaling_groups     = []
    deployment_config_name = "CodeDeployDefault.AllAtOnce"
    deployment_group_name  = "${var.project}-group"
    service_role_arn       = data.aws_iam_role.deployment_role.arn
    tags                   = {}
    tags_all               = {}

    deployment_style {
        deployment_option = "WITHOUT_TRAFFIC_CONTROL"
        deployment_type   = "IN_PLACE"
    }

    ec2_tag_set {
        ec2_tag_filter {
            key   = "Name"
            type  = "KEY_AND_VALUE"
            value = aws_instance.ec2.tags["Name"]
        }
    }
}

resource "aws_codecommit_repository" "repo" {
    repository_name = "${var.project}-repo"
}

