terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub Actions OIDC thumbprint
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = merge(var.tags, {
    Name = "github-actions-oidc-provider"
  })
}

resource "aws_iam_role" "github_actions_terraform_plan" {
  name        = var.role_name
  description = "IAM role assumed by GitHub Actions to run Terraform fmt, validate, and plan."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_repo}:ref:refs/heads/main",
              "repo:${var.github_repo}:pull_request",
              "repo:${var.github_repo}:ref:refs/heads/add-terraform-github-actions"
            ]
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.role_name
  })
}

# Broad read access lets Terraform refresh and plan existing AWS infrastructure.
# This is for plan-only. Do not use this same role for apply later.
resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.github_actions_terraform_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Extra permissions needed for the S3 backend lock file and state access.
resource "aws_iam_policy" "terraform_backend_access" {
  name        = "${var.role_name}-backend-access"
  description = "Allows GitHub Actions Terraform plan role to read remote state and use S3 state locking."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListStateBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.terraform_state_bucket}"
        Condition = {
          StringLike = {
            "s3:prefix" = [
              var.terraform_state_key,
              "${var.terraform_state_key}.tflock"
            ]
          }
        }
      },
      {
        Sid    = "ReadTerraformState"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.terraform_state_bucket}/${var.terraform_state_key}"
        ]
      },
      {
        Sid    = "ManageTerraformStateLock"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.terraform_state_bucket}/${var.terraform_state_key}.tflock"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.role_name}-backend-access"
  })
}

resource "aws_iam_role_policy_attachment" "terraform_backend_access" {
  role       = aws_iam_role.github_actions_terraform_plan.name
  policy_arn = aws_iam_policy.terraform_backend_access.arn
}

# Your Terraform config reads the RDS secret during plan, so this role needs GetSecretValue.
resource "aws_iam_policy" "secrets_read_access" {
  name        = "${var.role_name}-secrets-read"
  description = "Allows GitHub Actions Terraform plan role to read Secrets Manager values needed by Terraform plan."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadSecretsManagerValues"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.role_name}-secrets-read"
  })
}

resource "aws_iam_role_policy_attachment" "secrets_read_access" {
  role       = aws_iam_role.github_actions_terraform_plan.name
  policy_arn = aws_iam_policy.secrets_read_access.arn
}
