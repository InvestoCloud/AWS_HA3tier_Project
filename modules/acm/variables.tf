variable "domain_name" {
  description = "Fully qualified domain name for the ACM certificate."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID used for DNS validation."
  type        = string
}

variable "tags" {
  description = "Tags applied to ACM resources."
  type        = map(string)
  default     = {}
}