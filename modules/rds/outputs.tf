output "db_instance_address" {
  description = "RDS instance address"
  value       = aws_db_instance.this.address
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint (address:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "db_resource_id" {
  description = "RDS resource ID (for IAM authentication)"
  value       = aws_db_instance.this.resource_id
}
