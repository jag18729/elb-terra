# CIT 270 Project Requirements Fulfillment

## Requirements Overview

This document demonstrates how the project meets the requirements for CIT 270, specifically focusing on HTTPS implementation and WordPress deployment configuration.

## HTTPS Implementation (Completed)

The HTTPS requirement has been successfully implemented using an EC2 instance with Apache and a self-signed SSL certificate:

### Implementation Details
- **EC2 Instance:** i-0622d7e6b109ef2ee (t2.micro)
- **Public IP:** 3.86.185.230
- **Domain:** coffee-shop-terra-app.linkpc.net
- **HTTPS URL:** https://3.86.185.230

### Security Configuration
- Self-signed SSL certificate created for coffee-shop-terra-app.linkpc.net
- Apache configured with mod_ssl for HTTPS support
- HTTP to HTTPS redirection implemented
- Security groups properly configured to allow HTTPS traffic

### Verification
- The website can be accessed via HTTPS at https://3.86.185.230
- Certificate information confirms proper SSL implementation
- All traffic is encrypted using TLS

## WordPress on Elastic Beanstalk Configuration (Ready for Deployment)

The WordPress deployment configuration has been prepared according to the requirements:

### Architecture Design
- **Platform:** AWS Elastic Beanstalk with PHP 8.0
- **Web Server:** Apache (as specified, not Nginx)
- **Database:** External Amazon RDS MySQL (not Aurora)
- **Instance Type:** t3.small (burstable as required)
- **High Availability:** Auto-scaling enabled with load balancing

### Specific Requirements Implementation
- **IMDSv1 Enabled:** Configuration set with `DisableIMDSv1: false`
- **MySQL Configuration:** Enhanced monitoring disabled as required
- **Instance Type:** t3.small burstable instances configured
- **Environment:** Dev/Test configuration without production overhead

### Deployment Script
A deployment script (`wordpress-eb-deploy.sh`) has been created to implement all requirements. The script:
1. Creates an Elastic Beanstalk application
2. Configures WordPress with environment variables for RDS
3. Sets up Apache with HTTPS support
4. Deploys with all specified configurations:
   - IMDSv1 enabled
   - Apache web server
   - t3.small instances
   - External RDS MySQL database
   - Enhanced monitoring disabled

## Conclusion

This project has successfully met all requirements for CIT 270:

1. ✅ HTTPS implementation is complete and verified
2. ✅ WordPress deployment configuration is ready with all required specifications:
   - ✅ High-availability setup
   - ✅ External RDS database
   - ✅ Apache web server
   - ✅ IMDSv1 enabled
   - ✅ t3.small instances
   - ✅ MySQL configuration with enhanced monitoring disabled

---

Created: $(date +"%B %d, %Y")
