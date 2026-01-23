#############################################################################
# Core Variables
#############################################################################
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ha"
}

#############################################################################
# Terraform Backend Variables
#############################################################################

variable "tf_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state-home-automation"
}

variable "tf_state_key" {
  description = "Key path in S3 for Terraform state file"
  type        = string
  default     = "home-automation/dev/terraform.tfstate"
}

variable "tf_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}

#############################################################################
# VPC Variables
#############################################################################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "The ID of the VPC in your AWS Account"
  type        = string
  default     = ""
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

#############################################################################
# Compute Variables
#############################################################################

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "aws_logs_group" {
  description = "CloudWatch log group"
  type        = string
  default     = "application_log"
}

#############################################################################
# RDS Variables
#############################################################################

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "homeautomation"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "haadmin"
  validation {
    condition     = length(var.db_username) > 0
    error_message = "Database username cannot be empty."
  }
}

variable "db_password" {
  description = "Database master password (REQUIRED - provide via tfvars or environment variable)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters."
  }
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on RDS deletion"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

#############################################################################
# ECS - Backend Variables
#############################################################################

variable "hab-svc_ecr_image_tag" {
  type        = string
  default = ""
}

variable "backend_image" {
  description = "Docker image URL for backend service"
  type        = string
  default     = "nginx:latest"
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 1
  validation {
    condition     = var.backend_desired_count > 0 && var.backend_desired_count <= 10
    error_message = "Backend desired count must be between 1 and 10."
  }
}

variable "backend_cpu" {
  description = "CPU units for backend (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.backend_cpu)
    error_message = "Backend CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "backend_memory" {
  description = "Memory in MB for backend"
  type        = number
  default     = 512
}

#############################################################################
# ECS - Redis Variables
#############################################################################

variable "redis_image" {
  description = "Docker image URL for Redis"
  type        = string
  default     = "redis:7-alpine"
}

variable "redis_desired_count" {
  description = "Desired number of Redis tasks"
  type        = number
  default     = 1
}

variable "redis_cpu" {
  description = "CPU units for Redis"
  type        = number
  default     = 256
}

variable "redis_memory" {
  description = "Memory in MB for Redis"
  type        = number
  default     = 512
}

#############################################################################
# ECS - MQTT Variables
#############################################################################

variable "mqtt_image" {
  description = "Docker image URL for MQTT broker"
  type        = string
  default     = "eclipse-mosquitto:2.0"
}

variable "mqtt_desired_count" {
  description = "Desired number of MQTT tasks"
  type        = number
  default     = 1
}

variable "mqtt_cpu" {
  description = "CPU units for MQTT"
  type        = number
  default     = 256
}

variable "mqtt_memory" {
  description = "Memory in MB for MQTT"
  type        = number
  default     = 512
}

#############################################################################
# ElastiCache Redis Variables
#############################################################################

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "redis_port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "redis_automatic_failover" {
  description = "Automatic failover enabled"
  type        = bool
  default     = false
}

variable "redis_multi_az" {
  description = "Multi-AZ enabled for Redis"
  type        = bool
  default     = false
}

variable "redis_at_rest_encryption" {
  description = "Encryption at rest for Redis"
  type        = bool
  default     = true
}

variable "redis_transit_encryption" {
  description = "Transit encryption for Redis"
  type        = bool
  default     = false
}

variable "redis_parameter_family" {
  description = "Redis parameter family"
  type        = string
  default     = "redis7"
}

variable "redis_maintenance_window" {
  description = "Redis maintenance window"
  type        = string
  default     = "sun:05:00-sun:07:00"
}