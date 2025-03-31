#\!/bin/bash

# Update system packages
sudo yum update -y

# Install Apache web server
sudo yum install -y httpd mod_ssl

# Install tools for HTTPS setup
sudo yum install -y certbot python3-certbot-apache

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Install AWS CLI
sudo yum install -y awscli

# Download website files from S3
aws s3 sync s3://coffee-shop-website-garcia-rafael-2274088/ /var/www/html/

# Set correct permissions
sudo chmod -R 755 /var/www/html/

# Configure HTTPS with a self-signed certificate (for testing)
sudo mkdir -p /etc/ssl/private
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=US/ST=California/L=Northridge/O=CSUN/OU=CIT270/CN=coffee-shop-server"

# Configure Apache for HTTPS
sudo tee /etc/httpd/conf.d/ssl.conf > /dev/null << 'SSLCONF'
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
SSLCONF

# Redirect HTTP to HTTPS
sudo tee /etc/httpd/conf.d/redirect.conf > /dev/null << 'REDIRECTCONF'
<VirtualHost *:80>
    ServerName localhost
    Redirect permanent / https://localhost/
</VirtualHost>
REDIRECTCONF

# Restart Apache to apply changes
sudo systemctl restart httpd

# Display public IP address for easy access
echo "Server setup complete\! Access your website at:"
echo "http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "https://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) (HTTPS with self-signed certificate)"
