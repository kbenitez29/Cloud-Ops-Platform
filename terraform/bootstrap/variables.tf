variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

variable "state_bucket_name" {
  description = "Name of S3 bucket for the terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of dynamoDB table for state locking"
  type        = string
  default     = "cloud-ops-terraform-lock"
}