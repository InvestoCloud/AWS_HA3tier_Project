output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs."
}

output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "Private app subnet IDs."
}

output "private_db_subnet_ids" {
  value       = aws_subnet.private_db[*].id
  description = "Private database subnet IDs."
}