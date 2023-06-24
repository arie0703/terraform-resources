resource "aws_lb" "this" {
  load_balancer_type = "application"
  name               = local.app_name
  internal           = false
  security_groups    = [aws_security_group.lb.id]
  subnets            = ["${data.aws_subnet.public_a.id}", "${data.aws_subnet.public_c.id}"]
}

resource "aws_lb_target_group" "blue" {
  name = "${local.app_name}-blue"

  vpc_id = data.aws_vpc.this.id

  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_target_group" "green" {
  name = "${local.app_name}-green"

  vpc_id = data.aws_vpc.this.id

  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener" "blue_prod" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  /* デプロイ時にターゲットが切り替わって差分が出るので、ignore_changesを設定 */
  lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_lb_listener" "blue_test" {
  load_balancer_arn = aws_lb.this.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  /* デプロイ時にターゲットが切り替わって差分が出るので、ignore_changesを設定 */
  lifecycle {
    ignore_changes = [default_action]
  }
}

