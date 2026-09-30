#!/bin/bash
# Soal 20 (project close/reopen case) - rebuild-at-boot for vault (obladi, desmond).
# Called in the background by /root/init.sh at every node start. Safe to run any time:
# installs only MISSING packages, rewrites only config that DIFFERS, starts services that are DOWN.
# Log: /root/boot.log
exec 9>/run/soal20.lock; flock -n 9 || exit 0
export DEBIAN_FRONTEND=noninteractive
CHANGED=0
say(){ echo "[$(date +%T)] soal20 vault (obladi, desmond): $*"; }
put(){ mkdir -p "$(dirname "$1")"; cat > /tmp/.soal20.$$; if ! cmp -s /tmp/.soal20.$$ "$1"; then cp /tmp/.soal20.$$ "$1"; CHANGED=1; say "wrote $1"; fi; rm -f /tmp/.soal20.$$; }
putnew(){ if [ -s "$1" ]; then cat >/dev/null; else put "$1"; fi; }
need(){ MISSING=""; for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || MISSING="$MISSING $p"; done
  [ -z "$MISSING" ] && return 0; say "installing:$MISSING"
  for i in $(seq 1 40); do apt-get update -qq >/dev/null 2>&1 && apt-get install -y $MISSING >/dev/null 2>&1 && { CHANGED=1; return 0; }; say "apt not ready, retry $i"; sleep 15; done
  say "PACKAGE INSTALL FAILED"; return 1; }
ensure(){ if [ "$CHANGED" = 1 ]; then service "$1" restart 9>&-; else service "$1" status >/dev/null 2>&1 || service "$1" start 9>&-; fi; }  # 9>&- so daemons do not inherit (and hold) the lock
say "start"
need apache2 || exit 1
mkdir -p /var/www/html/arsip
echo "file contoh 1 dari $(hostname)" > /var/www/html/arsip/contoh1.txt
echo "file contoh 2 dari $(hostname)" > /var/www/html/arsip/contoh2.txt
put /etc/apache2/conf-available/arsip.conf <<'SOAL20_EOF'
<Directory /var/www/html/arsip>
    Options +Indexes
    Require all granted
</Directory>
SOAL20_EOF
put /etc/apache2/conf-available/remoteip.conf <<'SOAL20_EOF'
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.88.5.2
SOAL20_EOF
a2enmod remoteip >/dev/null 2>&1; a2enconf arsip remoteip >/dev/null 2>&1
ensure apache2
say "done"
