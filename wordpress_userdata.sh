#!/bin/bash
set -ex
sudo apt update -y
sudo apt install apache2 php php-mysql mysql-client wget unzip -y
sudo systemctl enable apache2
sudo systemctl start apache2

# Clean default page
sudo rm -f /var/www/html/index.html

cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo cp -r wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# Permissions
sudo chown -R www-data:www-data /var/www
sudo find /var/www -type d -exec chmod 2755 {} \;
sudo find /var/www -type f -exec chmod 0644 {} \;

# Setup wp-config
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/${db_name}/" wp-config.php
sudo sed -i "s/username_here/${db_username}/" wp-config.php
sudo sed -i "s/password_here/${db_password}/" wp-config.php
sudo sed -i "s/localhost/${db_host}/" wp-config.php
systemctl restart httpd

# Validate DB_NAME replacement
if grep -q "define( 'DB_NAME', '${db_name}' );" /var/www/html/wp-config.php; then
  echo "✅ DB_NAME was set correctly."
else
  echo "❌ Failed to set DB_NAME. Exiting..."
  exit 1
fi

if grep -q "define( 'DB_NAME', '${db_name}' );" /var/www/html/wp-config.php; then
  echo "✅ DB_NAME was set correctly."
else
  echo "❌ Failed to set DB_NAME. Exiting..."
  exit 1
fi

