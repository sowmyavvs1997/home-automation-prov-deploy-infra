#############################################################################
# Launch Template
#############################################################################

data template_file "lt_user_data" {
  template = file("${path.module}/templates/user-data.pl")

  vars = {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }
}

resource "aws_launch_template" "this" {
  name          = var.lt_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = var.iam_instance_profile

  vpc_security_group_ids = [var.security_group_id]

  user_data = data.template_file.lt_user_data.rendered
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.asg_name}-lt"
      Environment = var.environment
      Project     = var.project_name
    }
  }
}

#############################################################################
# Auto Scaling Group
#############################################################################

data "aws_iam_role" "asg_role" {
  name = "AWSServiceRoleForAutoScaling_AMP"
}


resource "aws_autoscaling_group" "this" {
  name                = var.asg_name
  vpc_zone_identifier = var.private_subnet_ids

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  service_linked_role_arn = data.aws_iam_role.asg_role.arn

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
