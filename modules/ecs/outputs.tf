output "backend_service_arn" {
  description = "ARN of backend ECS service"
  value       = aws_ecs_service.ecs-service-hab.arn
}

output "backend_service_name" {
  description = "Name of backend ECS service"
  value       = aws_ecs_service.ecs-service-hab.name
}

output "backend_task_definition_arn" {
  description = "ARN of backend task definition"
  value       = aws_ecs_task_definition.hab-td.arn
}

output "redis_service_arn" {
  description = "ARN of Redis ECS service"
  value       = aws_ecs_service.redis.arn
}

output "redis_service_name" {
  description = "Name of Redis ECS service"
  value       = aws_ecs_service.redis.name
}

output "redis_task_definition_arn" {
  description = "ARN of Redis task definition"
  value       = aws_ecs_task_definition.redis.arn
}

output "mqtt_service_arn" {
  description = "ARN of MQTT ECS service"
  value       = aws_ecs_service.ecs-service-mqtt.arn
}

output "mqtt_service_name" {
  description = "Name of MQTT ECS service"
  value       = aws_ecs_service.ecs-service-mqtt.name
}

output "mqtt_task_definition_arn" {
  description = "ARN of MQTT task definition"
  value       = aws_ecs_task_definition.mqtt-td.arn
}

output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}