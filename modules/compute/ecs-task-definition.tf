#############################################################################
# ECS Task Definition
#############################################################################

data "template_file" "container_definition" {
  template = file("${path.module}/templates/task-definition.json")

  vars = {
    image               = var.ecr_image
    awslogsGroup        = var.aws_logs_group
    awslogsStreamPrefix = var.log_stream_prefix
    awsRegion           = var.aws_region
    containerName       = var.container_name
    containerPort       = var.container_port
    hostPort            = var.host_port
    serviceName         = var.ecs_service_name
    environment         = var.environment
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.ecs_task_definition_name
  container_definitions = data.template_file.container_definition.rendered
  execution_role_arn = var.task_execution_role_arn
  task_role_arn      = var.task_role_arn

  volume {
    name      = "certs-vol"
    host_path = "/opt/gateway/certs"
  }

  volume {
    name      = "props-vol"
    host_path = "/opt/gateway/properties"
  }

  tags = {
    Name        = var.ecs_task_definition_name
    Project     = var.project_name
    Environment = var.environment
  }
}