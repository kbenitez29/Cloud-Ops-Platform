variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource naming"
  type        = string
}

# ALB lives in public subnets — one per AZ for high availability
variable "public_subnet_ids" {
  description = "Public subnet IDs where the ALB is deployed"
  type        = list(string)
}

# Controls what traffic the ALB accepts
variable "alb_sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

# VPC where the target group is created
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "container_port" {
  description = "Port the ECS containers listen on"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Path the ALB uses to check if a task is healthy"
  type        = string
  default     = "/health"
}

# Frontend container port — Nginx serves on 80
variable "frontend_container_port" {
  description = "Port the frontend container listens on"
  type        = number
  default     = 80
}