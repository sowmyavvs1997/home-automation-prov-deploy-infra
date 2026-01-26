data "aws_cloudformation_export" "ecs-role-arn" {
  name = "ECSRoleArn"
}

data "aws_cloudformation_export" "ecs-role-name" {
  name = "ECSRole"
}

data "aws_cloudformation_export" "ec2-instance-profile" {
  name = "EC2InstanceProfile"
}

#############################################################################
# ECS EC2 Instance Role
#############################################################################

resource "aws_iam_role" "ecs_instance" {
  name = "${var.project_name}-${var.environment}-ecs-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.project_name}-${var.environment}-ecs"
  role        = aws_iam_role.ecs_instance.name
}

#############################################################################
# ECS Task Execution Role
#############################################################################

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-exec-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
