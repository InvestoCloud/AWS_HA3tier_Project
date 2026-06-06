output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer."
  value       = aws_lb.this.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer. Used for CloudWatch metrics."
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn" {
  description = "ARN of the ALB target group."
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group. Used for CloudWatch metrics."
  value       = aws_lb_target_group.app.arn_suffix
}

output "http_listener_arn" {
  description = "HTTP redirect listener ARN."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN."
  value       = aws_lb_listener.https.arn
}