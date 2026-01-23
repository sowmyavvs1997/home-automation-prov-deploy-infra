resource "aws_security_group" "sg" {
  name = var.sg_name
  vpc_id = var.vpc_id
}

# MQTT broker ingress (port 1883)
resource "aws_vpc_security_group_ingress_rule" "mqtt" {
  count             = contains(var.allow_ports, 1883) ? 1 : 0
  security_group_id = aws_security_group.sg.id
  description       = "MQTT broker"
  from_port         = 1883
  to_port           = 1883
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allow_cidr
}

# Backend API ingress (port 8080)
resource "aws_vpc_security_group_ingress_rule" "backend" {
  count             = contains(var.allow_ports, 8080) ? 1 : 0
  security_group_id = aws_security_group.sg.id
  description       = "Backend API"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allow_cidr
}

# Redis ingress (port 6379)
resource "aws_vpc_security_group_ingress_rule" "redis" {
  count             = contains(var.allow_ports, 6379) ? 1 : 0
  security_group_id = aws_security_group.sg.id
  description       = "Redis"
  from_port         = 6379
  to_port           = 6379
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allow_cidr
}

# PostgreSQL ingress (port 5432)
resource "aws_vpc_security_group_ingress_rule" "postgres" {
  count             = contains(var.allow_ports, 5432) ? 1 : 0
  security_group_id = aws_security_group.sg.id
  description       = "PostgreSQL database"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allow_cidr
}

# Egress: allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.sg.id
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}