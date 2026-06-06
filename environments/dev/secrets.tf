resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.db_secret_name
  description = "Database credentials for RDS instance"

  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-db-credentials"
    Rotation = "manual"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}