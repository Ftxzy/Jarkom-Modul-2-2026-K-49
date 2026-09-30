#!/bin/bash
cat > /etc/nginx/conf.d/realip.conf <<'CONF'
set_real_ip_from 10.88.4.2;
real_ip_header X-Real-IP;
CONF

nginx -t && service nginx restart
