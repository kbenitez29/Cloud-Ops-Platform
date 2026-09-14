# Subnet group — tells RDS which private subnets it can deploy into
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids # spans both AZs for Multi-AZ support

  tags = {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  }
}

# Parameter group — explicit control over DB engine settings, even if defaults are used
resource "aws_db_parameter_group" "main" {
  name   = "${var.project}-${var.environment}-db-params"
  family = "postgres16"

  tags = {
    Name = "${var.project}-${var.environment}-db-params"
  }
}

# RDS instance — private Postgres database, only reachable from ECS
resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-db"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100 # enables autoscaling up to 100GB as data grows

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  multi_az            = false # single AZ for staging — would be true in prod
  publicly_accessible = false # never reachable from internet

  backup_retention_period = 0    # keeps 0 days of automated backups
  skip_final_snapshot     = true # allows destroy without creating a final snapshot (staging only)

  tags = {
    Name = "${var.project}-${var.environment}-db"
  }
}