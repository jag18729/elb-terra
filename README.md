# SECURE COFFEE SHOP DEPLOYMENT WITH HTTPS

Deploy a complete coffee shop application with HTTPS support using CloudFormation.

## DEPLOYMENT OPTIONS

### OPTION 1: SIMPLE CONSOLE DEPLOYMENT
1. Upload the `bootstrap-resources.yaml` template in CloudFormation console
2. Upload the `coffee-shop-stack.yaml` template in CloudFormation console
3. Follow the step-by-step guide in [DEPLOY-INSTRUCTIONS.md](DEPLOY-INSTRUCTIONS.md)

### OPTION 2: SECURE CLI DEPLOYMENT (RECOMMENDED)
1. Set up AWS CLI following [AWS-CLI-SETUP.md](AWS-CLI-SETUP.md)
2. Run the secure deployment script: `./secure-deployment.sh`
3. Edit the generated parameters file with your secure values
4. Run the deployment script: `./deploy.sh`

## WHAT'S INCLUDED

- **Complete Coffee Shop Website**
- **Front-end:** Static website hosted on S3
- **Back-end:** Elastic Beanstalk PHP application
- **Database:** MySQL 8.0 database
- **Storage:** EFS for shared persistence
- **HTTPS Support:** CloudFront with custom domain and SSL/TLS

## HTTPS CONFIGURATION

For secure HTTPS setup with your custom domain:

1. Set `EnableCustomDomain` to `true` when deploying
2. Provide your domain name (e.g., yourdomain.com)
3. Follow detailed instructions in [HTTPS-SETUP.md](HTTPS-SETUP.md)

## SECURITY FEATURES

This deployment includes several security features:

- **Secure Parameter Handling:** Sensitive values stored in secure parameter files
- **Proper .gitignore:** Prevents committing sensitive files
- **Encrypted Database:** RDS with encryption enabled
- **Encrypted File System:** EFS with encryption enabled
- **SSL/TLS Support:** Secure HTTPS connections
- **Secure Security Groups:** Minimal required access

## DOCUMENTATION

- **[DEPLOY-INSTRUCTIONS.md](DEPLOY-INSTRUCTIONS.md)** - Step-by-step deployment guide
- **[AWS-CLI-SETUP.md](AWS-CLI-SETUP.md)** - Secure AWS CLI configuration
- **[HTTPS-SETUP.md](HTTPS-SETUP.md)** - Custom domain and HTTPS setup

## HOW IT WORKS

1. **First Template (`bootstrap-resources.yaml`):**
   - Creates a bootstrap S3 bucket
   - Runs a Lambda function that packages and uploads the application
   - Prepares everything needed for the main stack

2. **Second Template (`coffee-shop-stack.yaml`):**
   - Creates ALL infrastructure using CloudFormation's intrinsic functions
   - No manual configuration of networking components required
   - Automatically sets up HTTPS if a custom domain is provided

## GETTING STARTED

The fastest way to get started securely:

```bash
# Clone this repository
git clone <repository-url>

# Make the script executable
chmod +x secure-deployment.sh

# Run the secure setup script
./secure-deployment.sh

# Edit the parameters file with your values
nano coffee-shop-parameters.json

# Deploy using the generated script
./deploy.sh
```

IMPORTANT: See [AWS-CLI-SETUP.md](AWS-CLI-SETUP.md) for secure credential management!