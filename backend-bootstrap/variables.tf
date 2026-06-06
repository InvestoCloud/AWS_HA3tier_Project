variable "aws_region" {
  description = "Region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
  default     = "ha3tier-dev-terraform-state-901170571830"
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