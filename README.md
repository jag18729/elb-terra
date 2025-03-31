# COFFEE SHOP DEPLOYMENT WITH HTTPS AND CLI AUTOMATION

Deploy a complete coffee shop application with HTTPS support using CloudFormation and CLI automation.

## FULLY AUTOMATED CLI DEPLOYMENT (RECOMMENDED)

```bash
# Make deployment script executable
chmod +x deploy.sh

# Run the script (creates config file template on first run)
./deploy.sh

# Edit config with your database password and domain settings
vim deployment-config.json

# Deploy with the updated config
./deploy.sh --region us-east-1 --yes
```

For complete CLI options and examples, see [CLI-USAGE.md](CLI-USAGE.md)

## WHAT'S INCLUDED

- **Complete Coffee Shop Website**
- **Front-end:** Static website hosted on S3
- **Back-end:** Elastic Beanstalk PHP application  
- **Database:** MySQL 8.0 database
- **Storage:** EFS for persistent storage
- **HTTPS Support:** CloudFront with SSL/TLS
- **Full CLI Automation:** Zero AWS console interaction needed

## FEATURES

### Comprehensive CLI Automation

- Modular deployment script with robust error handling
- JSON configuration for all deployment parameters 
- Detailed logging with timestamps
- Automatic credential validation
- Stack event troubleshooting information
- Support for create/update/delete operations

### HTTPS with Custom Domain

For secure HTTPS with your domain:

1. Edit `deployment-config.json`:
```json
{
    "appName": "coffee-shop",
    "dbPassword": "YOUR-SECURE-PASSWORD",
    "enableCustomDomain": true,
    "domainName": "yourdomain.com",
    "environment": "prod"
}
```

2. Deploy with CLI:
```bash
./deploy.sh --yes
```

3. Follow certificate validation steps in [HTTPS-SETUP.md](HTTPS-SETUP.md)

### Security Features

- **Secure Parameter Handling:** JSON configuration outside git
- **Comprehensive .gitignore:** Prevents credential leakage
- **Encrypted Database:** RDS with encryption enabled
- **Encrypted File Storage:** EFS with encryption enabled
- **Proper Security Groups:** Least privilege access
- **HTTPS Support:** SSL/TLS for secure connections

## DOCUMENTATION

- **[CLI-USAGE.md](CLI-USAGE.md)** - Complete CLI usage guide
- **[AWS-CLI-SETUP.md](AWS-CLI-SETUP.md)** - AWS CLI configuration
- **[HTTPS-SETUP.md](HTTPS-SETUP.md)** - Custom domain setup
- **[DEPLOY-INSTRUCTIONS.md](DEPLOY-INSTRUCTIONS.md)** - Console deployment (alternative)

## ARCHITECTURE

1. **Bootstrap Stack:**
   - Creates S3 bucket
   - Runs Lambda function to package application
   - Uses CloudFormation intrinsic functions (`!Ref`, `!Sub`, `!GetAtt`)

2. **Main Application Stack:**
   - Creates full infrastructure automatically:
     - VPC with public/private subnets
     - Security groups and networking
     - S3 website bucket with proper content types
     - Elastic Beanstalk application with RDS
     - EFS for shared storage
     - CloudFront with SSL/TLS (when enabled)

## VIM USERS

The deployment script is compatible with Vim workflows:

```bash
# Generate default config
./deploy.sh

# Edit with Vim
vim deployment-config.json

# Deploy with options
./deploy.sh --mode update --region us-west-2
```

See [CLI-USAGE.md](CLI-USAGE.md#vim-users) for Vim-specific tips.