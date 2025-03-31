# CIT 270 Project - Coffee Shop Website with HTTPS

## Project Overview
This project implements a Coffee Shop website deployed on AWS Elastic Beanstalk with HTTPS support. It fulfills all the requirements specified for the CIT 270 course.

## Deployment Details

### Web Application
- **URL**: http://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com
- **HTTPS URL**: https://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com
- **Elastic Beanstalk Application**: coffee-shop
- **Elastic Beanstalk Environment**: coffee-shop-env

### Infrastructure
- **Web Server**: Apache (not Nginx) as specified in requirements
- **Instance Type**: t3.small burstable instance
- **IMDSv1 Status**: Enabled as required
- **Deployment Platform**: AWS Elastic Beanstalk
- **SSL/TLS**: Self-signed certificate with HTTP to HTTPS redirection

## Requirements Fulfillment

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| Deploy to Elastic Beanstalk | Environment: coffee-shop-env | ✅ |
| HTTPS support | Self-signed SSL certificate with redirect | ✅ |
| Apache (not Nginx) | Configured in EB environment | ✅ |
| IMDSv1 enabled | Set DisableIMDSv1 to false | ✅ |
| t3.small instance | Configured in EB environment | ✅ |

## Verification

### AWS Console
1. Log in to AWS Console: https://console.aws.amazon.com/
2. Navigate to Elastic Beanstalk service
3. Select the "coffee-shop" application
4. Select the "coffee-shop-env" environment
5. Review the Configuration settings:
   - Under "Capacity" - Instance type: t3.small
   - Under "Software" - Proxy server: Apache
   - Under "Security" - IAM instance profile: LabInstanceProfile

### Web Browser
1. Visit the HTTP URL (will redirect to HTTPS):
   http://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com
2. Confirm the site loads over HTTPS:
   https://coffee-shop-env.eba-h9d9kuyw.us-east-1.elasticbeanstalk.com
3. View the certificate details to confirm HTTPS implementation

## Implementation Notes

### HTTPS Setup
The HTTPS implementation uses a self-signed SSL certificate created during deployment. While this certificate generates a browser warning (expected for self-signed certificates), it demonstrates the proper implementation of SSL/TLS for the project requirements.

Key files:
- Certificate: `/etc/pki/tls/certs/localhost.crt`
- Private Key: `/etc/pki/tls/private/localhost.key`
- Apache SSL Config: `/etc/httpd/conf.d/ssl.conf`

### Elastic Beanstalk Configuration
The deployment uses `.ebextensions` configuration files to set up:
- Apache web server
- HTTPS with self-signed certificate
- t3.small instance type
- IMDSv1 enabled
- HTTP to HTTPS redirection

## Screenshots
[Include screenshots showing:
1. The website loaded over HTTPS
2. Certificate details
3. AWS Console configuration showing the requirements are met]

## Conclusion
This project successfully implements all the requirements for the CIT 270 assignment, including the deployment of a Coffee Shop website to Elastic Beanstalk with HTTPS support using Apache, t3.small instances, and IMDSv1 enabled.

---

Completed: $(date)
