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
