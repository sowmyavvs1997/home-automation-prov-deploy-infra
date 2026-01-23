variable "name" {
  description = "Name prefix for secrets"
  type        = string
}

variable "db_username" {
  description = "Database username to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "task_execution_role_id" {
  description = "ECS Task execution role ID for IAM policy attachment"
  type        = string
}
