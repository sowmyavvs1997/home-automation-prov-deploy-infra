#############################################################################
# Project / Environment
#############################################################################
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "home-automation"
}

variable "name_prefix" {
  description = "Name prefix for all resources for home automation project"
  type        = string
  default     = "ha"
}

#############################################################################
# Terraform Variables
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

variable "availability_zones" {
  description = "List of AZs to use"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]  # default AZs for Mumbai region
}

#############################################################################
# Backend ECS service
#############################################################################

variable "backend_image_tag" {
  description = "Docker image tag for the backend service"
  type        = string
  default     = "latest"
}

variable "backend_desired_count" {
  description = "Number of ECS backend tasks to run"
  type        = number
  default     = 2
}

variable "backend_cpu" {
  description = "CPU units for backend ECS task"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory (MB) for backend ECS task"
  type        = number
  default     = 512
}

#############################################################################
# MQTT ECS service (public image)
#############################################################################

variable "mqtt_image" {
  description = "Docker image for MQTT service (public image)"
  type        = string
  default     = "eclipse-mosquitto:2.0"
}

variable "mqtt_desired_count" {
  description = "Number of ECS MQTT tasks to run"
  type        = number
  default     = 1
}

variable "mqtt_cpu" {
  description = "CPU units for MQTT ECS task"
  type        = number
  default     = 256
}

variable "mqtt_memory" {
  description = "Memory (MB) for MQTT ECS task"
  type        = number
  default     = 512
}