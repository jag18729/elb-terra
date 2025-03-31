# ===== AWS CONFIGURATION =====

# Region 
aws_region = "us-east-1"

# Application name
app_name    = "coffee-shop-app"
app_version = "v1.0.0"

# IMPORTANT: These bucket names MUST BE GLOBALLY UNIQUE!
app_version_bucket_name = "coffee-shop-app-deployment-garcia-rafael-2274088"
website_bucket_name = "coffee-shop-website-garcia-rafael-2274088"

# Database credentials
db_username = "dbadmin"
db_password = "CoffeeShop123!"

# VPC Configuration
vpc_id = "vpc-0448ce4a5f07d6e3f"

# Using public subnets since we don't have private subnets in the lab environment
# Subnet IDs for EC2 instances - using subnets from different AZs
subnet_ids = [
  "subnet-08c65b386cfdba976",  # us-east-1a
  "subnet-0a5be1a4c3da6a5fe"   # us-east-1b
]

# Subnet IDs for ELB - using public subnets
elb_subnet_ids = [
  "subnet-08c65b386cfdba976",  # us-east-1a
  "subnet-0a5be1a4c3da6a5fe"   # us-east-1b
]

# Subnet IDs for EFS mount targets - using the same subnets
efs_subnet_ids = [
  "subnet-08c65b386cfdba976",  # us-east-1a
  "subnet-0a5be1a4c3da6a5fe"   # us-east-1b
]