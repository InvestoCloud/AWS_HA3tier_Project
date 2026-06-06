variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, stage, or prod."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private database subnet IDs used by the DB subnet group."
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID attached to the RDS database."
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

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
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

variable "allocated_storage" {
  description = "Allocated RDS storage in GB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage in GB for RDS storage autoscaling."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when destroying the database."
  type        = bool
  default     = true
}