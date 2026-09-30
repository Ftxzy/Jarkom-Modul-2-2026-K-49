#!/bin/bash
apt update
apt install -y bind9 bind9-utils dnsutils
sed -i 's/dnssec-validation auto;/dnssec-validation no;/' /etc/bind/named.conf.options
cat >> /etc/bind/named.conf.local <<'CONF'
zone "K-49.com" { type forward; forward only; forwarders { 10.88.3.2; }; };
CONF
named-checkconf && service bind9 restart
