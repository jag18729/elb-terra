#\!/bin/bash

echo "=== COFFEE SHOP WEBSITE TROUBLESHOOTING ==="
echo "Running diagnostics..."

# 1. Check if Apache is running
echo -e "\n=== Apache Status ==="
if systemctl is-active httpd > /dev/null; then
    echo "✅ Apache is running"
else
    echo "❌ Apache is NOT running"
    echo "Attempting to start Apache..."
    sudo systemctl start httpd
fi

# 2. Check if SSL module is loaded
echo -e "\n=== SSL Module Status ==="
if apache2ctl -M 2>/dev/null | grep ssl_module > /dev/null; then
    echo "✅ SSL module is loaded"
elif httpd -M 2>/dev/null | grep ssl_module > /dev/null; then
    echo "✅ SSL module is loaded"
else
    echo "❌ SSL module is NOT loaded"
    echo "Installing mod_ssl..."
    sudo yum install -y mod_ssl
fi

# 3. Check if website files exist
echo -e "\n=== Website Files ==="
if [ -f /var/www/html/index.html ]; then
    echo "✅ Website files found"
    echo "Number of files in /var/www/html/: $(find /var/www/html -type f | wc -l)"
else
    echo "❌ Website files NOT found"
    echo "Attempting to download website files from S3..."
    sudo yum install -y awscli
    sudo aws s3 sync s3://coffee-shop-website-garcia-rafael-2274088/ /var/www/html/
    sudo chmod -R 755 /var/www/html/
fi

# 4. Check SSL certificate
echo -e "\n=== SSL Certificate ==="
if [ -f /etc/ssl/certs/apache-selfsigned.crt ] && [ -f /etc/ssl/private/apache-selfsigned.key ]; then
    echo "✅ SSL certificate files found"
    echo "Certificate information:"
    sudo openssl x509 -in /etc/ssl/certs/apache-selfsigned.crt -text -noout | grep -E 'Subject:|Issuer:|Not Before:|Not After :'
else
    echo "❌ SSL certificate files NOT found"
    echo "Creating self-signed certificate..."
    sudo mkdir -p /etc/ssl/private
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/apache-selfsigned.key \
      -out /etc/ssl/certs/apache-selfsigned.crt \
      -subj "/C=US/ST=California/L=Northridge/O=CSUN/OU=CIT270/CN=coffee-shop-terra-app.linkpc.net"
fi

# 5. Check Apache configuration
echo -e "\n=== Apache Configuration ==="
if sudo apachectl configtest 2>&1 | grep "Syntax OK" > /dev/null || sudo httpd -t 2>&1 | grep "Syntax OK" > /dev/null; then
    echo "✅ Apache configuration syntax is OK"
else
    echo "❌ Apache configuration has syntax errors"
    echo "Configuration test output:"
    sudo apachectl configtest 2>&1 || sudo httpd -t 2>&1
    
    echo -e "\nRecreating Apache configuration files..."
    
    # Recreate SSL config
    sudo tee /etc/httpd/conf.d/ssl.conf > /dev/null << 'SSLCONF'
<VirtualHost *:443>
    ServerName coffee-shop-terra-app.linkpc.net
    ServerAlias www.coffee-shop-terra-app.linkpc.net
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

    # Create HTTP vhost
    sudo tee /etc/httpd/conf.d/vhost.conf > /dev/null << 'VHOSTCONF'
<VirtualHost *:80>
    ServerName coffee-shop-terra-app.linkpc.net
    ServerAlias www.coffee-shop-terra-app.linkpc.net
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
fi

# 6. Check for common issues
echo -e "\n=== Common Issues ==="

# Check SELinux
if command -v getenforce > /dev/null; then
    SELINUX=$(getenforce)
    if [ "$SELINUX" = "Enforcing" ]; then
        echo "ℹ️ SELinux is Enforcing - might block web server access"
        echo "Temporarily setting SELinux to permissive mode..."
        sudo setenforce 0
    else
        echo "✅ SELinux is not blocking access ($SELINUX)"
    fi
fi

# Check firewall
if command -v firewall-cmd > /dev/null; then
    if sudo firewall-cmd --state 2>/dev/null | grep "running" > /dev/null; then
        HTTP_ALLOWED=$(sudo firewall-cmd --list-all | grep http)
        HTTPS_ALLOWED=$(sudo firewall-cmd --list-all | grep https)
        if [[ -z "$HTTP_ALLOWED" || -z "$HTTPS_ALLOWED" ]]; then
            echo "ℹ️ Firewall may be blocking HTTP/HTTPS"
            echo "Adding HTTP and HTTPS to firewall..."
            sudo firewall-cmd --permanent --add-service=http
            sudo firewall-cmd --permanent --add-service=https
            sudo firewall-cmd --reload
        else
            echo "✅ Firewall is properly configured for HTTP/HTTPS"
        fi
    else
        echo "✅ Firewall is not running"
    fi
fi

# 7. Restart Apache
echo -e "\n=== Restarting Apache ==="
sudo systemctl restart httpd
if [ $? -eq 0 ]; then
    echo "✅ Apache restarted successfully"
else
    echo "❌ Failed to restart Apache"
    echo "Apache error log:"
    sudo tail -n 20 /var/log/httpd/error_log
fi

# 8. Check connectivity
echo -e "\n=== Connectivity ==="
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP: $PUBLIC_IP"
echo "Domain: coffee-shop-terra-app.linkpc.net"
echo "HTTP URL: http://$PUBLIC_IP"
echo "HTTPS URL: https://$PUBLIC_IP"

echo -e "\n=== TROUBLESHOOTING COMPLETE ==="
echo "Your server should now be properly configured."
echo "Access your website at http://$PUBLIC_IP and https://$PUBLIC_IP"
echo "To directly test domain resolution locally, add this to your hosts file:"
echo "$PUBLIC_IP coffee-shop-terra-app.linkpc.net www.coffee-shop-terra-app.linkpc.net"
