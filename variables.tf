variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the Elastic Beanstalk application"
  type        = string
  default     = "web-app"
}

variable "app_version" {
  description = "Version of the application"
  type        = string
  default     = "v1.0.0"
}

variable "app_version_bucket_name" {
  description = "Name of the S3 bucket to store application versions (must be globally unique)"
  type        = string
}

variable "website_bucket_name" {
  description = "Name of the S3 bucket to host the website (must be globally unique)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances"
  type        = list(string)
}

variable "elb_subnet_ids" {
  description = "List of subnet IDs for Elastic Load Balancer"
  type        = list(string)
}

variable "efs_subnet_ids" {
  description = "List of subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password for the RDS database (should be set in terraform.tfvars)"
  type        = string
  sensitive   = true
}