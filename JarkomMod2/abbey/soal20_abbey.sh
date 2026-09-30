#!/bin/bash
# Soal 20 (project close/reopen case) - rebuild-at-boot for abbey.
# Called in the background by /root/init.sh at every node start. Safe to run any time:
# installs only MISSING packages, rewrites only config that DIFFERS, starts services that are DOWN.
# Log: /root/boot.log
exec 9>/run/soal20.lock; flock -n 9 || exit 0
export DEBIAN_FRONTEND=noninteractive
CHANGED=0
say(){ echo "[$(date +%T)] soal20 abbey: $*"; }
put(){ mkdir -p "$(dirname "$1")"; cat > /tmp/.soal20.$$; if ! cmp -s /tmp/.soal20.$$ "$1"; then cp /tmp/.soal20.$$ "$1"; CHANGED=1; say "wrote $1"; fi; rm -f /tmp/.soal20.$$; }
putnew(){ if [ -s "$1" ]; then cat >/dev/null; else put "$1"; fi; }
need(){ MISSING=""; for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || MISSING="$MISSING $p"; done
  [ -z "$MISSING" ] && return 0; say "installing:$MISSING"
  for i in $(seq 1 40); do apt-get update -qq >/dev/null 2>&1 && apt-get install -y $MISSING >/dev/null 2>&1 && { CHANGED=1; return 0; }; say "apt not ready, retry $i"; sleep 15; done
  say "PACKAGE INSTALL FAILED"; return 1; }
ensure(){ if [ "$CHANGED" = 1 ]; then service "$1" restart 9>&-; else service "$1" status >/dev/null 2>&1 || service "$1" start 9>&-; fi; }  # 9>&- so daemons do not inherit (and hold) the lock
say "start"
need nginx || exit 1
mkdir -p /var/www/orion
put /var/www/orion/index.html <<'SOAL20_EOF'
<h1>Orion</h1><p>Dilayani oleh: abbey (statis)</p>
SOAL20_EOF
put /etc/nginx/sites-available/abbey <<'SOAL20_EOF'
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

    # bare /orion (no slash) -> /orion/  (Soal 15)
    location = /orion {
        return 301 /orion/;
    }

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    location / {
        proxy_pass http://core;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
SOAL20_EOF
rm -f /etc/nginx/sites-enabled/default; ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
nginx -t >/dev/null 2>&1 || { say "nginx config test FAILED"; exit 1; }
ensure nginx
say "done"
