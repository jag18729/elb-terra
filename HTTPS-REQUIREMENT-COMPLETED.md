# HTTPS Implementation Documentation

## Overview
This document demonstrates that the HTTPS requirement for the CIT 270 project has been successfully completed. The implementation provides secure HTTPS access to the Coffee Shop website.

## Implementation Details

### Server Information
- **EC2 Instance ID:** i-029bc686c60d16758
- **Public IP Address:** 35.175.151.118
- **Domain Name:** coffee-shop-terra-app.linkpc.net
- **Web Server:** Apache with mod_ssl

### HTTPS Configuration
- Self-signed SSL certificate for the domain coffee-shop-terra-app.linkpc.net
- TLS/SSL encryption enabled on port 443
- HTTP to HTTPS redirection implemented
- Security groups properly configured to allow HTTPS traffic

### Security Features
- **Encryption:** All traffic is encrypted using TLS
- **Certificate:** Self-signed certificate with 1-year validity
- **HTTP Redirection:** Automatic redirection from HTTP to HTTPS
- **Protected Content:** All website content is served securely

## Verification Method

To verify the HTTPS implementation:

1. **Direct IP Access:**
   - Visit https://35.175.151.118
   - You will see a certificate warning (expected for self-signed certificates)
   - Proceed past the warning to access the secure site

2. **Domain Access:**
   - Add this entry to your hosts file:
     ```
     35.175.151.118 coffee-shop-terra-app.linkpc.net www.coffee-shop-terra-app.linkpc.net
     ```
   - Visit https://coffee-shop-terra-app.linkpc.net
   - Proceed past the certificate warning

3. **Certificate Verification:**
   - Click the lock icon in your browser address bar
   - View certificate details to confirm it was issued to coffee-shop-terra-app.linkpc.net

## Screenshots

[Include screenshots showing:
1. The website loading with HTTPS
2. Certificate information showing it's issued for coffee-shop-terra-app.linkpc.net
3. Lock icon in the browser address bar]

## Technical Implementation

The HTTPS implementation was achieved using:
1. Apache web server with mod_ssl
2. OpenSSL for certificate generation
3. Configuration directives for proper SSL/TLS settings
4. HTTP to HTTPS redirection via mod_rewrite

## Conclusion

The HTTPS requirement for CIT 270 has been successfully implemented. The website is accessible securely over HTTPS with proper encryption and certificate configuration for the specified domain coffee-shop-terra-app.linkpc.net.

---

Created: $(date +"%B %d, %Y")
