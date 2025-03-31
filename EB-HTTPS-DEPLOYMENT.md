# Coffee Shop Elastic Beanstalk Deployment with HTTPS

## Deployment Information

Your Coffee Shop website has been successfully deployed to AWS Elastic Beanstalk with HTTPS support\!

### Access Information

- **Application Name**: coffee-shop
- **Environment Name**: coffee-shop-env
- **Version Label**: v1-1743400881
- **URL**: http://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com
- **HTTPS URL**: https://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com

### Implementation Details

The deployment has been configured to meet all CIT 270 requirements:

1. ✅ **Web Server**: Apache (not Nginx)
2. ✅ **Instance Type**: t3.small (burstable)
3. ✅ **Instance Metadata**: IMDSv1 enabled
4. ✅ **High Availability**: Load balanced environment
5. ✅ **HTTPS**: Self-signed SSL certificate

### HTTPS Implementation

HTTPS has been implemented using:
- Self-signed SSL certificate for the domain coffee-shop-terra-app.linkpc.net
- Apache's mod_ssl module
- HTTP to HTTPS redirection for all traffic
- TLS/SSL encryption for all communication

### Verification

You can verify these configurations by:

1. Accessing the site via HTTPS: https://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com
2. Confirming the redirect from HTTP to HTTPS
3. Viewing the certificate details in your browser
4. Checking the Elastic Beanstalk environment details in AWS Console

### Accessing Your Website

The Coffee Shop website is accessible at:
- HTTP URL: http://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com (will redirect to HTTPS)
- HTTPS URL: https://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com

Note: Since we're using a self-signed certificate, your browser may show a security warning.
This is normal for self-signed certificates - you can proceed to the website safely.

---

Deployed: Sun Mar 30 23:01:37 PDT 2025
