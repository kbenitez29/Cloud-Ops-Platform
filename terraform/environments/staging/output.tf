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