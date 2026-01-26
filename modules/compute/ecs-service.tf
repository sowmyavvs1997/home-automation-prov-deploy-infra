#############################################################################
# ECS Service
#############################################################################

resource "aws_ecs_service" "this" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.ecs_service_desire_count
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  ordered_placement_strategy {
    type = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_target_group.this, aws_lb.this]

  tags = {
    Name        = var.ecs_service_name
    Project     = var.project_name
    Environment = var.environment
  }
}
