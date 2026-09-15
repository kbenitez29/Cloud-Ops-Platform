# DNS name to reach the platform — used for Route53 and testing
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

# Passed to the ECS module so tasks register themselves with this target group
output "api_target_group_arn" {
  description = "ARN of the API target group"
  value       = aws_lb_target_group.api.arn
}

# Passed to the frontend ECS service
output "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

# Needed for Route53 alias record in milestone 4
output "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  value       = aws_lb.main.zone_id
}