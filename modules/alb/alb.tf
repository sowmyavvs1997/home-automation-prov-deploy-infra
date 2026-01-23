resource "aws_lb_target_group" "tg" {
  name = var.lb_target_group_name
  port = var.container_port
  protocol = var.protocol
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    protocol = "HTTP"
    timeout = 5
    port = 8080
    path = "/_health"
    interval = 30
    healthy_threshold = 5
    unhealthy_threshold = 5
    matcher = 404
  }
}

resource "aws_lb" "lb" {
  name = var.lb_name
  internal = true
  load_balancer_type = "application"
  security_groups = [var.security_group_id]
  subnets = var.subnet_private_ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port = var.lb_port
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}