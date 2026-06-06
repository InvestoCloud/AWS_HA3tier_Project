data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "selected" {
  name         = var.hosted_zone_name
  private_zone = false
}

locals {
  db_secret = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)

  db_username = local.db_secret.username
  db_password = local.db_secret.password
}

module "vpc" {
  source = "../../modules/vpc"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  enable_nat_gateway       = var.enable_nat_gateway
}

module "security_groups" {
  source = "../../modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  db_engine    = var.db_engine
}

module "acm" {
  source = "../../modules/acm"

  domain_name    = var.domain_name
  hosted_zone_id = data.aws_route53_zone.selected.zone_id

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  alb_sg_id      = module.security_groups.alb_sg_id

  certificate_arn = module.acm.certificate_arn
}

module "waf" {
  source = "../../modules/waf"

  project_name = var.project_name
  environment  = var.environment
  alb_arn      = module.alb.alb_arn

  enable_rate_limit = var.enable_waf_rate_limit
  rate_limit        = var.waf_rate_limit

  tags = var.tags
}

module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  rds_sg_id             = module.security_groups.rds_sg_id
  db_engine             = var.db_engine
  db_name               = var.db_name
  db_username           = local.db_username
  db_password           = local.db_password
  db_instance_class     = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  multi_az              = var.db_multi_az
}

module "compute" {
  source = "../../modules/compute"

  project_name           = var.project_name
  environment            = var.environment
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  app_sg_id              = module.security_groups.app_sg_id
  target_group_arn       = module.alb.target_group_arn

  instance_type        = var.instance_type
  asg_min_size         = var.asg_min_size
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size

  db_endpoint = module.rds.db_endpoint
  db_name     = var.db_name
  db_engine   = var.db_engine

  aws_region    = var.aws_region
  db_secret_arn = aws_secretsmanager_secret.db_credentials.arn


  scale_out_cpu_threshold = var.scale_out_cpu_threshold
  scale_in_cpu_threshold  = var.scale_in_cpu_threshold
  #scaling_cooldown        = var.scaling_cooldown

  health_check_grace_period = var.health_check_grace_period
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name       = var.project_name
  environment        = var.environment
  notification_email = var.notification_email

  asg_name                = module.compute.asg_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  db_identifier           = module.rds.db_identifier

  ec2_cpu_alarm_threshold          = var.ec2_cpu_alarm_threshold
  alb_5xx_alarm_threshold          = var.alb_5xx_alarm_threshold
  unhealthy_host_threshold         = var.unhealthy_host_threshold
  rds_cpu_alarm_threshold          = var.rds_cpu_alarm_threshold
  rds_free_storage_threshold_bytes = var.rds_free_storage_threshold_bytes
}

