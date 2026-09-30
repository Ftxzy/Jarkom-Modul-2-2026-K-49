#!/bin/bash
mkdir -p /etc/bind/K-49

cat > /etc/bind/named.conf.local << 'CONF'
zone "K-49.com" {
    type master;
    notify yes;
    also-notify { 10.88.3.3; };
    allow-transfer { 10.88.3.3; };
    file "/etc/bind/K-49/K-49.com";
};
CONF

cat > /etc/bind/K-49/K-49.com << 'ZONE'
$TTL    604800
@       IN      SOA     prab.K-49.com. root.K-49.com. (
                        2026092802 ; Serial
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
abbey   IN      A       10.88.4.2
penny   IN      A       10.88.5.2
obladi  IN      A       10.88.3.4
desmond IN      A       10.88.3.5
oblada  IN      A       10.88.3.6
molly   IN      A       10.88.3.7
ZONE

cat > /etc/bind/named.conf.options << 'OPT'
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
OPT

cat > /root/init.sh << 'INIT'
#!/bin/sh
service bind9 start
INIT
chmod +x /root/init.sh

service bind9 restart
