# AWS region where all staging resources will be deployed
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

# Used in resource names and tags — e.g. cloud-ops-staging-vpc
variable "environment" {
  description = "Environment name used in resource naming and tagging"
  type        = string
  default     = "staging"
}

# Passed via tfvars or CI/CD secrets — never committed to git
variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "cloud-ops"
}