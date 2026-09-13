# VPC where all security groups will be created
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource naming"
  type        = string
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
}