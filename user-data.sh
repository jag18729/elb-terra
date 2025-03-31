#\!/bin/bash
# Update system packages
yum update -y

# Install Apache web server
yum install -y httpd mod_ssl

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
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=US/ST=California/L=Northridge/O=CSUN/OU=CIT270/CN=coffee-shop-server"

# Configure Apache for HTTPS
cat > /etc/httpd/conf.d/ssl.conf << 'SSLCONF'
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
cat > /etc/httpd/conf.d/redirect.conf << 'REDIRECTCONF'
<VirtualHost *:80>
    ServerName localhost
    Redirect permanent / https://localhost/
</VirtualHost>
REDIRECTCONF

# Restart Apache to apply changes
systemctl restart httpd

# Create a success file
echo "Setup completed successfully" > /var/www/html/setup-success.html
