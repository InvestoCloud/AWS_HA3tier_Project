variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, stage, or prod."
  type        = string
}

variable "notification_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name."
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix used for CloudWatch ALB metrics."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix used for CloudWatch target group metrics."
  type        = string
}

variable "db_identifier" {
  description = "RDS database identifier."
  type        = string
}

variable "ec2_cpu_alarm_threshold" {
  description = "EC2 average CPU threshold for alarm."
  type        = number
  default     = 70
}

variable "alb_5xx_alarm_threshold" {
  description = "ALB 5XX count threshold."
  type        = number
  default     = 5
}

variable "unhealthy_host_threshold" {
  description = "Unhealthy host count threshold."
  type        = number
  default     = 1
}

variable "rds_cpu_alarm_threshold" {
  description = "RDS CPU threshold for alarm."
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold_bytes" {
  description = "RDS free storage threshold in bytes."
  type        = number
  default     = 2147483648
}