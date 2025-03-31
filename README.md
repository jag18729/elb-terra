# SIMPLE AWS COFFEE SHOP DEPLOYMENT

This project deploys a complete coffee shop application to AWS using CloudFormation.

## ULTRA-SIMPLE DEPLOYMENT METHOD

### ONLY TWO STEPS!

1. Upload the `bootstrap-resources.yaml` template in CloudFormation
2. Upload the `coffee-shop-stack.yaml` template in CloudFormation

That's it! Everything else will be created automatically.

## WHAT'S INCLUDED

- **Complete Coffee Shop Website**
- **Front-end:** Static website hosted on S3
- **Back-end:** Elastic Beanstalk PHP application
- **Database:** MySQL 8.0 database
- **Storage:** EFS for shared persistence

## DETAILED INSTRUCTIONS

For complete step-by-step instructions, see:
**[DEPLOY-INSTRUCTIONS.md](DEPLOY-INSTRUCTIONS.md)**

## ONLY TWO THINGS YOU NEED TO PROVIDE:

1. **A NAME** for your coffee shop application
2. **A PASSWORD** for the MySQL database

## HOW IT WORKS

1. **First Template (`bootstrap-resources.yaml`):**
   - Creates a bootstrap S3 bucket
   - Runs a Lambda function that packages and uploads the application
   - Prepares everything needed for the main stack

2. **Second Template (`coffee-shop-stack.yaml`):**
   - Creates ALL infrastructure:
     - VPC with public/private subnets
     - Security groups
     - S3 website bucket
     - Elastic Beanstalk environment
     - RDS MySQL database
     - EFS for shared storage

## NO CONFIGURATION NEEDED!

This deployment uses CloudFormation's intrinsic functions like `!Ref`, `!Sub`, `!GetAtt` 
to automatically configure everything. The templates:

- Auto-create all networking components
- Generate unique resource names
- Connect all components together
- Set up proper security

## GETTING STARTED

1. Open the AWS Console
2. Go to CloudFormation
3. Follow instructions in **[DEPLOY-INSTRUCTIONS.md](DEPLOY-INSTRUCTIONS.md)**

## ADVANCED USERS

If you want to upload the templates to your own S3 bucket and generate direct links:

1. Edit the `cfn-upload.sh` script with your bucket name
2. Run the script to upload templates and generate links
3. Use the quick-create links to launch stacks