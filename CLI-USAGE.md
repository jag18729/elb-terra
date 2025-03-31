# CLI DEPLOYMENT GUIDE

This guide explains how to deploy the Coffee Shop application entirely via command line, using the `deploy.sh` script.

## PREREQUISITES

1. AWS CLI installed and configured
2. Bash shell environment
3. jq installed (for JSON processing) - `apt install jq` or `brew install jq`

## QUICK START

```bash
# Make the script executable
chmod +x deploy.sh

# Run with default settings (create mode, all operations)
./deploy.sh
```

The script will automatically:
1. Create a template configuration file if none exists
2. Validate your AWS CLI setup
3. Create the bootstrap stack
4. Deploy the main application stack
5. Display all stack outputs

## CONFIGURATION FILE

Edit the `deployment-config.json` file to set your parameters:

```json
{
    "appName": "coffee-shop",
    "dbPassword": "YOUR-SECURE-PASSWORD",
    "enableCustomDomain": false,
    "domainName": "",
    "environment": "dev"
}
```

To enable HTTPS with a custom domain:
```json
{
    "appName": "coffee-shop",
    "dbPassword": "YOUR-SECURE-PASSWORD",
    "enableCustomDomain": true,
    "domainName": "yourdomain.com",
    "environment": "dev"
}
```

## ADVANCED CLI USAGE

### Deployment Options

Deploy with custom configuration file:
```bash
./deploy.sh --config my-custom-config.json
```

Deploy to a specific region:
```bash
./deploy.sh --region us-west-2
```

Use a different stack name prefix:
```bash
./deploy.sh --prefix my-coffee-app
```

Skip confirmation prompts:
```bash
./deploy.sh --yes
```

### Deployment Modes

Create new stacks (default):
```bash
./deploy.sh --mode create
```

Update existing stacks:
```bash
./deploy.sh --mode update
```

Delete all stacks:
```bash
./deploy.sh --mode delete
```

### Selective Operations

Deploy only the bootstrap stack:
```bash
./deploy.sh --operation bootstrap
```

Deploy only the main application stack:
```bash
./deploy.sh --operation main
```

Deploy everything (default):
```bash
./deploy.sh --operation all
```

### Combined Examples

Update an existing deployment with a new configuration:
```bash
./deploy.sh --mode update --config production-config.json
```

Deploy to production with a custom domain:
```bash
./deploy.sh --prefix prod-coffee --config production-config.json
```

Delete a specific deployment:
```bash
./deploy.sh --mode delete --prefix test-deployment
```

## ERROR HANDLING

The script includes comprehensive error handling:

1. **Validation Errors:**
   - AWS CLI configuration check
   - JSON configuration validation
   - CloudFormation template validation
   - Parameter validation

2. **Operational Errors:**
   - Stack creation/update/deletion failures
   - Resource creation failures
   - Permission issues
   - Detailed stack event reporting

3. **Troubleshooting:**
   - When a stack operation fails, the script displays failed stack events
   - Error messages include specific reasons for failures
   - All operations are logged with timestamps

## LOGGING

All script output includes timestamps and log levels for better traceability:
- INFO: General information
- SUCCESS: Successful operations
- WARN: Warning conditions
- ERROR: Error conditions

## VIM USERS

For Vim users, to edit the configuration file:

```bash
# Create default config if it doesn't exist
./deploy.sh

# Edit with Vim
vim deployment-config.json
```

Use Vim JSON syntax highlighting:
```
:syntax on
:set filetype=json
```

## FULL USAGE REFERENCE

```
COFFEE SHOP SECURE DEPLOYMENT SCRIPT

Usage: ./deploy.sh [options]

Options:
  -h, --help                 Show this help message
  -c, --config FILE          Configuration file (default: deployment-config.json)
  -r, --region REGION        AWS region (default: from AWS CLI config)
  -p, --prefix PREFIX        Stack name prefix (default: coffee-shop)
  -m, --mode MODE            Deployment mode: create, update, or delete (default: create)
  -o, --operation OPERATION  Operation to perform: bootstrap, main, all (default: all)
  -y, --yes                  Skip confirmation prompts

Example:
  ./deploy.sh --config my-config.json --region us-east-1 --prefix my-app
```