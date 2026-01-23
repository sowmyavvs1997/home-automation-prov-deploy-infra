#############################################################################
# ECS Service - Backend
#############################################################################

resource "aws_ecs_service" "ecs-service-hab" {
  name            = local.service_ecs_config["backend-svc"].ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.hab-td.arn
  desired_count   = local.service_ecs_config["backend-svc"].ecs_service_desire_count

  ordered_placement_strategy {
    type = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_constraints {
    type = "distinctInstance"
  }

  lifecycle {
    create_before_destroy = true
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = local.service_ecs_config["backend-svc"].container_name
    container_port   = local.service_ecs_config["backend-svc"].container_port
  }

  tags = {
    Name = local.service_ecs_config["backend-svc"].ecs_service_name
  }
}

#############################################################################
# ECS Service - MQTT
#############################################################################

resource "aws_ecs_service" "ecs-service-mqtt" {
  name            = local.service_ecs_config["mqtt-svc"].ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.mqtt-td.arn
  desired_count   = local.service_ecs_config["mqtt-svc"].ecs_service_desire_count

  ordered_placement_strategy {
    type = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_constraints {
    type = "distinctInstance"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = local.service_ecs_config["mqtt-svc"].ecs_service_name
  }
}
