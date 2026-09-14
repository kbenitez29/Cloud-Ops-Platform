# ALB — internet-facing, deployed across public subnets in both AZs
resource "aws_lb" "main" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false # false = internet-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # spans both AZs for HA

  # Protects against accidental deletion via terraform destroy
  enable_deletion_protection = false

  tags = {
    Name = "${var.project}-${var.environment}-alb"
  }
}

# Target group — pool of ECS tasks the ALB forwards traffic to
resource "aws_lb_target_group" "main" {
  name        = "${var.project}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # required for Fargate — tasks register by IP, not instance ID

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2 # 2 consecutive successes = healthy
    unhealthy_threshold = 3 # 3 consecutive failures = unhealthy, removed from rotation
    timeout             = 5
    interval            = 30 # checks every 30 seconds
    matcher             = "200" # expects HTTP 200 to consider the task healthy
  }

  tags = {
    Name = "${var.project}-${var.environment}-tg"
  }
}

# HTTP listener — for now forwards all traffic to ECS, will redirect to HTTPS in milestone 4
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}