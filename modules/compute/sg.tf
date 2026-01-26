#############################################################################
# ALB Security Group
#############################################################################

resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress to container port"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["10.61.68.0/22"]
  }

  ingress {
    description = "Ingress to ssh port"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["10.61.68.0/22"]
  }

  ingress {
    description = "HTTP from VPC to load balancer port"
    from_port   = var.lb_port
    to_port     = var.lb_port
    protocol    = "tcp"
    cidr_blocks = ["10.61.68.0/22"]
  }

  egress {
    description = "Egress to internet - outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.lb_name}-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}
