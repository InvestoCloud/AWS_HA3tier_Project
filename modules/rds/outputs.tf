output "db_identifier" {
  description = "RDS database identifier."
  value       = aws_db_instance.this.identifier
}

output "db_endpoint" {
  description = "RDS database endpoint."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS database port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "db_engine" {
  description = "Database engine."
  value       = aws_db_instance.this.engine
}

output "db_multi_az" {
  description = "Whether Multi-AZ is enabled."
  value       = aws_db_instance.this.multi_az
}