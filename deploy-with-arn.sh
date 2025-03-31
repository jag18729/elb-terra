#\!/bin/bash
# Deployment script with full ARN for LabRole

# Configuration
APP_NAME="coffee-shop"
ENV_NAME="coffee-shop-env"
S3_BUCKET="coffee-shop-app-deployment-garcia-rafael-2274088"
IAM_ROLE_ARN="arn:aws:iam::785362574523:role/LabRole"

# Find PHP solution stack
echo "Finding PHP solution stack..."
SOLUTION_STACK=$(aws elasticbeanstalk list-available-solution-stacks | grep -i "running php" | grep -i "Amazon Linux" | head -1 | sed 's/.*"\(.*\)".*/\1/')
echo "Using solution stack: $SOLUTION_STACK"

# Create application bundle if not already created
if [ \! -f s3website.zip ]; then
  echo "Creating application bundle..."
  cd S3Website
  zip -r ../s3website.zip *
  cd ..
else
  echo "Using existing application bundle s3website.zip"
fi

# Upload to S3
echo "Uploading to S3..."
aws s3 cp s3website.zip s3://$S3_BUCKET/

# Create or update application
echo "Creating/updating application..."
aws elasticbeanstalk create-application --application-name $APP_NAME > /dev/null 2>&1 || true

# Create application version
VERSION="v1-$(date +%s)"
echo "Creating application version: $VERSION"
aws elasticbeanstalk create-application-version \
  --application-name $APP_NAME \
  --version-label $VERSION \
  --source-bundle S3Bucket=$S3_BUCKET,S3Key=s3website.zip

# Attempt to create a new environment with the full ARN
echo "Creating new environment with full ARN for LabRole..."
aws elasticbeanstalk create-environment \
  --application-name $APP_NAME \
  --environment-name $ENV_NAME \
  --solution-stack-name "$SOLUTION_STACK" \
  --version-label $VERSION \
  --option-settings \
    "Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=$IAM_ROLE_ARN" \
    "Namespace=aws:autoscaling:launchconfiguration,OptionName=InstanceType,Value=t3.small" \
    "Namespace=aws:autoscaling:launchconfiguration,OptionName=DisableIMDSv1,Value=false" \
    "Namespace=aws:elasticbeanstalk:environment:proxy,OptionName=ProxyServer,Value=apache"

echo "Deployment initiated. Checking status..."
sleep 10

# Get current status
STATUS=$(aws elasticbeanstalk describe-environments \
  --application-name $APP_NAME \
  --environment-names $ENV_NAME \
  --query "Environments[0].Status" \
  --output text)

HEALTH=$(aws elasticbeanstalk describe-environments \
  --application-name $APP_NAME \
  --environment-names $ENV_NAME \
  --query "Environments[0].Health" \
  --output text)

ENV_URL=$(aws elasticbeanstalk describe-environments \
  --application-name $APP_NAME \
  --environment-names $ENV_NAME \
  --query "Environments[0].CNAME" \
  --output text)

echo "Environment Status: $STATUS"
echo "Environment Health: $HEALTH"
echo "Environment URL: $ENV_URL"

echo "To check the status in the AWS console:"
echo "1. Log in to AWS Console at https://console.aws.amazon.com/"
echo "2. Navigate to Elastic Beanstalk service"
echo "3. Click on 'coffee-shop' application"
echo "4. Select 'coffee-shop-env' environment"
echo "5. You'll see the dashboard with status, health, and recent events"

echo "You can also check status from command line with:"
echo "aws elasticbeanstalk describe-environments --application-name coffee-shop --environment-names coffee-shop-env --query \"Environments[0].[Status,Health,CNAME]\" --output text"
