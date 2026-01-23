#############################################################################
# VPC Outputs
#############################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

#############################################################################
# Compute (ECS Cluster & ALB) Outputs
#############################################################################

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.compute.ecs_cluster_arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.compute.alb_dns_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = module.compute.alb_arn
}

output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = module.compute.backend_target_group_arn
}

#############################################################################
# RDS Outputs
#############################################################################

output "rds_endpoint" {
  description = "RDS database endpoint (address:port)"
  value       = module.rds.db_instance_endpoint
  sensitive   = false
}

output "rds_address" {
  description = "RDS database address"
  value       = module.rds.db_instance_address
}

output "rds_port" {
  description = "RDS database port"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "rds_resource_id" {
  description = "RDS resource ID (for IAM authentication)"
  value       = module.rds.db_resource_id
}

#############################################################################
#############################################################################
# CloudWatch Log Groups
#############################################################################

output "backend_log_group" {
  description = "CloudWatch log group for backend"
  value       = module.compute.backend_log_group_name
}

output "mqtt_log_group" {
  description = "CloudWatch log group for MQTT"
  value       = module.compute.mqtt_log_group_name
}

#############################################################################
# Application Access Information
#############################################################################

output "application_endpoint" {
  description = "Application endpoint (via ALB)"
  value       = "http://${module.compute.alb_dns_name}"
}

output "mqtt_endpoint" {
  description = "MQTT broker endpoint (internal)"
  value       = "mqtt://mqtt:1883"
}

output "redis_endpoint" {
  description = "Redis endpoint (internal)"
  value       = "redis://redis:6379"
}