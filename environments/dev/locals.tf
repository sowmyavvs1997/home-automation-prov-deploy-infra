locals {
  ha_service_names = toset([
    "ha-backend-svc",
    "ha-mqtt-svc"
  ])

  name_prefix = "home-automation"

  service_ecs_config = {
    "backend-svc" = {
      "ecs_cluster_name"         = "${var.project_name}-${var.environment}-backendSvcEcsCluster"
      "ecs_service_name"         = "${var.project_name}-${var.environment}-backendSvcEcsService"
      "ecs_service_desire_count" = 2
      "ecs_task_definition_name" = "${var.project_name}-${var.environment}-backendSvcEcsTd"
      "ecr_image"                = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/home-automation-backend-ecr:${var.hab-svc_ecr_image_tag}"
      "container_name"           = "${var.project_name}-${var.environment}-backendSvcContainer"
      "lb_target_group_name"     = "${var.project_name}-${var.environment}-backendSvcTG"
      "lb_name"                  = "${var.project_name}-${var.environment}-backendSvcLB"
      "container_port"           = 8080
      "host_port"                = 8080
      "lb_port"                  = "80"
      "aws_logs_group"            = "${var.project_name}-${var.environment}-backendSvcLog"
      "sg_name"                  = "${var.project_name}-${var.environment}-backendSvcSg"
      "container_memory"         = 1024
      "asg_name"                 = "${var.project_name}-${var.environment}-backendSvcAsg"
      "asg_min_size"             = 2
      "asg_max_size"             = 2
      "asg_desired"              = 2
      "lc_name"                  = "${var.project_name}-${var.environment}-backendSvcLc"
      "ami_id"                   = ""
      "instance_type"            = "t3.micro"
      "instance_name"            = "${var.project_name}-${var.environment}-backendSvcInstance"
      "ssh_port"                 = "22"
      "log_group_name"           = "application_log"
      "log_stream_prefix"        = "${var.project_name}-${var.environment}-backendSvc"
    }

    "mqtt-svc" = {
      "ecs_cluster_name"         = "${var.project_name}-${var.environment}-mqttSvcEcsCluster"
      "ecs_service_name"         = "${var.project_name}-${var.environment}-mqttSvcEcsService"
      "ecs_service_desire_count" = 2
      "ecs_task_definition_name" = "${var.project_name}-${var.environment}-mqttSvcEcsTd"
      "ecr_image"                = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/home-automation-mqtt-ecr:${var.hab-svc_ecr_image_tag}"
      "container_name"           = "${var.project_name}-${var.environment}-mqttSvcContainer"
      "lb_target_group_name"     = "${var.project_name}-${var.environment}-mqttSvcTG"
      "lb_name"                  = "${var.project_name}-${var.environment}-mqttSvcLB"
      "container_port"           = 1883
      "host_port"                = 1883
      "lb_port"                  = "80"
      "aws_logs_group"            = "${var.project_name}-${var.environment}-mqttSvcLog"
      "sg_name"                  = "${var.project_name}-${var.environment}-mqttSvcSg"
      "container_memory"         = 1024
      "asg_name"                 = "${var.project_name}-${var.environment}-mqttSvcAsg"
      "asg_min_size"             = 2
      "asg_max_size"             = 2
      "asg_desired"              = 2
      "lc_name"                  = "${var.project_name}-${var.environment}-mqttSvcLc"
      "ami_id"                   = ""
      "instance_type"            = "t3.micro"
      "instance_name"            = "${var.project_name}-${var.environment}-mqttSvcInstance"
      "ssh_port"                 = "22"
      "log_group_name"           = "application_log"
      "log_stream_prefix"        = "${var.project_name}-${var.environment}-mqttSvc"
    }
  }
}


