# Stores the RDS master password encrypted — ECS retrieves it at container startup
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project}-${var.environment}-db-password"
  description = "RDS master password for the ${var.environment} environment"

  # Keeps the secret recoverable for 7 days after deletion before permanent removal
  recovery_window_in_days = 7

  tags = {
    Name = "cloud-ops-${var.environment}-db-password"
  }
}

# The actual secret value — sensitive = true hides it from plan and apply output
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password # comes from tfvars, never hardcoded
}