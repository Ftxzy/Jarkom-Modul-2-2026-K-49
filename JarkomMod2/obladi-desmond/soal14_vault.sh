#!/bin/bash
a2enmod remoteip

cat > /etc/apache2/conf-available/remoteip.conf <<'CONF'
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.88.5.2
CONF

a2enconf remoteip
apachectl -t && service apache2 restart
