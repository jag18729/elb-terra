# SUPER EASY COFFEE SHOP DEPLOYMENT

Follow these simple steps to deploy your Coffee Shop application with AWS CloudFormation:

## STEP 1: CREATE BOOTSTRAP RESOURCES

This step creates an S3 bucket with the application.zip file automatically:

1. Go to AWS Console
2. Navigate to CloudFormation
3. Click "Create stack" → "With new resources"
4. Choose "Upload a template file"
5. Upload the `bootstrap-resources.yaml` file
6. Click "Next"
7. Enter stack name: `coffee-shop-bootstrap`
8. Click "Next" on the next screens and "Create stack"
9. Wait for the stack to complete (Status: CREATE_COMPLETE)

## STEP 2: DEPLOY MAIN APPLICATION

This step creates ALL required infrastructure automatically:

1. Go to AWS Console
2. Navigate to CloudFormation
3. Click "Create stack" → "With new resources"
4. Choose "Upload a template file"
5. Upload the `coffee-shop-stack.yaml` file
6. Click "Next"
7. Enter stack name: `coffee-shop-application`
8. In parameters section:
   - AppName: Enter your preferred name (default: coffee-shop)
   - DBPassword: ENTER A STRONG PASSWORD FOR DATABASE
   - EnvironmentName: Choose dev, test, or prod (default: dev)
9. Click "Next" on the next screens, check "I acknowledge..." checkbox
10. Click "Create stack"
11. Wait for stack to complete (15-20 minutes)

## STEP 3: ACCESS YOUR WEBSITE

When stack creation is complete:

1. Go to the "Outputs" tab of your stack
2. Find "WebsiteURL" - This is your S3 static website URL
3. Find "ElasticBeanstalkURL" - This is your application URL

## WHAT GETS CREATED

The CloudFormation templates automatically create:

- VPC with public and private subnets
- Internet and NAT gateways
- S3 bucket with website hosting
- RDS MySQL database
- Elastic Beanstalk environment
- EFS for shared storage
- All required security groups

## HOW TO CLEAN UP

To remove all resources:

1. Go to CloudFormation
2. Select your stack `coffee-shop-application`
3. Click "Delete"
4. After it completes, select `coffee-shop-bootstrap`
5. Click "Delete"

THIS DELETES EVERYTHING - DATABASE INCLUDED!

## TROUBLESHOOTING

If stack creation fails:

1. Go to the "Events" tab to see error
2. Most common issues:
   - Weak database password (must be 8+ characters)
   - Resource name conflicts (try a different AppName)
   - Service limits exceeded (reduce instance sizes)

Need help? Ask your instructor!