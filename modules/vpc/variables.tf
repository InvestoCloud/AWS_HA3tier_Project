variable "project_name" {
  type        = string
  description = "Project name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs."
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "Private app subnet CIDRs."
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "Private DB subnet CIDRs."
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT Gateway."
}