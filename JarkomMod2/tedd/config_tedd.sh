#!/bin/bash
cat > /etc/bind/named.conf.local << 'CONF'
zone "K-49.com" {
    type slave;
    masters { 10.88.3.2; };
    file "/var/cache/bind/db.K-49.com";
};
CONF

cat > /root/init.sh << 'INIT'
#!/bin/sh
service bind9 start
INIT
chmod +x /root/init.sh

service bind9 restart
