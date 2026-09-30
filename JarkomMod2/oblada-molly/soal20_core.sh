#!/bin/bash
# Soal 20 (project close/reopen case) - rebuild-at-boot for core (oblada, molly).
# Called in the background by /root/init.sh at every node start. Safe to run any time:
# installs only MISSING packages, rewrites only config that DIFFERS, starts services that are DOWN.
# Log: /root/boot.log
exec 9>/run/soal20.lock; flock -n 9 || exit 0
export DEBIAN_FRONTEND=noninteractive
CHANGED=0
say(){ echo "[$(date +%T)] soal20 core (oblada, molly): $*"; }
put(){ mkdir -p "$(dirname "$1")"; cat > /tmp/.soal20.$$; if ! cmp -s /tmp/.soal20.$$ "$1"; then cp /tmp/.soal20.$$ "$1"; CHANGED=1; say "wrote $1"; fi; rm -f /tmp/.soal20.$$; }
putnew(){ if [ -s "$1" ]; then cat >/dev/null; else put "$1"; fi; }
need(){ MISSING=""; for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || MISSING="$MISSING $p"; done
  [ -z "$MISSING" ] && return 0; say "installing:$MISSING"
  for i in $(seq 1 40); do apt-get update -qq >/dev/null 2>&1 && apt-get install -y $MISSING >/dev/null 2>&1 && { CHANGED=1; return 0; }; say "apt not ready, retry $i"; sleep 15; done
  say "PACKAGE INSTALL FAILED"; return 1; }
ensure(){ if [ "$CHANGED" = 1 ]; then service "$1" restart 9>&-; else service "$1" status >/dev/null 2>&1 || service "$1" start 9>&-; fi; }  # 9>&- so daemons do not inherit (and hold) the lock
say "start"
need nginx php8.4-fpm || exit 1
mkdir -p /var/www/core
put /var/www/core/index.php <<'SOAL20_EOF'
<?php
echo "<h1>Beranda</h1>";
echo "<p>Dilayani oleh: " . gethostname() . "</p>";
echo "<a href='/profil'>Lihat profil</a>";
SOAL20_EOF
put /var/www/core/profil.php <<'SOAL20_EOF'
<?php
echo "<h1>Profil</h1>";
echo "<p>Kelompok K-49</p>";
echo "<p>Dilayani oleh: " . gethostname() . "</p>";
SOAL20_EOF
put /etc/nginx/sites-available/core <<'SOAL20_EOF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/core;
    index index.php;

    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
SOAL20_EOF
put /etc/nginx/conf.d/realip.conf <<'SOAL20_EOF'
set_real_ip_from 10.88.4.2;
real_ip_header X-Real-IP;
SOAL20_EOF
rm -f /etc/nginx/sites-enabled/default; ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core
nginx -t >/dev/null 2>&1 || { say "nginx config test FAILED"; exit 1; }
ensure php8.4-fpm; ensure nginx
say "done"
