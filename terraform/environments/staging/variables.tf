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