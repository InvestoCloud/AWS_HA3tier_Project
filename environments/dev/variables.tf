variable "aws_region" {
  description = "Region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ha3tier"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet outbound access."
  type        = bool
  default     = true
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

variable "db_engine" {
  description = "Database engine. Use postgres or mysql."
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "db_secret_name" {
  description = "Secrets Manager secret name containing database credentials."
  type        = string
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GB."
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ RDS."
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
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

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}



variable "hosted_zone_name" {
  description = "Route 53 hosted zone name. For example, example.com."
  type        = string
}

variable "domain_name" {
  description = "Fully qualified domain name for the application, such as app.example.com."
  type        = string
}



variable "enable_waf_rate_limit" {
  description = "Whether to enable WAF rate limiting."
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "Maximum requests from a single IP in a 5-minute window."
  type        = number
  default     = 2000
}