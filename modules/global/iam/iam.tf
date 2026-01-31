terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
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
# ECS Task Execution Role
#############################################################################


## Create a role which allows ECS containers to perform actions such as write logs, call KMS
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazon.com", "elasticloadbalancing.amazon.com", "lambda.amazon.com"]
      type = "Service"
     }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = var.ecs_exec_iam_role
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary = "arn:aws:iam::${var.aws_account_id}:policy/amp-permissions-boundary"
}

#############################################################################
# ECS Task Execution Role Policy
#############################################################################

resource "aws_iam_policy" "ecs_execution_policy" {
  name = "var.ecs_exec_iam_policy"
  path = "/"
  description = "Allows ECS containers to execute commands on our behalf"

  policy = <<EOF
  {
    "version" : "2012-10-17",
    "statement" : [{
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLaterAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "iam:*",
          "logs:CreateRole",
          "logs:CreateLogStream",
          "logs:PutEventLogs",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "s3:*",
          "ecs:*"
        ],
        "Resource" : "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
  role       = aws_iam_role.ecsTaskExecutionRole.name
}

#############################################################################
# Master Role Policy Doc
#############################################################################

data "aws_iam_policy_document" "auto_tag_master_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    principals {
      identifiers = [data.aws_cloudformation_export.ecs-role-arn.value]
      type = "AWS"
    }
  }
}

#ecs-tasks-role master role
resource "aws_iam_role" "ecs-tasks-role" {
  name = var.ecs_tasks_iam_role
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.auto_tag_master_role_policy.json
  permissions_boundary = "arn:aws:iam::${var.aws_account_id}:policy/amp-permissions-boundary"
}

#Policy 2 - task role
resource "aws_iam_policy" "s3_service_policy" {
  name        = var.s3_service_policy
  path        = "/"
  description = "Allows ECS Containers to execute s3 api calls on its behalf"
  policy      = <<EOF
  {
     "version": "2012-10-17",
     "Statement" : [{
     "Effect": "Allow",
     "Action" : [
        "s3:*",
        "iam:UpdateAssumeRolePolicy",
        "dynamodb:*",
        "kms:*"
    ],
    "Resource": "*"
   }]
}
EOF
}