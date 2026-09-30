#!/bin/bash
cat > /etc/nginx/sites-available/abbey << 'CONF'
upstream core {
    server 10.88.3.6;
    server 10.88.3.7;
}

# Default: akses via IP atau abbey.K-49.com -> 302 ke static
server {
    listen 80 default_server;
    server_name _;
    return 302 http://static.K-49.com$request_uri;
}

# Kanonik: static.K-49.com
server {
    listen 80;
    server_name static.K-49.com;

    location / {
        proxy_pass http://core;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
CONF

nginx -t && service nginx restart
