# Used by CI/CD pipeline to push images to the right registry
output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = aws_ecr_repository.main.repository_url
}

# Service name needed by CI/CD to force new deployments
output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

# Task role ARN — additional policies will be attached here in later milestones
output "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.arn
}

