#!/bin/bash
# Soal 20 (project close/reopen case) - rebuild-at-boot for tedd.
# Called in the background by /root/init.sh at every node start. Safe to run any time:
# installs only MISSING packages, rewrites only config that DIFFERS, starts services that are DOWN.
# Log: /root/boot.log
exec 9>/run/soal20.lock; flock -n 9 || exit 0
export DEBIAN_FRONTEND=noninteractive
CHANGED=0
say(){ echo "[$(date +%T)] soal20 tedd: $*"; }
put(){ mkdir -p "$(dirname "$1")"; cat > /tmp/.soal20.$$; if ! cmp -s /tmp/.soal20.$$ "$1"; then cp /tmp/.soal20.$$ "$1"; CHANGED=1; say "wrote $1"; fi; rm -f /tmp/.soal20.$$; }
putnew(){ if [ -s "$1" ]; then cat >/dev/null; else put "$1"; fi; }
need(){ MISSING=""; for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || MISSING="$MISSING $p"; done
  [ -z "$MISSING" ] && return 0; say "installing:$MISSING"
  for i in $(seq 1 40); do apt-get update -qq >/dev/null 2>&1 && apt-get install -y $MISSING >/dev/null 2>&1 && { CHANGED=1; return 0; }; say "apt not ready, retry $i"; sleep 15; done
  say "PACKAGE INSTALL FAILED"; return 1; }
ensure(){ if [ "$CHANGED" = 1 ]; then service "$1" restart 9>&-; else service "$1" status >/dev/null 2>&1 || service "$1" start 9>&-; fi; }  # 9>&- so daemons do not inherit (and hold) the lock
say "start"
need bind9 || exit 1
[ -e /etc/init.d/bind9 ] || ln -s /etc/init.d/named /etc/init.d/bind9
if ! grep -q 'zone "K-49.com"' /etc/bind/named.conf.local; then
  put /etc/bind/named.conf.local <<'SOAL20_EOF'
zone "K-49.com" {
    type slave;
    masters { 10.88.3.2; };
    file "/var/cache/bind/db.K-49.com";
};

zone "88.10.in-addr.arpa" {
    type slave;
    masters { 10.88.3.2; };
    file "/var/cache/bind/db.88.10.in-addr.arpa";
};
SOAL20_EOF
fi
# same options as prab (forwarders to 192.168.122.1 + allow-query any) so tedd also answers outside names
put /etc/bind/named.conf.options <<'SOAL20_EOF'
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    dnssec-validation no;
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
SOAL20_EOF
ensure bind9
# slave: pull both zones from prab (SOA retry is a day, do not wait for it)
for i in $(seq 1 30); do
  [ -s /var/cache/bind/db.K-49.com ] && [ -s /var/cache/bind/db.88.10.in-addr.arpa ] && break
  rndc retransfer K-49.com >/dev/null 2>&1; rndc retransfer 88.10.in-addr.arpa >/dev/null 2>&1; sleep 10
done
say "done"
