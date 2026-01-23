# Terraform Implementation Guide

## Overview

This guide provides a comprehensive walkthrough of the production-ready Terraform infrastructure for deploying the Home Automation application on AWS.

---

## ✅ What Has Been Implemented

### 1. **VPC Module** (`modules/vpc/vpc.tf`)
**Purpose**: Network foundation with public/private subnets and NAT gateways

**Features**:
- [x] Configurable CIDR block (default: 10.0.0.0/16)
- [x] 2 Public subnets for ALB (1 per AZ)
- [x] 2 Private subnets for ECS & RDS (1 per AZ)
- [x] Internet Gateway for public access
- [x] 2 NAT Gateways (1 per AZ for HA)
- [x] Route tables with proper associations
- [x] Tags on all resources

**Key Outputs**:
- `vpc_id` - VPC identifier
- `public_subnet_ids` - List of public subnets
- `private_subnet_ids` - List of private subnets

---

### 2. **IAM Module** (`modules/global/iam/iam.tf`)
**Purpose**: Least-privilege IAM roles for ECS and database access

**Features**:
- [x] **ECS Task Execution Role**: Pulls container images from ECR, writes logs to CloudWatch
- [x] **ECS Task Role**: Application permissions (RDS access, Secrets Manager)
- [x] **RDS IAM Auth Role**: IAM-based database authentication
- [x] Inline policies with minimal required permissions
- [x] Service assume role policies

**Security Model**:
- Separate roles for execution and task logic
- ECR authentication support
- RDS connection support
- Secrets Manager integration ready

**Key Outputs**:
- `ecs_task_execution_role_arn` - For ECS task execution
- `ecs_task_role_arn` - For container applications

---

### 3. **RDS Module** (`modules/rds/rds.tf`)
**Purpose**: PostgreSQL database with high availability features

**Features**:
- [x] PostgreSQL 15 (configurable)
- [x] Encrypted storage (gp3 with 3000 IOPS)
- [x] DB subnet group for private deployment
- [x] Parameter groups for PostgreSQL
- [x] Enhanced monitoring with IAM role
- [x] CloudWatch log export
- [x] Automated backups (7-day retention default)
- [x] Multi-AZ ready (disable for dev, enable for prod)
- [x] IAM database authentication
- [x] Deletion protection

**Database Configuration**:
- Master username: `haadmin`
- Master password: Via Terraform variable (sensitive)
- Initial database: `homeautomation`
- Port: 5432 (default PostgreSQL)

**Monitoring**:
- Enhanced monitoring every 60 seconds
- PostgreSQL slow logs exported to CloudWatch
- Performance Insights enabled

**Key Outputs**:
- `db_instance_endpoint` - Connection string
- `db_instance_address` - Hostname only
- `db_instance_port` - Database port

---

### 4. **Compute Module** (`modules/compute/compute.tf`)
**Purpose**: EC2 launch template, ECS cluster, load balancer, and logging infrastructure

**Features**:
- [x] **EC2 Launch Template** for auto-scaling group
  - User data script with system updates and ECS agent
  - IAM instance profile for ECS
  - CloudWatch logging enabled
- [x] **ECS Cluster** with Container Insights enabled
- [x] **Application Load Balancer** (ALB)
  - HTTP listener on port 80
  - Target group for backend service
  - Health checks every 30 seconds
- [x] **Security Groups**
  - ALB: Allow inbound 80/tcp from 0.0.0.0/0
  - ECS Tasks: Allow from ALB on 8080, internal on 1883/6379/5432
- [x] **CloudWatch Log Groups**
  - `/ecs/dev-ha/backend` - Backend service logs
  - `/ecs/dev-ha/mqtt` - MQTT logs
  - `/ecs/dev-ha/redis` - Redis logs
  - 7-day retention (configurable)

**Capacity Providers**:
- EC2 via Launch Template and Auto-Scaling Group
- Auto-scaling based on CPU/Memory metrics

**Key Outputs**:
- `ecs_cluster_name` / `ecs_cluster_arn`
- `alb_dns_name` - For application access
- `alb_arn`
- `backend_target_group_arn` - For service registration
- Security group IDs for ALB and ECS tasks

---

### 5. **ECS Module** (`modules/ecs/`)
**Purpose**: Container task definitions and services

**Services Deployed**:

#### **Backend Service**
```
Task Definition: dev-ha-backend
Container: backend
Image: user-provided (default: nginx:latest)
Port: 8080 → ALB target group
CPU: 256 units (configurable: 256-4096)
Memory: 512 MB (configurable)
Environment Variables:
  - DATABASE_URL: postgresql://user:pass@host:5432/db
  - REDIS_URL: redis://redis:6379
  - MQTT_BROKER: mqtt://mqtt:1883
  - ENVIRONMENT: dev
Logging: CloudWatch (dev-ha-backend)
Load Balancer: ALB → Target Group
```

#### **Redis Service**
```
Task Definition: dev-ha-redis
Container: redis
Image: redis:7-alpine
Port: 6379 (not exposed to ALB)
CPU: 256 units
Memory: 512 MB
Command: redis-server --appendonly yes (AOF persistence)
Logging: CloudWatch (dev-ha-redis)
Network: Private subnets only
```

#### **MQTT Service**
```
Task Definition: dev-ha-mqtt
Container: mqtt
Image: eclipse-mosquitto:2.0
Port: 1883 (not exposed to ALB)
CPU: 256 units
Memory: 512 MB
Logging: CloudWatch (dev-ha-mqtt)
Network: Private subnets only
```

**Common Features**:
- [x] Fargate launch type (serverless containers)
- [x] awsvpc network mode (required for Fargate)
- [x] CloudWatch logging for all containers
- [x] Deployment circuit breaker with auto-rollback
- [x] Health checks via ALB (backend only)
- [x] Task execution and task roles assigned
- [x] Sensitive variables for database credentials

**Key Outputs**:
- Service ARNs and names
- Task definition ARNs

---

### 6. **Environment Configuration** (`environments/dev/`)

#### **main.tf**
```
Terraform Configuration:
├── Provider Setup: AWS with default tags
├── Remote Backend: S3 + DynamoDB (commented, ready to enable)
├── Module Calls:
│   ├── VPC Module
│   ├── Compute Module
│   ├── Global IAM Module
│   ├── RDS Module
│   └── ECS Module
└── ALB Listener: HTTP on port 80
```

#### **variables.tf**
- 30+ variables for complete configuration
- Type validation on all variables
- Sensible defaults where appropriate
- Marked sensitive fields (`db_password`)

#### **locals.tf**
```hcl
name_prefix = "${environment}-ha"
common_tags = {
  Environment = var.environment
  Project     = "home-automation"
  ManagedBy   = "terraform"
}
```

#### **outputs.tf**
- 30+ outputs organized by resource type
- VPC outputs (subnets, NAT IPs)
- Compute outputs (ALB, cluster)
- RDS outputs (endpoint, database info)
- ECS outputs (services, log groups)
- Application access endpoints

#### **terraform.tfvars**
```hcl
Pre-configured with:
- Environment: dev
- Region: ap-south-1
- VPC CIDR: 10.0.0.0/16
- Subnet configuration
- RDS sizing (t3.micro, 20GB)
- Container defaults (nginx, redis, mosquitto)
- Database: homeautomation, haadmin user
```

#### **terraform.tfvars.example**
Complete example with all options and comments

---

## 🔄 Deployment Flow

### Step 1: Prepare Environment
```bash
cd environments/dev

# Set database password
export TF_VAR_db_password="YourSecurePassword123!"

# OR edit terraform.tfvars directly
cp terraform.tfvars.example terraform.tfvars
# Edit with your values
```

### Step 2: Initialize Terraform
```bash
terraform init
# Downloads AWS provider
# Initializes working directory
```

### Step 3: Validate Configuration
```bash
terraform validate
terraform fmt --recursive
```

### Step 4: Plan Deployment
```bash
terraform plan -out=tfplan
# Review what will be created
```

### Step 5: Apply Configuration
```bash
terraform apply tfplan
# Creates all resources
```

### Step 6: Retrieve Outputs
```bash
terraform output
terraform output application_endpoint
```

---

## 🔐 Security Architecture

### Network Security
```
Internet
  ↓
ALB (Public Subnets)
  ↓ (Port 8080)
Backend Service (Private Subnets)
  ↓ (Internal traffic only)
Redis, MQTT (Private Subnets)
RDS (Private Subnets)
```

### IAM Security

**Task Execution Role**:
- ECR: GetAuthorizationToken, BatchGetImage, GetDownloadUrlForLayer
- CloudWatch Logs: CreateLogStream, PutLogEvents

**Task Role**:
- RDS: rds-db:connect
- Secrets Manager: GetSecretValue

**Database Access**:
- Via RDS IAM auth tokens
- Credentials injected as environment variables
- Encrypted passwords as sensitive outputs

---

## 📊 Resource Summary

| Module | Resource Type | Count | Details |
|--------|---------------|-------|---------|
| VPC | VPC | 1 | 10.0.0.0/16 |
| VPC | Subnets | 4 | 2 public, 2 private |
| VPC | NAT Gateways | 2 | 1 per AZ |
| VPC | IGW | 1 | Internet access |
| VPC | Route Tables | 3 | 1 public, 2 private |
| Compute | ECS Cluster | 1 | Container Insights enabled |
| Compute | ALB | 1 | HTTP, 80/tcp |
| Compute | Target Group | 1 | Backend service |
| Compute | Security Groups | 2 | ALB + ECS tasks |
| Compute | Log Groups | 3 | Backend, Redis, MQTT |
| RDS | DB Subnet Group | 1 | Private deployment |
| RDS | RDS Instance | 1 | PostgreSQL 15 |
| RDS | CloudWatch Log Group | 1 | PostgreSQL logs |
| RDS | IAM Role | 1 | Enhanced monitoring |
| ECS | Task Definitions | 3 | Backend, Redis, MQTT |
| ECS | Services | 3 | One per task |
| IAM | Roles | 3 | Execution, Task, RDS Auth |
| IAM | Policies | 3 | Inline policies |
| **TOTAL** | **~25 resources** | | Ready for production |

---

## 💰 Estimated Costs (Monthly)

### Computing (US-EAST-1 pricing as reference)
- 3 Fargate tasks @ 256 CPU / 512 MB: ~$30-40/month

### Database
- RDS t3.micro @ 20GB gp3: ~$20-30/month

### Networking
- 2 NAT Gateways: ~$32-64/month
- ALB: ~$16-20/month
- Data transfer: Variable

### Logging
- CloudWatch Logs: ~$5-10/month

**Estimated Total: $100-170/month** (varies by region and actual usage)

> Use AWS Cost Explorer for precise estimates in your region

---

## 📋 Production Checklist

- [ ] Enable S3 remote state backend
- [ ] Enable Terraform Cloud/Enterprise for collaboration
- [ ] Configure SNS for Terraform notifications
- [ ] Set up AWS CloudTrail for audit logging
- [ ] Enable AWS Config for compliance checking
- [ ] Configure AWS Secrets Manager for DB password
- [ ] Set up CloudWatch Alarms for critical metrics
- [ ] Configure RDS automated backups
- [ ] Enable RDS Multi-AZ for production
- [ ] Set up AWS Backup for application recovery
- [ ] Configure ALB with HTTPS/ACM certificate
- [ ] Implement Web ACL with AWS WAF
- [ ] Set up CloudFront CDN for static assets
- [ ] Configure VPC Flow Logs for network monitoring
- [ ] Enable GuardDuty for threat detection
- [ ] Implement Systems Manager Session Manager for secure access

---

## 🚀 Next Steps

1. **Deploy with your backend image**:
   ```bash
   terraform apply -var="backend_image=<your-ecr-image>"
   ```

2. **Configure database credentials**:
   ```bash
   # Connect and create users/databases
   psql -h $(terraform output -raw rds_address) -U haadmin
   ```

3. **Set up CI/CD**:
   - GitHub Actions / GitLab CI
   - Auto-deploy on tag push
   - Terraform plan/apply in pipeline

4. **Monitor and maintain**:
   - Set up CloudWatch dashboards
   - Configure SNS notifications
   - Regular backup verification

5. **Scale for production**:
   - Enable Multi-AZ RDS
   - Increase task desired counts
   - Add auto-scaling policies
   - Implement database read replicas

---

## 🆘 Support & Resources

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest
- **AWS ECS Guide**: https://docs.aws.amazon.com/ecs/
- **AWS RDS Guide**: https://docs.aws.amazon.com/rds/
- **Terraform Best Practices**: https://www.terraform.io/cloud/guides/recommended-practices

---

## 📝 Notes

- All resources are tagged with `Environment: dev`, `Project: home-automation`, `ManagedBy: terraform`
- Terraform state is sensitive - protect your `.tfstate` files
- Never commit `terraform.tfvars` with real passwords
- Use AWS Secrets Manager for credential management
- Regular backups are essential - configure them before going to production
