#!/bin/bash
# Script to upload CloudFormation templates to an S3 bucket and generate links

# CHANGE THESE VALUES:
BUCKET_NAME="YOUR-BUCKET-NAME"  # Create an S3 bucket in your account and put its name here
REGION="us-east-1"              # Change if using a different region

# Create bucket if it doesn't exist
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION

# Upload CloudFormation templates
aws s3 cp bootstrap-resources.yaml s3://$BUCKET_NAME/coffee-shop/bootstrap-resources.yaml
aws s3 cp coffee-shop-stack.yaml s3://$BUCKET_NAME/coffee-shop/coffee-shop-stack.yaml

# Generate S3 URLs
BOOTSTRAP_URL="https://$BUCKET_NAME.s3.amazonaws.com/coffee-shop/bootstrap-resources.yaml"
MAIN_URL="https://$BUCKET_NAME.s3.amazonaws.com/coffee-shop/coffee-shop-stack.yaml"

# Generate CloudFormation quick-create links
BOOTSTRAP_CFN_URL="https://console.aws.amazon.com/cloudformation/home?region=$REGION#/stacks/create/review?templateURL=$BOOTSTRAP_URL&stackName=coffee-shop-bootstrap"
MAIN_CFN_URL="https://console.aws.amazon.com/cloudformation/home?region=$REGION#/stacks/create/review?templateURL=$MAIN_URL&stackName=coffee-shop-application"

# Output the URLs
echo "============================================================"
echo "BOOTSTRAP TEMPLATE URL:"
echo $BOOTSTRAP_URL
echo ""
echo "MAIN TEMPLATE URL:"
echo $MAIN_URL
echo ""
echo "============================================================"
echo "BOOTSTRAP QUICK-CREATE LINK:"
echo $BOOTSTRAP_CFN_URL
echo ""
echo "MAIN QUICK-CREATE LINK:"
echo $MAIN_CFN_URL
echo "============================================================"
echo ""
echo "INSTRUCTIONS:"
echo "1. First click the BOOTSTRAP QUICK-CREATE LINK and create that stack"
echo "2. Wait for it to complete"
echo "3. Then click the MAIN QUICK-CREATE LINK and create the main stack"
echo "4. Enter your database password when prompted"
echo "============================================================"