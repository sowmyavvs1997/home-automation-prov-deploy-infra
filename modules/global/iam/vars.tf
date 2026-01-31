variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_exec_iam_role" {}
variable "aws_account_id" {}
variable "ecs_tasks_iam_role" {}
variable "s3_service_policy" {}