#############################################################################
# ECS Task Execution Role (for pulling images and writing logs)
#############################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name_prefix = "${var.name_prefix}-ecs-task-exec-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-ecs-task-execution-role"
  }
}

# Attach the default ECS task execution role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow pulling from ECR (least-privilege)
resource "aws_iam_role_policy" "ecs_task_execution_ecr_policy" {
  name_prefix = "${var.name_prefix}-ecs-ecr-"
  role        = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

#############################################################################
# ECS Task Role (for application permissions)
#############################################################################

resource "aws_iam_role" "ecs_task_role" {
  name_prefix = "${var.name_prefix}-ecs-task-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-ecs-task-role"
  }
}

# Least-privilege policy for RDS access
resource "aws_iam_role_policy" "ecs_task_rds_policy" {
  name_prefix = "${var.name_prefix}-ecs-rds-"
  role        = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = "arn:aws:rds:*:*:db/*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:*"
      }
    ]
  })
}

#############################################################################
# RDS IAM Database Authentication Role
#############################################################################

resource "aws_iam_role" "rds_iam_auth_role" {
  name_prefix = "${var.name_prefix}-rds-iam-auth-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-rds-iam-auth-role"
  }
}

resource "aws_iam_role_policy" "rds_iam_auth_policy" {
  name_prefix = "${var.name_prefix}-rds-iam-auth-"
  role        = aws_iam_role.rds_iam_auth_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = "arn:aws:rds-db:*:*:dbuser:*/*"
      }
    ]
  })
}
