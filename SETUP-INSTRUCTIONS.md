# SETUP INSTRUCTIONS FOR VOCARIUM LAB

## STEP 1: LOCATE YOUR AWS INFORMATION
-----------------------------------

### VPC ID
1. Go to AWS Console
2. Navigate to VPC → Your VPCs
3. COPY YOUR VPC ID: vpc-XXXXXXXXXX

### SUBNET IDs
1. Go to AWS Console 
2. Navigate to VPC → Subnets
3. You need:
   - At least 2 PRIVATE SUBNETS (different AZs)
   - At least 2 PUBLIC SUBNETS (different AZs)

How to identify subnet types:
- PUBLIC subnets have a route to an Internet Gateway
- PRIVATE subnets don't have a route to an Internet Gateway
- Check "Route table" column or click on each subnet and view "Route table" tab

### S3 BUCKET NAMES
You need to create TWO GLOBALLY UNIQUE names:
1. App deployment bucket: "coffee-shop-app-deployment-UNIQUE-ID"
2. Website bucket: "coffee-shop-website-bucket-UNIQUE-ID"

Replace UNIQUE-ID with your:
- Student ID
- AWS account number
- Random string
- Date (YYYYMMDD)

## STEP 2: OPEN AND EDIT terraform.tfvars
---------------------------------------

```
# REPLACE ALL VALUES BELOW WITH YOUR ACTUAL AWS INFORMATION

app_version_bucket_name = "UNIQUE-NAME-FOR-APP-DEPLOYMENT-BUCKET"
website_bucket_name = "UNIQUE-NAME-FOR-WEBSITE-BUCKET"
db_password = "CHANGE-TO-SECURE-PASSWORD"

vpc_id = "REPLACE-WITH-YOUR-VPC-ID"

# Use at least 2 PRIVATE subnets in different AZs
subnet_ids = [
  "PRIVATE-SUBNET-ID-1",
  "PRIVATE-SUBNET-ID-2"
]

# Use at least 2 PUBLIC subnets in different AZs
elb_subnet_ids = [
  "PUBLIC-SUBNET-ID-1",
  "PUBLIC-SUBNET-ID-2"
]

# Same as your private subnets for EC2
efs_subnet_ids = [
  "PRIVATE-SUBNET-ID-1", 
  "PRIVATE-SUBNET-ID-2"
]
```

## STEP 3: DEPLOY WITH TERRAFORM
------------------------------

Run these commands in order:

1. `terraform init`
2. `terraform plan`   (review changes)
3. `terraform apply`  (type "yes" when prompted)

## STEP 4: ACCESS YOUR WEBSITES
----------------------------

After successful deployment, get your URLs:

```
terraform output website_url           # S3 static website
terraform output elastic_beanstalk_url # Elastic Beanstalk app
```

## TROUBLESHOOTING
---------------

### ERROR: "S3 bucket already exists"
- S3 bucket names are GLOBALLY unique (across ALL AWS accounts)
- Solution: Choose completely different unique names

### ERROR: "Cannot create EFS mount targets"
- Subnet IDs might be incorrect
- Solution: Verify your private subnet IDs are correct and exist in your VPC

### ERROR: "LoadBalancer cannot be created"
- Public subnet IDs might be incorrect or not public
- Solution: Verify subnet IDs have routes to Internet Gateway

### WEBSITE NOT LOADING
- Can take 5-10 minutes for Elastic Beanstalk to fully deploy
- Solution: Wait and refresh; check AWS Console for status