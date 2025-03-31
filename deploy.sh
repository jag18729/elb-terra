#!/bin/bash
# Comprehensive deployment script for Coffee Shop application with error handling

# Text formatting
BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Default variables
CONFIG_FILE="deployment-config.json"
STACK_PREFIX="coffee-shop"
REGION=$(aws configure get region || echo "us-east-1")
DEPLOY_MODE="create"
OPERATION="all"
NO_PROMPT=false

# Function to display script usage
show_usage() {
    echo -e "${BOLD}COFFEE SHOP SECURE DEPLOYMENT SCRIPT${NC}"
    echo
    echo -e "Usage: $0 [options]"
    echo
    echo -e "Options:"
    echo -e "  -h, --help                 Show this help message"
    echo -e "  -c, --config FILE          Configuration file (default: deployment-config.json)"
    echo -e "  -r, --region REGION        AWS region (default: from AWS CLI config)"
    echo -e "  -p, --prefix PREFIX        Stack name prefix (default: coffee-shop)"
    echo -e "  -m, --mode MODE            Deployment mode: create, update, or delete (default: create)"
    echo -e "  -o, --operation OPERATION  Operation to perform: bootstrap, main, all (default: all)"
    echo -e "  -y, --yes                  Skip confirmation prompts"
    echo
    echo -e "Example:"
    echo -e "  $0 --config my-config.json --region us-east-1 --prefix my-app"
    echo
}

# Function to log messages with timestamp
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    case $level in
        "INFO")
            echo -e "${timestamp} ${CYAN}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${timestamp} ${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARN")
            echo -e "${timestamp} ${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${timestamp} ${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo -e "${timestamp} $message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if JSON file is valid
validate_json() {
    local file=$1
    if ! command_exists jq; then
        log "ERROR" "jq is not installed. Cannot validate JSON. Please install jq or manually verify your JSON files."
        return 1
    fi
    
    if ! jq . "$file" > /dev/null 2>&1; then
        log "ERROR" "Invalid JSON in file: $file"
        return 1
    fi
    
    log "INFO" "JSON validation passed for: $file"
    return 0
}

# Function to check AWS CLI configuration
check_aws_cli() {
    if ! command_exists aws; then
        log "ERROR" "AWS CLI is not installed. Please install it and configure your credentials."
        return 1
    fi
    
    log "INFO" "Verifying AWS CLI credentials..."
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        log "ERROR" "AWS CLI is not properly configured. Please run 'aws configure' to set up your credentials."
        return 1
    fi
    
    local identity=$(aws sts get-caller-identity --output json)
    local account_id=$(echo "$identity" | jq -r '.Account')
    local user_arn=$(echo "$identity" | jq -r '.Arn')
    
    log "SUCCESS" "AWS CLI is properly configured"
    log "INFO" "Account ID: $account_id"
    log "INFO" "User ARN: $user_arn"
    log "INFO" "Using region: $REGION"
    
    return 0
}

# Function to create parameter file from config
create_parameter_file() {
    local config_file=$1
    local params_file="coffee-shop-parameters.json"
    
    if [ ! -f "$config_file" ]; then
        log "ERROR" "Configuration file not found: $config_file"
        return 1
    fi
    
    log "INFO" "Creating CloudFormation parameters file from config..."
    
    if ! validate_json "$config_file"; then
        return 1
    fi
    
    local app_name=$(jq -r '.appName // "coffee-shop"' "$config_file")
    local db_password=$(jq -r '.dbPassword // ""' "$config_file")
    local enable_custom_domain=$(jq -r '.enableCustomDomain // "false"' "$config_file")
    local domain_name=$(jq -r '.domainName // ""' "$config_file")
    local environment=$(jq -r '.environment // "dev"' "$config_file")
    
    if [ -z "$db_password" ] || [ "$db_password" == "null" ]; then
        log "ERROR" "Database password not specified in config file"
        return 1
    fi
    
    if [ "$enable_custom_domain" == "true" ] && [ -z "$domain_name" ]; then
        log "ERROR" "Custom domain is enabled but no domain name specified"
        return 1
    fi
    
    cat > "$params_file" << EOF
[
  {
    "ParameterKey": "AppName",
    "ParameterValue": "$app_name"
  },
  {
    "ParameterKey": "DBPassword",
    "ParameterValue": "$db_password"
  },
  {
    "ParameterKey": "EnableCustomDomain",
    "ParameterValue": "$enable_custom_domain"
  },
  {
    "ParameterKey": "DomainName",
    "ParameterValue": "$domain_name"
  },
  {
    "ParameterKey": "EnvironmentName",
    "ParameterValue": "$environment"
  }
]
EOF
    
    log "SUCCESS" "Created parameters file: $params_file"
    return 0
}

# Function to check if CloudFormation stack exists
stack_exists() {
    local stack_name=$1
    aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" &> /dev/null
    return $?
}

# Function to wait for stack operation to complete
wait_for_stack() {
    local stack_name=$1
    local operation=$2
    local wait_cmd="stack-$operation-complete"
    local status_cmd="stack-$operation-failed"
    
    log "INFO" "Waiting for $stack_name $operation to complete..."
    
    if ! aws cloudformation wait "$wait_cmd" --stack-name "$stack_name" --region "$REGION"; then
        log "ERROR" "$stack_name $operation failed"
        
        local events=$(aws cloudformation describe-stack-events \
            --stack-name "$stack_name" \
            --region "$REGION" \
            --query "StackEvents[?ResourceStatus=='CREATE_FAILED' || ResourceStatus=='UPDATE_FAILED' || ResourceStatus=='DELETE_FAILED'].{Status:ResourceStatus,Reason:ResourceStatusReason,LogicalId:LogicalResourceId}" \
            --output json)
        
        log "ERROR" "Stack events with failures:"
        echo "$events" | jq -r '.[] | "\(.LogicalId): \(.Status) - \(.Reason)"'
        
        return 1
    fi
    
    log "SUCCESS" "$stack_name $operation completed successfully"
    return 0
}

# Function to deploy bootstrap stack
deploy_bootstrap() {
    local stack_name="${STACK_PREFIX}-bootstrap"
    local template="bootstrap-resources.yaml"
    
    log "INFO" "Validating bootstrap template..."
    if ! aws cloudformation validate-template --template-body "file://$template" --region "$REGION" > /dev/null; then
        log "ERROR" "Bootstrap template validation failed"
        return 1
    fi
    
    if [ "$DEPLOY_MODE" == "delete" ]; then
        if stack_exists "$stack_name"; then
            log "INFO" "Deleting bootstrap stack: $stack_name"
            aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
            wait_for_stack "$stack_name" "delete"
            return $?
        else
            log "INFO" "Bootstrap stack does not exist, skipping deletion"
            return 0
        fi
    fi
    
    if stack_exists "$stack_name"; then
        if [ "$DEPLOY_MODE" == "update" ]; then
            log "INFO" "Updating bootstrap stack: $stack_name"
            aws cloudformation update-stack \
                --stack-name "$stack_name" \
                --template-body "file://$template" \
                --capabilities CAPABILITY_IAM \
                --region "$REGION" || {
                    local update_error=$?
                    if echo $update_error | grep -q "No updates are to be performed"; then
                        log "INFO" "No updates needed for bootstrap stack"
                        return 0
                    else
                        log "ERROR" "Failed to update bootstrap stack"
                        return 1
                    fi
                }
            wait_for_stack "$stack_name" "update"
            return $?
        else
            log "WARN" "Bootstrap stack already exists. Use --mode update to update it."
            return 0
        fi
    else
        if [ "$DEPLOY_MODE" == "update" ]; then
            log "WARN" "Bootstrap stack does not exist, creating instead of updating"
        fi
        
        log "INFO" "Creating bootstrap stack: $stack_name"
        aws cloudformation create-stack \
            --stack-name "$stack_name" \
            --template-body "file://$template" \
            --capabilities CAPABILITY_IAM \
            --region "$REGION"
        
        wait_for_stack "$stack_name" "create"
        return $?
    fi
}

# Function to deploy main application stack
deploy_main_stack() {
    local stack_name="${STACK_PREFIX}-application"
    local template="coffee-shop-stack.yaml"
    local params_file="coffee-shop-parameters.json"
    
    if [ ! -f "$params_file" ]; then
        log "ERROR" "Parameters file not found: $params_file"
        return 1
    fi
    
    log "INFO" "Validating main application template..."
    if ! aws cloudformation validate-template --template-body "file://$template" --region "$REGION" > /dev/null; then
        log "ERROR" "Main application template validation failed"
        return 1
    fi
    
    # Check if bootstrap stack is deployed
    local bootstrap_stack="${STACK_PREFIX}-bootstrap"
    if ! stack_exists "$bootstrap_stack" && [ "$DEPLOY_MODE" != "delete" ]; then
        log "ERROR" "Bootstrap stack does not exist. Please deploy bootstrap stack first."
        return 1
    fi
    
    if [ "$DEPLOY_MODE" == "delete" ]; then
        if stack_exists "$stack_name"; then
            log "INFO" "Deleting main application stack: $stack_name"
            aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
            wait_for_stack "$stack_name" "delete"
            return $?
        else
            log "INFO" "Main application stack does not exist, skipping deletion"
            return 0
        fi
    fi
    
    if stack_exists "$stack_name"; then
        if [ "$DEPLOY_MODE" == "update" ]; then
            log "INFO" "Updating main application stack: $stack_name"
            aws cloudformation update-stack \
                --stack-name "$stack_name" \
                --template-body "file://$template" \
                --parameters "file://$params_file" \
                --capabilities CAPABILITY_IAM \
                --region "$REGION" || {
                    local update_error=$?
                    if echo $update_error | grep -q "No updates are to be performed"; then
                        log "INFO" "No updates needed for main application stack"
                        return 0
                    else
                        log "ERROR" "Failed to update main application stack"
                        return 1
                    fi
                }
            wait_for_stack "$stack_name" "update"
            return $?
        else
            log "WARN" "Main application stack already exists. Use --mode update to update it."
            return 0
        fi
    else
        if [ "$DEPLOY_MODE" == "update" ]; then
            log "WARN" "Main application stack does not exist, creating instead of updating"
        fi
        
        log "INFO" "Creating main application stack: $stack_name"
        aws cloudformation create-stack \
            --stack-name "$stack_name" \
            --template-body "file://$template" \
            --parameters "file://$params_file" \
            --capabilities CAPABILITY_IAM \
            --region "$REGION"
        
        wait_for_stack "$stack_name" "create"
        return $?
    fi
}

# Function to display stack outputs
display_outputs() {
    local stack_name="${STACK_PREFIX}-application"
    
    if ! stack_exists "$stack_name"; then
        log "ERROR" "Main application stack does not exist, no outputs to display"
        return 1
    fi
    
    log "INFO" "Retrieving stack outputs..."
    
    local outputs=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" --query "Stacks[0].Outputs" --output json)
    
    echo -e "\n${BOLD}${GREEN}===== DEPLOYMENT SUCCESSFUL =====\n${NC}"
    echo -e "${BOLD}APPLICATION ENDPOINTS:${NC}"
    
    echo "$outputs" | jq -r '.[] | "\(.OutputKey): \(.OutputValue)"' | while read -r line; do
        key=$(echo "$line" | cut -d: -f1)
        value=$(echo "$line" | cut -d: -f2- | sed 's/^ //')
        echo -e "${BOLD}${BLUE}$key:${NC} $value"
    done
    
    # Special note for HTTPS setup
    if echo "$outputs" | grep -q "CertificateValidationInfo"; then
        echo -e "\n${BOLD}${YELLOW}IMPORTANT FOR HTTPS SETUP:${NC}"
        echo -e "1. Validate your certificate in the AWS Certificate Manager console"
        echo -e "2. Follow the instructions in HTTPS-SETUP.md to complete domain setup"
        echo -e "3. Certificate validation can take up to 24 hours to propagate"
    fi
    
    echo -e "\n${BOLD}To access these values later, run:${NC}"
    echo -e "aws cloudformation describe-stacks --stack-name $stack_name --region $REGION --query \"Stacks[0].Outputs\" --output table"
    
    return 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_usage
            exit 0
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift
            shift
            ;;
        -r|--region)
            REGION="$2"
            shift
            shift
            ;;
        -p|--prefix)
            STACK_PREFIX="$2"
            shift
            shift
            ;;
        -m|--mode)
            DEPLOY_MODE="$2"
            if [[ ! "$DEPLOY_MODE" =~ ^(create|update|delete)$ ]]; then
                log "ERROR" "Invalid mode: $DEPLOY_MODE. Must be create, update, or delete."
                exit 1
            fi
            shift
            shift
            ;;
        -o|--operation)
            OPERATION="$2"
            if [[ ! "$OPERATION" =~ ^(bootstrap|main|all)$ ]]; then
                log "ERROR" "Invalid operation: $OPERATION. Must be bootstrap, main, or all."
                exit 1
            fi
            shift
            shift
            ;;
        -y|--yes)
            NO_PROMPT=true
            shift
            ;;
        *)
            log "ERROR" "Unknown option: $key"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo -e "${BOLD}${BLUE}======================================================${NC}"
    echo -e "${BOLD}${BLUE}    COFFEE SHOP APPLICATION DEPLOYMENT SCRIPT        ${NC}"
    echo -e "${BOLD}${BLUE}======================================================${NC}"
    echo
    
    # Display deployment plan
    log "INFO" "Deployment plan:"
    log "INFO" " - Mode: $DEPLOY_MODE"
    log "INFO" " - Stack prefix: $STACK_PREFIX"
    log "INFO" " - Region: $REGION"
    log "INFO" " - Config file: $CONFIG_FILE"
    log "INFO" " - Operation: $OPERATION"
    echo
    
    if [ ! -f "$CONFIG_FILE" ] && [ "$DEPLOY_MODE" != "delete" ]; then
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        log "INFO" "Creating template configuration file..."
        
        cat > "$CONFIG_FILE" << EOF
{
    "appName": "coffee-shop",
    "dbPassword": "CHANGE-ME-TO-SECURE-PASSWORD",
    "enableCustomDomain": false,
    "domainName": "",
    "environment": "dev"
}
EOF
        
        log "SUCCESS" "Created template configuration file: $CONFIG_FILE"
        log "ERROR" "Please edit $CONFIG_FILE with your values and run the script again"
        exit 1
    fi
    
    # Check AWS CLI configuration
    if ! check_aws_cli; then
        exit 1
    fi
    
    # Confirm deployment
    if [ "$NO_PROMPT" = false ]; then
        if [ "$DEPLOY_MODE" == "delete" ]; then
            echo -e "${BOLD}${RED}WARNING:${NC} You are about to DELETE the following stacks:"
            if [ "$OPERATION" == "bootstrap" ] || [ "$OPERATION" == "all" ]; then
                echo " - ${STACK_PREFIX}-bootstrap"
            fi
            if [ "$OPERATION" == "main" ] || [ "$OPERATION" == "all" ]; then
                echo " - ${STACK_PREFIX}-application"
            fi
            
            read -p "Do you want to continue? (y/N) " confirm
            if [[ $confirm != [yY] ]]; then
                log "INFO" "Deployment cancelled by user"
                exit 0
            fi
        else
            echo -e "${BOLD}Ready to deploy?${NC}"
            read -p "Continue with deployment? (Y/n) " confirm
            if [[ $confirm == [nN] ]]; then
                log "INFO" "Deployment cancelled by user"
                exit 0
            fi
        fi
    fi
    
    # Create parameter file for non-delete operations
    if [ "$DEPLOY_MODE" != "delete" ]; then
        if ! create_parameter_file "$CONFIG_FILE"; then
            exit 1
        fi
    fi
    
    # Execute deployment operations
    local result=0
    
    if [ "$OPERATION" == "bootstrap" ] || [ "$OPERATION" == "all" ]; then
        if ! deploy_bootstrap; then
            log "ERROR" "Bootstrap stack deployment failed"
            result=1
            if [ "$OPERATION" == "all" ]; then
                log "ERROR" "Skipping main stack deployment due to bootstrap failure"
                exit $result
            fi
        fi
    fi
    
    if [ "$OPERATION" == "main" ] || [ "$OPERATION" == "all" ]; then
        if ! deploy_main_stack; then
            log "ERROR" "Main application stack deployment failed"
            result=1
        elif [ "$DEPLOY_MODE" != "delete" ]; then
            display_outputs
        fi
    fi
    
    if [ $result -eq 0 ]; then
        if [ "$DEPLOY_MODE" == "delete" ]; then
            log "SUCCESS" "Stack deletion completed successfully"
        else
            log "SUCCESS" "Deployment completed successfully"
        fi
    else
        log "ERROR" "Deployment completed with errors"
    fi
    
    exit $result
}

# Execute main function
main