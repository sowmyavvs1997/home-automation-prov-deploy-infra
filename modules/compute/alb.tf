#############################################################################
# Application Load Balancer
#############################################################################

resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = true
  load_balancer_type = "application"

  security_groups = [var.lb_security_group_id]
  subnets         = var.private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = var.lb_name
    Environment = var.environment
    Project     = var.project_name
  }
}

#############################################################################
# Target Group
#############################################################################

resource "aws_lb_target_group" "this" {
  name     = var.lb_target_group_name
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = var.health_check_path
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.lb_name}-tg"
    Environment = var.environment
    Project     = var.project_name
  }
}

#############################################################################
# Listener
#############################################################################

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
