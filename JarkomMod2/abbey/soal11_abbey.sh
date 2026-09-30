#!/bin/bash
apt-get update
apt-get install -y nginx

cat > /etc/nginx/sites-available/abbey << 'CONF'
upstream core {
    server 10.88.3.6;
    server 10.88.3.7;
}

server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://core;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
CONF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey

nginx -t && service nginx restart
