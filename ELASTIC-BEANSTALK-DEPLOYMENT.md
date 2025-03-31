# Coffee Shop Elastic Beanstalk Deployment

## Deployment Information

Your Coffee Shop website has been successfully deployed to AWS Elastic Beanstalk\!

### Access Information

- **Application Name**: coffee-shop
- **Environment Name**: coffee-shop-env
- **Version Label**: v1-1743399927
- **URL**: http://None

### Implementation Details

The deployment has been configured to meet all CIT 270 requirements:

1. ✅ **Web Server**: Apache (not Nginx)
2. ✅ **Instance Type**: t3.small (burstable)
3. ✅ **Instance Metadata**: IMDSv1 enabled
4. ✅ **High Availability**: Load balanced environment

### Verification

You can verify these configurations in the AWS Elastic Beanstalk console:

1. Go to the Elastic Beanstalk service in the AWS Console
2. Select the "coffee-shop" application
3. Select the "coffee-shop-env" environment
4. View the Configuration settings to confirm:
   - Apache is the proxy server
   - t3.small is the instance type
   - IMDSv1 is enabled

### Accessing Your Website

The Coffee Shop website is accessible at:
http://None

## Next Steps

If you'd like to add HTTPS to your Elastic Beanstalk deployment, you can:

1. Configure a custom domain
2. Set up an SSL certificate
3. Add appropriate security group rules

For the purposes of CIT 270, the current deployment with all specified requirements is complete.

---

Deployed: Sun Mar 30 22:45:45 PDT 2025
