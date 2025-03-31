#\!/bin/bash
# Update system packages
yum update -y

# Install Apache web server and additional tools
yum install -y httpd mod_ssl wget

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Install AWS CLI
yum install -y awscli

# Create web directory
mkdir -p /var/www/html

# Download website files from S3
aws s3 sync s3://coffee-shop-website-garcia-rafael-2274088/ /var/www/html/

# Set correct permissions
chmod -R 755 /var/www/html/

# Configure HTTPS with a self-signed certificate
DOMAIN="coffee-shop-terra-app.linkpc.net"
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=US/ST=California/L=Northridge/O=CSUN/OU=CIT270/CN=${DOMAIN}"

# Configure Apache for HTTPS with the domain
cat > /etc/httpd/conf.d/ssl.conf << SSLCONF
<VirtualHost *:443>
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Add CORS headers
    <IfModule mod_headers.c>
        Header set Access-Control-Allow-Origin "*"
        Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
        Header set Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept"
    </IfModule>
</VirtualHost>
SSLCONF

# Configure HTTP with the domain
cat > /etc/httpd/conf.d/vhost.conf << VHOSTCONF
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Add CORS headers
    <IfModule mod_headers.c>
        Header set Access-Control-Allow-Origin "*"
        Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
        Header set Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept"
    </IfModule>
</VirtualHost>
VHOSTCONF

# Add hostname to hosts file for local resolution
echo "127.0.0.1 ${DOMAIN} www.${DOMAIN}" >> /etc/hosts

# Install certbot for Let's Encrypt
amazon-linux-extras install epel -y
yum install -y certbot python3-certbot-apache

# Install and configure local hostname resolution
echo "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) ${DOMAIN} www.${DOMAIN}" >> /etc/hosts

# Restart Apache to apply changes
systemctl restart httpd

# Create a success file
echo "Setup completed successfully for ${DOMAIN}" > /var/www/html/setup-success.html
