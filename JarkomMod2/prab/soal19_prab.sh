#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com

cat >> $ZONE <<'REC'
outbound   IN  CNAME  http.badssl.com.
REC

# naikkan serial 2026093006 -> 2026093007
sed -i 's/2026093006/2026093007/' $ZONE

named-checkzone K-49.com $ZONE && rndc reload
