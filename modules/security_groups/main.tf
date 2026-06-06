locals {
  db_port = var.db_engine == "postgres" ? 5432 : 3306
}

# ALB Security Group
# Allows public HTTP traffic from the internet.
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Allow HTTP traffic from the internet to the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
    Tier = "public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_from_internet" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP from the internet"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_outbound" {
  security_group_id = aws_security_group.alb.id

  description = "Allow all outbound traffic from ALB"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


# EC2 App Security Group
# Allows HTTP traffic only from the ALB security group.
resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Allow HTTP traffic from ALB to EC2 app instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
    Tier = "private-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_http_from_alb" {
  security_group_id = aws_security_group.app.id

  description                  = "Allow HTTP from ALB security group"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_internet" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTPS from the internet"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_all_outbound" {
  security_group_id = aws_security_group.app.id

  description = "Allow all outbound traffic from app instances"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


# RDS Security Group
# Allows database traffic only from the EC2 app security group.
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Allow database traffic only from EC2 app security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
    Tier = "private-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id = aws_security_group.rds.id

  description                  = "Allow database traffic from EC2 app security group"
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_egress_rule" "rds_all_outbound" {
  security_group_id = aws_security_group.rds.id

  description = "Allow all outbound traffic from RDS"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}