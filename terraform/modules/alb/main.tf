# ALB — internet-facing, spans both public subnets for high availability
resource "aws_lb" "main" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-${var.environment}-alb"
  }
}

# Target group for the API service — ECS registers tasks here by IP
resource "aws_lb_target_group" "api" {
  name        = "${var.project}-${var.environment}-tg-api"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project}-${var.environment}-tg-api"
  }
}

# Target group for the frontend service — Nginx serves on port 80
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project}-${var.environment}-tg-fe"
  port        = var.frontend_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project}-${var.environment}-tg-fe"
  }
}

# Default listener on port 80 — routes to frontend by default
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action sends all unmatched traffic to the frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Listener rule — routes /api/* paths to the API target group
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100 # lower number = higher priority, evaluated before default action

  condition {
    path_pattern {
      values = ["/api/*"] # matches any request starting with /api/
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}