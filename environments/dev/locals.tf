locals {
  ha_service_names = toset([
    "ha-backend",
    "ha-mqtt"
  ])

  name_prefix = "ha"

  service_ecs_config = {
    "backend-svc" = {
      "ecs_cluster_name"         = "${var.name_prefix}-${var.environment}-backendSvcEcsCluster"
      "ecs_service_name"         = "${var.name_prefix}-${var.environment}-backendSvcEcsService"
      "ecs_service_desire_count" = 2
      "ecs_task_definition_name" = "${var.name_prefix}-${var.environment}-backendSvcEcsTd"
      "ecr_image"                = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/home-automation-backend-ecr:${var.backend_image_tag}"
      "container_name"           = "${var.name_prefix}-${var.environment}-backendSvcContainer"
      "container_port"           = 8080
      "host_port"                = 8080
      "container_memory"         = 1024

      "lb_port"                  = "80"
      "lb_target_group_name"     = "${var.name_prefix}-${var.environment}-backendSvcTG"
      "lb_name"                  = "${var.name_prefix}-${var.environment}-backendSvcLB"
      "aws_logs_group"            = "${var.name_prefix}-${var.environment}-backendSvcLog"
      "sg_name"                  = "${var.name_prefix}-${var.environment}-backendSvcSg"
      "asg_name"                 = "${var.name_prefix}-${var.environment}-backendSvcAsg"
      "asg_min_size"             = 2
      "asg_max_size"             = 2
      "asg_desired"              = 2
      "lt_name"                  = "${var.name_prefix}-${var.environment}-backendSvcLt"

      "ami_id"                   = ""
      "instance_type"            = "t3.micro"
      "instance_name"            = "${var.name_prefix}-${var.environment}-backendSvcInstance"
      "ssh_port"                 = "22"
      "log_group_name"           = "application_log"
      "log_stream_prefix"        = "${var.name_prefix}-${var.environment}-backendSvc"
    }

    "mqtt-svc" = {
      "ecs_cluster_name"         = "${var.name_prefix}-${var.environment}-mqttSvcEcsCluster"
      "ecs_service_name"         = "${var.name_prefix}-${var.environment}-mqttSvcEcsService"
      "ecs_service_desire_count" = 2
      "ecs_task_definition_name" = "${var.name_prefix}-${var.environment}-mqttSvcEcsTd"
      "ecr_image"                =  var.mqtt_image
      "container_name"           = "${var.name_prefix}-${var.environment}-mqttSvcContainer"
      "lb_target_group_name"     = "${var.name_prefix}-${var.environment}-mqttSvcTG"
      "lb_name"                  = "${var.name_prefix}-${var.environment}-mqttSvcLB"
      "container_port"           = 1883
      "host_port"                = 1883
      "lb_port"                  = "80"
      "aws_logs_group"            = "${var.name_prefix}-${var.environment}-mqttSvcLog"
      "sg_name"                  = "${var.name_prefix}-${var.environment}-mqttSvcSg"
      "container_memory"         = 1024
      "asg_name"                 = "${var.name_prefix}-${var.environment}-mqttSvcAsg"
      "asg_min_size"             = 2
      "asg_max_size"             = 2
      "asg_desired"              = 2
      "lt_name"                  = "${var.name_prefix}-${var.environment}-mqttSvcLt"
      "ami_id"                   = ""
      "instance_type"            = "t3.micro"
      "instance_name"            = "${var.name_prefix}-${var.environment}-mqttSvcInstance"
      "ssh_port"                 = "22"
      "log_group_name"           = "application_log"
      "log_stream_prefix"        = "${var.name_prefix}-${var.environment}-mqttSvc"
    }
  }
}


