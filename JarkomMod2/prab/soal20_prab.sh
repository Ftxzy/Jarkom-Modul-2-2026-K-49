#!/bin/bash
# Soal 20 (project close/reopen case) - rebuild-at-boot for prab.
# Called in the background by /root/init.sh at every node start. Safe to run any time:
# installs only MISSING packages, rewrites only config that DIFFERS, starts services that are DOWN.
# Log: /root/boot.log
exec 9>/run/soal20.lock; flock -n 9 || exit 0
export DEBIAN_FRONTEND=noninteractive
CHANGED=0
say(){ echo "[$(date +%T)] soal20 prab: $*"; }
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
if ! grep -q 'zone "K-49.com"' /etc/bind/named.conf.local || [ ! -s /etc/bind/K-49/K-49.com ]; then
  put /etc/bind/named.conf.local <<'SOAL20_EOF'
zone "K-49.com" {
    type master;
    notify yes;
    also-notify { 10.88.3.3; };
    allow-transfer { 10.88.3.3; };
    file "/etc/bind/K-49/K-49.com";
};

zone "88.10.in-addr.arpa" {
    type master;
    notify yes;
    also-notify { 10.88.3.3; };
    allow-transfer { 10.88.3.3; };
    file "/etc/bind/K-49/88.10.in-addr.arpa";
};
SOAL20_EOF
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
  putnew /etc/bind/K-49/K-49.com <<'SOAL20_EOF'
$TTL    604800
@       IN      SOA     prab.K-49.com. root.K-49.com. (
                        2026093007 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.K-49.com.
@       IN      NS      tedd.K-49.com.
prab    IN      A       10.88.3.2
tedd    IN      A       10.88.3.3
@       IN      A       10.88.5.2
rootkit IN      A       10.88.3.1
alpha   IN      A       10.88.1.2
beta    IN      A       10.88.1.3
gamma   IN      A       10.88.1.4
delta   IN      A       10.88.2.2
epsilon IN      A       10.88.2.3
abbey  IN  A  10.88.4.2
penny   IN      A       10.88.5.2
obladi  IN      A       10.88.3.4
desmond IN      A       10.88.3.5
oblada  IN      A       10.88.3.6
molly   IN      A       10.88.3.7
vault   IN  A      10.88.3.4
vault   IN  A      10.88.3.5
core    IN  A      10.88.3.6
core    IN  A      10.88.3.7
www     IN  CNAME  penny.K-49.com.
static  IN  CNAME  abbey.K-49.com.
alpha   IN  TXT    "alpha"
beta    IN  TXT    "beta"
gamma   IN  TXT    "gamma"
delta   IN  TXT    "delta"
epsilon IN  TXT    "epsilon"
outbound   IN  CNAME  http.badssl.com.
SOAL20_EOF
  putnew /etc/bind/K-49/88.10.in-addr.arpa <<'SOAL20_EOF'
$TTL    604800
@       IN      SOA     prab.K-49.com. root.K-49.com. (
                        2026092901 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.K-49.com.
@       IN      NS      tedd.K-49.com.
2.4     IN      PTR     abbey.K-49.com.
2.5     IN      PTR     penny.K-49.com.
4.3     IN      PTR     vault.K-49.com.
5.3     IN      PTR     vault.K-49.com.
6.3     IN      PTR     core.K-49.com.
7.3     IN      PTR     core.K-49.com.
SOAL20_EOF
fi
ensure bind9
say "done"
