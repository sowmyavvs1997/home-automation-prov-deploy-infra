
#############################################################################
# ECS Task Definition - Backend
#############################################################################

data "template_file" "backend_container_definition" {
  template = file("${path.module}/templates/backend-task-definition.json")

  vars = {
    image = var.ecr_image
    awslogsGroup = var.log_group_name
    awslogsStreamPrefix = var.log_stream_prefix
    awsRegion = var.aws_region
    name = var.container_name
    containerPort = var.container_port
    hostPort = var.host_port
    service_name = var.service_name
    env_name = var.env_name
    config = var.config
    db_host = var.db_host
    db_port = var.db_port
    db_username_secret_arn = var.db_username_secret_arn
    db_password_secret_arn = var.db_password_secret_arn
    db_name = var.db_name
  }
}

resource "aws_ecs_task_definition" "hab-td" {
  family                   = var.ecs_task_definition_name

  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = data.template_file.backend_container_definition.rendered

  volume {
    name = "config-vol"
    host_path = "/opt/properties"
  }

  volume {
    name = "certs-vol"
    host_path = "/opt/certs"
  }

  tags = {
    Name = var.ecs_task_definition_name
  }
}


#############################################################################
# ECS Task Definition - MQTT
#############################################################################

data "template_file" "mqtt_container_definition" {
  template = file("${path.module}/templates/mqtt-task-definition.json")

  vars = {
    image = var.ecr_image
    awslogsGroup = var.log_group_name
    awslogsStreamPrefix = var.log_stream_prefix
    awsRegion = var.aws_region
    name = var.container_name
    containerPort = var.container_port
    hostPort = var.host_port
    service_name = var.service_name
    env_name = var.env_name
    config = var.config
  }
}

resource "aws_ecs_task_definition" "mqtt-td" {
  family                   = var.ecs_task_definition_name
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = data.template_file.mqtt_container_definition.rendered

  tags = {
    Name = var.ecs_task_definition_name
  }
}


