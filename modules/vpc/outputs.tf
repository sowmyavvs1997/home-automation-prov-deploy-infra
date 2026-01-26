output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnets_by_az" {
  description = "Map of public subnet IDs by AZ"
  value       = { for s in aws_subnet.public : s.availability_zone => s.id }
}

output "private_subnets_by_az" {
  description = "Map of private subnet IDs by AZ"
  value       = { for s in aws_subnet.private : s.availability_zone => s.id }
}
