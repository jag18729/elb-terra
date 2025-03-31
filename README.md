# Coffee Shop Website - Elastic Beanstalk with MySQL and EFS

This Terraform project deploys a coffee shop website to AWS using:
- S3 for static website hosting (front-end)
- Elastic Beanstalk for dynamic content (back-end)
- MySQL/MariaDB database
- EFS (Elastic File System) for persistent shared storage

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS CLI configured with your Vocarium Lab credentials
- Access to your Vocarium AWS Lab environment

## QUICK START CONFIGURATION GUIDE

### STEP 1: GATHER YOUR AWS INFORMATION

Before editing any files, collect the following information from your AWS Console:

1. **VPC ID** 
   - Go to AWS Console → VPC → Your VPCs
   - Copy your VPC ID (format: vpc-xxxxxxxxxxxxxxxxx)

2. **Subnet IDs**
   - Go to AWS Console → VPC → Subnets
   - Identify at least 2 PRIVATE subnets (in different AZs)
   - Identify at least 2 PUBLIC subnets (in different AZs)
   - Copy all subnet IDs (format: subnet-xxxxxxxxxxxxxxxxx)

3. **Choose Unique Bucket Names**
   - Create two globally unique S3 bucket names by adding your student ID or other identifier
   - Example: "coffee-shop-app-deployment-student123"
   - Example: "coffee-shop-website-bucket-student123"

### STEP 2: UPDATE terraform.tfvars FILE

Open the `terraform.tfvars` file and REPLACE ALL CAPITALIZED VALUES with information from Step 1:

```
# Find and replace ALL CAPITALIZED text with your values
app_version_bucket_name = "UNIQUE-NAME-FOR-APP-DEPLOYMENT-BUCKET"
website_bucket_name = "UNIQUE-NAME-FOR-WEBSITE-BUCKET"
db_password = "CHANGE-TO-SECURE-PASSWORD"
vpc_id = "REPLACE-WITH-YOUR-VPC-ID"
subnet_ids = ["PRIVATE-SUBNET-ID-1", "PRIVATE-SUBNET-ID-2"]
elb_subnet_ids = ["PUBLIC-SUBNET-ID-1", "PUBLIC-SUBNET-ID-2"]
efs_subnet_ids = ["PRIVATE-SUBNET-ID-1", "PRIVATE-SUBNET-ID-2"]
```

### STEP 3: DEPLOYMENT

Open your terminal in the project directory and run:

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Preview the deployment plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```
   - Type "yes" when prompted to confirm

4. After deployment completes, find your website URLs:
   ```
   terraform output website_url        # S3 front-end website
   terraform output elastic_beanstalk_url  # Elastic Beanstalk URL
   ```

## Architecture Details

- **Front-end:** Static website hosted on S3
  - Complete coffee shop catalog
  - Product browsing pages
  - Coffee bean information

- **Back-end:** Elastic Beanstalk PHP application
  - PHP 8.0 on Amazon Linux 2
  - Integrates with MySQL database
  - Burstable t3.small instance type
  - Elastic Load Balancer for traffic distribution

- **Database:** MySQL 8.0
  - t3.small instance
  - 5GB allocated storage
  - Manages product inventory and orders

- **Storage:** EFS for shared persistence
  - Mounted at `/var/app/efs` 
  - EFS mount points in each Availability Zone
  - Shared access across all application instances

- **Security Features:**
  - IMDSv1 enabled (as required for lab)
  - Security groups for EFS access
  - Dev/test environment configuration

## Cleanup

When you're finished with the lab, destroy all resources to avoid charges:
```
terraform destroy
```
Type "yes" when prompted to confirm deletion.

## Troubleshooting

If you encounter issues during deployment:

1. **VPC/Subnet Problems:**
   - Verify you've entered the correct VPC and subnet IDs
   - Ensure subnets are in different Availability Zones

2. **S3 Bucket Name Conflicts:**
   - If bucket creation fails, choose different unique names
   - S3 bucket names must be globally unique across all AWS accounts

3. **Permission Issues:**
   - Confirm your Vocarium Lab has sufficient permissions
   - The "LabRole" instance profile should have appropriate access