variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "github_repo" {
  description = "GitHub repository in OWNER/REPO format."
  type        = string
}

variable "terraform_state_bucket" {
  description = "S3 bucket used for Terraform remote state."
  type        = string
}

variable "terraform_state_key" {
  description = "Terraform state key path."
  type        = string
  default     = "ha3tier.3/environments/dev/terraform.tfstate"
}

variable "role_name" {
  description = "IAM role name for GitHub Actions Terraform plan."
  type        = string
  default     = "github-actions-terraform-plan-role"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}