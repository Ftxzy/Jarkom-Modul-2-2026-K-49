#!/bin/bash
apt update
apt install -y php8.4-fpm

a2enmod proxy_fcgi setenvif

mkdir -p /var/www/eternal
cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "<h1>Eternal</h1><p>Dilayani oleh: penny (PHP " . phpversion() . ")</p>";
PHP

# sisipkan Alias + exclusion proxy tepat setelah baris /admin
sed -i '/ProxyPass \/admin !/a\
    ProxyPass /eternal !\
    Alias /eternal /var/www/eternal\
    <Directory /var/www/eternal>\
        Require all granted\
        DirectoryIndex index.php\
        <FilesMatch "\\.php$">\
            SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost"\
        </FilesMatch>\
    </Directory>' /etc/apache2/sites-available/penny.conf

service php8.4-fpm restart
apachectl -t && service apache2 restart
