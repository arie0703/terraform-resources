data "aws_iam_policy" "ecs_task_execution_role_policy_source" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
data "aws_iam_policy_document" "ecs_task_execution_role_policy_document" {
    source_json = data.aws_iam_policy.ecs_task_execution_role_policy_source.policy
    statement {
        effect    = "Allow"
        actions   = ["logs:CreateLogGroup"]
        resources = ["*"]
    }
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name               = "sandbox-cicd-task-execution-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "ecs_task_execution_role_policy" {
    name   = "sandbox-cicd-task-execution-role-policy"
    policy = data.aws_iam_policy_document.ecs_task_execution_role_policy_document.json
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = aws_iam_policy.ecs_task_execution_role_policy.arn
}
