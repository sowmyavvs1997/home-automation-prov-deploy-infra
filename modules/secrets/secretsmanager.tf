#############################################################################
# AWS Secrets Manager - Database Credentials
#############################################################################

resource "aws_secretsmanager_secret" "db_username" {
  name_prefix = "${var.name}-db-username-"
  description = "RDS database username for ${var.name}"

  tags = {
    Name = "${var.name}-db-username"
  }
}

resource "aws_secretsmanager_secret_version" "db_username" {
  secret_id     = aws_secretsmanager_secret.db_username.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.name}-db-password"
  description = "RDS database password for ${var.name}"

  tags = {
    Name = "${var.name}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

#############################################################################
# IAM Policy for ECS Task Execution Role to Access Secrets
#############################################################################

resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "${var.name}-ecs-secrets"
  role        = var.task_execution_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.db_username.arn,
          aws_secretsmanager_secret.db_password.arn
        ]
      }
    ]
  })
}
