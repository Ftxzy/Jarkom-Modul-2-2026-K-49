#!/bin/bash
a2enmod headers
sed -i 's|RequestHeader set X-Real-IP .*|RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}|' /etc/apache2/sites-available/penny.conf
sed -i 's|RequestHeader set X-Forwarded-For .*|RequestHeader set X-Forwarded-For expr=%{REMOTE_ADDR}|' /etc/apache2/sites-available/penny.conf
apachectl -t && service apache2 restart
