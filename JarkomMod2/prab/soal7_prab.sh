#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com

cat >> $ZONE <<'REC'
vault   IN  A      10.88.3.4
vault   IN  A      10.88.3.5
core    IN  A      10.88.3.6
core    IN  A      10.88.3.7
www     IN  CNAME  penny.K-49.com.
static  IN  CNAME  abbey.K-49.com.
REC

# naikkan serial 2026092802 -> 2026092803
sed -i 's/2026092802/2026092803/' $ZONE

named-checkzone K-49.com $ZONE && rndc reload
