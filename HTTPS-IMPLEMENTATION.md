# HTTPS Implementation Documentation

## Summary
This document outlines the HTTPS implementation for the Coffee Shop website, designed to fulfill the security requirements of the CIT 270 project.

## Implementation Details

### Architecture
- **Primary Website:** [S3 Static Website](http://coffee-shop-website-garcia-rafael-2274088.s3-website-us-east-1.amazonaws.com/)
- **HTTPS Website:** [EC2 Secure Site](https://3.86.185.230)
- **Domain Configuration:** coffee-shop-terra-app.linkpc.net
- **Implementation Method:** EC2 + Apache + Self-signed SSL Certificate

### Components
1. **S3 Bucket:**
   - Name: coffee-shop-website-garcia-rafael-2274088
   - Configuration: Static website hosting enabled
   - CORS: Configured for cross-origin requests

2. **EC2 Instance:**
   - Instance ID: i-0622d7e6b109ef2ee
   - Type: t2.micro
   - AMI: Amazon Linux 2
   - Public IP: 3.86.185.230

3. **Security:**
   - Security Group: Ports 22 (SSH), 80 (HTTP), and 443 (HTTPS) open
   - Self-signed SSL Certificate: 1-year validity
   - HTTP to HTTPS redirection configured

4. **Web Server:**
   - Apache 2.4 with mod_ssl
   - Virtual hosts configured for both HTTP and HTTPS
   - CORS headers enabled for API compatibility

## HTTPS Configuration Details

### SSL Certificate
A self-signed SSL certificate was generated for the domain with the following characteristics:
- **Subject:** coffee-shop-terra-app.linkpc.net
- **Organization:** CSUN
- **Organizational Unit:** CIT270
- **Validity:** 365 days
- **Key Strength:** 2048-bit RSA

### Apache Configuration
Apache is configured with proper SSL settings including:
- SSLEngine enabled
- Modern cipher suites for security
- TLS 1.2 protocol support
- HTTP to HTTPS redirection
- Proper directory permissions

### Testing Verification
- HTTP requests to the server are automatically redirected to HTTPS
- HTTPS connection is established with the self-signed certificate
- All website content is served securely over encrypted connection
- CORS headers allow cross-origin resource sharing

## Demonstration
To demonstrate the HTTPS implementation:

1. **View Success Page:**
   - [HTTPS Success Page](http://coffee-shop-website-garcia-rafael-2274088.s3-website-us-east-1.amazonaws.com/https-success.html)

2. **Access Secure Website:**
   - Direct HTTPS access: https://3.86.185.230
   - Domain access (requires hosts file modification): https://coffee-shop-terra-app.linkpc.net

3. **Certificate Verification:**
   - View the SSL certificate details in your browser
   - Verify the self-signed certificate was issued to coffee-shop-terra-app.linkpc.net

## Security Considerations
- In a production environment, this self-signed certificate would be replaced with a trusted certificate from Let's Encrypt or another certificate authority
- The current implementation demonstrates the technical setup of HTTPS but displays a certificate warning in browsers (expected behavior for self-signed certificates)
- All encryption and HTTP-to-HTTPS redirection functionality is properly implemented

## Conclusion
The implementation satisfies the HTTPS requirements for the CIT 270 project. The website is accessible over a secure connection with proper SSL/TLS encryption, ensuring that all communication between clients and the server is encrypted.

---

Created: $(date +"%B %d, %Y")
