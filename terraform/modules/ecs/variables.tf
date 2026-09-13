variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource naming"
  type        = string
}

# Networking — where ECS tasks will run
variable "private_subnet_ids" {
  description = "Private subnet IDs where ECS tasks are deployed"
  type        = list(string)
}

# Security group controlling inbound traffic to tasks
variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# ALB target group — ECS registers tasks here so ALB can route traffic to them
variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB for the task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of task instances to keep running"
  type        = number
  default     = 2
}