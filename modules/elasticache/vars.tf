variable "name" {
  description = "Name prefix for ElastiCache resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ElastiCache"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS security group ID for Redis access"
  type        = string
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The initial number of cache nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.num_cache_nodes >= 1 && var.num_cache_nodes <= 6
    error_message = "Number of cache nodes must be between 1 and 6."
  }
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

variable "parameter_family" {
  description = "Parameter family for Redis"
  type        = string
  default     = "redis7"
}

variable "automatic_failover_enabled" {
  description = "Automatic failover enabled for Multi-AZ"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Multi-AZ enabled"
  type        = bool
  default     = false
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for cache notifications"
  type        = string
  default     = null
}
