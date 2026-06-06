variable "aws_region" {
  description = "AWS region used by EC2 to retrieve Secrets Manager secret."
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, stage, or prod."
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs where EC2 instances will run."
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID attached to EC2 app instances."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN where ASG instances will register."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for app servers."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 4
}

variable "db_endpoint" {
  description = "RDS database endpoint."
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager secret ARN containing database credentials."
  type        = string
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_engine" {
  description = "Database engine. Valid values are postgres or mysql."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.db_engine)
    error_message = "db_engine must be either postgres or mysql."
  }
}

variable "scale_out_cpu_threshold" {
  description = "CPU threshold that triggers scale out."
  type        = number
  default     = 60
}

variable "scale_in_cpu_threshold" {
  description = "CPU threshold that triggers scale in."
  type        = number
  default     = 30
}

variable "scaling_cooldown" {
  description = "Cooldown period in seconds between scaling actions."
  type        = number
  default     = 300
}

variable "health_check_grace_period" {
  description = "Time in seconds before ASG checks instance health after launch."
  type        = number
  default     = 300
}