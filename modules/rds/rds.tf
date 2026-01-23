#############################################################################
# RDS Subnet Group
#############################################################################

resource "aws_db_subnet_group" "this" {
  name_prefix = "ha-"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

#############################################################################
# RDS PostgreSQL Instance
#############################################################################

resource "aws_db_instance" "this" {
  identifier            = var.identifier
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_encrypted     = true
  storage_type          = "gp3"
  iops                  = 3000
  db_name               = var.db_name
  username              = var.username
  password              = var.password
  db_subnet_group_name  = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  # High availability and backup settings
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Performance and monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]

  # IAM database authentication
  iam_database_authentication_enabled = var.enable_iam_auth

  # Deletion protection
  deletion_protection = true
  skip_final_snapshot = var.skip_final_snapshot

  tags = {
    Name = var.identifier
  }

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring]
}

#############################################################################
# RDS Monitoring IAM Role
#############################################################################

resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

#############################################################################
# CloudWatch Log Group
#############################################################################

resource "aws_cloudwatch_log_group" "postgres" {
  name              = "/aws/rds/instance/${var.identifier}/postgresql"
  retention_in_days = 30

  tags = {
    Name = "${var.identifier}-postgres-logs"
  }
}
