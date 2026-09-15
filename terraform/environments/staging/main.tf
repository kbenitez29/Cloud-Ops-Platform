terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Applies these tags automatically to every resource in this environment
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cloud-ops-platform"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# Calls the VPC module with staging-specific network values
module "vpc" {
  source = "../../modules/vpc"

  project     = "cloud-ops"
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"

  # Index-matched — position 0 in AZs pairs with position 0 in subnet CIDRs
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Security groups — defines traffic rules between ALB, ECS, and RDS
module "sg" {
  source = "../../modules/sg"

  project     = "cloud-ops"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id # pulls the VPC ID from the VPC module output
}

# ALB — public entry point, deployed across public subnets
module "alb" {
  source = "../../modules/alb"

  project           = "cloud-ops"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
  health_check_path = "/health"
  container_port    = 3000
}

# Shared ECS cluster — both API and frontend services run inside this
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project     = var.project
  environment = var.environment
}

# API ECS service — Node.js backend, handles /api/* routes
module "ecs_api" {
  source = "../../modules/ecs"

  project            = var.project
  environment        = var.environment
  cluster_id         = module.ecs_cluster.cluster_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.sg.ecs_sg_id
  target_group_arn   = module.alb.api_target_group_arn
  container_port     = 3000
  cpu                = 256
  memory             = 512
  desired_count      = 2
  db_endpoint        = module.rds.db_endpoint
  db_name            = module.rds.db_name
  db_secret_arn      = aws_secretsmanager_secret.db_password.arn

  # Unique name suffix so API and frontend resources don't conflict
  service_name       = "api"
}

# Frontend ECS service — React app served by Nginx
module "ecs_frontend" {
  source = "../../modules/ecs"

  project            = var.project
  environment        = var.environment
  cluster_id         = module.ecs_cluster.cluster_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.sg.ecs_sg_id
  target_group_arn   = module.alb.frontend_target_group_arn
  container_port     = 80
  cpu                = 256
  memory             = 512
  desired_count      = 2
  db_endpoint        = ""
  db_name            = ""
  db_secret_arn      = ""
  service_name       = "frontend"
}

# RDS — private Postgres instance, only reachable from ECS via security group
module "rds" {
  source = "../../modules/rds"

  project            = var.project
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.sg.rds_sg_id
  db_password        = var.db_password # pulled from Secrets Manager at runtime by ECS
}