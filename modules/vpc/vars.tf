
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}
#############################################################################
# Project / Environment
#############################################################################
variable "name_prefix" {
  description = "Name prefix for all VPC resources"
  type        = string
  default     = "ha"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "home-automation"
}

#############################################################################
# VPC Variables
#############################################################################

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of AZs to use"
  type        = list(string)
}
