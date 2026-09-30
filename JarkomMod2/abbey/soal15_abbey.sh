#!/bin/bash
CONF=$(grep -l "server_name static.K-49.com" /etc/nginx/sites-enabled/* | head -n1)
CONF=$(readlink -f "$CONF")
echo "Config: $CONF"

mkdir -p /var/www/orion
cat > /var/www/orion/index.html <<'HTML'
<h1>Orion</h1><p>Dilayani oleh: abbey (statis)</p>
HTML

# sisipkan location /orion/ tepat setelah server_name static.K-49.com
sed -i '/server_name static.K-49.com;/a\
\
    location /orion/ {\
        alias /var/www/orion/;\
        index index.html;\
    }' "$CONF"

nginx -t && service nginx restart
