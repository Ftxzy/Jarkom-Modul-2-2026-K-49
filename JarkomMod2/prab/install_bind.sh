#!/bin/bash
apt-get update
apt-get install -y bind9
[ -e /etc/init.d/bind9 ] || ln -s /etc/init.d/named /etc/init.d/bind9
