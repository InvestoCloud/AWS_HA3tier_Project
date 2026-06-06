output "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications."
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

output "ec2_high_cpu_alarm_name" {
  description = "EC2 high CPU alarm name."
  value       = aws_cloudwatch_metric_alarm.ec2_high_cpu.alarm_name
}

output "alb_5xx_alarm_name" {
  description = "ALB 5XX alarm name."
  value       = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "unhealthy_targets_alarm_name" {
  description = "Unhealthy targets alarm name."
  value       = aws_cloudwatch_metric_alarm.unhealthy_targets.alarm_name
}

output "rds_high_cpu_alarm_name" {
  description = "RDS high CPU alarm name."
  value       = aws_cloudwatch_metric_alarm.rds_high_cpu.alarm_name
}

output "rds_low_storage_alarm_name" {
  description = "RDS low storage alarm name."
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.alarm_name
}