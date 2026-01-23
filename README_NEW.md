# Home Automation Infrastructure as Code

**Production-ready Terraform infrastructure for deploying a containerized microservices application on AWS.**

This repository contains well-structured, modular Terraform code to provision a complete AWS infrastructure with:
- **3 ECS Fargate containers**: Backend, Redis, MQTT
- **PostgreSQL RDS database**
- **Custom VPC with public/private subnets**
- **Application Load Balancer**
- **Least-privilege IAM roles**
- **CloudWatch logging**

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────┐
│         Application Load Balancer            │
│           (80: HTTP Traffic)                 │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
    ┌───▼────────┐    ┌──────▼──────┐
    │ Backend    │    │ Redis        │
    │ (Fargate)  │    │ (Fargate)    │
    │ Port 8080  │    │ Port 6379    │
    └────┬───────┘    └──────┬───────┘
         │                   │
         └─────────┬─────────┘
                   │
            ┌──────▼──────┐
            │ MQTT        │
            │ (Fargate)   │
            │ Port 1883   │
            └─────────────┘
                   │
         ┌─────────▼──────────┐
         │ PostgreSQL RDS     │
         │ (Multi-AZ Ready)   │
         │ Port 5432          │
         └────────────────────┘
```

### Infrastructure Components

#### **Networking (VPC Module)**
- Custom VPC with configurable CIDR
- 2 Public subnets (for ALB)
- 2 Private subnets (for ECS & RDS)
- NAT Gateways for outbound traffic
- Internet Gateway for ALB access

#### **Compute (Compute Module)**
- **ECS Cluster** with Container Insights enabled
- **Application Load Balancer** for distributing traffic
- **Security Groups** with least-privilege access
- **CloudWatch Log Groups** for all services
- Capacity providers for FARGATE & FARGATE_SPOT

#### **Containers (ECS Module)**
Three containerized services:
1. **Backend** (Fargate): Main application service
   - CPU: 256, Memory: 512MB (configurable)
   - Port: 8080
   - Connected to ALB

2. **Redis** (Fargate): In-memory cache
   - CPU: 256, Memory: 512MB (configurable)
   - Port: 6379
   - Persistent storage with AOF

3. **MQTT** (Fargate): Message broker
   - CPU: 256, Memory: 512MB (configurable)
   - Port: 1883
   - Eclipse Mosquitto broker

#### **Database (RDS Module)**
- PostgreSQL 15 (configurable version)
- Multi-AZ ready
- Encrypted storage (gp3)
- IAM database authentication
- Enhanced monitoring
- Automated backups
- 7-day retention policy (default)

#### **Security & Access (IAM Module)**
- **ECS Task Execution Role**: For pulling images & CloudWatch logs
- **ECS Task Role**: For application permissions (RDS, Secrets Manager)
- **RDS IAM Auth Role**: For IAM-based database authentication
- Least-privilege policies for each service

## 🚀 Quick Start

### Prerequisites
- AWS Account with appropriate credentials
- Terraform >= 1.5
- AWS CLI configured

### 1. Clone & Prepare

```bash
cd environments/dev
```

### 2. Configure Variables

Copy the example file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:
```hcl
environment = "dev"
aws_region  = "ap-south-1"

db_password = "YourSecurePassword123!"
backend_image = "your-ecr-repo/backend:latest"
```

> **⚠️ Important**: Never commit `terraform.tfvars` to version control. Use Terraform Cloud or set environment variables:
> ```bash
> export TF_VAR_db_password="YourSecurePassword123!"
> ```

### 3. Initialize & Plan

```bash
terraform init
terraform plan
```

### 4. Apply

```bash
terraform apply
```

### 5. Get Outputs

```bash
terraform output

# Access your application
terraform output application_endpoint
```

---

## 📁 Directory Structure

```
.
├── modules/
│   ├── vpc/                    # VPC, Subnets, NAT Gateways
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/                # ECS Cluster, ALB, Log Groups
│   │   ├── main.tf
│   │   ├── vars.tf
│   │   └── outputs.tf
│   │
│   ├── ecs/                    # Task Definitions & Services
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/                    # PostgreSQL RDS
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── global/
│       └── iam/                # IAM Roles & Policies
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
├── environments/
│   └── dev/
│       ├── main.tf             # Main configuration & module calls
│       ├── variables.tf        # Input variables
│       ├── locals.tf           # Local values
│       ├── aws-vars.tf         # AWS-specific variables
│       ├── outputs.tf          # Output definitions
│       ├── terraform.tfvars    # Environment-specific values (git-ignored)
│       └── terraform.tfvars.example
│
└── scripts/
    └── run.sh                  # Helper script
```

---

## 🔧 Configuration Reference

### Essential Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `environment` | `dev` | Environment name (dev, staging, prod) |
| `aws_region` | `ap-south-1` | AWS region to deploy |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `db_password` | N/A | **REQUIRED** RDS master password |
| `backend_image` | `nginx:latest` | Backend container image URL |

### ECS Task Sizing

Available CPU/Memory combinations for Fargate:

| CPU | Memory Options |
|-----|-----------------|
| 256 | 512, 1024, 2048 |
| 512 | 1024-4096 (1GB increments) |
| 1024 | 2048-8192 (1GB increments) |
| 2048 | 4096-16384 (1GB increments) |
| 4096 | 8192-30720 (1GB increments) |

---

## 🔐 Security Best Practices

✅ **Implemented:**
- [x] Least-privilege IAM roles
- [x] Encrypted RDS storage (gp3)
- [x] VPC with private subnets
- [x] Security groups with restricted access
- [x] CloudWatch audit logging
- [x] No public database access
- [x] IAM database authentication support

**Recommendations for Production:**

1. **Database Password Management**
   ```bash
   # Use AWS Secrets Manager
   aws secretsmanager create-secret --name db-password --secret-string "your-password"
   ```

2. **Enable S3 Remote State**
   ```hcl
   # Uncomment in environments/dev/alb.tf
   backend "s3" {
     bucket         = "terraform-state-bucket"
     key            = "home-automation/dev/terraform.tfstate"
     region         = "ap-south-1"
     encrypt        = true
     dynamodb_table = "terraform-locks"
   }
   ```

3. **Enable HTTPS for ALB**
   ```hcl
   # Add ACM certificate
   # Convert ALB listener to HTTPS
   ```

4. **Enable Multi-AZ for RDS**
   ```hcl
   multi_az = true  # In terraform.tfvars
   ```

5. **Implement Monitoring**
   ```bash
   # CloudWatch Alarms for:
   # - ALB health checks
   # - ECS task failures
   # - RDS CPU/memory
   # - Database connections
   ```

---

## 📊 Monitoring & Logging

### CloudWatch Log Groups
- `/ecs/dev-ha/backend` - Backend service logs
- `/ecs/dev-ha/mqtt` - MQTT broker logs
- `/ecs/dev-ha/redis` - Redis logs
- `/aws/rds/instance/dev-ha-db/postgresql` - PostgreSQL logs

### CloudWatch Container Insights
Monitor ECS cluster metrics:
```bash
aws logs list-log-groups | grep /ecs/
```

### View Logs
```bash
# Backend logs
aws logs tail /ecs/dev-ha/backend --follow

# RDS logs
aws logs tail /aws/rds/instance/dev-ha-db/postgresql --follow
```

---

## 🔄 Common Operations

### Update Backend Image
```bash
terraform apply -var="backend_image=your-ecr-repo/backend:v2.0"
```

### Scale Services
```bash
terraform apply -var="backend_desired_count=3"
```

### Change RDS Instance Size
```bash
terraform apply -var="db_instance_class=db.t3.small"
```

### Destroy Infrastructure
```bash
# WARNING: This will delete all resources including database
terraform destroy
```

---

## 🧪 Testing & Validation

### Terraform Validation
```bash
terraform validate
terraform fmt --recursive
```

### Lint with Tflint (Optional)
```bash
tflint --init
tflint
```

### Plan Output
```bash
terraform plan -out=tfplan
terraform show tfplan
```

---

## 📝 Outputs

After applying, access important information:

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Get RDS endpoint
terraform output rds_endpoint

# Get all outputs
terraform output -json
```

### Important Outputs:
| Output | Description |
|--------|-------------|
| `application_endpoint` | HTTP endpoint for backend service |
| `rds_endpoint` | Database connection string |
| `mqtt_endpoint` | MQTT broker endpoint (internal) |
| `redis_endpoint` | Redis endpoint (internal) |
| `ecs_cluster_name` | ECS cluster identifier |
| `backend_log_group` | CloudWatch log group name |

---

## 🐛 Troubleshooting

### Backend Image Not Found
```bash
# Push your image to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <your-ecr-repo>
docker build -t <your-ecr-repo>/backend:latest .
docker push <your-ecr-repo>/backend:latest
```

### ECS Task Failing to Start
```bash
# Check CloudWatch logs
aws logs tail /ecs/dev-ha/backend --follow

# Check ECS service events
aws ecs describe-services --cluster dev-ha-ecs-cluster --services dev-ha-backend
```

### Database Connection Issues
```bash
# Test RDS connectivity
psql -h <rds-endpoint> -U haadmin -d homeautomation
```

### ALB Not Receiving Traffic
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <arn>

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>
```

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-best-practices.html)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)

---

## 📄 License

[Your License Here]

## 👥 Contributing

[Your Contributing Guidelines Here]
