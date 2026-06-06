variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, stage, or prod."
  type        = string
}

variable "alb_arn" {
  description = "Application Load Balancer ARN to associate with WAF."
  type        = string
}

variable "enable_rate_limit" {
  description = "Whether to enable a basic WAF rate limit rule."
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Maximum number of requests allowed from a single IP in a 5-minute window."
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Tags applied to WAF resources."
  type        = map(string)
  default     = {}
}