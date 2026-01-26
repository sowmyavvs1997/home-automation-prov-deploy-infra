# General
variable "name" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "aws_account_id" {}

# VPC & subnets
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

# ECS
variable "ecs_cluster_name" { type = string }
variable "ecs_service_name" { type = string }
variable "ecs_service_desire_count" { type = number }
variable "ecs_task_definition_name" { type = string }

variable "task_execution_role_arn" { type = string }
variable "task_role_arn" { type = string }

# Container
variable "container_name" { type = string }
variable "container_port" { type = number }
variable "host_port" { type = number }
variable "container_memory" { type = number }
variable "ecr_image" { type = string }

# Load Balancer
variable "lb_name" { type = string }
variable "lb_target_group_name" { type = string }
variable "lb_port" { type = number }

# EC2 / ASG / SG
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "instance_name" {}
variable "iam_instance_profile" { type = string }
variable "asg_name" { type = string }
variable "asg_min_size" { type = number }
variable "asg_max_size" { type = number }
variable "asg_desired" { type = number }
variable "lt_name" { type = string }
variable "security_group_id" { type = string }

# Logging
variable "aws_logs_group" { type = string }
variable "log_group_name" { type = string }
variable "log_stream_prefix" { type = string }

# Security / SSH
variable "sg_name" { type = string }
variable "ssh_port" { type = number }
variable "health_check_path" { type = string, default = "/" }
