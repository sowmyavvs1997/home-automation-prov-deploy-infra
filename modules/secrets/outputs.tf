output "db_username_secret_arn" {
  description = "ARN of the database username secret"
  value       = aws_secretsmanager_secret.db_username.arn
}

output "db_password_secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}
