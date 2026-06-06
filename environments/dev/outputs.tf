output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs."
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs."
  value       = module.vpc.private_db_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS database endpoint."
  value       = module.rds.db_endpoint
}
/*
output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = module.monitoring.dashboard_name
}
*/
output "alb_sg_id" {
  description = "Application Load Balancer security group ID."
  value       = module.security_groups.alb_sg_id
}

output "app_sg_id" {
  description = "EC2 application security group ID."
  value       = module.security_groups.app_sg_id
}

output "rds_sg_id" {
  description = "RDS database security group ID."
  value       = module.security_groups.rds_sg_id
}

output "db_port" {
  description = "Database port opened on the RDS security group."
  value       = module.security_groups.db_port
}

output "scale_out_policy_arn" {
  description = "Scale out policy ARN."
  value       = module.compute.scale_out_policy_arn
}

output "scale_in_policy_arn" {
  description = "Scale in policy ARN."
  value       = module.compute.scale_in_policy_arn
}

output "scale_out_alarm_name" {
  description = "Scale out CloudWatch alarm name."
  value       = module.compute.scale_out_alarm_name
}

output "scale_in_alarm_name" {
  description = "Scale in CloudWatch alarm name."
  value       = module.compute.scale_in_alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for monitoring alerts."
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = module.monitoring.dashboard_name
}

output "monitoring_alarm_names" {
  description = "CloudWatch monitoring alarm names."
  value = {
    ec2_high_cpu      = module.monitoring.ec2_high_cpu_alarm_name
    alb_5xx           = module.monitoring.alb_5xx_alarm_name
    unhealthy_targets = module.monitoring.unhealthy_targets_alarm_name
    rds_high_cpu      = module.monitoring.rds_high_cpu_alarm_name
    rds_low_storage   = module.monitoring.rds_low_storage_alarm_name
  }
}

# Route 53

output "app_url" {
  description = "HTTPS URL for the application."
  value       = "https://${var.domain_name}"
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN."
  value       = module.acm.certificate_arn
}

output "route53_app_record" {
  description = "Route 53 app DNS record."
  value       = aws_route53_record.app.fqdn
}

output "alb_zone_id" {
  description = "ALB Route 53 zone ID."
  value       = module.alb.alb_zone_id
}

output "https_listener_arn" {
  description = "HTTPS listener ARN."
  value       = module.alb.https_listener_arn
}

# WAF

output "waf_web_acl_name" {
  description = "WAF Web ACL name."
  value       = module.waf.web_acl_name
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN."
  value       = module.waf.web_acl_arn
}

output "waf_web_acl_capacity" {
  description = "WAF Web ACL capacity units used."
  value       = module.waf.web_acl_capacity
}