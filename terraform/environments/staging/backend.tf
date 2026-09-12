# Stores staging state in S3, native S3 locking replaces DynamoDB (Terraform >= 1.10)
terraform {
  backend "s3" {
    bucket       = "cloud-ops-tfstate-896568317504"
    key          = "staging/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}