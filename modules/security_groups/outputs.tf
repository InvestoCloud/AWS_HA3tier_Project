output "alb_sg_id" {
  description = "Security group ID for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security group ID for the EC2 application instances."
  value       = aws_security_group.app.id
}

output "rds_sg_id" {
  description = "Security group ID for the RDS database."
  value       = aws_security_group.rds.id
}

output "db_port" {
  description = "Database port based on selected database engine."
  value       = local.db_port
}