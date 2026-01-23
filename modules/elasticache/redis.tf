#############################################################################
# ElastiCache Subnet Group
#############################################################################

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-redis-subnet-group"
  }
}

#############################################################################
# ElastiCache Redis Cluster
#############################################################################

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}-redis"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = var.redis_engine_version
  port                 = var.redis_port
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  maintenance_window      = var.maintenance_window
  notification_topic_arn  = var.notification_topic_arn

  tags = {
    Name = "${var.name}-redis-cluster"
  }

  depends_on = [aws_security_group.redis]
}

#############################################################################
# ElastiCache Parameter Group
#############################################################################

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${var.name}-redis-params"
  family = var.parameter_family

  # Common Redis configurations
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = {
    Name = "${var.name}-redis-parameter-group"
  }
}

#############################################################################
# Security Group for Redis
#############################################################################

resource "aws_security_group" "redis" {
  name_prefix = "${var.name}-redis-"
  description = "Security group for Redis ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
    description     = "Redis port from ECS"
  }

  ingress {
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Redis port from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-redis-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
