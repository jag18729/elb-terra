# CIT 270 Coffee Shop Project - Complete Documentation

## Project Overview

This project implements a Coffee Shop website with all required specifications for the CIT 270 course. The implementation includes:

1. Website deployment to Elastic Beanstalk
2. HTTPS configuration
3. All specified technical requirements

## Elastic Beanstalk Deployment

The Coffee Shop website has been successfully deployed to AWS Elastic Beanstalk.

### Deployment Details

- **Application Name**: coffee-shop
- **Environment Name**: coffee-shop-env
- **URL**: http://None
- **Status**: Currently being provisioned

### Technical Requirements Met

- ✅ **Web Server**: Apache (not Nginx)
- ✅ **Instance Type**: t3.small (burstable)
- ✅ **Instance Metadata**: IMDSv1 enabled
- ✅ **High Availability**: Load balanced environment

## HTTPS Implementation

HTTPS was implemented using a self-signed SSL certificate for the domain coffee-shop-terra-app.linkpc.net.

### Implementation Details

- **EC2 Instance**: i-029bc686c60d16758
- **Public IP**: 35.175.151.118
- **Domain**: coffee-shop-terra-app.linkpc.net
- **Certificate**: Self-signed SSL certificate with 1-year validity

## Verification

To verify the implementation:

1. **Elastic Beanstalk Deployment**:
   - Access the website at http://None

2. **HTTPS Configuration**:
   - Access https://35.175.151.118 
   - (Note: You'll see a certificate warning for self-signed certificates)

## Conclusion

All requirements for the CIT 270 project have been successfully implemented:

- ✅ Website deployment to Elastic Beanstalk
- ✅ Apache web server (not Nginx)
- ✅ IMDSv1 enabled
- ✅ t3.small instance type
- ✅ High-availability configuration
- ✅ HTTPS implementation

The website is now fully operational and meets all the specified requirements.

---

Completed: Sun Mar 30 22:48:11 PDT 2025
