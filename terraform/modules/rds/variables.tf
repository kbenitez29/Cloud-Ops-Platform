variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource naming"
  type        = string
}

# RDS is deployed into private subnets via the subnet group
variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

# Only ECS security group is allowed to reach RDS
variable "rds_sg_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "cloudops"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "cloudops_admin"
}

# Password comes from Secrets Manager, passed in at runtime — never hardcoded
variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true # prevents password appearing in logs and plan output
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro" # free tier eligible
}

variable "allocated_storage" {
  description = "Storage allocated in GB"
  type        = number
  default     = 20
}