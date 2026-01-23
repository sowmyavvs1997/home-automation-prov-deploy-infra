output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_id" {
  description = "ID of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.id
}

output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}
