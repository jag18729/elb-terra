# ===== IMPORTANT: REPLACE ALL CAPITALIZED VALUES WITH YOUR LAB INFORMATION =====

# Region should be the same as your Vocarium lab region
aws_region = "us-east-1"  # REPLACE WITH YOUR LAB REGION IF DIFFERENT

# Application name - you can customize this
app_name    = "coffee-shop-app"
app_version = "v1.0.0"

# IMPORTANT: These bucket names MUST BE GLOBALLY UNIQUE! 
# ADD YOUR AWS STUDENT ID OR OTHER UNIQUE IDENTIFIER AFTER THE NAME
app_version_bucket_name = "UNIQUE-NAME-FOR-APP-DEPLOYMENT-BUCKET"
website_bucket_name = "UNIQUE-NAME-FOR-WEBSITE-BUCKET"

# Database credentials - CHANGE THE PASSWORD TO A SECURE VALUE
db_username = "dbadmin"
db_password = "CHANGE-TO-SECURE-PASSWORD"

# ===== VOCARIUM LAB VPC CONFIGURATION =====
# REPLACE WITH VALUES FROM YOUR VOCARIUM LAB AWS CONSOLE

# Find your VPC ID in the AWS Console under VPC → Your VPCs
vpc_id = "REPLACE-WITH-YOUR-VPC-ID"  # Example: vpc-0a1b2c3d4e5f6g7h8

# Find subnet IDs in AWS Console under VPC → Subnets
# Use at least 2 PRIVATE subnets in different Availability Zones

# Subnet IDs for EC2 instances - MUST BE PRIVATE SUBNETS
subnet_ids = [
  "PRIVATE-SUBNET-ID-1",  # Example: subnet-0a1b2c3d4e5f6g7h8
  "PRIVATE-SUBNET-ID-2"   # Example: subnet-1a2b3c4d5e6f7g8h9
]

# Subnet IDs for ELB - MUST BE PUBLIC SUBNETS
elb_subnet_ids = [
  "PUBLIC-SUBNET-ID-1",  # Example: subnet-2a3b4c5d6e7f8g9h0
  "PUBLIC-SUBNET-ID-2"   # Example: subnet-3a4b5c6d7e8f9g0h1
]

# Subnet IDs for EFS mount targets - USE THE SAME PRIVATE SUBNETS
efs_subnet_ids = [
  "PRIVATE-SUBNET-ID-1",  # Example: subnet-0a1b2c3d4e5f6g7h8
  "PRIVATE-SUBNET-ID-2"   # Example: subnet-1a2b3c4d5e6f7g8h9
]