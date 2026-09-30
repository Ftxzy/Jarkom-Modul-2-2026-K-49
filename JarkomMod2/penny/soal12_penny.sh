#!/bin/bash
mkdir -p /var/www/admin
echo "Area rahasia sindikat" > /var/www/admin/index.html

cat > /etc/apache2/sites-available/penny.conf << 'CONF'
<Proxy "balancer://vault">
    BalancerMember http://10.88.3.4
    BalancerMember http://10.88.3.5
    ProxySet lbmethod=byrequests
</Proxy>

<VirtualHost *:80>
    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass /admin !
    Alias /admin /var/www/admin
    <Directory /var/www/admin>
        AuthType Basic
        AuthName "Area Rahasia"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>

    ProxyPass / balancer://vault/
    ProxyPassReverse / balancer://vault/
</VirtualHost>
CONF

apachectl -t && service apache2 restart
