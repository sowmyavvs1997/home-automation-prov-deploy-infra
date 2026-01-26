output "ecs_instance_profile" {
  value = data.aws_cloudformation_export.ec2-instance-profile.value
}

output "ecs_task_role_arn_from_tf" {
  value = data.aws_cloudformation_export.ecs-role-arn.value
}

output "ecs_task_role_name_from_tf" {
  value = data.aws_cloudformation_export.ecs-role-name.value
}
