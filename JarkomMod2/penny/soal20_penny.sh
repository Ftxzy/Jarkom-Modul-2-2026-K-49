#!/bin/bash
# Soal 20 (project close/reopen case) - rebuild-at-boot for penny.
# Called in the background by /root/init.sh at every node start. Safe to run any time:
# installs only MISSING packages, rewrites only config that DIFFERS, starts services that are DOWN.
# Log: /root/boot.log
exec 9>/run/soal20.lock; flock -n 9 || exit 0
export DEBIAN_FRONTEND=noninteractive
CHANGED=0
say(){ echo "[$(date +%T)] soal20 penny: $*"; }
put(){ mkdir -p "$(dirname "$1")"; cat > /tmp/.soal20.$$; if ! cmp -s /tmp/.soal20.$$ "$1"; then cp /tmp/.soal20.$$ "$1"; CHANGED=1; say "wrote $1"; fi; rm -f /tmp/.soal20.$$; }
putnew(){ if [ -s "$1" ]; then cat >/dev/null; else put "$1"; fi; }
need(){ MISSING=""; for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || MISSING="$MISSING $p"; done
  [ -z "$MISSING" ] && return 0; say "installing:$MISSING"
  for i in $(seq 1 40); do apt-get update -qq >/dev/null 2>&1 && apt-get install -y $MISSING >/dev/null 2>&1 && { CHANGED=1; return 0; }; say "apt not ready, retry $i"; sleep 15; done
  say "PACKAGE INSTALL FAILED"; return 1; }
ensure(){ if [ "$CHANGED" = 1 ]; then service "$1" restart 9>&-; else service "$1" status >/dev/null 2>&1 || service "$1" start 9>&-; fi; }  # 9>&- so daemons do not inherit (and hold) the lock
say "start"
need apache2 php8.4-fpm || exit 1
mkdir -p /var/www/admin /var/www/eternal
put /var/www/admin/index.html <<'SOAL20_EOF'
Area rahasia sindikat
SOAL20_EOF
put /var/www/eternal/index.php <<'SOAL20_EOF'
<?php
echo "<h1>Eternal</h1><p>Dilayani oleh: penny (PHP " . phpversion() . ")</p>";
SOAL20_EOF
put /etc/apache2/.htpasswd <<'SOAL20_EOF'
prabs:$apr1$1PC3y2wl$drh6EpoaSg2UnWPwhXaKf/
SOAL20_EOF
put /etc/apache2/sites-available/penny.conf <<'SOAL20_EOF'
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
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    ProxyPass /admin !
    ProxyPass /eternal !
    Alias /eternal /var/www/eternal
    <Directory /var/www/eternal>
        Require all granted
        DirectoryIndex index.php
        <FilesMatch "\.php$">
            SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost"
        </FilesMatch>
    </Directory>
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
SOAL20_EOF
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers proxy_fcgi setenvif >/dev/null 2>&1
a2dissite 000-default >/dev/null 2>&1; a2ensite penny >/dev/null 2>&1
apachectl -t >/dev/null 2>&1 || { say "apache config test FAILED"; exit 1; }
ensure php8.4-fpm; ensure apache2
say "done"
