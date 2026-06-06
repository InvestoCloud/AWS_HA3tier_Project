locals {
  engine_config = {
    postgres = {
      engine         = "postgres"
      engine_version = "16"
      port           = 5432
      family         = "postgres16"
    }

    mysql = {
      engine         = "mysql"
      engine_version = "8.0"
      port           = 3306
      family         = "mysql8.0"
    }
  }

  selected_engine = local.engine_config[var.db_engine]
}

# DB subnet group using private database subnets
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
    Tier = "private-db"
  }
}

# RDS Database Instance
resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-${var.environment}-db"

  engine         = local.selected_engine.engine
  engine_version = local.selected_engine.engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = local.selected_engine.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false

  multi_az = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = {
    Name = "${var.project_name}-${var.environment}-db"
    Tier = "private-db"
  }
}