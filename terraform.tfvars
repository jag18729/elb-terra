aws_region = "us-east-1"
app_name    = "coffee-shop-app"
app_version = "v1.0.0"

# IMPORTANT: This bucket name must be globally unique
app_version_bucket_name = "coffee-shop-app-deployment-123456"

# Path to your application ZIP file
app_source_zip = "./application.zip"

# Database credentials
db_username = "dbadmin"
db_password = "SecurePassword123!" # Change this to a strong password

# VPC details
vpc_id = "vpc-12345678" # Update with your VPC ID

# Subnet IDs for EC2 instances
subnet_ids = [
  "subnet-1234abcd",
  "subnet-5678efgh"
]

# Subnet IDs for ELB
elb_subnet_ids = [
  "subnet-1234abcd",
  "subnet-5678efgh"
]

# Subnet IDs for EFS mount targets
efs_subnet_ids = [
  "subnet-1234abcd",
  "subnet-5678efgh"
]