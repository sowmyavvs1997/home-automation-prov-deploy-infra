terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

   #backend "s3" {
   #  bucket        = "ha-backend-${var.environment}-tf-state"
   # key            = "ha-backend/${var.environment}/terraform.tfstate"
   # region         = var.aws_region
   # dynamodb_table = "ha-backend-${var.environment}-tf-state-lock"
  #}

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
  profile = "PowerUserAccess-223533143333"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

###########################################################
# VPC Module
###########################################################

module "vpc" {
  source = "../../modules/vpc"

  # Project / Environment
  name_prefix = var.name_prefix
  aws_region            = var.aws_region

  # VPC Configuration
  cidr_block            = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
}

#############################################################################
# Compute (ECS + ALB + SG)
#############################################################################

module "compute" {
  source = "../../modules/compute"

  # General
  name                     = "home-automation"
  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  aws_account_id           = var.aws_account_id

  for_each = local.ha_service_names

  # ECS / ALB specifics
  ecs_cluster_name         = lookup(local.service_ecs_config[each.key], "ecs_cluster_name")
  ecs_service_name         = lookup(local.service_ecs_config[each.key], "ecs_service_name")
  ecs_service_desire_count = lookup(local.service_ecs_config[each.key], "ecs_service_desire_count")
  ecs_task_definition_name = lookup(local.service_ecs_config[each.key], "ecs_task_definition_name")
  ecr_image                = lookup(local.service_ecs_config[each.key], "ecr_image")
  container_name           = lookup(local.service_ecs_config[each.key], "container_name")
  container_port           = lookup(local.service_ecs_config[each.key], "container_port")
  host_port                = lookup(local.service_ecs_config[each.key], "host_port")
  container_memory         = lookup(local.service_ecs_config[each.key], "container_memory")

  # VPC
  private_subnet_ids       = module.vpc.private_subnet_ids

  # ASG
  asg_name = lookup(local.service_ecs_config[each.key], "asg_name")
  asg_max_size = lookup(local.service_ecs_config[each.key], "asg_max_size")
  asg_min_size = lookup(local.service_ecs_config[each.key], "asg_min_size")
  asg_desired = lookup(local.service_ecs_config[each.key], "asg_desired")
  lt_name = lookup(local.service_ecs_config[each.key], "lt_name")

  #IAM
  iam_instance_profile = "${var.environment}-InstanceProfile"


  # Alb
  lb_name                  = lookup(local.service_ecs_config[each.key], "lb_name")
  lb_target_group_name     = lookup(local.service_ecs_config[each.key], "lb_target_group_name")
  lb_port                  = lookup(local.service_ecs_config[each.key], "lb_port")

  # Security Group
  sg_name = lookup(local.service_ecs_config[each.key], "sg_name")
  security_group_id        = module.compute.sg_id
  task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  task_role_arn            = module.iam.ecs_task_role_arn
  health_check_path        = "/_health"

  # Ec2
  ami_id = lookup(local.service_ecs_config[each.key], "ami_id")
  aws_logs_group = lookup(local.service_ecs_config[each.key], "aws_logs_group")
  log_group_name = lookup(local.service_ecs_config[each.key], "log_group_name")
  log_stream_prefix = lookup(local.service_ecs_config[each.key], "log_stream_prefix")
  instance_type = lookup(local.service_ecs_config[each.key], "instance_type")
  instance_name = lookup(local.service_ecs_config[each.key], "instance_name")
  ssh_port      = lookup(local.service_ecs_config[each.key], "ssh_port")

}

#############################################################################
# IAM Global (IAM)
#############################################################################

module "iam" {
  source = "../../modules/global/iam"

  project_name = var.project_name
  environment  = var.environment
}




