# AWS CLI SETUP FOR SECURE DEPLOYMENT

This guide helps you set up AWS CLI securely for deploying the Coffee Shop application.

## STEP 1: INSTALL AWS CLI

### For Windows:
1. Download the AWS CLI MSI installer:
   https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run the downloaded installer
3. Verify installation: `aws --version`

### For macOS:
```bash
# Option 1: Using Homebrew
brew install awscli

# Option 2: Using the official installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### For Linux:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## STEP 2: CREATE ACCESS KEYS (SECURE METHOD)

The most secure approach is to create temporary credentials using AWS IAM Identity Center:

1. Log into AWS Console
2. Go to IAM Identity Center
3. Set up an SSO user if not already done
4. Enable command line access for your user
5. Use the provided AWS access portal URL to sign in
6. Choose "Command line or programmatic access"
7. Copy the credentials

Alternatively, for standard IAM users (less secure but simpler):

1. Log into AWS Console
2. Go to IAM → Users → Your User → Security credentials
3. Click "Create access key"
4. Choose "Command Line Interface"
5. Download the CSV file with credentials
6. NEVER SHARE THIS FILE OR COMMIT IT TO GIT!

## STEP 3: CONFIGURE AWS CLI

```bash
aws configure
```

Enter when prompted:
- AWS Access Key ID: [your access key]
- AWS Secret Access Key: [your secret key]
- Default region name: [your region, e.g., us-east-1]
- Default output format: json

## STEP 4: VERIFY CONFIGURATION

```bash
aws sts get-caller-identity
```

You should see output with your:
- Account ID
- User ARN
- User ID

## STEP 5: SETUP CREDENTIALS FILE FOR SECURE DEPLOYMENT

Our deployment script will automatically create a parameter file for sensitive values.

Run the secure setup script:
```bash
chmod +x secure-deployment.sh
./secure-deployment.sh
```

This will:
1. Create a secure parameters file (excluded from git)
2. Set up proper .gitignore
3. Generate a deployment script
4. Check your AWS CLI configuration

## SECURITY BEST PRACTICES

1. **Never commit credentials to git**
   - The .gitignore file is set up to exclude sensitive files
   - Double-check before committing that no credentials are exposed

2. **Use temporary credentials when possible**
   - AWS IAM Identity Center is preferred
   - Alternatively, use AWS STS AssumeRole

3. **Use least privilege access**
   - Create IAM policies that grant only the permissions needed
   - Example policy for this deployment:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DeleteStack",
        "s3:CreateBucket",
        "s3:PutObject",
        "acm:RequestCertificate",
        "cloudfront:CreateDistribution",
        "elasticbeanstalk:CreateApplication",
        "rds:CreateDBInstance",
        "efs:CreateFileSystem"
      ],
      "Resource": "*"
    }
  ]
}
```

4. **Rotate credentials regularly**
   - Change your access keys every 90 days
   - Delete unused keys

5. **Enable MFA for CLI access**
   - Use `aws sts get-session-token` with MFA for sensitive operations

## OBTAINING ACCESS TOKEN FOR AUTOMATED SETUP

For CI/CD pipelines or automated setup, use AWS Security Token Service:

```bash
# Assuming a role with MFA
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT_ID:role/YourDeployRole \
  --role-session-name DeploySession \
  --serial-number arn:aws:iam::ACCOUNT_ID:mfa/your-username \
  --token-code 123456

# Export the temporary credentials
export AWS_ACCESS_KEY_ID="temporary_access_key"
export AWS_SECRET_ACCESS_KEY="temporary_secret_key"
export AWS_SESSION_TOKEN="temporary_session_token"
```

## AUTOMATING WITH AWS PROFILES

For multiple environments, use AWS profiles:

```bash
# Create a profile
aws configure --profile coffee-shop-dev

# Use a specific profile
aws cloudformation create-stack --profile coffee-shop-dev ...
```

Add to your deployment script:
```bash
# Set environment variable to use profile
export AWS_PROFILE=coffee-shop-dev
```

## TROUBLESHOOTING

If you see "Unable to locate credentials":
1. Verify credentials file: `cat ~/.aws/credentials`
2. Check environment variables: `env | grep AWS`
3. Try running `aws configure` again

For "Access Denied" errors:
1. Verify your IAM permissions
2. Check if temporary credentials have expired
3. Ensure you have permissions for the specific services