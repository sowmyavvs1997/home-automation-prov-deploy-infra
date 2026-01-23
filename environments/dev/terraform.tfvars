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
# Database Configuration
#############################################################################

db_instance_class      = "db.t3.micro"
db_allocated_storage   = 20
db_engine_version      = "15"
db_name                = "homeautomation"
db_username            = "haadmin"
# IMPORTANT: Set db_password via environment variable or tfvars file
# export TF_VAR_db_password="your-secure-password"
skip_final_snapshot    = true
backup_retention_period = 7

#############################################################################
# ECS - Backend Configuration
#############################################################################

backend_image       = "nginx:latest"
backend_desired_count = 1
backend_cpu         = 256
backend_memory      = 512

#############################################################################
# ECS - Redis Configuration
#############################################################################

redis_image        = "redis:7-alpine"
redis_desired_count = 1
redis_cpu          = 256
redis_memory       = 512

#############################################################################
# ECS - MQTT Configuration
#############################################################################

mqtt_image        = "eclipse-mosquitto:2.0"
mqtt_desired_count = 1
mqtt_cpu          = 256
mqtt_memory       = 512