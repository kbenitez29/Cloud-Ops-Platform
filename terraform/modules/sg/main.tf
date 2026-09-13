# ALB security group — public facing, accepts HTTP and HTTPS from anywhere
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.environment}-sg-alb"
  description = "Controls traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP — will redirect to HTTPS once certificates are set up
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound — ALB needs to forward traffic to ECS tasks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-sg-alb"
  }
}

# ECS security group — only accepts traffic from the ALB, not from the internet
resource "aws_security_group" "ecs" {
  name        = "${var.project}-${var.environment}-sg-ecs"
  description = "Controls traffic to ECS tasks"
  vpc_id      = var.vpc_id

  # Only the ALB can reach ECS tasks on port 3000 (app port)
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow all outbound — ECS tasks need to reach internet via NAT and AWS APIs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-sg-ecs"
  }
}

# RDS security group — only accepts traffic from ECS tasks, fully private
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-sg-rds"
  description = "Controls traffic to RDS database"
  vpc_id      = var.vpc_id

  # Only ECS tasks can reach the database on the Postgres port
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  # RDS never initiates connections but AWS requires an egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-sg-rds"
  }
}