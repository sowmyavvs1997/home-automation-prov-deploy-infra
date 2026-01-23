terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

#############################################################################
# Data Sources
#############################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

#############################################################################
# VPC Module
#############################################################################
module "vpc" {
  source               = "../../modules/vpc"
  name                 = local.name_prefix
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
}

#############################################################################
# Global IAM Module (ECS roles)
#############################################################################

module "global_iam" {
  source = "../../modules/global/iam"
  name_prefix = local.name_prefix
}

#############################################################################
# Secrets Manager Module (Database Credentials)
#############################################################################

module "secrets" {
  source = "../../modules/secrets"

  name                      = local.name_prefix
  db_username               = var.db_username
  db_password               = var.db_password
  task_execution_role_id    = module.global_iam.ecs_task_execution_role_id
}

#############################################################################
# Compute Module (ECS Cluster, ALB, Log Groups, ASG, Services)
#############################################################################

module "compute" {
  source = "../../modules/compute"

  name               = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc_cidr
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  log_retention_days = var.log_retention_days
  aws_region         = var.aws_region
}

#############################################################################
# RDS Module (PostgreSQL Database)
#############################################################################

module "rds" {
  source = "../../modules/rds"

  identifier              = "${local.name_prefix}-db"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  multi_az                = false
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period
  publicly_accessible     = false
  enable_iam_auth         = true

  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.compute.ecs_tasks_security_group_id]
}

#############################################################################
# ElastiCache Module (Redis)
#############################################################################

module "elasticache" {
  source = "../../modules/elasticache"

  name                     = local.name_prefix
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  ecs_security_group_id    = module.compute.ecs_tasks_security_group_id
  node_type                = var.redis_node_type
  num_cache_nodes          = var.redis_num_nodes
  redis_engine_version     = var.redis_engine_version
  redis_port               = var.redis_port
  automatic_failover_enabled = var.redis_automatic_failover
  multi_az_enabled         = var.redis_multi_az
  at_rest_encryption_enabled = var.redis_at_rest_encryption
  transit_encryption_enabled = var.redis_transit_encryption
  parameter_family         = var.redis_parameter_family
  maintenance_window       = var.redis_maintenance_window
}

#############################################################################
# ECS Module (Task Definitions and Services)
# COMMENTED OUT - Infrastructure complete with compute module
# Services are defined in compute/services.tf and task-definition.tf
#############################################################################

# module "ecs" {
#   source = "../../modules/ecs"
#   ... see compute module for services and task definitions
# }



