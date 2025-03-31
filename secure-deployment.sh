#!/bin/bash
# Secure deployment script for Coffee Shop application

# Text formatting
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo "${BOLD}${BLUE}=======================================================${RESET}"
echo "${BOLD}${BLUE}  SECURE COFFEE SHOP APPLICATION DEPLOYMENT ASSISTANT  ${RESET}"
echo "${BOLD}${BLUE}=======================================================${RESET}"

# Check AWS CLI installation
echo "${YELLOW}Checking AWS CLI installation...${RESET}"
if ! command -v aws &> /dev/null; then
    echo "${RED}AWS CLI not found! Please install it first:${RESET}"
    echo "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check AWS CLI configuration
echo "${YELLOW}Checking AWS CLI configuration...${RESET}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo "${RED}AWS CLI is not configured properly!${RESET}"
    echo "Please run: aws configure"
    exit 1
fi

# Get current identity
IDENTITY=$(aws sts get-caller-identity)
ACCOUNT_ID=$(echo $IDENTITY | jq -r '.Account')
USER_ARN=$(echo $IDENTITY | jq -r '.Arn')

echo "${GREEN}Successfully authenticated with AWS!${RESET}"
echo "Account ID: ${BOLD}$ACCOUNT_ID${RESET}"
echo "User ARN: ${BOLD}$USER_ARN${RESET}"

# Create secure parameter file
echo "${YELLOW}Creating secure parameter file...${RESET}"
cat > coffee-shop-parameters.json << EOF
[
  {
    "ParameterKey": "AppName",
    "ParameterValue": "coffee-shop"
  },
  {
    "ParameterKey": "DBPassword",
    "ParameterValue": "CHANGE_ME_TO_A_SECURE_PASSWORD"
  },
  {
    "ParameterKey": "EnableCustomDomain",
    "ParameterValue": "false"
  },
  {
    "ParameterKey": "DomainName",
    "ParameterValue": ""
  },
  {
    "ParameterKey": "EnvironmentName",
    "ParameterValue": "dev"
  }
]
EOF

echo "${GREEN}Created parameter file: coffee-shop-parameters.json${RESET}"
echo "${BOLD}${YELLOW}IMPORTANT: Edit this file to set your secure database password!${RESET}"
echo "You can also enable HTTPS by setting EnableCustomDomain to true and providing your domain."

# Create secure .gitignore
echo "${YELLOW}Creating .gitignore file for sensitive data...${RESET}"
cat > .gitignore << EOF
# Ignore parameter files with sensitive information
*-parameters.json

# Ignore sensitive credential files
.aws/
aws.config

# Ignore local deployment artifacts
.terraform/
terraform.tfstate
terraform.tfstate.backup
.terraform.lock.hcl

# Ignore CloudFormation artifacts
cloudformation-packaged.yaml

# Ignore temporary files
*.tmp
*.temp
.DS_Store
EOF

echo "${GREEN}Created .gitignore file to protect sensitive information${RESET}"

# Create CloudFormation deployment script
echo "${YELLOW}Creating deployment script...${RESET}"
cat > deploy.sh << EOF
#!/bin/bash
# Secure deployment script for CloudFormation

# Step 1: Create bootstrap stack
aws cloudformation create-stack \\
  --stack-name coffee-shop-bootstrap \\
  --template-body file://bootstrap-resources.yaml \\
  --capabilities CAPABILITY_IAM

echo "Waiting for bootstrap stack to complete..."
aws cloudformation wait stack-create-complete \\
  --stack-name coffee-shop-bootstrap

# Step 2: Deploy main application stack
aws cloudformation create-stack \\
  --stack-name coffee-shop-application \\
  --template-body file://coffee-shop-stack.yaml \\
  --parameters file://coffee-shop-parameters.json \\
  --capabilities CAPABILITY_IAM

echo "Deployment started! Monitor progress in the CloudFormation console."
echo "Full deployment may take 15-20 minutes to complete."
EOF

chmod +x deploy.sh
echo "${GREEN}Created executable deployment script: deploy.sh${RESET}"

# Instructions
echo "${BOLD}${BLUE}=======================================================${RESET}"
echo "${BOLD}${BLUE}                   NEXT STEPS                          ${RESET}"
echo "${BOLD}${BLUE}=======================================================${RESET}"
echo ""
echo "${BOLD}1. Edit coffee-shop-parameters.json:${RESET}"
echo "   - Set a strong database password"
echo "   - Customize application name if desired"
echo "   - Set EnableCustomDomain to true and add domain if using HTTPS"
echo ""
echo "${BOLD}2. Deploy using one of these methods:${RESET}"
echo "   A) Run the deployment script: ./deploy.sh"
echo "   B) Upload templates manually to CloudFormation console"
echo ""
echo "${BOLD}3. If using HTTPS:${RESET}"
echo "   - Follow instructions in HTTPS-SETUP.md"
echo ""
echo "${BOLD}${YELLOW}SECURITY REMINDER:${RESET}"
echo "- DO NOT commit coffee-shop-parameters.json to git"
echo "- Keep your AWS credentials secure"
echo "- Rotate your access keys regularly"
echo ""
echo "${BOLD}${GREEN}Setup complete! Your deployment is ready to be secured.${RESET}"