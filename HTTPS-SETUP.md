# HTTPS SETUP GUIDE

This guide explains how to set up HTTPS for your Coffee Shop application using your own domain.

## PREREQUISITES

1. **Own a domain name** (purchased from Route 53, GoDaddy, Namecheap, etc.)
2. **Access to modify DNS records** for your domain
3. **AWS CLI configured** with proper permissions

## AUTOMATED HTTPS SETUP

Our CloudFormation template automatically handles HTTPS setup when you enable it:

1. Creates an SSL/TLS certificate through AWS Certificate Manager (ACM)
2. Deploys a CloudFront distribution with the certificate
3. Configures proper security headers and redirects

## STEP 1: PREPARE DOMAIN CONFIGURATION

### Option A: Using AWS Route 53 (Recommended)
If your domain is in Route 53:

1. Create a hosted zone for your domain if not already done:
   ```bash
   aws route53 create-hosted-zone --name yourdomain.com --caller-reference $(date +%s)
   ```

2. Note the nameservers provided and update them with your domain registrar

### Option B: Using Another DNS Provider
If using GoDaddy, Namecheap, etc., be prepared to add CNAME records for validation.

## STEP 2: DEPLOY WITH CUSTOM DOMAIN

When deploying the CloudFormation template:

1. Set `EnableCustomDomain` to `true`
2. Enter your domain in `DomainName` parameter (e.g., yourdomain.com)

## STEP 3: VALIDATE THE CERTIFICATE

After deployment starts:

1. Go to AWS Certificate Manager console
2. Find your certificate (status will be "Pending validation")
3. Note the CNAME records shown (will look like "_xxx.yourdomain.com")

Add these CNAME records to your DNS:

### Option A: Route 53 Automatic Validation
If using CloudFormation with DNS in Route 53, validation may happen automatically.

### Option B: Manual DNS Configuration
For other DNS providers:

1. Add each CNAME record shown in the ACM console
2. Format: 
   - NAME: _validation-name.yourdomain.com 
   - VALUE: _validation-value.acm-validations.aws
3. Wait for validation (can take 30 minutes to several hours)

## STEP 4: ADD DOMAIN DNS RECORD

After validation is complete and CloudFront is deployed:

1. Get your CloudFront distribution domain:
   ```bash
   aws cloudformation describe-stacks --stack-name coffee-shop-application --query "Stacks[0].Outputs[?OutputKey=='CloudFrontURL'].OutputValue" --output text
   ```

2. Create DNS records for your domain:

   **For Route 53:**
   ```bash
   # Create a JSON file named alias-record.json
   cat > alias-record.json << EOF
   {
     "Changes": [
       {
         "Action": "CREATE",
         "ResourceRecordSet": {
           "Name": "yourdomain.com",
           "Type": "A",
           "AliasTarget": {
             "HostedZoneId": "Z2FDTNDATAQYW2",
             "DNSName": "YOUR-CLOUDFRONT-DOMAIN.cloudfront.net",
             "EvaluateTargetHealth": false
           }
         }
       },
       {
         "Action": "CREATE",
         "ResourceRecordSet": {
           "Name": "www.yourdomain.com",
           "Type": "A",
           "AliasTarget": {
             "HostedZoneId": "Z2FDTNDATAQYW2",
             "DNSName": "YOUR-CLOUDFRONT-DOMAIN.cloudfront.net",
             "EvaluateTargetHealth": false
           }
         }
       }
     ]
   }
   EOF
   
   # Apply the changes (replace with your hosted zone ID)
   aws route53 change-resource-record-sets --hosted-zone-id YOUR-HOSTED-ZONE-ID --change-batch file://alias-record.json
   ```

   **For Other DNS Providers:**
   Add CNAME records:
   - NAME: yourdomain.com → VALUE: YOUR-CLOUDFRONT-DOMAIN.cloudfront.net
   - NAME: www.yourdomain.com → VALUE: YOUR-CLOUDFRONT-DOMAIN.cloudfront.net

## STEP 5: TEST YOUR SECURE WEBSITE

1. Wait for DNS changes to propagate (can take up to 48 hours, but usually 15-30 minutes)
2. Visit https://yourdomain.com
3. Confirm the secure padlock icon appears in your browser

## TROUBLESHOOTING

### Certificate Not Validating
- Double-check CNAME records match exactly what's shown in ACM
- Verify your DNS changes have propagated with `dig _validation-name.yourdomain.com CNAME`
- ACM validation can take several hours

### Website Not Working on Custom Domain
- Verify DNS records are correct
- Check if CloudFront distribution is deployed (Status: Deployed)
- Test connection with `curl -I https://yourdomain.com`

### HTTPS Issues
- Verify certificate status is "Issued" in ACM
- Check CloudFront distribution is using the correct certificate
- Ensure browser cache is cleared when testing

## SECURITY BEST PRACTICES

1. **Keep AWS CLI credentials secure**
2. **Use least privilege IAM roles**
3. **Enable CloudTrail for auditing**
4. **Regularly rotate access keys**