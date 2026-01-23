#############################################################################
# AWS Provider Variables
#############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "ap-south-1"
}

