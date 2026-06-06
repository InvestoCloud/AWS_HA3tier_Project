terraform {
  backend "s3" {
    bucket       = "ha3tier-dev-terraform-state-901170571830"
    key          = "ha3tier-3/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}