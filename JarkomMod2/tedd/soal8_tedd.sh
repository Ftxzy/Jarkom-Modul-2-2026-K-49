#!/bin/bash
cat >> /etc/bind/named.conf.local << 'CONF'

zone "88.10.in-addr.arpa" {
    type slave;
    masters { 10.88.3.2; };
    file "/var/cache/bind/db.88.10.in-addr.arpa";
};
CONF
rndc reload
