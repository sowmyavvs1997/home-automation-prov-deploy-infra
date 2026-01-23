variable "name" {
  description = "Name prefix for ECS resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

#ECS task definition variables
variable "env_name" {type = string}
variable "ecs_cluster_name" {type = string}
variable "ecs_service_name" {type = string}
variable "service_name" {type = string}
variable "ecs_task_definition_name" {type = string}
variable "ecs_service_desire_count" {type = number}
variable "ecr_image" {type = string}
variable "container_name" {type = string}
variable "container_port" {type = number}
variable "host_port" {type = number}
variable "container_memory" {type = number}
variable "subnet_private_ids" {}
variable "ecs_tasks_iam_role" {}
variable "ecs_exec_iam_role" {}
variable "lb_name" {}
variable "lb_port" {type = number}
variable "aws_logs_group" {}
variable "lb_target_group_name" {}
variable "vpc_id" {}
variable "sg_name" {}

# For Ec2
variable "iam_instance_profile" {}
variable "service_linked_role_arn" {}
variable "ami_id" {}
variable "asg_name" {}
variable "asg_min_size" {type = number}
variable "asg_max_size" {type = number}
variable "asg_desired" {type = number}
variable "lt_name" {}
variable "instance_type" {}
variable "instance_name" {}
variable "ssh_port" {type = number}
variable "log_group_name" {}
variable "log_stream_prefix" {}
variable "config" {}





variable "account_id" {}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "task_execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS tasks"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

#############################################################################
# Backend Configuration
#############################################################################

variable "backend_image" {
  description = "Docker image for backend service"
  type        = string
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 1
}

variable "backend_cpu" {
  description = "CPU units for backend task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory in MB for backend task"
  type        = number
  default     = 512
}

variable "backend_log_group" {
  description = "CloudWatch log group for backend"
  type        = string
}

variable "backend_target_group_arn" {
  description = "ALB target group ARN for backend"
  type        = string
}

#############################################################################
# Redis Configuration
#############################################################################

variable "redis_image" {
  description = "Docker image for Redis"
  type        = string
  default     = "redis:7-alpine"
}

variable "redis_desired_count" {
  description = "Desired number of Redis tasks"
  type        = number
  default     = 1
}

variable "redis_cpu" {
  description = "CPU units for Redis task"
  type        = number
  default     = 256
}

variable "redis_memory" {
  description = "Memory in MB for Redis task"
  type        = number
  default     = 512
}

variable "redis_log_group" {
  description = "CloudWatch log group for Redis"
  type        = string
}

#############################################################################
# MQTT Configuration
#############################################################################

variable "mqtt_image" {
  description = "Docker image for MQTT broker"
  type        = string
  default     = "eclipse-mosquitto:2.0"
}

variable "mqtt_desired_count" {
  description = "Desired number of MQTT tasks"
  type        = number
  default     = 1
}

variable "mqtt_cpu" {
  description = "CPU units for MQTT task"
  type        = number
  default     = 256
}

variable "mqtt_memory" {
  description = "Memory in MB for MQTT task"
  type        = number
  default     = 512
}

variable "mqtt_log_group" {
  description = "CloudWatch log group for MQTT"
  type        = string
}

#############################################################################
# Database Configuration
#############################################################################

variable "db_host" {
  description = "RDS database host"
  type        = string
}

variable "db_port" {
  description = "RDS database port"
  type        = number
  default     = 5432
}

variable "db_user" {
  description = "RDS database username"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}
