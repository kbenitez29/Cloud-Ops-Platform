# Exposed so future modules (ECS, RDS, ALB) can reference the VPC they live in
output "vpc_id" {
  description = "ID of the staging VPC"
  value       = module.vpc.vpc_id
}

# ALB will be placed in public subnets — exposed here for future modules
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# ECS tasks and RDS live here — private, no direct internet access
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# Exposed for visibility and consumed by future modules
output "alb_sg_id" {
  description = "ALB security group ID"
  value       = module.sg.alb_sg_id
}
# URL to reach the platform once deployed
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "api_ecr_repository_url" {
  description = "ECR repository URL for the API"
  value       = module.ecs_api.ecr_repository_url
}

output "frontend_ecr_repository_url" {
  description = "ECR repository URL for the frontend"
  value       = module.ecs_frontend.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "api_service_name" {
  description = "API ECS service name"
  value       = module.ecs_api.ecs_service_name
}

output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = module.ecs_frontend.ecs_service_name
}