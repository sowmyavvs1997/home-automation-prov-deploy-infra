variable "identifier" {
  description = "RDS instance identifier"
  type        = string
  validation {
    condition     = length(var.identifier) > 0 && length(var.identifier) <= 63
    error_message = "Identifier must be between 1 and 63 characters."
  }
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GB."
  }
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
  validation {
    condition     = var.engine == "postgres"
    error_message = "Only postgres engine is supported."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "admin"
  validation {
    condition     = length(var.username) > 0 && !can(regex("^[0-9]", var.username))
    error_message = "Username must not start with a number."
  }
}

variable "password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.password) >= 8
    error_message = "Password must be at least 8 characters long."
  }
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "homeautomation"
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Make RDS instance publicly accessible"
  type        = bool
  default     = false
}

variable "enable_iam_auth" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = true
}
