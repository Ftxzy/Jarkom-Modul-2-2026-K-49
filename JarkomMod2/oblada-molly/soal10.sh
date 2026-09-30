#!/bin/bash
apt-get update
apt-get install -y nginx php8.4-fpm

mkdir -p /var/www/core

cat > /var/www/core/index.php << 'PHP'
<?php
echo "<h1>Beranda</h1>";
echo "<p>Dilayani oleh: " . gethostname() . "</p>";
echo "<a href='/profil'>Lihat profil</a>";
PHP

cat > /var/www/core/profil.php << 'PHP'
<?php
echo "<h1>Profil</h1>";
echo "<p>Kelompok K-49</p>";
echo "<p>Dilayani oleh: " . gethostname() . "</p>";
PHP

cat > /etc/nginx/sites-available/core << 'CONF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/core;
    index index.php;

    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
CONF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core

service php8.4-fpm restart
nginx -t && service nginx restart
