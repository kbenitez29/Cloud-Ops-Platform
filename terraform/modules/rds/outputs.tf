# Endpoint ECS uses to connect to the database
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

# Database name passed to the app as an environment variable
output "db_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}