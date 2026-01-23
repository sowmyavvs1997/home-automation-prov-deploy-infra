#############################################################################
# Launch Template for EC2 Instances
#############################################################################

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.name}-ecs-lt-"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ecs_tasks.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  user_data = base64encode(templatefile("${path.module}/templates/user-data.pl", {
    cluster_name = aws_ecs_cluster.main.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}-ecs-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

#############################################################################
# Auto Scaling Group
#############################################################################

resource "aws_autoscaling_group" "ecs" {
  name              = "${var.name}-ecs-asg"
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  health_check_type   = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.name}-ecs-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_ecs_cluster.main]
}

#############################################################################
# IAM Role for EC2 Instance
#############################################################################

resource "aws_iam_role" "ecs_instance_role" {
  name_prefix = "${var.name}-ecs-instance-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name}-ecs-instance-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name_prefix = "${var.name}-ecs-"
  role        = aws_iam_role.ecs_instance_role.name
}

#############################################################################
# Data Source for Current AWS Account
#############################################################################

data "aws_caller_identity" "current" {}

#############################################################################
# ECS Cluster
#############################################################################

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.name}-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

#############################################################################
# Application Load Balancer
#############################################################################

resource "aws_lb" "main" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "backend" {
  name_prefix = "bknd"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200-299"
  }

  tags = {
    Name = "${var.name}-backend-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

#############################################################################
# Security Groups
#############################################################################

resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.name}-ecs-"
  description = "ECS tasks security group"
  vpc_id      = var.vpc_id

  # Allow from ALB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow MQTT
  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow Redis
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}

#############################################################################
# CloudWatch Log Groups
#############################################################################

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.name}/backend"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name}-backend-logs"
  }
}

resource "aws_cloudwatch_log_group" "mqtt" {
  name              = "/ecs/${var.name}/mqtt"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name}-mqtt-logs"
  }
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/${var.name}/redis"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name}-redis-logs"
  }
}
