variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, stage, or prod."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created."
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