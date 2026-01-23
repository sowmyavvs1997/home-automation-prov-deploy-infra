output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = aws_lb_target_group.backend.arn
}

output "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "backend_log_group_name" {
  description = "CloudWatch log group name for backend"
  value       = aws_cloudwatch_log_group.backend.name
}

output "mqtt_log_group_name" {
  description = "CloudWatch log group name for MQTT"
  value       = aws_cloudwatch_log_group.mqtt.name
}
