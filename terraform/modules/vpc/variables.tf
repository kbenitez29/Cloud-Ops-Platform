variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "environment" {
    description = "Environment name (staging, prod)"
    type        = string
}

variable "project" {
    description = "Project name used for resource naming and tagging"
    type        = string
}
variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for public subnets, one per AZ"
    type        = list(string)

}
variable "private_subnet_cidrs" {
     description = "List of CIDR blocks for private subnets, one per AZ"
    type        = list(string)

}

variable "availability_zones" {
     description = "List of availability zones to deploy subnets into it"
    type        = list(string)

}