#############################################################################
# VPC Configuration
#############################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

#############################################################################
# Internet Gateway
#############################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

#############################################################################
# Public Subnets
#############################################################################

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

#############################################################################
# Private Subnets
#############################################################################

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.name}-private-subnet-${count.index + 1}"
    Type = "Private"
  }
}

#############################################################################
# Elastic IPs for NAT Gateways
#############################################################################

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

#############################################################################
# NAT Gateways (one per public subnet for HA)
#############################################################################

resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

#############################################################################
# Public Route Table
#############################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#############################################################################
# Private Route Tables (one per NAT Gateway for HA)
#############################################################################

resource "aws_route_table" "private" {
  count  = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}
