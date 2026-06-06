variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, stage, or prod."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs where the Application Load Balancer will be deployed."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID attached to the Application Load Balancer."
  type        = string
}

variable "target_port" {
  description = "Port where the application targets receive traffic."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the target group."
  type        = string
  default     = "/health"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. If null, only HTTP forwarding is created."
  type        = string
}