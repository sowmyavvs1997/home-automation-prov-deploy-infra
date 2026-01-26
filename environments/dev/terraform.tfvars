environment = "dev"
aws_region  = "ap-south-1"

#############################################################################
# Terraform Backend Configuration
#############################################################################

tf_state_bucket = "terraform-state-home-automation"
tf_state_key    = "home-automation/dev/terraform.tfstate"
tf_lock_table   = "terraform-locks"

#############################################################################
# VPC Configuration
#############################################################################

vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]

#############################################################################
# ECS Configuration
#############################################################################
backend_image_tag   = "v1.0.0"
backend_desired_count = 2
mqtt_desired_count    = 1