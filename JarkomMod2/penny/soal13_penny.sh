#!/bin/bash
cat > /etc/apache2/sites-available/penny.conf << 'CONF'
<Proxy "balancer://vault">
    BalancerMember http://10.88.3.4
    BalancerMember http://10.88.3.5
    ProxySet lbmethod=byrequests
</Proxy>

# Default (harus paling atas): akses via IP atau penny.K-49.com -> 301 ke www
<VirtualHost *:80>
    ServerName penny.K-49.com
    Redirect permanent / http://www.K-49.com/
</VirtualHost>

# Kanonik: www.K-49.com
<VirtualHost *:80>
    ServerName www.K-49.com
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
