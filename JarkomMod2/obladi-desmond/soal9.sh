#!/bin/bash
apt-get update
apt-get install -y apache2

mkdir -p /var/www/html/arsip
echo "file contoh 1 dari $(hostname)" > /var/www/html/arsip/contoh1.txt
echo "file contoh 2 dari $(hostname)" > /var/www/html/arsip/contoh2.txt

cat > /etc/apache2/conf-available/arsip.conf << 'CONF'
<Directory /var/www/html/arsip>
    Options +Indexes
    Require all granted
</Directory>
CONF

a2enconf arsip
service apache2 restart
