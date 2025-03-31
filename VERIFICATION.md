# CIT 270 Project Requirements Verification

## Project URL
http://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com

## HTTP to HTTPS
After deployment completes, the site will be accessible via HTTPS and will automatically redirect HTTP traffic to HTTPS:
https://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com

## Requirements Implemented
1. ✅ **Elastic Beanstalk Deployment**: Application deployed to AWS Elastic Beanstalk
2. ✅ **Apache Web Server**: Using Apache (not Nginx) as specified
3. ✅ **IMDSv1 Enabled**: Instance Metadata Service v1 enabled as required
4. ✅ **T3.small Instance**: Using t3.small burstable instance type
5. ✅ **HTTPS Implementation**: Self-signed SSL certificate with HTTP to HTTPS redirection

## Verification Steps

### In AWS Console
1. Log in to AWS Console
2. Navigate to Elastic Beanstalk
3. Select the "coffee-shop" application
4. Select the "coffee-shop-env" environment
5. View "Configuration" to verify:
   - Apache web server (under "Software")
   - t3.small instance type (under "Capacity")
   - IMDSv1 enabled (under "Security")

### In Web Browser
1. Visit the HTTP URL (will redirect to HTTPS)
2. Confirm the site loads over HTTPS
3. Verify the lock icon indicating secure connection
4. View the certificate details to confirm HTTPS implementation

## Troubleshooting Note
If you experience any issues with the deployment:
1. Check the environment health in AWS Console
2. Review the environment events and logs
3. Ensure proper permissions are configured
4. If needed, try accessing the S3 static website version as a fallback

## Screenshots
Add screenshots here showing:
1. Site loading with HTTPS in browser
2. Certificate details
3. AWS Console configuration showing requirements met

---

Created: $(date)
