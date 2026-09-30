#!/bin/bash
apt-get update
apt-get install -y apache2

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers
a2dissite 000-default

cat > /etc/apache2/sites-available/penny.conf << 'CONF'
<Proxy "balancer://vault">
    BalancerMember http://10.88.3.4
    BalancerMember http://10.88.3.5
    ProxySet lbmethod=byrequests
</Proxy>

<VirtualHost *:80>
    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vault/
    ProxyPassReverse / balancer://vault/
</VirtualHost>
CONF

a2ensite penny
service apache2 restart
