# ECR repository — stores Docker images that ECS pulls from
resource "aws_ecr_repository" "main" {
  name                 = "${var.project}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # scans for vulnerabilities on every image push
  }

  tags = {
    Name = "${var.project}-${var.environment}-ecr"
  }
}

# Lifecycle policy — keeps only the last 10 images to control storage costs
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 7 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 7
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# IAM role that ECS uses to pull images from ECR and write logs to CloudWatch
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Attaches AWS managed policy — grants ECR pull and CloudWatch Logs write permissions
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role assumed by the running container itself to call AWS APIs
resource "aws_iam_role" "ecs_task" {
  name = "${var.project}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# CloudWatch log group — ECS tasks stream logs here
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 30 # keeps logs for 30 days then auto-deletes to control costs

  tags = {
    Name = "${var.project}-${var.environment}-logs"
  }
}

# ECS cluster — logical boundary where all tasks for this environment run
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled" # enables CloudWatch Container Insights for deeper metrics
  }

  tags = {
    Name = "${var.project}-${var.environment}-cluster"
  }
}

# Task definition — blueprint describing the container: image, CPU, memory, ports, logs
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project}-${var.environment}"
  network_mode             = "awsvpc" # each task gets its own ENI and private IP
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn # used by ECS agent
  task_role_arn            = aws_iam_role.ecs_task.arn      # used by the container

  container_definitions = jsonencode([{
    name  = "${var.project}-${var.environment}"
    image = "${aws_ecr_repository.main.repository_url}:latest"

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    # Sends container logs to the CloudWatch log group defined above
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = "eu-west-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }

    environment = []
    secrets     = [] # will be populated from Secrets Manager in later milestones
  }])
}

# ECS service — maintains desired_count running tasks, restarts them if they die
resource "aws_ecs_service" "main" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids # tasks run in private subnets
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false # no public IP — traffic comes via ALB only
  }

  # Registers running tasks with the ALB target group so traffic can reach them
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project}-${var.environment}"
    container_port   = var.container_port
  }

  # Ensures a new task is healthy before the old one is stopped during deploys
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [aws_iam_role_policy_attachment.ecs_execution]
}