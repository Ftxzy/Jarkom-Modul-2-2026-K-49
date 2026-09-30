#!/bin/bash
cat >> /etc/bind/named.conf.local << 'CONF'

zone "88.10.in-addr.arpa" {
    type master;
    notify yes;
    also-notify { 10.88.3.3; };
    allow-transfer { 10.88.3.3; };
    file "/etc/bind/K-49/88.10.in-addr.arpa";
};
CONF

cat > /etc/bind/K-49/88.10.in-addr.arpa << 'ZONE'
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
ZONE

named-checkzone 88.10.in-addr.arpa /etc/bind/K-49/88.10.in-addr.arpa && rndc reload
