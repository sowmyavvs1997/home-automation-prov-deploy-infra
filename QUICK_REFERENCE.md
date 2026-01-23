# Quick Reference Guide

## 🚀 Deploy in 5 Minutes

```bash
# 1. Navigate to environment
cd environments/dev

# 2. Set password (or edit terraform.tfvars)
export TF_VAR_db_password="YourSecurePassword123!"

# 3. Initialize
terraform init

# 4. Validate (✅ Already passes)
terraform validate

# 5. Plan & Review
terraform plan -lock=false

# 6. Deploy
terraform apply -lock=false

# 7. Get Access Info
terraform output application_endpoint
terraform output mqtt_endpoint
terraform output redis_endpoint
terraform output rds_endpoint
```

---

## 📝 Common Terraform Commands

### Planning & Applying
```bash
# See what will be created/modified
terraform plan -lock=false

# Save plan to file (good for CI/CD)
terraform plan -lock=false -out=tfplan
terraform apply tfplan

# Apply with variable override
terraform apply -lock=false -var="backend_desired_count=3"

# Apply with tfvars file
terraform apply -lock=false -var-file="prod.tfvars"
```

### Viewing State
```bash
# List all resources
terraform state list

# View specific resource
terraform state show module.vpc.aws_vpc.this

# View entire state (sensitive!)
terraform state pull
```

### Destroying
```bash
# Destroy everything (WARNING: deletes database)
terraform destroy -lock=false

# Destroy specific resource
terraform destroy -lock=false -target=module.ecs.aws_ecs_service.redis

# Preview destruction
terraform plan -lock=false -destroy
```

### Formatting & Validation
```bash
# Format code
terraform fmt -recursive

# Validate syntax (✅ Already passes for this project)
terraform validate

# Check for unused variables
terraform console  # Then query var.unused_var
```

---

## 🔧 Variable Overrides (Priority Order)

1. **Command line**: `terraform apply -var="key=value"`
2. **Environment variables**: `export TF_VAR_key=value`
3. **terraform.tfvars file**
4. **Module defaults**

```bash
# Example: Multiple overrides
terraform apply \
  -var="backend_image=my-repo/app:latest" \
  -var="backend_desired_count=2" \
  -var="db_instance_class=db.t3.small"
```

---

## 📊 Common Configurations

### Scale Backend to 3 Tasks
```bash
terraform apply -lock=false -var="backend_desired_count=3"
```

### Upgrade Database Size
```bash
terraform apply -lock=false -var="db_instance_class=db.t3.small"
```

### Change Container Image
```bash
terraform apply -lock=false -var="backend_image=your-repo/app:v2.0"
```

### Increase Log Retention
```bash
terraform apply -lock=false -var="log_retention_days=30"
```

### Enable Multi-AZ Database
```bash
terraform apply -lock=false -var="multi_az=true"
```

---

## 🔐 Password Management

### Option 1: Environment Variable (Secure)
```bash
export TF_VAR_db_password="YourSecurePassword!"
terraform apply
```

### Option 2: AWS Secrets Manager
```bash
# Store in Secrets Manager
aws secretsmanager create-secret \
  --name home-automation-db \
  --secret-string "YourPassword!"

# Reference in terraform.tfvars
db_password = "YourPassword!"
```

### Option 3: Terraform Cloud (Recommended)
```bash
# Use Terraform Cloud UI to set sensitive variables
# They'll never appear in logs or state files
```

---

## 📡 Network Access

### Access Backend via ALB
```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test connectivity
curl http://$ALB_DNS

# Or use in your application
echo "Backend URL: http://$ALB_DNS"
```

### Access Database
```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_address)
RDS_PORT=$(terraform output -raw rds_port)

# Connect with psql
psql -h $RDS_ENDPOINT -U haadmin -d homeautomation

# Or from application
postgresql://haadmin:PASSWORD@$RDS_ENDPOINT:5432/homeautomation
```

### Access Redis (Internal Only)
```bash
# From backend container
redis://redis:6379

# Or from other containers
redis://redis:6379
```

### Access MQTT (Internal Only)
```bash
# From backend container
mqtt://mqtt:1883

# Or from other containers
mqtt://mqtt:1883
```

---

## 📊 Monitoring & Logs

### View ECS Logs
```bash
# Get log group names
terraform output backend_log_group
terraform output redis_log_group
terraform output mqtt_log_group

# Tail backend logs
aws logs tail /ecs/dev-ha/backend --follow

# Get specific log events
aws logs get-log-events \
  --log-group-name /ecs/dev-ha/backend \
  --log-stream-name ecs/backend/xxx
```

### View RDS Logs
```bash
# Get RDS log group
terraform output rds_log_group  # Not yet implemented

# Or via AWS CLI
aws logs tail /aws/rds/instance/dev-ha-db/postgresql --follow
```

### Check ECS Service Status
```bash
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw backend_service_name)

# Get service details
aws ecs describe-services \
  --cluster $CLUSTER \
  --services $SERVICE \
  --region ap-south-1

# Get service events
aws ecs describe-services \
  --cluster $CLUSTER \
  --services $SERVICE \
  --region ap-south-1 \
  | jq '.services[0].events'
```

### Check ALB Health
```bash
TARGET_GROUP=$(terraform output -raw backend_target_group_arn)

aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP \
  --region ap-south-1
```

---

## 🔍 Debugging

### Terraform Debug Mode
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Save to file
export TF_LOG_PATH=/tmp/terraform.log
terraform apply
```

### Check ECS Task Status
```bash
CLUSTER="dev-ha-ecs-cluster"

# List tasks
aws ecs list-tasks --cluster $CLUSTER

# Describe task
aws ecs describe-tasks \
  --cluster $CLUSTER \
  --tasks "arn:aws:ecs:..." \
  --region ap-south-1
```

### Verify Security Groups
```bash
# Get ECS security group
SG=$(terraform output -raw ecs_tasks_security_group_id)

# View inbound rules
aws ec2 describe-security-groups \
  --group-ids $SG \
  --region ap-south-1 | jq '.SecurityGroups[0].IpPermissions'
```

### Test RDS Connectivity
```bash
# From your local machine
RDS_HOST=$(terraform output -raw rds_address)

# Using psql
psql -h $RDS_HOST -U haadmin -d homeautomation -c "SELECT 1"

# Using AWS Systems Manager Session Manager
# (requires proper IAM setup)
aws ssm start-session --target <instance-id>
```

---

## 🚨 Troubleshooting

### Error: "Apply failed"

1. **Check logs**:
   ```bash
   aws logs tail /ecs/dev-ha/backend --follow
   ```

2. **Check resource status**:
   ```bash
   terraform state list
   terraform state show module.ecs.aws_ecs_service.backend
   ```

3. **Review CloudFormation events** (if using nested stacks):
   ```bash
   aws cloudformation describe-stack-events --stack-name <stack-name>
   ```

### Error: "Database password rejected"

1. **Verify password is set**:
   ```bash
   echo $TF_VAR_db_password
   ```

2. **Check RDS parameter**:
   ```bash
   terraform plan | grep db_password
   ```

3. **Recreate with new password**:
   ```bash
   export TF_VAR_db_password="NewPassword!"
   terraform destroy -auto-approve
   terraform apply -auto-approve
   ```

### Error: "Task failed to start"

1. **Check CloudWatch logs**
2. **Verify image exists in ECR**:
   ```bash
   aws ecr describe-images --repository-name backend
   ```

3. **Check IAM permissions**:
   ```bash
   terraform show module.global_iam
   ```

4. **Verify security group rules**:
   ```bash
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```

---

## 📋 Maintenance Tasks

### Update All Images
```bash
terraform apply \
  -var="backend_image=repo/backend:v2" \
  -var="redis_image=redis:7.2-alpine" \
  -var="mqtt_image=eclipse-mosquitto:2.0.15"
```

### Backup Database
```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier dev-ha-db \
  --db-snapshot-identifier dev-ha-db-backup-$(date +%s)

# List snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier dev-ha-db
```

### Update Terraform Version
```bash
# Check current version
terraform version

# Update to latest
terraform init -upgrade

# Update provider
terraform init -upgrade -get=false
```

---

## 💾 Backup & Restore

### Export Terraform State
```bash
# Backup state file
cp terraform.tfstate terraform.tfstate.backup

# Or use remote state backup
aws s3 cp s3://state-bucket/dev/terraform.tfstate ./backup/
```

### Export Database
```bash
# Using pg_dump
pg_dump -h $(terraform output -raw rds_address) \
  -U haadmin \
  -d homeautomation \
  -f backup.sql

# Upload to S3
aws s3 cp backup.sql s3://backups/homeautomation/$(date +%Y-%m-%d).sql
```

---

## 📖 File Locations & Purposes

| Path | Purpose |
|------|---------|
| `environments/dev/main.tf` | Provider, module calls |
| `environments/dev/variables.tf` | Input variable definitions |
| `environments/dev/locals.tf` | Local computed values |
| `environments/dev/outputs.tf` | Output definitions |
| `environments/dev/terraform.tfvars` | **Your configuration** |
| `modules/vpc/` | VPC infrastructure |
| `modules/ecs/` | Container definitions |
| `modules/rds/` | Database configuration |
| `modules/compute/` | ECS cluster & ALB |
| `modules/global/iam/` | IAM roles & policies |

---

## ⚡ Performance Tips

1. **Use Fargate Spot** for non-critical workloads (50% cheaper)
2. **Enable auto-scaling** for variable load
3. **Use RDS read replicas** for high-read workloads
4. **Enable RDS caching** with Redis
5. **Use CloudFront** for static content
6. **Monitor and optimize** CloudWatch metrics

---

## 🎯 Best Practices

✅ Always run `terraform plan` before `apply`
✅ Keep `terraform.tfvars` out of git
✅ Use remote state for team collaboration
✅ Tag all resources for cost tracking
✅ Regular backups before destructive operations
✅ Document any manual changes
✅ Use version control for all code
✅ Test in dev before prod

---

## 📞 Support

For issues:
1. Check logs: `aws logs tail <log-group> --follow`
2. Check Terraform output: `terraform show`
3. Check AWS Console for resource status
4. Enable debug mode: `export TF_LOG=DEBUG`
5. Review implementation guide: `IMPLEMENTATION_GUIDE.md`
